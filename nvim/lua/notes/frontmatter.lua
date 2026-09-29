-- notes/frontmatter.lua
-- YAML frontmatter handling for notes

local utils = require("notes.utils")

local M = {}

-- Canonical field order for consistent YAML output.
-- Fields not listed here are rendered alphabetically after the canonical ones.
local CANONICAL_ORDER = {
  "title",
  "aliases",
  "id",
  "created",
  "updated",
  "date",
  "lang",
  "category",
  "status",
  "type",
  "tags",
  "client",
  "project",
  "due",
  "wait_until",
  "priority",
  "task_uuid",
  "participants",
  "email",
  "role",
}

-- ============================================================================
-- FRONTMATTER BUILDERS
-- ============================================================================

---Fields every note type carries. The per-type builders below add only what is
---specific to their category; CANONICAL_ORDER decides the rendered key order,
---so the shape of the table built here does not matter.
---
---`id` is the canonical wiki-link target and must equal the filename stem.
---`aliases[1]` keeps the human title searchable by the native resolver and
---compatible vault tools. A mismatched `id` would point at no file on disk.
---@param category string Note category, also the default tag
---@param opts table Builder options {name, id?, aliases?, lang?, tags?}
---@return table
local function build_base(category, opts)
  local title = opts.name or ""
  return {
    title = title,
    aliases = opts.aliases or (title ~= "" and { title } or {}),
    id = opts.id or utils.now_id(),
    created = utils.now_iso(),
    updated = utils.now_iso(),
    lang = opts.lang or "en",
    tags = opts.tags or { category },
    category = category,
  }
end

---Build frontmatter for a project note
---@param opts table Options {name: string, client?: string, project?: string, tags?: table, status?: string}
---@return table Frontmatter data
function M.build_project(opts)
  opts = opts or {}
  return vim.tbl_extend("force", build_base("project", opts), {
    status = opts.status or "active",
    client = opts.client or "",
    project = opts.project or "",
  })
end

---Build frontmatter for an area note
---@param opts table Options {name: string, tags?: table}
---@return table Frontmatter data
function M.build_area(opts)
  opts = opts or {}
  return build_base("area", opts)
end

---Build frontmatter for a knowledge note
---@param opts table Options {name: string, tags?: table, type?: string}
---@return table Frontmatter data
function M.build_knowledge(opts)
  opts = opts or {}
  return vim.tbl_extend("force", build_base("knowledge", opts), {
    type = opts.type or "atomic",
  })
end

---Build frontmatter for a task note
---@param opts table Options {name: string, client?: string, project?: string, tags?: table, status?: string}
---@return table Frontmatter data
function M.build_task(opts)
  opts = opts or {}
  return vim.tbl_extend("force", build_base("task", opts), {
    status = opts.status or "active",
    client = opts.client or "",
    project = opts.project or "",
    wait_until = opts.wait_until or "",
  })
end

---Build frontmatter for a meeting note
---@param opts table Options {name: string, date?: string, participants?: table, tags?: table}
---@return table Frontmatter data
function M.build_meeting(opts)
  opts = opts or {}
  return vim.tbl_extend("force", build_base("meeting", opts), {
    date = opts.date or utils.date_iso(),
    participants = opts.participants or {},
  })
end

---Build frontmatter for a person/contact note
---@param opts table Options {name: string, email?: string, role?: string, tags?: table}
---@return table Frontmatter data
function M.build_person(opts)
  opts = opts or {}
  return vim.tbl_extend("force", build_base("person", opts), {
    email = opts.email or "",
    role = opts.role or "",
  })
end

---Build frontmatter for a generic note.
---@param opts table Options {name: string, tags?: table}
---@return table Frontmatter data
function M.build_note(opts)
  opts = opts or {}
  return build_base("note", opts)
end

---Build frontmatter for a daily note
---@param date? string Date in YYYY-MM-DD format (default: today)
---@return table Frontmatter data
function M.build_daily(date)
  date = date or utils.date_iso()
  -- The id is the filename stem `YYYYMMDD` that notes.commands.daily_note
  -- writes, not a `YYYYMMDD_HHmm` timestamp: a daily note is identified by its
  -- day, and `[[20260921]]` has to land on the file of that name.
  return vim.tbl_extend(
    "force",
    build_base("daily", {
      name = "Daily Note - " .. date,
      id = (date:gsub("%-", "")),
    }),
    {
      date = date,
    }
  )
end

---Build frontmatter for a weekly review note. The field names match the
---Obsidian weekly review template (week, week_start, week_end), so notes
---created from either side can be queried the same way.
---@param spec notes.PeriodicSpec From notes.periodic.week()
---@return table Frontmatter data
function M.build_weekly(spec)
  return vim.tbl_extend(
    "force",
    build_base("weekly", { name = spec.title, id = spec.stem, tags = { "weekly", "review" } }),
    {
      week = spec.key,
      week_start = spec.start,
      week_end = spec.finish,
    }
  )
end

---Build frontmatter for a monthly review note.
---@param spec notes.PeriodicSpec From notes.periodic.month()
---@return table Frontmatter data
function M.build_monthly(spec)
  return vim.tbl_extend(
    "force",
    build_base("monthly", { name = spec.title, id = spec.stem, tags = { "monthly", "review" } }),
    {
      month = spec.key,
      month_start = spec.start,
      month_end = spec.finish,
    }
  )
end

-- ============================================================================
-- YAML RENDERING
-- ============================================================================

---Render frontmatter table as YAML string
---@param fm table Frontmatter data
---@return string YAML frontmatter with delimiters
function M.render_yaml(fm)
  local lines = { "---" }

  ---Quote a string for YAML double-quoted scalar output, escaping backslashes
  ---and embedded double quotes so values like `John "Doe" Inc.` don't corrupt
  ---the surrounding YAML.
  ---@param str string
  ---@return string
  local function quote_yaml_string(str)
    local escaped = str:gsub("\\", "\\\\"):gsub('"', '\\"')
    return string.format('"%s"', escaped)
  end

  -- YAML words that read back as null or a boolean, in any spelling a reader
  -- accepts (YAML 1.2 core, as Obsidian and vault-agent read frontmatter).
  local YAML_WORDS = {
    ["true"] = true,
    ["false"] = true,
    ["null"] = true,
    ["~"] = true,
  }

  ---A string must be quoted when it is empty, carries YAML syntax, or would
  ---read back as another type: a daily note's id `20260921` written bare
  ---becomes the number 20260921 for parse_scalar, Obsidian and vault-agent's
  ---frontmatter schema alike.
  ---@param str string
  ---@return boolean
  local function needs_quotes(str)
    return str == "" or str:match('[:#%[%]{}"]') ~= nil or tonumber(str) ~= nil or YAML_WORDS[str:lower()] == true
  end

  -- Render a single key/value pair
  local function render_pair(key, value)
    if type(value) == "table" then
      if #value == 0 then
        table.insert(lines, string.format("%s: []", key))
      else
        table.insert(lines, string.format("%s:", key))
        for _, item in ipairs(value) do
          if type(item) == "string" and needs_quotes(item) then
            table.insert(lines, string.format("  - %s", quote_yaml_string(item)))
          else
            table.insert(lines, string.format("  - %s", item))
          end
        end
      end
    elseif type(value) == "string" then
      if needs_quotes(value) then
        table.insert(lines, string.format("%s: %s", key, quote_yaml_string(value)))
      else
        table.insert(lines, string.format("%s: %s", key, value))
      end
    elseif type(value) == "number" then
      table.insert(lines, string.format("%s: %s", key, value))
    elseif type(value) == "boolean" then
      table.insert(lines, string.format("%s: %s", key, value and "true" or "false"))
    end
  end

  -- Track which keys have been rendered
  local rendered = {}

  -- Emit canonical fields first (in order)
  for _, key in ipairs(CANONICAL_ORDER) do
    if fm[key] ~= nil then
      render_pair(key, fm[key])
      rendered[key] = true
    end
  end

  -- Emit remaining fields alphabetically
  local extra = {}
  for key in pairs(fm) do
    if not rendered[key] then
      table.insert(extra, key)
    end
  end
  table.sort(extra)
  for _, key in ipairs(extra) do
    render_pair(key, fm[key])
  end

  table.insert(lines, "---")
  table.insert(lines, "")

  return table.concat(lines, "\n")
end

-- ============================================================================
-- YAML PARSING
-- ============================================================================

---Parse a single scalar YAML value (string/number/boolean) from raw text
---@param raw string Raw scalar text (already trimmed)
---@return string|number|boolean Parsed scalar value
local function parse_scalar(raw)
  if raw:match('^".*"$') then
    -- Unescape \" and \\ for double-quoted strings (mirrors render_yaml's escaping)
    local inner = raw:sub(2, -2)
    return (inner:gsub('\\(["\\])', "%1"))
  elseif raw:match("^'.*'$") then
    return (raw:sub(2, -2):gsub("''", "'"))
  elseif raw == "true" then
    return true
  elseif raw == "false" then
    return false
  elseif tonumber(raw) then
    return tonumber(raw)
  end
  return raw
end

---Parse an inline YAML array like `["a", "b"]` or `[a, b]` into a Lua table
---@param raw string Content between (and including) the square brackets
---@return table Array of parsed scalar values
local function parse_inline_array(raw)
  local inner = raw:match("^%[(.*)%]$") or ""
  local items = {}
  local item_start = 1
  local quote
  local escaped = false
  local index = 1

  while index <= #inner do
    local char = inner:sub(index, index)
    if quote == '"' then
      if escaped then
        escaped = false
      elseif char == "\\" then
        escaped = true
      elseif char == '"' then
        quote = nil
      end
    elseif quote == "'" then
      if char == "'" then
        if inner:sub(index + 1, index + 1) == "'" then
          index = index + 1
        else
          quote = nil
        end
      end
    elseif char == '"' or char == "'" then
      quote = char
    elseif char == "," then
      local item = vim.trim(inner:sub(item_start, index - 1))
      if item ~= "" then
        table.insert(items, parse_scalar(item))
      end
      item_start = index + 1
    end
    index = index + 1
  end

  local item = vim.trim(inner:sub(item_start))
  if item ~= "" then
    table.insert(items, parse_scalar(item))
  end

  return items
end

---Locate the closing delimiter of a note's YAML frontmatter block.
---A note has frontmatter only when line 1 is "---" and a later "---" closes it.
---@param lines table Lines of the note
---@return integer|nil end_line Index of the closing "---", nil when there is none
function M.block_end(lines)
  if #lines < 3 or lines[1] ~= "---" then
    return nil
  end

  for i = 2, #lines do
    if lines[i] == "---" then
      return i
    end
  end

  return nil
end

---Parse YAML frontmatter from markdown content
---@param content string|table Markdown content (string or lines table)
---@return table|nil Frontmatter data or nil if not found
function M.parse_yaml(content)
  local lines = type(content) == "string" and vim.split(content, "\n") or content

  local end_line = M.block_end(lines)
  if not end_line then
    return nil
  end

  -- Parse YAML (simple parser for common cases)
  local fm = {}
  local current_key = nil
  local current_array = nil

  for i = 2, end_line - 1 do
    local line = lines[i]

    -- Array item
    if line:match("^%s*-%s") then
      -- Retroactively promote a pending empty-scalar key (e.g. "tags:")
      -- into an array once we see its first "- item" line. Keys that had
      -- an explicit "[]" or inline value already have current_array set
      -- (or nil with no pending key), so this only fires for the
      -- multi-line-array case.
      if not current_array and current_key and fm[current_key] == "" then
        current_array = {}
        fm[current_key] = current_array
      end
      if current_array then
        local value = line:match("^%s*-%s*(.+)$")
        table.insert(current_array, parse_scalar(vim.trim(value)))
      end
    -- Key-value pair
    else
      local key, value = line:match("^([^:]+):%s*(.*)$")
      if key then
        key = vim.trim(key)
        value = vim.trim(value)

        -- Empty scalar value (e.g. "client:") is a plain empty string, NOT
        -- an array. Only an explicit "[]" marks an empty array. Multi-line
        -- arrays are still detected lazily: if subsequent "- item" lines
        -- follow, `current_array` is set retroactively once the first
        -- array item is encountered (see below).
        if value == "" then
          fm[key] = ""
          current_array = nil
          current_key = key
        elseif value == "[]" then
          current_array = {}
          fm[key] = current_array
          current_key = key
        -- Handle inline arrays, e.g. tags: ["task", "x"] or tags: [a, b]
        elseif value:match("^%[.*%]$") then
          fm[key] = parse_inline_array(value)
          current_array = nil
        -- Handle quoted strings, numbers, booleans, plain strings
        else
          fm[key] = parse_scalar(value)
          current_array = nil
        end
      end
    end
  end

  return fm
end

---Parse frontmatter from current buffer
---@return table|nil Frontmatter data or nil if not found
function M.parse_current_buffer()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  return M.parse_yaml(lines)
end

---Parse frontmatter from file
---@param path string File path
---@return table|nil Frontmatter data or nil if not found
function M.parse_file(path)
  if not utils.file_exists(path) then
    return nil
  end

  local lines = vim.fn.readfile(path)
  return M.parse_yaml(lines)
end

-- ============================================================================
-- FRONTMATTER OPERATIONS
-- ============================================================================

---Insert frontmatter at beginning of current buffer
---@param fm table Frontmatter data
function M.insert_frontmatter(fm)
  local yaml = M.render_yaml(fm)
  local lines = vim.split(yaml, "\n")
  vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
end

---Keep the note findable under its own title.
---
---`title` is written by four places: `:NoteRename`, the Taskwarrior push in
---notes/taskwarrior.lua, the `on-modify.vault-note` hook, and a note template.
---The native wiki-link resolver uses canonical ids and aliases, so a title
---changed outside note creation remains searchable.
---
---The title is inserted, never substituted, and nothing is removed: a note
---that has been renamed stays reachable under the name older notes link it by,
---which is what keeps those links working. Deliberate aliases a human added
---are never touched.
---@param fm table Parsed frontmatter, modified in place
local function ensure_title_alias(fm)
  local title = type(fm.title) == "string" and vim.trim(fm.title) or ""
  if title == "" then
    return
  end

  local aliases = utils.normalize_tags(fm.aliases)
  if aliases[1] == title then
    fm.aliases = aliases
    return
  end

  for index = #aliases, 1, -1 do
    if aliases[index] == title then
      table.remove(aliases, index)
    end
  end
  table.insert(aliases, 1, title)
  fm.aliases = aliases
end

---Update existing frontmatter in current buffer
---@param updates table Frontmatter updates
---@return boolean Success
function M.update_frontmatter(updates)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local end_line = M.block_end(lines)
  if not end_line then
    return false
  end

  -- Parse existing frontmatter
  local fm = M.parse_yaml(lines)
  if not fm then
    return false
  end

  -- Apply updates
  for key, value in pairs(updates) do
    fm[key] = value
  end

  ensure_title_alias(fm)

  -- Render and replace
  local yaml = M.render_yaml(fm)
  local new_lines = vim.split(yaml, "\n")
  vim.api.nvim_buf_set_lines(0, 0, end_line, false, new_lines)

  return true
end

return M
