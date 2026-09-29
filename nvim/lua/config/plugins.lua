local profile = require("core.profile")

-- Core plugins loaded for every profile (minimal baseline).
-- Includes: colorscheme, basic UI helpers, text-object enhancements,
-- fuzzy finder and key-discovery.
local plugins = {
  { import = "plugin.theme" },
  { import = "plugin.snacks" },
  { import = "plugin.which-key" },
  { import = "plugin.telescope" },
  { import = "plugin.mini-ai" },
  { import = "plugin.mini-pairs" },
  { import = "plugin.ts-comments" },
  { import = "plugin.nvim-ts-autotag" },
}

-- dev and allMight: LSP, debugging, formatting, git, completion, enhanced UI
-- and workflow tools.
if profile.at_least("dev") then
  vim.list_extend(plugins, {
    -- lsp / dev
    { import = "plugin.lspconfig" },
    { import = "plugin.mason" },
    { import = "plugin.omnisharp-extended-lsp" },
    { import = "plugin.powershell" },
    { import = "plugin.nvim-bicep" },

    -- completion
    { import = "plugin.nvim-cmp" },

    -- formatting
    { import = "plugin.conform" },

    -- debugging
    { import = "plugin.nvim-dap" },

    -- git
    { import = "plugin.git" },

    -- ui
    { import = "plugin.devicons" },
    { import = "plugin.lualine" },
    { import = "plugin.bufferline" },
    { import = "plugin.noice" },
    { import = "plugin.nvim-colorizer" },
    { import = "plugin.log-highlight" },

    -- navigation
    { import = "plugin.grug-far" },

    -- editing
    { import = "plugin.nvim-ufo" },
    { import = "plugin.autolist" },

    -- workflow
    { import = "plugin.persistence" },
    { import = "plugin.todo-comments" },
    { import = "plugin.trouble" },
  })
end

-- allMight only: AI, notes, media and miscellaneous integrations.
if profile.is("allMight") then
  vim.list_extend(plugins, {
    -- ai
    { import = "plugin.copilot" },

    -- notes
    { import = "plugin.notes" },
    -- { import = "plugin.obsidian" }, -- Keep the spec available without the runtime dependency.
    { import = "plugin.render-markdown" },

    -- Specifications that exist under lua/plugin/ but are deliberately not
    -- loaded. lazy.nvim only sees what is imported here, so a spec file on its
    -- own does nothing; uncomment a line to enable it.
    -- { import = "plugin.lazydocker" },
    -- { import = "plugin.octo" },
    -- { import = "plugin.sqls" },
  })
end

return plugins
