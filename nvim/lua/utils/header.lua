-- Header and Quote Generator for Snacks Dashboard
-- This module provides a dynamic header and quote loading system for the Neovim dashboard
--
-- Features:
-- - Minimalist developer header (ASCII art)
-- - Random quote loading from external file
-- - Cached quote loading for performance
-- - Easy extensibility for new header styles and quote sources
--
-- Usage:
--   local header = require("utils.header")
--   local dashboard_text = header.get_dashboard_header()

local M = {}

-- Cache for loaded quotes to avoid repeated file I/O
local quotes_cache = nil
local quotes_file_path = vim.fn.stdpath("config") .. "/quotes.txt"

-- Minimalist Developer Header
-- This is a clean, professional header without excessive ornamentation
-- To change the header style, simply modify this string
-- Alternative header styles can be added as separate functions
--[[
M.header = [[
╭────────────────────────────────────────╮
│                                        │
│           DEVELOPER  SPACE             │
│                                        │
╰────────────────────────────────────────╯
]]
-- ]]
-- Alternative minimalist headers (commented out, can be easily swapped)
-- Uncomment and assign to M.header to use a different style

--[[
M.header = [[
┌──────────────────────────────────────┐
│      { CODE • CREATE • INNOVATE }    │
└──────────────────────────────────────┘
]]
--]]

--[[
M.header = [[
  ╔═══════════════════════════════╗
  ║     D E V E L O P M E N T     ║
  ╚═══════════════════════════════╝
]]
--]]

--[[
M.header = [[
    ╭───────────────────────────╮
    │     < CODING MODE />      │
    ╰───────────────────────────╯
]]
--]]

M.header = ""

-- Load quotes from file with error handling
-- Returns: table of quotes or empty table on error
local function load_quotes_from_file()
  -- Check if file exists
  local file = io.open(quotes_file_path, "r")
  if not file then
    -- File doesn't exist, return empty table
    -- This prevents errors if quotes.txt hasn't been created yet
    return {}
  end

  local quotes = {}
  for line in file:lines() do
    -- Trim whitespace and skip empty lines
    local trimmed = line:match("^%s*(.-)%s*$")
    if trimmed and trimmed ~= "" then
      table.insert(quotes, trimmed)
    end
  end
  file:close()

  return quotes
end

-- Get all quotes (cached)
-- This function loads quotes once and caches them for performance
-- To reload quotes (e.g., after modifying quotes.txt), call M.reload_quotes()
function M.get_quotes()
  if quotes_cache == nil then
    quotes_cache = load_quotes_from_file()
  end
  return quotes_cache
end

-- Reload quotes from file (useful after modifying quotes.txt)
-- Call this function if you've added new quotes and want to see them without restarting Neovim
function M.reload_quotes()
  quotes_cache = nil
  return M.get_quotes()
end

-- Get a random quote from the quotes file
-- Returns: random quote string or nil if no quotes available
function M.get_random_quote()
  local quotes = M.get_quotes()

  if #quotes == 0 then
    return nil
  end

  -- Use Lua's math.random for randomization
  math.randomseed(os.time())
  local index = math.random(1, #quotes)
  return quotes[index]
end

-- Format a quote with a decorative frame
-- Args:
--   quote: string - The quote text to format
-- Returns: string - Formatted quote with frame
local function format_quote(quote)
  if not quote then
    return ""
  end

  -- Calculate width based on quote length, with min/max constraints
  local min_width = 40
  local max_width = 80
  local quote_length = #quote
  local width = math.min(math.max(quote_length + 4, min_width), max_width)

  -- Word wrap if quote is too long
  local wrapped_lines = {}
  if quote_length > max_width - 4 then
    local words = {}
    for word in quote:gmatch("%S+") do
      table.insert(words, word)
    end

    local current_line = ""
    for _, word in ipairs(words) do
      if #current_line + #word + 1 <= max_width - 4 then
        current_line = current_line == "" and word or current_line .. " " .. word
      else
        table.insert(wrapped_lines, current_line)
        current_line = word
      end
    end
    if current_line ~= "" then
      table.insert(wrapped_lines, current_line)
    end
  else
    wrapped_lines = { quote }
  end

  -- Build the frame
  local top = "╭" .. string.rep("─", width - 2) .. "╮"
  local bottom = "╰" .. string.rep("─", width - 2) .. "╯"

  local result = { "", top }

  for _, line in ipairs(wrapped_lines) do
    local padding = width - #line - 4
    local left_pad = math.floor(padding / 2)
    local right_pad = padding - left_pad
    table.insert(result, "│ " .. string.rep(" ", left_pad) .. line .. string.rep(" ", right_pad) .. " │")
  end

  table.insert(result, bottom)
  table.insert(result, "")

  return table.concat(result, "\n")
end

-- Get the complete dashboard header (header + quote)
-- This is the main function to call from the snacks configuration
-- Returns: string - Complete formatted dashboard text
function M.get_dashboard_header()
  local result = M.header

  local quote = M.get_random_quote()
  if quote then
    result = result .. "\n" .. format_quote(quote)
  end

  return result
end

-- Export quotes file path for external access
-- Useful if you want to edit the quotes file programmatically
M.quotes_file_path = quotes_file_path

return M
