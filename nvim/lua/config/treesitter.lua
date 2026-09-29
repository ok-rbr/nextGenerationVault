-- native treesitter configuration.
--
-- neovim 0.12+ provides built-in treesitter integration.
-- This module keeps startup deterministic by only registering runtime mappings
-- during boot. Parser installation is exposed through explicit user commands.

local M = {}

-- Parsers managed by this config.
--
-- Keep this list explicit and close to the languages you actually use.
-- Installation is intentionally not performed during startup.
local parsers = {
  -- Python / Django.
  "python",
  "htmldjango",

  -- Web.
  "html",
  "css",
  "javascript",
  "typescript",
  "tsx",
  "json",
  "jsonc",

  -- Markup / config.
  "yaml",
  "toml",
  "gotmpl",
  "markdown",
  "markdown_inline",
  "xml",

  -- Shell / scripting.
  "bash",
  "lua",

  -- .NET.
  "c_sharp",

  -- Misc.
  "query",
  "regex",
  "diff",
  "gitcommit",
  "git_rebase",
}

-- Filetype-to-parser mappings.
--
-- Use this for filetypes whose name does not directly match the parser name.
local language_mappings = {
  htmldjango = { "htmldjango" },
  c_sharp = { "csharp", "cs" },
}

local function register_languages()
  for language, filetypes in pairs(language_mappings) do
    vim.treesitter.language.register(language, filetypes)
  end
end

local function install_configured_parsers()
  if not vim.treesitter.install then
    vim.notify("vim.treesitter.install is not available", vim.log.levels.WARN, {
      title = "treesitter",
    })
    return
  end

  vim.treesitter.install(parsers)
end

local function show_configured_parsers()
  vim.notify(table.concat(parsers, "\n"), vim.log.levels.INFO, {
    title = "configured treesitter parsers",
  })
end

local function create_commands()
  vim.api.nvim_create_user_command("TreesitterInstallConfigured", install_configured_parsers, {
    desc = "Install all configured Treesitter parsers",
  })

  vim.api.nvim_create_user_command("TreesitterShowParsers", show_configured_parsers, {
    desc = "Show configured Treesitter parsers",
  })
end

function M.setup()
  register_languages()
  create_commands()
end

return M
