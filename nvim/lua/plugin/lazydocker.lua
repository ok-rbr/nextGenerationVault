-- lua/plugin/lazydocker.lua
-- docker / lazydocker integration

return {
  "mgierada/lazydocker.nvim",
  dependencies = {
    "akinsho/toggleterm.nvim",
  },
  keys = {
    {
      "<leader>ld",
      function()
        if vim.fn.executable("lazydocker") ~= 1 then
          vim.notify("lazydocker binary not found", vim.log.levels.ERROR, { title = "lazydocker.nvim" })
          return
        end

        require("lazydocker").open()
      end,
      desc = "Open LazyDocker",
    },
  },
  opts = {
    border = "curved",
  },
}
