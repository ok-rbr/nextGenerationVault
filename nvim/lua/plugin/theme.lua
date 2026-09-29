-- thme plugin configuration

return {
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    lazy = false,

    config = function()
      require("onedarkpro").setup({
        options = {
          transparency = false,
        },
      })

      vim.cmd.colorscheme("vaporwave")
    end,
  },
}
