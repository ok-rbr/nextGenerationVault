-- formatting utilities.
--
-- project-first formatting policy.
-- neovim should only format when the project explicitly provides formatter
-- configuration.

local M = {}

local prettier_config_files = {
  ".prettierrc",
  ".prettierrc.json",
  ".prettierrc.yml",
  ".prettierrc.yaml",
  ".prettierrc.json5",
  ".prettierrc.js",
  ".prettierrc.cjs",
  ".prettierrc.mjs",
  "prettier.config.js",
  "prettier.config.cjs",
  "prettier.config.mjs",
  "prettier.config.ts",
  "prettier.config.cts",
  "prettier.config.mts",
}

local project_config_files_by_filetype = {
  lua = {
    ".stylua.toml",
    "stylua.toml",
  },

  javascript = prettier_config_files,
  typescript = prettier_config_files,
  svelte = prettier_config_files,
  json = prettier_config_files,
  html = prettier_config_files,
  css = prettier_config_files,
  markdown = prettier_config_files,
  yaml = prettier_config_files,
  yml = prettier_config_files,

  python = {
    "pyproject.toml",
    "setup.cfg",
    "tox.ini",
    ".style.yapf",
    ".isort.cfg",
    "isort.cfg",
  },

  cs = {
    ".editorconfig",
  },

  powershell = {
    "PSScriptAnalyzerSettings.psd1",
  },
  ps1 = {
    "PSScriptAnalyzerSettings.psd1",
  },
  psm1 = {
    "PSScriptAnalyzerSettings.psd1",
  },
  psd1 = {
    "PSScriptAnalyzerSettings.psd1",
  },

  kotlin = {
    ".editorconfig",
  },
}

M.disabled_format_on_save = {
  -- python = true,
  -- kotlin = true,
  -- ps1 = true,
}

local function is_marp_buffer(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 60, false)
  if #lines == 0 or lines[1] ~= "---" then
    return false
  end

  for i = 2, #lines do
    if lines[i] == "---" or lines[i] == "..." then
      break
    end
    if lines[i]:match("^marp:%s*true") then
      return true
    end
  end

  return false
end

---Whether the buffer is a note inside the configured notebook.
---
---A vault note is never formatted on save. Two reasons, both specific to
---notes rather than to Markdown in general:
---
---  * Prettier reflows prose. At this repository's `proseWrap: "always"` a
---    `[[Note Title With Spaces]]` sitting near the margin is wrapped at one
---    of its spaces, which silently breaks the link — the exact failure this
---    stack was just repaired for (docs/ADR-005).
---  * It would put a second writer on the frontmatter block. notes/init.lua
---    already rewrites it on BufWritePre to refresh `updated`, and layer 1
---    owning frontmatter alone is what keeps a note's identity stable.
---
---`:Format` (`<leader>f`) still formats a note on request; only the automatic
---path is off. Markdown outside the vault, including this repository's own
---`docs/`, is unaffected.
---@param bufnr integer
---@return boolean
local function is_vault_note(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return false
  end

  local ok, notes_utils = pcall(require, "notes.utils")
  return ok and notes_utils.in_notebook(name)
end

local function get_buf_start_dir(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then
    return nil
  end

  return vim.fs.dirname(filename)
end

local function find_project_file(config_files, start_dir)
  if not config_files or not start_dir then
    return nil
  end

  return vim.fs.find(config_files, {
    upward = true,
    path = start_dir,
    type = "file",
  })[1]
end

function M.get_project_config_path(bufnr, filetype)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return nil
  end

  local resolved_filetype = filetype or vim.bo[bufnr].filetype
  local config_files = project_config_files_by_filetype[resolved_filetype]

  return find_project_file(config_files, get_buf_start_dir(bufnr))
end

function M.has_project_formatter_config(bufnr)
  return M.get_project_config_path(bufnr) ~= nil
end

function M.should_format_on_save(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local filetype = vim.bo[bufnr].filetype
  if M.disabled_format_on_save[filetype] then
    return false
  end

  if filetype == "markdown" and is_marp_buffer(bufnr) then
    return false
  end

  if filetype == "markdown" and is_vault_note(bufnr) then
    return false
  end

  return M.has_project_formatter_config(bufnr)
end

function M.toggle_format_on_save()
  local filetype = vim.bo.filetype

  if M.disabled_format_on_save[filetype] then
    M.disabled_format_on_save[filetype] = nil
    vim.notify("Format on save enabled for " .. filetype, vim.log.levels.INFO)
    return
  end

  M.disabled_format_on_save[filetype] = true
  vim.notify("Format on save disabled for " .. filetype, vim.log.levels.WARN)
end

function M.format_buffer(opts)
  opts = opts or {}

  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  if not M.has_project_formatter_config(bufnr) then
    vim.notify("Format skipped: no project-local formatter config found", vim.log.levels.INFO)
    return
  end

  return require("conform").format(vim.tbl_extend("force", {
    async = true,
    bufnr = bufnr,
    lsp_format = "never",
  }, opts))
end

return M
