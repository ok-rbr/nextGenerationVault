-- Kotlin Language Server

local M = {}

M.config = {
  cmd = { "kotlin-language-server" },
  filetypes = { "kotlin" },

  root_markers = {
    "settings.gradle.kts",
    "settings.gradle",
    "build.gradle.kts",
    "build.gradle",
    "gradlew",
    "pom.xml",
    ".git",
  },

  init_options = {
    storagePath = vim.fn.stdpath("cache") .. "/kotlin-language-server",
  },
}

return M
