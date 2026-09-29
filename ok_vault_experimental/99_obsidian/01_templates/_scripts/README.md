# Templater User Scripts Library

This library provides reusable functions for Obsidian Templater templates and implements KISS/DRY/SRP principles.

**Version 2.0** - Enhanced with language policy and comprehensive archive functionality.

## Language & Casing Policy

- **Default language**: English for all new/updated content
- **Lowercase by default**: folders, files, slugs, tags, categories, status values, internal keys
- **Exceptions allowed**: Proper names (e.g., Microsoft Entra ID), common acronyms (API, SSO, JWT), code tokens
- **Frontmatter**: All new/adjusted notes include `lang: "en"`

## Usage

Load and use the library in any template:

```javascript
<%*
// Load library
const lib = tp.user.lib;
const app = this.app; // For file operations

// Use library functions
const title = await lib.promptTitle(tp, "Enter title:");
const id = lib.generateId(tp);
await lib.renameAndMove(tp, title, `01_projects/${projectName}/${title}`);
-%>
```

## Function Overview

### Date & Time Utilities

**New (Templater-independent):**
- **`nowId(dateId?)`**: Generate ID in format `YYYYMMDD_HHmm`
- **`nowIso(fmt?)`**: Generate ISO timestamp (default: `YYYY-MM-DD HH:mm`)

**Legacy (Templater-compatible):**
- **`generateId(tp)`**: Generate ID in format `YYYYMMDD_HHmm`
- **`generateCreatedTimestamp(tp)`**: ISO timestamp `YYYY-MM-DD HH:mm`
- **`generateDateId(tp)`**: Date ID in format `YYYYMMDD`
- **`generateCreatedLegacy(tp)`**: Legacy format `YYYYMMDD - HHmm`

### String & Slug Utilities (NEW)

- **`slugify(str, options?)`**: Slugify to ASCII lowercase with underscores
  - Handles German umlauts: ä→ae, ö→oe, ü→ue, ß→ss
  - Removes diacritics and special characters
  - Options: `{preserveCase: false}`

### File & Folder Utilities (NEW)

- **`exists(app, path)`**: Check if file/folder exists
- **`ensureFolder(app, path, options?)`**: Create folder with intermediate paths
- **`safeMove(app, src, dest, options?)`**: Move with conflict handling (-1, -2, etc.)
- **`read(app, path)`**: Read file content
- **`write(app, path, content, options?)`**: Write with optional backup
- **`listDir(app, path, options?)`**: List directory contents
  - Options: `{recursive: false, filter: fn}`

### Frontmatter / YAML Utilities (NEW)

- **`parseYamlFromContent(content)`**: Parse frontmatter from content
- **`stringifyYaml(frontmatter)`**: Convert object to YAML with delimiters
- **`updateFrontmatter(frontmatter, patch)`**: Merge patch into frontmatter
- **`setStatus(content, status)`**: Set status in content (lowercase)
- **`addMeta(content, meta)`**: Add metadata to content
- **`ensureTags(frontmatter, tagsArray)`**: Add tags without duplicates (lowercase)
- **`ensureLang(frontmatter, lang?)`**: Ensure lang field exists (default: "en")

### Standard Builders (NEW - DRY with Language Policy)

All builders return frontmatter with `lang: "en"` and lowercase slugs/tags/fields:

- **`fmBase(overrides?)`**: Base frontmatter with defaults
- **`fmProject({name, client, due, extraTags})`**: Project frontmatter
- **`fmArea({name, extraTags})`**: Area frontmatter
- **`fmKnowledge({title, type, extraTags})`**: Knowledge frontmatter
- **`fmResource({title, extraTags})`**: Resource frontmatter
- **`fmIndex({folderName})`**: Index frontmatter

### Index & Dataview Utilities (NEW)

- **`upsertIndex(app, {indexPath, frontmatter, sections}, options?)`**: Create/update index
  - Automatically adds `lang: "en"` and lowercase category/status
  - Supports markdown sections and dataview blocks

### Archiving Core (NEW - Enhanced Functionality)

- **`dailyArchiveRoot(dateId?)`**: Get daily archive path (`04_archive/<YYYYMMDD>`)
- **`ensureDailyIndex(app, dateId, options?)`**: Create daily index if needed
- **`archiveNote(app, {notePath, dateId?, dryRun?})`**: Archive single note
  - Patches frontmatter: status→archived, adds archived_on/from/by, ensures lang: "en"
  - Moves to `04_archive/<YYYYMMDD>/notes/`
  - Updates daily index
  - Returns: `{success, destPath, error?}`
- **`archiveProject(app, {projectDir, dateId?, dryRun?})`**: Archive entire project
  - Recursively patches all .md files
  - Moves folder to `04_archive/<YYYYMMDD>/projects/<slug>/`
  - Updates daily index
  - Returns: `{success, destPath, fileCount, error?}`

### Prompt Utilities

- **`promptTitle(tp, promptText, defaultTitle)`**: Prompt for title with fallback
- **`promptText(tp, promptText, defaultValue)`**: Simple text prompt
- **`promptSuggester(tp, promptText, displayOptions, valueOptions)`**: Selection prompt
- **`promptStatus(tp, statusOptions)`**: Standard status selection
- **`promptPriority(tp)`**: Priority selection

### File Operations (Legacy)

- **`renameAndMove(tp, newTitle, targetPath)`**: Rename and move file
- **`safeMove(tp, targetPath)`**: Safe move with error handling

### Tag & String Utilities

- **`normalizeSlug(text)`**: Normalize to slug (lowercase, underscores)
- **`processTags(tagsInput)`**: Process comma-separated tags
- **`createYamlArray(input, withQuotes)`**: Create YAML array string
- **`createYamlList(input, indent)`**: Create multi-line YAML list

### Frontmatter Generation (Legacy)

- **`generateBaseFrontmatter(tp, title, tags, category, status)`**: Base frontmatter
- **`generateProjectFrontmatter(tp, title, projectName, status, client, due)`**: Project frontmatter

### Related Items Utilities

- **`createRelatedLinks(input)`**: Create markdown links from comma-separated input
- **`parseRelatedItems(input)`**: Parse related items for frontmatter array

### Archiving Utilities (Legacy)

- **`getArchivePath(tp, dateStr)`**: Archive folder path for day
- **`getArchiveNotesPath(tp, dateStr)`**: Note archive path
- **`getArchiveProjectsPath(tp, dateStr)`**: Project archive path
- **`generateArchiveMetadata(tp, originalPath, archiver)`**: Archive metadata

### Error Handling & Validation

- **`safeExecute(fn, errorContext)`**: Try-catch wrapper for safe execution
- **`validateProjectName(projectName)`**: Validate project name
- **`validateDateFormat(dateStr)`**: Validate date string (YYYYMMDD)

## Examples

### Example 1: Create Simple Note with Language Policy

```javascript
<%*
const lib = tp.user.lib;

const title = await lib.promptTitle(tp, "Note title:");
const tags = await lib.promptText(tp, "Tags (comma-separated):");

// Use standard builder with lang: "en"
const fm = lib.fmBase({
    title: title,
    category: "note",
    tags: ["note", ...lib.processTags(tags).map(t => t.toLowerCase())]
});

await lib.renameAndMove(tp, title, `/02_areas/01_notes/${title}`);
-%>---
<% Object.entries(fm).map(([k,v]) => 
    Array.isArray(v) ? `${k}:\n${v.map(i => `  - "${i}"`).join('\n')}` : `${k}: "${v}"`
).join('\n') %>
---
```

### Example 2: Create Project with Builder

```javascript
<%*
const lib = tp.user.lib;
const app = this.app;

const name = await lib.promptText(tp, "Project name:");
const client = await lib.promptText(tp, "Client name:");
const status = await lib.promptStatus(tp);

// Use project builder (includes lang: "en", lowercase tags)
const fm = lib.fmProject({ name, client, extraTags: [] });
fm.status = status.toLowerCase();

await lib.renameAndMove(tp, name, `01_projects/${lib.slugify(name)}/${name}`);
-%>---
<% lib.stringifyYaml(fm) %>
# [[<% name %>]]

Project: **<% name %>**
Client: **<% client %>**
Status: **<% status %>**
```

### Example 3: Archive Note (Simple)

```javascript
<%*
const lib = tp.user.lib;
const app = this.app;

const notePath = tp.file.path(true);

// Archive with dry-run option
const result = await lib.archiveNote(app, {
    notePath,
    dryRun: false
});

if (result.success) {
    await tp.system.prompt("Archived to: " + result.destPath);
}
-%>
```

### Example 4: Archive Project (Full Folder)

```javascript
<%*
const lib = tp.user.lib;
const app = this.app;

const projectDir = "01_projects/my_project";

// Archive entire project folder
const result = await lib.archiveProject(app, {
    projectDir,
    dateId: "20251111", // optional custom date
    dryRun: false
});

if (result.success) {
    await tp.system.prompt(`Archived ${result.fileCount} files to: ${result.destPath}`);
}
-%>
```

### Example 5: Create Index with Dataview

```javascript
<%*
const lib = tp.user.lib;
const app = this.app;

const folderName = "my_area";
const indexPath = `02_areas/${folderName}/00_index.md`;

// Use index builder (includes lang: "en")
const fm = lib.fmIndex({ folderName });

const sections = [
    {
        title: "Overview",
        content: `This is the index for ${folderName}.`
    },
    {
        title: "Recent Notes",
        content: '```dataview\nTABLE file.link as Note, created\nFROM "02_areas/' + folderName + '"\nSORT created DESC\n```'
    }
];

await lib.upsertIndex(app, { indexPath, frontmatter: fm, sections });
-%>
```

## Conventions

- **Timezone**: Europe/Berlin
- **Date formats**:
  - ID: `YYYYMMDD_HHmm`
  - ISO: `YYYY-MM-DD HH:mm`
  - Legacy: `YYYYMMDD - HHmm`
- **Slugs**: lowercase, underscores, no special characters (umlauts converted: ä→ae, ö→oe, ü→ue, ß→ss)
- **Tags**: short, lowercase, with context (`topic/identity`, `client/acme_gmbh`)
- **Language**: English by default, `lang: "en"` in all new frontmatter
- **Exceptions**: Proper names (Microsoft Entra ID), acronyms (API, SSO), code tokens may retain uppercase

## Safety Features

- **Backups**: Automatic `.bak` creation when writing files (can be disabled)
- **Idempotency**: Conflict handling with `-1`, `-2` suffixes
- **Dry-run**: All archive functions support `dryRun: true` to preview changes
- **Error handling**: Try-catch wrappers with detailed error messages

## Maintenance

When updating the library:

1. Document function with JSDoc comments
2. Test with existing templates
3. Update README.md
4. Create backup (`lib.js.bak`)

## Version

**Version**: 2.0  
**Date**: 2025-11-11  
**Author**: AI Agent for Vault Maintenance
