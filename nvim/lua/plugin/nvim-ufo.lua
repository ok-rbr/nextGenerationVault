return {
  -- TODO: review
  "kevinhwang91/nvim-ufo",
  dependencies = {
    "kevinhwang91/promise-async",
  },
  event = { "BufReadPost", "BufNewFile" },
  keys = {
    {
      "zR",
      function()
        require("ufo").openAllFolds()
      end,
      desc = "Open all folds",
    },
    {
      "zM",
      function()
        require("ufo").closeAllFolds()
      end,
      desc = "Close all folds",
    },
    {
      "zr",
      function()
        require("ufo").openFoldsExceptKinds()
      end,
      desc = "Open folds except kinds",
    },
    {
      "zm",
      function()
        require("ufo").closeFoldsWith()
      end,
      desc = "Close folds with",
    },
    {
      "zK",
      function()
        require("ufo").peekFoldedLinesUnderCursor()
      end,
      desc = "Peek folded lines under cursor",
    },
  },
  opts = {
    -- Provider priority: LSP -> treesitter -> indent
    provider_selector = function(bufnr, filetype, buftype)
      -- Use LSP folding for C# files; indent as fallback since c_sharp has no
      -- treesitter fold queries (avoids UfoFallbackException on buffer load)
      if filetype == "cs" then
        return { "lsp", "indent" }
      end

      -- For other filetypes, prefer treesitter then indent
      return { "treesitter", "indent" }
    end,

    -- Folding range preview configuration
    preview = {
      win_config = {
        border = "single",
        winhighlight = "Normal:Folded",
        winblend = 0,
      },
      mappings = {
        scrollU = "<C-u>",
        scrollD = "<C-d>",
        jumpTop = "[",
        jumpBot = "]",
      },
    },

    -- Fold virtual text configuration
    fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
      local newVirtText = {}
      local suffix = (" 󰁂 %d "):format(endLnum - lnum)
      local sufWidth = vim.fn.strdisplaywidth(suffix)
      local targetWidth = width - sufWidth
      local curWidth = 0

      for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
          table.insert(newVirtText, chunk)
        else
          chunkText = truncate(chunkText, targetWidth - curWidth)
          local hlGroup = chunk[2]
          table.insert(newVirtText, { chunkText, hlGroup })
          chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if curWidth + chunkWidth < targetWidth then
            suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
          end
          break
        end
        curWidth = curWidth + chunkWidth
      end

      table.insert(newVirtText, { suffix, "MoreMsg" })
      return newVirtText
    end,

    -- Close fold when cursor leaves it
    --    close_fold_kinds_for_ft = {
    --      cs = { "imports", "comment" },
    --      default = { "comment", "imports" },
    --    },
  },

  config = function(_, opts)
    -- Configure folding options for nvim-ufo
    -- vim.opt.foldcolumn = "1"
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99
    vim.opt.foldenable = true
    vim.opt.fillchars = [[eob: ,fold: ,foldopen: ,foldsep: ,foldclose: ]]

    require("ufo").setup(opts)
  end,
}
