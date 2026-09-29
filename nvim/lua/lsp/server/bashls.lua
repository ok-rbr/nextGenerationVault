-- Bash Language Server

local M = {}

M.config = {
  cmd = { "bash-language-server", "start" },
  filetypes = { "bash", "sh", "zsh" },
  root_markers = { ".git", vim.uv.cwd() },
  settings = {
    bashIde = {
      globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
    },
  },
}

return M
