-- notes/templates.lua
-- Dynamic template system that reads from the vault's templates directory
-- (path defined once in notes.init.config.directories.templates)
-- Templates are markdown files with {{ variable }} placeholders
-- Variables are prompted at runtime from the user

local utils = require("notes.utils")
local frontmatter = require("notes.frontmatter")

local M = {}

-- Configuration constants
local OPTIONAL_PROMPT_SUFFIX = " (optional - press Enter to skip)"

---Return whether a template is for a recurring (weekly or monthly) meeting,
---which is then prefixed with its meeting date. Review notes for a week or a
---month are not created here: :NoteWeekly and :NoteMonthly own those.
---@param filepath string
---@return boolean
local function is_recurring_meeting_template(filepath)
  local filename = vim.fn.fnamemodify(filepath, ":t:r"):lower()
  return filename:find("weekly", 1, true) ~= nil or filename:find("monthly", 1, true) ~= nil
end

---Prompt for a valid ISO meeting date.
---@return string|nil
local function prompt_for_meeting_date()
  local default_date = utils.date_iso()

  while true do
    local date = utils.prompt_text("Meeting date (YYYY-MM-DD)", default_date)
    if not date or date == "" then
      return nil
    end

    local year, month, day = date:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
    if year and month and day then
      local timestamp = os.time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = 12,
      })
      if timestamp and os.date("%Y-%m-%d", timestamp) == date then
        return date
      end
    end

    vim.notify("Meeting date must use the format YYYY-MM-DD", vim.log.levels.WARN)
  end
end

-- ============================================================================
-- TEMPLATE DISCOVERY
-- ============================================================================

---Get the templates directory path
---@return string Path to templates directory
local function get_templates_dir()
  local root = utils.get_notebook_root()
  local templates_dir = require("notes.init").config.directories.templates
  return utils.path_join(root, templates_dir)
end

---Discover all template files in the templates directory
---@return table List of template file paths
function M.discover_templates()
  local templates_dir = get_templates_dir()
  local templates = {}

  -- Use Neovim's glob for safer file discovery
  local pattern = templates_dir .. "/**/*.md"
  local files = vim.fn.glob(pattern, false, true)

  -- Periodic templates at the root (daily.md, weekly.md, monthly.md) belong to
  -- :NoteDaily, :NoteWeekly and :NoteMonthly, which derive the file name and
  -- id from the period. Through the picker they would get a timestamped name
  -- in the wrong folder, so they are not offered here.
  local periodic_names = {}
  for _, names in pairs(require("notes.periodic").template_names) do
    for _, name in ipairs(names) do
      periodic_names[name] = true
    end
  end
  local root = vim.fs.normalize(templates_dir)

  for _, filepath in ipairs(files) do
    local filename = vim.fn.fnamemodify(filepath, ":t")
    local at_root = vim.fs.normalize(vim.fn.fnamemodify(filepath, ":h")) == root
    -- Skip README and CHANGELOG files, and files in _scripts directory
    if
      filename ~= "README.md"
      and filename ~= "CHANGELOG.md"
      and not filepath:match("/_scripts/")
      and not (at_root and periodic_names[filename])
    then
      table.insert(templates, filepath)
    end
  end

  return templates
end

-- ============================================================================
-- TEMPLATE PARSING
-- ============================================================================

---Extract variables from template content
---Variables are marked with {{ variable_name }}
---@param content string Template content
---@return table List of variable names
local function extract_variables(content)
  local variables = {}
  local seen = {}

  -- Match {{ variable }} patterns
  for var in content:gmatch("{{%s*([%w_]+)%s*}}") do
    if not seen[var] then
      table.insert(variables, var)
      seen[var] = true
    end
  end

  return variables
end

---Get template metadata from filepath
---@param filepath string Path to template file
---@return table Template metadata
local function get_template_metadata(filepath)
  local templates_dir = get_templates_dir()
  local relative_path = filepath:sub(#templates_dir + 2) -- +2 for the trailing /

  -- Extract category from path (e.g., 01_projects, 02_areas, etc.)
  local category = relative_path:match("^(%d+_%w+)/") or "general"

  -- Get filename without extension
  local filename = vim.fn.fnamemodify(filepath, ":t:r")

  -- Create display name from filename
  local display_name = filename:gsub("_", " "):gsub("(%a)([%w_']*)", function(first, rest)
    return first:upper() .. rest:lower()
  end)

  -- Determine icon based on category
  local icon = "📄"
  if category:match("project") then
    icon = "📁"
  elseif category:match("area") then
    icon = "🎯"
  elseif category:match("knowledge") then
    icon = "💡"
  elseif category:match("resource") then
    icon = "📚"
  elseif category:match("archive") then
    icon = "📦"
  end

  return {
    name = display_name,
    filepath = filepath,
    relative_path = relative_path,
    category = category,
    icon = icon,
  }
end

-- ============================================================================
-- VARIABLE PROMPTING
-- ============================================================================

---Prompt user for variable values (with deduplication)
---@param variables table List of variable names
---@param context table|nil Optional pre-filled values to avoid re-prompting.
---  Contains variable names as keys, for example `{ title = "My Title", date = "2025-12-27" }`.
---@return table|nil Variable values or nil if cancelled
local function prompt_for_variables(variables, context)
  local values = context or {}

  -- Add default variables that are always available (only if not already set)
  if not values["id"] then
    values["id"] = utils.now_id()
  end
  if not values["created"] then
    values["created"] = utils.now_iso()
  end
  if not values["created_date"] then
    values["created_date"] = utils.date_iso()
  end
  if not values["current_date"] then
    values["current_date"] = utils.date_iso()
  end

  -- Prompt for each variable
  for _, var in ipairs(variables) do
    -- Skip variables that are already set (defaults or pre-filled from context)
    if not values[var] then
      -- Format variable name for prompt (e.g., "project_name" -> "Project Name")
      local prompt_text = var:gsub("_", " "):gsub("(%a)([%w]*)", function(first, rest)
        return first:upper() .. rest
      end)

      local value = utils.prompt_text(prompt_text .. OPTIONAL_PROMPT_SUFFIX)

      -- Allow empty values (optional variables)
      if value and value ~= "" then
        values[var] = value
      else
        -- Use empty string for optional variables
        values[var] = ""
      end
    end
  end

  return values
end

---Replace variables in template content
---@param content string Template content with {{ variable }} placeholders
---@param values table Variable values
---@return string Content with variables replaced
local function replace_variables(content, values)
  local result = content

  for var, value in pairs(values) do
    -- Escape the variable name for safe regex matching
    local escaped_var = var:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
    -- Coerce to string (numbers/booleans would otherwise error inside gsub)
    -- and escape "%" in the replacement so gsub doesn't interpret it as a
    -- capture-group reference (e.g. a value containing "%1" or a bare "%").
    local str_value = tostring(value):gsub("%%", "%%%%")
    -- Replace {{ var }} with proper handling of whitespace
    result = result:gsub("{{%s*" .. escaped_var .. "%s*}}", str_value)
  end

  return result
end

-- ============================================================================
-- TEMPLATE CREATION
-- ============================================================================
-- IMPORTANT PATH BEHAVIOR:
-- - Templates are READ from: vault_root/<notes.init.config.directories.templates>/...
-- - Notes are CREATED at: vault_root/<location>/<filename>
-- - Example: Template at "<templates_dir>/01_projects/example.md"
--            creates note at "01_projects/my_note.md" (NOT in templates dir)
-- ============================================================================

---Read template file content and extract location metadata
---@param filepath string Path to template file
---@return string|nil Template content or nil on error
---@return string|nil Location path extracted from template
local function read_template(filepath)
  local file = io.open(filepath, "r")
  if not file then
    return nil, nil
  end

  local content = file:read("*all")
  file:close()

  -- Extract location from template (looks for "location: path/to/folder" line)
  -- This line will be removed from the final content
  local clean_content = content

  -- Check for location in frontmatter or as special comment
  -- Pattern 1: In frontmatter - location: "path/to/folder"
  local location = content:match("\nlocation:%s*[\"']?([^\"'\n]+)[\"']?%s*\n")

  -- Pattern 2: As special comment - <!-- location: path/to/folder -->
  if not location then
    location = content:match("<!%-%-%s*location:%s*([^%-%s][^%-]-)%s*%-%->")
  end

  -- Remove location line from content if found
  if location then
    -- Remove from frontmatter
    clean_content = clean_content:gsub("\nlocation:%s*[\"']?[^\"'\n]+[\"']?%s*\n", "\n")
    -- Remove from comment
    clean_content = clean_content:gsub("<!%-%-%s*location:%s*[^%-]-%s*%-%->\n?", "")
    -- Trim the extracted location
    location = location:match("^%s*(.-)%s*$")
  end

  return clean_content, location
end

---Create note from template file.
---@param template_path string Path to template file
---@param context table|nil Values pre-filled before prompting for template variables
---@return boolean Success
---@return string|nil filepath Absolute path of the created note (only on success)
function M.create_from_template_file(template_path, context)
  -- Read template content and extract location
  local template_content, template_location = read_template(template_path)
  if not template_content then
    vim.notify("Failed to read template: " .. template_path, vim.log.levels.ERROR)
    return false
  end

  -- Extract variables from template
  local variables = extract_variables(template_content .. "\n" .. (template_location or ""))

  -- Initialize context for deduplication
  local values_context = vim.tbl_extend("force", {}, context or {})
  local meeting_date

  -- Smart prompting: if template has 'title' variable, prompt for it first
  -- and use it to suggest filename
  local has_title = vim.tbl_contains(variables, "title")

  if has_title and not values_context.title then
    local title_value = utils.prompt_text("Title")
    if not title_value or title_value == "" then
      vim.notify("Title required", vim.log.levels.WARN)
      return false
    end
    values_context.title = title_value
  end

  if is_recurring_meeting_template(template_path) then
    meeting_date = prompt_for_meeting_date()
    if not meeting_date then
      vim.notify("Meeting date required", vim.log.levels.WARN)
      return false
    end

    -- Support both common template variable names without prompting twice.
    values_context.date = meeting_date
    values_context.meeting_date = meeting_date
  end

  -- The filename is settled before the remaining variables are prompted,
  -- because its stem *is* the note's `{{ id }}`. The native resolver
  -- matches the frontmatter id and filename stem, so an id that does not
  -- match the stem produces links that no file on disk answers to (docs/ADR-005).
  --
  -- The default carries a timestamp prefix for the same reason `:NoteNew`
  -- does: two notes titled "Meeting Notes" in different folders would
  -- otherwise both become `meeting_notes.md`, and `[[meeting_notes]]` could
  -- no longer name either of them unambiguously.
  local default_filename = ""
  if values_context.title then
    default_filename = utils.slugify(values_context.title)
  end
  if meeting_date then
    default_filename = meeting_date:gsub("%-", "") .. (default_filename ~= "" and "_" .. default_filename or "")
  elseif default_filename ~= "" then
    default_filename = utils.now_id() .. "_" .. default_filename
  end

  -- Prompt for filename with smart default
  local filename = utils.prompt_text("Filename (without .md)", default_filename)
  if not filename or filename == "" then
    vim.notify("Filename required", vim.log.levels.WARN)
    return false
  end

  -- The meeting date distinguishes recurring weekly and monthly meetings with
  -- the same title, even when the filename is manually edited at the prompt.
  local compact_date = meeting_date and meeting_date:gsub("%-", "")
  if compact_date and not filename:find(compact_date, 1, true) then
    filename = compact_date .. "_" .. filename
  end

  -- Keep the note's id equal to its filename stem, whether the stem came from
  -- the default above or was typed over at the prompt.
  local stem = filename:gsub("%.md$", "")
  if not utils.is_safe_filename(stem) then
    vim.notify("Filename must be a single safe path component", vim.log.levels.ERROR)
    return false
  end
  stem = utils.slugify(stem)
  if not utils.is_slug(stem) then
    vim.notify("Filename must use lowercase letters, numbers, and single underscores", vim.log.levels.ERROR)
    return false
  end
  filename = stem .. ".md"
  values_context.id = stem

  -- Prompt for remaining variable values (with context to avoid re-prompting)
  local values = prompt_for_variables(variables, values_context)
  if not values then
    vim.notify("Template creation cancelled", vim.log.levels.WARN)
    return false
  end
  for _, field in ipairs({ "client_slug", "project_slug" }) do
    if values[field] ~= nil and not utils.is_slug(values[field]) then
      vim.notify(field .. " must be a lowercase underscore-separated slug", vim.log.levels.ERROR)
      return false
    end
  end

  -- Replace variables in template
  local content = replace_variables(template_content, values)

  -- Get vault root (where notes actually live)
  local vault_root = utils.get_notebook_root()

  -- Determine location: use template_location if specified, otherwise infer from template path
  local location = template_location and replace_variables(template_location, values) or nil

  if not location then
    -- Fallback: infer from template path (old behavior), directories always
    -- sourced from the centralized notes.init config (single source of truth)
    local template_metadata = get_template_metadata(template_path)
    local dirs = require("notes.init").config.directories
    local default_location = ""

    if template_metadata.category:match("project") then
      default_location = dirs.projects .. "/"
    elseif template_metadata.category:match("area") then
      default_location = dirs.areas .. "/"
    elseif template_metadata.category:match("knowledge") then
      default_location = dirs.knowledge .. "/"
    elseif template_metadata.category:match("resource") then
      default_location = dirs.resources .. "/"
    end

    location = default_location
  end

  if (location and location:find("{{%s*[%w_]+%s*}}")) or not utils.is_safe_relative_path(location or "") then
    vim.notify("Unsafe template location: " .. tostring(location), vim.log.levels.ERROR)
    return false
  end

  -- Build full filepath in VAULT (not in templates directory)
  local relative_path = utils.path_join(location, filename)
  local filepath, path_err = utils.resolve_relative_path(vault_root, relative_path)
  if not filepath then
    vim.notify("Unsafe template path: " .. tostring(path_err), vim.log.levels.ERROR)
    return false
  end

  if utils.path_is_taken(filepath) then
    vim.notify("Note already exists or is open: " .. filepath, vim.log.levels.ERROR)
    return false
  end

  -- Ensure directory exists
  local dir = vim.fn.fnamemodify(filepath, ":h")
  if not utils.ensure_dir(dir) then
    vim.notify("Failed to create directory: " .. dir, vim.log.levels.ERROR)
    return false
  end

  -- Create file and insert content
  vim.cmd("edit " .. vim.fn.fnameescape(filepath))
  vim.bo.filetype = "markdown"
  local lines = vim.split(content, "\n")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

  if frontmatter.parse_current_buffer() then
    local updates = { id = values_context.id }
    if type(values.title) == "string" and values.title ~= "" then
      updates.title = values.title
    end
    if not frontmatter.update_frontmatter(updates) then
      vim.notify("Failed to set note identity from template", vim.log.levels.ERROR)
      return false
    end
  end

  -- Move cursor to first empty line after frontmatter
  vim.cmd("normal! gg")

  vim.notify(string.format("Created note: %s at %s", filename, location), vim.log.levels.INFO)
  return true, filepath
end

-- ============================================================================
-- TEMPLATE PICKER
-- ============================================================================

---Show template picker with fuzzy search.
---@param context table|nil Values pre-filled before prompting for template variables
---@param on_created? fun(path: string) Called with the new note's path once it exists
function M.pick_template(context, on_created)
  local function create(filepath)
    local ok, path = M.create_from_template_file(filepath, context)
    if ok and path and on_created then
      on_created(path)
    end
  end

  -- Discover templates
  local template_files = M.discover_templates()

  if #template_files == 0 then
    vim.notify("No templates found in " .. get_templates_dir(), vim.log.levels.WARN)
    return
  end

  -- Build choices for telescope/vim.ui.select
  local choices = {}
  for _, filepath in ipairs(template_files) do
    local metadata = get_template_metadata(filepath)
    table.insert(choices, {
      filepath = filepath,
      display = string.format("%s %s (%s)", metadata.icon, metadata.name, metadata.category),
      metadata = metadata,
    })
  end

  -- Sort by name
  table.sort(choices, function(a, b)
    return a.metadata.name < b.metadata.name
  end)

  -- Use the shared Telescope picker when available, otherwise fall back to vim.ui.select.
  local has_telescope = pcall(require, "telescope")
  if has_telescope then
    require("notes.picker").pick(choices, {
      prompt_title = "Select Template",
      previewer = false,
      display_fn = function(item)
        return item.display
      end,
      ordinal_fn = function(item)
        return item.metadata.name .. " " .. item.metadata.category .. " " .. item.metadata.relative_path
      end,
      on_select = function(item)
        create(item.filepath)
      end,
    })
  else
    vim.ui.select(choices, {
      prompt = "Select Template:",
      format_item = function(item)
        return item.display
      end,
    }, function(choice)
      if choice then
        create(choice.filepath)
      end
    end)
  end
end

return M
