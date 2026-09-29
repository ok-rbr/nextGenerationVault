return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<F5>",
        function()
          require("dap").continue()
        end,
        desc = "DAP Continue",
      },
      {
        "<F10>",
        function()
          require("dap").step_over()
        end,
        desc = "DAP Step Over",
      },
      {
        "<F11>",
        function()
          require("dap").step_into()
        end,
        desc = "DAP Step Into",
      },
      {
        "<F12>",
        function()
          require("dap").step_out()
        end,
        desc = "DAP Step Out",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "DAP Toggle Breakpoint",
      },
      {
        "<leader>dq",
        function()
          require("dap").terminate()
        end,
        desc = "DAP Terminate",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.open()
        end,
        desc = "DAP REPL",
      },
    },
    config = function()
      local dap = require("dap")
      local python_utils = require("utils.python")
      local local_bin_dir = require("notes.env").get("LOCAL_BIN_DIR") or "~"

      local function find_dll()
        local cwd = vim.fn.getcwd()
        local project = vim.fn.fnamemodify(cwd, ":t")
        local matches = vim.fn.glob(cwd .. "/bin/Debug/**/" .. project .. ".dll", true, true)

        matches = vim.tbl_filter(function(path)
          return not path:match("[/\\]ref[/\\]") and not path:match("[/\\]publish[/\\]")
        end, matches)

        if #matches > 0 then
          return matches[#matches]
        end

        return vim.fn.input("Path to DLL: ", cwd .. "/bin/Debug/", "file")
      end

      dap.set_log_level("TRACE")

      vim.fn.sign_define("DapBreakpoint", {
        text = "●",
        texthl = "DiagnosticError",
      })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarning" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticInfo", linehl = "DapStoppedLine" })
      vim.fn.sign_define("DapLogPoint", { text = "◎", texthl = "DiagnosticInfo" })

      dap.adapters.coreclr = {
        type = "executable",
        command = vim.fn.expand(local_bin_dir .. "/netcoredbg-arm64"),
        args = { "--interpreter=vscode" },
      }

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch .NET",
          request = "launch",
          program = find_dll,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
        },
      }

      dap.adapters.python = python_utils.make_python_adapter()

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
        },
        {
          type = "python",
          request = "launch",
          name = "Debug pytest (current file)",
          module = "pytest",
          args = { "-vv", "${file}" },
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
        },
        {
          type = "python",
          request = "launch",
          name = "Debug module",
          module = function()
            return vim.fn.input("Module to launch: ")
          end,
          args = function()
            return vim.split(vim.fn.input("Arguments: "), " ", { trimempty = true })
          end,
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
        },
        {
          type = "python",
          request = "attach",
          name = "Attach (Docker / remote debugpy)",
          connect = function()
            local host = vim.fn.input("Host: ", "127.0.0.1")
            local port = tonumber(vim.fn.input("Port: ", "5678"))
            return { host = host ~= "" and host or "127.0.0.1", port = port or 5678 }
          end,
          pathMappings = {
            {
              localRoot = "${workspaceFolder}",
              remoteRoot = function()
                return vim.fn.input("Remote root: ", "/app")
              end,
            },
          },
          justMyCode = false,
        },
      }

      local ok, dapui = pcall(require, "dapui")
      if ok then
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          dapui.close()
        end
      end
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    keys = {
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "DAP UI Toggle",
      },
      {
        "<leader>de",
        function()
          require("dapui").eval()
        end,
        mode = { "n", "v" },
        desc = "DAP Eval",
      },
    },
    config = function()
      require("dapui").setup()
    end,
  },
}
