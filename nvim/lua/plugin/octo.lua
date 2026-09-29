-- octo.nvim — GitHub PR and issue management inside Neovim
-- Requires: gh CLI authenticated (`gh auth login`)
-- Telescope integration: :Telescope octo  or  <leader>goS

return {
  {
    "pwntester/octo.nvim",
    cmd = { "Octo" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      -- PR operations
      { "<leader>gop", "<cmd>Octo pr list<cr>", desc = "GitHub: List PRs" },
      { "<leader>gor", "<cmd>Octo review start<cr>", desc = "GitHub: Start PR review" },
      { "<leader>gom", "<cmd>Octo pr merge<cr>", desc = "GitHub: Merge PR" },
      { "<leader>goc", "<cmd>Octo pr create<cr>", desc = "GitHub: Create PR" },
      -- Issue operations
      { "<leader>goi", "<cmd>Octo issue list<cr>", desc = "GitHub: List issues" },
      { "<leader>goI", "<cmd>Octo issue create<cr>", desc = "GitHub: Create issue" },
      -- Search (telescope)
      { "<leader>goS", "<cmd>Octo search<cr>", desc = "GitHub: Search (Telescope)" },
      -- Current buffer actions
      { "<leader>goa", "<cmd>Octo actions<cr>", desc = "GitHub: Actions (context menu)" },
    },
    config = function()
      require("octo").setup({
        -- Use gh CLI for authentication — no hardcoded tokens
        github_hostname = "", -- empty = github.com; set for GHES
        use_local_fs = true, -- check out PRs as local branches
        enable_builtin = true, -- <C-o> keybindings in octo buffers

        -- Open PR/issue URLs in the default browser
        browser = vim.fn.has("linux") == 1 and "xdg-open" or "open",

        picker = "telescope", -- use telescope for search/list pickers

        -- Appearance
        ui = {
          use_signcolumn = true,
        },

        -- File panel (PR changed files)
        file_panel = {
          size = 10,
          use_icons = true,
        },

        -- Reaction icons
        reaction_viewer_hint_icon = " ",
        user_icon = " ",
        timeline_marker = " ",
        timeline_indent = "2",

        -- Mappings inside octo buffers
        -- (these are in addition to the global keymaps defined above)
        mappings = {
          issue = {
            close_issue = { lhs = "<leader>ic", desc = "Close issue" },
            reopen_issue = { lhs = "<leader>io", desc = "Reopen issue" },
            add_assignee = { lhs = "<leader>iaa", desc = "Add assignee" },
            remove_assignee = { lhs = "<leader>iad", desc = "Remove assignee" },
            add_label = { lhs = "<leader>ila", desc = "Add label" },
            remove_label = { lhs = "<leader>ild", desc = "Remove label" },
            add_comment = { lhs = "<leader>ica", desc = "Add comment" },
            delete_comment = { lhs = "<leader>icd", desc = "Delete comment" },
          },
          pull_request = {
            checkout_pr = { lhs = "<leader>po", desc = "Checkout PR branch" },
            merge_pr = { lhs = "<leader>pm", desc = "Merge PR" },
            squash_and_merge = { lhs = "<leader>psm", desc = "Squash and merge PR" },
            list_commits = { lhs = "<leader>pc", desc = "List PR commits" },
            list_changed_files = { lhs = "<leader>pf", desc = "List PR changed files" },
            show_pr_diff = { lhs = "<leader>pd", desc = "Show PR diff" },
            add_reviewer = { lhs = "<leader>pra", desc = "Add reviewer" },
            remove_reviewer = { lhs = "<leader>prd", desc = "Remove reviewer" },
            close_pr = { lhs = "<leader>pxc", desc = "Close PR" },
            reopen_pr = { lhs = "<leader>pxo", desc = "Reopen PR" },
            add_comment = { lhs = "<leader>pca", desc = "Add comment" },
            delete_comment = { lhs = "<leader>pcd", desc = "Delete comment" },
          },
          review_thread = {
            add_comment = { lhs = "<space>ca", desc = "Add comment" },
            add_suggestion = { lhs = "<space>sa", desc = "Add suggestion" },
          },
        },
      })

      -- Register telescope extension
      pcall(require("telescope").load_extension, "octo")
    end,
  },
}
