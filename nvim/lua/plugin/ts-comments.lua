-- ts-comments: Treesitter-aware comment strings for Neovim's native comments.
--
-- Enhances `gc` / `gcc` by choosing the correct commentstring based on
-- the Treesitter node under the cursor.

return {
  {
    "folke/ts-comments.nvim",

    event = "VeryLazy",

    enabled = function()
      return vim.fn.has("nvim-0.10.0") == 1
    end,

    opts = {},
  },
}
