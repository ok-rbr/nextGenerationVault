-- notes/commands.lua
-- Custom commands for note-taking workflow

local utils = require("notes.utils")
local frontmatter = require("notes.frontmatter")
local queries = require("notes.queries")
local periodic = require("notes.periodic")
local links = require("notes.links")

local M = {}

local function enable_markdown_lists()
  require("lazy").load({
    plugins = { "autolist.nvim" },
  })
end

-- ============================================================================
-- NOTE OPERATIONS
-- ============================================================================

---Create a new note with frontmatter
---@param opts table Options {type: string, name?: string}
function M.new_note(opts)
  opts = opts or {}
  local note_type = opts.type or "note"

  -- Get note name
  local name = opts.name or utils.prompt_text("Note name")
  if not name then
    vim.notify("Note creation cancelled", vim.log.levels.WARN)
    return
  end

  local slug = utils.slugify(name)
  if slug == "" then
    vim.notify("Note title must contain at least one letter or number", vim.log.levels.ERROR)
    return
  end

  local root = utils.get_notebook_root()
  local notes_config = require("notes.init").config
  local subdir = ""

  if note_type == "project" then
    subdir = notes_config.directories.projects
  elseif note_type == "area" then
    subdir = notes_config.directories.areas
  elseif note_type == "knowledge" then
    subdir = notes_config.directories.knowledge
  elseif note_type == "resource" then
    subdir = notes_config.directories.resources
  end

  local stem = utils.unique_note_stem(root, subdir, name)
  local filename = stem .. ".md"
  local filepath = utils.path_join(root, subdir, filename)
  if utils.path_is_taken(filepath) then
    vim.notify("Note creation aborted: target already exists at " .. filepath, vim.log.levels.ERROR)
    return
  end

  local dir = vim.fn.fnamemodify(filepath, ":h")
  if not utils.ensure_dir(dir) then
    vim.notify("Failed to create note directory: " .. dir, vim.log.levels.ERROR)
    return
  end

  -- Create file
  vim.cmd("edit " .. vim.fn.fnameescape(filepath))
  vim.bo.filetype = "markdown"

  -- Insert frontmatter based on type
  local fm_data
  local fm_opts = { name = name, id = stem }
  if note_type == "project" then
    fm_data = frontmatter.build_project(fm_opts)
  elseif note_type == "area" then
    fm_data = frontmatter.build_area(fm_opts)
  elseif note_type == "knowledge" then
    fm_data = frontmatter.build_knowledge(fm_opts)
  elseif note_type == "task" then
    fm_data = frontmatter.build_task(fm_opts)
  elseif note_type == "meeting" then
    fm_data = frontmatter.build_meeting(fm_opts)
  elseif note_type == "person" then
    fm_data = frontmatter.build_person(fm_opts)
  else
    fm_data = frontmatter.build_note(fm_opts)
  end

  frontmatter.insert_frontmatter(fm_data)

  -- Move cursor after frontmatter
  vim.cmd("normal! G")

  vim.notify(string.format("Created %s note: %s", note_type, filename), vim.log.levels.INFO)
end

---Move or rename a note and update inbound links.
---@param current_file string Absolute path of the note being moved
---@param new_path string Absolute path the note is expected to end up at
---@return boolean Success
local function move_note_with_links(current_file, new_path)
  local new_stem = vim.fn.fnamemodify(new_path, ":t:r")
  local ok, err = links.move_note(current_file, new_path, new_stem)
  if not ok then
    vim.notify("Move aborted: " .. tostring(err), vim.log.levels.ERROR)
    return false
  end
  return true
end

---Archive current note (move to archive and update status)
function M.archive_note()
  local current_file = vim.fn.expand("%:p")

  if not utils.file_exists(current_file) then
    vim.notify("No file to archive", vim.log.levels.WARN)
    return
  end

  -- Confirm
  if not utils.confirm("Archive this note?") then
    return
  end

  local root = utils.get_notebook_root()
  local notes_config = require("notes.init").config
  local filename = vim.fn.fnamemodify(current_file, ":t")
  local archive_path = utils.path_join(root, notes_config.directories.archive, filename)

  if utils.path_is_taken(archive_path) then
    vim.notify("Archive aborted: file already exists or is open at " .. archive_path, vim.log.levels.ERROR)
    return
  end

  -- Parse frontmatter and update status
  local fm = frontmatter.parse_current_buffer()
  if fm then
    local ok = frontmatter.update_frontmatter({ status = "archived", archived = utils.now_iso() })
    if not ok then
      vim.notify("Failed to update frontmatter, aborting archive", vim.log.levels.ERROR)
      return
    end
  end

  vim.cmd("write")

  -- Ensure archive directory exists
  local archive_dir = vim.fn.fnamemodify(archive_path, ":h")
  if not utils.ensure_dir(archive_dir) then
    vim.notify("Failed to create archive directory: " .. archive_dir, vim.log.levels.ERROR)
    return
  end

  -- Move the file and rewrite every link that pointed into it
  if not move_note_with_links(current_file, archive_path) then
    return
  end

  vim.notify("Note archived: " .. filename, vim.log.levels.INFO)
end

---Delete the current Markdown note from the configured notebook.
function M.delete_note()
  local current_file = vim.fn.expand("%:p")

  if not utils.file_exists(current_file) then
    vim.notify("No file to delete", vim.log.levels.WARN)
    return
  end

  if vim.bo.filetype ~= "markdown" or vim.fn.fnamemodify(current_file, ":e"):lower() ~= "md" then
    vim.notify("Only Markdown notes can be deleted", vim.log.levels.WARN)
    return
  end

  if not utils.in_notebook(current_file) then
    vim.notify("Only notes inside the configured notebook can be deleted", vim.log.levels.WARN)
    return
  end

  if vim.bo.modified then
    vim.notify("Save or discard changes before deleting this note", vim.log.levels.WARN)
    return
  end

  local filename = vim.fn.fnamemodify(current_file, ":t")
  if not utils.confirm("Permanently delete " .. filename .. "?") then
    return
  end

  if vim.fn.delete(current_file) ~= 0 then
    vim.notify("Failed to delete note: " .. current_file, vim.log.levels.ERROR)
    return
  end

  vim.cmd("bdelete")
  vim.notify("Note deleted: " .. filename, vim.log.levels.INFO)
end

---Rename current note and update title in frontmatter
function M.rename_note()
  local current_file = vim.fn.expand("%:p")

  if not utils.file_exists(current_file) then
    vim.notify("No file to rename", vim.log.levels.WARN)
    return
  end

  -- Prompt with the human title, not the filename stem. The answer is used as
  -- the new `title` and `aliases[1]` and is only slugified on its way into the
  -- filename, so offering `20260921_1030_my_note` for editing produced notes
  -- whose displayed name was their own slug.
  local old_stem = vim.fn.fnamemodify(current_file, ":t:r")
  local current_fm = frontmatter.parse_current_buffer()
  local old_name = (current_fm and type(current_fm.title) == "string" and current_fm.title ~= "" and current_fm.title)
    or old_stem

  local new_name = utils.prompt_text("New title", old_name)

  if not new_name or new_name == "" or new_name == old_name then
    vim.notify("Rename cancelled", vim.log.levels.WARN)
    return
  end

  local periodic_categories = { daily = true, weekly = true, monthly = true }
  if current_fm and periodic_categories[current_fm.category] then
    if not frontmatter.update_frontmatter({ title = new_name, id = old_stem }) then
      vim.notify("Failed to update periodic note title", vim.log.levels.ERROR)
      return
    end
    vim.cmd("write")
    vim.notify("Periodic note title updated; its canonical filename and ID were kept", vim.log.levels.INFO)
    return
  end

  -- Generate new filename (keep ID if present)
  local id_part = old_stem:match("^(%d+_%d+)")
  local slug = utils.slugify(new_name)
  if slug == "" then
    vim.notify("New title must contain at least one letter or number", vim.log.levels.ERROR)
    return
  end
  local new_filename
  if id_part then
    new_filename = string.format("%s_%s.md", id_part, slug)
  else
    new_filename = string.format("%s_%s.md", utils.now_id(), slug)
  end

  local new_stem = new_filename:gsub("%.md$", "")
  local new_path = vim.fn.fnamemodify(current_file, ":h") .. "/" .. new_filename

  -- Refuse to silently overwrite an existing note with the same filename
  if new_path ~= current_file and utils.path_is_taken(new_path) then
    vim.notify("Rename aborted: file already exists or is open at " .. new_path, vim.log.levels.ERROR)
    return
  end

  -- Move first, then relabel so inbound links are rewritten from the current
  -- id before the frontmatter changes.
  if not move_note_with_links(current_file, new_path) then
    return
  end

  -- Relabel the moved note: `title` for humans and `id` so it keeps matching
  -- its own filename. `aliases` is deliberately not passed —
  -- update_frontmatter adds the new title to the list and keeps the old one,
  -- so the note stays reachable under the name it was linked by before.
  local ok = frontmatter.update_frontmatter({ title = new_name, id = new_stem })
  if not ok then
    vim.notify("Renamed, but failed to update frontmatter of " .. new_filename, vim.log.levels.ERROR)
    return
  end
  vim.cmd("write")

  vim.notify("Note renamed to: " .. new_filename .. " (inbound links rewritten)", vim.log.levels.INFO)
end

---Update status of current note
function M.update_status()
  local fm = frontmatter.parse_current_buffer()
  if not fm then
    vim.notify("No frontmatter found", vim.log.levels.WARN)
    return
  end

  local current_status = fm.status or "unknown"
  local new_status = utils.prompt_text("New status", current_status)

  if not new_status or new_status == "" then
    return
  end

  local ok = frontmatter.update_frontmatter({ status = new_status })
  if not ok then
    vim.notify("Failed to update frontmatter", vim.log.levels.ERROR)
    return
  end
  vim.cmd("write")

  vim.notify("Status updated to: " .. new_status, vim.log.levels.INFO)
end

---Add tag to current note
function M.add_tag()
  local fm = frontmatter.parse_current_buffer()
  if not fm then
    vim.notify("No frontmatter found", vim.log.levels.WARN)
    return
  end

  local new_tag = utils.prompt_text("Tag to add")
  if not new_tag or new_tag == "" then
    return
  end

  -- Ensure tags is a table (preserve any existing string tag instead of discarding it)
  fm.tags = utils.normalize_tags(fm.tags)

  -- Check if tag already exists
  if vim.tbl_contains(fm.tags, new_tag) then
    vim.notify("Tag already exists: " .. new_tag, vim.log.levels.WARN)
    return
  end

  table.insert(fm.tags, new_tag)
  local ok = frontmatter.update_frontmatter({ tags = fm.tags })
  if not ok then
    vim.notify("Failed to update frontmatter", vim.log.levels.ERROR)
    return
  end
  vim.cmd("write")

  vim.notify("Tag added: " .. new_tag, vim.log.levels.INFO)
end

---Open the note for one period, creating it first if it does not exist.
---
---The file name stem comes from the period (notes.periodic), never from a
---prompt, and it is also the note's id: the native resolver handles [[wiki-links]]
---against the id, so `[[2026_w39]]` has to land on `2026_w39.md`
---(docs/ADR-005). An existing note is opened as is and never rewritten.
---@param note table {spec: notes.PeriodicSpec, dir: string, templates: string[], replacements: table, frontmatter: table, body: string, label: string}
local function open_periodic_note(note)
  local root = utils.get_notebook_root()
  local notes_config = require("notes.init").config
  local dir = utils.path_join(root, note.dir)
  if not utils.ensure_dir(dir) then
    vim.notify("Failed to create periodic note directory: " .. dir, vim.log.levels.ERROR)
    return
  end

  local filename = note.spec.stem .. ".md"
  local filepath = utils.path_join(dir, filename)

  -- If file exists, open it
  if utils.file_exists(filepath) then
    vim.cmd("edit " .. vim.fn.fnameescape(filepath))
    vim.bo.filetype = "markdown"
    enable_markdown_lists()
    return
  end

  local template_path = nil
  local tmpl_dir = utils.path_join(root, notes_config.directories.templates)
  for _, name in ipairs(note.templates) do
    local candidate = utils.path_join(tmpl_dir, name)
    if utils.file_exists(candidate) then
      template_path = candidate
      break
    end
  end

  vim.cmd("edit " .. vim.fn.fnameescape(filepath))
  vim.bo.filetype = "markdown"
  enable_markdown_lists()

  if template_path then
    -- Use template system with the period's variables pre-filled
    local lines = vim.fn.readfile(template_path)
    local content = table.concat(lines, "\n")
    local replacements = vim.tbl_extend("force", {
      id = note.spec.stem,
      title = note.spec.title,
      created = utils.now_iso(),
      current_date = utils.date_iso(),
      previous = note.spec.previous,
      next = note.spec.next,
    }, note.replacements)
    for variable, value in pairs(replacements) do
      content = content:gsub("{{%s*" .. variable .. "%s*}}", function()
        return value
      end)
    end
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(content, "\n"))
  else
    -- Fallback: build frontmatter + minimal template content
    frontmatter.insert_frontmatter(note.frontmatter)
    vim.api.nvim_buf_set_lines(0, -1, -1, false, vim.split(note.body, "\n"))
  end

  local existing_frontmatter = frontmatter.parse_current_buffer()
  if existing_frontmatter then
    if not frontmatter.update_frontmatter({ id = note.spec.stem, title = note.spec.title }) then
      vim.notify("Failed to set periodic note identity", vim.log.levels.ERROR)
      return
    end
  elseif template_path then
    frontmatter.insert_frontmatter(note.frontmatter)
  end

  -- Move cursor to end
  vim.cmd("normal! G")
  vim.cmd("nohlsearch")

  vim.notify("Created " .. note.label .. " note: " .. filename, vim.log.levels.INFO)
end

---Create daily note for today (or specified date)
---@param date? string YYYY-MM-DD
function M.daily_note(date)
  local spec, err = periodic.day(date)
  if not spec then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  open_periodic_note({
    spec = spec,
    label = "daily",
    dir = require("notes.init").config.directories.daily,
    templates = periodic.template_names.daily,
    replacements = { date = spec.key, current_date = spec.key },
    frontmatter = frontmatter.build_daily(spec.key),
    body = "## What will we do today?\n\n-\n",
  })
end

---Create or open the weekly review note for this ISO week (or a given one)
---@param week? string YYYY-Www
function M.weekly_note(week)
  local spec, err = periodic.week(week)
  if not spec then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  open_periodic_note({
    spec = spec,
    label = "weekly",
    dir = require("notes.init").config.directories.weekly,
    templates = periodic.template_names.weekly,
    replacements = { week = spec.key, week_start = spec.start, week_end = spec.finish },
    frontmatter = frontmatter.build_weekly(spec),
    body = string.format(
      [=[
# %s

%s to %s · [[%s|previous]] · [[%s|next]]

## Achievements

-

## Challenges

-

## Learnings

-

## Next week

1.
2.
3.
]=],
      spec.title,
      spec.start,
      spec.finish,
      spec.previous,
      spec.next
    ),
  })
end

---Create or open the monthly review note for this month (or a given one)
---@param month? string YYYY-MM
function M.monthly_note(month)
  local spec, err = periodic.month(month)
  if not spec then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  open_periodic_note({
    spec = spec,
    label = "monthly",
    dir = require("notes.init").config.directories.monthly,
    templates = periodic.template_names.monthly,
    replacements = { month = spec.key, month_start = spec.start, month_end = spec.finish },
    frontmatter = frontmatter.build_monthly(spec),
    body = string.format(
      [=[
# %s

%s to %s · [[%s|previous]] · [[%s|next]]

## Highlights

-

## What did not work

-

## Goals for next month

1.
2.
3.
]=],
      spec.title,
      spec.start,
      spec.finish,
      spec.previous,
      spec.next
    ),
  })
end

-- ============================================================================
-- LINK INSERTION
-- ============================================================================
-- Wiki-link creation and following are implemented in notes.links; Marksman
-- supplies Markdown LSP completion and diagnostics.

---Insert an external markdown link [text](url) at cursor position
function M.insert_ext_link()
  local text = utils.prompt_text("Link text")
  if not text or text == "" then
    return
  end
  local url = utils.prompt_text("URL")
  if not url or url == "" then
    return
  end

  local link = string.format("[%s](%s)", text, url)
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local new_line = line:sub(1, pos[2]) .. link .. line:sub(pos[2] + 1)
  vim.api.nvim_set_current_line(new_line)
  vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] + #link })
end

---Return the target of the wiki-link under the cursor, without label or fragment.
---@return string|nil
local function wiki_link_title_at_cursor()
  local link = links.link_at_cursor()
  if not link or link.kind ~= "wiki" or link.target == "" then
    return nil
  end
  return link.target
end

---Create a note from a template using the wiki-link under the cursor as title.
function M.template_from_wiki_link()
  local title = wiki_link_title_at_cursor()
  if not title then
    vim.notify("Place the cursor inside a [[wiki-link]] with a title", vim.log.levels.WARN)
    return
  end

  require("notes.templates").pick_template({ title = title })
end

-- ============================================================================
-- CHECKBOX TOGGLE
-- ============================================================================

---Toggle checkbox on current line: [ ] <-> [x]
---Works in all markdown buffers
function M.toggle_checkbox()
  local line = vim.api.nvim_get_current_line()
  local new_line

  if line:match("%- %[x%]") then
    new_line = line:gsub("%- %[x%]", "- [ ]", 1)
  elseif line:match("%- %[ %]") then
    new_line = line:gsub("%- %[ %]", "- [x]", 1)
  else
    -- Convert plain list item to checkbox
    new_line = line:gsub("^(%s*)%- ", "%1- [ ] ", 1)
  end

  if new_line and new_line ~= line then
    vim.api.nvim_set_current_line(new_line)
  end
end

-- ============================================================================
-- SETUP FUNCTION
-- ============================================================================

---Setup commands and keymaps
function M.setup()
  -- Create user commands
  vim.api.nvim_create_user_command("NoteNew", function(opts)
    M.new_note({ type = opts.args })
  end, {
    nargs = "?",
    complete = function()
      return { "project", "area", "knowledge", "task", "meeting", "person", "note" }
    end,
    desc = "Create a new note",
  })

  vim.api.nvim_create_user_command("NoteArchive", M.archive_note, {
    desc = "Archive current note",
  })

  vim.api.nvim_create_user_command("NoteDelete", M.delete_note, {
    desc = "Delete current Markdown note",
  })

  vim.api.nvim_create_user_command("NoteRename", M.rename_note, {
    desc = "Rename current note",
  })

  vim.api.nvim_create_user_command("NoteStatus", M.update_status, {
    desc = "Update note status",
  })

  vim.api.nvim_create_user_command("NoteTag", M.add_tag, {
    desc = "Add tag to current note",
  })

  vim.api.nvim_create_user_command("NoteDaily", function(opts)
    M.daily_note(opts.args ~= "" and opts.args or nil)
  end, {
    nargs = "?",
    desc = "Create or open daily note",
  })

  vim.api.nvim_create_user_command("NoteWeekly", function(opts)
    M.weekly_note(opts.args ~= "" and opts.args or nil)
  end, {
    nargs = "?",
    desc = "Create or open weekly review note (YYYY-Www)",
  })

  vim.api.nvim_create_user_command("NoteMonthly", function(opts)
    M.monthly_note(opts.args ~= "" and opts.args or nil)
  end, {
    nargs = "?",
    desc = "Create or open monthly review note (YYYY-MM)",
  })

  -- Template command - passes a wiki-link target to the picker when available.
  vim.api.nvim_create_user_command("NoteTemplate", function()
    local templates = require("notes.templates")
    local title = wiki_link_title_at_cursor()
    templates.pick_template(title and { title = title } or nil)
  end, {
    desc = "Create note from template (fuzzy search)",
  })

  vim.api.nvim_create_user_command("NoteTemplateFromLink", M.template_from_wiki_link, {
    desc = "Create note from template using wiki-link title under cursor",
  })

  -- Project generator command
  vim.api.nvim_create_user_command("NoteProjectCreate", function(opts)
    local project_gen = require("notes.project_generator")
    project_gen.create_project()
  end, {
    desc = "Create new project with templates and client index",
  })

  -- Query commands
  vim.api.nvim_create_user_command("NoteQueryTasks", queries.active_tasks, {
    desc = "Query active tasks",
  })

  vim.api.nvim_create_user_command("NoteQueryTasksPending", queries.pending_tasks, {
    desc = "Query pending tasks",
  })

  vim.api.nvim_create_user_command("NoteQueryTasksClosed", queries.closed_tasks, {
    desc = "Query closed tasks",
  })

  vim.api.nvim_create_user_command("NoteQueryTasksDone", queries.completed_tasks, {
    desc = "Query completed tasks",
  })

  vim.api.nvim_create_user_command("NoteQueryTasksProject", function(opts)
    queries.tasks_by_project(opts.args ~= "" and opts.args or nil)
  end, {
    nargs = "?",
    desc = "Query tasks by project",
  })

  vim.api.nvim_create_user_command("NoteQueryProjects", queries.active_projects, {
    desc = "Query active projects",
  })

  vim.api.nvim_create_user_command("NoteQueryProjectsArchived", queries.archived_projects, {
    desc = "Query archived projects",
  })

  vim.api.nvim_create_user_command("NoteQueryClient", function(opts)
    queries.by_client(opts.args ~= "" and opts.args or nil)
  end, {
    nargs = "?",
    desc = "Query notes by client slug",
  })

  vim.api.nvim_create_user_command("NoteQueryMeetings", function(opts)
    if opts.args ~= "" then
      queries.meetings_by_date(opts.args)
    else
      queries.all_meetings()
    end
  end, {
    nargs = "?",
    desc = "Query today's and upcoming meetings (optionally by date YYYY-MM-DD)",
  })

  vim.api.nvim_create_user_command("NoteQueryKnowledge", function(opts)
    queries.knowledge_notes(opts.args ~= "" and opts.args or nil)
  end, {
    nargs = "?",
    desc = "Query knowledge notes (optionally by type)",
  })

  vim.api.nvim_create_user_command("NoteQueryPeople", queries.people, {
    desc = "Query people/contacts",
  })

  vim.api.nvim_create_user_command("NoteQueryTag", function(opts)
    queries.by_tag(opts.args)
  end, {
    nargs = "?",
    desc = "Query notes by tag",
  })

  vim.api.nvim_create_user_command("NoteQueryRecent", function(opts)
    local days = tonumber(opts.args) or 7
    queries.recent_notes(days)
  end, {
    nargs = "?",
    desc = "Query recent notes (default: 7 days)",
  })

  vim.api.nvim_create_user_command("NoteInsertExtLink", M.insert_ext_link, {
    desc = "Insert [text](url) external link at cursor",
  })

  vim.api.nvim_create_user_command("NoteLink", links.insert, {
    range = true,
    desc = "Pick a vault note and insert a wiki-link (a range links the selection)",
  })
  vim.api.nvim_create_user_command("NoteLinkNew", links.insert_new, {
    range = true,
    desc = "Link the selection to a new note titled after it",
  })
  vim.api.nvim_create_user_command("NoteFollowLink", function()
    links.follow()
  end, {
    desc = "Follow the link under the cursor",
  })
  vim.api.nvim_create_user_command("NoteBacklinks", links.show_backlinks, {
    desc = "List notes that link to the current note",
  })
  vim.api.nvim_create_user_command("NoteLinks", links.show_outgoing_links, {
    desc = "List the links in the current note",
  })
  vim.api.nvim_create_user_command("NoteSwitch", links.quick_switch, {
    desc = "Open a vault note by title, alias or path",
  })
  vim.api.nvim_create_user_command("NoteSearch", links.search, {
    desc = "Full-text search across the vault",
  })
  vim.api.nvim_create_user_command("NotePasteImage", links.paste_image, {
    desc = "Save the clipboard image to the vault and embed it",
  })
  vim.api.nvim_create_user_command("NoteOpenInObsidian", links.open_in_app, {
    desc = "Open the current note in the Obsidian app",
  })

  -- Keymaps (prefixed with <leader>n for notes)
  local keymap = vim.keymap.set
  local opts = { silent = true }

  -- Template picker (main way to create notes)
  keymap("n", "<leader>nT", function()
    local templates = require("notes.templates")
    local title = wiki_link_title_at_cursor()
    templates.pick_template(title and { title = title } or nil)
  end, vim.tbl_extend("force", opts, { desc = "[N]ote from [T]emplate (fuzzy)" }))

  keymap(
    "n",
    "<leader>nt",
    M.template_from_wiki_link,
    vim.tbl_extend("force", opts, { desc = "[N]ote from [T]itle in wiki-link" })
  )

  -- Periodic notes (special case, commonly used). Capitals for weekly and
  -- monthly: <leader>nw is the workflow prefix (calendar, tasks, health).
  keymap("n", "<leader>nd", M.daily_note, vim.tbl_extend("force", opts, { desc = "[N]ote [D]aily" }))
  keymap("n", "<leader>nW", M.weekly_note, vim.tbl_extend("force", opts, { desc = "[N]ote [W]eekly review" }))
  keymap("n", "<leader>nM", M.monthly_note, vim.tbl_extend("force", opts, { desc = "[N]ote [M]onthly review" }))

  -- Project creation
  keymap("n", "<leader>np", function()
    local project_gen = require("notes.project_generator")
    project_gen.create_project()
  end, vim.tbl_extend("force", opts, { desc = "[N]ote new [P]roject" }))

  -- Note operations
  keymap("n", "<leader>na", M.archive_note, vim.tbl_extend("force", opts, { desc = "[N]ote [A]rchive" }))
  keymap("n", "<leader>nx", M.delete_note, vim.tbl_extend("force", opts, { desc = "[N]ote delete ([X])" }))
  keymap("n", "<leader>nr", M.rename_note, vim.tbl_extend("force", opts, { desc = "[N]ote [R]ename" }))
  keymap("n", "<leader>nu", M.update_status, vim.tbl_extend("force", opts, { desc = "[N]ote [U]pdate status" }))
  keymap("n", "<leader>ng", M.add_tag, vim.tbl_extend("force", opts, { desc = "[N]ote add ta[G]" }))

  -- Vault links (<leader>o, the namespace obsidian.nvim used; docs/ADR-005)
  local function link_map(mode, lhs, rhs, desc)
    keymap(mode, lhs, function()
      rhs()
    end, vim.tbl_extend("force", opts, { desc = desc }))
  end
  link_map("n", "<leader>ni", links.insert, "[N]ote [I]nsert wiki-link")
  link_map({ "n", "x" }, "<leader>oi", links.insert, "[O]bsidian l[I]nk (selection) to note")
  link_map("x", "<leader>oN", links.insert_new, "[O]bsidian link selection to [N]ew note")
  link_map("n", "<leader>of", links.follow, "[O]bsidian [F]ollow link")
  link_map("n", "<leader>ob", links.show_backlinks, "[O]bsidian [B]acklinks")
  link_map("n", "<leader>ol", links.show_outgoing_links, "[O]bsidian [L]inks in note")
  link_map("n", "<leader>oq", links.quick_switch, "[O]bsidian [Q]uick switch")
  link_map("n", "<leader>os", links.search, "[O]bsidian [S]earch vault")
  link_map("n", "<leader>ot", queries.by_tag, "[O]bsidian [T]ag search")
  link_map("n", "<leader>or", M.rename_note, "[O]bsidian [R]ename (updates links)")
  link_map("n", "<leader>op", links.paste_image, "[O]bsidian [P]aste image")
  link_map("n", "<leader>oo", links.open_in_app, "[O]bsidian [O]pen in app")
  keymap(
    { "n", "i" },
    "<leader>nL",
    M.insert_ext_link,
    vim.tbl_extend("force", opts, { desc = "[N]ote insert ext [L]ink [text](url)" })
  )

  -- Queries
  keymap("n", "<leader>nqt", queries.active_tasks, vim.tbl_extend("force", opts, { desc = "[N]ote [Q]uery [T]asks" }))
  keymap(
    "n",
    "<leader>nqP",
    queries.pending_tasks,
    vim.tbl_extend("force", opts, { desc = "[N]ote [Q]uery [P]ending tasks" })
  )
  keymap(
    "n",
    "<leader>nqX",
    queries.closed_tasks,
    vim.tbl_extend("force", opts, { desc = "[N]ote [Q]uery [X] closed tasks" })
  )
  keymap(
    "n",
    "<leader>nqf",
    queries.tasks_by_project,
    vim.tbl_extend("force", opts, { desc = "[N]ote [Q]uery tasks by project [F]ilter" })
  )
  keymap(
    "n",
    "<leader>nqp",
    queries.active_projects,
    vim.tbl_extend("force", opts, { desc = "[N]ote [Q]uery [P]rojects" })
  )
  keymap(
    "n",
    "<leader>nqC",
    queries.by_client,
    vim.tbl_extend("force", opts, { desc = "[N]ote [Q]uery by [C]lient slug" })
  )
  keymap(
    "n",
    "<leader>nqm",
    queries.all_meetings,
    vim.tbl_extend("force", opts, { desc = "[N]ote [Q]uery upcoming [M]eetings" })
  )
  keymap(
    "n",
    "<leader>nqk",
    queries.knowledge_notes,
    vim.tbl_extend("force", opts, { desc = "[N]ote [Q]uery [K]nowledge" })
  )
  keymap("n", "<leader>nqc", queries.people, vim.tbl_extend("force", opts, { desc = "[N]ote [Q]uery [C]ontacts" }))
  keymap("n", "<leader>nqr", queries.recent_notes, vim.tbl_extend("force", opts, { desc = "[N]ote [Q]uery [R]ecent" }))
  keymap("n", "<leader>nqg", queries.by_tag, vim.tbl_extend("force", opts, { desc = "[N]ote [Q]uery by ta[G]" }))

  -- Checkbox toggle for markdown buffers. Lives under <leader>n like every
  -- other lua/notes/ binding; <leader>w is no longer a note-taking namespace
  -- (docs/ADR-005 stage 3).
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("voidcore-notes-checkbox-markdown", { clear = true }),
    pattern = "markdown",
    callback = function()
      vim.keymap.set(
        "n",
        "<leader>nc",
        M.toggle_checkbox,
        { buffer = true, silent = true, desc = "[N]ote toggle [C]heckbox [ ]/[x]" }
      )
    end,
  })

  -- VoidDash dashboard (sub-modules register their own commands via dashboard.setup())
  local ok_dash, dashboard = pcall(require, "notes.dashboard")
  if ok_dash then
    dashboard.setup()
  end
end

return M
