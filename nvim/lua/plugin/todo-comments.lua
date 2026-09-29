-- todo-comments: highlight and navigate TODO/FIX/WARN/NOTE comments.

return {
  {
    "folke/todo-comments.nvim",

    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    event = {
      "BufReadPost",
      "BufNewFile",
    },

    cmd = {
      "TodoTelescope",
      "TodoLocList",
      "TodoQuickFix",
    },

    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next todo comment",
      },

      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Previous todo comment",
      },

      {
        "]T",
        function()
          require("todo-comments").jump_next({
            keywords = {
              "ERROR",
              "WARNING",
            },
          })
        end,
        desc = "Next error/warning todo comment",
      },

      {
        "<leader>st",
        "<cmd>TodoTelescope<cr>",
        desc = "[S]earch [T]odos",
      },
    },

    opts = function()
      local icons = require("config.icons").icons.todo
      local todo = require("theme.palette").ui.todo

      return {
        signs = true,
        sign_priority = 8,

        keywords = {
          FIX = {
            icon = icons.fix,
            color = "error",
            alt = {
              "FIXME",
              "BUG",
              "FIXIT",
              "ISSUE",
            },
          },

          TODO = {
            icon = icons.todo,
            color = "info",
          },

          HACK = {
            icon = icons.hack,
            color = "warning",
          },

          WARN = {
            icon = icons.warn,
            color = "warning",
            alt = {
              "WARNING",
              "XXX",
            },
          },

          PERF = {
            icon = icons.perf,
            alt = {
              "OPTIM",
              "PERFORMANCE",
              "OPTIMIZE",
            },
          },

          NOTE = {
            icon = icons.note,
            color = "hint",
            alt = {
              "INFO",
            },
          },

          TEST = {
            icon = icons.test,
            color = "test",
            alt = {
              "TESTING",
              "PASSED",
              "FAILED",
            },
          },
        },

        gui_style = {
          fg = "NONE",
          bg = "bold",
        },

        merge_keywords = true,

        highlight = {
          multiline = true,
          multiline_pattern = "^.",
          multiline_context = 10,

          before = "",
          keyword = "wide",
          after = "fg",

          pattern = [[.*<(KEYWORDS)\s*:]],
          comments_only = true,
          max_line_len = 400,
          exclude = {},
        },

        colors = {
          error = {
            "DiagnosticError",
            "ErrorMsg",
            todo.error,
          },

          warning = {
            "DiagnosticWarn",
            "WarningMsg",
            todo.warning,
          },

          info = {
            "DiagnosticInfo",
            todo.info,
          },

          hint = {
            "DiagnosticHint",
            todo.hint,
          },

          default = {
            "Identifier",
            todo.default,
          },

          test = {
            "Identifier",
            todo.test,
          },
        },

        search = {
          command = "rg",
          args = {
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
          },
          pattern = [[\b(KEYWORDS):]],
        },
      }
    end,
  },
}
