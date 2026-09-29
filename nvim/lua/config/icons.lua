-- Centralized Icon Configuration
-- JetBrains Mono Nerd Font + subtle Dev Icons (monochrome, minimal)
-- Works best on dark backgrounds
local M = {}

-- Monochrome color palette for dark backgrounds (primary, secondary, tertiary,
-- accent, muted), set in .chezmoidata/theme.toml under [theme.ui.icons].
local colors = require("theme.palette").ui.icons

-- Core icon definitions organized by functionality
M.icons = {

  -- === FILE TYPE ICONS ===
  filetype = {
    -- Programming Languages
    lua = { icon = "", color = colors.primary, name = "Lua" },
    js = { icon = "", color = colors.primary, name = "JavaScript" },
    ts = { icon = "", color = colors.primary, name = "TypeScript" },
    py = { icon = "", color = colors.primary, name = "Python" },
    cs = { icon = "", color = colors.primary, name = "CSharp" }, -- seti-csharp
    java = { icon = "", color = colors.primary, name = "Java" },
    kt = { icon = "", color = colors.primary, name = "Kotlin" },
    go = { icon = "", color = colors.primary, name = "Go" },
    rs = { icon = "", color = colors.primary, name = "Rust" },
    cpp = { icon = "", color = colors.primary, name = "Cpp" },
    c = { icon = "", color = colors.primary, name = "C" },
    php = { icon = "", color = colors.primary, name = "PHP" },
    rb = { icon = "", color = colors.primary, name = "Ruby" },

    -- Web Technologies
    html = { icon = "", color = colors.secondary, name = "Html" },
    css = { icon = "", color = colors.secondary, name = "Css" },
    scss = { icon = "", color = colors.secondary, name = "Scss" },
    sass = { icon = "", color = colors.secondary, name = "Sass" },
    vue = { icon = "", color = colors.secondary, name = "Vue" },
    jsx = { icon = "", color = colors.secondary, name = "ReactJs" },
    tsx = { icon = "", color = colors.secondary, name = "ReactTs" },

    -- Configuration & Data
    json = { icon = "", color = colors.tertiary, name = "Json" },
    yaml = { icon = "", color = colors.tertiary, name = "Yaml" },
    yml = { icon = "", color = colors.tertiary, name = "Yml" },
    toml = { icon = "", color = colors.tertiary, name = "Toml" },
    xml = { icon = "", color = colors.tertiary, name = "Xml" },
    ini = { icon = "", color = colors.tertiary, name = "Ini" },
    conf = { icon = "", color = colors.tertiary, name = "Config" },

    -- Documentation
    md = { icon = "", color = colors.secondary, name = "Markdown" },
    txt = { icon = "", color = colors.muted, name = "Text" },
    pdf = { icon = "", color = colors.tertiary, name = "PDF" },

    -- Shell & Scripts
    sh = { icon = "", color = colors.secondary, name = "Shell" },
    bash = { icon = "", color = colors.secondary, name = "Bash" },
    zsh = { icon = "", color = colors.secondary, name = "Zsh" },
    fish = { icon = "", color = colors.secondary, name = "Fish" },

    -- Database
    sql = { icon = "", color = colors.tertiary, name = "Sql" },
    db = { icon = "", color = colors.tertiary, name = "Database" },

    -- Version Control & Build
    gitignore = { icon = "", color = colors.muted, name = "GitIgnore" },
    makefile = { icon = "", color = colors.tertiary, name = "Makefile" },
    dockerfile = { icon = "", color = colors.tertiary, name = "Dockerfile" },

    -- Lock & Package Files
    ["package-lock.json"] = { icon = "", color = colors.muted, name = "PackageLockJson" },
    ["yarn.lock"] = { icon = "", color = colors.muted, name = "YarnLock" },
    ["composer.lock"] = { icon = "", color = colors.muted, name = "ComposerLock" },
    ["Cargo.lock"] = { icon = "", color = colors.muted, name = "CargoLock" },
  },

  -- === LSP COMPLETION KINDS === (Codicons)
  lsp = {
    Text = "",
    Method = "",
    Function = "",
    Constructor = "",
    Field = "",
    Variable = "",
    Class = "",
    Interface = "",
    Module = "",
    Property = "",
    Unit = "",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = "",
  },

  -- === DIAGNOSTIC ICONS ===
  diagnostics = {
    error = "",
    warn = "",
    info = "",
    hint = "",
    ok = "",
    question = "",
  },

  -- === GIT ICONS === (Octicons/Codicons mix, monochrome)
  git = {
    added = "",
    add = "+",
    change = "~",
    topdelete = "‾",
    delete = "_",
    changedelete = "~",
    modified = "",
    removed = "",
    renamed = "",
    untracked = "",
    ignored = "",
    unstaged = "",
    staged = "",
    conflict = "",
    branch = "",
    commit = "",
    merge = "",
    tag = "",
  },

  -- === UI ELEMENTS ===
  ui = {
    -- Dashboard actions
    file = "",
    new_file = "",
    find_text = "",
    recent = "",
    config = "",
    session = "",
    lazy = "󰒲",
    quit = "",

    -- Navigation & controls
    folder_open = "",
    folder_closed = "",
    arrow_right = "",
    arrow_down = "",
    close = "",
    maximize = "",
    minimize = "",

    -- Status indicators
    loading = "",
    success = "",
    warning = "",
    error = "",
    info = "",

    -- Common actions
    search = "",
    filter = "",
    sort = "",
    refresh = "",
    settings = "",
    help = "",

    -- Separators & decorations
    separator = "▎",
    bullet = "•",
    chevron_right = "",
    chevron_down = "",
  },

  -- === COMMAND & MODE ICONS ===
  command = {
    search = "/",
    bash = "",
    lua = "",
    help = "",
    filter = "$",
    input = "",
    command = ":",
  },

  -- === TODO COMMENT ICONS ===
  todo = {
    fix = "", -- bug
    todo = "", -- task list
    hack = "", -- lightning/hack
    warn = "",
    perf = "", -- tachometer
    note = "",
    test = "", -- beaker
  },

  -- === SPECIAL SYMBOLS ===
  special = {
    vim = "",
    neovim = "",
    terminal = "",
    code = "",
    bookmark = "",
    calendar = "",
    clock = "",
    database = "",
    globe = "",
    heart = "",
    home = "",
    key = "",
    lock = "",
    mail = "",
    phone = "",
    star = "",
    user = "",
    users = "",
    package = "",
    plugin = "",
    tool = "",
    wrench = "",
  },
}

-- Helper functions for easy access
function M.get_filetype_icon(filetype)
  return M.icons.filetype[filetype] or { icon = "", color = colors.muted, name = "Unknown" }
end

function M.get_lsp_icon(kind)
  return M.icons.lsp[kind] or ""
end

function M.get_diagnostic_icon(level)
  return M.icons.diagnostics[level] or ""
end

function M.get_git_icon(status)
  return M.icons.git[status] or ""
end

function M.get_ui_icon(element)
  return M.icons.ui[element] or ""
end

function M.get_command_icon(cmd)
  return M.icons.command[cmd] or ""
end

-- Get all file type icons formatted for nvim-web-devicons
function M.get_devicons_override()
  local override = {}
  for ext, config in pairs(M.icons.filetype) do
    override[ext] = {
      icon = config.icon,
      color = config.color,
      name = config.name,
    }
  end
  return override
end

-- Get all LSP kind icons as a simple mapping
function M.get_lsp_kind_icons()
  local kind_icons = {}
  for kind, icon in pairs(M.icons.lsp) do
    kind_icons[kind] = icon
  end
  return kind_icons
end

return M
