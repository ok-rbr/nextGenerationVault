-- notes/periodic.lua
-- Date arithmetic for periodic notes (daily, weekly, monthly).
--
-- Pure Lua on purpose: nothing here touches the editor, so the calendar logic
-- can be reasoned about (and exercised) without a running Neovim. Creating and
-- opening the note is notes.commands' job.
--
-- Weeks are ISO 8601 weeks: they start on Monday, and week 1 is the week that
-- contains the year's first Thursday. So 2026-12-31 belongs to 2026-W53 and
-- 2027-01-01 does too; the year of a week is not always the calendar year of
-- its days.

local M = {}

local DAY = 24 * 60 * 60

-- Template file names looked up at the root of the Neovim templates directory.
-- They are also hidden from the :NoteTemplate picker, because a periodic note
-- has exactly one creation path: its own command, which derives the file name
-- (and with it the note's id) from the period rather than from a prompt.
M.template_names = {
  daily = { "daily.md", "_daily.md", "Daily.md" },
  weekly = { "weekly.md" },
  monthly = { "monthly.md" },
}

---Noon keeps whole-day arithmetic away from midnight, so a DST shift moves the
---time by an hour but never onto a neighbouring day.
---@return integer
local function noon(year, month, day)
  return os.time({ year = year, month = month, day = day, hour = 12 })
end

---@param t integer
---@return integer weekday 1 = Monday ... 7 = Sunday
local function iso_weekday(t)
  local w = tonumber(os.date("%w", t))
  return w == 0 and 7 or w
end

---Return the ISO week-year and week number that contain `t`.
---@param t integer
---@return integer year
---@return integer week
function M.iso_week(t)
  -- The Thursday of a week decides which year the week belongs to.
  local thursday = t + (4 - iso_weekday(t)) * DAY
  local year = tonumber(os.date("%Y", thursday))
  local yday = tonumber(os.date("%j", thursday))
  return year, math.floor((yday - 1) / 7) + 1
end

---Number of ISO weeks (52 or 53) in `year`. 28 December is always in the
---year's last week.
---@param year integer
---@return integer
function M.weeks_in_year(year)
  local _, week = M.iso_week(noon(year, 12, 28))
  return week
end

---@param year integer
---@param week integer
---@return integer monday Noon on the Monday that starts the week
local function week_monday(year, week)
  -- 4 January is always in week 1.
  local jan4 = noon(year, 1, 4)
  return jan4 + (1 - iso_weekday(jan4) + (week - 1) * 7) * DAY
end

---@param year integer
---@param week integer
---@return string
local function week_stem(year, week)
  -- Lowercase and underscore-separated: file names follow the repository's
  -- slug grammar (notes.utils.is_slug), which rejects "-" and capitals.
  return string.format("%04d_w%02d", year, week)
end

---@param year integer
---@param month integer
---@return string
local function month_stem(year, month)
  return string.format("%04d_%02d", year, month)
end

---@class notes.PeriodicSpec
---@field key string Period in ISO form: YYYY-MM-DD, YYYY-Www or YYYY-MM
---@field stem string File name stem, also the note's id
---@field title string Human title, also aliases[1]
---@field start string First day of the period, YYYY-MM-DD
---@field finish string Last day of the period, YYYY-MM-DD
---@field previous string Stem of the preceding period's note
---@field next string Stem of the following period's note

---Resolve a daily period.
---@param date string|nil YYYY-MM-DD; nil or "" for today
---@return notes.PeriodicSpec|nil spec
---@return string|nil err
function M.day(date)
  date = date and date:match("^%s*(.-)%s*$") or ""
  local t
  if date == "" then
    local now = os.date("*t")
    t = noon(now.year, now.month, now.day)
  else
    local y, m, d = date:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
    t = y and noon(tonumber(y), tonumber(m), tonumber(d))
    -- os.time normalises 2026-02-30 to 2026-03-02; reject what did not survive.
    if not t or os.date("%Y-%m-%d", t) ~= date then
      return nil, "Daily note date must use YYYY-MM-DD"
    end
  end

  local key = os.date("%Y-%m-%d", t)
  return {
    key = key,
    stem = os.date("%Y%m%d", t),
    title = "Daily Note - " .. key,
    start = key,
    finish = key,
    previous = os.date("%Y%m%d", t - DAY),
    next = os.date("%Y%m%d", t + DAY),
  }
end

---Resolve a weekly period.
---@param week string|nil YYYY-Www (e.g. 2026-W39); nil or "" for this week
---@return notes.PeriodicSpec|nil spec
---@return string|nil err
function M.week(week)
  week = week and week:match("^%s*(.-)%s*$") or ""
  local year, number
  if week == "" then
    local now = os.date("*t")
    year, number = M.iso_week(noon(now.year, now.month, now.day))
  else
    local y, w = week:match("^(%d%d%d%d)%-[Ww](%d%d)$")
    year, number = tonumber(y), tonumber(w)
    if not year or number < 1 or number > M.weeks_in_year(year) then
      return nil, "Weekly note must use YYYY-Www with an existing ISO week (e.g. 2026-W39)"
    end
  end

  local monday = week_monday(year, number)
  local prev_year, prev_week = M.iso_week(monday - 7 * DAY)
  local next_year, next_week = M.iso_week(monday + 7 * DAY)
  local key = string.format("%04d-W%02d", year, number)
  return {
    key = key,
    stem = week_stem(year, number),
    title = "Weekly Review - " .. key,
    start = os.date("%Y-%m-%d", monday),
    finish = os.date("%Y-%m-%d", monday + 6 * DAY),
    previous = week_stem(prev_year, prev_week),
    next = week_stem(next_year, next_week),
  }
end

---Resolve a monthly period.
---@param month string|nil YYYY-MM; nil or "" for this month
---@return notes.PeriodicSpec|nil spec
---@return string|nil err
function M.month(month)
  month = month and month:match("^%s*(.-)%s*$") or ""
  local year, number
  if month == "" then
    local now = os.date("*t")
    year, number = now.year, now.month
  else
    local y, m = month:match("^(%d%d%d%d)%-(%d%d)$")
    year, number = tonumber(y), tonumber(m)
    if not year or number < 1 or number > 12 then
      return nil, "Monthly note must use YYYY-MM"
    end
  end

  -- Day 0 of the following month normalises to the last day of this one.
  local last = noon(year, number + 1, 0)
  local prev_year, prev_month = year, number - 1
  if prev_month == 0 then
    prev_year, prev_month = year - 1, 12
  end
  local next_year, next_month = year, number + 1
  if next_month == 13 then
    next_year, next_month = year + 1, 1
  end

  local key = string.format("%04d-%02d", year, number)
  return {
    key = key,
    stem = month_stem(year, number),
    title = "Monthly Review - " .. key,
    start = key .. "-01",
    finish = os.date("%Y-%m-%d", last),
    previous = month_stem(prev_year, prev_month),
    next = month_stem(next_year, next_month),
  }
end

return M
