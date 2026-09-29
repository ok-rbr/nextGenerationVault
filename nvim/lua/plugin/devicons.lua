-- nvim-web-devicons plugin configuration.

return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    config = function()
      require("config.devicons").setup()
    end,
  },
}
