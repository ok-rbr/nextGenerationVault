-- notes/health.lua
-- Health & workout stats for VoidDash
-- Sources:
--   1. Primary: `wger` CLI or REST API (if configured via WGER_TOKEN env var)
--   2. Fallback: markdown notes in the vault with tags containing "workout" or "training"
--      Frontmatter fields read: date, training_type, muscle_groups (list), sets, reps, duration_min

local M = {}

local vault_index = require("notes.vault_index")

-- ============================================================================
-- CORE HELPERS
-- ============================================================================

---Scan vault for notes tagged "workout" or "training"
---@return table[] Array of frontmatter tables sorted by date desc
local function scan_workout_notes()
  local workouts = {}
  for _, note in ipairs(vault_index.scan()) do
    local fm = note.frontmatter
    local tags = fm.tags or {}
    if type(tags) == "string" then
      tags = { tags }
    end

    local is_workout = false
    for _, tag in ipairs(tags) do
      local normalized = tostring(tag):lower()
      if normalized == "workout" or normalized == "training" or normalized == "fitness" then
        is_workout = true
        break
      end
    end

    local category = tostring(fm.category or ""):lower()
    if category == "health" or category == "fitness" or category == "workout" then
      is_workout = true
    end

    if is_workout then
      table.insert(workouts, { path = note.path, fm = fm })
    end
  end

  table.sort(workouts, function(a, b)
    local date_a = (a.fm.date or a.fm.created or ""):sub(1, 10)
    local date_b = (b.fm.date or b.fm.created or ""):sub(1, 10)
    return date_a > date_b
  end)

  return workouts
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

local function summary_for(workouts)
  if #workouts == 0 then
    return "🏋️ Workout — no entries found"
  end

  local last = workouts[1].fm
  local date = (last.date or last.created or ""):sub(1, 10)
  local workout_type = last.training_type or last.title or "Training"
  return string.format("🏋️ Last workout — %s (%s)", workout_type, date)
end

local function detail_for(workouts)
  if #workouts == 0 then
    return { "  No workout entries found in the vault" }
  end

  local last = workouts[1]
  local fm = last.fm
  local lines = {}
  local date = (fm.date or fm.created or ""):sub(1, 10)
  local workout_type = fm.training_type or fm.title or "Training"
  local duration = fm.duration_min and (fm.duration_min .. " min") or "?"

  table.insert(lines, string.format("  Date:       %s", date))
  table.insert(lines, string.format("  Type:       %s", workout_type))
  table.insert(lines, string.format("  Duration:   %s", duration))

  if fm.muscle_groups then
    if type(fm.muscle_groups) == "table" then
      table.insert(lines, "  Muscles:    " .. table.concat(fm.muscle_groups, ", "))
    else
      table.insert(lines, "  Muscles:    " .. tostring(fm.muscle_groups))
    end
  end
  if fm.sets then
    table.insert(lines, string.format("  Sets:       %s", fm.sets))
  end
  if fm.reps then
    table.insert(lines, string.format("  Reps:       %s", fm.reps))
  end
  table.insert(lines, string.format("  File:       %s", vim.fn.fnamemodify(last.path, ":t")))
  return lines
end

local function stats_for(workouts)
  local today = os.date("%Y-%m-%d")
  local month = today:sub(1, 7)
  local timestamp = os.time()
  local weekday = tonumber(os.date("%w", timestamp))
  local iso_weekday = weekday == 0 and 7 or weekday
  local monday = os.date("%Y-%m-%d", timestamp - (iso_weekday - 1) * 86400)

  local week_count = 0
  local month_count = 0
  for _, workout in ipairs(workouts) do
    local date = (workout.fm.date or workout.fm.created or ""):sub(1, 10)
    if date >= monday then
      week_count = week_count + 1
    end
    if date:sub(1, 7) == month then
      month_count = month_count + 1
    end
  end

  return { this_week = week_count, this_month = month_count, total = #workouts }
end

---Return a one-line summary for the dashboard header.
---@return string
function M.summary()
  return summary_for(scan_workout_notes())
end

---Return detailed info about the last workout.
---@return string[]
function M.last_workout_detail()
  return detail_for(scan_workout_notes())
end

---Return stats: total workouts this week / this month.
---@return table {this_week: number, this_month: number, total: number}
function M.stats()
  return stats_for(scan_workout_notes())
end

---Return every dashboard health value from one vault scan.
---@return table {summary: string, lines: string[], stats: table}
function M.dashboard_data()
  local workouts = scan_workout_notes()
  return {
    summary = summary_for(workouts),
    lines = detail_for(workouts),
    stats = stats_for(workouts),
  }
end

---Open a Telescope picker with all workout notes
function M.telescope_pick()
  local picker = require("notes.picker")

  local workouts = scan_workout_notes()

  if #workouts == 0 then
    vim.notify("No workout notes found in vault", vim.log.levels.INFO)
    return
  end

  local items = {}
  for _, w in ipairs(workouts) do
    local date = (w.fm.date or w.fm.created or ""):sub(1, 10)
    local type_ = w.fm.training_type or w.fm.title or "Training"
    local display = string.format("%s  %s", date, type_)
    table.insert(items, { display = display, path = w.path })
  end

  picker.pick(items, { prompt_title = "Health — Workout Notes" })
end

-- ============================================================================
-- COMMAND REGISTRATION
-- ============================================================================

function M.setup()
  vim.api.nvim_create_user_command("HealthPick", M.telescope_pick, {
    desc = "Browse workout notes (Telescope)",
  })

  vim.keymap.set(
    "n",
    "<leader>nwh",
    M.telescope_pick,
    { silent = true, desc = "[N]ote [W]orkflow [H]ealth / workouts" }
  )
end

return M
