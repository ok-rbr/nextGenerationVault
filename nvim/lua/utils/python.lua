-- Shared Python utilities for LSP and DAP
-- Provides common Python path detection logic used by basedpyright and nvim-dap

local M = {}

--- Check whether debugpy is available for the given Python executable.
--- Returns true when `python -c "import debugpy"` exits successfully.
--- @param python_path string Path to the Python executable
--- @return boolean
function M.check_debugpy(python_path)
  vim.fn.system({ python_path, "-c", "import debugpy" })
  return vim.v.shell_error == 0
end

--- Build the nvim-dap adapter function for Python.
--- The returned function handles both local launch (executable) and
--- remote/Docker attach (server), and warns if debugpy is not installed.
--- @return function DAP adapter callback
function M.make_python_adapter()
  return function(callback, config)
    if config.request == "attach" then
      local connect = config.connect or {}
      callback({
        type = "server",
        host = connect.host or "127.0.0.1",
        port = connect.port or 5678,
      })
    else
      local python = M.get_python_path(vim.fn.getcwd(), "DAP")
      if not M.check_debugpy(python) then
        vim.notify(
          ("DAP: debugpy not found for %s. Install it with: pip install debugpy"):format(python),
          vim.log.levels.WARN
        )
      end
      callback({
        type = "executable",
        command = python,
        args = { "-m", "debugpy.adapter" },
      })
    end
  end
end

--- Get the Python executable path for the current workspace.
--- Searches in the following order:
--- 1. Workspace-local virtual environments (.venv, venv)
--- 2. Python in PATH (python3, python)
--- 3. Windows: Common installation directories (Python 3.10-3.14)
--- 4. Fallback to "python" with a warning
--- @param workspace string|nil Optional workspace path. If nil, uses current working directory.
--- @param context string|nil Optional context name for notifications (e.g., "LSP", "DAP")
--- @return string Python executable path
function M.get_python_path(workspace, context)
  workspace = workspace or vim.fn.getcwd()
  context = context or "Python"

  local sep = package.config:sub(1, 1)
  local is_windows = sep == "\\"

  -- Workspace-local virtual environments
  local candidates = {
    workspace .. sep .. ".venv" .. sep .. "Scripts" .. sep .. "python.exe",
    workspace .. sep .. ".venv" .. sep .. "bin" .. sep .. "python",
    workspace .. sep .. "venv" .. sep .. "Scripts" .. sep .. "python.exe",
    workspace .. sep .. "venv" .. sep .. "bin" .. sep .. "python",
  }

  for _, path in ipairs(candidates) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end

  -- Try to find Python in PATH
  local path_candidates = is_windows and { "python", "python3" } or { "python3", "python" }

  for _, cmd in ipairs(path_candidates) do
    local py = vim.fn.exepath(cmd)
    if py and py ~= "" then
      return py
    end
  end

  -- On Windows, search common installation directories
  if is_windows then
    local localappdata = os.getenv("LOCALAPPDATA")
    local win_candidates = {}

    -- Add user-specific and system-wide Python installations (versions 3.10-3.14)
    for version = 314, 310, -1 do
      local major = math.floor(version / 100)
      local minor = version % 100
      local version_str = "Python" .. major .. minor

      if localappdata then
        table.insert(win_candidates, localappdata .. "\\Programs\\Python\\" .. version_str .. "\\python.exe")
      end
      table.insert(win_candidates, "C:\\" .. version_str .. "\\python.exe")
    end

    for _, path in ipairs(win_candidates) do
      if vim.fn.executable(path) == 1 then
        return path
      end
    end
  end

  -- Final fallback with warning
  vim.notify(
    context
      .. ": Could not find Python executable. Using 'python' as fallback. "
      .. "Please ensure Python is in your PATH.",
    vim.log.levels.WARN
  )
  return "python"
end

return M
