-- lua/config/filetypes.lua
-- In here, we define custom filetype patterns, so that our ide will handle them correctly.

vim.filetype.add({
  pattern = {
    [".*%.gitconfig%.base"] = "gitconfig",
    [".*%.gitconfig%.local"] = "gitconfig",
    [".*%.tmpl"] = function(path)
      local non_template_path = path:gsub("%.tmpl$", "")
      local maybe_dotfile_path = non_template_path:gsub("^dot_", "."):gsub("/dot_", "/.")
      local detected = vim.filetype.match({
        filename = maybe_dotfile_path,
      })

      if detected then
        return detected
      end

      if non_template_path:match("%.chezmoiignore$") then
        return "gitignore"
      end

      return "gotmpl"
    end,
  },
})

vim.filetype.add({
  extension = {
    http = "http",
    rest = "http",
    bicep = "bicep",

    ps1 = "ps1",
    psm1 = "psm1",
    psd1 = "psd1",

    mdx = "markdown.mdx",
  },
})
