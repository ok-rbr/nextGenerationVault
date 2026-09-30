-- notes/project_generator.lua
-- creates project templates based on default templates
--
-- workflow:
-- 0. derives client_slug and project_slug from the names and enforces the
--    slug grammar from docs/WORK_TAXONOMY.md on both
-- 1. loads templates from <templates_dir>/<projects_dir>/default/
-- 2. removes JS/script blocks
-- 3. replaces project/client metadata, order number and technologies
-- 4. keeps other variables ({{ title }}, {{ id }}, {{ created }}) for :NoteTemplate
-- 5. saves to <templates_dir>/<projects_dir>/<client_slug>/<project_slug>/
-- 6. creates/updates the client index below 03_resources/clients/<client_slug>/

local utils = require("notes.utils")
local frontmatter = require("notes.frontmatter")

local M = {}

-- Paths (derived from the centralized notes.init config so the templates,
-- projects and resources directories only need to be changed in one place)
local NOTES_CONFIG = require("notes.init").config
local TEMPLATES_DIR = NOTES_CONFIG.directories.templates
local PROJECT_DIR = NOTES_CONFIG.directories.projects
local DEFAULT_TEMPLATES_DIR = TEMPLATES_DIR .. "/" .. PROJECT_DIR .. "/default"
local OUTPUT_TEMPLATES_DIR = TEMPLATES_DIR .. "/" .. PROJECT_DIR
local CLIENT_DIR = NOTES_CONFIG.directories.resources .. "/clients"

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

---Read file content
---@param filepath string
---@return string|nil content
---@return string|nil err
local function read_file(filepath)
  local bufnr = vim.fn.bufnr(filepath)
  if bufnr >= 0 and vim.api.nvim_buf_is_loaded(bufnr) then
    local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
    if vim.bo[bufnr].endofline then
      content = content .. "\n"
    end
    return content, nil
  end

  local file, err = io.open(filepath, "r")
  if not file then
    return nil, string.format("cannot read %s: %s", filepath, err or "unknown error")
  end

  local content = file:read("*all")
  file:close()
  if not content then
    return nil, string.format("cannot read contents of %s", filepath)
  end
  return content, nil
end

---Write file content, updating an open buffer instead of racing it on disk.
---@param filepath string
---@param content string
---@return boolean success
---@return string|nil err
local function write_file(filepath, content)
  local bufnr = vim.fn.bufnr(filepath)
  if bufnr >= 0 and vim.api.nvim_buf_is_loaded(bufnr) then
    local ok, err = pcall(function()
      local endofline = content:sub(-1) == "\n"
      local lines = vim.split(content, "\n", { plain = true })
      if endofline then
        table.remove(lines)
      end
      if #lines == 0 then
        lines = { "" }
      end
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      vim.bo[bufnr].endofline = endofline
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("silent write")
      end)
    end)
    if not ok then
      return false, string.format("cannot update open buffer %s: %s", filepath, tostring(err))
    end
    require("notes.vault_index").invalidate()
    return true, nil
  end

  local file, err = io.open(filepath, "w")
  if not file then
    return false, string.format("cannot write %s: %s", filepath, err or "unknown error")
  end
  local ok, write_err = file:write(content)
  local close_ok, close_err = file:close()
  if not ok then
    return false, string.format("cannot write %s: %s", filepath, write_err or "unknown error")
  end
  if not close_ok then
    return false, string.format("cannot close %s: %s", filepath, close_err or "unknown error")
  end

  require("notes.vault_index").invalidate()
  return true, nil
end

---Create a new file without replacing user-owned content.
---@param filepath string
---@param content string
---@return boolean success
---@return string|nil err
local function write_new_file(filepath, content)
  if utils.path_is_taken(filepath) then
    return false, "refusing to overwrite existing file: " .. filepath
  end
  return write_file(filepath, content)
end

---Ensure a directory exists and report failures to the user.
---@param path string
---@param description string
---@return boolean success
---@return string|nil err
local function ensure_dir(path, description)
  if utils.ensure_dir(path) then
    return true, nil
  end

  local err = string.format("unable to create %s: %s", description, path)
  vim.notify(err, vim.log.levels.ERROR)
  return false, err
end

local function report_error(context, err)
  local message = context .. (err and (": " .. err) or "")
  vim.notify("Project generation failed — " .. message, vim.log.levels.ERROR)
end

---Remove JS/Script blocks from content
---@param content string
---@return string
local function remove_scripts(content)
  local result = content
  -- Remove <%* ... -%> blocks (Templater)
  result = result:gsub("<%%*.-%-%%>", "")
  result = result:gsub("<%%*.-%%>", "")
  -- Remove <% ... %> inline
  result = result:gsub("<%%.-%%>", "")
  -- Remove ```js or ```javascript blocks
  result = result:gsub("```javascript.-```", "")
  result = result:gsub("```js.-```", "")
  -- Remove <script>...</script>
  result = result:gsub("<script>.-</script>", "")
  -- Clean up multiple blank lines
  result = result:gsub("\n\n\n+", "\n\n")
  return result
end

---Replace all project/client placeholders in frontmatter and body
---@param content string
---@param vars table
---@return string
local function replace_placeholders(content, vars)
  local project_index_id = vars.project_index_id or (vars.client_slug .. "_" .. vars.project_slug .. "_index")
  local replacements = {
    project_name = vars.project_name,
    project_slug = vars.project_slug,
    project_tag = vars.project_slug,
    project_index_id = project_index_id,
    client_name = vars.client_name,
    client_slug = vars.client_slug,
    client_tag = vars.client_slug,
    client_index_id = vars.client_slug .. "_client_index",
    order_number = vars.order_number,
    technologies = vars.technologies,
  }

  local result = content:gsub("{{%s*project_slug%s*}}_index", function()
    return project_index_id
  end)

  for placeholder, value in pairs(replacements) do
    local safe_value = tostring(value):gsub("%%", "%%%%")
    local pattern = "{{%s*" .. placeholder .. "%s*}}"
    result = result:gsub(pattern, safe_value)
  end

  return result
end

---Update location in frontmatter
---@param content string
---@param project_slug string
---@param subdir string|nil
---@return string
local function update_location(content, vars, subdir)
  local location = PROJECT_DIR .. "/" .. vars.client_slug .. "/" .. vars.project_slug
  if subdir and subdir ~= "" then
    location = location .. "/" .. subdir
  end

  -- Replace existing location line
  local result = content:gsub('location: "[^"]*"', 'location: "' .. location .. '"')

  return result
end

---Add project/client references to template frontmatter
---@param content string Template content
---@param vars table {project_slug: string, client_slug: string}
---@return string|nil updated
---@return string|nil err
local function update_project_frontmatter(content, vars)
  local lines = vim.split(content, "\n")

  local end_line = frontmatter.block_end(lines)
  if not end_line then
    return nil, "template has no valid YAML frontmatter"
  end

  local fm = frontmatter.parse_yaml(lines)
  if not fm then
    return nil, "template frontmatter could not be parsed"
  end

  -- Ensure project/<slug> and client/<slug> are in the tags list
  local project_tag = "project/" .. vars.project_slug
  local client_tag = "client/" .. vars.client_slug

  fm.tags = utils.normalize_tags(fm.tags)

  if not vim.tbl_contains(fm.tags, project_tag) then
    table.insert(fm.tags, project_tag)
  end

  if not vim.tbl_contains(fm.tags, client_tag) then
    table.insert(fm.tags, client_tag)
  end

  -- Always set the project and client fields for generated project templates
  fm.project = vars.project_slug
  fm.client = vars.client_slug
  fm.order_number = vars.order_number
  fm.technologies = vars.technologies

  -- Reconstruct: new YAML frontmatter + original body
  local body_lines = {}
  for i = end_line + 1, #lines do
    table.insert(body_lines, lines[i])
  end

  return frontmatter.render_yaml(fm) .. table.concat(body_lines, "\n"), nil
end

---Get template subdir from filename
---@param filename string
---@return string
local function get_subdir(filename)
  if filename:match("daily") then
    return "daily"
  elseif filename:match("docs") then
    return "docs"
  elseif filename:match("meetings") then
    return "meetings"
  elseif filename:match("weekly") then
    return "weekly"
  elseif filename:match("monthly") then
    return "monthly"
  elseif filename:match("scripts") then
    return "scripts"
  elseif filename:match("task") then
    return "tasks"
  else
    return ""
  end
end

-- ============================================================================
-- CLIENT NOTE HANDLING
-- ============================================================================

---The client index's filename stem, and therefore its wiki-link target and its
---frontmatter id. It carries the client slug because every client used to get a
---file called plain `client_index.md`: with one per client, `[[client_index]]`
---named all of them and none of them, which is precisely the ambiguity that
---made links unresolvable (docs/ADR-005).
---@param client_slug string
---@return string
local function client_index_stem(client_slug)
  return client_slug .. "_client_index"
end

---Find existing client note. Indexes written before the rename above still use
---the ambiguous `client_index.md`, so both names are accepted on read; only the
---unambiguous one is ever written.
---@param client_slug string
---@return string|nil filepath
local function find_client_note(client_slug)
  local vault_root = utils.get_notebook_root()
  local client_dir = utils.path_join(vault_root, CLIENT_DIR, client_slug)

  for _, name in ipairs({ client_index_stem(client_slug) .. ".md", "client_index.md" }) do
    local filepath = utils.path_join(client_dir, name)
    if utils.file_exists(filepath) then
      return filepath
    end
  end

  return nil
end

---The stable stem for a project index in this client namespace.
---@param vars table
---@return string
local function project_index_stem(vars)
  return vars.client_slug .. "_" .. vars.project_slug .. "_index"
end

---Add project link to existing client note
---@param filepath string
---@param vars table
---@return boolean
local function add_project_to_client(filepath, vars)
  local content, read_err = read_file(filepath)
  if not content then
    return false, read_err
  end

  -- Link by filename stem, never by vault path. The native resolver matches a stem
  -- anywhere in the vault, so a stem link survives the note being moved or
  -- archived; a path link names one location and dies the moment PARA routing
  -- moves the file (docs/ADR-005).
  local index_id = vars.project_index_id or project_index_stem(vars)
  local project_link = index_id .. "|" .. vars.project_name

  -- Match the full target so a slug prefix cannot suppress a distinct project.
  if content:find("[[" .. index_id .. "|", 1, true) or content:find("[[" .. index_id .. "]]", 1, true) then
    vim.notify("  Project already linked in client note", vim.log.levels.INFO)
    return true
  end

  local link = "- [[" .. project_link .. "]]"

  -- Find the "## Projects" / "## Projekte" heading (as a whole line) and
  -- insert the link directly below it. Simple, line-based lookup instead of
  -- a fragile combined regex.
  local lines = vim.split(content, "\n")
  local heading_line = nil

  for i, line in ipairs(lines) do
    if line:match("^##%s*Projects%s*$") or line:match("^##%s*Projekte%s*$") then
      heading_line = i
      break
    end
  end

  if heading_line then
    table.insert(lines, heading_line + 1, link)
    content = table.concat(lines, "\n")
  else
    -- No section found: append a new "## Projects" section at the end
    content = content .. "\n## Projects\n\n" .. link .. "\n"
  end

  return write_file(filepath, content)
end

---Create new client note
---@param vars table {client_name: string, client_slug: string, project_name: string}
---@return string|nil filepath
local function create_client_note(vars)
  local vault_root = utils.get_notebook_root()
  local client_dir = utils.path_join(vault_root, CLIENT_DIR, vars.client_slug)
  if not ensure_dir(client_dir, "client directory") then
    return nil
  end

  local filepath = utils.path_join(client_dir, client_index_stem(vars.client_slug) .. ".md")

  -- Build frontmatter via notes.frontmatter so field values (client_name may
  -- contain quotes/colons) are escaped correctly instead of being
  -- string-concatenated into raw YAML.
  local fm = {
    title = vars.client_name,
    id = client_index_stem(vars.client_slug),
    created = utils.now_iso(),
    updated = utils.now_iso(),
    tags = { "client/" .. vars.client_slug },
    category = "client",
    client = vars.client_slug,
    status = "active",
    related = {},
    concepts = {},
    aliases = { vars.client_name },
  }

  local content = frontmatter.render_yaml(fm) .. "\n"
  content = content .. "# " .. vars.client_name .. "\n\n"
  content = content .. "## Client Information\n\n"
  content = content .. "- **Name**: " .. vars.client_name .. "\n"
  content = content .. "- **Slug**: " .. vars.client_slug .. "\n"
  content = content .. "- **Status**: active\n\n"
  content = content .. "## Projects\n\n"
  content = content
    .. "- [["
    .. (vars.project_index_id or project_index_stem(vars))
    .. "|"
    .. vars.project_name
    .. "]]\n\n"
  -- No empty "- [[ ]]" placeholders: they are broken links by construction and
  -- every link check in the vault has to report them.
  content = content .. "## Contacts\n\n## Notes\n"

  local ok, err = write_new_file(filepath, content)
  if ok then
    return filepath, nil
  end

  return nil, err
end

---Ensure client note exists and contains project link
---@param vars table
---@return string|nil filepath
local function ensure_client_note(vars)
  local existing = find_client_note(vars.client_slug)

  if existing then
    vim.notify("✓ Found existing client note", vim.log.levels.INFO)
    local ok, err = add_project_to_client(existing, vars)
    if ok then
      return existing, nil
    end

    return nil, err
  else
    vim.notify("Creating new client note...", vim.log.levels.INFO)
    local path, err = create_client_note(vars)

    if path then
      vim.notify("✓ Created client index: " .. path, vim.log.levels.INFO)
    end

    return path, err
  end
end

-- ============================================================================
-- PROJECT INDEX HANDLING
-- ============================================================================

---Create the project's index note unless it already exists.
---@param vars table {project_name: string, project_slug: string, client_name: string, client_slug: string}
---@return string|nil filepath
local function ensure_project_index(vars)
  local vault_root = utils.get_notebook_root()
  local project_dir = utils.path_join(vault_root, PROJECT_DIR, vars.client_slug, vars.project_slug)

  if not ensure_dir(project_dir, "project directory") then
    return nil
  end

  local composite_stem = project_index_stem(vars)
  local legacy_stem = vars.project_slug .. "_index"
  for _, stem in ipairs({ composite_stem, legacy_stem }) do
    local filepath = utils.path_join(project_dir, stem .. ".md")
    if utils.file_exists(filepath) then
      vars.project_index_id = stem
      vim.notify("✓ Found existing project index", vim.log.levels.INFO)
      return filepath
    end
  end

  vars.project_index_id = composite_stem
  local filepath = utils.path_join(project_dir, composite_stem .. ".md")
  if utils.path_is_taken(filepath) then
    return nil, "project index already exists or is open: " .. filepath
  end

  local content = frontmatter.render_yaml(frontmatter.build_project({
    name = vars.project_name,
    id = composite_stem,
    client = vars.client_slug,
    project = vars.project_slug,
    order_number = vars.order_number,
    technologies = vars.technologies,
    tags = {
      "project",
      "project/" .. vars.project_slug,
      "client/" .. vars.client_slug,
    },
  })) .. "\n"
  content = content .. "# " .. vars.project_name .. "\n\n"
  content = content .. "## Client\n\n"
  content = content .. "- [[" .. client_index_stem(vars.client_slug) .. "|" .. vars.client_name .. "]]\n\n"
  content = content .. "## Overview\n\n"
  content = content .. "- Order number: " .. vars.order_number .. "\n"
  content = content .. "- Technologies: " .. vars.technologies .. "\n\n"
  content = content .. "## Notes\n\n"

  local ok, err = write_new_file(filepath, content)
  if ok then
    vim.notify("✓ Created project index: " .. composite_stem .. ".md", vim.log.levels.INFO)
    return filepath, nil
  end

  return nil, err
end

-- ============================================================================
-- TEMPLATE GENERATION
-- ============================================================================

---Get all default templates
---@return table templates
---@return string|nil err
local function get_default_templates()
  local vault_root = utils.get_notebook_root()
  local templates_dir = utils.path_join(vault_root, DEFAULT_TEMPLATES_DIR)
  if not utils.dir_exists(templates_dir) then
    return {}, "default template directory does not exist: " .. templates_dir
  end

  local files = vim.fn.glob(templates_dir .. "/*.md", false, true)

  local templates = {}

  for _, filepath in ipairs(files) do
    local filename = vim.fn.fnamemodify(filepath, ":t")

    -- Skip company template and README
    if not filename:match("company") and filename ~= "README.md" then
      table.insert(templates, {
        filepath = filepath,
        filename = filename,
      })
    end
  end

  if #templates == 0 then
    return {}, "no project templates found in " .. templates_dir
  end

  return templates, nil
end

---Create project templates from defaults
---@param vars table
---@return boolean success
---@return number created
---@return string[] errors
---@return number kept
local function create_project_templates(vars)
  local vault_root = utils.get_notebook_root()
  local errors = {}

  -- Create output directory: <templates dir>/<projects dir>/<client_slug>/<project_slug>/
  local output_dir = utils.path_join(vault_root, OUTPUT_TEMPLATES_DIR, vars.client_slug, vars.project_slug)
  if not ensure_dir(output_dir, "project template directory") then
    return false, 0, { "project template directory: " .. output_dir }
  end

  -- Create project directory structure: <PROJECT_DIR>/<client_slug>/<project_slug>/
  local project_dir = utils.path_join(vault_root, PROJECT_DIR, vars.client_slug, vars.project_slug)
  local subdirs = {
    "daily",
    "docs",
    "meetings",
    "weekly",
    "monthly",
    "scripts",
    "tasks",
  }

  for _, subdir in ipairs(subdirs) do
    if not ensure_dir(utils.path_join(project_dir, subdir), "project subdirectory") then
      return false, 0, { "project subdirectory: " .. subdir }
    end
  end

  -- Process templates
  local templates, template_err = get_default_templates()
  if template_err then
    return false, 0, { template_err }
  end
  local created = 0
  local kept = 0

  for _, tpl in ipairs(templates) do
    local content, read_err = read_file(tpl.filepath)

    if content then
      -- 1. Remove JS/scripts
      content = remove_scripts(content)

      -- 2. Replace project/client placeholders
      content = replace_placeholders(content, vars)

      -- 3. Update location
      local subdir = get_subdir(tpl.filename)
      content = update_location(content, vars, subdir)

      -- 4. Add project/client frontmatter references
      local updated_content, frontmatter_err = update_project_frontmatter(content, vars)
      if not updated_content then
        local err = string.format("%s: %s", tpl.filepath, frontmatter_err or "invalid frontmatter")
        table.insert(errors, err)
        vim.notify("  ✗ " .. err, vim.log.levels.ERROR)
      else
        content = updated_content

        -- 5. Generate output filename: <project_slug>_<type>_default.md
        local tpl_type = tpl.filename:gsub("^projects_", "")
        local output_filename = vars.project_slug .. "_" .. tpl_type
        local output_path = utils.path_join(output_dir, output_filename)

        if utils.path_is_taken(output_path) then
          kept = kept + 1
          vim.notify("  · Keeping existing template: " .. output_filename, vim.log.levels.INFO)
        else
          local ok, write_err = write_new_file(output_path, content)
          if ok then
            created = created + 1
            vim.notify("  ✓ " .. output_filename, vim.log.levels.INFO)
          else
            local err = write_err or ("cannot write " .. output_path)
            table.insert(errors, err)
            vim.notify("  ✗ " .. err, vim.log.levels.ERROR)
          end
        end
      end
    else
      local err = read_err or ("cannot read " .. tpl.filepath)
      table.insert(errors, err)
      vim.notify("  ✗ " .. err, vim.log.levels.ERROR)
    end
  end

  return created + kept > 0 and #errors == 0, created, errors, kept
end

-- ============================================================================
-- SLUG ENFORCEMENT
-- ============================================================================

---Derive a slug from a name, let the user correct it, and enforce the
---repository-wide slug grammar on the result.
---
---The slug is not free text. It is the single identifier this client or
---project carries in the azctx profile, the Taskwarrior project tree, the note
---tags and the vault paths (docs/WORK_TAXONOMY.md), so a value that does not
---match the grammar is rejected rather than silently written into five places.
---
---The prompt exists because the derived slug and the authoritative one can
---legitimately differ: "Acme GmbH" derives `acme_gmbh` while the azctx profile
---may well say `acme`. Whatever is typed is normalized through slugify() and
---then validated; it is never taken verbatim.
---@param label string Human-readable role ("Client", "Project")
---@param name string The name the slug is derived from
---@return string|nil slug nil when the user aborted or the value is unusable
local function prompt_slug(label, name)
  local derived = utils.slugify(name)

  if derived == "" then
    vim.notify(string.format("%s name '%s' contains nothing usable for a slug", label, name), vim.log.levels.ERROR)
    return nil
  end

  local input = utils.prompt_text(label .. " Slug (lowercase, underscores)", derived)
  if not input then
    return nil
  end

  local slug = utils.slugify(input)

  if not utils.is_slug(slug) then
    vim.notify(
      string.format(
        "%s slug '%s' is not valid — expected lowercase letters, digits and single underscores",
        label,
        input
      ),
      vim.log.levels.ERROR
    )
    return nil
  end

  if slug ~= vim.trim(input) then
    vim.notify(string.format("%s slug normalized: %s → %s", label, input, slug), vim.log.levels.WARN)
  end

  return slug
end

-- ============================================================================
-- MAIN FUNCTION
-- ============================================================================

---Main entry point
function M.create_project()
  local notes_config = require("notes.init").config

  -- 1. Prompt for project_name (required), pre-fill from config if set
  local project_name = utils.prompt_text("Project Name (required)", notes_config.default_project_name or "")

  if not project_name or project_name == "" then
    vim.notify("Aborted: Project name required", vim.log.levels.WARN)
    return
  end

  -- 2. Prompt for client_name (required), pre-fill from config if set
  local client_name = utils.prompt_text("Client Name (required)", notes_config.default_client_name or "")

  if not client_name or client_name == "" then
    vim.notify("Aborted: Client name required", vim.log.levels.WARN)
    return
  end

  local order_number = utils.prompt_text("Order Number (required)")
  if not order_number then
    vim.notify("Aborted: order number required", vim.log.levels.WARN)
    return
  end

  local technologies = utils.prompt_text("Technologies (comma-separated, required)")
  if not technologies then
    vim.notify("Aborted: technologies required", vim.log.levels.WARN)
    return
  end

  -- 3. Derive the slugs and enforce the grammar on both. The client slug has
  --    to match the azctx profile's VOID_CLIENT_SLUG; that cross-check is not
  --    made here because the profile files are outside what this layer reads.
  --    `void-work check` is the validator for it.
  local client_slug = prompt_slug("Client", client_name)
  if not client_slug then
    vim.notify("Aborted: valid client slug required", vim.log.levels.WARN)
    return
  end

  local project_slug = prompt_slug("Project", project_name)
  if not project_slug then
    vim.notify("Aborted: valid project slug required", vim.log.levels.WARN)
    return
  end

  local vars = {
    project_name = project_name,
    project_slug = project_slug,
    client_name = client_name,
    client_slug = client_slug,
    order_number = order_number,
    technologies = technologies,
  }

  vim.notify(
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    vim.log.levels.INFO
  )
  vim.notify("Creating project: " .. project_name, vim.log.levels.INFO)
  vim.notify("  Slug: " .. project_slug, vim.log.levels.INFO)
  vim.notify("  Client: " .. client_name .. " (" .. client_slug .. ")", vim.log.levels.INFO)
  vim.notify(
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    vim.log.levels.INFO
  )

  -- 4. Create the project index before linking it from the client note.
  local project_path, project_err = ensure_project_index(vars)
  if not project_path then
    report_error("project index", project_err)
    return
  end

  -- 5. Create/update client note
  local client_path, client_err = ensure_client_note(vars)
  if not client_path then
    report_error("client index", client_err)
    return
  end

  -- 6. Generate project templates
  vim.notify("Creating templates...", vim.log.levels.INFO)
  local success, count, template_errors, kept = create_project_templates(vars)

  -- 7. Report
  vim.notify(
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    vim.log.levels.INFO
  )

  if success then
    vim.notify("✓ Project created!", vim.log.levels.INFO)
    vim.notify(
      "  Templates: " .. OUTPUT_TEMPLATES_DIR .. "/" .. client_slug .. "/" .. project_slug .. "/",
      vim.log.levels.INFO
    )
    vim.notify(
      "  Project dir: " .. PROJECT_DIR .. "/" .. client_slug .. "/" .. project_slug .. "/",
      vim.log.levels.INFO
    )
    vim.notify(string.format("  Created templates: %d; kept existing: %d", count, kept), vim.log.levels.INFO)

    vim.notify("  Project index: " .. project_path, vim.log.levels.INFO)
    vim.notify("  Client index: " .. client_path, vim.log.levels.INFO)
    vim.notify("", vim.log.levels.INFO)
    vim.notify("→ Use :NoteTemplate to create notes!", vim.log.levels.INFO)
  else
    vim.notify(string.format("✗ Project incomplete: %d template(s) created", count), vim.log.levels.ERROR)
    for _, err in ipairs(template_errors) do
      vim.notify("  - " .. err, vim.log.levels.ERROR)
    end
  end

  vim.notify(
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    vim.log.levels.INFO
  )
end

return M
