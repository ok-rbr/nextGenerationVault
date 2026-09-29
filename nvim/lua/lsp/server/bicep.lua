-- Bicep Language Server
-- Requires the `bicep` CLI to be available in PATH.

local M = {}

M.config = {
  cmd = { "bicep", "lsp" },
  filetypes = { "bicep" },
  root_markers = { "bicepconfig.json", "*.bicep", ".git" },
  single_file_support = true,
}

return M
