-- Docker utilities for DAP auto-detection
-- Detects debugpy configuration (port, WORKDIR) from docker-compose.yml and Dockerfile.

local M = {}

--- Maximum number of parent directories to traverse when searching for a
--- docker-compose.yml file.
local MAX_TRAVERSAL_DEPTH = 20

--- Number of lines above and below a 'debugpy' mention to search for a
--- port mapping when the '--listen' argument is not found directly.
local PORT_SEARCH_WINDOW = 10

-- Simple last-call cache for detect_debugpy_config.
-- Both 'port' and 'remoteRoot' functions in the DAP config table call
-- detect_debugpy_config independently, so caching avoids reading the same
-- files twice within a single debug-session start sequence.
local _detect_cache = { cwd = nil, valid = false, result = nil }

--- Find docker-compose.yml by traversing parent directories from start_dir.
--- Accepts both .yml and .yaml extensions.
--- @param start_dir string Directory to start searching from
--- @return string|nil Absolute path to the compose file, or nil if not found
function M.find_docker_compose(start_dir)
  local sep = package.config:sub(1, 1)
  local dir = start_dir
  local names = { "docker-compose.yml", "docker-compose.yaml" }

  for _ = 1, MAX_TRAVERSAL_DEPTH do
    for _, name in ipairs(names) do
      local path = dir .. sep .. name
      if vim.fn.filereadable(path) == 1 then
        return path
      end
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then
      break
    end -- reached filesystem root
    dir = parent
  end

  return nil
end

--- Parse a docker-compose.yml to find the debugpy listen port.
--- Uses three strategies in order:
---   1. '--listen [host:]port' on the same line as 'debugpy'
---   2. Whitespace-collapsed full-file search for debugpy … --listen
---   3. Port mapping (HOST:CONTAINER) within ±10 lines of a 'debugpy' mention
--- @param compose_path string Path to docker-compose.yml
--- @return integer|nil Detected port number, or nil if not found
function M.parse_debugpy_port(compose_path)
  local lines = vim.fn.readfile(compose_path)
  if not lines then
    return nil
  end

  -- Strategy 1: '--listen [host:]port' on the same line as 'debugpy'
  for _, line in ipairs(lines) do
    if line:match("debugpy") then
      local port = line:match("%-%-listen%s+%S-:(%d+)") or line:match("%-%-listen%s+(%d+)")
      if port then
        return tonumber(port)
      end
    end
  end

  -- Strategy 2: reached only when Strategy 1 found no port.
  -- Flatten content (handles multi-line YAML lists where command
  -- args are spread over multiple lines) and search for debugpy … --listen.
  -- '.-' is Lua's lazy quantifier (matches as few chars as possible), so the
  -- pattern finds the nearest '--listen' after any 'debugpy' occurrence.
  -- '%-?%s*' skips an optional YAML list-item separator ('- ') that appears
  -- between '--listen' and the port when args are split across list items.
  local content = table.concat(lines, " ")
  content = content:gsub("%s+", " ")
  local port = content:match("debugpy.-%-%-listen%s+%-?%s*%S-:(%d+)")
    or content:match("debugpy.-%-%-listen%s+%-?%s*(%d+)")
  if port then
    return tonumber(port)
  end

  -- Strategy 3: port mapping (HOST:CONTAINER) within ±10 lines of any
  -- line that mentions 'debugpy'
  for i, line in ipairs(lines) do
    if line:match("debugpy") then
      local lo = math.max(1, i - PORT_SEARCH_WINDOW)
      local hi = math.min(#lines, i + PORT_SEARCH_WINDOW)
      for j = lo, hi do
        -- Match quoted form: "5678:5678" or '5678:5678'
        local host_port = lines[j]:match('"(%d+):%d+"') or lines[j]:match("'(%d+):%d+'")
        -- Match unquoted form: - 5678:5678 (leading whitespace / dash)
        if not host_port then
          host_port = lines[j]:match("^%s*%-%s*(%d+):%d+%s*$")
        end
        if host_port then
          return tonumber(host_port)
        end
      end
    end
  end

  return nil
end

--- Find a Dockerfile in the given directory.
--- Checks common names: Dockerfile, Dockerfile.dev, Dockerfile.debug.
--- @param dir string Directory to search in
--- @return string|nil Absolute path to the Dockerfile, or nil if not found
function M.find_dockerfile(dir)
  local sep = package.config:sub(1, 1)
  local names = {
    "Dockerfile",
    "Dockerfile.dev",
    "Dockerfile.debug",
    "dockerfile",
  }
  for _, name in ipairs(names) do
    local path = dir .. sep .. name
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end
  return nil
end

--- Parse the effective WORKDIR from a Dockerfile.
--- Returns the value of the last WORKDIR instruction, which is the directory
--- the container process starts in.
--- @param dockerfile_path string Path to the Dockerfile
--- @return string|nil WORKDIR value, or nil if not found
function M.parse_workdir(dockerfile_path)
  local lines = vim.fn.readfile(dockerfile_path)
  if not lines then
    return nil
  end

  -- The last WORKDIR instruction is the effective one
  local workdir = nil
  for _, line in ipairs(lines) do
    local dir = line:match("^%s*WORKDIR%s+(%S+)")
    if dir then
      workdir = dir
    end
  end
  return workdir
end

--- Auto-detect debugpy configuration from docker-compose.yml and Dockerfile.
---
--- Traverses parent directories starting from cwd to locate a
--- docker-compose.yml, then extracts the debugpy listen port and, if a
--- Dockerfile is present alongside the compose file, the container WORKDIR.
---
--- Results are cached by cwd for the lifetime of the Neovim session so that
--- repeated calls during a single debug-session start (one for `port`, one for
--- `remoteRoot`) do not re-read the same files. The cache is not invalidated
--- when files change on disk; restart Neovim to pick up changes.
---
--- @param cwd string|nil Starting directory (defaults to vim.fn.getcwd())
--- @return {port: integer, remote_root: string|nil}|nil
---   Table with detected values, or nil when no docker-compose.yml is found
---   or no debugpy port can be determined.
function M.detect_debugpy_config(cwd)
  cwd = cwd or vim.fn.getcwd()

  -- Return cached result when the cwd is unchanged (both 'port' and
  -- 'remoteRoot' DAP config functions call this independently).
  if _detect_cache.valid and _detect_cache.cwd == cwd then
    return _detect_cache.result
  end

  -- Inner helper: compute result with early returns for clarity.
  local function compute()
    local compose_path = M.find_docker_compose(cwd)
    if not compose_path then
      return nil
    end

    local port = M.parse_debugpy_port(compose_path)
    if not port then
      return nil
    end

    local compose_dir = vim.fn.fnamemodify(compose_path, ":h")
    local dockerfile_path = M.find_dockerfile(compose_dir)
    return {
      port = port,
      remote_root = dockerfile_path and M.parse_workdir(dockerfile_path) or nil,
    }
  end

  local result = compute()
  _detect_cache.cwd = cwd
  _detect_cache.valid = true
  _detect_cache.result = result
  return result
end

return M
