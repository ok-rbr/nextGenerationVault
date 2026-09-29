---@class Snacks
---@diagnostic disable: undefined-global
---
-- icons
local icons = require("config.icons").icons.ui

-- dynamic header
local header = require("utils.header")

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = true,
    event = "UIEnter",

    opts = {
      -- animate
      animate = {
        enabled = true,
        duration = 20,
        easing = "linear",
        fps = 60,
      },

      -- big files (~1.5mb)
      bigfile = {
        enabled = true,
        size = 1.5 * 1024 * 1024,
        setup = function(ctx)
          vim.cmd([[NoMatchParen]])
          vim.schedule(function()
            vim.bo[ctx.buf].syntax = ctx.ft
          end)
        end,
      },

      -- dashboard
      dashboard = {
        enabled = true,
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
        preset = {
          header = header.get_dashboard_header(),
          keys = {
            {
              icon = icons.file,
              key = "f",
              desc = "Find File",
              action = ":lua Snacks.dashboard.pick('files')",
            },
            {
              icon = icons.new_file,
              key = "n",
              desc = "New File",
              action = ":ene | startinsert",
            },
            {
              icon = icons.find_text,
              key = "g",
              desc = "Find Text",
              action = ":lua Snacks.dashboard.pick('live_grep')",
            },
            {
              icon = icons.recent,
              key = "r",
              desc = "Recent Files",
              action = ":lua Snacks.dashboard.pick('oldfiles')",
            },
            {
              icon = icons.config,
              key = "c",
              desc = "Config",
              action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })",
            },
            {
              icon = icons.session,
              key = "s",
              desc = "Restore Session",
              section = "session",
            },
            {
              icon = icons.lazy,
              key = "L",
              desc = "Lazy",
              action = ":Lazy",
              enabled = package.loaded.lazy ~= nil,
            },
            {
              icon = icons.quit,
              key = "q",
              desc = "Quit",
              action = ":qa",
            },
          },
        },
      },

      input = { enabled = true },

      -- disabled (using noice)
      notifier = { enabled = false },

      quickfile = { enabled = true },
      scope = { enabled = true },

      -- scroll
      scroll = {
        enabled = true,
        animate = {
          duration = { step = 15, total = 250 },
          easing = "linear",
        },
      },

      statuscolumn = { enabled = false },

      -- disabled (using toggleterm)
      terminal = { enabled = false },

      toggle = { enabled = true },

      -- word highlight
      words = {
        enabled = true,
        debounce = 200,
      },

      -- zen
      zen = {
        enabled = true,
        toggles = {
          dim = true,
          git_signs = false,
          mini_diff_signs = false,
        },
        show = {
          tabline = false,
          statusline = false,
        },
        win = {
          backdrop = 95,
          width = 0.8,
        },
      },
    },

    keys = {
      {
        "<leader>bd",
        function()
          Snacks.bufdelete()
        end,
        desc = "Delete Buffer",
      },

      {
        "<leader>gb",
        function()
          Snacks.git.blame_line()
        end,
        desc = "Git Blame Line",
      },
      {
        "<leader>gB",
        function()
          Snacks.gitbrowse()
        end,
        desc = "Git Browse",
      },

      {
        "<leader>cR",
        function()
          Snacks.rename.rename_file()
        end,
        desc = "Rename File",
      },

      {
        "]]",
        function()
          Snacks.words.jump(vim.v.count1)
        end,
        desc = "Next Reference",
        mode = { "n", "t" },
      },
      {
        "[[",
        function()
          Snacks.words.jump(-vim.v.count1)
        end,
        desc = "Prev Reference",
        mode = { "n", "t" },
      },

      {
        "<leader>N",
        function()
          Snacks.win.open("https://neovim.io/news/", { width = 0.6, height = 0.6 })
        end,
        desc = "Neovim News",
      },

      {
        "<leader>z",
        function()
          Snacks.zen()
        end,
        desc = "Toggle Zen Mode",
      },
      {
        "<leader>Z",
        function()
          Snacks.zen.zoom()
        end,
        desc = "Toggle Zoom",
      },
    },

    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- debug helpers
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd

          -- toggles
          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle
            .option("conceallevel", {
              off = 0,
              on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
            })
            :map("<leader>uc")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle
            .option("background", {
              off = "light",
              on = "dark",
              name = "Dark Background",
            })
            :map("<leader>ub")
          Snacks.toggle.inlay_hints():map("<leader>uh")
        end,
      })
    end,
  },
}
