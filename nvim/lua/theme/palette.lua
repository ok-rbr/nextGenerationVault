-- theme/palette.lua — the desktop palette for Neovim.
--
-- Rendered by chezmoi from .chezmoidata/theme.toml, the single place where a
-- desktop or terminal colour is set. Do not edit colours here: this file is
-- generated at apply time, so change the data file and apply instead. Plugins
-- read their colours from this module rather than carrying literals.
--
--   local palette = require("theme.palette")
--   palette.accent.red

return {
  base = {
    bg = "#282c34",
    bg_dark = "#21252b",
    bg_hover = "#2c313a",
    bg_terminal = "#1e222a",
    bg_terminal_alt = "#1e2127",
    fg = "#abb2bf",
    fg_bright = "#ffffff",
    selection = "#3e4451",
    shadow = "#000000",
  },
  accent = {
    blue = "#61afef",
    cyan = "#56b6c2",
    gray = "#5c6370",
    green = "#98c379",
    orange = "#d19a66",
    purple = "#c678dd",
    red = "#e06c75",
    yellow = "#e5c07b",
  },
  ui = {
    attention = "#ff9e64",
    icons = {
      accent = "#ffffff",
      muted = "#606060",
      primary = "#c9c9c9",
      secondary = "#a0a0a0",
      tertiary = "#808080",
    },
    heading_bg = {
      h1 = "#3a1f1f",
      h2 = "#3a2a1a",
      h3 = "#3a3020",
      h4 = "#243220",
      h5 = "#1c2e30",
      h6 = "#1c2a3a",
    },
    todo = {
      default = "#7c3aed",
      error = "#dc2626",
      hint = "#10b981",
      info = "#2563eb",
      test = "#ff006e",
      warning = "#fbbf24",
    },
  },
}
