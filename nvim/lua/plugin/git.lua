-- git integration

return {

  ---------------------------------------------------------------------------
  -- Fugitive (low-level git power)
  ---------------------------------------------------------------------------
  {
    "tpope/vim-fugitive",
    cmd = {
      "Git",
      "G",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GDelete",
      "GBrowse",
      "Gdiffsplit",
      "Gvdiffsplit",
    },
    keys = {
      { "<leader>gs", "<cmd>Git<CR>", desc = "Git status" },
      { "<leader>gd", "<cmd>Gdiffsplit<CR>", desc = "Git diff split" },
    },
  },

  ---------------------------------------------------------------------------
  -- Diffview (PR-style diff UI)
  ---------------------------------------------------------------------------
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
    },
    keys = {
      { "<leader>gD", "<cmd>DiffviewOpen<CR>", desc = "Diffview open" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<CR>", desc = "File history" },
      { "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "Diffview close" },
    },
    opts = {},
  },

  ---------------------------------------------------------------------------
  -- Gitsigns (inline changes + hunks)
  ---------------------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = function()
      local icons = require("config.icons").icons.git

      return {
        signs = {
          add = { text = icons.add },
          change = { text = icons.change },
          delete = { text = icons.delete },
          topdelete = { text = icons.topdelete },
          changedelete = { text = icons.changedelete },
        },

        signcolumn = true,

        current_line_blame = true,
        current_line_blame_opts = {
          delay = 300,
          virt_text_pos = "eol",
        },

        on_attach = function(buf)
          local gs = require("gitsigns")

          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
          end

          -- Hunk actions
          map({ "n", "v" }, "<leader>hs", gs.stage_hunk, "Stage hunk")
          map({ "n", "v" }, "<leader>hr", gs.reset_hunk, "Reset hunk")

          map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
          map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")

          -- Diff
          map("n", "<leader>hd", gs.diffthis, "Diff buffer")
          map("n", "<leader>hD", function()
            gs.diffthis("~")
          end, "Diff against HEAD")

          -- Blame / Toggle
          map("n", "<leader>hb", function()
            gs.blame_line({ full = true })
          end, "Blame line")

          map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle blame")
          map("n", "<leader>td", gs.toggle_deleted, "Toggle deleted")

          -- Navigation
          map("n", "]h", gs.next_hunk, "Next hunk")
          map("n", "[h", gs.prev_hunk, "Prev hunk")

          -- Buffer
          map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
        end,
      }
    end,
  },

  ---------------------------------------------------------------------------
  -- LazyGit (main workflow UI)
  ---------------------------------------------------------------------------
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit" },
      { "<leader>gf", "<cmd>LazyGitCurrentFile<CR>", desc = "LazyGit file" },
      { "<leader>gl", "<cmd>LazyGitFilter<CR>", desc = "LazyGit log" },
    },
    config = function()
      vim.g.lazygit_floating_window_scaling_factor = 0.9
      vim.g.lazygit_floating_window_winblend = 0
      vim.g.lazygit_floating_window_border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
      vim.g.lazygit_use_neovim_remote = 0
    end,
  },

  ---------------------------------------------------------------------------
  -- Git Conflict (merge resolution)
  ---------------------------------------------------------------------------
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "BufReadPost",
    config = function()
      require("git-conflict").setup({
        default_commands = true,
        default_mappings = {
          ours = "co",
          theirs = "ct",
          both = "cb",
          none = "cn",
          next = "xn",
          prev = "xp",
        },
        disable_diagnostics = false,
        list_opener = "copen",
      })

      local map = vim.keymap.set
      map("n", "<leader>co", "<cmd>GitConflictChooseOurs<CR>", { desc = "Choose main (current)" })
      map("n", "<leader>ct", "<cmd>GitConflictChooseTheirs<CR>", { desc = "Choose incoming" })
      map("n", "<leader>cb", "<cmd>GitConflictChooseBoth<CR>", { desc = "Choose both (main + incoming)" })
      map("n", "<leader>cn", "<cmd>GitConflictChooseNone<CR>", { desc = "Choose none (manual)" })
      map("n", "<leader>xn", "<cmd>GitConflictNextConflict<CR>", { desc = "Next conflict" })
      map("n", "<leader>xp", "<cmd>GitConflictPrevConflict<CR>", { desc = "Prev conflict" })
    end,
  },
}
