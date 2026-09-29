-- plugin for SQL language server setup and configuration

return {

  "nanotee/sqls.nvim",
  ft = { "sql", "mysql", "plsql" },
  dependencies = {
    "williamboman/mason.nvim",
    "neovim/nvim-lspconfig",
  },
  cmd = {
    "SqlsExecuteQuery",
    "SqlsExecuteQueryVertical",
    "SqlsShowDatabases",
    "SqlsShowSchemas",
    "SqlsShowConnections",
    "SqlsSwitchDatabase",
    "SqlsSwitchConnection",
  },
  keys = {
    {
      "<leader>qe",
      "<cmd>SqlsExecuteQuery<CR>",
      desc = "[Q]uery [E]xecute",
      ft = "sql",
    },
    {
      "<leader>qv",
      "<cmd>SqlsExecuteQueryVertical<CR>",
      desc = "[Q]uery Execute [V]ertical",
      ft = "sql",
    },
    {
      "<leader>qd",
      "<cmd>SqlsShowDatabases<CR>",
      desc = "[Q]uery Show [D]atabases",
      ft = "sql",
    },
    {
      "<leader>qs",
      "<cmd>SqlsShowSchemas<CR>",
      desc = "[Q]uery Show [S]chemas",
      ft = "sql",
    },
    {
      "<leader>qc",
      "<cmd>SqlsShowConnections<CR>",
      desc = "[Q]uery Show [C]onnections",
      ft = "sql",
    },
    {
      "<leader>qD",
      "<cmd>SqlsSwitchDatabase<CR>",
      desc = "[Q]uery Switch [D]atabase",
      ft = "sql",
    },
    {
      "<leader>qC",
      "<cmd>SqlsSwitchConnection<CR>",
      desc = "[Q]uery Switch [C]onnection",
      ft = "sql",
    },
  },
  config = function()
    -- Ensure sqls is installed via Mason
    local mason_registry = require("mason-registry")
    if not mason_registry.is_installed("sqls") then
      vim.notify("Installing sqls via Mason...", vim.log.levels.INFO)
      local sqls_package = mason_registry.get_package("sqls")
      sqls_package:install()
    end

    -- Configure sqls LSP
    local lspconfig = require("lspconfig")

    lspconfig.sqls.setup({
      capabilities = pcall(require, "cmp_nvim_lsp") and require("cmp_nvim_lsp").default_capabilities() or {},
      -- Only the sqls-specific commands belong here. The shared LSP keymaps
      -- (gd, gD, gi, gr, K, <C-k>, <leader>l*) are set for every client by
      -- lua/lsp/keymaps.lua on LspAttach; repeating them here bound rename and
      -- code action to <leader>rn / <leader>ca in SQL buffers only, while the
      -- rest of the config uses <leader>lr / <leader>la.
      on_attach = function(client, bufnr)
        require("sqls").on_attach(client, bufnr)
      end,
      settings = {
        sqls = {
          -- Database connections (can be configured per project)
          connections = {
            -- Example connection configurations
            -- {
            --   driver = "mysql",
            --   dataSourceName = "username:password@tcp(localhost:3306)/database_name",
            -- },
            -- {
            --   driver = "postgres",
            -- luacheck: ignore 631
            --   dataSourceName = "host=localhost port=5432 user=username password=password dbname=database_name sslmode=disable",
            -- },
            -- {
            --   driver = "sqlite3",
            --   dataSourceName = "path/to/database.db",
            -- },
          },
          -- Completion settings
          completion = {
            enable = true,
            snippets = true,
          },
          -- Diagnostics settings
          diagnostics = {
            enable = true,
          },
          -- Formatting settings
          format = {
            enable = true,
          },
        },
      },
    })

    -- Set up filetype associations
    vim.filetype.add({
      extension = {
        sql = "sql",
        mysql = "mysql",
        psql = "sql",
        plsql = "plsql",
      },
      pattern = {
        [".*%.sql"] = "sql",
        [".*%.mysql"] = "mysql",
        [".*%.plsql"] = "plsql",
      },
    })

    -- Auto-command to set up SQL-specific settings
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "sql", "mysql", "plsql" },
      callback = function()
        -- Enable line numbers for SQL files
        vim.opt_local.number = true
        vim.opt_local.relativenumber = true

        -- Set indentation for SQL
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.expandtab = true

        -- Enable word wrap for long queries
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
      end,
    })
  end,
}
