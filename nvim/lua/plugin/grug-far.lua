-- grugFar: project-wide search and replace.

return {
  {
    "MagicDuck/grug-far.nvim",

    cmd = {
      "GrugFar",
    },

    keys = {
      {
        "<leader>rr",
        "<cmd>GrugFar<cr>",
        desc = "[R]eplace",
      },

      {
        "<leader>rw",
        function()
          require("grug-far").open({
            prefills = {
              search = vim.fn.expand("<cword>"),
            },
          })
        end,
        desc = "[R]eplace current [W]ord",
      },

      {
        "<leader>rf",
        function()
          require("grug-far").open({
            prefills = {
              paths = vim.fn.expand("%"),
            },
          })
        end,
        desc = "[R]eplace in current [F]ile",
      },

      {
        "<leader>rr",
        function()
          require("grug-far").open({
            visualSelectionUsage = "operate-within-range",
          })
        end,
        mode = "v",
        desc = "[R]eplace in selection",
      },
    },

    opts = {
      windowCreationCommand = "vsplit",

      folding = {
        enabled = true,
        save = true,
      },

      searchEngine = "rg",
      replaceEngine = "rg",

      icons = {
        enabled = true,
      },

      maxSearchResults = 2000,

      keymaps = {
        replace = { n = "<localleader>r" },
        qflist = { n = "<localleader>q" },
        sync_cursor = { n = "<localleader>s" },
        sync_line = { n = "<localleader>l" },
        close = { n = "<localleader>c" },
        historyOpen = { n = "<localleader>t" },
        historyAdd = { n = "<localleader>a" },
        refresh = { n = "<localleader>f" },
        openLocation = { n = "<localleader>o" },
        gotoLocation = { n = "<enter>" },
      },
    },
  },
}
