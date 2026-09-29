-- notes: wires up the custom PARA/notes system (lua/notes/*)
--
-- This is not an external plugin — it's a virtual lazy.nvim spec (via `dir`)
-- whose only job is to call require("notes.init").setup() once Neovim has
-- finished starting up. Without this, all :Note* commands, <leader>n*
-- keymaps and the frontmatter auto-update autocmd defined under lua/notes/
-- are dead code (never registered).
--
-- Layer 1 of the note-taking architecture (docs/ADR-005). lua/notes/ owns
-- note creation, templates, frontmatter, PARA routing, metadata, queries and
-- native wiki-link operations; Marksman owns Markdown diagnostics and completion;
-- render-markdown.nvim owns presentation.
--
-- Uses event = "VeryLazy" so it loads after startup without blocking it.
-- Telescope-dependent code paths require Telescope lazily inside their own
-- functions, so load order relative to telescope.nvim does not matter here.

return {
  dir = vim.fn.stdpath("config"),
  name = "notes",
  event = "VeryLazy",
  config = function()
    require("notes.init").setup()
  end,
}
