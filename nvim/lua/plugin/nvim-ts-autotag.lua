-- nvim-ts-autotag: auto-close and auto-rename HTML/XML-like tags.
--
-- Requires Treesitter parsers for the target filetypes.

return {
  "windwp/nvim-ts-autotag",

  ft = {
    "astro",
    "html",
    "javascript",
    "javascriptreact",
    "markdown",
    "php",
    "rescript",
    "svelte",
    "typescript",
    "typescriptreact",
    "tsx",
    "vue",
    "xml",
  },

  opts = {
    opts = {
      enable_close = true,
      enable_rename = true,
      enable_close_on_slash = false,
    },

    per_filetype = {
      -- Add overrides only if a filetype behaves badly.
      -- Example:
      -- html = {
      --   enable_close = false,
      -- },
    },
  },
}
