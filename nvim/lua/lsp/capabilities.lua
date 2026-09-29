-- LSP capabilities configuration.
--
-- This module configures global client capabilities for all LSP servers.
-- Server-specific capabilities should stay in `lsp/server/*`.

local M = {}

local function make_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- Required by nvim-ufo for LSP-based folding.
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  -- Improve semantic token support for capable servers.
  capabilities.textDocument.semanticTokens.multilineTokenSupport = true

  -- Allow snippet support in completion items.
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  return capabilities
end

function M.setup()
  vim.lsp.config("*", {
    capabilities = make_capabilities(),
  })
end

return M
