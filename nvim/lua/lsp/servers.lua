-- LSP server setup.
--
-- This module loads and enables all configured LSP servers using the native
-- Neovim LSP API. Individual server settings live in `lsp/server/*`.

local M = {}
local servers = {
  "lua_ls",

  -- azure / .net
  "omnisharp",
  "bicep",
  -- PowerShell is deliberately absent: lua/plugin/powershell.lua starts
  -- PowerShell Editor Services through powershell.nvim, which also provides the
  -- terminal, eval and DAP integration. Enabling it here as well attached two
  -- PSES clients to every ps1 buffer.

  -- shell
  "bashls",

  -- python
  "basedpyright",

  -- kotlin / spring boot
  "kotlin_language_server",
  "html",
  "cssls",
  "jsonls",
  "svelte",
  "ts_ls",

  -- config / docs
  "yamlls",

  -- Markdown diagnostics and completion for vault wiki-links and repository
  -- docs. Marksman does not attach to daily-note buffers in allMight.
  "marksman",
}

local function setup_server(server_name, config)
  vim.lsp.config[server_name] = config
  vim.lsp.enable(server_name)
end

local function setup_basedpyright(server_config)
  if server_config.autocmd then
    server_config.autocmd()
  end
end

local function setup_configured_server(server_name)
  local ok, server_config = pcall(require, "lsp.server." .. server_name)

  if not ok or not server_config.config then
    vim.notify("Failed to load LSP server config: " .. server_name, vim.log.levels.WARN)
    return
  end

  -- basedpyright manages its setup through a custom autocmd because it
  -- dynamically resolves Python environments per project.
  if server_name == "basedpyright" then
    setup_basedpyright(server_config)
    return
  end

  setup_server(server_name, server_config.config)
end

function M.setup()
  for _, server_name in ipairs(servers) do
    setup_configured_server(server_name)
  end
end

return M
