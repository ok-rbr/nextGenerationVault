-- mini.ai: enhanced textobjects.
--
-- Keep this parser-independent while Treesitter is not part of the stable core.

return {
  {
    "echasnovski/mini.ai",

    event = "VeryLazy",

    opts = function()
      local ai = require("mini.ai")

      return {
        custom_textobjects = {
          -- Whole buffer.
          g = function()
            local from = { line = 1, col = 1 }
            local to = {
              line = vim.fn.line("$"),
              col = math.max(vim.fn.getline("$"):len(), 1),
            }

            return {
              from = from,
              to = to,
            }
          end,

          -- Function call.
          u = ai.gen_spec.function_call(),

          -- Function call without dot in function name.
          U = ai.gen_spec.function_call({
            name_pattern = "[%w_]",
          }),
        },

        mappings = {
          around = "a",
          inside = "i",

          around_next = "an",
          inside_next = "in",
          around_last = "al",
          inside_last = "il",

          goto_left = "g[",
          goto_right = "g]",
        },

        n_lines = 50,
        search_method = "cover_or_next",
        silent = true,
      }
    end,

    config = function(_, opts)
      require("mini.ai").setup(opts)
    end,
  },
}
