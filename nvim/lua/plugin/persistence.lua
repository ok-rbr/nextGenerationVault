-- persistence: lightweight session management.

return {
  {
    "folke/persistence.nvim",

    event = "BufReadPre",

    opts = {
      dir = vim.fn.stdpath("state") .. "/sessions/",

      options = {
        "buffers",
        "curdir",
        "tabpages",
        "winsize",
        "folds",
      },

      pre_save = nil,
      save_empty = false,
    },

    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore session",
      },

      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore last session",
      },

      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "Do not save current session",
      },
    },
  },
}
