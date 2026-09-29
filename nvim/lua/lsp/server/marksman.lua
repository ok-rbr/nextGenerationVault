-- Marksman Language Server (Markdown)
--
-- Layer 2 of the note-taking split (docs/ADR-005). It is here for one thing
-- the rest of the stack cannot do: report a [[wiki-link]] that points at
-- nothing. Without it, a link broken by a rename or a move stays silent until
-- the note is needed and cannot be found — which is the failure mode the
-- stem-as-id contract in notes/frontmatter.lua is meant to prevent, and this
-- is how a remaining violation gets noticed.
--
-- Install: Mason → marksman
-- Requires: https://github.com/artempyanykh/marksman

local M = {}
local profile = require("core.profile")
local root_markers = { ".marksman.toml", ".git" }

local function is_daily_note(bufnr)
  if not profile.is("allMight") then
    return false
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then
    return false
  end

  local notes = require("notes.init")
  local utils = require("notes.utils")
  local relative = utils.relative_path(utils.get_notebook_root(), filename)
  if not relative then
    return false
  end

  local daily_dir = notes.config.directories.daily:gsub("\\", "/"):gsub("/+$", "")
  relative = relative:gsub("\\", "/")
  return relative == daily_dir or relative:sub(1, #daily_dir + 1) == daily_dir .. "/"
end

M.config = {
  cmd = { "marksman", "server" },
  filetypes = { "markdown", "markdown.mdx" },
  root_markers = root_markers,

  root_dir = function(bufnr, on_dir)
    -- Marksman can stall while indexing daily notes; keep it off those buffers
    -- buffers in the allMight profile without affecting other Markdown files.
    if is_daily_note(bufnr) then
      on_dir(nil)
      return
    end

    on_dir(vim.fs.root(vim.api.nvim_buf_get_name(bufnr), root_markers))
  end,
}

return M
