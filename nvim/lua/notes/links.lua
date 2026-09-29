-- notes/links.lua
-- Native vault-link layer: wiki-link creation, following, backlinks, outgoing
-- links, quick switch, vault search, clipboard images and link rewriting when a
-- note moves. Replaces obsidian.nvim (docs/ADR-005, layer 3).
--
-- Link contract, shared with the Obsidian desktop app and Marksman:
--   * Generated links always target the note id, which equals the filename
--     stem: `[[id]]` or `[[id|Label]]`. Obsidian and Marksman resolve a
--     wiki-link by filename, so a link written against an alias would only
--     work here.
--   * The resolver is more lenient than that when reading: it accepts an id,
--     a filename stem, a vault-relative path (with or without `.md`) and,
--     as a last resort, a title or alias. Heading (`#Heading`, `#heading-slug`)
--     and block (`#^block`) fragments are honoured.
--   * Links inside fenced code blocks are text, not links: they are never
--     followed as backlinks and never rewritten.

local utils = require("notes.utils")
local frontmatter = require("notes.frontmatter")

local M = {}

local WIKI_LINK = "(!?)%[%[([^%]]-)%]%]"
local MARKDOWN_LINK = "(!?)%[([^%]]*)%]%(([^%)]*)%)"

-- ============================================================================
-- HELPERS
-- ============================================================================

local function normalize_path(path)
  local normalized = vim.fs.normalize(vim.fn.fnamemodify(path, ":p")):gsub("\\", "/"):gsub("/+$", "")
  return normalized
end

---Case-insensitive comparison key for a link target.
local function target_key(target)
  local key = vim.trim(target or ""):gsub("\\", "/"):gsub("^%./", ""):gsub("%.md$", ""):lower()
  return key
end

local function config()
  return require("notes.init").config
end

local function is_url(target)
  return target:match("^%a[%w+.-]*:") ~= nil
end

---Split a wiki-link body `target#fragment|label` into its parts.
---@param body string
---@return string target, string fragment, string|nil label
local function split_wiki_body(body)
  local destination, label = body:match("^([^|]*)|(.*)$")
  destination = destination or body
  local target, fragment = destination:match("^([^#]*)#(.*)$")
  return vim.trim(target or destination), vim.trim(fragment or ""), label
end

---Decode `%20` style escapes that Markdown links often carry.
local function url_decode(value)
  local decoded = value:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end)
  return decoded
end

---Iterate over the lines of a document that are outside fenced code blocks.
---@param lines string[]
---@return fun(): integer|nil, string|nil
local function prose_lines(lines)
  local index, fence = 0, nil
  return function()
    while true do
      index = index + 1
      local line = lines[index]
      if line == nil then
        return nil
      end
      local marker = line:match("^%s*(```+)") or line:match("^%s*(~~~+)")
      if fence then
        if marker and marker:sub(1, 1) == fence:sub(1, 1) and #marker >= #fence then
          fence = nil
        end
      elseif marker then
        fence = marker
      else
        return index, line
      end
    end
  end
end

local function buffer_for(path)
  local wanted = normalize_path(path)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and normalize_path(vim.api.nvim_buf_get_name(bufnr)) == wanted then
      return bufnr
    end
  end
end

---Read a note from its loaded buffer (unsaved edits included) or from disk.
local function note_lines(path)
  local bufnr = buffer_for(path)
  if bufnr then
    return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  end
  local ok, lines = pcall(vim.fn.readfile, path)
  return ok and lines or {}
end

local function current_note_path()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" or not utils.in_notebook(path) then
    return nil
  end
  return path
end

---Show a list of locations in the shared picker, or in the quickfix list when
---Telescope is not installed.
local function show_locations(items, opts)
  if #items == 0 then
    vim.notify(opts.empty_message, vim.log.levels.INFO)
    return
  end
  if pcall(require, "telescope") then
    require("notes.picker").pick(items, {
      prompt_title = opts.title,
      display_fn = function(item)
        return item.display
      end,
      ordinal_fn = function(item)
        return item.display
      end,
    })
    return
  end
  vim.fn.setqflist({}, " ", {
    title = opts.title,
    items = vim.tbl_map(function(item)
      return { filename = item.path, lnum = item.lnum or 1, col = item.col or 1, text = item.text or item.display }
    end, items),
  })
  vim.cmd("copen")
end

-- ============================================================================
-- VAULT INDEX
-- ============================================================================

local function note_title(metadata, stem)
  local aliases = metadata.aliases
  if type(aliases) == "string" and aliases ~= "" then
    return aliases
  end
  if type(aliases) == "table" and type(aliases[1]) == "string" and aliases[1] ~= "" then
    return aliases[1]
  end
  return type(metadata.title) == "string" and metadata.title ~= "" and metadata.title or stem
end

local function note_aliases(metadata)
  local aliases = {}
  local raw = metadata.aliases
  if type(raw) == "string" then
    raw = { raw }
  end
  for _, alias in ipairs(type(raw) == "table" and raw or {}) do
    if type(alias) == "string" and alias ~= "" then
      aliases[#aliases + 1] = alias
    end
  end
  if type(metadata.title) == "string" and metadata.title ~= "" then
    aliases[#aliases + 1] = metadata.title
  end
  return aliases
end

---Kept for callers that invalidate every notes cache; the index itself lives in
---notes.vault_index.
function M.invalidate()
  require("notes.vault_index").invalidate()
end

---Return every Markdown note in the vault, templates excluded, sorted by title.
---@param force? boolean Bypass the short-lived index cache
---@return table[] Array of {path, relative_path, stem, id, title, aliases}
function M.scan(force)
  local root = utils.get_notebook_root()
  local notes = {}
  for _, entry in ipairs(require("notes.vault_index").scan({ force = force, include_plain = true })) do
    local relative_path = utils.relative_path(root, entry.path)
    if relative_path then
      local metadata = entry.frontmatter or {}
      local stem = vim.fn.fnamemodify(entry.path, ":t:r")
      notes[#notes + 1] = {
        path = entry.path,
        relative_path = relative_path,
        stem = stem,
        id = type(metadata.id) == "string" and metadata.id ~= "" and metadata.id or stem,
        title = note_title(metadata, stem),
        aliases = note_aliases(metadata),
      }
    end
  end

  table.sort(notes, function(a, b)
    local left, right = a.title:lower(), b.title:lower()
    if left == right then
      return a.relative_path:lower() < b.relative_path:lower()
    end
    return left < right
  end)
  return notes
end

---The set of target keys under which a note can be linked.
---@param note table An entry from M.scan()
---@param include_aliases boolean
---@return table<string, boolean>
local function note_keys(note, include_aliases)
  local keys = {
    [target_key(note.id)] = true,
    [target_key(note.stem)] = true,
    [target_key(note.relative_path)] = true,
  }
  if include_aliases then
    for _, alias in ipairs(note.aliases or {}) do
      keys[target_key(alias)] = true
    end
  end
  return keys
end

---Resolve an id, filename stem, vault-relative path, or note alias.
---Ids, stems and paths win over aliases, so a title never shadows a file.
---@param target string
---@return table|nil note, table[] matches
function M.resolve(target)
  local key = target_key(target)
  if key == "" then
    return nil, {}
  end

  local primary, secondary = {}, {}
  for _, note in ipairs(M.scan()) do
    if note_keys(note, false)[key] then
      primary[#primary + 1] = note
    elseif note_keys(note, true)[key] then
      secondary[#secondary + 1] = note
    end
  end

  local matches = #primary > 0 and primary or secondary
  return #matches == 1 and matches[1] or nil, matches
end

---Look up the scan entry for an absolute note path.
local function note_for_path(path)
  local wanted = normalize_path(path)
  for _, note in ipairs(M.scan()) do
    if normalize_path(note.path) == wanted then
      return note
    end
  end
end

-- ============================================================================
-- LINK UNDER THE CURSOR
-- ============================================================================

---Return the link that contains the cursor, if any.
---@return table|nil {kind = "wiki"|"markdown", target, fragment, label, embed, start_col, end_col}
function M.link_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local column = vim.api.nvim_win_get_cursor(0)[2] + 1

  local search_from = 1
  while true do
    local first, last, bang, body = line:find(WIKI_LINK, search_from)
    if not first then
      break
    end
    if column >= first and column <= last then
      local target, fragment, label = split_wiki_body(body)
      return {
        kind = "wiki",
        target = target,
        fragment = fragment,
        label = label,
        embed = bang == "!",
        start_col = first,
        end_col = last,
      }
    end
    search_from = last + 1
  end

  search_from = 1
  while true do
    local first, last, bang, label, destination = line:find(MARKDOWN_LINK, search_from)
    if not first then
      break
    end
    if column >= first and column <= last then
      destination = vim.trim(destination):gsub('%s+".*"$', "")
      destination = destination:match("^<(.*)>$") or destination
      local target, fragment = destination:match("^([^#]*)#(.*)$")
      return {
        kind = "markdown",
        target = target or destination,
        fragment = fragment or "",
        label = label,
        embed = bang == "!",
        start_col = first,
        end_col = last,
      }
    end
    search_from = last + 1
  end
end

local function heading_key(value)
  local key = vim.trim((value or ""):lower():gsub("[%p]", " ")):gsub("%s+", "-")
  return key
end

---Move the cursor to a heading (`Heading`, `heading-slug`) or block (`^id`).
local function jump_to_fragment(fragment)
  if not fragment or fragment == "" then
    return
  end
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local block = fragment:match("^%^(.+)$")
  if block then
    for lnum, line in ipairs(lines) do
      if line:match("%^" .. vim.pesc(block) .. "%s*$") then
        vim.api.nvim_win_set_cursor(0, { lnum, 0 })
        return
      end
    end
    return
  end

  local wanted = heading_key(url_decode(fragment))
  for lnum, line in prose_lines(lines) do
    local title = line:match("^#+%s+(.-)%s*#*%s*$")
    if title and heading_key(title) == wanted then
      vim.api.nvim_win_set_cursor(0, { lnum, 0 })
      return
    end
  end
end

local function open_path(path, fragment)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  jump_to_fragment(fragment)
end

-- ============================================================================
-- NOTE CREATION FROM A LINK
-- ============================================================================

---Replace columns [start_col, end_col] (1-based, inclusive) of a line if it
---still holds `expected`, so an edit made while a picker was open is not
---overwritten.
local function replace_span(bufnr, lnum, start_col, end_col, expected, replacement)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
  if line:sub(start_col, end_col) ~= expected then
    return false
  end
  vim.api.nvim_buf_set_text(bufnr, lnum - 1, start_col - 1, lnum - 1, end_col, { replacement })
  return true
end

---Create a note titled `title` from a template, then call `on_created(note)`
---with its scan entry.
local function create_note(title, on_created)
  require("notes.templates").pick_template({ title = title }, function(path)
    M.invalidate()
    local note = note_for_path(path)
      or { path = path, stem = vim.fn.fnamemodify(path, ":t:r"), id = vim.fn.fnamemodify(path, ":t:r"), title = title }
    on_created(note)
  end)
end

-- ============================================================================
-- FOLLOW
-- ============================================================================

---Follow the link under the cursor: wiki-links and relative Markdown links
---open the note (and jump to the heading or block), URLs open in the system
---handler. A wiki-link whose target does not exist offers to create the note
---from a template and repoints the link at the new note's id.
---@return boolean handled
function M.follow()
  local link = M.link_at_cursor()
  if not link then
    vim.notify("No link under the cursor", vim.log.levels.WARN)
    return false
  end

  if link.target == "" then
    jump_to_fragment(link.fragment)
    return true
  end

  if link.kind == "markdown" then
    if is_url(link.target) then
      vim.ui.open(link.target)
      return true
    end
    local base = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
    local path = vim.fn.fnamemodify(utils.path_join(base, url_decode(link.target)), ":p")
    if vim.fn.filereadable(path) == 0 and vim.fn.filereadable(path .. ".md") == 1 then
      path = path .. ".md"
    end
    if vim.fn.filereadable(path) == 1 then
      open_path(path, link.fragment)
      return true
    end
    vim.notify("Link target not found: " .. link.target, vim.log.levels.WARN)
    return false
  end

  if not utils.in_notebook(vim.api.nvim_buf_get_name(0)) then
    vim.notify("Wiki-links resolve only inside the configured vault", vim.log.levels.WARN)
    return false
  end

  local note, matches = M.resolve(link.target)
  if note then
    open_path(note.path, link.fragment)
    return true
  end

  if #matches > 1 then
    vim.ui.select(matches, {
      prompt = "Several notes match " .. link.target,
      format_item = function(item)
        return item.title .. " — " .. item.relative_path
      end,
    }, function(choice)
      if choice then
        open_path(choice.path, link.fragment)
      end
    end)
    return true
  end

  -- Attachments and other non-note files are linked by file name.
  if link.target:find("%.[%w]+$") and not link.target:lower():match("%.md$") then
    local found = vim.fs.find(vim.fs.basename(link.target), { path = utils.get_notebook_root(), limit = 1 })[1]
    if found then
      vim.ui.open(found)
      return true
    end
  end

  if not utils.confirm(string.format("Note '%s' does not exist. Create it?", link.target)) then
    return false
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local original = vim.api.nvim_get_current_line():sub(link.start_col, link.end_col)
  create_note(link.target, function(created)
    local label = link.label or link.target
    local fragment = link.fragment ~= "" and ("#" .. link.fragment) or ""
    local replacement = (link.embed and "!" or "") .. "[[" .. created.id .. fragment .. "|" .. label .. "]]"
    if created.id ~= link.target then
      replace_span(bufnr, lnum, link.start_col, link.end_col, original, replacement)
    end
  end)
  return true
end

-- ============================================================================
-- INSERT
-- ============================================================================

local function clean_label(value)
  local label = vim.trim((value or ""):gsub("[%c\r\n]+", " "):gsub("|", ""):gsub("%]%]", ""))
  return label
end

---Build `[[id]]` or `[[id|label]]` for a note.
function M.format_link(note, label)
  local target = note.id or note.stem
  label = clean_label(label)
  if label == "" or label == target then
    return "[[" .. target .. "]]"
  end
  return "[[" .. target .. "|" .. label .. "]]"
end

---Capture a visual selection from two `getpos()` results.
---@param first integer[] getpos() of one end
---@param last integer[] getpos() of the other end
---@param mode string "v" or "V" (blockwise is not supported)
---@return table|nil
local function capture_selection(first, last, mode)
  if mode ~= "v" and mode ~= "V" then
    return nil
  end
  if first[2] > last[2] or (first[2] == last[2] and first[3] > last[3]) then
    first, last = last, first
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local last_line = vim.api.nvim_buf_get_lines(bufnr, last[2] - 1, last[2], false)[1] or ""
  local end_col = math.min(last[3], #last_line) -- byte where the last character starts
  if mode == "v" and end_col > 0 then
    -- Extend to the end of a multi-byte last character.
    local char = vim.fn.strcharpart(last_line:sub(end_col), 0, 1)
    end_col = end_col + math.max(#char, 1) - 1
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, first[2] - 1, last[2], false)
  if mode == "v" then
    -- Trim the last line first: on a single-line selection both ends apply to
    -- the same string and the end column is measured from its start.
    lines[#lines] = lines[#lines]:sub(1, end_col)
    lines[1] = lines[1]:sub(first[3])
  end

  local text = clean_label(table.concat(lines, " "))
  if text == "" then
    return nil
  end
  return { mode = mode, text = text, first_row = first[2], first_col = first[3], last_row = last[2], last_col = end_col }
end

---The active visual selection (from a keymap in visual mode).
local function active_selection()
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" then
    return nil
  end
  local selection = capture_selection(vim.fn.getpos("v"), vim.fn.getpos("."), mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  return selection
end

---The last visual selection (from `:'<,'>NoteLink`).
local function marked_selection()
  return capture_selection(vim.fn.getpos("'<"), vim.fn.getpos("'>"), vim.fn.visualmode())
end

---Where a link goes when nothing is selected: after the character under the
---cursor in Normal mode (like `a`), at the cursor in Insert mode.
local function insertion_point(bufnr)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""
  if not vim.fn.mode():match("^i") and #line > 0 then
    local char = vim.fn.strcharpart(line:sub(col + 1), 0, 1)
    col = math.min(col + #char, #line)
  end
  return row, col
end

local function put_link(bufnr, selection, point, text)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  local row, col
  if not selection then
    row, col = point[1], point[2]
    vim.api.nvim_buf_set_text(bufnr, row - 1, col, row - 1, col, { text })
  elseif selection.mode == "V" then
    row, col = selection.first_row, 0
    vim.api.nvim_buf_set_lines(bufnr, selection.first_row - 1, selection.last_row, false, { text })
  else
    row, col = selection.first_row, selection.first_col - 1
    vim.api.nvim_buf_set_text(bufnr, row - 1, col, selection.last_row - 1, selection.last_col, { text })
  end
  local winid = vim.fn.bufwinid(bufnr)
  if winid ~= -1 then
    vim.api.nvim_win_set_cursor(winid, { row, math.max(col + #text - 1, 0) })
  end
end

---Pick a vault note and insert a wiki-link to it. A visual selection becomes
---the link label; without one the note's title is used.
---@param opts? table Command opts from nvim_create_user_command, or nil from a keymap
function M.insert(opts)
  local bufnr = vim.api.nvim_get_current_buf()
  if not current_note_path() then
    vim.notify("Wiki-links can only be inserted inside the configured vault", vim.log.levels.WARN)
    return
  end

  local selection
  if type(opts) == "table" and (opts.range or 0) > 0 then
    selection = marked_selection()
  else
    selection = active_selection()
  end
  local point = { insertion_point(bufnr) }

  require("notes.picker").pick(M.scan(), {
    prompt_title = selection and ("Link “" .. selection.text .. "” to") or "Insert wiki-link",
    empty_message = "No notes found in the configured vault",
    display_fn = function(note)
      return note.title .. " — " .. note.relative_path
    end,
    ordinal_fn = function(note)
      return note.title .. " " .. note.id .. " " .. table.concat(note.aliases, " ") .. " " .. note.relative_path
    end,
    on_select = function(note)
      put_link(bufnr, selection, point, M.format_link(note, selection and selection.text or note.title))
    end,
  })
end

---Turn the visual selection into a link to a new note titled after it.
function M.insert_new()
  local bufnr = vim.api.nvim_get_current_buf()
  if not current_note_path() then
    vim.notify("Wiki-links can only be inserted inside the configured vault", vim.log.levels.WARN)
    return
  end
  local selection = active_selection() or marked_selection()
  if not selection then
    vim.notify("Select the text that should become the new note's title", vim.log.levels.WARN)
    return
  end
  create_note(selection.text, function(note)
    put_link(bufnr, selection, nil, M.format_link(note, selection.text))
  end)
end

-- ============================================================================
-- BACKLINKS AND OUTGOING LINKS
-- ============================================================================

---Collect every link in the vault that points at `path`.
---@param path string Absolute path of the target note
---@return table[] Array of {path, lnum, col, text, display}
function M.backlinks(path)
  local root = utils.get_notebook_root()
  local target = note_for_path(path)
  if not target then
    return {}
  end
  local keys = note_keys(target, true)
  local target_path = normalize_path(path)

  local results = {}
  for _, note in ipairs(M.scan()) do
    if normalize_path(note.path) ~= target_path then
      local source_dir = vim.fn.fnamemodify(note.path, ":h")
      for lnum, line in prose_lines(note_lines(note.path)) do
        local hit
        for col, _, body in line:gmatch("()" .. WIKI_LINK) do
          local link_target = split_wiki_body(body)
          if link_target ~= "" and keys[target_key(link_target)] then
            hit = hit or col
          end
        end
        for col, _, _, destination in line:gmatch("()" .. MARKDOWN_LINK) do
          local link_path = (destination:match("^<(.*)>$") or destination):match("^([^#]*)") or ""
          if link_path ~= "" and not is_url(link_path) then
            local absolute = vim.fn.fnamemodify(utils.path_join(source_dir, url_decode(link_path)), ":p")
            local relative = utils.relative_path(root, absolute)
            if relative and keys[target_key(relative)] then
              hit = hit or col
            end
          end
        end
        if hit then
          results[#results + 1] = {
            path = note.path,
            lnum = lnum,
            col = hit,
            text = vim.trim(line),
            display = string.format("%s:%d  %s", note.title, lnum, vim.trim(line)),
          }
        end
      end
    end
  end
  return results
end

---Show the notes that link to the current note.
function M.show_backlinks()
  local path = current_note_path()
  if not path then
    vim.notify("Backlinks are only available for notes inside the configured vault", vim.log.levels.WARN)
    return
  end
  show_locations(M.backlinks(path), {
    title = "Backlinks to " .. vim.fn.fnamemodify(path, ":t:r"),
    empty_message = "No backlinks to this note",
  })
end

---Collect the wiki-links in the current buffer with their resolution status.
---@return table[] Array of {path?, lnum, col, target, resolved, display}
function M.outgoing_links()
  local results = {}
  local buffer_path = vim.api.nvim_buf_get_name(0)
  for lnum, line in prose_lines(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    for col, _, body in line:gmatch("()" .. WIKI_LINK) do
      local target, fragment = split_wiki_body(body)
      local note, matches = M.resolve(target)
      local status = note and "→ " .. note.relative_path
        or (#matches > 1 and "⚠ ambiguous" or (target == "" and "↳ this note" or "✗ missing"))
      results[#results + 1] = {
        path = note and note.path or buffer_path,
        lnum = note and 1 or lnum,
        col = col,
        target = target,
        fragment = fragment,
        resolved = note ~= nil or target == "",
        display = string.format("%d  [[%s]]  %s", lnum, body, status),
      }
    end
  end
  return results
end

---Show the links of the current note; picking one opens its target.
function M.show_outgoing_links()
  if not current_note_path() then
    vim.notify("Links are only listed for notes inside the configured vault", vim.log.levels.WARN)
    return
  end
  show_locations(M.outgoing_links(), { title = "Links in this note", empty_message = "No wiki-links in this note" })
end

-- ============================================================================
-- NAVIGATION AND SEARCH
-- ============================================================================

---Fuzzy-find a note by title, alias, id or path and open it.
function M.quick_switch()
  require("notes.picker").pick(M.scan(), {
    prompt_title = "Notes",
    empty_message = "No notes found in the configured vault",
    display_fn = function(note)
      return note.title .. " — " .. note.relative_path
    end,
    ordinal_fn = function(note)
      return note.title .. " " .. note.id .. " " .. table.concat(note.aliases, " ") .. " " .. note.relative_path
    end,
  })
end

---Full-text search across the vault.
function M.search()
  local root = utils.get_notebook_root()
  local ok, builtin = pcall(require, "telescope.builtin")
  if ok then
    builtin.live_grep({ cwd = root, prompt_title = "Search vault", glob_pattern = "*.md" })
    return
  end
  local query = utils.prompt_text("Search vault")
  if not query or query == "" then
    return
  end
  vim.cmd(
    "silent! vimgrep /" .. vim.fn.escape(query, "/") .. "/j " .. vim.fn.fnameescape(utils.path_join(root, "**/*.md"))
  )
  vim.cmd("copen")
end

---Open the current note in the Obsidian desktop app.
function M.open_in_app()
  local path = current_note_path()
  if not path then
    vim.notify("Only notes inside the configured vault can be opened in Obsidian", vim.log.levels.WARN)
    return
  end
  local root = utils.get_notebook_root()
  local function encode(value)
    local encoded = value:gsub("[^%w%-_%.~/]", function(char)
      return string.format("%%%02X", char:byte())
    end)
    return encoded
  end
  local vault = vim.fn.fnamemodify(normalize_path(root), ":t")
  local file = (utils.relative_path(root, path) or ""):gsub("%.md$", "")
  vim.ui.open("obsidian://open?vault=" .. encode(vault) .. "&file=" .. encode(file))
end

-- ============================================================================
-- CLIPBOARD IMAGES
-- ============================================================================

---Return a command that prints the clipboard image as PNG, or nil.
local function clipboard_image_command(target)
  if vim.fn.has("win32") == 1 then
    local script = "Add-Type -AssemblyName System.Windows.Forms; $i = [System.Windows.Forms.Clipboard]::GetImage(); "
      .. "if ($null -eq $i) { exit 1 }; $i.Save('"
      .. target:gsub("'", "''")
      .. "', [System.Drawing.Imaging.ImageFormat]::Png)"
    return { "powershell", "-NoProfile", "-Command", script }, false
  end
  if vim.fn.has("mac") == 1 and vim.fn.executable("pngpaste") == 1 then
    return { "pngpaste", target }, false
  end
  if os.getenv("WAYLAND_DISPLAY") and vim.fn.executable("wl-paste") == 1 then
    return { "wl-paste", "--no-newline", "--type", "image/png" }, true
  end
  if vim.fn.executable("xclip") == 1 then
    return { "xclip", "-selection", "clipboard", "-target", "image/png", "-out" }, true
  end
end

---Save the clipboard image into the vault's attachment folder (shared with
---the Obsidian app, see dot_config/obsidian/app.json) and embed it as
---`![[name.png]]` at the cursor.
function M.paste_image()
  local bufnr = vim.api.nvim_get_current_buf()
  if not current_note_path() then
    vim.notify("Images can only be pasted into notes inside the configured vault", vim.log.levels.WARN)
    return
  end

  local name = utils.prompt_text("Image name", os.date("%Y%m%d_%H%M%S"))
  if not name or name == "" then
    return
  end
  name = utils.slugify(name:gsub("%.png$", ""), { separator = "_" })
  local directory = utils.path_join(utils.get_notebook_root(), config().directories.attachments)
  local target = utils.path_join(directory, name .. ".png")
  if utils.path_is_taken(target) then
    vim.notify("Attachment already exists: " .. target, vim.log.levels.ERROR)
    return
  end

  local command, to_stdout = clipboard_image_command(target)
  if not command then
    vim.notify("No clipboard tool found (wl-paste, xclip, pngpaste or PowerShell)", vim.log.levels.ERROR)
    return
  end
  utils.ensure_dir(directory)
  local result = vim.system(command, { text = false }):wait()
  if result.code ~= 0 or (to_stdout and (result.stdout or "") == "") then
    vim.notify("The clipboard does not hold an image", vim.log.levels.WARN)
    return
  end
  if to_stdout then
    local file = io.open(target, "wb")
    if not file then
      vim.notify("Cannot write " .. target, vim.log.levels.ERROR)
      return
    end
    file:write(result.stdout)
    file:close()
  end

  put_link(bufnr, nil, { insertion_point(bufnr) }, "![[" .. name .. ".png]]")
end

-- ============================================================================
-- LINK REWRITING ON MOVE
-- ============================================================================

local function target_set(targets)
  local result = {}
  for _, target in ipairs(targets or {}) do
    result[target_key(target)] = true
  end
  return result
end

---Apply `rewrite(line)` to every line outside fenced code blocks.
local function map_prose(content, rewrite)
  local lines = vim.split(content, "\n", { plain = true })
  for index, line in prose_lines(lines) do
    lines[index] = rewrite(line)
  end
  return table.concat(lines, "\n")
end

---Rewrite wiki-link targets while preserving fragments, labels and embeds.
---@param content string
---@param old_targets string[]
---@param new_target string
---@return string
function M.rewrite_content(content, old_targets, new_target)
  local targets = target_set(old_targets)
  return map_prose(content, function(line)
    local rewritten = line:gsub("%[%[([^%]]-)%]%]", function(body)
      local destination, label = body:match("^([^|]*)(.*)$")
      local base, fragment = destination:match("^([^#]*)(.*)$")
      if targets[target_key(base)] then
        return "[[" .. new_target .. fragment .. label .. "]]"
      end
    end)
    return rewritten
  end)
end

---Relative path from the directory of `source` to `target`, both absolute.
local function relative_link(root, source, target)
  local source_dir = utils.relative_path(root, vim.fn.fnamemodify(source, ":h")) or ""
  local target_relative = utils.relative_path(root, target)
  if not target_relative then
    return nil
  end

  local source_parts = vim.split(source_dir, "/", { trimempty = true })
  local target_parts = vim.split(target_relative, "/", { trimempty = true })
  local common = 0
  while source_parts[common + 1] and source_parts[common + 1] == target_parts[common + 1] do
    common = common + 1
  end

  local parts = {}
  for _ = common + 1, #source_parts do
    parts[#parts + 1] = ".."
  end
  for index = common + 1, #target_parts do
    parts[#parts + 1] = target_parts[index]
  end
  return table.concat(parts, "/")
end

---Rewrite relative Markdown links `[label](path.md#fragment)` that point at the
---moved note. `source_path` is where the linking note lives before the move;
---when that note is the moved note itself its links are recomputed from the
---new location.
local function rewrite_markdown_links(content, root, source_path, moved_from, new_path, targets)
  local source_dir = vim.fn.fnamemodify(source_path, ":h")
  local effective_source = normalize_path(source_path) == normalize_path(moved_from) and new_path or source_path
  return map_prose(content, function(line)
    local rewritten = line:gsub("(%[[^%]]*%]%()([^%)]*)(%))", function(open, raw, close)
      local angled = raw:match("^<(.*)>$")
      local destination = angled or raw
      local link_path, fragment = destination:match("^([^#]*)(.*)$")
      if link_path == "" or is_url(link_path) or link_path:sub(1, 1) == "/" then
        return nil
      end
      local absolute = vim.fn.fnamemodify(utils.path_join(source_dir, url_decode(link_path)), ":p")
      local relative = utils.relative_path(root, absolute)
      if not (relative and targets[target_key(relative)]) then
        return nil
      end
      local new_link = relative_link(root, effective_source, new_path)
      if not new_link then
        return nil
      end
      if not link_path:lower():match("%.md$") then
        new_link = new_link:gsub("%.md$", "")
      end
      if angled then
        new_link = "<" .. new_link .. ">"
      elseif link_path:find("%%20") then
        new_link = new_link:gsub(" ", "%%20")
      end
      return open .. new_link .. fragment .. close
    end)
    return rewritten
  end)
end

local function read_file(path)
  local file, err = io.open(path, "rb")
  if not file then
    return nil, err
  end
  local content = file:read("*a")
  file:close()
  return content
end

local function write_file(path, content)
  local file, err = io.open(path, "wb")
  if not file then
    return false, err
  end
  local ok, write_err = file:write(content)
  file:close()
  if not ok then
    return false, write_err
  end
  return true
end

local function buffer_content(bufnr)
  local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
  if vim.bo[bufnr].endofline or vim.bo[bufnr].fixendofline then
    content = content .. "\n"
  end
  if vim.bo[bufnr].fileformat == "dos" then
    content = content:gsub("\n", "\r\n")
  end
  return content
end

local function set_buffer_content(bufnr, content)
  local normalized = content:gsub("\r\n", "\n"):gsub("\n$", "")
  local view = vim.fn.bufwinid(bufnr) ~= -1 and vim.api.nvim_win_call(vim.fn.bufwinid(bufnr), vim.fn.winsaveview)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(normalized, "\n", { plain = true }))
  vim.bo[bufnr].modified = false
  if view then
    vim.api.nvim_win_call(vim.fn.bufwinid(bufnr), function()
      vim.fn.winrestview(view)
    end)
  end
end

---Point a loaded buffer at the file's new location. The rename is followed by
---a write so the buffer is "edited" again (a bare rename leaves `:w` failing
---with E13), and the placeholder buffer left for the old name is wiped.
local function retarget_buffer(bufnr, old_path, new_path)
  vim.api.nvim_buf_set_name(bufnr, new_path)
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd("silent noautocmd keepalt write!")
  end)
  local stale = vim.fn.bufnr(old_path)
  if stale ~= -1 and stale ~= bufnr and not vim.bo[stale].modified then
    pcall(vim.api.nvim_buf_delete, stale, { force = true })
  end
end

local function plain_move(current_file, new_path)
  if vim.fn.rename(current_file, new_path) ~= 0 then
    return false, "Failed to move note to: " .. new_path
  end
  local bufnr = buffer_for(current_file)
  if bufnr then
    retarget_buffer(bufnr, current_file, new_path)
  else
    vim.cmd("edit " .. vim.fn.fnameescape(new_path))
  end
  return true
end

---Move a note and rewrite every inbound wiki-link and relative Markdown link.
---All edits are computed before anything is written; if a write fails the
---files already written and the move itself are rolled back.
---@param current_file string Absolute path of the note
---@param new_path string Absolute destination path
---@param new_stem string Filename stem (= id) at the destination
---@return boolean success, string|nil error
function M.move_note(current_file, new_path, new_stem)
  if normalize_path(current_file) ~= normalize_path(new_path) and utils.path_is_taken(new_path) then
    return false, "Move target already exists: " .. new_path
  end

  local root = utils.get_notebook_root()
  if not utils.relative_path(root, current_file) or not utils.relative_path(root, new_path) then
    return plain_move(current_file, new_path)
  end

  local source_buf = buffer_for(current_file)
  if source_buf and vim.bo[source_buf].modified then
    if source_buf ~= vim.api.nvim_get_current_buf() then
      return false, "Save the note before moving it"
    end
    local ok, err = pcall(vim.cmd, "write")
    if not ok then
      return false, "Failed to save note before moving it: " .. tostring(err)
    end
  end

  local metadata = frontmatter.parse_file(current_file) or {}
  local old_relative = utils.relative_path(root, current_file)
  local old_targets = { vim.fn.fnamemodify(current_file, ":t:r"), old_relative }
  if type(metadata.id) == "string" and metadata.id ~= "" then
    old_targets[#old_targets + 1] = metadata.id
  end
  local targets = target_set(old_targets)

  local changes = {}
  for _, note in ipairs(M.scan(true)) do
    local bufnr = buffer_for(note.path)
    local original, err
    if bufnr then
      original = buffer_content(bufnr)
    else
      original, err = read_file(note.path)
    end
    if not original then
      return false, "Failed to read note while updating links: " .. tostring(err)
    end

    local updated = M.rewrite_content(original, old_targets, new_stem)
    updated = rewrite_markdown_links(updated, root, note.path, current_file, new_path, targets)
    if updated ~= original then
      if bufnr and vim.bo[bufnr].modified then
        return false, "Save linked note before moving this note: " .. note.relative_path
      end
      local is_moved = normalize_path(note.path) == normalize_path(current_file)
      changes[#changes + 1] = {
        path = note.path,
        write_path = is_moved and new_path or note.path,
        buffer = bufnr,
        original = original,
        updated = updated,
      }
    end
  end

  utils.ensure_dir(vim.fn.fnamemodify(new_path, ":h"))
  if vim.fn.rename(current_file, new_path) ~= 0 then
    return false, "Failed to move note to: " .. new_path
  end

  local written = {}
  for _, change in ipairs(changes) do
    local ok, err = write_file(change.write_path, change.updated)
    if not ok then
      for _, previous in ipairs(written) do
        write_file(previous.write_path, previous.original)
      end
      vim.fn.rename(new_path, current_file)
      return false, "Failed to update links in " .. change.path .. ": " .. tostring(err)
    end
    written[#written + 1] = change
  end

  for _, change in ipairs(changes) do
    if change.buffer then
      set_buffer_content(change.buffer, change.updated)
    end
  end
  if source_buf then
    retarget_buffer(source_buf, current_file, new_path)
  else
    vim.cmd("edit " .. vim.fn.fnameescape(new_path))
  end
  M.invalidate()

  if #changes > 0 then
    vim.notify(string.format("Updated links in %d note(s)", #changes), vim.log.levels.INFO)
  end
  return true
end

-- ============================================================================
-- BUFFER-LOCAL MAPPINGS
-- ============================================================================

---`gf` follows a link when the cursor is on one and keeps its built-in
---behaviour everywhere else. `<CR>` is left alone: autolist.nvim owns it for
---checkbox toggling. Attached to vault Markdown buffers only.
---@param bufnr integer
function M.attach(bufnr)
  vim.keymap.set("n", "gf", function()
    if M.link_at_cursor() then
      M.follow()
    else
      vim.cmd("normal! " .. (vim.v.count > 0 and vim.v.count or "") .. "gf")
    end
  end, { buffer = bufnr, desc = "Follow link or file under cursor" })
end

return M
