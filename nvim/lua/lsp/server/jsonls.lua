-- JSON Language Server
--
-- Install: Mason → json-lsp
-- Requires: npm install -g vscode-langservers-extracted
-- Optional: b0o/SchemaStore.nvim for automatic schema detection

local M = {}

local ok_schemastore, schemastore = pcall(require, "schemastore")

M.config = {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { "package.json", ".git" },
  single_file_support = true,
  init_options = {
    provideFormatter = true,
  },
  settings = {
    json = {
      -- Schema store integration: auto-detect well-known schemas by filename.
      schemas = ok_schemastore and schemastore.json.schemas() or nil,
      validate = { enable = true },
      format = {
        -- Disabled: conform.nvim uses prettier for JSON formatting.
        enable = false,
      },
    },
  },
}

return M
