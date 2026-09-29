-- telescope: fuzzy finding for files, buffers, grep, diagnostics, and navigation.

return {
  {
    "nvim-telescope/telescope.nvim",

    event = "VimEnter",

    dependencies = {
      "nvim-lua/plenary.nvim",

      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },

      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "jvgrootveld/telescope-zoxide",

      {
        "nvim-tree/nvim-web-devicons",
        enabled = vim.g.have_nerd_font,
      },
    },

    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")
      local themes = require("telescope.themes")

      telescope.setup({
        extensions = {
          ["ui-select"] = themes.get_dropdown(),

          file_browser = {
            theme = "ivy",
            hijack_netrw = true,
            hidden = true,
          },
        },
      })

      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")
      pcall(telescope.load_extension, "file_browser")
      pcall(telescope.load_extension, "zoxide")

      -- Buffers / keymaps.
      vim.keymap.set("n", "<leader><leader>", builtin.buffers, {
        desc = "Find buffers",
      })

      vim.keymap.set("n", "<leader>sk", builtin.keymaps, {
        desc = "[S]earch [K]eymaps",
      })

      -- Files.
      vim.keymap.set("n", "<leader>sf", function()
        builtin.find_files({
          hidden = true,
          no_ignore = false,
          file_ignore_patterns = {
            "%.git/",
            "node_modules/",
            "%.pnpm/",
            "%.venv/",
          },
        })
      end, {
        desc = "[S]earch [F]iles",
      })

      vim.keymap.set("n", "<leader>sF", function()
        builtin.find_files({
          hidden = true,
          no_ignore = true,
          find_command = {
            "fd",
            "--type",
            "f",
            "--hidden",
            "--no-ignore",
            "--exclude",
            ".git",
            "--exclude",
            "node_modules",
            "--exclude",
            ".pnpm",
            "--exclude",
            ".venv",
          },
        })
      end, {
        desc = "[S]earch all [F]iles",
      })

      -- Grep / search.
      vim.keymap.set("n", "<leader>sw", builtin.grep_string, {
        desc = "[S]earch current [W]ord",
      })

      vim.keymap.set("n", "<leader>sg", builtin.live_grep, {
        desc = "[S]earch by [G]rep",
      })

      vim.keymap.set("n", "<leader>s/", function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        })
      end, {
        desc = "[S]earch in open files",
      })

      vim.keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find(themes.get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, {
        desc = "Search in current buffer",
      })

      -- Recent / diagnostics / help.
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles, {
        desc = "[S]earch recent files",
      })

      vim.keymap.set("n", "<leader>sd", builtin.diagnostics, {
        desc = "[S]earch [D]iagnostics",
      })

      vim.keymap.set("n", "<leader>wd", function()
        builtin.diagnostics({ bufnr = 0 })
      end, {
        desc = "[W]orkspace current buffer [D]iagnostics",
      })

      vim.keymap.set("n", "<leader>sr", builtin.resume, {
        desc = "[S]earch [R]esume",
      })

      vim.keymap.set("n", "<leader>ss", builtin.builtin, {
        desc = "[S]earch [S]elect Telescope",
      })

      vim.keymap.set("n", "<leader>sh", builtin.help_tags, {
        desc = "[S]earch [H]elp",
      })

      -- Neovim config.
      vim.keymap.set("n", "<leader>sn", function()
        builtin.find_files({
          cwd = vim.fn.stdpath("config"),
        })
      end, {
        desc = "[S]earch [N]eovim config",
      })

      -- File browser.
      vim.keymap.set("n", "<leader>fb", function()
        telescope.extensions.file_browser.file_browser()
      end, {
        desc = "[F]ile [B]rowser",
      })

      vim.keymap.set("n", "<leader>f.", function()
        telescope.extensions.file_browser.file_browser({
          path = vim.fn.expand("%:p:h"),
        })
      end, {
        desc = "[F]ile browser current directory",
      })

      vim.keymap.set("n", "<leader>fc", function()
        telescope.extensions.file_browser.file_browser({
          path = vim.fn.getcwd(),
        })
      end, {
        desc = "[F]ile browser cwd",
      })

      -- Zoxide.
      vim.keymap.set("n", "<leader>fz", function()
        telescope.extensions.zoxide.list()
      end, {
        desc = "[F]ind via [Z]oxide",
      })
    end,
  },
}
