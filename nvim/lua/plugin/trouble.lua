-- diagnostics and LSP issues viewer

return {
  -- NOTE: i'm not sure if i realy use this plugin enough to keep it, rethink it maybe later
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "Trouble", "TroubleToggle" },
    keys = {
      {
        "<leader>xx",
        function()
          require("trouble").toggle()
        end,
        desc = "Toggle Trouble",
      },
      {
        "<leader>xw",
        function()
          require("trouble").toggle("workspace_diagnostics")
        end,
        desc = "Workspace Diagnostics (Trouble)",
      },
      {
        "<leader>xd",
        function()
          require("trouble").toggle("document_diagnostics")
        end,
        desc = "Document Diagnostics (Trouble)",
      },
      {
        "<leader>xq",
        function()
          require("trouble").toggle("quickfix")
        end,
        desc = "Quickfix List (Trouble)",
      },
      {
        "<leader>xl",
        function()
          require("trouble").toggle("loclist")
        end,
        desc = "Location List (Trouble)",
      },
      {
        "gR",
        function()
          require("trouble").toggle("lsp_references")
        end,
        desc = "LSP References (Trouble)",
      },
    },
    opts = {
      -- Position of the trouble list
      position = "bottom",
      -- Height of the trouble list when position is top or bottom
      height = 10,
      -- Width when position is left or right
      width = 50,
      -- Use icons
      icons = true,
      -- Mode can be "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
      mode = "workspace_diagnostics",
      -- Fold closed by default
      fold_open = "▾",
      fold_closed = "▸",
      -- Group results by file
      group = true,
      -- Padding from the left
      padding = true,
      -- Auto open trouble list
      auto_open = false,
      -- Auto close trouble list
      auto_close = false,
      -- Auto preview the location of the diagnostic
      auto_preview = true,
      -- Auto fold a file trouble list at creation
      auto_fold = false,
      -- Auto jump to the item under the cursor
      auto_jump = { "lsp_definitions" },
      -- Signs
      signs = {
        error = "✘",
        warning = "▲",
        hint = "⚑",
        information = "",
        other = "﫠",
      },
      -- Use diagnostic signs from elsewhere
      use_diagnostic_signs = false,
    },
    config = function(_, opts)
      require("trouble").setup(opts)
    end,
  },
}
