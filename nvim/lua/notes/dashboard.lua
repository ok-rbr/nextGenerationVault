-- notes/dashboard.lua
-- VoidDash — Unified daily overview dashboard
--
-- Opens a read-only floating buffer with aggregated data from:
--   · khal       (calendar events)
--   · taskwarrior (pending tasks)
--   · health     (last workout / stats)
--   · mail       (unread count via notmuch or maildir scan)
--
-- Usage:
--   :VoidDash                     open the dashboard
--   <leader>nD                    keymap shortcut

local M = {}

-- ============================================================================
-- MAIL HELPERS
-- ============================================================================

---Render an unread count as the dashboard's one-line mail summary.
---@param count number
---@return string
local function unread_line(count)
  if count == 0 then
    return "📬 Mail — no unread"
  end
  return string.format("📬 Mail — %d unread", count)
end

---Count unread mail messages.
---Strategy:
---  1. notmuch count tag:unread (if available)
---  2. Count files in maildir new/ directories (reads
---     ~/.local/state/aerc/maildir_path)
---@return string  One-line summary
local function mail_summary()
  -- 1. notmuch
  if vim.fn.executable("notmuch") == 1 then
    local result = vim.fn.system({ "notmuch", "count", "tag:unread" })
    if vim.v.shell_error == 0 then
      return unread_line(tonumber(result:match("%d+")) or 0)
    end
  end

  -- 2. Maildir scan
  local maildir_state = vim.fn.expand("~/.local/state/aerc/maildir_path")
  local maildir = nil
  if vim.fn.filereadable(maildir_state) == 1 then
    local lines = vim.fn.readfile(maildir_state)
    if lines and lines[1] then
      maildir = vim.fn.trim(lines[1])
    end
  end

  if maildir and vim.fn.isdirectory(maildir) == 1 then
    local new_dirs = vim.fn.globpath(maildir, "**/new", false, true)
    local count = 0
    for _, dir in ipairs(new_dirs) do
      local files = vim.fn.globpath(dir, "*", false, true)
      count = count + #files
    end
    return unread_line(count)
  end

  return "📬 Mail — not configured"
end

-- ============================================================================
-- BUFFER HELPERS
-- ============================================================================

---Build the full list of lines for the dashboard buffer
---@return string[]
local function build_lines()
  local date = os.date("%Y-%m-%d")
  local time = os.date("%H:%M")

  -- Gather dashboard snapshots once per data source.
  local cal_summary, task_summary, health_summary
  local task_lines = {}
  local health_lines = {}

  local ok_cal, cal = pcall(require, "notes.calendar")
  cal_summary = ok_cal and cal.summary() or "📅 Events — unavailable"

  local ok_task, task = pcall(require, "notes.taskwarrior")
  if ok_task then
    task_summary, task_lines = task.dashboard_data(5)
  else
    task_summary = "✅ Tasks — unavailable"
  end

  local ok_health, health = pcall(require, "notes.health")
  if ok_health then
    local data = health.dashboard_data()
    health_summary = data.summary
    health_lines = data.lines
    local stats = data.stats
    table.insert(
      health_lines,
      string.format("  This week: %d | This month: %d | Total: %d", stats.this_week, stats.this_month, stats.total)
    )
  else
    health_summary = "🏋️ Workout — unavailable"
  end

  local mail = mail_summary()

  -- Detailed upcoming events (today only, max 5 lines)
  local cal_lines = {}
  if ok_cal then
    cal_lines = cal.today_events()
    if #cal_lines > 5 then
      cal_lines = vim.list_slice(cal_lines, 1, 5)
      table.insert(cal_lines, "  … (more events)")
    end
  end

  -- ── Layout ──────────────────────────────────────────────────────────────
  local W = 52 -- inner width (between ║ chars)
  local border_top = "╔" .. string.rep("═", W) .. "╗"
  local border_sep = "╠" .. string.rep("═", W) .. "╣"
  local border_bottom = "╚" .. string.rep("═", W) .. "╝"

  local function row(content)
    content = content or ""
    local visible = content:gsub("\27%[[%d;]*[mKHJABCDsuhl]", "") -- strip common ANSI sequences
    local pad = W - vim.fn.strdisplaywidth(visible)
    if pad < 0 then
      pad = 0
    end
    return "║" .. content .. string.rep(" ", pad) .. "║"
  end

  local function section_header(title)
    return row("  " .. title)
  end

  local lines = {
    border_top,
    row(string.format("  VoidDash — %s  %s", date, time)),
    border_sep,
    -- Calendar
    section_header(cal_summary),
  }

  for _, l in ipairs(cal_lines) do
    table.insert(lines, row(l))
  end

  table.insert(lines, border_sep)
  -- Tasks
  table.insert(lines, section_header(task_summary))
  for _, l in ipairs(task_lines) do
    table.insert(lines, row(l))
  end

  table.insert(lines, border_sep)
  -- Health
  table.insert(lines, section_header(health_summary))
  for _, l in ipairs(health_lines) do
    table.insert(lines, row(l))
  end

  table.insert(lines, border_sep)
  -- Mail
  table.insert(lines, section_header(mail))

  table.insert(lines, border_sep)
  -- Help
  table.insert(lines, row("  q  close   r  refresh"))
  table.insert(lines, border_bottom)

  return lines
end

-- ============================================================================
-- WINDOW / BUFFER MANAGEMENT
-- ============================================================================

-- Track current dashboard window/buffer to support refresh
local _state = { win = nil, buf = nil }

---Write lines into the dashboard buffer (re-uses existing buf if open)
local function render()
  local lines = build_lines()

  if not _state.buf or not vim.api.nvim_buf_is_valid(_state.buf) then
    _state.buf = vim.api.nvim_create_buf(false, true)
  end

  vim.bo[_state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(_state.buf, 0, -1, false, lines)
  vim.bo[_state.buf].modifiable = false
  vim.bo[_state.buf].filetype = "voiddash"
  vim.bo[_state.buf].bufhidden = "wipe"
end

---Open (or refresh) the VoidDash floating window
function M.open()
  -- If window is already open just refresh it
  if _state.win and vim.api.nvim_win_is_valid(_state.win) then
    render()
    vim.api.nvim_set_current_win(_state.win)
    return
  end

  render()

  -- Determine window dimensions based on content
  local lines = vim.api.nvim_buf_get_lines(_state.buf, 0, -1, false)
  local height = #lines
  local width = 0
  for _, l in ipairs(lines) do
    local w = vim.fn.strdisplaywidth(l)
    if w > width then
      width = w
    end
  end
  width = math.max(width, 40)

  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  _state.win = vim.api.nvim_open_win(_state.buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "none",
    title = "",
    noautocmd = true,
  })

  -- Key mappings inside the dashboard
  local map_opts = { buffer = _state.buf, silent = true, nowait = true }
  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(_state.win) then
      vim.api.nvim_win_close(_state.win, true)
    end
  end, map_opts)

  vim.keymap.set("n", "r", function()
    render()
    vim.notify("VoidDash refreshed", vim.log.levels.INFO)
  end, map_opts)

  -- Close on focus loss
  vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
    buffer = _state.buf,
    once = true,
    callback = function()
      if _state.win and vim.api.nvim_win_is_valid(_state.win) then
        vim.api.nvim_win_close(_state.win, true)
      end
      _state.win = nil
      _state.buf = nil
    end,
  })
end

-- ============================================================================
-- COMMAND REGISTRATION
-- ============================================================================

function M.setup()
  -- Register sub-module commands
  local ok_task, task = pcall(require, "notes.taskwarrior")
  if ok_task then
    task.setup()
  end

  local ok_cal, cal = pcall(require, "notes.calendar")
  if ok_cal then
    cal.setup()
  end

  local ok_health, health = pcall(require, "notes.health")
  if ok_health then
    health.setup()
  end

  -- Main VoidDash command
  vim.api.nvim_create_user_command("VoidDash", M.open, {
    desc = "Open VoidDash daily overview dashboard",
  })

  -- Keybinding: <leader>nD  (capital D to avoid clash with daily note <leader>nd)
  vim.keymap.set("n", "<leader>nD", M.open, { silent = true, desc = "[N]ote Voi[D]ash dashboard" })
end

return M
