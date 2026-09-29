-- colorizer: highlights color values in CSS-like and config files.

return {
  {
    "NvChad/nvim-colorizer.lua",

    ft = {
      "css",
      "scss",
      "sass",
      "html",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "lua",
    },

    cmd = {
      "ColorizerToggle",
      "ColorizerAttachToBuffer",
      "ColorizerDetachFromBuffer",
      "ColorizerReloadAllBuffers",
    },

    keys = {
      {
        "<leader>tc",
        "<cmd>ColorizerToggle<cr>",
        desc = "[T]oggle [C]olorizer",
      },
    },

    opts = {
      filetypes = {
        css = {
          css = true,
          css_fn = true,
          names = true,
        },

        scss = {
          css = true,
          css_fn = true,
          names = true,
        },

        sass = {
          css = true,
          css_fn = true,
          names = true,
        },

        html = {
          css = true,
          css_fn = true,
          names = false,
        },

        javascript = {
          names = false,
        },

        javascriptreact = {
          names = false,
        },

        typescript = {
          names = false,
        },

        typescriptreact = {
          names = false,
        },

        lua = {
          names = false,
        },
      },

      user_default_options = {
        RGB = true,
        RRGGBB = true,
        RRGGBBAA = true,
        AARRGGBB = false,

        names = false,

        rgb_fn = false,
        hsl_fn = false,
        css = false,
        css_fn = false,

        mode = "background",

        tailwind = false,

        sass = {
          enable = false,
          parsers = { "css" },
        },

        virtualtext = "■",
        always_update = false,
      },

      buftypes = {},
    },
  },
}
