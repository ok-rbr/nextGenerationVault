-- Azure Functions debug orchestration for nvim-dap
-- Workflow: dotnet build -> func host start (terminal) -> PID detect -> attach

local M = {}

---@class AzFuncState
---@field term_buf number|nil
---@field term_win number|nil
---@field job_id number|nil
local state = {
  term_buf = nil,
  term_win = nil,
  job_id = nil,
}

---@param cwd string
---@return string[]
local function find_csproj_files(cwd)
  return vim.fn.glob(cwd .. "/*.csproj", true, true)
end

---@param path string
---@return string
local function read_file(path)
  local lines = vim.fn.readfile(path)
  return table.concat(lines, "\n")
end

---@param csproj_text string
---@return boolean
local function has_azure_functions_markers(csproj_text)
  if csproj_text:match("Microsoft%.NET%.Sdk%.Functions") then
    return true
  end
  if csproj_text:match("Microsoft%.Azure%.Functions%.Worker") then
    return true
  end
  if csproj_text:match("AzureFunctionsVersion") then
    return true
  end
  return false
end

--- checks whether a directory is an Azure Functions C# project
---@param cwd string|nil
---@return boolean
function M.is_azure_functions_project(cwd)
  local root = cwd or vim.fn.getcwd()
  if vim.fn.filereadable(root .. "/host.json") ~= 1 then
    return false
  end

  for _, csproj in ipairs(find_csproj_files(root)) do
    if vim.fn.filereadable(csproj) == 1 and has_azure_functions_markers(read_file(csproj)) then
      return true
    end
  end

  return false
end

--- returns the terminal buffer (for dapui integration)
---@return number|nil
function M.get_term_buf()
  if state.term_buf and vim.api.nvim_buf_is_valid(state.term_buf) then
    return state.term_buf
  end
  return nil
end

--- stops the func host and cleans up the terminal
function M.stop()
  if state.job_id then
    pcall(vim.fn.jobstop, state.job_id)
    state.job_id = nil
  end
  if state.term_buf and vim.api.nvim_buf_is_valid(state.term_buf) then
    pcall(vim.api.nvim_buf_delete, state.term_buf, { force = true })
  end
  state.term_buf = nil
  state.term_win = nil
end

--- Stellt sicher, dass das func-Terminal sichtbar bleibt (nach dapui.open)
function M.ensure_term_visible()
  local buf = M.get_term_buf()
  if not buf then
    return
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      return
    end
  end

  vim.cmd("botright split | resize 15")
  vim.api.nvim_win_set_buf(0, buf)
  state.term_win = vim.api.nvim_get_current_win()
  vim.cmd("wincmd p")
end

---@class AzFuncProc
---@field pid number
---@field name string
---@field args string

---@return AzFuncProc[]
local function list_processes()
  local result = {}
  local output

  if vim.fn.has("win32") == 1 then
    local cmd = table.concat({
      [[powershell -NoProfile -Command "Get-CimInstance Win32_Process |]],
      [[ForEach-Object { '{0}|{1}|{2}' -f $_.ProcessId, $_.Name,]],
      [[($_.CommandLine -replace '\|', ' ') }"]],
    }, " ")
    output = vim.fn.system(cmd)
    for _, line in ipairs(vim.split(output, "\n", { trimempty = true })) do
      local pid, name, args = line:match("^(%d+)|([^|]*)|(.*)$")
      if pid and name then
        table.insert(result, {
          pid = tonumber(pid),
          name = name:lower(),
          args = (args or ""):lower(),
        })
      end
    end
  else
    local cmd = "ps -ax -o pid=,comm=,args="
    output = vim.fn.system(cmd)
    for _, line in ipairs(vim.split(output, "\n", { trimempty = true })) do
      local pid, name, args = line:match("^%s*(%d+)%s+([^%s]+)%s*(.*)$")
      if pid and name then
        table.insert(result, {
          pid = tonumber(pid),
          name = name:lower(),
          args = (args or ""):lower(),
        })
      end
    end
  end

  if vim.v.shell_error ~= 0 then
    return {}
  end

  return result
end

---@param csproj_path string
---@return string|nil
local function get_assembly_name_from_csproj(csproj_path)
  if vim.fn.filereadable(csproj_path) ~= 1 then
    return nil
  end

  local text = read_file(csproj_path)

  local assembly = text:match("<AssemblyName>(.-)</AssemblyName>")
  if assembly and assembly ~= "" then
    return assembly
  end

  return vim.fn.fnamemodify(csproj_path, ":t:r")
end

---@param root string
---@return string
local function get_project_assembly_name(root)
  for _, csproj in ipairs(find_csproj_files(root)) do
    local asm = get_assembly_name_from_csproj(csproj)
    if asm and asm ~= "" then
      return asm
    end
  end

  return vim.fn.fnamemodify(root, ":t")
end

---@param proc AzFuncProc
---@param assembly_name string
---@return integer
local function process_score(proc, assembly_name)
  local score = 0
  local lowered_assembly = assembly_name:lower()
  local dll_name = lowered_assembly .. ".dll"

  -- stark bevorzugen: echter isolated worker
  if proc.name == "dotnet" then
    score = score + 30
  end
  if proc.args:match(vim.pesc(dll_name)) then
    score = score + 220
  end
  if proc.args:match("%-%-host") then
    score = score + 80
  end
  if proc.args:match("%-%-port") then
    score = score + 80
  end
  if proc.args:match("workerid") or proc.args:match("%-%-worker") then
    score = score + 60
  end

  -- weichere Marker
  if proc.name:match(vim.pesc(lowered_assembly)) then
    score = score + 100
  end
  if proc.args:match(vim.pesc(lowered_assembly)) then
    score = score + 80
  end
  if proc.args:match("azure%.functions") or proc.args:match("webjobs") then
    score = score + 20
  end

  -- explizit abwerten: Host/Tooling statt App-Worker
  if proc.args:match("omnisharp") then
    score = score - 500
  end
  if proc.args:match("vbcscompiler") then
    score = score - 500
  end
  if proc.args:match("azure%-functions%-core%-tools") then
    score = score - 150
  end
  if proc.args:match("func start") or proc.args:match("func host start") then
    score = score - 150
  end

  return score
end

---@param cwd string|nil
---@return number|nil
function M.find_running_pid(cwd)
  local root = cwd or vim.fn.getcwd()
  local project_name = get_project_assembly_name(root)

  local best_score = -math.huge
  local best_pid = nil

  for _, proc in ipairs(list_processes()) do
    local score = process_score(proc, project_name)
    if score > best_score or (score == best_score and best_pid and proc.pid > best_pid) then
      best_score = score
      best_pid = proc.pid
    end
  end

  if best_score <= 0 then
    return nil
  end

  return best_pid
end

---@param proc table
---@return boolean
function M.is_likely_functions_process(proc)
  local name = (proc.name or ""):lower()
  local cmd = (proc.cmdline or proc.args or ""):lower()
  return name:match("func")
    or name:match("dotnet")
    or cmd:match("azure%.functions")
    or cmd:match("webjobs")
    or cmd:match("microsoft%.azure%.functions")
    or cmd:match("%.dll")
end

---@param opts table|nil
---@return string
function M.func_host_command(opts)
  local base = "func host start"
  local extra = opts and opts.extra_args or ""
  if extra ~= "" then
    return base .. " " .. extra
  end
  return base
end

--- tries to find the worker and invoke callback(pid) with retries
---@param root string
---@param callback fun(pid: number)
---@param opts table|nil
local function try_attach_with_retry(root, callback, opts)
  local max_attempts = (opts and opts.attach_retries) or 8
  local delay_ms = (opts and opts.attach_retry_delay_ms) or 1000
  local attempt = 0

  local function step()
    attempt = attempt + 1
    local pid = M.find_running_pid(root)

    if pid then
      vim.notify(
        string.format("Azure Functions: attaching to PID %d (attempt %d/%d)", pid, attempt, max_attempts),
        vim.log.levels.INFO
      )
      callback(pid)
      return
    end

    if attempt >= max_attempts then
      vim.notify("Azure Functions: worker process was not found", vim.log.levels.ERROR)
      return
    end

    vim.defer_fn(step, delay_ms)
  end

  step()
end

--- Builds and starts func host in a terminal, then calls callback(pid) when ready.
---@param callback fun(pid: number)
---@param opts table|nil
function M.start(callback, opts)
  local root = (opts and opts.cwd) or vim.fn.getcwd()

  if vim.fn.executable("func") ~= 1 then
    vim.notify("Azure Functions: 'func' not found. Install Azure Functions Core Tools.", vim.log.levels.ERROR)
    return
  end

  M.stop()

  vim.notify("Azure Functions: dotnet build ...", vim.log.levels.INFO)
  local build_result = vim.fn.system("dotnet build --nologo -v quiet")
  if vim.v.shell_error ~= 0 then
    vim.notify("Azure Functions: Build failed\n" .. build_result, vim.log.levels.ERROR)
    return
  end

  vim.cmd("botright split | resize 15")
  state.term_win = vim.api.nvim_get_current_win()

  local ready = false

  local function on_output(_, data)
    if ready then
      return
    end

    for _, line in ipairs(data or {}) do
      -- Host startup markers seen across runtime modes:
      -- - in-process: "Host lock lease acquired", "Job host started"
      -- - isolated worker: "Worker process started and initialized", "Host initialized"
      -- - common host readiness: "Now listening on", "Host started"
      if
        line:match("Worker process started and initialized")
        or line:match("Host lock lease acquired")
        or line:match("Job host started")
        or line:match("Now listening on")
        or line:match("Host started")
        or line:match("Host initialized")
      then
        ready = true
        vim.defer_fn(function()
          try_attach_with_retry(root, callback, opts)
        end, (opts and opts.initial_attach_delay_ms) or 3000)
        return
      end
    end
  end

  state.job_id = vim.fn.termopen(M.func_host_command(opts), {
    cwd = root,
    env = vim.fn.environ(),
    on_stdout = function(_, data)
      on_output(_, data)
    end,
    on_stderr = on_output,
    on_exit = function(_, code)
      vim.schedule(function()
        state.job_id = nil
        if not ready and code ~= 0 then
          vim.notify("Azure Functions: func host exited (" .. code .. ")", vim.log.levels.ERROR)
        end
      end)
    end,
  })

  state.term_buf = vim.api.nvim_get_current_buf()
  vim.cmd("wincmd p")

  -- Fallback timeout for when no ready signal is detected
  vim.defer_fn(function()
    if ready then
      return
    end

    ready = true
    vim.notify("Azure Functions: startup timeout, trying attach ...", vim.log.levels.WARN)
    try_attach_with_retry(root, callback, opts)
  end, (opts and opts.startup_timeout_ms) or 20000)
end

return M
