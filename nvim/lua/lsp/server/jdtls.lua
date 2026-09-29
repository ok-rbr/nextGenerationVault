-- Java Language Server (JDTLS)

local M = {}

-- Collect java-debug bundles installed via Mason.
-- Returns an empty list if the package is not installed yet, so the server
-- starts without error and bundles are loaded once they are available.
local function get_bundles()
  local bundles = {}

  -- java-debug-adapter: required for DAP support.
  -- Mason installs exactly one version at a time; take the newest jar in case
  -- multiple versions are present from manual installs.
  local debug_jars = vim.fn.glob(
    vim.fn.stdpath("data")
      .. "/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
    true,
    true
  )
  if #debug_jars > 0 then
    table.sort(debug_jars)
    table.insert(bundles, debug_jars[#debug_jars])
  end

  return bundles
end

M.config = {
  cmd = { "jdtls" },
  filetypes = { "java" },
  root_markers = { "pom.xml", "build.gradle", ".git" },
  settings = {
    java = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = "fernflower" },
      completion = {
        favoriteStaticMembers = {
          "org.junit.Assert.*",
          "java.util.Objects.requireNonNull",
        },
      },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
      },
    },
  },
  init_options = {
    bundles = get_bundles(),
  },
  on_attach = function(client, bufnr)
    -- Enable DAP integration once the server is attached and bundles are loaded.
    -- setup_dap() must be called here (not during plugin init) because it
    -- requires a live jdtls session to register the debug adapter.
    local ok, jdtls = pcall(require, "jdtls")
    if ok and jdtls.setup_dap then
      jdtls.setup_dap({ hotcodereplace = "auto" })
    end
  end,
}

return M
