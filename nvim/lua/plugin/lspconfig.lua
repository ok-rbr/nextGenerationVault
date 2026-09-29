-- lsp entrypoint.
--
-- server-specific setup lives in lua/lsp/.
-- this plugin only loads nvim-lspconfig and delegates setup.

return {
  "neovim/nvim-lspconfig",

  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },

  event = { "BufReadPre", "BufNewFile" },

  config = function()
    require("lsp").setup()
  end,
}
