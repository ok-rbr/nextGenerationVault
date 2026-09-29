-- [[ Setting options ]]
-- See `:help vim.opt`

-- Enable JetBrains Nerd Font support for icons
vim.g.have_nerd_font = true

-- Enable 24-bit RGB colors in the terminal
vim.opt.termguicolors = true

-- Line numbers config
vim.opt.number = true
vim.opt.relativenumber = true

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Disable the native ruler (line:col indicator in the command-line area).
-- lualine already shows position via its `location` component.
-- Without this, noice.nvim's message-area interception changes the HL attribute
-- that redraw_ruler expects (HLF_MSG), causing an assertion crash (SIGABRT).
vim.opt.ruler = false

-- Configure 2 spaces as tab
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.bo.softtabstop = 2

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.opt.breakindent = true

-- enables automatic indentation based on the previous line
vim.opt.autoindent = true

-- enables smart indentation for programming languages (e.g. C)
vim.opt.smartindent = true

-- Save undo history
vim.opt.undofile = true

-- Note: Fold configuration is handled by nvim-ufo plugin (see plugin/nvim-ufo.lua)

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Hide the number of lines in a buffer when it is not visible
vim.opt.conceallevel = 2

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 15
