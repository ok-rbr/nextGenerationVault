-- noice.nvim configuration
-- Improves command line UI, messages, LSP hover/signature, and notifications.

return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",

    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },

    keys = {
      {
        "<S-Enter>",
        function()
          require("noice").redirect(vim.fn.getcmdline())
        end,
        mode = "c",
        desc = "Redirect command line",
      },

      {
        "<leader>snl",
        function()
          require("noice").cmd("last")
        end,
        desc = "Noice last message",
      },

      {
        "<leader>snh",
        function()
          require("noice").cmd("history")
        end,
        desc = "Noice history",
      },

      {
        "<leader>sna",
        function()
          require("noice").cmd("all")
        end,
        desc = "Noice all messages",
      },

      {
        "<leader>snd",
        function()
          require("noice").cmd("dismiss")
        end,
        desc = "Dismiss notifications",
      },

      {
        "<C-f>",
        function()
          if not require("noice.lsp").scroll(4) then
            return "<C-f>"
          end
        end,
        mode = { "i", "n", "s" },
        silent = true,
        expr = true,
        desc = "Scroll documentation forward",
      },

      {
        "<C-b>",
        function()
          if not require("noice.lsp").scroll(-4) then
            return "<C-b>"
          end
        end,
        mode = { "i", "n", "s" },
        silent = true,
        expr = true,
        desc = "Scroll documentation backward",
      },
    },

    opts = function()
      local icons = require("config.icons").icons
      local cmd = icons.command
      local ui = icons.ui

      return {
        lsp = {
          -- Let Noice render markdown documentation through Treesitter.
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },

          progress = {
            enabled = true,
            throttle = 1000 / 30,
            view = "mini",
          },

          hover = {
            enabled = true,
            silent = false,
          },

          signature = {
            enabled = true,
            auto_open = {
              enabled = true,
              trigger = true,
              luasnip = true,
              throttle = 50,
            },
          },
        },

        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = true,
        },

        messages = {
          enabled = true,
          view = "notify",
          view_error = "notify",
          view_warn = "notify",
          view_history = "messages",
          view_search = "virtualtext",
        },

        notify = {
          enabled = true,
          view = "notify",
        },

        cmdline = {
          enabled = true,
          view = "cmdline_popup",

          format = {
            cmdline = {
              pattern = "^:",
              icon = cmd.command,
              lang = "vim",
            },
            search_down = {
              kind = "search",
              pattern = "^/",
              icon = ui.search,
              lang = "regex",
            },
            search_up = {
              kind = "search",
              pattern = "^%?",
              icon = ui.search,
              lang = "regex",
            },
            filter = {
              pattern = "^:%s*!",
              icon = cmd.filter,
              lang = "bash",
            },
            lua = {
              pattern = "^:%s*lua%s+",
              icon = cmd.lua,
              lang = "lua",
            },
            help = {
              pattern = "^:%s*he?l?p?%s+",
              icon = cmd.help,
            },
          },
        },

        popupmenu = {
          enabled = true,
          backend = "nui",
        },

        views = {
          cmdline_popup = {
            position = {
              row = 5,
              col = "50%",
            },
            size = {
              width = 60,
              height = "auto",
            },
          },

          popupmenu = {
            relative = "editor",
            position = {
              row = 8,
              col = "50%",
            },
            size = {
              width = 60,
              height = 10,
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
            win_options = {
              winhighlight = {
                Normal = "Normal",
                FloatBorder = "DiagnosticInfo",
              },
            },
          },
        },

        routes = {
          -- Hide common write messages like: "file.lua" 42L, 1337B written
          {
            filter = {
              event = "msg_show",
              kind = "",
              find = "written",
            },
            opts = { skip = true },
          },

          -- Hide search count spam.
          {
            filter = {
              event = "msg_show",
              kind = "search_count",
            },
            opts = { skip = true },
          },

          -- Route very long messages into a split instead of notifications.
          {
            filter = {
              event = "msg_show",
              min_height = 10,
            },
            view = "split",
          },
        },
      }
    end,
  },
}
