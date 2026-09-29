#!/usr/bin/env bash
set -euo pipefail

nvim --headless "+lua require('config.lazy')" +qa
nvim --headless "+lua require('config.opts')" +qa
nvim --headless "+lua require('config.filetypes')" +qa
nvim --headless "+lua require('config.autocmds')" +qa
nvim --headless "+lua require('config.keymaps')" +qa
nvim --headless "+lua require('config.treesitter').setup()" +qa
nvim --headless "+checkhealth" +qa
