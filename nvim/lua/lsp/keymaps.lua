-- LSP keymap configuration.
--
-- This module registers buffer-local LSP behavior on LspAttach.
-- Global editor keymaps live in `config.keymaps`.

local M = {}

local semantic_token_clients = {
  "omnisharp",
  "ts_ls",
  "kotlin_language_server",
  "basedpyright",
}

local function configure_buffer_options(bufnr, client)
  if client.server_capabilities.completionProvider then
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
  end

  if client.server_capabilities.definitionProvider then
    vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
  end
end

local function configure_semantic_tokens(client)
  if not vim.tbl_contains(semantic_token_clients, client.name) then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

local function set_lsp_keymaps(bufnr)
  local keymap = vim.keymap.set
  local lsp = vim.lsp
  local opts = { silent = true, buffer = bufnr }

  local function opt(desc, extra)
    return vim.tbl_extend("force", opts, { desc = desc }, extra or {})
  end

  keymap("n", "gd", lsp.buf.definition, opt("Go to definition"))
  keymap("n", "gD", lsp.buf.declaration, opt("Go to declaration"))

  keymap("n", "gi", function()
    lsp.buf.implementation({ border = "single" })
  end, opt("Go to implementation"))

  keymap("n", "gr", lsp.buf.references, opt("Show References"))
  keymap("n", "gl", vim.diagnostic.open_float, opt("Open diagnostic in float"))
  keymap("n", "<C-k>", lsp.buf.signature_help, opt("Signature help"))

  pcall(vim.keymap.del, "n", "K", { buffer = bufnr })

  keymap("n", "K", function()
    lsp.buf.hover({ border = "single", max_height = 30, max_width = 120 })
  end, opt("Toggle hover"))

  keymap("n", "<leader>lF", function()
    require("utils.formatting").toggle_format_on_save()
  end, opt("Toggle AutoFormat"))

  keymap("n", "<leader>lI", vim.cmd.Mason, opt("Mason"))
  keymap("n", "<leader>lS", lsp.buf.workspace_symbol, opt("Workspace Symbols"))
  keymap("n", "<leader>la", lsp.buf.code_action, opt("Code Action"))

  keymap("n", "<leader>lh", function()
    lsp.inlay_hint.enable(not lsp.inlay_hint.is_enabled({}))
  end, opt("Toggle Inlayhints"))

  keymap("n", "<leader>li", vim.cmd.LspInfo, opt("LspInfo"))
  keymap("n", "<leader>ll", lsp.codelens.run, opt("Run CodeLens"))
  keymap("n", "<leader>lr", lsp.buf.rename, opt("Rename"))
  keymap("n", "<leader>ls", lsp.buf.document_symbol, opt("Document Symbols"))

  keymap("n", "<leader>dn", function()
    vim.diagnostic.jump({ count = 1, float = true })
  end, opt("Next Diagnostic"))

  keymap("n", "<leader>dp", function()
    vim.diagnostic.jump({ count = -1, float = true })
  end, opt("Prev Diagnostic"))

  keymap("n", "<leader>dl", vim.diagnostic.setloclist, opt("Set LocList"))

  keymap("n", "<leader>dv", function()
    vim.diagnostic.config({
      virtual_lines = not vim.diagnostic.config().virtual_lines,
    })
  end, opt("Toggle diagnostic virtual_lines"))
end

local function on_lsp_attach(ev)
  local bufnr = ev.buf
  local client = vim.lsp.get_client_by_id(ev.data.client_id)

  if not client then
    return
  end

  configure_buffer_options(bufnr, client)
  configure_semantic_tokens(client)
  set_lsp_keymaps(bufnr)
end

function M.setup()
  for _, bind in ipairs({ "grn", "gra", "gri", "grr" }) do
    pcall(vim.keymap.del, "n", bind)
  end

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = on_lsp_attach,
  })
end

return M
