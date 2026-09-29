-- devicons configuration.
--
-- Uses the centralized icon system from `config.icons`.

local M = {}

function M.setup()
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    return
  end

  local icons = require("config.icons")

  devicons.setup({
    override = icons.get_devicons_override(),
    default = true,
  })
end

return M
