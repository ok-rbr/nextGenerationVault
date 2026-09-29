-- Lualine: minimal statusline with diagnostics, git, LSP, and file context.

return {
  {
    "nvim-lualine/lualine.nvim",

    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },

    event = "UIEnter",

    opts = function()
      local icons = require("config.icons").icons
      local diagnostics = icons.diagnostics
      local git = icons.git
      local palette = require("theme.palette")

      local lazy_ok, lazy_status = pcall(require, "lazy.status")

      local function lazy_updates()
        if not lazy_ok or not lazy_status.has_updates() then
          return ""
        end

        return lazy_status.updates()
      end

      local function macro_recording()
        local recording = vim.fn.reg_recording()
        if recording == "" then
          return ""
        end

        return "󰑋 REC @" .. recording
      end

      local function lsp_clients()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then
          return ""
        end

        local names = {}
        for _, client in ipairs(clients) do
          table.insert(names, client.name)
        end

        table.sort(names)

        return " " .. table.concat(names, ", ")
      end

      local function has_lsp_clients()
        return #vim.lsp.get_clients({ bufnr = 0 }) > 0
      end

      local function gitsigns_diff()
        local status = vim.b.gitsigns_status_dict
        if not status then
          return nil
        end

        return {
          added = status.added,
          modified = status.changed,
          removed = status.removed,
        }
      end

      return {
        options = {
          theme = "auto",
          globalstatus = true,

          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },

          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          },
        },

        sections = {
          lualine_a = {
            {
              "mode",
              padding = { left = 1, right = 1 },
            },
          },

          lualine_b = {
            {
              "branch",
              icon = git.branch or "",
              padding = { left = 1, right = 1 },
            },
          },

          lualine_c = {
            {
              "diagnostics",
              sources = { "nvim_diagnostic" },
              symbols = {
                error = diagnostics.error,
                warn = diagnostics.warn,
                info = diagnostics.info,
                hint = diagnostics.hint,
              },
              padding = { left = 1, right = 1 },
            },

            {
              "filename",
              path = 1,
              symbols = {
                modified = " 󰷈",
                readonly = " ",
                unnamed = "[No Name]",
                newfile = "[New]",
              },
              padding = { left = 1, right = 1 },
            },

            {
              macro_recording,
              color = { fg = palette.ui.attention, gui = "bold" },
              padding = { left = 1, right = 1 },
            },
          },

          lualine_x = {
            {
              lazy_updates,
              cond = function()
                return lazy_ok and lazy_status.has_updates()
              end,
              color = { fg = palette.ui.attention },
              padding = { left = 1, right = 1 },
            },

            {
              "diff",
              source = gitsigns_diff,
              symbols = {
                added = git.add,
                modified = git.change,
                removed = git.delete,
              },
              padding = { left = 1, right = 1 },
            },

            {
              lsp_clients,
              cond = has_lsp_clients,
              padding = { left = 1, right = 1 },
            },

            {
              "filetype",
              icon_only = false,
              padding = { left = 1, right = 1 },
            },
          },

          lualine_y = {
            {
              "progress",
              padding = { left = 1, right = 0 },
            },
            {
              "location",
              padding = { left = 0, right = 1 },
            },
          },

          lualine_z = {
            {
              function()
                return " " .. os.date("%H:%M")
              end,
              padding = { left = 1, right = 1 },
            },
          },
        },

        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            {
              "filename",
              path = 1,
              symbols = {
                modified = " 󰷈",
                readonly = " ",
                unnamed = "[No Name]",
                newfile = "[New]",
              },
            },
          },
          lualine_x = {
            {
              "location",
              padding = { left = 1, right = 1 },
            },
          },
          lualine_y = {},
          lualine_z = {},
        },

        extensions = {
          "lazy",
        },
      }
    end,

    config = function(_, opts)
      require("lualine").setup(opts)
    end,
  },
}
