/**
 * Templater User Scripts Library (lib.js)
 * 
 * Central library for reusable template functions.
 * Implements KISS/DRY/SRP principles for Obsidian Vault Templates.
 * 
 * Language Policy: English by default, lowercase for folders/files/slugs/tags/categories/status
 * Exceptions: Proper names, acronyms, code tokens may retain uppercase
 * 
 * Timezone: Europe/Berlin
 * Usage: tp.user.lib.functionName(params)
 * Version: 2.0 - Enhanced with archive functionality and language policy
 */

// ============================================================================
// DATE & TIME UTILITIES
// ============================================================================

/**
 * Generate ID in format YYYYMMDD_HHmm for current date/time
 * @param {string} dateId - Optional date override (YYYYMMDD format)
 * @returns {string} ID in format "YYYYMMDD_HHmm"
 */
function nowId(dateId = null) {
    if (dateId) {
        const now = new Date();
        const time = now.toLocaleTimeString('en-GB', { 
            hour: '2-digit', 
            minute: '2-digit',
            hour12: false 
        }).replace(':', '');
        return `${dateId}_${time}`;
    }
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    return `${year}${month}${day}_${hours}${minutes}`;
}

/**
 * Generate ISO timestamp with custom format
 * @param {string} fmt - Format string (default: "YYYY-MM-DD HH:mm")
 * @returns {string} Formatted timestamp
 */
function nowIso(fmt = "YYYY-MM-DD HH:mm") {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const seconds = String(now.getSeconds()).padStart(2, '0');
    
    return fmt
        .replace('YYYY', year)
        .replace('MM', month)
        .replace('DD', day)
        .replace('HH', hours)
        .replace('mm', minutes)
        .replace('ss', seconds);
}

/**
 * Generate ID in format YYYYMMDD_HHmm (Templater-compatible wrapper)
 * @param {object} tp - Templater object
 * @returns {string} ID in format "YYYYMMDD_HHmm"
 */
function generateId(tp) {
    return tp.date.now("YYYYMMDD_HHmm");
}

/**
 * Generate ISO timestamp for created field (YYYY-MM-DD HH:mm)
 * @param {object} tp - Templater object
 * @returns {string} ISO timestamp
 */
function generateCreatedTimestamp(tp) {
    return tp.date.now("YYYY-MM-DD HH:mm");
}

/**
 * Generate date ID in format YYYYMMDD for current day
 * @param {object} tp - Templater object
 * @returns {string} Date in format "YYYYMMDD"
 */
function generateDateId(tp) {
    return tp.date.now("YYYYMMDD");
}

/**
 * Generate created field in alternative format YYYYMMDD - HHmm
 * @param {object} tp - Templater object
 * @returns {string} Timestamp in format "YYYYMMDD - HHmm"
 */
function generateCreatedLegacy(tp) {
    return tp.date.now("YYYYMMDD - HHmm");
}

// ============================================================================
// STRING & SLUG UTILITIES (Language Policy: lowercase, ASCII)
// ============================================================================

/**
 * Slugify string to ASCII lowercase with underscores
 * Handles umlauts and diacritics (ä→ae, ö→oe, ü→ue, ß→ss)
 * Exception: Preserves uppercase in known proper names/acronyms if explicitly marked
 * @param {string} str - String to slugify
 * @param {object} options - Options {preserveCase: false}
 * @returns {string} Slugified string
 */
function slugify(str, options = {}) {
    if (!str) return '';
    
    let result = str
        // German umlauts
        .replace(/ä/g, 'ae').replace(/Ä/g, 'Ae')
        .replace(/ö/g, 'oe').replace(/Ö/g, 'Oe')
        .replace(/ü/g, 'ue').replace(/Ü/g, 'Ue')
        .replace(/ß/g, 'ss')
        // Common diacritics
        .replace(/[àáâãå]/g, 'a')
        .replace(/[èéêë]/g, 'e')
        .replace(/[ìíîï]/g, 'i')
        .replace(/[òóôõ]/g, 'o')
        .replace(/[ùúû]/g, 'u')
        .replace(/[ñ]/g, 'n')
        .replace(/[ç]/g, 'c')
        // Remove other special chars
        .replace(/[^\w\s-]/g, '')
        // Replace spaces/hyphens with underscores
        .replace(/[\s-]+/g, '_')
        // Remove duplicate underscores
        .replace(/_+/g, '_')
        // Trim underscores from start/end
        .replace(/^_+|_+$/g, '');
    
    // Apply lowercase unless preserveCase is true
    return options.preserveCase ? result : result.toLowerCase();
}

/**
 * Normalize slug (wrapper for slugify for backward compatibility)
 * @param {string} text - Text to normalize
 * @returns {string} Normalized slug
 */
function normalizeSlug(text) {
    return slugify(text);
}

// ============================================================================
// FILE & FOLDER UTILITIES
// ============================================================================

/**
 * Check if file exists (Obsidian-compatible)
 * @param {object} app - Obsidian app object
 * @param {string} path - File path
 * @returns {boolean} True if exists
 */
function exists(app, path) {
    return app.vault.getAbstractFileByPath(path) !== null;
}

/**
 * Ensure folder exists, create intermediate folders if needed
 * @param {object} app - Obsidian app object
 * @param {string} path - Folder path
 * @param {object} options - Options {dryRun: false}
 * @returns {Promise<void>}
 */
async function ensureFolder(app, path, options = {}) {
    if (options.dryRun) {
        console.log(`[DRY-RUN] Would create folder: ${path}`);
        return;
    }
    
    const parts = path.split('/').filter(p => p);
    let currentPath = '';
    
    for (const part of parts) {
        currentPath = currentPath ? `${currentPath}/${part}` : part;
        if (!exists(app, currentPath)) {
            await app.vault.createFolder(currentPath);
        }
    }
}

/**
 * Safe move with overwrite protection and conflict handling
 * @param {object} app - Obsidian app object
 * @param {string} src - Source path
 * @param {string} dest - Destination path
 * @param {object} options - Options {overwrite: false, dryRun: false}
 * @returns {Promise<string>} Final destination path
 */
async function safeMove(app, src, dest, options = {}) {
    const { overwrite = false, dryRun = false } = options;
    
    if (dryRun) {
        console.log(`[DRY-RUN] Would move: ${src} → ${dest}`);
        return dest;
    }
    
    let finalDest = dest;
    let counter = 1;
    
    // Handle conflicts by appending -1, -2, etc.
    while (exists(app, finalDest) && !overwrite) {
        const ext = finalDest.endsWith('.md') ? '.md' : '';
        const base = ext ? finalDest.slice(0, -3) : finalDest;
        finalDest = `${base}-${counter}${ext}`;
        counter++;
    }
    
    const file = app.vault.getAbstractFileByPath(src);
    if (file) {
        // Ensure destination folder exists
        const destFolder = finalDest.substring(0, finalDest.lastIndexOf('/'));
        if (destFolder) {
            await ensureFolder(app, destFolder, options);
        }
        
        await app.vault.rename(file, finalDest);
    }
    
    return finalDest;
}

/**
 * Read file content
 * @param {object} app - Obsidian app object
 * @param {string} path - File path
 * @returns {Promise<string>} File content
 */
async function read(app, path) {
    const file = app.vault.getAbstractFileByPath(path);
    if (!file) {
        throw new Error(`File not found: ${path}`);
    }
    return await app.vault.read(file);
}

/**
 * Write file content with optional backup
 * @param {object} app - Obsidian app object
 * @param {string} path - File path
 * @param {string} content - Content to write
 * @param {object} options - Options {backup: true, dryRun: false}
 * @returns {Promise<void>}
 */
async function write(app, path, content, options = {}) {
    const { backup = true, dryRun = false } = options;
    
    if (dryRun) {
        console.log(`[DRY-RUN] Would write to: ${path}`);
        return;
    }
    
    const file = app.vault.getAbstractFileByPath(path);
    
    if (file && backup) {
        // Create backup
        const backupPath = `${path}.bak`;
        const existingContent = await read(app, path);
        await app.vault.create(backupPath, existingContent);
    }
    
    if (file) {
        await app.vault.modify(file, content);
    } else {
        // Ensure folder exists
        const folder = path.substring(0, path.lastIndexOf('/'));
        if (folder) {
            await ensureFolder(app, folder, options);
        }
        await app.vault.create(path, content);
    }
}

/**
 * List directory contents
 * @param {object} app - Obsidian app object
 * @param {string} path - Directory path
 * @param {object} options - Options {recursive: false, filter: null}
 * @returns {Array<string>} Array of file paths
 */
function listDir(app, path, options = {}) {
    const { recursive = false, filter = null } = options;
    const folder = app.vault.getAbstractFileByPath(path);
    
    if (!folder || folder.children === undefined) {
        return [];
    }
    
    let results = [];
    
    for (const child of folder.children) {
        const childPath = child.path;
        
        if (child.children && recursive) {
            // Recursively list subdirectories
            results = results.concat(listDir(app, childPath, options));
        }
        
        if (!filter || filter(child)) {
            results.push(childPath);
        }
    }
    
    return results;
}

// ============================================================================
// FRONTMATTER / YAML UTILITIES
// ============================================================================

/**
 * Parse YAML frontmatter from content
 * @param {string} content - File content with frontmatter
 * @returns {object} {frontmatter: object, body: string}
 */
function parseYamlFromContent(content) {
    const fmRegex = /^---\n([\s\S]*?)\n---\n([\s\S]*)$/;
    const match = content.match(fmRegex);
    
    if (!match) {
        return { frontmatter: {}, body: content };
    }
    
    const yamlStr = match[1];
    const body = match[2];
    const frontmatter = {};
    
    // Simple YAML parser (handles basic key-value pairs and arrays)
    const lines = yamlStr.split('\n');
    let currentKey = null;
    let inArray = false;
    
    for (const line of lines) {
        if (line.trim() === '') continue;
        
        if (line.match(/^[\w_]+:/)) {
            inArray = false;
            const [key, ...valueParts] = line.split(':');
            const value = valueParts.join(':').trim();
            currentKey = key.trim();
            
            if (value.startsWith('[') && value.endsWith(']')) {
                // Inline array
                frontmatter[currentKey] = JSON.parse(value.replace(/'/g, '"'));
            } else if (value === '') {
                // Empty value or array start
                frontmatter[currentKey] = [];
                inArray = true;
            } else {
                // Simple value
                frontmatter[currentKey] = value.replace(/^["']|["']$/g, '');
            }
        } else if (inArray && line.trim().startsWith('-')) {
            // Array item
            const item = line.trim().substring(1).trim().replace(/^["']|["']$/g, '');
            if (Array.isArray(frontmatter[currentKey])) {
                frontmatter[currentKey].push(item);
            }
        }
    }
    
    return { frontmatter, body };
}

/**
 * Stringify frontmatter object to YAML
 * @param {object} frontmatter - Frontmatter object
 * @returns {string} YAML string with --- delimiters
 */
function stringifyYaml(frontmatter) {
    let yaml = '---\n';
    
    for (const [key, value] of Object.entries(frontmatter)) {
        if (Array.isArray(value)) {
            if (value.length === 0) {
                yaml += `${key}: []\n`;
            } else {
                yaml += `${key}:\n`;
                for (const item of value) {
                    yaml += `  - "${item}"\n`;
                }
            }
        } else if (typeof value === 'string') {
            yaml += `${key}: "${value}"\n`;
        } else {
            yaml += `${key}: ${value}\n`;
        }
    }
    
    yaml += '---\n';
    return yaml;
}

/**
 * Update frontmatter with patch object
 * @param {object} frontmatter - Original frontmatter
 * @param {object} patch - Patch to apply
 * @returns {object} Merged frontmatter
 */
function updateFrontmatter(frontmatter, patch) {
    return { ...frontmatter, ...patch };
}

/**
 * Set status in content
 * @param {string} content - File content
 * @param {string} status - Status value (lowercase)
 * @returns {string} Updated content
 */
function setStatus(content, status) {
    const { frontmatter, body } = parseYamlFromContent(content);
    frontmatter.status = status.toLowerCase();
    return stringifyYaml(frontmatter) + body;
}

/**
 * Add metadata to content
 * @param {string} content - File content
 * @param {object} meta - Metadata to add {archived_on, archived_from, archived_by, etc}
 * @returns {string} Updated content
 */
function addMeta(content, meta) {
    const { frontmatter, body } = parseYamlFromContent(content);
    const updated = updateFrontmatter(frontmatter, meta);
    return stringifyYaml(updated) + body;
}

/**
 * Ensure tags exist in frontmatter (no duplicates, lowercase)
 * @param {object} frontmatter - Frontmatter object
 * @param {Array<string>} tagsArray - Tags to ensure
 * @returns {object} Updated frontmatter
 */
function ensureTags(frontmatter, tagsArray) {
    const existing = frontmatter.tags || [];
    const existingSet = new Set(existing.map(t => t.toLowerCase()));
    
    for (const tag of tagsArray) {
        const lowerTag = tag.toLowerCase();
        if (!existingSet.has(lowerTag)) {
            existing.push(lowerTag);
            existingSet.add(lowerTag);
        }
    }
    
    return { ...frontmatter, tags: existing };
}

/**
 * Ensure lang field exists in frontmatter
 * @param {object} frontmatter - Frontmatter object
 * @param {string} lang - Language code (default: "en")
 * @returns {object} Updated frontmatter
 */
function ensureLang(frontmatter, lang = "en") {
    if (!frontmatter.lang) {
        return { ...frontmatter, lang };
    }
    return frontmatter;
}

// ============================================================================
// PROMPT UTILITIES
// ============================================================================

/**
 * Prompt for title with fallback to current filename
 * @param {object} tp - Templater object
 * @param {string} promptText - Text for the prompt
 * @param {string} defaultTitle - Default title if not Untitled/Unbenannt
 * @returns {Promise<string>} Entered or current title
 */
async function promptTitle(tp, promptText = "Title:", defaultTitle = null) {
    const currentTitle = tp.file.title;
    if (currentTitle === "Untitled" || currentTitle === "Unbenannt") {
        return await tp.system.prompt(promptText);
    } else {
        return defaultTitle || currentTitle;
    }
}

/**
 * Prompt für Text-Eingabe
 * @param {object} tp - Templater-Objekt
 * @param {string} promptText - Text für den Prompt
 * @param {string} defaultValue - Standard-Wert (optional)
 * @returns {Promise<string>} Eingegebener Text
 */
async function promptText(tp, promptText, defaultValue = "") {
    return await tp.system.prompt(promptText, defaultValue);
}

/**
 * Prompt mit Auswahl-Optionen (Suggester)
 * @param {object} tp - Templater-Objekt
 * @param {string} promptText - Text für den Prompt
 * @param {Array<string>} displayOptions - Anzuzeigende Optionen
 * @param {Array<string>} valueOptions - Werte der Optionen
 * @returns {Promise<string>} Ausgewählter Wert
 */
async function promptSuggester(tp, promptText, displayOptions, valueOptions) {
    return await tp.system.suggester(displayOptions, valueOptions, false, promptText);
}

/**
 * Standard Status-Auswahl
 * @param {object} tp - Templater-Objekt
 * @param {Array<string>} statusOptions - Array von Status-Optionen (optional)
 * @returns {Promise<string>} Ausgewählter Status
 */
async function promptStatus(tp, statusOptions = null) {
    const defaultOptions = ["active", "draft", "in-progress", "completed", "archived"];
    const displayOptions = statusOptions || ["Active", "Draft", "In Progress", "Completed", "Archived"];
    const valueOptions = statusOptions || defaultOptions;
    
    return await tp.system.suggester(
        displayOptions,
        valueOptions,
        false,
        "Select Status:"
    );
}

/**
 * Prioritäts-Auswahl
 * @param {object} tp - Templater-Objekt
 * @returns {Promise<string>} Ausgewählte Priorität
 */
async function promptPriority(tp) {
    return await tp.system.suggester(
        ["Critical", "High", "Medium", "Low"],
        ["critical", "high", "medium", "low"],
        false,
        "Select Priority:"
    );
}

// ============================================================================
// FILE OPERATIONS
// ============================================================================

/**
 * Benennt Datei um und verschiebt sie
 * @param {object} tp - Templater-Objekt
 * @param {string} newTitle - Neuer Dateiname
 * @param {string} targetPath - Zielpfad (relativ zur Vault-Root)
 * @returns {Promise<void>}
 */
async function renameAndMove(tp, newTitle, targetPath) {
    await tp.file.rename(newTitle);
    await tp.file.move(targetPath);
}

/**
 * Sicheres Verschieben einer Datei (non-destructive)
 * @param {object} tp - Templater-Objekt
 * @param {string} targetPath - Zielpfad
 * @returns {Promise<void>}
 */
async function safeMove(tp, targetPath) {
    try {
        await tp.file.move(targetPath);
    } catch (error) {
        console.error(`Error moving file to ${targetPath}:`, error);
        throw error;
    }
}

// ============================================================================
// TAG & STRING UTILITIES
// ============================================================================

/**
 * Normalisiert einen String für Tags/Slugs (lowercase, underscores)
 * @param {string} text - Zu normalisierender Text
 * @returns {string} Normalisierter Slug
 */
function normalizeSlug(text) {
    return text.toLowerCase().replace(/\s+/g, '_').replace(/[^\w_-]/g, '');
}

/**
 * Verarbeitet komma-separierte Tags
 * @param {string} tagsInput - Komma-separierte Tags
 * @returns {Array<string>} Array von normalisierten Tags
 */
function processTags(tagsInput) {
    if (!tagsInput || tagsInput.trim() === "") {
        return [];
    }
    return tagsInput.split(",").map(tag => tag.trim());
}

/**
 * Erstellt YAML-Array-String aus komma-separierter Eingabe
 * @param {string} input - Komma-separierte Werte
 * @param {boolean} withQuotes - Ob Werte in Anführungszeichen gesetzt werden sollen
 * @returns {string} YAML-Array-String
 */
function createYamlArray(input, withQuotes = true) {
    if (!input || input.trim() === "") {
        return "[]";
    }
    
    const items = input.split(",").map(item => item.trim());
    if (withQuotes) {
        return "[" + items.map(item => `"${item}"`).join(", ") + "]";
    }
    return "[" + items.join(", ") + "]";
}

/**
 * Erstellt mehrzeilige YAML-Liste aus komma-separierter Eingabe
 * @param {string} input - Komma-separierte Werte
 * @param {number} indent - Einrückung (Anzahl Leerzeichen)
 * @returns {string} Mehrzeilige YAML-Liste
 */
function createYamlList(input, indent = 2) {
    if (!input || input.trim() === "") {
        return "";
    }
    
    const indentStr = " ".repeat(indent);
    const items = input.split(",").map(item => item.trim());
    return items.map(item => `${indentStr}- ${item}`).join("\n");
}

// ============================================================================
// FRONTMATTER GENERATION
// ============================================================================

/**
 * Generiert Standard-Frontmatter-Basis
 * @param {object} tp - Templater-Objekt
 * @param {string} title - Titel der Notiz
 * @param {Array<string>} tags - Tags-Array
 * @param {string} category - Kategorie
 * @param {string} status - Status
 * @returns {object} Frontmatter-Objekt
 */
function generateBaseFrontmatter(tp, title, tags, category, status) {
    return {
        title: title,
        id: generateId(tp),
        created: generateCreatedTimestamp(tp),
        tags: tags,
        category: category,
        status: status,
        related: [],
        concepts: [],
        aliases: []
    };
}

/**
 * Erstellt Frontmatter für Projekt-Notizen
 * @param {object} tp - Templater-Objekt
 * @param {string} title - Titel
 * @param {string} projectName - Projektname
 * @param {string} status - Status
 * @param {string} client - Client-Name (optional)
 * @param {string} due - Fälligkeitsdatum (optional)
 * @returns {object} Project-Frontmatter
 */
function generateProjectFrontmatter(tp, title, projectName, status, client = "", due = "") {
    const base = generateBaseFrontmatter(tp, title, ["project"], "project", status);
    return {
        ...base,
        client: client,
        due: due
    };
}

// ============================================================================
// STANDARD BUILDERS (DRY, with language policy)
// ============================================================================

/**
 * Base frontmatter builder (includes lang: "en")
 * @param {object} overrides - Override values
 * @returns {object} Base frontmatter with defaults
 */
function fmBase(overrides = {}) {
    const now = new Date();
    return {
        id: nowId(),
        created: nowIso(),
        lang: "en",
        status: "active",
        tags: [],
        related: [],
        concepts: [],
        aliases: [],
        ...overrides
    };
}

/**
 * Project frontmatter builder
 * @param {object} params - {name, client, due, extraTags}
 * @returns {object} Project frontmatter
 */
function fmProject(params = {}) {
    const { name, client, due, extraTags = [] } = params;
    const slug = slugify(name || 'project');
    
    return fmBase({
        title: name || 'Untitled Project',
        category: "project",
        tags: ["project", ...extraTags.map(t => t.toLowerCase())],
        client: client || "",
        due: due || ""
    });
}

/**
 * Area frontmatter builder
 * @param {object} params - {name, extraTags}
 * @returns {object} Area frontmatter
 */
function fmArea(params = {}) {
    const { name, extraTags = [] } = params;
    
    return fmBase({
        title: name || 'Untitled Area',
        category: "area",
        tags: ["area", ...extraTags.map(t => t.toLowerCase())],
        status: "in-progress"
    });
}

/**
 * Knowledge frontmatter builder
 * @param {object} params - {title, type, extraTags}
 * @returns {object} Knowledge frontmatter
 */
function fmKnowledge(params = {}) {
    const { title, type = "permanent", extraTags = [] } = params;
    
    return fmBase({
        title: title || 'Untitled Note',
        category: "knowledge",
        tags: [type.toLowerCase(), ...extraTags.map(t => t.toLowerCase())],
        status: "completed"
    });
}

/**
 * Resource frontmatter builder
 * @param {object} params - {title, extraTags}
 * @returns {object} Resource frontmatter
 */
function fmResource(params = {}) {
    const { title, extraTags = [] } = params;
    
    return fmBase({
        title: title || 'Untitled Resource',
        category: "resource",
        tags: ["resource", ...extraTags.map(t => t.toLowerCase())]
    });
}

/**
 * Index frontmatter builder
 * @param {object} params - {folderName}
 * @returns {object} Index frontmatter
 */
function fmIndex(params = {}) {
    const { folderName } = params;
    const slug = slugify(folderName || 'index');
    
    return fmBase({
        title: `index - ${folderName || 'untitled'}`,
        category: "index",
        tags: ["obsidian/index"],
        status: "active"
    });
}

// ============================================================================
// RELATED ITEMS UTILITIES
// ============================================================================

/**
 * Erstellt Markdown-Links aus komma-separierter Eingabe
 * @param {string} input - Komma-separierte Notiz-Namen
 * @returns {string} Markdown-Liste mit Links
 */
function createRelatedLinks(input) {
    if (!input || input.trim() === "") {
        return "- None";
    }
    
    const items = input.split(",").map(item => item.trim());
    return items.map(item => `- [[${item}]]`).join("\n");
}

/**
 * Parst related items für Frontmatter-Array
 * @param {string} input - Komma-separierte Items
 * @returns {Array<string>} Array von Items
 */
function parseRelatedItems(input) {
    if (!input || input.trim() === "") {
        return [];
    }
    return input.split(",").map(item => item.trim());
}

// ============================================================================
// ARCHIVING UTILITIES
// ============================================================================

/**
 * Generiert Archiv-Ordnerpfad für einen bestimmten Tag
 * @param {object} tp - Templater-Objekt
 * @param {string} dateStr - Datums-String (YYYYMMDD) oder null für heute
 * @returns {string} Archiv-Pfad im Format "04_archive/YYYYMMDD"
 */
function getArchivePath(tp, dateStr = null) {
    const date = dateStr || generateDateId(tp);
    return `04_archive/${date}`;
}

/**
 * Generiert Archiv-Pfad für Notizen
 * @param {object} tp - Templater-Objekt
 * @param {string} dateStr - Datums-String (YYYYMMDD) oder null für heute
 * @returns {string} Notiz-Archiv-Pfad
 */
function getArchiveNotesPath(tp, dateStr = null) {
    return `${getArchivePath(tp, dateStr)}/notes`;
}

/**
 * Generiert Archiv-Pfad für Projekte
 * @param {object} tp - Templater-Objekt
 * @param {string} dateStr - Datums-String (YYYYMMDD) oder null für heute
 * @returns {string} Projekt-Archiv-Pfad
 */
function getArchiveProjectsPath(tp, dateStr = null) {
    return `${getArchivePath(tp, dateStr)}/projects`;
}

/**
 * Erstellt Archiv-Metadaten für Frontmatter
 * @param {object} tp - Templater-Objekt
 * @param {string} originalPath - Originaler Pfad der Datei
 * @param {string} archiver - Name des Archivierers (default: "system")
 * @returns {object} Archiv-Metadaten
 */
function generateArchiveMetadata(tp, originalPath, archiver = "system") {
    return {
        status: "archived",
        archived_on: generateCreatedTimestamp(tp),
        archived_from: originalPath,
        archived_by: archiver
    };
}

// ============================================================================
// INDEX & DATAVIEW UTILITIES
// ============================================================================

/**
 * Upsert index file (create or update 00_index.md)
 * @param {object} app - Obsidian app object
 * @param {object} params - {indexPath, frontmatter, sections}
 * @param {object} options - {dryRun: false}
 * @returns {Promise<void>}
 */
async function upsertIndex(app, params, options = {}) {
    const { indexPath, frontmatter, sections = [] } = params;
    const { dryRun = false } = options;
    
    if (dryRun) {
        console.log(`[DRY-RUN] Would upsert index: ${indexPath}`);
        return;
    }
    
    // Ensure lang: "en" and lowercase category/status
    const fm = ensureLang(frontmatter);
    if (fm.category) fm.category = fm.category.toLowerCase();
    if (fm.status) fm.status = fm.status.toLowerCase();
    
    let content = stringifyYaml(fm);
    content += '\n';
    
    // Add sections
    for (const section of sections) {
        if (typeof section === 'string') {
            content += section + '\n\n';
        } else if (section.title && section.content) {
            content += `## ${section.title}\n\n${section.content}\n\n`;
        }
    }
    
    await write(app, indexPath, content, { backup: true, dryRun });
}

// ============================================================================
// ARCHIVING CORE (Enhanced with full functionality)
// ============================================================================

/**
 * Get daily archive root path
 * @param {string} dateId - Date ID in YYYYMMDD format (default: today)
 * @returns {string} Archive path "04_archive/<YYYYMMDD>"
 */
function dailyArchiveRoot(dateId = null) {
    const date = dateId || nowId().slice(0, 8);
    return `04_archive/${date}`;
}

/**
 * Ensure daily index exists
 * @param {object} app - Obsidian app object
 * @param {string} dateId - Date ID in YYYYMMDD format
 * @param {object} options - {dryRun: false}
 * @returns {Promise<void>}
 */
async function ensureDailyIndex(app, dateId, options = {}) {
    const { dryRun = false } = options;
    const archiveRoot = dailyArchiveRoot(dateId);
    const indexPath = `${archiveRoot}/00_index.md`;
    
    // Check if already exists
    if (exists(app, indexPath)) {
        return;
    }
    
    if (dryRun) {
        console.log(`[DRY-RUN] Would create daily index: ${indexPath}`);
        return;
    }
    
    // Format date for display (DD.MM.YYYY)
    const year = dateId.slice(0, 4);
    const month = dateId.slice(4, 6);
    const day = dateId.slice(6, 8);
    const displayDate = `${day}.${month}.${year}`;
    
    const frontmatter = {
        title: `index - ${dateId}`,
        id: nowId(dateId),
        created: nowIso(),
        lang: "en",
        tags: ["obsidian/index", "archive/day"],
        category: "index",
        status: "active"
    };
    
    const sections = [
        {
            title: `Archived on ${displayDate}`,
            content: `Archive index for ${displayDate}.`
        },
        {
            title: "Archived Notes",
            content: `\`\`\`dataview
TABLE file.link as Item, status, archived_on, archived_from
FROM "${archiveRoot}/notes"
SORT file.name ASC
\`\`\``
        },
        {
            title: "Archived Projects",
            content: `\`\`\`dataview
TABLE file.link as Item, status, archived_on, archived_from
FROM "${archiveRoot}/projects"
SORT file.name ASC
\`\`\``
        }
    ];
    
    await upsertIndex(app, { indexPath, frontmatter, sections }, options);
}

/**
 * Archive a note
 * @param {object} app - Obsidian app object
 * @param {object} params - {notePath, dateId, dryRun}
 * @returns {Promise<object>} Result {success, destPath, error}
 */
async function archiveNote(app, params) {
    const { notePath, dateId = null, dryRun = false } = params;
    const date = dateId || nowId().slice(0, 8);
    
    try {
        // Ensure daily index exists
        await ensureDailyIndex(app, date, { dryRun });
        
        // Create destination directory
        const destDir = `${dailyArchiveRoot(date)}/notes`;
        await ensureFolder(app, destDir, { dryRun });
        
        // Read and patch frontmatter
        const content = await read(app, notePath);
        const { frontmatter, body } = parseYamlFromContent(content);
        
        const patchedFm = updateFrontmatter(frontmatter, {
            status: "archived",
            archived_on: nowIso(),
            archived_from: notePath,
            archived_by: "agent",
            lang: frontmatter.lang || "en"
        });
        
        const newContent = stringifyYaml(patchedFm) + body;
        
        // Get filename and move
        const fileName = notePath.split('/').pop();
        const destPath = `${destDir}/${fileName}`;
        
        if (!dryRun) {
            await write(app, notePath, newContent, { backup: false });
            await safeMove(app, notePath, destPath, { dryRun });
        } else {
            console.log(`[DRY-RUN] Would archive note: ${notePath} → ${destPath}`);
        }
        
        // Update daily index with entry
        const indexPath = `${dailyArchiveRoot(date)}/00_index.md`;
        if (exists(app, indexPath) && !dryRun) {
            const indexContent = await read(app, indexPath);
            const entry = `- note: [[notes/${fileName.replace('.md', '')}]] (archived_from: ${notePath})\n`;
            await write(app, indexPath, indexContent + entry, { backup: false });
        }
        
        return { success: true, destPath };
    } catch (error) {
        console.error(`Error archiving note ${notePath}:`, error);
        return { success: false, error: error.message };
    }
}

/**
 * Archive a project (entire folder)
 * @param {object} app - Obsidian app object
 * @param {object} params - {projectDir, dateId, dryRun}
 * @returns {Promise<object>} Result {success, destPath, fileCount, error}
 */
async function archiveProject(app, params) {
    const { projectDir, dateId = null, dryRun = false } = params;
    const date = dateId || nowId().slice(0, 8);
    
    try {
        // Ensure daily index exists
        await ensureDailyIndex(app, date, { dryRun });
        
        // Get project slug from folder name
        const projectSlug = slugify(projectDir.split('/').pop());
        const destDir = `${dailyArchiveRoot(date)}/projects/${projectSlug}`;
        
        await ensureFolder(app, destDir, { dryRun });
        
        // Recursively load all .md files and patch frontmatter
        const mdFiles = listDir(app, projectDir, {
            recursive: true,
            filter: (file) => file.path.endsWith('.md')
        });
        
        let fileCount = 0;
        
        for (const filePath of mdFiles) {
            const content = await read(app, filePath);
            const { frontmatter, body } = parseYamlFromContent(content);
            
            const patchedFm = updateFrontmatter(frontmatter, {
                status: "archived",
                archived_on: nowIso(),
                archived_from: filePath,
                archived_by: "agent",
                lang: frontmatter.lang || "en"
            });
            
            const newContent = stringifyYaml(patchedFm) + body;
            
            if (!dryRun) {
                await write(app, filePath, newContent, { backup: false });
            }
            
            fileCount++;
        }
        
        // Move entire folder
        if (!dryRun) {
            await safeMove(app, projectDir, destDir, { dryRun });
        } else {
            console.log(`[DRY-RUN] Would archive project: ${projectDir} → ${destDir} (${fileCount} files)`);
        }
        
        // Update daily index with entry
        const indexPath = `${dailyArchiveRoot(date)}/00_index.md`;
        if (exists(app, indexPath) && !dryRun) {
            const indexContent = await read(app, indexPath);
            const entry = `- project: [[projects/${projectSlug}/]] (files: ${fileCount}, from: ${projectDir})\n`;
            await write(app, indexPath, indexContent + entry, { backup: false });
        }
        
        return { success: true, destPath: destDir, fileCount };
    } catch (error) {
        console.error(`Error archiving project ${projectDir}:`, error);
        return { success: false, error: error.message };
    }
}

// ============================================================================
// ERROR HANDLING
// ============================================================================

/**
 * Wrapper für sichere Template-Ausführung mit Try-Catch
 * @param {Function} fn - Auszuführende Funktion
 * @param {string} errorContext - Kontext für Fehlermeldung
 * @returns {Promise<any>} Ergebnis der Funktion oder null bei Fehler
 */
async function safeExecute(fn, errorContext = "Template execution") {
    try {
        return await fn();
    } catch (error) {
        console.error(`Error in ${errorContext}:`, error);
        return null;
    }
}

// ============================================================================
// VALIDATION UTILITIES
// ============================================================================

/**
 * Validiert Projekt-Name (nicht leer, gültiger Slug)
 * @param {string} projectName - Zu validierender Projektname
 * @returns {boolean} true wenn valide
 */
function validateProjectName(projectName) {
    return projectName && projectName.trim().length > 0;
}

/**
 * Validiert Datums-String im Format YYYYMMDD
 * @param {string} dateStr - Zu validierender Datums-String
 * @returns {boolean} true wenn valide
 */
function validateDateFormat(dateStr) {
    const dateRegex = /^\d{8}$/;
    return dateRegex.test(dateStr);
}

// ============================================================================
// EXPORTS (for Templater)
// ============================================================================

module.exports = {
    // Date & Time (new)
    nowId,
    nowIso,
    
    // Date & Time (legacy, Templater-compatible)
    generateId,
    generateCreatedTimestamp,
    generateDateId,
    generateCreatedLegacy,
    
    // String & Slug Utilities (new)
    slugify,
    
    // File & Folder Utilities (new)
    exists,
    ensureFolder,
    read,
    write,
    listDir,
    
    // Prompts
    promptTitle,
    promptText,
    promptSuggester,
    promptStatus,
    promptPriority,
    
    // File Operations (legacy)
    renameAndMove,
    safeMove,
    
    // Tags & Strings
    normalizeSlug,
    processTags,
    createYamlArray,
    createYamlList,
    
    // Frontmatter / YAML (new)
    parseYamlFromContent,
    stringifyYaml,
    updateFrontmatter,
    setStatus,
    addMeta,
    ensureTags,
    ensureLang,
    
    // Frontmatter (legacy)
    generateBaseFrontmatter,
    generateProjectFrontmatter,
    
    // Standard Builders (new)
    fmBase,
    fmProject,
    fmArea,
    fmKnowledge,
    fmResource,
    fmIndex,
    
    // Related Items
    createRelatedLinks,
    parseRelatedItems,
    
    // Index & Dataview (new)
    upsertIndex,
    
    // Archiving (legacy)
    getArchivePath,
    getArchiveNotesPath,
    getArchiveProjectsPath,
    generateArchiveMetadata,
    
    // Archiving Core (new)
    dailyArchiveRoot,
    ensureDailyIndex,
    archiveNote,
    archiveProject,
    
    // Error Handling
    safeExecute,
    
    // Validation
    validateProjectName,
    validateDateFormat
};
