-- completion for LSP.

return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",

  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
  },

  config = function()
    local cmp = require("cmp")

    local icons = require("config.icons")
    local cmp_kinds = icons.get_lsp_kind_icons()

    cmp.setup({
      snippet = {
        expand = function(args)
          vim.snippet.expand(args.body)
        end,
      },

      formatting = {
        format = function(_, vim_item)
          vim_item.kind = (cmp_kinds[vim_item.kind] or "") .. vim_item.kind
          return vim_item
        end,
      },

      mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),

        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { "i", "s" }),
      }),

      sources = cmp.config.sources({
        { name = "nvim_lsp" },
      }),
    })

    -- Marksman supplies Markdown completion in both profiles. Avoid generic
    -- buffer/path sources, and keep popups manual (<C-Space>) so completion
    -- does not scan or display results on every keystroke.
    cmp.setup.filetype("markdown", {
      completion = {
        autocomplete = false,
      },
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
      }),
    })
  end,
}
