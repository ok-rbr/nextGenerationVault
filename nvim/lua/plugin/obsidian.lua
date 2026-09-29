-- obsidian.nvim — wiki-link / navigation / search layer on top of VoidLink
--
-- ARCHITECTURE
-- ============
-- Layer 3 of the four-layer note-taking split (docs/ADR-005). Each capability
-- has exactly one owner; nothing is configured twice.
--
--   1 Workflow / data  lua/notes/ (plugin/notes.lua) — Daily Notes, Templates,
--                      Frontmatter, Projects, PARA Routing, Metadata, Queries
--   2 Language         marksman (lsp/server/marksman.lua) — link diagnostics,
--                      heading anchors, definition, references
--   3 Vault semantics  THIS FILE — Wiki-Links, Backlinks, Link Navigation,
--                      Vault Search, Tag Search, Completion
--   4 Presentation     render-markdown.nvim (plugin/render-markdown.lua) —
--                      headings, checkboxes, tables, concealment
--
-- Layers 2 and 3 overlap in exactly one capability, completion, which is why
-- marksman runs with its completion capability disabled and this file stays
-- the single completion source (see CHANGELOG for the earlier conflict).
--
-- To keep that split unambiguous, `daily_notes` and `templates` are
-- intentionally NOT configured here — those stay lua/notes/'s job
-- (:NoteDaily, :NoteWeekly, :NoteMonthly, :NoteTemplate). The commands obsidian.nvim ships for them
-- (:ObsidianNew, :ObsidianToday, :ObsidianTomorrow, :ObsidianDailies,
-- :ObsidianTemplate) are not bound to any keymap below so they don't compete
-- with lua/notes/ in everyday use.
--
-- Vault path: resolved through notes.utils.get_notebook_root(), the same
-- resolution function every other lua/notes/ module uses. There is no
-- separate OBSIDIAN_VAULT env var — notebook_root (backed by NOTES_ROOT in
-- .env) is the single source of truth for the vault path.
--
-- KEYMAPS
-- =======
-- Every Obsidian keybinding lives in exactly one place: the `keys` list at the
-- bottom of this spec (lazy.nvim's global keymap layer), grouped under
-- <leader>o. Wiki-link navigation is <leader>of (:Obsidian follow_link); `gf`
-- and `<cr>` keep their native Neovim behaviour.

return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },

  opts = {
    legacy_commands = false, -- disables the Obsidian.nvim commands and keymaps
    -- -----------------------------------------------------------------------
    -- Workspace
    -- -----------------------------------------------------------------------
    workspaces = {
      {
        name = "vault",
        path = function()
          return require("notes.utils").get_notebook_root()
        end,
      },
    },

    -- -----------------------------------------------------------------------
    -- Picker
    --
    -- Uses Telescope for commands such as:
    --   :Obsidian search       (Vault Search)
    --   :Obsidian quick_switch (Quick Switch)
    --   :Obsidian backlinks    (Backlinks)
    --   :Obsidian tags         (Tag Search)
    -- -----------------------------------------------------------------------
    picker = {
      name = "telescope.nvim",
    },

    -- Keep completion focused on actual vault links. A slightly longer
    -- prefix avoids scanning the vault for every short or accidental input.
    completion = {
      min_chars = 3,
    },

    -- Keep reference pickers (link insertion, backlinks, quick switch) focused
    -- on notes that changed most recently.
    search = {
      sort_by = "modified",
      sort_reversed = true,
    },

    -- -----------------------------------------------------------------------
    -- Frontmatter
    --
    -- obsidian.nvim's own frontmatter writer is off: layer 1 owns frontmatter
    -- (docs/ADR-005) and two writers on one block is not a split, it is a
    -- race. Left on, this plugin rewrites `id`, `aliases` and `tags` on every
    -- `:w` of a vault note, pushing every other field into an opaque
    -- `metadata` table, while lua/notes/'s BufWritePre hook re-renders the
    -- same block to refresh `updated`. Whichever ran last won, so a note's
    -- `id` could flip between saves and the wiki-links written against the
    -- previous value stopped resolving.
    --
    -- The contract that replaces it: `id` always equals the filename stem and
    -- `aliases[1]` always holds the human title (notes/frontmatter.lua). That
    -- is what this plugin reads, so nothing is lost by not letting it write.
    -- -----------------------------------------------------------------------
    frontmatter = {
      enabled = false,
    },

    -- -----------------------------------------------------------------------
    -- Note IDs
    --
    -- Only relevant for link-following auto-creation of missing notes
    -- (lua/notes/ owns explicit note creation otherwise).
    -- -----------------------------------------------------------------------
    note_id_func = function(title)
      local slug = ""

      if title and title ~= "" then
        slug = "_" .. title:gsub("%s+", "_"):gsub("[^%w_]", ""):lower()
      end

      return os.date("%Y%m%d_%H%M") .. slug
    end,

    -- -----------------------------------------------------------------------
    -- Attachments
    --
    -- One destination for pasted images, shared with the Obsidian desktop app.
    -- The value mirrors "attachmentFolderPath" in dot_config/obsidian/app.json,
    -- which is the source of truth because the app cannot read Neovim config.
    -- Keep the two in sync; see docs/ADR-005 stage 3.
    --
    -- The path is vault-relative, not relative to the current note, so every
    -- image lands in the same folder regardless of which note pasted it.
    -- -----------------------------------------------------------------------
    attachments = {
      folder = "99_system/attachments/imgs",
    },

    -- -----------------------------------------------------------------------
    -- UI
    --
    -- Disabled: presentation is render-markdown.nvim's layer (docs/ADR-005).
    -- Both conceal the same buffers, so exactly one may own it. See
    -- plugin/render-markdown.lua for headings, checkboxes and tables.
    -- -----------------------------------------------------------------------
    ui = {
      enable = false,
    },
  },

  -- -------------------------------------------------------------------------
  -- Global keymaps
  --
  -- The only keymap surface of this spec: all Obsidian mappings are grouped
  -- under <leader>o and registered by lazy.nvim, never by the plugin options.
  -- <leader>of (:Obsidian follow_link) is the wiki-link navigation entry point.
  --
  -- Intentionally NOT bound: ObsidianNew, ObsidianToday/Tomorrow/Dailies,
  -- ObsidianTemplate, ObsidianExtractNote — those overlap with lua/notes/'s
  -- Daily Notes, Templates and note-creation ownership.
  -- -------------------------------------------------------------------------
  keys = {
    { "<leader>oo", "<cmd>Obsidian open<cr>", desc = "[O]bsidian [O]pen in App" },
    { "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "[O]bsidian [Q]uick Switch" },
    { "<leader>os", "<cmd>Obsidian search<cr>", desc = "[O]bsidian [S]earch (vault)" },
    { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "[O]bsidian [B]acklinks" },
    { "<leader>ol", "<cmd>Obsidian links<cr>", desc = "[O]bsidian [L]inks in buffer" },
    { "<leader>of", "<cmd>Obsidian follow_link<cr>", desc = "[O]bsidian [F]ollow link" },
    { "<leader>ot", "<cmd>Obsidian tags<cr>", desc = "[O]bsidian [T]ag search" },
    { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "[O]bsidian [R]ename (updates backlinks)" },
    { "<leader>op", "<cmd>Obsidian paste_img<cr>", desc = "[O]bsidian [P]aste image" },

    -- Linking from the text already written, rather than from memory. Select
    -- the words that should become the link and pick the target from a
    -- picker; the selection stays as the link label. This is the path that
    -- replaces opening the target note to copy its title by hand.
    { "<leader>oi", ":Obsidian link<cr>", mode = "v", desc = "[O]bsidian l[I]nk selection to note" },
    { "<leader>oN", ":Obsidian link_new<cr>", mode = "v", desc = "[O]bsidian link selection to [N]ew note" },
  },
}
