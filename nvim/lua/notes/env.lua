-- notes/env.lua
-- Load configuration from .env file without evaluating shell expansions.

local M = {}
local cached_file
local cached_signature
local cached_env
local uv = vim.uv or vim.loop

local function copy_env(env)
  local copy = {}
  for key, value in pairs(env) do
    copy[key] = value
  end
  return copy
end

local function expand_home(value)
  local home = vim.env.HOME or vim.fn.expand("~")
  value = value:gsub("%$HOME([^%w_])", function(suffix)
    return home .. suffix
  end)
  value = value:gsub("%$HOME$", function()
    return home
  end)

  if value == "~" then
    return home
  elseif value:sub(1, 2) == "~/" or value:sub(1, 2) == "~\\" then
    return home .. value:sub(2)
  end

  return value
end

local function file_signature(path)
  local stat = uv.fs_stat(path)
  if not stat then
    return "missing"
  end

  local mtime = stat.mtime or {}
  local ctime = stat.ctime or {}
  return table.concat({
    tostring(stat.size or ""),
    tostring(stat.mode or ""),
    tostring(mtime.sec or ""),
    tostring(mtime.nsec or ""),
    tostring(ctime.sec or ""),
    tostring(ctime.nsec or ""),
  }, ":")
end

---Load .env file from the Neovim config directory, cached until the file changes.
---@return table<string, string> Environment variables
function M.load_env()
  local env_file = vim.fn.stdpath("config") .. "/.env"
  local signature = file_signature(env_file)
  if cached_file == env_file and cached_signature == signature and cached_env then
    return copy_env(cached_env)
  end

  local env = {}
  if vim.fn.filereadable(env_file) == 1 then
    for _, line in ipairs(vim.fn.readfile(env_file)) do
      if line:match("%S") and not line:match("^%s*#") then
        local key, value = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
        if key and value then
          value = value:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
          env[key] = expand_home(value)
        end
      end
    end
  end

  cached_file = env_file
  cached_signature = signature
  cached_env = env
  return copy_env(env)
end

---Discard the cached file values so the next read picks up edits.
function M.invalidate()
  cached_file = nil
  cached_signature = nil
  cached_env = nil
end

---Get NOTES_ROOT from .env or fallback to default
---@return string|nil Notes root path or nil if not set
function M.get_notes_root()
  local env = M.load_env()
  return env.NOTES_ROOT
end

---Get the Neovim templates directory from .env, if configured.
---Vault-relative (for example "99_system/015_templates"). Kept separate from
---the Obsidian template directory on purpose: Obsidian's templates use
---Templater and contain JavaScript that lua/notes/ cannot execute.
---@return string|nil Vault-relative templates directory or nil if not set
function M.get_templates_dir()
  return M.load_env().NOTES_TEMPLATES_DIR
end

---Get a value from the generated .env file
---@param key string Environment key
---@return string|nil Configured value or nil if not set
function M.get(key)
  return M.load_env()[key]
end

return M
