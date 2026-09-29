-- LSP command configuration.
--
-- This module registers user-facing LSP commands.

local M = {}

local function get_attached_client_names()
  local client_names = {}

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    table.insert(client_names, client.name)
  end

  return client_names
end

local function stop_clients(opts)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    if opts.args == "" or opts.args == client.name then
      client:stop(true)
      vim.notify(client.name .. ": stopped")
    end
  end
end

local function restart_clients()
  local detach_clients = {}

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    client:stop(true)

    if vim.tbl_count(client.attached_buffers) > 0 then
      detach_clients[client.name] = {
        client,
        vim.lsp.get_buffers_by_client_id(client.id),
      }
    end
  end

  local timer = vim.uv.new_timer()
  if not timer then
    return vim.notify("Servers are stopped but have not been restarted", vim.log.levels.WARN)
  end

  timer:start(
    100,
    50,
    vim.schedule_wrap(function()
      for name, client in pairs(detach_clients) do
        local client_id = vim.lsp.start(client[1].config, { attach = false })

        if client_id then
          for _, buf in ipairs(client[2]) do
            vim.lsp.buf_attach_client(buf, client_id)
          end

          vim.notify(name .. ": restarted")
        end

        detach_clients[name] = nil
      end

      if next(detach_clients) == nil and not timer:is_closing() then
        timer:close()
      end
    end)
  )
end

function M.setup()
  vim.api.nvim_create_user_command("LspStart", function()
    vim.cmd.e()
  end, {
    desc = "Start LSP clients in the current buffer",
  })

  vim.api.nvim_create_user_command("LspStop", stop_clients, {
    desc = "Stop all LSP clients or a specific client attached to the current buffer",
    nargs = "?",
    complete = function()
      return get_attached_client_names()
    end,
  })

  vim.api.nvim_create_user_command("LspRestart", restart_clients, {
    desc = "Restart all LSP clients attached to the current buffer",
  })

  vim.api.nvim_create_user_command("LspLog", function()
    vim.cmd.vsplit(vim.lsp.log.get_filename())
  end, {
    desc = "Open the LSP log",
  })

  vim.api.nvim_create_user_command("LspInfo", function()
    vim.cmd("silent checkhealth vim.lsp")
  end, {
    desc = "Show LSP health information",
  })
end

return M
