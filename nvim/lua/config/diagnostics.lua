-- diagnostic helper functions.
--
-- This module contains only diagnostic-related utility logic.
-- Keymaps are registered in `config.keymaps`.

local M = {}

local virtual_text_enabled = false

local severity_names = {
  [vim.diagnostic.severity.ERROR] = "error",
  [vim.diagnostic.severity.WARN] = "warn",
  [vim.diagnostic.severity.INFO] = "info",
  [vim.diagnostic.severity.HINT] = "hint",
}

local function format_diag(diagnostic)
  local severity = severity_names[diagnostic.severity] or "info"
  local file = vim.api.nvim_buf_get_name(diagnostic.bufnr)
  local line = (diagnostic.lnum or 0) + 1
  local col = (diagnostic.col or 0) + 1
  local source = diagnostic.source or "lsp"
  local message = (diagnostic.message or ""):gsub("\n", " ")

  return string.format("%s:%d:%d: %s (%s): %s", file, line, col, severity, source, message)
end

local function sort_diagnostics(a, b)
  if a.bufnr ~= b.bufnr then
    return a.bufnr < b.bufnr
  end

  if a.lnum ~= b.lnum then
    return a.lnum < b.lnum
  end

  return (a.col or 0) < (b.col or 0)
end

local function copy_diagnostics(diags, empty_message, success_message)
  if #diags == 0 then
    return vim.notify(empty_message, vim.log.levels.INFO)
  end

  table.sort(diags, sort_diagnostics)

  local text = table.concat(vim.tbl_map(format_diag, diags), "\n")
  vim.fn.setreg("+", text)

  vim.notify(success_message, vim.log.levels.INFO)
end

function M.yank_line()
  local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diags = vim.diagnostic.get(0, { lnum = lnum })

  copy_diagnostics(diags, "no diagnostics on this line", "copied line diagnostics to clipboard")
end

function M.yank_buffer()
  local diags = vim.diagnostic.get(0)

  copy_diagnostics(diags, "no diagnostics in buffer", "copied buffer diagnostics to clipboard")
end

function M.yank_workspace()
  local diags = vim.diagnostic.get()

  copy_diagnostics(diags, "no diagnostics in workspace", "copied workspace diagnostics to clipboard")
end

function M.toggle_virtual_text()
  virtual_text_enabled = not virtual_text_enabled

  vim.diagnostic.config({
    virtual_text = virtual_text_enabled and true or false,
  })

  vim.notify("Virtual text " .. (virtual_text_enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end

return M
