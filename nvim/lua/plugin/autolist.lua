-- autolist: automatic list continuation and formatting for Markdown.

local function parse_table_row(line)
  local content = vim.trim(line)
  if content:sub(1, 1) == "|" then
    content = vim.trim(content:sub(2))
  end
  if content:sub(-1) == "|" then
    content = vim.trim(content:sub(1, -2))
  end

  local cells = {}
  local cell = {}
  local escaped = false

  for index = 1, #content do
    local character = content:sub(index, index)
    if character == "|" and not escaped then
      table.insert(cells, vim.trim(table.concat(cell)))
      cell = {}
    else
      table.insert(cell, character)
    end
    escaped = character == "\\" and not escaped
  end

  table.insert(cells, vim.trim(table.concat(cell)))
  return cells
end

local function is_separator_row(cells)
  if #cells < 2 then
    return false
  end

  for _, cell in ipairs(cells) do
    if not cell:match("^:?-+:?$") then
      return false
    end
  end

  return true
end

local function is_table_candidate(line)
  return line:find("|", 1, true) ~= nil and vim.trim(line) ~= ""
end

local function format_table()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local current = vim.api.nvim_win_get_cursor(0)[1]
  local first = current
  local last = current

  while first > 1 and is_table_candidate(lines[first - 1]) do
    first = first - 1
  end
  while last < #lines and is_table_candidate(lines[last + 1]) do
    last = last + 1
  end

  local rows = {}
  local separator
  for index = first, last do
    local cells = parse_table_row(lines[index])
    table.insert(rows, cells)
    if is_separator_row(cells) then
      if separator then
        vim.notify("Markdown table format skipped: multiple separator rows", vim.log.levels.WARN)
        return
      end
      separator = #rows
    end
  end

  if not separator then
    vim.notify("Markdown table format skipped: no separator row found", vim.log.levels.WARN)
    return
  end

  local column_count = #rows[separator]
  for _, cells in ipairs(rows) do
    if #cells ~= column_count then
      vim.notify("Markdown table format skipped: inconsistent column count", vim.log.levels.WARN)
      return
    end
  end

  local widths = {}
  for column = 1, column_count do
    widths[column] = 3
  end
  for row, cells in ipairs(rows) do
    if row ~= separator then
      for column, cell in ipairs(cells) do
        widths[column] = math.max(widths[column], vim.fn.strdisplaywidth(cell))
      end
    end
  end

  local formatted = {}
  for row, cells in ipairs(rows) do
    local output = {}
    for column, cell in ipairs(cells) do
      if row == separator then
        local left_aligned = cell:sub(1, 1) == ":"
        local right_aligned = cell:sub(-1) == ":"
        local marker = string.rep("-", math.max(widths[column], 3))
        if left_aligned then
          marker = ":" .. marker
        end
        if right_aligned then
          marker = marker .. ":"
        end
        table.insert(output, marker)
      else
        table.insert(output, cell .. string.rep(" ", widths[column] - vim.fn.strdisplaywidth(cell)))
      end
    end
    table.insert(formatted, "| " .. table.concat(output, " | ") .. " |")
  end

  vim.api.nvim_buf_set_lines(bufnr, first - 1, last, false, formatted)
end

return {
  "gaoDean/autolist.nvim",

  ft = {
    "markdown",
  },

  config = function()
    require("autolist").setup({
      enabled = true,
      list_cap = 50,

      colon = {
        indent = true,
      },
    })

    local group = vim.api.nvim_create_augroup("voidcore-autolist", {
      clear = true,
    })

    local function attach(bufnr, filetype)
      local opts = {
        buffer = bufnr,
        silent = true,
      }

      vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>", opts)
      vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>", opts)
      vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>", opts)

      vim.keymap.set("i", "<Tab>", "<cmd>AutolistTab<cr>", opts)
      vim.keymap.set("i", "<S-Tab>", "<cmd>AutolistShiftTab<cr>", opts)

      vim.keymap.set("n", "<CR>", "<cmd>AutolistToggleCheckbox<cr><CR>", opts)
      vim.keymap.set("n", "<C-r>", "<cmd>AutolistRecalculate<cr>", opts)

      vim.keymap.set("n", ">>", ">><cmd>AutolistRecalculate<cr>", opts)
      vim.keymap.set("n", "<<", "<<<cmd>AutolistRecalculate<cr>", opts)
      vim.keymap.set("v", ">", "><cmd>AutolistRecalculate<cr>gv", opts)
      vim.keymap.set("v", "<", "<<cmd>AutolistRecalculate<cr>gv", opts)

      if filetype == "markdown" then
        vim.api.nvim_buf_create_user_command(bufnr, "MarkdownTableFormat", format_table, {
          desc = "Align the Markdown table at the cursor",
        })
        vim.keymap.set("n", "<leader>mt", "<cmd>MarkdownTableFormat<cr>", {
          buffer = bufnr,
          desc = "[M]arkdown [T]able format",
          silent = true,
        })
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = { "markdown" },
      callback = function(args)
        attach(args.buf, args.match)
      end,
    })

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      local filetype = vim.bo[bufnr].filetype
      if filetype == "markdown" then
        attach(bufnr, filetype)
      end
    end
  end,
}
