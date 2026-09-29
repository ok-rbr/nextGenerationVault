-- C# (OmniSharp)

local M = {}

local pid = vim.fn.getpid()

M.config = {
  cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(pid) },
  filetypes = { "cs", "vb" },
  root_markers = { "*.sln", "*.csproj", "*.slnx" },
  enable_roslyn_analyzers = true,
  organize_imports_on_format = true,
  enable_import_completion = true,
  handlers = {
    ["textDocument/definition"] = function(...)
      return require("omnisharp_extended").handler(...)
    end,
  },
}

return M
