-- notes/init.lua
-- Main entry point for notes system
--
-- CENTRALIZED CONFIGURATION
-- ========================
-- This module provides a single source of truth for all note-related paths and directories.
-- All other modules (notes.utils, notes.commands, plugin.telescope) use this
-- centralized configuration to determine root paths and directory structures.
--
-- CUSTOMIZATION
-- =============
-- To customize paths, modify the `M.config` table in this file or call `require("notes.init").setup()`
-- with custom options in your init.lua:
--
--   require("notes.init").setup({
--     notebook_root = "~/my-notes",  -- Set explicit root path
--     directories = {
--       projects = "projects",        -- Customize directory structure
--       areas = "areas",
--     },
--     root_search_paths = function()  -- Customize search locations
--       return { "~/my-notes", "~/Documents/notes" }
--     end,
--   })

local M = {}

-- Configuration
M.config = {
  -- Default notebook root (will be auto-detected if not set)
  -- First tries to load from .env file (NOTES_ROOT), then falls back to this value
  notebook_root = (function()
    local ok, env = pcall(require, "notes.env")
    if ok then
      local env_root = env.get_notes_root()
      if env_root then
        return env_root
      end
    end
    return nil
  end)(),

  -- Root path search locations (in priority order)
  -- Each entry can be:
  --   - A string path (e.g., "~/Documents/notes")
  --   - A function that returns a string path
  -- The first existing directory will be used
  root_search_paths = function()
    local home = vim.fn.expand("~")
    local cwd = vim.fn.getcwd()
    local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
    local sep = is_windows and "\\" or "/"

    return {
      cwd .. sep .. "PARA",
      home .. sep .. "PARA",
      home .. sep .. "Documents" .. sep .. "PARA",
    }
  end,

  -- Fallback root path (used if no search paths exist)
  root_fallback = function()
    local home = vim.fn.expand("~")
    local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
    return is_windows and (home .. "\\PARA") or (home .. "/PARA")
  end,

  -- Template used for the note behind a Taskwarrior task, given as the
  -- template's file name without the .md extension. It is looked up in the
  -- templates directory configured below.
  task_note_template = "task",

  -- Default project name pre-filled in NoteProjectCreate prompt (nil = always prompt)
  default_project_name = nil,

  -- Default client name pre-filled in NoteProjectCreate prompt (nil = always prompt)
  default_client_name = nil,

  -- Default language for frontmatter
  default_lang = "en",

  -- Slug separator (underscore or hyphen)
  slug_separator = "_",

  -- Date format for display
  date_format = "%Y-%m-%d",

  -- Timestamp format for display
  timestamp_format = "%Y-%m-%d %H:%M",

  -- ID format (Lua date format string)
  id_format = "%Y%m%d_%H%M",

  -- Default tags for different note types
  default_tags = {
    project = { "project" },
    area = { "area" },
    knowledge = { "knowledge" },
    task = { "task" },
    meeting = { "meeting" },
    person = { "person" },
    daily = { "daily" },
  },

  -- PARA directory structure
  directories = {
    projects = "01_projects",
    areas = "02_areas",
    knowledge = "00_knowledge/01_atomic",
    resources = "03_resources",
    archive = "04_archive",
    daily = "02_areas/life/logs/daily",
    weekly = "02_areas/life/logs/weekly",
    monthly = "02_areas/life/logs/monthly",
    -- Pasted images (:NotePasteImage). Must match "attachmentFolderPath" in
    -- dot_config/obsidian/app.json, the Obsidian app's copy of this setting.
    attachments = "99_system/attachments/imgs",
    -- Templates are read from here (never written to); shared by
    -- notes.templates (template discovery) and notes.commands (daily note
    -- template lookup) so the path only needs to change in one place.
    --
    -- This is the NEOVIM template directory and is deliberately not the same
    -- as Obsidian's 99_system/01_templates: those use Templater and contain
    -- JavaScript, which lua/notes/ cannot execute. lua/notes/ templates use
    -- plain {{ variable }} placeholders instead.
    --
    -- Override per machine with NOTES_TEMPLATES_DIR in .env.
    templates = (function()
      local ok, env = pcall(require, "notes.env")
      return (ok and env.get_templates_dir()) or "99_system/015_templates"
    end)(),
  },

  -- Query settings
  query = {
    -- Number of days for "recent" query
    recent_days = 7,

    -- Enable previewer in Telescope
    enable_previewer = true,
  },

  -- Template settings
  template = {
    -- Auto-create directories when creating notes
    auto_create_dirs = true,

    -- Include ID in filename
    include_id_in_filename = true,
  },
}

-- Setup function (called from init.lua)
function M.setup(opts)
  -- Merge user config with defaults
  if opts then
    M.config = vim.tbl_deep_extend("force", M.config, opts)
  end

  local note_utils = require("notes.utils")
  note_utils.invalidate_notebook_root()
  require("notes.vault_index").invalidate()
  require("notes.links").invalidate()

  -- Initialize commands and keymaps
  require("notes.commands").setup()

  -- Auto-update 'updated' frontmatter field on save (only if date changed)
  local augroup = vim.api.nvim_create_augroup("voidcore-notes-auto-updated", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    pattern = "*.md",
    callback = function()
      if not require("notes.utils").in_notebook(vim.fn.expand("%:p")) then
        return
      end
      local ok, fm_mod = pcall(require, "notes.frontmatter")
      if not ok then
        return
      end
      local buf_fm = fm_mod.parse_current_buffer()
      if not buf_fm then
        return
      end
      local today = os.date("%Y-%m-%d")
      local current_updated = (buf_fm.updated or ""):sub(1, 10)
      if current_updated ~= today then
        local utils_ok, u = pcall(require, "notes.utils")
        if utils_ok then
          fm_mod.update_frontmatter({ updated = u.now_iso() })
        end
      end
    end,
  })

  -- `gf` follows wiki-links in vault notes (notes/links.lua).
  local link_group = vim.api.nvim_create_augroup("voidcore-notes-links", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = link_group,
    pattern = "markdown",
    callback = function(args)
      if note_utils.in_notebook(vim.api.nvim_buf_get_name(args.buf)) then
        require("notes.links").attach(args.buf)
      end
    end,
  })

  local cache_group = vim.api.nvim_create_augroup("voidcore-notes-vault-index", { clear = true })
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufFilePost", "BufDelete" }, {
    group = cache_group,
    pattern = "*.md",
    callback = function(args)
      local path = vim.api.nvim_buf_get_name(args.buf)
      if note_utils.in_notebook(path) then
        require("notes.vault_index").invalidate()
        require("notes.links").invalidate()
      end
    end,
  })
  vim.api.nvim_create_autocmd("DirChanged", {
    group = cache_group,
    callback = function()
      note_utils.invalidate_notebook_root()
      require("notes.vault_index").invalidate()
      require("notes.links").invalidate()
    end,
  })
end

return M
