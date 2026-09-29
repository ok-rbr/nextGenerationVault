-- LSP diagnostic configuration.
--
-- This module configures Neovim's diagnostic UI for LSP clients.
-- Diagnostic helper actions live in `config.diagnostics`.

local M = {}

local diagnostic_icons = require("config.icons").icons.diagnostics

local diagnostic_config = {
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = diagnostic_icons.error,
      [vim.diagnostic.severity.WARN] = diagnostic_icons.warn,
      [vim.diagnostic.severity.HINT] = diagnostic_icons.hint,
      [vim.diagnostic.severity.INFO] = diagnostic_icons.info,
    },
  },
  update_in_insert = true,
  underline = true,
  severity_sort = true,
  virtual_text = false,
  float = {
    focusable = false,
    style = "minimal",
    border = "single",
    source = "always",
    header = "",
    prefix = "",
    suffix = "",
  },
}

function M.setup()
  vim.diagnostic.config(diagnostic_config)
end

return M
