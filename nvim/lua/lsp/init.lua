-- LSP setup orchestration.
--
-- This module only coordinates the LSP subsystem.
-- Dedicated responsibilities live in separate modules under `lsp/*`.

local M = {}

local icons = require("config.icons").icons.lsp

local function configure_lsp_ui()
  local completion_kinds = vim.lsp.protocol.CompletionItemKind

  for index, kind in ipairs(completion_kinds) do
    completion_kinds[index] = icons[kind] and icons[kind] .. kind or kind
  end
end

function M.setup()
  require("lsp.diagnostics").setup()
  require("lsp.capabilities").setup()
  require("lsp.commands").setup()
  require("lsp.keymaps").setup()
  require("lsp.servers").setup()

  configure_lsp_ui()
end

return M
