-- basic keymaps.
--
-- keep this file focused on keymap registration.
-- implementation details should live in dedicated modules.

local diagnostics = require("config.diagnostics")
local clipboard = require("config.clipboard")

-- clear search highlights.
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostics.
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>yd", diagnostics.yank_line, { desc = "[Y]ank line [D]iagnostics" })
vim.keymap.set("n", "<leader>yD", diagnostics.yank_buffer, { desc = "[Y]ank buffer [D]iagnostics (all)" })
vim.keymap.set("n", "<leader>yW", diagnostics.yank_workspace, { desc = "[Y]ank [W]orkspace diagnostics (all)" })
vim.keymap.set("n", "<leader>tv", diagnostics.toggle_virtual_text, { desc = "[T]oggle [V]irtual diagnostics text" })

-- Clipboard.
vim.keymap.set("n", "<leader>ya", clipboard.yank_buffer, { desc = "[Y]ank [A]ll file content to clipboard" })

-- terminal mode.
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- window navigation.
--
-- see `:help wincmd` for available window commands.
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
