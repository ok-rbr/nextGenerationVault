-- PowerShell language support.
--
-- Provides PowerShell Editor Services integration, extension terminal,
-- evaluation helpers, and optional DAP support via powershell.nvim.

local function setup_powershell_buffer(bufnr)
  vim.opt_local.commentstring = "# %s"
  vim.opt_local.expandtab = true
  vim.opt_local.shiftwidth = 2
  vim.opt_local.tabstop = 2
  vim.opt_local.softtabstop = 2

  local opts = { buffer = bufnr, silent = true }

  vim.keymap.set(
    "n",
    "<leader>P",
    function()
      require("powershell").toggle_term()
    end,
    vim.tbl_extend("force", opts, {
      desc = "PowerShell terminal",
    })
  )

  vim.keymap.set(
    { "n", "x" },
    "<leader>E",
    function()
      require("powershell").eval()
    end,
    vim.tbl_extend("force", opts, {
      desc = "PowerShell eval",
    })
  )

  vim.keymap.set(
    "n",
    "<leader>lR",
    function()
      vim.cmd("LspRestart")
    end,
    vim.tbl_extend("force", opts, {
      desc = "Restart PowerShell LSP",
    })
  )

  vim.keymap.set(
    "n",
    "<leader>lf",
    function()
      require("utils.formatting").format_buffer({
        formatters = { "pwshfmt" },
      })
    end,
    vim.tbl_extend("force", opts, {
      desc = "Format PowerShell",
    })
  )
end

return {
  {
    "TheLeoP/powershell.nvim",
    ft = { "ps1", "psm1", "psd1" },

    config = function()
      local bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services"
      local analyzer_settings = vim.fn.stdpath("config") .. "/style-configs/PSScriptAnalyzerSettings.psd1"

      if vim.fn.executable("pwsh") ~= 1 then
        vim.notify("PowerShell: 'pwsh' not found in PATH", vim.log.levels.WARN)
      end

      require("powershell").setup({
        bundle_path = bundle_path,
        shell = "pwsh",

        -- powershell.nvim owns the PowerShell Editor Services client. These
        -- settings used to be duplicated in lua/lsp/server/powershell_es.lua,
        -- which enabled a *second* PSES instance for the same buffers.
        settings = {
          powershell = {
            scriptAnalysis = {
              enable = true,
              settingsPath = analyzer_settings,
            },

            -- Carried over from the removed powershell_es config.
            codeFormatting = {
              preset = "OTBS", -- opening brace on the same line
              useCorrectCasing = true,
              whitespaceBeforeOpenBrace = true,
              whitespaceBeforeOpenParen = true,
              whitespaceAroundOperator = true,
              whitespaceAfterSeparator = true,
              ignoreOneLineBlock = true,
              newLineAfterOpenBrace = true,
              newLineAfterCloseBrace = true,
              alignPropertyValuePairs = true,
              useConstantStrings = false,
            },

            developer = {
              editorServicesLogLevel = "Normal",
              bundledModulesPath = bundle_path,
            },

            debugging = {
              createTemporaryIntegratedConsole = false,
            },

            integratedConsole = {
              showOnStartup = false,
              focusConsoleOnExecute = false,
            },
          },
        },
      })

      local augroup = vim.api.nvim_create_augroup("voidcore-powershell", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = { "ps1", "psm1", "psd1" },
        callback = function(args)
          setup_powershell_buffer(args.buf)
        end,
      })

      -- Apply settings to the current buffer as well.
      -- This matters because the plugin itself is loaded by FileType.
      if vim.tbl_contains({ "ps1", "psm1", "psd1" }, vim.bo.filetype) then
        setup_powershell_buffer(vim.api.nvim_get_current_buf())
      end
    end,
  },
}
