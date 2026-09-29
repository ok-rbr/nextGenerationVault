-- init.lua

-- Set leader
vim.g.mapleader = " "
vim.g.maplocalleader = "/"

require("config.lazy") -- Load lazy.nvim plugin manager

-- Load essential configurations immediately
require("config.opts") -- Basic vim options (critical for startup)

-- Native treesitter parser management (Neovim 0.12+)
require("config.treesitter").setup()

-- Load filetype config
require("config.filetypes")

-- Load basic autocommands
require("config.autocmds")

-- Load keymap config
require("config.keymaps")
