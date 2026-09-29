-- TypeScript Language Server (ts_ls)
-- Handles JavaScript and TypeScript files.
-- Svelte files are intentionally excluded – handled by svelte-language-server.

local M = {}

local inlay_hints = {
  includeInlayParameterNameHints = "all",
  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayVariableTypeHints = false,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayEnumMemberValueHints = true,
}

M.config = {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
  init_options = {
    hostInfo = "neovim",
  },
  settings = {
    -- ts_ls reads the same hint settings under both language keys; one table
    -- means they cannot drift apart.
    typescript = { inlayHints = inlay_hints },
    javascript = { inlayHints = inlay_hints },
  },
}

return M
