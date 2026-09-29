-- notes/queries.lua
-- Query system for notes (Obsidian Dataview replacement)

local utils = require("notes.utils")
local picker = require("notes.picker")

local M = {}
local vault_index = require("notes.vault_index")

-- ============================================================================
-- CORE QUERY FUNCTIONS
-- ============================================================================

---Return the shared vault index for query consumers.
---@param opts? table
---@return table[]
local function scan_notes(opts)
  return vault_index.scan(opts)
end

local function filter_notes(notes, predicate)
  local filtered = {}
  for _, note in ipairs(notes) do
    if predicate(note) then
      table.insert(filtered, note)
    end
  end
  return filtered
end

---Sort notes by field
---@param notes table Array of notes
---@param field string Frontmatter field to sort by
---@param order? string "asc" or "desc" (default: "asc")
---@return table Sorted notes
local function sort_notes(notes, field, order)
  order = order or "asc"
  table.sort(notes, function(a, b)
    local val_a = tostring(a.frontmatter[field] or "")
    local val_b = tostring(b.frontmatter[field] or "")
    if order == "desc" then
      return val_a > val_b
    else
      return val_a < val_b
    end
  end)
  return notes
end

---Normalize a frontmatter date to YYYY-MM-DD for comparisons.
---Accepts both the established ISO format and compact numeric dates.
---@param value any
---@return string
local function normalize_date(value)
  local date = tostring(value or "")
  local compact = date:gsub("%D", "")
  if #compact >= 8 then
    return string.format("%s-%s-%s", compact:sub(1, 4), compact:sub(5, 6), compact:sub(7, 8))
  end
  return date
end

---Return whether a note uses one of the supported meeting classifications.
---@param fm table
---@return boolean
local function is_meeting(fm)
  return utils.has_tag(fm.tags, "meeting") or fm.category == "meeting" or fm.type == "meeting"
end

-- ============================================================================
-- TELESCOPE PICKER HELPERS
-- ============================================================================

---Create a Telescope picker for notes (thin wrapper over notes.picker with
---the notes-specific default display: "Title [tag1, tag2]")
---@param notes table Array of notes
---@param opts table Telescope options {prompt_title: string, display_fn?: function}
local function create_picker(notes, opts)
  opts = opts or {}

  -- Default display function
  local display_fn = opts.display_fn
    or function(note)
      local fm = note.frontmatter
      local title = tostring(fm.title or vim.fn.fnamemodify(note.path, ":t:r"))
      local tags = ""
      if fm.tags and type(fm.tags) == "table" and #fm.tags > 0 then
        tags = " [" .. table.concat(vim.tbl_map(tostring, fm.tags), ", ") .. "]"
      end
      return title .. tags
    end

  picker.pick(notes, {
    prompt_title = opts.prompt_title or "Notes",
    display_fn = display_fn,
    ordinal_fn = function(note)
      return tostring(note.frontmatter.title or vim.fn.fnamemodify(note.path, ":t:r"))
    end,
    picker_opts = opts,
  })
end

-- ============================================================================
-- PUBLIC QUERY FUNCTIONS
-- ============================================================================

---Query all active tasks
---@param opts table
---  {statuses?: string[], prompt_title?: string, project?: string, sort_field?: string, sort_order?: string}
local function query_tasks(opts)
  opts = opts or {}
  local notes = scan_notes()
  local statuses = opts.statuses
  local project_filter = opts.project and vim.trim(opts.project) or nil
  if project_filter == "" then
    project_filter = nil
  end
  local project_filter_lower = project_filter and project_filter:lower() or nil

  local tasks = filter_notes(notes, function(note)
    local fm = note.frontmatter
    if not utils.has_tag(fm.tags, "task") then
      return false
    end

    if statuses and #statuses > 0 then
      local status = (fm.status and tostring(fm.status):lower()) or ""
      if not vim.tbl_contains(statuses, status) then
        return false
      end
    end

    if project_filter_lower then
      local project = (fm.project and tostring(fm.project):lower()) or ""
      return project == project_filter_lower
    end

    return true
  end)

  tasks = sort_notes(tasks, opts.sort_field or "project", opts.sort_order or "asc")

  create_picker(tasks, {
    prompt_title = opts.prompt_title or "Tasks",
    display_fn = function(note)
      local fm = note.frontmatter
      local project = tostring(fm.project or "No Project")
      local title = tostring(fm.title or "Untitled")
      return string.format("[%s] %s", project, title)
    end,
  })
end

---Query all active tasks
function M.active_tasks()
  query_tasks({
    statuses = { "active" },
    prompt_title = "Active Tasks",
  })
end

---Query all pending tasks
function M.pending_tasks()
  query_tasks({
    statuses = { "pending" },
    prompt_title = "Pending Tasks",
  })
end

---Query all closed tasks
function M.closed_tasks()
  query_tasks({
    statuses = { "closed", "completed", "done" },
    prompt_title = "Closed Tasks",
    sort_field = "created",
    sort_order = "desc",
  })
end

---Query all completed tasks
function M.completed_tasks()
  query_tasks({
    statuses = { "completed", "done" },
    prompt_title = "Completed Tasks",
    sort_field = "created",
    sort_order = "desc",
  })
end

---Query tasks for a specific project
---@param project? string Project name (prompts when omitted)
function M.tasks_by_project(project)
  if not project or project == "" then
    project = utils.prompt_text("Project name")
    if not project then
      return
    end
  end

  query_tasks({
    project = project,
    prompt_title = string.format("Tasks (%s)", project),
  })
end

---Query all active projects
function M.active_projects()
  local notes = scan_notes()

  local projects = filter_notes(notes, function(note)
    local fm = note.frontmatter
    return fm.category == "project" and fm.status == "active"
  end)

  projects = sort_notes(projects, "title", "asc")

  create_picker(projects, {
    prompt_title = "Active Projects",
    display_fn = function(note)
      local fm = note.frontmatter
      local client = fm.client and fm.client ~= "" and " (" .. fm.client .. ")" or ""
      return (fm.title or "Untitled") .. client
    end,
  })
end

---Query all archived projects
function M.archived_projects()
  local notes = scan_notes()

  local projects = filter_notes(notes, function(note)
    local fm = note.frontmatter
    return fm.category == "project" and fm.status == "archived"
  end)

  projects = sort_notes(projects, "title", "asc")

  create_picker(projects, {
    prompt_title = "Archived Projects",
  })
end

---Query every note belonging to one client.
---
---Matches the `client/<slug>` tag and the `client` frontmatter field, which is
---the pair `:NoteProjectCreate` writes. Deliberately not restricted to project
---notes: the client note, its meetings and its contacts all carry the same
---axis, and finding them together is the point of having one.
---
---No slug validation here on purpose — a query that refuses to look for a
---legacy value cannot help find the notes that still carry it
---(docs/WORK_TAXONOMY.md, "Migrating existing data").
---@param client? string Client slug (prompts when omitted)
function M.by_client(client)
  if not client or client == "" then
    client = utils.prompt_text("Client slug")
    if not client then
      return
    end
  end

  client = vim.trim(client):lower()
  if client == "" then
    return
  end

  local notes = scan_notes()

  local filtered = filter_notes(notes, function(note)
    local fm = note.frontmatter
    if utils.has_tag(fm.tags, "client/" .. client) then
      return true
    end
    return fm.client ~= nil and tostring(fm.client):lower() == client
  end)

  filtered = sort_notes(filtered, "title", "asc")

  create_picker(filtered, {
    prompt_title = string.format("Client: %s", client),
    display_fn = function(note)
      local fm = note.frontmatter
      local title = tostring(fm.title or vim.fn.fnamemodify(note.path, ":t:r"))
      local project = fm.project and tostring(fm.project) ~= "" and (" [" .. tostring(fm.project) .. "]") or ""
      return title .. project
    end,
  })
end

---Query meetings by date
---@param date? string Date in YYYY-MM-DD format (default: today)
function M.meetings_by_date(date)
  date = date or utils.date_iso()
  local normalized_date = normalize_date(date)
  local today = normalize_date(utils.date_iso())
  local notes = scan_notes()

  local meetings = filter_notes(notes, function(note)
    local fm = note.frontmatter
    return is_meeting(fm) and normalized_date >= today and normalize_date(fm.date) == normalized_date
  end)

  meetings = sort_notes(meetings, "date", "asc")

  create_picker(meetings, {
    prompt_title = string.format("Meetings on %s", date),
    display_fn = function(note)
      local fm = note.frontmatter
      local participants = ""
      if fm.participants and type(fm.participants) == "table" and #fm.participants > 0 then
        participants = " [" .. table.concat(vim.tbl_map(tostring, fm.participants), ", ") .. "]"
      end
      return tostring(fm.title or "Untitled") .. participants
    end,
  })
end

---Query meetings scheduled for today or later.
function M.all_meetings()
  local today = normalize_date(utils.date_iso())
  local notes = scan_notes()

  local meetings = filter_notes(notes, function(note)
    local fm = note.frontmatter
    local date = normalize_date(fm.date)
    return is_meeting(fm) and date ~= "" and date >= today
  end)

  meetings = sort_notes(meetings, "date", "asc")

  create_picker(meetings, {
    prompt_title = "Upcoming Meetings",
    display_fn = function(note)
      local fm = note.frontmatter
      local date = normalize_date(fm.date)
      return string.format("[%s] %s", date ~= "" and date or "No Date", tostring(fm.title or "Untitled"))
    end,
  })
end

---Query knowledge notes
---@param type? string Knowledge type filter (e.g., "atomic", "literature", "permanent")
function M.knowledge_notes(type)
  local notes = scan_notes()

  local knowledge = filter_notes(notes, function(note)
    local fm = note.frontmatter
    local is_knowledge = fm.category == "knowledge" or utils.has_tag(fm.tags, "knowledge")
    if type then
      return is_knowledge and fm.type == type
    end
    return is_knowledge
  end)

  knowledge = sort_notes(knowledge, "title", "asc")

  local title = type and string.format("Knowledge Notes (%s)", type) or "Knowledge Notes"
  create_picker(knowledge, {
    prompt_title = title,
  })
end

---Query people/contacts
function M.people()
  local notes = scan_notes()

  local people = filter_notes(notes, function(note)
    local fm = note.frontmatter
    return fm.category == "person" or utils.has_tag(fm.tags, "person")
  end)

  people = sort_notes(people, "title", "asc")

  create_picker(people, {
    prompt_title = "People & Contacts",
    display_fn = function(note)
      local fm = note.frontmatter
      local role = fm.role and fm.role ~= "" and " - " .. fm.role or ""
      return (fm.title or "Untitled") .. role
    end,
  })
end

---Query notes by tag
---@param tag string Tag to filter by
function M.by_tag(tag)
  if not tag or tag == "" then
    tag = utils.prompt_text("Enter tag to search")
    if not tag then
      return
    end
  end

  local notes = scan_notes()

  local filtered = filter_notes(notes, function(note)
    local fm = note.frontmatter
    return utils.has_tag(fm.tags, tag)
  end)

  filtered = sort_notes(filtered, "created", "desc")

  create_picker(filtered, {
    prompt_title = string.format("Notes tagged with #%s", tag),
  })
end

---Query notes by status
---@param status string Status to filter by
function M.by_status(status)
  if not status or status == "" then
    status = utils.prompt_text("Enter status")
    if not status then
      return
    end
  end

  local notes = scan_notes()

  local filtered = filter_notes(notes, function(note)
    return note.frontmatter.status == status
  end)

  filtered = sort_notes(filtered, "created", "desc")

  create_picker(filtered, {
    prompt_title = string.format("Notes with status: %s", status),
  })
end

---Query recent notes
---@param days? number Number of days to look back (default: 7)
function M.recent_notes(days)
  days = days or 7
  local cutoff_time = os.time() - (days * 24 * 60 * 60)

  local notes = scan_notes()

  local filtered = filter_notes(notes, function(note)
    local fm = note.frontmatter
    if not fm.created then
      return false
    end

    -- Parse created timestamp (assuming YYYY-MM-DD HH:MM format)
    local year, month, day = tostring(fm.created):match("(%d+)-(%d+)-(%d+)")
    if year and month and day then
      local note_time = os.time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
      })
      return note_time >= cutoff_time
    end
    return false
  end)

  filtered = sort_notes(filtered, "created", "desc")

  create_picker(filtered, {
    prompt_title = string.format("Recent Notes (last %d days)", days),
    display_fn = function(note)
      local fm = note.frontmatter
      local created = fm.created or "Unknown"
      return string.format("[%s] %s", created, fm.title or "Untitled")
    end,
  })
end

return M
