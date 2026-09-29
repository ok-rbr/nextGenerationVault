-- Mason: external tool manager for LSP servers, formatters, and DAP adapters.

return {
  {
    "williamboman/mason.nvim",

    cmd = {
      "Mason",
      "MasonInstall",
      "MasonUninstall",
      "MasonUpdate",
    },

    event = { "BufReadPost", "BufNewFile" },

    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },

    config = function()
      require("mason").setup()

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "omnisharp",
          "powershell_es",
          "bashls",
          "basedpyright",
          "kotlin_language_server",
          "ts_ls",
          "html",
          "cssls",
          "jsonls",
          "svelte",
          "yamlls",
          "marksman",
        },

        automatic_enable = false,
      })
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",

    event = { "BufReadPost", "BufNewFile" },

    dependencies = {
      "williamboman/mason.nvim",
    },

    opts = {
      ensure_installed = {
        -- Formatters
        "stylua",
        "prettier",
        "isort",
        "yapf",
        "ktlint",

        -- DAP adapters
        "debugpy",
        "js-debug-adapter",
        "kotlin-debug-adapter",
      },

      auto_update = false,
      run_on_start = true,
    },
  },
}
