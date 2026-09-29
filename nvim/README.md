# Neovim Configuration

A modern, well-structured Neovim configuration with comprehensive LSP and plugin
support.

## Documentation

- **[lsp/README.md](./lua/lsp/README.md)** - LSP configuration and server
  details
- **[notes/README.md](./lua/notes/README.md)** - Notes subsystem (Obsidian
  vault, Taskwarrior, templates)
- **[style-configs/](./style-configs)** - Formatter and linter configuration
  this setup deploys for other projects
- **[docs/nvim/PROFILES.md](../../docs/nvim/PROFILES.md)** - Profile system
  (`core` / `dev` / `allMight`)

## Quick Start

### Getting Started

1. **Open Neovim**: `nvim`
2. **Install plugins**: Lazy.nvim installs automatically on first startup
3. **Install LSP servers**: Open `:Mason` and install the required servers

### Key Bindings

**Leader Key**: `<Space>` (Space bar)

| Action                   | Keymap             |
| ------------------------ | ------------------ |
| Find files               | `<leader>sf`       |
| Search text (grep)       | `<leader>sg`       |
| Switch buffers           | `<leader><leader>` |
| File Browser (Telescope) | `<leader>fb`       |
| Format code              | `<leader>f`        |
| LSP Code Actions         | `<leader>la`       |
| Rename symbol            | `<leader>lr`       |
| Show definition          | `gd`               |
| Hover Documentation      | `K`                |

**Full list**: `<leader>` then wait — which-key lists every binding
interactively. The definitions live in
[`lua/config/keymaps.lua`](./lua/config/keymaps.lua) and
[`lua/lsp/keymaps.lua`](./lua/lsp/keymaps.lua).

## Features

### Language Server Protocol (LSP)

Supported languages:

Enabled in [`lua/lsp/servers.lua`](./lua/lsp/servers.lua):

- **Lua** - lua_ls
- **C#** - omnisharp
- **Python** - basedpyright
- **Bash** - bashls
- **Kotlin** - kotlin_language_server
- **HTML** - html (supports `html` and `templ` filetypes)
- **CSS** - cssls
- **JSON** - jsonls
- **YAML** - yamlls
- **JavaScript/TypeScript** - ts_ls
- **Svelte** - svelte-language-server
- **Bicep** - bicep (`bicep lsp`, requires `bicep` in PATH)

Started by their own plugin rather than the list above:

- **PowerShell** - PowerShell Editor Services, through
  [`lua/plugin/powershell.lua`](./lua/plugin/powershell.lua) (powershell.nvim),
  which also provides the terminal, eval and DAP integration

Present in the tree but **not loaded**:

- The **jdtls** (Java) server configuration exists under `lua/lsp/server/`, but
  jdtls is not in the enabled list above.
- Plugin specifications [`lua/plugin/sqls.lua`](./lua/plugin/sqls.lua) (SQL
  LSP), [`lua/plugin/octo.lua`](./lua/plugin/octo.lua) (GitHub issues and pull
  requests) and [`lua/plugin/lazydocker.lua`](./lua/plugin/lazydocker.lua) exist
  but are not imported by `lua/config/plugins.lua`, so lazy.nvim never sees
  them. Uncomment the matching import there to enable one.

**marksman** (Markdown) supplies broken-wiki-link diagnostics and completion for
the vault and this repository's `docs/`. Completion is available on demand with
`<C-Space>`. In the `allMight` profile Marksman does not attach to the
daily-note directory, avoiding a known indexing stall there (see
[ADR-005](../../docs/ADR-005-note-taking-layer-ownership.md)).

Chezmoi templates (`*.tmpl`) are mapped to their underlying filetype when
possible (for example `dot_gitconfig.tmpl` → `gitconfig` and
`.chezmoiignore.tmpl` → `gitignore`) so syntax highlighting and LSP attachment
continue to work while editing template source files.

### Code Formatting

Automatic formatting with
[Conform.nvim](https://github.com/stevearc/conform.nvim):

- **Lua**: stylua
- **JavaScript/TypeScript**: prettier
- **Python**: isort + yapf
- **Kotlin**: ktlint
- **C#**: clang-format
- **PowerShell**: pwshfmt
- **and many more...**

Format on Save is only active when a matching formatter config file exists in
the current project. Repository defaults under `style-configs/` are no longer
used as automatic fallbacks for save-time formatting.

For Markdown, JSON, JSONC, and YAML in this repository, Conform uses the
project's `.prettierrc` and `.prettierignore`. When
`.tooling/node_modules/.bin/prettier` exists, it uses that repository-local
pinned version; otherwise it uses the project's `prettier` from `PATH`.

For Bicep, formatting is provided via LSP fallback (no extra formatter needed).
Install Bicep CLI via `brew install bicep` or `az bicep install`. Tree-sitter
highlighting for Bicep is optional and depends on parser availability.

**Format on Save Toggle**: `<leader>tf` - Enable/disable Format on Save for the
current file type. The formatter matrix is defined in
[`lua/plugin/conform.lua`](./lua/plugin/conform.lua); run `:ConformInfo` to see
what applies to the current buffer.

### Debugging (DAP)

Debug adapters configured in
[`lua/plugin/nvim-dap.lua`](./lua/plugin/nvim-dap.lua), with
[nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) for the interface.

Two adapters are wired up today:

| Language | Adapter   | Configurations                                                                 |
| -------- | --------- | ------------------------------------------------------------------------------ |
| C#       | `coreclr` | Launch .NET — finds `bin/Debug/**/<project>.dll`, prompts when there is none   |
| Python   | `debugpy` | Launch file, Debug pytest (current file), Debug module, Attach (Docker/remote) |

**C# adapter path.** `dap.adapters.coreclr` points at
`$LOCAL_BIN_DIR/netcoredbg-arm64`, where `LOCAL_BIN_DIR` comes from `.env`
(rendered by `dot_env.tmpl` from `paths.bin`). The binary name is
architecture-specific and is not resolved from `PATH` or Mason — on an x86_64
host the file has to be named accordingly or the adapter will not start.

**Python adapter** is built by [`lua/utils/python.lua`](./lua/utils/python.lua),
which resolves the interpreter per project (virtualenv, then system). The
Docker/remote attach configuration prompts for host, port and remote root.

**PowerShell** debugging comes from powershell.nvim rather than from
`nvim-dap.lua` — see [`lua/plugin/powershell.lua`](./lua/plugin/powershell.lua).

**Present but not wired up.** Two modules under `lua/utils/` implement further
debug workflows and are required by nothing:

- [`lua/utils/azure_functions.lua`](./lua/utils/azure_functions.lua) — detects
  an Azure Functions project from `host.json` plus `*.csproj` markers, and
  drives `dotnet build` → `func host start` → attach.
- [`lua/utils/docker.lua`](./lua/utils/docker.lua) — reads the debugpy port and
  `WORKDIR` out of `docker-compose.yml` and the `Dockerfile`, which would remove
  the prompts from the Python attach configuration.

Loading either means registering it from `nvim-dap.lua`. Until that happens the
workflows are not available, and this section does not claim otherwise.

There is no JavaScript, TypeScript, browser, Java or Kotlin adapter, and
`.vscode/launch.json` is not loaded.

**Key bindings**:

| Action             | Keymap       |
| ------------------ | ------------ |
| Start / Continue   | `<F5>`       |
| Step Over          | `<F10>`      |
| Step Into          | `<F11>`      |
| Step Out           | `<F12>`      |
| Toggle Breakpoint  | `<leader>db` |
| Terminate          | `<leader>dq` |
| Open REPL          | `<leader>dr` |
| Toggle DAP UI      | `<leader>du` |
| Evaluate (n and v) | `<leader>de` |

The UI opens automatically when a session initializes and closes when it
terminates or exits.

### Plugins

**Core functionality**:

- [lazy.nvim](https://github.com/folke/lazy.nvim) - Plugin Manager
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Fuzzy
  Finder
- Built-in Neovim Tree-sitter (0.12+) - Syntax Highlighting
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - LSP Configuration

**UI & UX**:

- [onedarkpro.nvim](https://github.com/olimorris/onedarkpro.nvim) - Theme
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) - Statusline
- [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) - Buffer Tabs
- [which-key.nvim](https://github.com/folke/which-key.nvim) - Keymap Helper
- [snacks.nvim](https://github.com/folke/snacks.nvim) - UI Enhancements

**Productivity**:

- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) - Autocompletion
- [trouble.nvim](https://github.com/folke/trouble.nvim) - Diagnostics List
- [grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim) - Search & Replace
- [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) - TODO
  Highlights
- [mini.nvim](https://github.com/echasnovski/mini.nvim) - Useful Mini Tools

**Git**:

- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) - Git Integration
- Git Browse & Blame via Snacks

**Notes & Knowledge Management**:

The stack is split into four layers with one owner each; see
[ADR-005](../../docs/ADR-005-note-taking-layer-ownership.md).

- [`lua/notes/`](./lua/notes/README.md) - daily notes, templates, frontmatter,
  PARA routing, queries and native wiki-link creation/following
- [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) -
  headings, checkboxes, tables, concealment (layer 4)
- [autolist.nvim](https://github.com/gaoDean/autolist.nvim) - Smart List
  Management

`:NotePasteImage` (`<leader>op`) saves the clipboard image into the attachment
folder shared with the Obsidian desktop app (`dot_config/obsidian/app.json`)
using `wl-paste`, `xclip`, `pngpaste` or PowerShell, whichever the platform has.
img-clip.nvim was removed earlier because it used a second destination path.

Marksman diagnostics and completion remain enabled outside daily notes; native
Lua owns wiki-links, backlinks, vault search and inbound-link rewrites.
Treesitter provides Markdown syntax highlighting, and render-markdown.nvim
handles in-editor presentation. The obsidian.nvim import is commented out while
its plugin spec remains available. vimwiki, markdown-preview.nvim and glow.nvim
were removed earlier.

## Profile System

Neovim can be started with a reduced feature set using the `NVIM_PROFILE`
environment variable:

| Profile    | What is loaded                                            |
| ---------- | --------------------------------------------------------- |
| `core`     | Options, keymaps, autocmds, treesitter, base plugins only |
| `dev`      | `core` + LSP, DAP, formatting, git, enhanced UI           |
| `allMight` | `dev` + AI, notes, media tools (default)                  |

```bash
NVIM_PROFILE=core nvim   # minimal mode
NVIM_PROFILE=dev  nvim   # development profile
nvim                     # allMight (full, default)
```

See **[docs/nvim/PROFILES.md](../../docs/nvim/PROFILES.md)** for the full
reference including the Lua API for querying the active profile.

## Structure

```text
nvim/
├── init.lua                    # Main entry point
├── lua/
│   ├── core/                   # Profile system (core.profile)
│   ├── config/                 # Core configuration
│   │   ├── opts.lua           # Vim options
│   │   ├── keymaps.lua        # Keybindings
│   │   ├── autocmds.lua       # Autocommands
│   │   ├── icons.lua          # Central icon system
│   │   └── ...
│   ├── lsp/                    # LSP configuration
│   │   ├── init.lua           # LSP Setup
│   │   └── server/            # Server-specific configs
│   └── plugin/                 # Plugin configurations
│       ├── telescope.lua
│       ├── lspconfig.lua
│       ├── conform.lua
│       └── ...
├── style-configs/              # Formatter configurations
└── scripts/                    # Utility scripts

```

## Configuration

### Formatter Settings

Formatter configurations are located in `style-configs/`:

- `.stylua.toml` - Lua
- `.prettierrc.json` - JavaScript/TypeScript
- `.clang-format` - C#
- `pyproject.toml` - Python
- and more...

### LSP Servers

LSP server configurations in `lua/lsp/server/`:

- Each server has its own file
- Contains settings, root markers, commands
- Easily extensible for new servers

## Customization

### Theme Customization

Edit `lua/plugin/theme.lua`:

```lua
colorscheme = "onedark", -- or "onedark_vivid", "onedark_dark"
```

### New Keybindings

Add to `lua/config/keymaps.lua`:

```lua
vim.keymap.set("n", "<leader>xy", function() ... end, { desc = "Description" })
```

### Add New LSP Server

1. Create `lua/lsp/server/SERVERNAME.lua`
2. Add server to `lua/lsp/init.lua`
3. Install with `:Mason`

## Performance

Startup loading is profile-aware and plugin loading is lazy. Snacks also
provides bigfile handling for large files.

**Check Startup Time**: `:Lazy profile`

## Help & Commands

### Important Commands

| Command        | Description           |
| -------------- | --------------------- |
| `:checkhealth` | Neovim Health Check   |
| `:Lazy`        | Open Plugin Manager   |
| `:Mason`       | LSP/Formatter Manager |
| `:LspInfo`     | LSP Client Info       |
| `:ConformInfo` | Formatter Info        |
| `:LspRestart`  | Restart LSP server    |

### Troubleshooting

**LSP not working**:

1. `:LspInfo` - Check if server is attached
2. `:Mason` - Check if server is installed
3. `:checkhealth vim.lsp` - Health Check

**Formatting not working**:

1. `:ConformInfo` - Check formatter status
2. Verify the formatter is installed (e.g. `stylua`, `prettier`, `isort`,
   `yapf`, `ktlint`)
3. `<leader>tf` - Toggle Format-on-Save
4. Check the formatter list for the file type in
   [`lua/plugin/conform.lua`](./lua/plugin/conform.lua)

**Plugins not loading**:

1. Open `:Lazy`
2. Press `U` to update
3. Restart Neovim

**Python/C# syntax highlighting not working**:

1. `:checkhealth vim.treesitter` - Verify parser/runtime health
2. `:Inspect` - Confirm captures are present under the cursor
3. `:set filetype? syntax?` - Verify Neovim sees `python` or `cs`

## Maintenance

### Updates

```vim
:Lazy sync          " Update plugins
:Mason update       " Update LSP servers
```

### Health Checks

```vim
:checkhealth        " Full health check
:checkhealth vim.lsp " LSP health check
```

## Credits

This configuration is based on:

- [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) - Starter
  template
- [LazyVim](https://github.com/LazyVim/LazyVim) - Plugin inspiration
- [NTBBloodbath/nvim](https://github.com/NTBBloodbath/nvim) - LSP configuration

## License

Part of this dotfiles repository — see the
[License section of the root README](../../README.md#license).
