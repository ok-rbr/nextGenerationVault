-- Bufferline: buffer tabs with diagnostics and navigation keymaps.

return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "BufAdd",

    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },

      { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle buffer pin" },
      { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Delete non-pinned buffers" },

      { "<leader>dbr", "<cmd>BufferLineCloseRight<cr>", desc = "Delete buffers to the right" },
      { "<leader>dbl", "<cmd>BufferLineCloseLeft<cr>", desc = "Delete buffers to the left" },
      { "<leader>dbe", "<cmd>BufferLineCloseOthers<cr>", desc = "Delete other buffers" },
    },

    opts = function()
      local icons = require("config.icons").icons
      local ui = icons.ui
      local diagnostics = icons.diagnostics

      local function close_buffer(bufnr)
        local ok, err = pcall(vim.cmd, "bdelete " .. bufnr)
        if not ok then
          vim.notify("Could not delete buffer: " .. err, vim.log.levels.WARN)
        end
      end

      local function diagnostics_indicator(_, _, diag)
        local result = {}

        if (diag.error or 0) > 0 then
          table.insert(result, diagnostics.error)
        end

        if (diag.warn or 0) > 0 then
          table.insert(result, diagnostics.warn)
        end

        if (diag.info or 0) > 0 then
          table.insert(result, diagnostics.info)
        end

        if (diag.hint or 0) > 0 then
          table.insert(result, diagnostics.hint)
        end

        return #result > 0 and " " .. table.concat(result, " ") or ""
      end

      return {
        options = {
          mode = "buffers",
          style_preset = require("bufferline").style_preset.default,
          themable = true,

          -- Buffer actions.
          close_command = close_buffer,
          right_mouse_command = close_buffer,
          left_mouse_command = "buffer %d",
          middle_mouse_command = nil,

          -- Icons / indicators.
          indicator = {
            icon = ui.separator,
            style = "icon",
          },
          buffer_close_icon = ui.close,
          close_icon = ui.close,
          modified_icon = ui.bullet,

          -- Diagnostics.
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          diagnostics_indicator = diagnostics_indicator,

          -- Layout.
          numbers = "none",
          separator_style = "slant",
          enforce_regular_tabs = false,
          always_show_bufferline = true,

          left_trunc_marker = " ",
          right_trunc_marker = " ",

          -- Display.
          color_icons = true,
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = true,
          show_duplicate_prefix = true,

          -- Sorting.
          persist_buffer_sort = true,
          sort_by = "insert_after_current",

          -- Hover close icon.
          hover = {
            enabled = true,
            delay = 200,
            reveal = { "close" },
          },
        },
      }
    end,

    config = function(_, opts)
      require("bufferline").setup(opts)
    end,
  },
}
