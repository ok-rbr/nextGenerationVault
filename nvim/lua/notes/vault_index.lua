-- notes/vault_index.lua
-- Shared, short-lived index for frontmatter-bearing Markdown files in the vault.

local utils = require("notes.utils")
local frontmatter = require("notes.frontmatter")
local uv = vim.uv or vim.loop

local M = {}
local CACHE_TTL_NS = 5 * 1000 * 1000 * 1000
local cache

local function normalize_path(path)
  return vim.fs.normalize(vim.fn.fnamemodify(path, ":p")):gsub("\\", "/"):gsub("/+$", "")
end

local function is_template_note(path, templates_root)
  local note_path = normalize_path(path)
  local prefix = templates_root .. "/"
  return note_path == templates_root or note_path:sub(1, #prefix) == prefix
end

local function copy_notes(notes, include_plain)
  local result = {}
  for _, note in ipairs(notes) do
    if include_plain or not note.plain then
      result[#result + 1] = note
    end
  end
  return result
end

---Invalidate the index after an in-editor or external vault change.
function M.invalidate()
  cache = nil
end

---Scan the vault once and reuse parsed frontmatter briefly across consumers.
---Notes without a frontmatter block are skipped unless `include_plain` is set,
---in which case they are returned with an empty `frontmatter` table (the link
---layer needs every note; the metadata queries only those with metadata).
---@param opts? table {path?: string, recursive?: boolean, force?: boolean, include_plain?: boolean}
---@return table[] Array of {path: string, frontmatter: table}
function M.scan(opts)
  opts = opts or {}
  local root = opts.path or utils.get_notebook_root()
  local recursive = opts.recursive ~= false
  local templates_dir = require("notes.init").config.directories.templates
  local templates_root = normalize_path(utils.path_join(root, templates_dir))
  local key = table.concat({ normalize_path(root), templates_root, recursive and "recursive" or "flat" }, "\0")
  local plain = opts.include_plain == true
  local now = uv.hrtime()

  if not opts.force and cache and cache.key == key and now - cache.scanned_at < CACHE_TTL_NS then
    return copy_notes(cache.notes, plain)
  end

  local pattern = recursive and "**/*.md" or "*.md"
  local files = vim.fn.globpath(root, pattern, false, true)
  local notes = {}

  for _, path in ipairs(files) do
    if not is_template_note(path, templates_root) then
      local fm = frontmatter.parse_file(path)
      table.insert(notes, { path = path, frontmatter = fm or {}, plain = fm == nil })
    end
  end

  cache = {
    key = key,
    scanned_at = uv.hrtime(),
    notes = notes,
  }
  return copy_notes(notes, plain)
end

return M
