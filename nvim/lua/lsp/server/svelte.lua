-- Svelte Language Server

local M = {}

M.config = {
  cmd = { "svelteserver", "--stdio" },
  filetypes = { "svelte" },
  root_markers = { "svelte.config.js", "svelte.config.ts", "package.json", ".git" },
  settings = {
    svelte = {
      plugin = {
        html = { completions = { enable = true, emmet = true } },
        svelte = { defaultScriptLanguage = "ts" },
      },
    },
  },
}

return M
