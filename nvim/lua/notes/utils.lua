-- notes/utils.lua
-- Shared path, date, and input utilities for the native notes workflow
-- Language Policy: English by default, lowercase for folders/files/slugs/tags/categories/status
-- Timezone: Europe/Berlin

local M = {}
local notebook_root_cache
local uv = vim.uv or vim.loop

-- ============================================================================
-- DATE & TIME UTILITIES
-- ============================================================================

---Generate ID in format YYYYMMDD_HHmm for current date/time
---@param date_id? string Optional date override (YYYYMMDD format)
---@return string ID in format "YYYYMMDD_HHmm"
function M.now_id(date_id)
  if date_id then
    local time = os.date("%H%M")
    return string.format("%s_%s", date_id, time)
  end
  return os.date("%Y%m%d_%H%M")
end

---Generate ISO timestamp with custom format
---@param fmt? string Format string (default: "%Y-%m-%d %H:%M")
---@return string Formatted timestamp
function M.now_iso(fmt)
  fmt = fmt or "%Y-%m-%d %H:%M"
  return os.date(fmt)
end

---Generate date ID in format YYYYMMDD for current day
---@return string Date in format "YYYYMMDD"
function M.date_id()
  return os.date("%Y%m%d")
end

---Generate date in ISO format YYYY-MM-DD
---@return string Date in format "YYYY-MM-DD"
function M.date_iso()
  return os.date("%Y-%m-%d")
end

-- ============================================================================
-- STRING & SLUG UTILITIES
-- ============================================================================

---Slugify string to ASCII lowercase with underscores or hyphens
---Handles German umlauts and common diacritics (ä→ae, ö→oe, ü→ue, ß→ss)
---@param str string String to slugify
---@param opts? table Options {preserve_case: false, separator: "_"}
---@return string Slugified string
function M.slugify(str, opts)
  if not str or str == "" then
    return ""
  end

  opts = opts or {}
  local separator = opts.separator or "_"

  local result = str
    -- German umlauts
    :gsub("ä", "ae")
    :gsub("Ä", "Ae")
    :gsub("ö", "oe")
    :gsub("Ö", "Oe")
    :gsub("ü", "ue")
    :gsub("Ü", "Ue")
    :gsub("ß", "ss")
    -- Common diacritics
    :gsub("[àáâãå]", "a")
    :gsub("[èéêë]", "e")
    :gsub("[ìíîï]", "i")
    :gsub("[òóôõ]", "o")
    :gsub("[ùúû]", "u")
    :gsub("[ñ]", "n")
    :gsub("[ç]", "c")
    -- Remove other special chars (keep alphanumeric, space, hyphen, underscore)
    :gsub("[^%w%s%-_]", "")
    -- Replace spaces/hyphens with separator
    :gsub("[%s%-]+", separator)
    -- Remove duplicate separators
    :gsub(separator .. "+", separator)
    -- Trim separators from start/end
    :gsub("^" .. separator .. "+", "")
    :gsub(separator .. "+$", "")

  -- Apply lowercase unless preserve_case is true
  if not opts.preserve_case then
    result = result:lower()
  end

  return result
end

---Check a string against the repository-wide slug grammar: lowercase ASCII
---alphanumerics separated by single underscores, with no leading, trailing or
---doubled separator. The same grammar is enforced by ~/.local/bin/void-work and
---by `azctx`; see docs/WORK_TAXONOMY.md.
---
---A slug must never contain a dot: Taskwarrior reserves it for its project
---hierarchy (`acme.migration`), so a dotted slug would silently split there.
---@param str string|nil
---@return boolean
function M.is_slug(str)
  if type(str) ~= "string" or str == "" then
    return false
  end

  -- Lua patterns have no alternation, so the grammar is checked in three
  -- steps instead of one expression.
  if not str:match("^[a-z0-9_]+$") then
    return false
  end

  return not (str:match("^_") or str:match("_$") or str:match("__"))
end

-- ============================================================================
-- FILE & PATH UTILITIES
-- ============================================================================

---Get the notebook root directory using centralized configuration
---@return string Root directory path
function M.get_notebook_root()
  local ok, notes = pcall(require, "notes.init")
  if not ok then
    return vim.fn.getcwd()
  end

  local config = notes.config
  local cwd = vim.fn.getcwd()
  if
    notebook_root_cache
    and notebook_root_cache.config == config
    and notebook_root_cache.cwd == cwd
    and notebook_root_cache.explicit == config.notebook_root
  then
    return notebook_root_cache.path
  end

  local root
  if config.notebook_root then
    root = config.notebook_root
  else
    local search_paths = config.root_search_paths
    if type(search_paths) == "function" then
      search_paths = search_paths()
    end

    if search_paths then
      for _, path in ipairs(search_paths) do
        if vim.fn.isdirectory(path) == 1 then
          root = path
          break
        end
      end
    end

    if not root and config.root_fallback then
      root = config.root_fallback
      if type(root) == "function" then
        root = root()
      end
    end
  end

  root = root or cwd
  notebook_root_cache = {
    config = config,
    cwd = cwd,
    explicit = config.notebook_root,
    path = root,
  }
  return root
end

---Invalidate the cached vault root after configuration or working-directory changes.
function M.invalidate_notebook_root()
  notebook_root_cache = nil
end

local function absolute_normalized_path(path)
  return vim.fs.normalize(vim.fn.fnamemodify(path, ":p")):gsub("\\", "/")
end

---Return whether a path is equal to or lexically below a root directory.
---@param root string
---@param path string
---@return boolean
function M.path_is_within(root, path)
  local normalized_root = absolute_normalized_path(root):gsub("/+$", "")
  local normalized_path = absolute_normalized_path(path)

  if normalized_root == "" then
    normalized_root = "/"
  elseif normalized_root:match("^%a:$") then
    normalized_root = normalized_root .. "/"
  end

  if normalized_root == "/" or normalized_root:match("^%a:/$") then
    return normalized_path:sub(1, #normalized_root) == normalized_root
  end

  local prefix = normalized_root .. "/"
  return normalized_path == normalized_root or normalized_path:sub(1, #prefix) == prefix
end

local function canonical_path(path)
  local current = absolute_normalized_path(path)
  local missing = {}

  while current and current ~= "" do
    if uv.fs_lstat(current) then
      local resolved = uv.fs_realpath(current)
      if not resolved then
        return nil, "cannot resolve path component: " .. current
      end

      for index = #missing, 1, -1 do
        resolved = M.path_join(resolved, missing[index])
      end

      return absolute_normalized_path(resolved), nil
    end

    local parent = vim.fn.fnamemodify(current, ":h")
    if parent == current then
      break
    end
    table.insert(missing, vim.fn.fnamemodify(current, ":t"))
    current = parent
  end

  return nil, "cannot resolve path: " .. tostring(path)
end

local function is_resolved_within(root, path)
  local resolved_root, root_err = canonical_path(root)
  if not resolved_root then
    return false, root_err
  end

  local resolved_path, path_err = canonical_path(path)
  if not resolved_path then
    return false, path_err
  end

  if not M.path_is_within(resolved_root, resolved_path) then
    return false, "path resolves outside the configured vault"
  end

  return true, nil
end

---Return a slash-separated vault-relative path for a file inside the vault.
---@param root string
---@param path string
---@return string|nil relative_path, string|nil err
function M.relative_path(root, path)
  if not M.path_is_within(root, path) then
    return nil, "path is outside the configured vault"
  end

  local inside, err = is_resolved_within(root, path)
  if not inside then
    return nil, err
  end

  local normalized_root = absolute_normalized_path(root):gsub("/+$", "")
  local normalized_path = absolute_normalized_path(path)
  if normalized_root == "" then
    normalized_root = "/"
  end

  if normalized_path == normalized_root then
    return nil, "path is the vault root, not a note"
  elseif normalized_root == "/" then
    return normalized_path:sub(2), nil
  end

  return normalized_path:sub(#normalized_root + 2), nil
end

local function is_safe_path_component(component)
  if type(component) ~= "string" or component == "" or component == "." or component == ".." then
    return false
  end

  if component:find('[%c<>:"/\\|?*]') or component:match("[%. ]$") then
    return false
  end

  local device = component:match("^([^%.]+)") or component
  device = device:gsub("[%. ]+$", ""):upper()
  return device ~= "CON"
    and device ~= "PRN"
    and device ~= "AUX"
    and device ~= "NUL"
    and not device:match("^COM[1-9]$")
    and not device:match("^LPT[1-9]$")
end

---Return whether a user-provided path is relative and contains no traversal.
---@param path string
---@return boolean
function M.is_safe_relative_path(path)
  if type(path) ~= "string" or path:find("%z") then
    return false
  end

  local normalized = path:gsub("\\", "/")
  if normalized:sub(1, 1) == "/" or normalized:match("^%a:") or normalized:find("//", 1, true) then
    return false
  end

  normalized = normalized:gsub("/+$", "")
  if normalized == "" then
    return path == ""
  end

  for component in normalized:gmatch("[^/]+") do
    if not is_safe_path_component(component) then
      return false
    end
  end

  return true
end

---Return whether a string is safe to use as one filename component.
---@param filename string
---@return boolean
function M.is_safe_filename(filename)
  return is_safe_path_component(filename)
end

---Resolve a vault-relative path and reject traversal or absolute paths.
---@param root string
---@param relative_path string
---@return string|nil path, string|nil err
function M.resolve_relative_path(root, relative_path)
  if not M.is_safe_relative_path(relative_path) then
    return nil, "path must be relative and cannot contain traversal components"
  end

  local path = M.path_join(root, (relative_path:gsub("\\", "/")))
  if not M.path_is_within(root, path) then
    return nil, "path resolves outside the configured vault"
  end

  local inside, err = is_resolved_within(root, path)
  if not inside then
    return nil, err
  end

  return path, nil
end

---Check whether a path lies inside the notebook root
---@param path string File path (absolute or relative)
---@return boolean True if the path is below the notebook root
function M.in_notebook(path)
  if not path or path == "" then
    return false
  end

  local root = absolute_normalized_path(M.get_notebook_root()):gsub("/+$", "")
  if root == "" then
    root = "/"
  end
  local normalized_path = absolute_normalized_path(path)
  if normalized_path == root or not M.path_is_within(root, normalized_path) then
    return false
  end

  return is_resolved_within(root, normalized_path)
end

---Check if file exists
---@param path string File path
---@return boolean True if file exists
function M.file_exists(path)
  return vim.fn.filereadable(path) == 1
end

---Check whether a file exists on disk or is already open in a buffer.
---@param path string
---@return boolean
function M.path_is_taken(path)
  return M.file_exists(path) or vim.fn.bufnr(path) >= 0
end

---Generate a unique timestamped note stem, including unsaved buffers.
---@param root string
---@param directory string
---@param title string
---@return string
function M.unique_note_stem(root, directory, title)
  local base = M.now_id() .. "_" .. M.slugify(title)
  local stem = base
  local suffix = 2

  while M.path_is_taken(M.path_join(root, directory, stem .. ".md")) do
    stem = base .. "_" .. suffix
    suffix = suffix + 1
  end

  return stem
end

---Check if directory exists
---@param path string Directory path
---@return boolean True if directory exists
function M.dir_exists(path)
  return vim.fn.isdirectory(path) == 1
end

---Ensure directory exists, create if needed
---@param path string Directory path
---@return boolean Success
function M.ensure_dir(path)
  if M.dir_exists(path) then
    return true
  end
  return vim.fn.mkdir(path, "p") == 1
end

---Join path components, normalizing separators for cross-platform use
---(this repo explicitly supports Windows alongside Arch Linux, and
---notebook roots may come from Windows-style backslash paths).
---Only trims separators between components; a leading separator on the
---first component (e.g. a UNC path `\\server\share`) is preserved.
---@param ... string Path components
---@return string Joined path
function M.path_join(...)
  local parts = {}
  for _, part in ipairs({ ... }) do
    if part and part ~= "" then
      table.insert(parts, part)
    end
  end

  for i, part in ipairs(parts) do
    if i > 1 then
      -- Strip leading separators (either style) to avoid doubled separators
      part = part:gsub("^[/\\]+", "")
    end
    if i < #parts then
      -- Strip trailing separators, but keep a bare root like "C:\"
      part = part:gsub("([^/\\])[/\\]+$", "%1")
    end
    parts[i] = part
  end

  return table.concat(parts, "/")
end

---Get filename without extension
---@param path string File path
---@return string Filename without extension
function M.get_basename(path)
  local filename = vim.fn.fnamemodify(path, ":t")
  return filename:match("(.+)%..+$") or filename
end

---Get file extension
---@param path string File path
---@return string Extension (without dot)
function M.get_extension(path)
  return vim.fn.fnamemodify(path, ":e")
end

-- ============================================================================
-- FRONTMATTER HELPERS
-- ============================================================================

---Normalize a frontmatter `tags` value to a Lua array of strings.
---Defensive helper: frontmatter tags may be a table (expected), a single
---string (e.g. legacy notes with `tags: work`), or nil (missing field).
---Using this instead of raw `vim.tbl_contains(fm.tags, ...)` avoids runtime
---errors when tags is not a table.
---@param tags any Raw tags value from parsed frontmatter
---@return string[] Array of tag strings (empty if tags is nil/invalid)
function M.normalize_tags(tags)
  if type(tags) == "table" then
    return tags
  elseif type(tags) == "string" and tags ~= "" then
    return { tags }
  end
  return {}
end

---Check whether a frontmatter `tags` value contains a given tag.
---Safe against tags being a string, nil, or any other non-table value.
---@param tags any Raw tags value from parsed frontmatter
---@param tag string Tag to look for
---@return boolean True if tag is present
function M.has_tag(tags, tag)
  return vim.tbl_contains(M.normalize_tags(tags), tag)
end

-- ============================================================================
-- USER INPUT UTILITIES
-- ============================================================================

---Prompt user for text input
---@param prompt string Prompt message
---@param default? string Default value
---@return string|nil User input or nil if cancelled
function M.prompt_text(prompt, default)
  local ok, result = pcall(vim.fn.input, {
    prompt = prompt .. ": ",
    default = default or "",
  })

  if ok and result and result ~= "" then
    return result
  end
  return nil
end

---Prompt user to select from list
---@param prompt string Prompt message
---@param items table List of items to choose from
---@return string|nil Selected item or nil if cancelled
function M.prompt_select(prompt, items)
  local ok, choice = pcall(vim.ui.select, items, {
    prompt = prompt,
  }, function(item)
    return item
  end)

  if ok then
    return choice
  end
  return nil
end

---Confirm yes/no with user
---@param prompt string Prompt message
---@return boolean True if confirmed
function M.confirm(prompt)
  local result = vim.fn.confirm(prompt, "&Yes\n&No", 2)
  return result == 1
end

-- ============================================================================
-- EXTERNAL COMMANDS
-- ============================================================================

---Run an external CLI and return its stdout as lines.
---Shared by the VoidDash integrations (khal, task), which each wrapped an
---identical copy of this around their own binary.
---@param bin string Executable that must be on $PATH
---@param args string[] Arguments passed to it
---@param opts? { env?: table<string, string> } Optional process environment overrides
---@return string[]|nil lines, string|nil err
function M.run_command(bin, args, opts)
  if vim.fn.executable(bin) ~= 1 then
    return nil, bin .. " not found in PATH"
  end

  local command = { bin }
  if opts and opts.env then
    local names = vim.tbl_keys(opts.env)
    table.sort(names)
    command = { "env" }
    for _, name in ipairs(names) do
      table.insert(command, name .. "=" .. opts.env[name])
    end
    table.insert(command, bin)
  end
  vim.list_extend(command, args)

  local result = vim.fn.system(command)
  if vim.v.shell_error ~= 0 then
    return nil, result
  end

  local lines = {}
  for line in result:gmatch("[^\n]+") do
    table.insert(lines, line)
  end
  return lines
end

return M
