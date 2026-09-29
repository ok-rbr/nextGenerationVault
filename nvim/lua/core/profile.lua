-- lua/core/profile.lua
--
-- Central profile system for Neovim configuration.
--
-- Three profiles are defined in ascending order of features:
--
--   core      – Minimal runtime: options, keymaps, autocmds, treesitter,
--               base plugin manager. No LSP, formatter, notes, AI or UI
--               extensions.
--
--   dev       – Development environment: adds LSP, debugging, diagnostics,
--               formatting and git integration on top of core.
--
--   allMight  – Full daily-driver environment (All Might from My Hero
--               Academia – "Full → All → allMight"): adds AI, notes, misc
--               tools and enhanced UI on top of dev.
--
-- Usage
-- -----
-- Select a profile at startup via the NVIM_PROFILE environment variable:
--
--   NVIM_PROFILE=core nvim
--   NVIM_PROFILE=dev  nvim
--
-- Without the variable (or with an unknown value) Neovim falls back to
-- "allMight", preserving the previous full-featured behaviour.
--
-- You can also set vim.g.nvim_profile in a machine-local init file before
-- the main init.lua is sourced (e.g. via --cmd in a wrapper script):
--
--   nvim --cmd "let g:nvim_profile='dev'" .
--
-- API
-- ---
--   require("core.profile").current()          -> "core"|"dev"|"allMight"
--   require("core.profile").is("dev")          -> boolean (exact match)
--   require("core.profile").at_least("dev")    -> boolean (>= level)

local M = {}

-- Ordered list of valid profile names (least to most features).
local VALID_PROFILES = { "core", "dev", "allMight" }

-- Numeric level for each profile – used by at_least().
local PROFILE_LEVEL = {}
for i, name in ipairs(VALID_PROFILES) do
  PROFILE_LEVEL[name] = i
end

--- Resolve the profile from the environment or vim globals.
---@return string
local function resolve()
  -- 1. Environment variable takes precedence.
  local env = os.getenv("NVIM_PROFILE")
  if env and env ~= "" then
    if PROFILE_LEVEL[env] then
      return env
    end
    -- Warn but don't abort – fall through to the default.
    vim.schedule(function()
      vim.notify(
        "[core.profile] Unknown NVIM_PROFILE value: '"
          .. env
          .. "'. Valid profiles: core, dev, allMight. Ignoring the environment value.",
        vim.log.levels.WARN
      )
    end)
  end

  -- 2. vim.g.nvim_profile (set via --cmd or a machine-local file).
  local g = vim.g.nvim_profile
  if g and g ~= "" then
    if PROFILE_LEVEL[g] then
      return g
    end
    vim.schedule(function()
      vim.notify(
        "[core.profile] Unknown vim.g.nvim_profile value: '"
          .. g
          .. "'. Valid profiles: core, dev, allMight. Falling back to 'allMight'.",
        vim.log.levels.WARN
      )
    end)
  end

  -- 3. Default: allMight (full feature set, backwards-compatible).
  return "allMight"
end

-- Cache the resolved value so every caller sees the same profile for a
-- given Neovim session (resolving only once avoids any env-change races).
local _current = nil

--- Return the name of the currently active profile.
---@return "core"|"dev"|"allMight"
function M.current()
  if not _current then
    _current = resolve()
  end
  return _current
end

--- Return true when the active profile matches `name` exactly.
---@param name "core"|"dev"|"allMight"
---@return boolean
function M.is(name)
  return M.current() == name
end

--- Return true when the active profile is at least as feature-rich as
--- `name`. Example: at_least("dev") is true for both "dev" and "allMight".
---@param name "core"|"dev"|"allMight"
---@return boolean
function M.at_least(name)
  local current_level = PROFILE_LEVEL[M.current()] or PROFILE_LEVEL["allMight"]
  local required_level = PROFILE_LEVEL[name] or 1
  return current_level >= required_level
end

return M
