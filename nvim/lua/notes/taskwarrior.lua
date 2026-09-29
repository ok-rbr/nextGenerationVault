-- notes/taskwarrior.lua
-- Taskwarrior integration: capture, browse, and linked task notes.
--
-- Taskwarrior commands can browse tasks and create linked notes manually.
-- Automatic two-way synchronization is opt-in through
-- VOIDCORE_TASK_NOTE_SYNC=1 and is disabled by default.

local frontmatter = require("notes.frontmatter")
local utils = require("notes.utils")

local M = {}
local SYNC_ENV = "VOIDCORE_TASK_NOTE_SYNC"

local function sync_enabled()
  return vim.env[SYNC_ENV] == "1"
end

-- Applied to every invocation: no decoration around the payload, no ID
-- renumbering while we read, and no confirmation prompt — Neovim gives the
-- child process no stdin to answer one with.
local RC = { "rc.verbose=nothing", "rc.confirmation=off", "rc.gc=0" }

-- The vault's status vocabulary per Taskwarrior status; `active` is the
-- fallback because a status this table does not know is still open work.
local NOTE_STATUS = {
  pending = "active",
  waiting = "waiting",
  completed = "done",
  deleted = "deleted",
}

-- Note statuses that mean the work is finished, whichever word a template used.
local DONE_STATUS = { done = true, completed = true, closed = true, archived = true }

local PRIORITY_VALUES = {
  urgent = "H",
  high = "H",
  h = "H",
  medium = "M",
  normal = "M",
  m = "M",
  low = "L",
  l = "L",
}

local sync_note_buffer

-- ============================================================================
-- TASKWARRIOR ACCESS
-- ============================================================================

---Run `task` with the shared rc overrides.
---@param args string[] Arguments appended after the overrides
---@return string[]|nil lines, string|nil err
local function task_run(args, origin)
  local opts = origin == "nvim" and { env = { VOIDCORE_TASK_ORIGIN = "nvim" } } or nil
  return utils.run_command("task", vim.list_extend(vim.deepcopy(RC), args), opts)
end

---Normalize note priority labels to Taskwarrior's H/M/L values.
---@param value any
---@return string|nil
local function taskwarrior_priority(value)
  local normalized = vim.trim(tostring(value or "")):lower()
  return PRIORITY_VALUES[normalized]
end

---Export the tasks matching a filter, most urgent first.
---@param filter string Taskwarrior filter expression
---@return table[]|nil tasks, string|nil err
local function task_export(filter)
  local lines, err = task_run({ filter, "export" })
  if not lines then
    return nil, err
  end

  local ok, tasks = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok then
    return nil, "cannot parse `task export`: " .. tasks
  end

  -- `export` emits tasks in ID order, which is insertion order. Urgency is
  -- what makes a list of tasks a list of the *next* tasks.
  table.sort(tasks, function(a, b)
    return (a.urgency or 0) > (b.urgency or 0)
  end)
  return tasks
end

---Create the Taskwarrior task behind a newly created task note.
---@param bufnr number
---@return boolean
local function create_task_from_note(bufnr)
  local buffer_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local fm = frontmatter.parse_yaml(buffer_lines)
  if not fm or tostring(fm.category or "") ~= "task" or tostring(fm.task_uuid or "") ~= "" then
    return true
  end

  local title = vim.trim(tostring(fm.title or ""))
  local client = vim.trim(tostring(fm.client or ""))
  local project = vim.trim(tostring(fm.project or ""))
  if title == "" then
    vim.notify("Task note was not added to Taskwarrior: title is empty", vim.log.levels.ERROR)
    return false
  end
  if client == "" or project == "" then
    vim.notify("Task note was not added to Taskwarrior: client and project are required", vim.log.levels.ERROR)
    return false
  end
  if not utils.is_slug(client) or not utils.is_slug(project) then
    vim.notify("Task note was not added to Taskwarrior: client and project must be valid slugs", vim.log.levels.ERROR)
    return false
  end

  local relative, path_err = utils.relative_path(utils.get_notebook_root(), vim.api.nvim_buf_get_name(bufnr))
  if not relative then
    vim.notify("Task note was not added to Taskwarrior: " .. tostring(path_err), vim.log.levels.ERROR)
    return false
  end

  local args = {
    "add",
    title,
    "project:" .. client .. "." .. project,
    "client:" .. client,
  }
  for _, field in ipairs({ "due", "wait_until", "priority" }) do
    local value = vim.trim(tostring(fm[field] or ""))
    if value ~= "" then
      if field == "priority" then
        value = taskwarrior_priority(value)
        if not value then
          vim.notify(
            "Task note was not added to Taskwarrior: priority must be urgent, high, medium, low or H/M/L",
            vim.log.levels.ERROR
          )
          return false
        end
      end
      local task_field = field == "wait_until" and "wait" or field
      table.insert(args, task_field .. ":" .. value)
    end
  end

  local _, add_err = task_run(args, "nvim")
  if add_err then
    vim.notify("Task note was not added to Taskwarrior: " .. add_err, vim.log.levels.ERROR)
    return false
  end

  local tasks, export_err = task_export("+LATEST")
  local task = tasks and tasks[1]
  if not task or not task.uuid then
    vim.notify(
      "Task was added, but its UUID could not be read from Taskwarrior: " .. (export_err or "no task returned"),
      vim.log.levels.ERROR
    )
    return false
  end

  local _, link_err = task_run({ task.uuid, "modify", "note:" .. relative }, "nvim")
  if link_err then
    vim.notify("Task was added, but linking its note failed: " .. link_err, vim.log.levels.ERROR)
    return false
  end

  if not sync_note_buffer(bufnr, task) then
    vim.notify("Task was added, but its canonical fields could not be written to the note", vim.log.levels.ERROR)
    return false
  end
  vim.notify("Taskwarrior task created and linked: " .. title, vim.log.levels.INFO)
  return true
end

---Format the project suffix shared by every task line.
---@param task table
---@return string
local function project_suffix(task)
  return task.project and ("  [" .. task.project .. "]") or ""
end

---Convert a Taskwarrior timestamp (20260917T120000Z) to an ISO date.
---@param stamp string|nil
---@return string
local function iso_date(stamp)
  local year, month, day = tostring(stamp or ""):match("^(%d%d%d%d)(%d%d)(%d%d)T")
  return year and string.format("%s-%s-%s", year, month, day) or ""
end

-- ============================================================================
-- LINKED NOTES
-- ============================================================================

---Split a task into the two slugs of docs/WORK_TAXONOMY.md: the project
---`acme.migration` is client `acme` and project `migration`, and the `client`
---UDA wins over the hierarchy when it is set.
---@param task table
---@return string client, string project
local function slugs(task)
  local project = task.project or ""
  return task.client or project:match("^([^%.]+)%.") or "", project:match("([^%.]+)$") or ""
end

---The slice of the Taskwarrior model the note carries. Taskwarrior stays the
---source of truth; these fields are the copy the vault reads and edits.
---@param task table Decoded Taskwarrior task
---@return table
local function note_fields(task)
  local client, project = slugs(task)

  return {
    title = task.description,
    status = NOTE_STATUS[task.status] or "active",
    client = client,
    project = project,
    due = iso_date(task.due),
    wait_until = iso_date(task.wait),
    priority = task.priority or "",
    urgency = task.urgency,
    task_uuid = task.uuid,
  }
end

---Apply Taskwarrior's canonical values to a task-note buffer and persist them
---without re-entering the note-to-task autocmd.
---@param bufnr number
---@param task table
---@return boolean
sync_note_buffer = function(bufnr, task, status_override)
  local updated = false
  local fields = note_fields(task)
  if status_override then
    fields.status = status_override
  end

  vim.api.nvim_buf_call(bufnr, function()
    updated = frontmatter.update_frontmatter(fields)
    if updated then
      vim.cmd("noautocmd update")
    end
  end)

  return updated
end

---Locate the note template for a task: the project's own task template, as
---`:NoteProjectCreate` generates it, before the global one from notes.init.
---This is where the assumption lives that a Taskwarrior project and the
---generated project carry the same slug.
---@param task table Decoded Taskwarrior task
---@return string|nil filepath, string|nil err
local function task_template(task)
  local client, project = slugs(task)
  local config = require("notes.init").config
  local templates_root = utils.path_join(utils.get_notebook_root(), config.directories.templates)
  local project_templates_root = utils.path_join(templates_root, config.directories.projects)
  local project_names = {}

  if project ~= "" then
    project_names = { project .. "_task_default", project .. "_task" }

    if client ~= "" then
      for _, name in ipairs(project_names) do
        local filepath = utils.path_join(project_templates_root, client, project, name .. ".md")
        if utils.file_exists(filepath) then
          return filepath
        end
      end
    end

    -- Older vaults generated project templates without a client directory.
    for _, name in ipairs(project_names) do
      local filepath = utils.path_join(project_templates_root, project, name .. ".md")
      if utils.file_exists(filepath) then
        return filepath
      end
    end
  end

  local global_name = config.task_note_template
  local templates = require("notes.templates").discover_templates()
  for _, filepath in ipairs(templates) do
    if vim.fn.fnamemodify(filepath, ":t:r") == global_name then
      return filepath
    end
  end

  local tried = vim.deepcopy(project_names)
  table.insert(tried, global_name)
  return nil,
    string.format("no task note template in the vault templates directory (tried: %s)", table.concat(tried, ", "))
end

---Create the note for a task and link both sides.
---Mutations use the UUID: Taskwarrior renumbers IDs whenever it collects
---garbage, so an ID read a minute ago can already belong to another task.
---@param task table Decoded Taskwarrior task
local function create_note(task)
  local template, template_err = task_template(task)
  if not template then
    return vim.notify(template_err, vim.log.levels.ERROR)
  end

  local fields = note_fields(task)

  -- These values reach the template as {{ title }}, {{ project }}, {{ due }}
  -- and so on; pre-filling them also stops the template engine from prompting
  -- for what the task already answers.
  local created, filepath = require("notes.templates").create_from_template_file(template, fields)
  if not created then
    return
  end

  local relative, path_err = utils.relative_path(utils.get_notebook_root(), filepath)
  if not relative then
    vim.notify("Note created, but its path could not be linked: " .. tostring(path_err), vim.log.levels.ERROR)
    return
  end

  -- Written unconditionally: a template that omits a placeholder would
  -- otherwise produce a note the task cannot be found from.
  if not frontmatter.update_frontmatter(fields) then
    vim.notify("Task note has no frontmatter block — link not written", vim.log.levels.WARN)
    return
  end
  vim.cmd("write")

  local _, modify_err = task_run({ task.uuid, "modify", "note:" .. relative })
  if modify_err then
    vim.notify("Note created, but linking it to the task failed: " .. modify_err, vim.log.levels.ERROR)
  end
end

---Locate a linked note by its vault-relative path or Taskwarrior UUID.
---@param task table Decoded Taskwarrior task
local function find_note_path(task)
  local root = utils.get_notebook_root()
  if task.note and task.note ~= "" then
    local filepath, path_err = utils.resolve_relative_path(root, task.note)
    if not filepath then
      return nil, "ignoring unsafe Taskwarrior note path: " .. tostring(path_err)
    end
    local note = frontmatter.parse_file(filepath)
    if note and note.category == "task" and tostring(note.task_uuid or "") == tostring(task.uuid or "") then
      return filepath, nil
    end
  end

  if task.uuid and task.uuid ~= "" then
    local matches = {}
    for _, note in ipairs(require("notes.vault_index").scan()) do
      if note.frontmatter.category == "task" and tostring(note.frontmatter.task_uuid or "") == tostring(task.uuid) then
        table.insert(matches, note.path)
      end
    end

    if #matches == 1 then
      return matches[1], nil
    elseif #matches > 1 then
      return nil, "multiple notes are linked to Taskwarrior task " .. tostring(task.uuid)
    end
  end

  return nil, nil
end

---Open the note of a task, creating it from the template on first use.
---A stale path is resolved by task UUID before a new note is created.
---@param task table Decoded Taskwarrior task
local function open_note(task)
  local filepath, err = find_note_path(task)
  if err then
    return vim.notify(err, vim.log.levels.ERROR)
  end

  if filepath then
    local relative, path_err = utils.relative_path(utils.get_notebook_root(), filepath)
    if not relative then
      return vim.notify("Cannot link task note: " .. tostring(path_err), vim.log.levels.ERROR)
    end
    if task.note ~= relative then
      local _, modify_err = task_run({ task.uuid, "modify", "note:" .. relative }, "nvim")
      if modify_err then
        vim.notify("Note found, but repairing its Taskwarrior link failed: " .. modify_err, vim.log.levels.ERROR)
      else
        task.note = relative
      end
    end
    vim.cmd("edit " .. vim.fn.fnameescape(filepath))
  else
    create_note(task)
  end
end

---Complete a task.
---@param task table Decoded Taskwarrior task
local function complete(task)
  local _, err = task_run({ task.uuid, "done" })
  if err then
    return vim.notify("Completing the task failed: " .. err, vim.log.levels.ERROR)
  end

  vim.notify("Completed: " .. task.description, vim.log.levels.INFO)
end

-- ============================================================================
-- NOTE → TASK
-- ============================================================================

---Push the task fields of a saved note back to Taskwarrior.
---Only values that differ are sent, which also ends the round trip: the
---on-modify hook writes nothing back when the note already says what the task
---says.
---@param bufnr number Buffer of the note
local function push_note(bufnr)
  local fm = frontmatter.parse_yaml(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  local uuid = fm and fm.task_uuid

  if not fm or tostring(fm.category or "") ~= "task" or type(uuid) ~= "string" or uuid == "" then
    return
  end

  local tasks = task_export(uuid)
  local task = tasks and tasks[1]
  if not task or tostring(task.uuid or "") ~= uuid then
    return
  end

  local current = note_fields(task)
  local mods = {}

  -- A field the note does not carry is not an instruction to clear it on the
  -- task; only a field that is present and empty is. A description cannot be
  -- cleared at all, so an empty title is ignored either way.
  for _, field in ipairs({ "title", "due", "wait_until", "priority" }) do
    local value = fm[field] and tostring(fm[field]) or nil
    if field == "priority" and value and value ~= "" then
      value = taskwarrior_priority(value)
      if not value then
        return vim.notify(
          "Task update failed: priority must be urgent, high, medium, low or H/M/L",
          vim.log.levels.ERROR
        )
      end
    end
    if value and value ~= current[field] and (field ~= "title" or value ~= "") then
      local task_field = field == "title" and "description" or field == "wait_until" and "wait" or field
      table.insert(mods, task_field .. ":" .. value)
    end
  end

  local changed = #mods > 0
  if changed then
    local _, err = task_run(vim.list_extend({ uuid, "modify" }, mods), "nvim")
    if err then
      return vim.notify("Updating the task failed: " .. err, vim.log.levels.ERROR)
    end
  end

  local status = fm.status and tostring(fm.status):lower()
  local done = status ~= nil and DONE_STATUS[status] == true

  if status and status ~= "deleted" and done ~= (task.status == "completed") then
    local _, err = task_run(done and { uuid, "done" } or { uuid, "modify", "status:pending" }, "nvim")
    if err then
      return vim.notify("Updating the task failed: " .. err, vim.log.levels.ERROR)
    end
    changed = true
  end

  if changed then
    local canonical, export_err = task_export(uuid)
    if not canonical or not canonical[1] then
      return vim.notify(
        "Task was updated, but its canonical values could not be read: " .. (export_err or "no task returned"),
        vim.log.levels.ERROR
      )
    end
    local archived_status = status == "archived" and "archived" or nil
    if not sync_note_buffer(bufnr, canonical[1], archived_status) then
      return vim.notify(
        "Task was updated, but its canonical values could not be written to the note",
        vim.log.levels.ERROR
      )
    end
    vim.notify("Task updated from note: " .. (fm.title or task.description), vim.log.levels.INFO)
  end
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

---Return the VoidDash summary line.
---@return string
function M.summary()
  local tasks, err = task_export("status:pending")
  if not tasks then
    return "✅ Tasks — " .. err
  end

  return string.format("✅ Tasks — %d open", #tasks)
end

---Return the most urgent pending tasks as VoidDash display lines.
---@param limit number Maximum number of tasks to return
---@return string[]
function M.pending_list(limit)
  local tasks, err = task_export("status:pending")
  if not tasks then
    return { "  " .. err }
  end

  local lines = {}
  for i = 1, math.min(limit, #tasks) do
    local task = tasks[i]
    lines[i] = string.format("  %s%s", task.description, project_suffix(task))
  end
  return lines
end

---Return the task summary and dashboard lines from one Taskwarrior export.
---@param limit number Maximum number of tasks to display
---@return string summary, string[] lines
function M.dashboard_data(limit)
  local tasks, err = task_export("status:pending")
  if not tasks then
    return "✅ Tasks — " .. err, { "  " .. err }
  end

  local lines = {}
  for i = 1, math.min(limit, #tasks) do
    local task = tasks[i]
    lines[i] = string.format("  %s%s", task.description, project_suffix(task))
  end
  return string.format("✅ Tasks — %d open", #tasks), lines
end

---Browse pending tasks, ordered by urgency.
---<CR> opens the task's note (creating it on first use), <C-d> completes it.
function M.telescope_pick()
  local tasks, err = task_export("status:pending")
  if not tasks then
    return vim.notify(err, vim.log.levels.ERROR)
  end

  local items = {}
  for i, task in ipairs(tasks) do
    items[i] = {
      task = task,
      display = string.format(
        "%5.1f  %s%s%s",
        task.urgency or 0,
        task.description,
        project_suffix(task),
        task.note and "  ●" or ""
      ),
    }
  end

  require("notes.picker").pick(items, {
    prompt_title = "Taskwarrior — pending by urgency (● has a note)",
    empty_message = "No pending tasks",
    previewer = false,
    -- Urgency and the note marker are decoration; matching them would make
    -- the fuzzy search behave unpredictably.
    ordinal_fn = function(item)
      return item.task.description .. (item.task.project or "")
    end,
    on_select = function(item)
      open_note(item.task)
    end,
    attach_mappings = function(prompt_bufnr, map, actions, action_state)
      local function complete_selection()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection then
          complete(selection.value.task)
        end
      end

      -- Telescope starts in insert mode, so a normal-mode-only mapping would
      -- never fire without pressing <Esc> first.
      map("i", "<C-d>", complete_selection)
      map("n", "<C-d>", complete_selection)
    end,
  })
end

---Capture a task.
---The input is handed to `task add` as-is, so the whole Taskwarrior syntax is
---available: `Call Bob project:acme due:tomorrow +call pri:H`.
function M.add_task()
  vim.ui.input({ prompt = "task add " }, function(input)
    if not input or input == "" then
      return
    end

    -- Split on whitespace so every `attribute:value` arrives as its own
    -- argument, exactly as a shell would hand it over.
    local _, err = task_run(vim.list_extend({ "add" }, vim.split(input, "%s+", { trimempty = true })))
    if err then
      return vim.notify("Adding the task failed: " .. err, vim.log.levels.ERROR)
    end

    vim.notify("Added: " .. input, vim.log.levels.INFO)

    -- `+LATEST` is Taskwarrior's virtual tag for the task added last, so the
    -- note can be offered without asking which task was just created.
    local tasks = task_export("+LATEST")
    if tasks and tasks[1] and utils.confirm("Create the note for this task?") then
      create_note(tasks[1])
    end
  end)
end

-- ============================================================================
function M.create_from_template()
  local template_module = require("notes.templates")
  local choices = {}

  for _, filepath in ipairs(template_module.discover_templates()) do
    local fm = frontmatter.parse_file(filepath)
    if fm and tostring(fm.category or "") == "task" then
      table.insert(choices, {
        filepath = filepath,
        display = vim.fn.fnamemodify(filepath, ":t:r") .. " (" .. vim.fn.fnamemodify(filepath, ":h:t") .. ")",
      })
    end
  end

  if #choices == 0 then
    return vim.notify("No task templates found in the vault templates directory", vim.log.levels.WARN)
  end

  table.sort(choices, function(a, b)
    return a.display < b.display
  end)

  local function create(item)
    local created = template_module.create_from_template_file(item.filepath)
    if created then
      create_task_from_note(vim.api.nvim_get_current_buf())
    end
  end

  local ok_telescope = pcall(require, "telescope")
  if ok_telescope then
    require("notes.picker").pick(choices, {
      prompt_title = "Create Taskwarrior task from template",
      previewer = false,
      display_fn = function(item)
        return item.display
      end,
      ordinal_fn = function(item)
        return item.display .. " " .. item.filepath
      end,
      on_select = create,
    })
  else
    vim.ui.select(choices, {
      prompt = "Select task template:",
      format_item = function(item)
        return item.display
      end,
    }, function(item)
      if item then
        create(item)
      end
    end)
  end
end

-- COMMAND REGISTRATION (called from notes/dashboard.lua)
-- ============================================================================

function M.setup()
  vim.api.nvim_create_user_command("TaskPick", M.telescope_pick, {
    desc = "Browse pending Taskwarrior tasks and open their notes",
  })

  vim.api.nvim_create_user_command("TaskAdd", M.add_task, {
    desc = "Capture a Taskwarrior task",
  })
  vim.api.nvim_create_user_command("TaskCreateFromTemplate", M.create_from_template, {
    desc = "Create a Taskwarrior task from a selected task template",
  })

  vim.keymap.set(
    "n",
    "<leader>nwt",
    M.telescope_pick,
    { silent = true, desc = "[N]ote [W]orkflow [T]asks (Taskwarrior)" }
  )
  vim.keymap.set(
    "n",
    "<leader>nwa",
    M.create_from_template,
    { silent = true, desc = "[N]ote [W]orkflow [A]dd task from template" }
  )

  if not sync_enabled() then
    return
  end

  -- The counterpart of ~/.config/task/hooks/on-modify.vault-note: the hook
  -- carries task changes into the note and this carries note edits back.
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("voidcore-task-note-sync", { clear = true }),
    pattern = "*.md",
    callback = function(args)
      if utils.in_notebook(vim.api.nvim_buf_get_name(args.buf)) then
        push_note(args.buf)
      end
    end,
  })

  vim.api.nvim_create_autocmd("FileChangedShell", {
    group = vim.api.nvim_create_augroup("voidcore-task-note-external-change", { clear = true }),
    pattern = "*.md",
    callback = function(args)
      if not utils.in_notebook(vim.api.nvim_buf_get_name(args.buf)) then
        return
      end

      local fm = frontmatter.parse_yaml(vim.api.nvim_buf_get_lines(args.buf, 0, -1, false))
      if not fm or tostring(fm.category or "") ~= "task" then
        return
      end

      if vim.bo[args.buf].modified then
        vim.v.fcs_choice = "ask"
        vim.notify("Task note changed outside Neovim; resolve the file conflict before saving", vim.log.levels.WARN)
      else
        vim.v.fcs_choice = "reload"
      end
    end,
  })
end

return M
