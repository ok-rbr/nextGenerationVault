-- lua/plugin/image-clip.lua
-- Paste images from clipboard into markdown/wiki notes.

return {
  "HakonHarnes/img-clip.nvim",
  ft = { "markdown", "vimwiki" },
  keys = {
    {
      "<leader>wi",
      "<cmd>PasteImage<CR>",
      desc = "[W]iki [I]mage paste",
    },
  },
  opts = {
    default = {
      dir_path = "99_system/attachements/imgs",
      file_name = "%Y-%m-%d-%H-%M-%S",
      url_encode_path = false,
      use_absolute_path = false,
      relative_to_current_file = true,
    },
    filetypes = {
      markdown = {
        url_encode_path = false,
        template = "![$FILE_NAME]($FILE_PATH)",
      },
      vimwiki = {
        url_encode_path = false,
        template = "![$FILE_NAME]($FILE_PATH)",
      },
    },
  },
}
