local formatting = require("utils.formatting")

local dotnet_format_running = {}

local function get_bufnr(ctx)
  if type(ctx) == "number" then
    return ctx
  end

  if type(ctx) == "table" then
    return ctx.bufnr or ctx.buf or 0
  end

  return 0
end

local function get_filename(ctx)
  if type(ctx) == "table" and ctx.filename then
    return ctx.filename
  end

  return vim.api.nvim_buf_get_name(get_bufnr(ctx))
end

local function prettier_formatter(ctx)
  local bufnr = get_bufnr(ctx)
  local config = formatting.get_project_config_path(bufnr)
  if not config then
    return nil
  end

  local project_root = vim.fs.dirname(config)
  local local_prettier = vim.fs.joinpath(project_root, ".tooling", "node_modules", ".bin", "prettier")
  local command = vim.fn.executable(local_prettier) == 1 and local_prettier or "prettier"
  local args = {
    "--config",
    config,
  }
  local ignore_path = vim.fs.joinpath(project_root, ".prettierignore")
  if vim.uv.fs_stat(ignore_path) then
    vim.list_extend(args, {
      "--ignore-path",
      ignore_path,
    })
  end
  vim.list_extend(args, {
    "--stdin-filepath",
    get_filename(ctx),
  })

  return {
    command = command,
    args = args,
    stdin = true,
  }
end

local function notify_once(message, level)
  if vim.notify_once then
    vim.notify_once(message, level)
  else
    vim.notify(message, level)
  end
end

local function find_dotnet_project(start_dir)
  local matches = vim.fs.find(function(name)
    return name:match("%.csproj$") or name:match("%.sln$")
  end, {
    path = start_dir,
    upward = true,
    type = "file",
  })

  return matches[1]
end

local function dotnet_format_file(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  if dotnet_format_running[bufnr] then
    return
  end

  if vim.bo[bufnr].filetype ~= "cs" then
    return
  end

  if vim.fn.executable("dotnet") ~= 1 then
    notify_once("C# format skipped: dotnet not found in PATH", vim.log.levels.WARN)
    return
  end

  if not formatting.get_project_config_path(bufnr, "cs") then
    return
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then
    return
  end

  local start_dir = vim.fs.dirname(filename)
  local project = find_dotnet_project(start_dir)

  if not project then
    vim.notify("C# format skipped: no .csproj or .sln found", vim.log.levels.INFO)
    return
  end

  local project_dir = vim.fs.dirname(project)
  local relative_file = vim.fs.relpath(project_dir, filename) or filename

  dotnet_format_running[bufnr] = true

  vim.system({
    "dotnet",
    "format",
    project,
    "--include",
    relative_file,
    "--no-restore",
    "--verbosity",
    "quiet",
  }, {
    cwd = project_dir,
  }, function(result)
    dotnet_format_running[bufnr] = nil

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      if result.code ~= 0 then
        vim.notify("C# format failed:\n" .. (result.stderr or result.stdout or ""), vim.log.levels.WARN)
        return
      end

      if not vim.bo[bufnr].modified then
        vim.cmd("checktime " .. bufnr)
      end
    end)
  end)
end

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },

  keys = {
    {
      "<leader>f",
      function()
        formatting.format_buffer()
      end,
      mode = "",
      desc = "[F]ormat buffer",
    },
    {
      "<leader>tf",
      function()
        formatting.toggle_format_on_save()
      end,
      mode = "",
      desc = "[T]oggle [F]ormat on save",
    },
  },

  init = function()
    local group = vim.api.nvim_create_augroup("voidcore-dotnet-format", { clear = true })

    vim.api.nvim_create_autocmd("BufWritePost", {
      group = group,
      pattern = "*.cs",
      callback = function(args)
        dotnet_format_file(args.buf)
      end,
    })
  end,

  opts = {
    notify_on_error = true,

    format_on_save = function(bufnr)
      -- C# is handled separately via dotnet format on BufWritePost.
      if vim.bo[bufnr].filetype == "cs" then
        return false
      end

      if not formatting.should_format_on_save(bufnr) then
        return false
      end

      return {
        timeout_ms = 10000,
        lsp_format = "never",
      }
    end,

    formatters_by_ft = {
      lua = { "stylua" },

      javascript = { "prettier" },
      typescript = { "prettier" },
      svelte = { "prettier" },
      json = { "prettier" },
      html = { "prettier" },
      css = { "prettier" },
      markdown = { "prettier" },
      yaml = { "prettier" },
      yml = { "prettier" },

      python = { "isort", "yapf" },

      powershell = { "pwshfmt" },
      ps1 = { "pwshfmt" },
      psm1 = { "pwshfmt" },
      psd1 = { "pwshfmt" },

      kotlin = { "ktlint" },

      xml = { "xmllint" },
    },

    formatters = {
      prettier = prettier_formatter,

      isort = function(ctx)
        local filename = get_filename(ctx)

        return {
          command = "isort",
          args = {
            "--filename",
            filename,
            "-",
          },
          stdin = true,
        }
      end,

      yapf = function(ctx)
        local bufnr = get_bufnr(ctx)
        local config = formatting.get_project_config_path(bufnr, "python")

        if not config then
          return nil
        end

        return {
          command = "yapf",
          args = {
            "--style",
            config,
          },
          stdin = true,
        }
      end,

      pwshfmt = function(ctx)
        local bufnr = get_bufnr(ctx)
        local settings = formatting.get_project_config_path(bufnr, "powershell")

        if not settings then
          return nil
        end

        return {
          command = "pwsh",
          args = {
            "-NonInteractive",
            "-ExecutionPolicy",
            "Bypass",
            "-Command",
            string.format(
              "$content = ($input | Out-String); Invoke-Formatter -ScriptDefinition $content -Settings '%s'",
              settings:gsub("'", "''")
            ),
          },
          stdin = true,
          timeout_ms = 80000,
        }
      end,

      ktlint = function(ctx)
        local filename = get_filename(ctx)

        return {
          command = "ktlint",
          args = {
            "-F",
            "--stdin",
            "--log-level=none",
          },
          stdin = true,
          timeout_ms = 8000,
          env = {
            KTLINT_STDIN_FILEPATH = filename,
          },
        }
      end,
    },
  },
}
