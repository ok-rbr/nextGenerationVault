-- YAML Language Server
-- Provides completion, validation, and hover for YAML files.
-- Includes Azure Pipelines schema auto-detection.
--
-- Install: Mason → yaml-language-server
-- Requires: npm install -g yaml-language-server

local M = {}

-- Azure Pipelines schema URL (official microsoft/azure-pipelines-vscode schema)
local azure_pipelines_schema =
  "https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/main/service-schema.json"

M.config = {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml" },
  root_markers = { ".git", vim.uv.cwd() },
  settings = {
    yaml = {
      validate = true,
      hover = true,
      completion = true,
      format = {
        enable = false,
      },
      -- Schema store integration: auto-detect well-known schemas by filename.
      -- The azure-pipelines entry below is matched explicitly by file glob.
      schemaStore = {
        enable = true,
        url = "https://www.schemastore.org/api/json/catalog.json",
      },
      schemas = {
        -- Azure Pipelines: match common naming conventions
        [azure_pipelines_schema] = {
          "azure-pipelines*.yml",
          "azure-pipelines*.yaml",

          "*.pipeline.yml",
          "*.pipeline.yaml",

          "pipeline.yml",
          "pipeline.yaml",

          "scripts/pipeline.yml",
          "scripts/pipeline.yaml",

          ".azure/*.yml",
          ".azure/*.yaml",

          "pipelines/*.yml",
          "pipelines/*.yaml",
        },
        -- GitHub Actions (also commonly edited alongside Azure Pipelines)
        ["https://json.schemastore.org/github-workflow.json"] = {
          ".github/workflows/*.yml",
          ".github/workflows/*.yaml",
        },
        -- Docker Compose
        ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
          "docker-compose*.yml",
          "docker-compose*.yaml",
        },
      },
    },
  },
}

return M
