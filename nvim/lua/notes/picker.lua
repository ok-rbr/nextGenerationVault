-- notes/picker.lua
-- Shared Telescope picker helpers for the notes system.
--
-- Before this module existed, nearly identical
-- pickers/finders/sorter/previewer/attach_mappings boilerplate was
-- duplicated across commands.lua, queries.lua, backlinks.lua, health.lua,
-- calendar.lua and taskwarrior.lua (~150+ lines total). Centralizing it here
-- means picker behavior (escaping, previewer, empty-result handling) only
-- needs to be fixed/extended in one place.
--
-- Telescope modules are required lazily inside functions (not at module
-- scope) so that requiring notes.picker never fails even if telescope.nvim
-- has not finished loading yet.

local M = {}

---Build and open a Telescope picker from a list of items.
---@param items table[] List of items. Each item should have at least a
---  `path` field (used by the default on_select/previewer), or a `display`
---  field for plain read-only lists without a file to open.
---@param opts table|nil Options:
---  - prompt_title string: Telescope picker title (default: "Notes")
---  - empty_message string: vim.notify message when items is empty
---  - display_fn function(item) -> string: entry label (default: item.display or item.path)
---  - ordinal_fn function(item) -> string: sort/filter text (default: display_fn result)
---  - on_select function(item): called when an entry is confirmed with <CR>
---    (default: opens item.path, jumping to item.lnum if present)
---  - previewer boolean: set to false to disable the file previewer (e.g. for
---    picking non-file entries like calendar events)
---  - attach_mappings function(prompt_bufnr, map, actions, action_state):
---    called after the default <CR> mapping is attached, to add extra keymaps
---  - picker_opts table: passed through as the Telescope layout opts
function M.pick(items, opts)
  opts = opts or {}

  if #items == 0 then
    vim.notify(opts.empty_message or "No results found", vim.log.levels.INFO)
    return
  end

  local ok_pickers, pickers = pcall(require, "telescope.pickers")
  if not ok_pickers then
    vim.notify("telescope.nvim is required for this picker", vim.log.levels.WARN)
    return
  end
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local display_fn = opts.display_fn or function(item)
    return item.display or item.path or tostring(item)
  end
  local ordinal_fn = opts.ordinal_fn or display_fn

  local on_select = opts.on_select
    or function(item)
      if not item.path then
        return
      end
      if item.lnum then
        vim.cmd("edit +" .. item.lnum .. " " .. vim.fn.fnameescape(item.path))
      else
        vim.cmd("edit " .. vim.fn.fnameescape(item.path))
      end
    end

  local picker_opts = opts.picker_opts or {}
  local has_file_paths = opts.previewer ~= false
  if has_file_paths then
    for _, item in ipairs(items) do
      if type(item.path) ~= "string" or item.path == "" then
        has_file_paths = false
        break
      end
    end
  end

  pickers
    .new(picker_opts, {
      prompt_title = opts.prompt_title or "Notes",
      finder = finders.new_table({
        results = items,
        entry_maker = function(item)
          return {
            value = item,
            display = display_fn(item),
            ordinal = ordinal_fn(item),
            path = item.path,
            filename = item.path,
            lnum = item.lnum,
          }
        end,
      }),
      sorter = conf.generic_sorter(picker_opts),
      previewer = has_file_paths and conf.file_previewer(picker_opts) or nil,
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            on_select(selection.value)
          end
        end)
        if opts.attach_mappings then
          opts.attach_mappings(prompt_bufnr, map, actions, action_state)
        end
        return true
      end,
    })
    :find()
end

return M
