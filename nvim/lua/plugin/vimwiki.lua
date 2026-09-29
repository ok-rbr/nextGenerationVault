-- markdown-based personal wiki with diary
--
-- STATUS: disabled in lua/config/plugins.lua
--
-- NOTE: The active note-taking system in this config is the custom
-- lua/notes/ module (see plugin/notes.lua). This vimwiki integration
-- reuses notes.utils/notes.env/notes.init for centralized notebook-root
-- and daily-folder detection (see init() below) so both systems agree on
-- where the vault lives if vimwiki is ever re-enabled. Both vimwiki and
-- obsidian.nvim cover overlapping note-taking use-cases; they are kept as
-- independent options so either can be enabled without affecting the
-- other, but lua/notes/ is the one actually wired up by default.

return {
  "vimwiki/vimwiki",
  event = "BufEnter *.md",
  keys = {
    { "<leader>ww", "<cmd>VimwikiIndex<cr>", desc = "[W]iki Index" },
    { "<leader>wt", "<cmd>VimwikiTabIndex<cr>", desc = "[W]iki Tab Index" },
    { "<leader>ws", "<cmd>VimwikiUISelect<cr>", desc = "[W]iki Select" },
    { "<leader>wi", "<cmd>VimwikiDiaryIndex<cr>", desc = "[W]iki Daily Index" },
    { "<leader>w<leader>w", "<cmd>VimwikiMakeDiaryNote<cr>", desc = "[W]iki Today's Daily" },
    { "<leader>w<leader>t", "<cmd>VimwikiTabMakeDiaryNote<cr>", desc = "[W]iki Today's Daily (Tab)" },
    { "<leader>w<leader>y", "<cmd>VimwikiMakeYesterdayDiaryNote<cr>", desc = "[W]iki Yesterday's Daily" },
    { "<leader>w<leader>m", "<cmd>VimwikiMakeTomorrowDiaryNote<cr>", desc = "[W]iki Tomorrow's Daily" },
  },
  init = function()
    -- Use centralized notebook root detection from notes.utils
    local ok, notes_utils = pcall(require, "notes.utils")
    local para_path

    if ok then
      -- Use centralized configuration
      para_path = notes_utils.get_notebook_root()
      -- Only create directory if explicitly configured via NOTES_ROOT in .env
      local env_ok, env_mod = pcall(require, "notes.env")
      local is_configured = env_ok and env_mod.get_notes_root() ~= nil
      if is_configured and vim.fn.isdirectory(para_path) == 0 then
        vim.fn.mkdir(para_path, "p")
      end
    else
      -- Fallback if notes module not available
      local home = vim.fn.expand("~")
      local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
      para_path = is_windows and (home .. "\\PARA") or (home .. "/PARA")
      vim.fn.mkdir(para_path, "p")
    end

    -- Get daily directory from centralized config
    local daily_rel = "02_areas/01_periodicNotes/daily/"
    if ok then
      local notes_config = require("notes.init").config
      daily_rel = notes_config.directories.daily .. "/"
    end

    -- Vimwiki configuration
    vim.g.vimwiki_list = {
      {
        path = para_path,
        syntax = "markdown",
        ext = ".md",
        -- Use markdown links instead of wiki-style
        links_space_char = "-",
        -- Daily path from centralized config
        diary_rel_path = daily_rel,
        diary_index = "daily",
        diary_header = "Daily",
        diary_sort = "desc",
      },
    }

    -- Global vimwiki settings
    vim.g.vimwiki_global_ext = 0 -- Don't treat all .md files as vimwiki
    vim.g.vimwiki_markdown_link_ext = 1 -- Use .md extension in links
    vim.g.vimwiki_listsyms = " ○◐●✓" -- Todo list symbols
    vim.g.vimwiki_listsym_rejected = "✗" -- Rejected todo symbol

    -- Use default markdown syntax highlighting
    vim.g.vimwiki_ext2syntax = {
      [".md"] = "markdown",
      [".markdown"] = "markdown",
      [".mdown"] = "markdown",
    }

    -- Folding configuration
    vim.g.vimwiki_folding = "expr"

    -- Don't conceal markdown syntax by default (can be toggled with <leader>uc)
    vim.g.vimwiki_conceallevel = 2

    -- Custom mappings for vimwiki
    vim.g.vimwiki_key_mappings = {
      all_maps = 1,
      global = 1,
      headers = 1,
      text_objs = 1,
      table_format = 1,
      table_mappings = 1,
      lists = 1,
      links = 1,
      html = 0, -- Disable HTML mappings
      mouse = 0, -- Disable mouse mappings
    }
  end,
  config = function()
    -- Additional vimwiki-specific autocommands and settings
    local augroup = vim.api.nvim_create_augroup("voidcore-vimwiki", { clear = true })

    -- Auto-update daily index when opening it
    vim.api.nvim_create_autocmd("BufRead", {
      group = augroup,
      pattern = "*/daily/daily.md",
      callback = function()
        vim.cmd("VimwikiDiaryGenerateLinks")
      end,
    })

    -- Enable table mode for vimwiki files
    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      pattern = "vimwiki",
      callback = function()
        -- Additional vimwiki-specific settings can go here
        -- For example, enable soft wrap for long lines
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
      end,
    })

    -- Custom commands for vimwiki workflow

    -- Command: WikiGrep - search within wiki
    vim.api.nvim_create_user_command("WikiGrep", function(opts)
      local para_path = vim.g.vimwiki_list[1].path
      require("telescope.builtin").live_grep({
        prompt_title = "Search Wiki",
        cwd = para_path,
      })
    end, { nargs = "*", desc = "Search within wiki using telescope" })

    -- Command: WikiFiles - find files in wiki
    vim.api.nvim_create_user_command("WikiFiles", function()
      local para_path = vim.g.vimwiki_list[1].path
      require("telescope.builtin").find_files({
        prompt_title = "Wiki Files",
        cwd = para_path,
      })
    end, { desc = "Find files in wiki using telescope" })

    -- Command: WikiRecent - recently modified files
    vim.api.nvim_create_user_command("WikiRecent", function()
      local para_path = vim.g.vimwiki_list[1].path
      require("telescope.builtin").oldfiles({
        prompt_title = "Recent Wiki Files",
        cwd = para_path,
        cwd_only = true,
      })
    end, { desc = "Recently modified wiki files" })

    -- Additional keymaps in vimwiki buffers
    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      pattern = "vimwiki",
      callback = function()
        local opts = { buffer = true, silent = true }

        -- Better navigation
        vim.keymap.set(
          "n",
          "<leader>wn",
          "<cmd>WikiFiles<cr>",
          vim.tbl_extend("force", opts, { desc = "[W]iki [N]avigate files" })
        )
        vim.keymap.set(
          "n",
          "<leader>wg",
          "<cmd>WikiGrep<cr>",
          vim.tbl_extend("force", opts, { desc = "[W]iki [G]rep" })
        )
        vim.keymap.set(
          "n",
          "<leader>wr",
          "<cmd>WikiRecent<cr>",
          vim.tbl_extend("force", opts, { desc = "[W]iki [R]ecent" })
        )

        -- Quick todo toggle
        vim.keymap.set(
          "n",
          "<leader>wc",
          "<Plug>VimwikiToggleListItem",
          vim.tbl_extend("force", opts, { desc = "[W]iki Toggle [C]heckbox" })
        )

        -- Table formatting (vimwiki has built-in)
        vim.keymap.set(
          "n",
          "<leader>wtf",
          "<Plug>VimwikiTableAlignQ",
          vim.tbl_extend("force", opts, { desc = "[W]iki [T]able [F]ormat" })
        )
      end,
    })
  end,
}
