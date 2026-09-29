-- Kulala: HTTP / REST client for .http and .rest files.
--
-- Use this for project-local API requests inside Neovim.
-- For quick ad-hoc terminal requests, use httpie/curl separately.

return {
  "mistweaverco/kulala.nvim",

  ft = {
    "http",
    "rest",
  },

  cmd = {
    "KulalaRun",
    "KulalaToggle",
    "KulalaInspect",
    "KulalaClose",
    "KulalaReplay",
    "KulalaShow",
  },

  keys = {
    {
      "<leader>kr",
      "<cmd>KulalaRun<cr>",
      desc = "[K]ulala [R]un request",
    },

    {
      "<leader>kt",
      "<cmd>KulalaToggle<cr>",
      desc = "[K]ulala [T]oggle view",
    },

    {
      "<leader>ki",
      "<cmd>KulalaInspect<cr>",
      desc = "[K]ulala [I]nspect request",
    },

    {
      "<leader>kc",
      "<cmd>KulalaClose<cr>",
      desc = "[K]ulala [C]lose",
    },

    {
      "<leader>kp",
      "<cmd>KulalaReplay<cr>",
      desc = "[K]ulala Re[P]lay last request",
    },

    {
      "<leader>ks",
      "<cmd>KulalaShow<cr>",
      desc = "[K]ulala [S]how",
    },
  },

  opts = function()
    local icons = require("config.icons").icons
    local http = icons.http
    local ui = icons.ui

    return {
      global_keymaps = false,
      timeout = 30000,

      show_icons = true,

      icons = {
        inlay = {
          loading = http.loading or ui.loading,
          done = http.done or ui.success,
          error = http.error or ui.error,
        },
        lualine = http.request,
      },

      winbar = {
        enable = true,
      },

      environment_scope = "b",

      default_headers = {
        ["User-Agent"] = "Kulala/1.0.0",
      },

      additional_curl_options = {},

      formatters = {
        json = { "jq", "." },
        xml = { "xmllint", "--format", "-" },
        html = { "tidy", "-i", "-q", "--show-errors", "0" },
      },

      debug = false,
    }
  end,
}
