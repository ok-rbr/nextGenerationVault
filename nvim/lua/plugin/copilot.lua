-- gitHub copilot inline suggestions.
--
-- Active for code buffers and for Markdown, disabled for secrets and special
-- buffers. The header used to claim notes were excluded while `markdown = true`
-- below enabled them everywhere; the config is what runs, so the sentence was
-- corrected rather than the behaviour.
--
-- Markdown means vault notes too. That is a deliberate choice, not an
-- oversight: ghost text and Marksman completion share Markdown note buffers,
-- and they coexist because `hide_during_completion` keeps suggestions out of
-- the way while the completion menu is open. Set
-- `markdown = false` to take Copilot out of notes entirely.

return {
  {
    "zbirenbaum/copilot.lua",
    main = "copilot",
    event = "InsertEnter",
    cmd = { "Copilot" },
    opts = {
      panel = {
        enabled = false,
      },

      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        debounce = 75,
        trigger_on_accept = true,
        keymap = {
          accept = "<C-J>",
          next = "<C-L>",
          prev = "<C-H>",
          dismiss = "<C-\\>",
        },
      },

      filetypes = {
        -- Documentation / notes. See the header: this covers vault notes, and
        -- ghost text shares Markdown buffers with Marksman completion.
        markdown = true,
        text = false,

        -- Secrets / local config.
        env = false,
        sh = true,
        yaml = true,

        -- Git / special buffers.
        gitcommit = false,
        gitrebase = false,
        help = false,
        TelescopePrompt = false,
        lazy = false,
        mason = false,

        -- Code by default.
        ["*"] = true,
      },
    },
  },
}
