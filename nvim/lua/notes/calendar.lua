-- notes/calendar.lua
-- khal calendar integration for VoidDash
-- Requires: khal CLI available in $PATH

local utils = require("notes.utils")

local M = {}

-- ============================================================================
-- CORE HELPERS
-- ============================================================================

---Check whether the `khal` binary is available
---@return boolean
local function has_khal()
  return vim.fn.executable("khal") == 1
end

---Run khal and return stdout lines
---@param args string[]
---@return string[]|nil lines, string|nil err
local function run_khal(args)
  return utils.run_command("khal", args)
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

---Return today's events as raw lines from `khal list today today`
---@return string[]
function M.today_events()
  if not has_khal() then
    return { "  khal not found in PATH" }
  end

  local lines, err = run_khal({ "list", "--notstarted", "today", "today" })
  if not lines then
    return { "  error: " .. (err or "unknown") }
  end

  if #lines == 0 then
    return { "  No events today" }
  end

  -- Strip leading header line (khal prints the date as first line)
  local result = {}
  for i, line in ipairs(lines) do
    if i ~= 1 or not line:match("^%a") then
      table.insert(result, "  " .. line)
    end
  end

  return result
end

---Return a one-line summary for the dashboard header
---@return string
function M.summary()
  if not has_khal() then
    return "📅 Events — khal not found"
  end

  local lines, err = run_khal({ "list", "--notstarted", "today", "today" })
  if not lines then
    return "📅 Events — error: " .. (err or "unknown")
  end

  -- Count non-header, non-empty lines
  local count = 0
  for i, line in ipairs(lines) do
    if (i ~= 1 or not line:match("^%a")) and line ~= "" then
      count = count + 1
    end
  end

  if count == 0 then
    return "📅 Events — none today"
  end
  return string.format("📅 Events — %d today", count)
end

---Open a Telescope picker showing today's khal events.
---Selecting an event has no special action (read-only view).
function M.telescope_pick()
  local picker = require("notes.picker")

  if not has_khal() then
    vim.notify("khal not found in PATH", vim.log.levels.WARN)
    return
  end

  -- Fetch events for the next 7 days
  local lines, err = run_khal({ "list", "--notstarted", "today", "7days" })
  if not lines then
    vim.notify("khal error: " .. (err or ""), vim.log.levels.ERROR)
    return
  end

  local items = {}
  for _, line in ipairs(lines) do
    table.insert(items, { display = line })
  end

  picker.pick(items, {
    prompt_title = "khal — Upcoming Events",
    previewer = false,
    on_select = function() end, -- read-only view, no action on <CR>
  })
end

---Interactively create a new khal event using `khal new`
function M.new_event()
  if not has_khal() then
    vim.notify("khal not found in PATH", vim.log.levels.WARN)
    return
  end

  vim.ui.input({ prompt = "Event date (YYYY-MM-DD, default: today): " }, function(date)
    date = (date and date ~= "") and date or os.date("%Y-%m-%d")

    vim.ui.input({ prompt = "Start time (HH:MM): " }, function(start_time)
      if not start_time or start_time == "" then
        return
      end

      vim.ui.input({ prompt = "End time (HH:MM): " }, function(end_time)
        if not end_time or end_time == "" then
          return
        end

        vim.ui.input({ prompt = "Event title: " }, function(title)
          if not title or title == "" then
            return
          end

          -- Use list form to avoid shell injection when title contains metacharacters
          local result = vim.fn.system({ "khal", "new", date, start_time, end_time, title })
          if vim.v.shell_error ~= 0 then
            vim.notify("khal new failed: " .. result, vim.log.levels.ERROR)
          else
            vim.notify("Event created: " .. title, vim.log.levels.INFO)
          end
        end)
      end)
    end)
  end)
end

-- ============================================================================
-- COMMAND REGISTRATION
-- ============================================================================

function M.setup()
  vim.api.nvim_create_user_command("CalendarPick", M.telescope_pick, {
    desc = "Browse upcoming khal events (Telescope)",
  })

  vim.api.nvim_create_user_command("CalendarNew", M.new_event, {
    desc = "Create a new khal calendar event",
  })

  vim.keymap.set("n", "<leader>nwc", M.telescope_pick, { silent = true, desc = "[N]ote [W]orkflow [C]alendar (khal)" })
  vim.keymap.set("n", "<leader>nwC", M.new_event, { silent = true, desc = "[N]ote [W]orkflow new [C]alendar event" })
end

return M
