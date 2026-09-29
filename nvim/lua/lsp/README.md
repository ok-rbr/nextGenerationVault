# LSP Configuration

This directory contains the modular LSP configuration for Neovim.

## Structure

- `init.lua` - Main LSP initialization module that loads all server
  configurations
- `server/` - Directory containing individual LSP server configurations

## Server Configurations

Each server has its own configuration file in the `server/` directory:

### Standard Servers

- `lua_ls.lua` - Lua Language Server
- `omnisharp.lua` - C# Language Server (OmniSharp)
- `bashls.lua` - Bash Language Server
- `bicep.lua` - Bicep Language Server (Azure IaC)
- `kotlin_language_server.lua` - Kotlin Language Server
- `jdtls.lua` - Java Language Server (JDTLS)
- `html.lua` - HTML Language Server (supports `html` and `templ` filetypes)

### Special Servers

- `basedpyright.lua` - Python Language Server with dynamic virtual environment
  detection
- `bicep.lua` - Uses `bicep lsp` from the Bicep CLI on your `PATH`

#### Bicep Configuration

The `bicep` server is configured with:

- **Command**: `bicep lsp`
- **Filetype**: `bicep`
- **Root detection**: `bicepconfig.json`, `*.bicep`, then `.git`
- **Single file support**: enabled

Install the Bicep CLI using one of:

1. `brew install bicep`
2. `az bicep install`

After installation, verify with:

- `bicep --version`
- `:checkhealth vim.lsp`

Formatting for Bicep buffers uses the existing Conform setup with
`lsp_fallback`, so no extra formatter dependency is required.

Tree-sitter support for Bicep is optional and depends on parser availability on
your system; LSP features work independently.

#### basedpyright Configuration

The `basedpyright` server automatically detects Python installations in the
following order:

1. **Workspace virtual environments**: `.venv` or `venv` folders in the project
   root
2. **System Python in PATH**: Searches for `python3` or `python` in your system
   PATH
3. **Windows common install locations**: On Windows, searches standard Python
   installation directories

- `%LOCALAPPDATA%\Programs\Python\Python3XX\python.exe`
- `C:\Python3XX\python.exe`

4. **Fallback**: Uses `python` command with a warning

**Handling Python Version Updates:**

If you upgrade Python and basedpyright shows errors like "No Python at '...'",
you may need to:

1. **Clear workspace cache**: Delete any `pyrightconfig.json` files in your
   project that have hardcoded Python paths
2. **Restart LSP**: Use `:LspRestart` command in Neovim
3. **Check PATH**: Ensure the new Python installation is in your system PATH
4. **Check notifications**: The LSP will notify you which Python path it's using

The configuration now includes proper error handling and logging to help
diagnose Python path issues.

## How It Works

1. The main `lsp.lua` file calls `require("lsp").setup()`
2. `init.lua` loads each server configuration from the `server/` directory
3. Each server configuration exports a table with a `config` field containing
   LSP settings
4. Special servers may also export additional functions like `autocmd` for
   custom setup logic

## Server Configuration Format

Each server configuration file should export a table with this structure:

```lua
local M = {}

M.config = {
  cmd = { "language-server-command" },
  filetypes = { "filetype1", "filetype2" },
  root_markers = { "file1", "file2", ".git" },
  settings = {
    -- language server specific settings
  },
  -- other LSP configuration options
}

-- Optional: custom setup function
M.autocmd = function()
  -- custom autocmd logic
end

return M
```

## Testing

All LSP configurations are covered by comprehensive tests in
`tests/test_lsp.lua`. The tests verify:

- **Configuration Validity**: All server configurations load without errors
- **Required Fields**: Each server has required fields (cmd, filetypes, root
  markers)
- **Special Servers**: Custom functions like basedpyright's autocmd and
  omnisharp's handlers
- **Filetype Coverage**: No conflicting filetype registrations (except expected
  ones)
- **Initialization**: LSP setup process runs without errors
- **Performance**: All servers load within acceptable time thresholds

Additional formatter tests in `tests/test_formatter.lua` verify:

- **Format on Save**: conform.nvim configuration and format_on_save behavior
- **Filetype Support**: Formatters configured for all expected filetypes
- **Conditional Logic**: Disabled filetypes (c, cpp) exclude LSP fallback
  properly
- **Keymap Integration**: Manual format keymap (<leader>f) is properly
  configured
- **Error Handling**: Graceful handling of edge cases and invalid inputs

Run all tests with: `cd nvim/tests && lua run_tests.lua`
