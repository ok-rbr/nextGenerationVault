-- autocommands.
--
-- keep this file focused on editor events.
-- reusable implementation details should live in dedicated modules.

-- =========================================================
-- highlight yank
-- =========================================================

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "highlight yanked text",
  group = vim.api.nvim_create_augroup("voidcore-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
