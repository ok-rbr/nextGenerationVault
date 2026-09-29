-- render-markdown.nvim: in-editor Markdown rendering (headings, bullets,
-- checkboxes, tables).
--
-- Layer 4 of the note-taking architecture (docs/ADR-005) and the single owner
-- of Markdown presentation. This renderer is independent of the disabled
-- obsidian.nvim spec and also applies outside the vault — this repository's
-- docs/ included.

return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  config = function()
    -- OneDark Pro palette, rendered from .chezmoidata/theme.toml.
    local palette = require("theme.palette")
    local c = {
      h1 = palette.accent.red,
      h2 = palette.accent.orange,
      h3 = palette.accent.yellow,
      h4 = palette.accent.green,
      h5 = palette.accent.cyan,
      h6 = palette.accent.blue,
      dim = palette.accent.gray, -- comments
    }

    require("render-markdown").setup({
      enabled = true,
      render_modes = { "n", "c" },
      anti_conceal = { enabled = true },

      heading = {
        enabled = true,
        sign = false,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        backgrounds = {
          "RenderMarkdownH1Bg",
          "RenderMarkdownH2Bg",
          "RenderMarkdownH3Bg",
          "RenderMarkdownH4Bg",
          "RenderMarkdownH5Bg",
          "RenderMarkdownH6Bg",
        },
        foregrounds = {
          "RenderMarkdownH1",
          "RenderMarkdownH2",
          "RenderMarkdownH3",
          "RenderMarkdownH4",
          "RenderMarkdownH5",
          "RenderMarkdownH6",
        },
      },

      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
      },

      checkbox = {
        enabled = true,
        unchecked = { icon = "󰄱 ", highlight = "RenderMarkdownUnchecked" },
        checked = { icon = "󰱒 ", highlight = "RenderMarkdownChecked" },
      },

      code = {
        enabled = true,
        sign = false,
        style = "full",
        position = "left",
        width = "full",
        border = "thin",
      },

      dash = { enabled = true, icon = "─", highlight = "RenderMarkdownDash" },
      quote = { enabled = true, icon = "▋", highlight = "RenderMarkdownQuote" },
      table = { enabled = true, style = "full", cell = "padded", padding = 1 },

      link = {
        enabled = true,
        footnote = { superscript = true },
        image = "󰥶 ",
        email = "󰀓 ",
        hyperlink = "󰌹 ",
        highlight = "RenderMarkdownLink",
        wiki = { icon = "󱗖 ", highlight = "RenderMarkdownWikiLink" },
      },

      sign = { enabled = false },
    })

    -- Apply OneDark Pro–aligned highlight groups after colorscheme loads
    local function set_highlights()
      local hl = vim.api.nvim_set_hl
      hl(0, "RenderMarkdownH1", { fg = c.h1, bold = true })
      hl(0, "RenderMarkdownH2", { fg = c.h2, bold = true })
      hl(0, "RenderMarkdownH3", { fg = c.h3, bold = true })
      hl(0, "RenderMarkdownH4", { fg = c.h4, bold = true })
      hl(0, "RenderMarkdownH5", { fg = c.h5, bold = true })
      hl(0, "RenderMarkdownH6", { fg = c.h6, bold = true })
      hl(0, "RenderMarkdownH1Bg", { bg = palette.ui.heading_bg.h1 })
      hl(0, "RenderMarkdownH2Bg", { bg = palette.ui.heading_bg.h2 })
      hl(0, "RenderMarkdownH3Bg", { bg = palette.ui.heading_bg.h3 })
      hl(0, "RenderMarkdownH4Bg", { bg = palette.ui.heading_bg.h4 })
      hl(0, "RenderMarkdownH5Bg", { bg = palette.ui.heading_bg.h5 })
      hl(0, "RenderMarkdownH6Bg", { bg = palette.ui.heading_bg.h6 })
      hl(0, "RenderMarkdownUnchecked", { fg = c.dim })
      hl(0, "RenderMarkdownChecked", { fg = c.h4 })
      hl(0, "RenderMarkdownDash", { fg = c.dim })
      hl(0, "RenderMarkdownQuote", { fg = c.h5, italic = true })
      hl(0, "RenderMarkdownLink", { fg = c.h6, underline = true })
      hl(0, "RenderMarkdownWikiLink", { fg = c.h5, underline = true })
    end

    set_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_highlights,
    })
  end,
}
