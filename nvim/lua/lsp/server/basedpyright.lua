-- Python (basedpyright)

local M = {}
local python_utils = require("utils.python")

-- Only root_markers is read from M.config (used by the autocmd below).
-- name/cmd/filetypes are hardcoded in vim.lsp.start to keep the call self-contained.
M.config = {
  root_markers = {
    "pyproject.toml",
    "requirements.txt",
    "Pipfile",
    "setup.py",
    "setup.cfg",
    "pyrightconfig.json",
    "manage.py", -- Django project root
    ".git",
  },
}

M.autocmd = function()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
      local root = vim.fs.root(0, M.config.root_markers) or vim.fs.dirname(vim.api.nvim_buf_get_name(0))

      local python_path = python_utils.get_python_path(root, "basedpyright")

      local client, err = vim.lsp.start({
        name = "basedpyright",
        cmd = { "basedpyright-langserver", "--stdio" },
        root_dir = root,
        before_init = function(_, config)
          config.settings.python = config.settings.python or {}
          config.settings.python.pythonPath = python_path
        end,
        settings = {
          basedpyright = {
            disableOrganizeImports = true,
            analysis = {
              autoSearchPaths = true,
              autoImportCompletions = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
              typeCheckingMode = "off",
              inlayHints = {
                variableTypes = true,
                callArgumentNames = true,
                functionReturnTypes = true,
                genericTypes = false,
              },
            },
          },
          python = {}, -- populated in before_init
        },
      })

      if client then
        vim.lsp.buf_attach_client(0, client)
      else
        vim.notify(
          "basedpyright: Failed to start LSP client.\n"
            .. (err or "Unknown error")
            .. "\nPython path used: "
            .. python_path,
          vim.log.levels.ERROR
        )
      end
    end,
  })
end

return M
