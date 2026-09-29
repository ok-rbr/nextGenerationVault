-- lua/config/clipboard.lua

local M = {}

function M.yank_buffer()
  local ok, err = pcall(function()
    vim.fn.setreg("+", vim.api.nvim_buf_get_lines(0, 0, -1, false), "l")
  end)

  if ok then
    vim.notify("File copied to clipboard", vim.log.levels.INFO)
  else
    vim.notify("Failed to copy file: " .. tostring(err), vim.log.levels.ERROR)
  end
end

return M
