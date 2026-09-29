-- lua/lsp/server/powershell_es.lua
-- PowerShell Editor Services LSP Configuration

local M = {}

M.config = {
  -- Use the Mason-installed PowerShell Editor Services bundle
  cmd = {
    "pwsh",
    "-NoLogo",
    "-NoProfile",
    "-Command",
    vim.fn.stdpath("data")
      .. "/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1",
    "-BundledModulesPath",
    vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
    "-LogPath",
    vim.fn.stdpath("cache") .. "/powershell_es.log",
    "-SessionDetailsPath",
    vim.fn.stdpath("cache") .. "/powershell_es_session.json",
    "-FeatureFlags",
    "@()",
    "-AdditionalModules",
    "@()",
    "-HostName",
    "nvim",
    "-HostProfileId",
    "nvim",
    "-HostVersion",
    "1.0.0",
    "-Stdio",
    "-LogLevel",
    "Normal",
  },

  -- File types this server should attach to
  filetypes = { "ps1", "psm1", "psd1" },

  -- Root directory markers
  root_markers = {
    "*.psd1",
    "*.psm1",
    "*.ps1",
    ".git",
    ".powershellrc",
  },

  -- Single file support
  single_file_support = true,

  -- Server settings
  settings = {
    powershell = {
      -- Code formatting settings
      codeFormatting = {
        -- Use One True Brace Style (opening brace on same line)
        preset = "OTBS",
        -- Use spaces for indentation
        useCorrectCasing = true,
        -- Enforce consistent whitespace
        whitespaceBeforeOpenBrace = true,
        whitespaceBeforeOpenParen = true,
        whitespaceAroundOperator = true,
        whitespaceAfterSeparator = true,
        -- Ignore DSC resource properties for casing
        ignoreOneLineBlock = true,
        -- New line settings
        newLineAfterOpenBrace = true,
        newLineAfterCloseBrace = true,
        -- Align assignment statements
        alignPropertyValuePairs = true,
        -- Use consistent indentation
        useConstantStrings = false,
      },

      -- Script analysis settings (references our style config)
      scriptAnalysis = {
        enable = true,
        settingsPath = vim.fn.stdpath("config") .. "/style-configs/PSScriptAnalyzerSettings.psd1",
      },

      -- IntelliSense features
      developer = {
        editorServicesLogLevel = "Normal",
        bundledModulesPath = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
      },

      -- Debugging support
      debugging = {
        createTemporaryIntegratedConsole = false,
      },

      -- Integrated console settings
      integratedConsole = {
        showOnStartup = false,
        focusConsoleOnExecute = false,
      },
    },
  },

  -- Capabilities configuration
  capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
          resolveSupport = {
            properties = { "documentation", "detail", "additionalTextEdits" },
          },
        },
      },
      -- Enable folding support
      foldingRange = {
        dynamicRegistration = true,
        lineFoldingOnly = true,
      },
      -- Enable semantic tokens
      semanticTokens = {
        multilineTokenSupport = true,
      },
    },
  },

  -- LSP initialization options
  init_options = {
    enableProfileLoading = false,
  },
}

return M
