-- live browser preview for Markdown files

return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown", "vimwiki" },
  build = function()
    vim.fn["mkdp#util#install"]()
  end,
  keys = {
    {
      "<leader>wp",
      "<cmd>MarkdownPreviewToggle<cr>",
      desc = "[W]iki [P]review",
      ft = { "markdown", "vimwiki" },
    },
  },
}
