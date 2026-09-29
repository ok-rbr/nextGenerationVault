-- log highlighting for generic log-like files.
--
-- provides filetype detection and syntax highlighting for logs.
-- keep custom rules minimal; the plugin already ships sane defaults.

return {
  {
    "fei6409/log-highlight.nvim",

    event = {
      "BufReadPost *.log",
      "BufReadPost *.out",
      "BufReadPost *.err",
      "BufReadPost *.stdout",
      "BufReadPost *.stderr",
      "BufNewFile *.log",
      "BufNewFile *.out",
      "BufNewFile *.err",
      "BufNewFile *.stdout",
      "BufNewFile *.stderr",
    },

    opts = {
      extension = {
        "log",
        "out",
        "err",
        "stdout",
        "stderr",
      },

      filename = {
        "syslog",
      },

      pattern = {
        "log.*%.txt",
        ".*%.log%.%d+",
      },

      keyword = {
        error = {
          "ERROR",
          "ERR",
          "FAIL",
          "FAILED",
          "Exception",
        },

        warning = {
          "WARN",
          "WARNING",
          "DEPRECATED",
        },

        info = {
          "INFO",
          "Information",
        },

        debug = {
          "DEBUG",
          "TRACE",
        },
      },
    },
  },
}
