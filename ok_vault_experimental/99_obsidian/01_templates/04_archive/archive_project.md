<%*
/**
 * Archive Project Action Template
 * 
 * Archives entire project folder to daily archive structure:
 * 04_archive/<YYYYMMDD>/projects/<project_slug>/
 * 
 * Sets status: archived in all markdown files and adds archive metadata.
 * Updates daily index automatically.
 */

// Load library
const lib = tp.user.lib;
const app = this.app;

// Get current folder (project directory)
let projectDir = tp.file.folder(true);

// Confirm or prompt for project directory
const confirmPath = await tp.system.suggester(
    [`Yes - Archive ${projectDir}`, "No - Enter different path"],
    [true, false],
    false,
    "Archive this project folder?"
);

if (!confirmPath) {
    projectDir = await lib.promptText(tp, "Enter project directory path:", projectDir);
}

// Prompt for optional dry-run
const dryRun = await tp.system.suggester(
    ["No - Archive the project", "Yes - Dry run (show what would happen)"],
    [false, true],
    false,
    "Dry run mode?"
);

// Optional: Custom date (default: today)
const useCustomDate = await tp.system.suggester(
    ["Use today's date", "Use custom date"],
    [false, true],
    false,
    "Archive date?"
);

let dateId = null;
if (useCustomDate) {
    dateId = await lib.promptText(tp, "Enter date (YYYYMMDD):", lib.generateDateId(tp));
}

// Execute archive
const result = await lib.archiveProject(app, {
    projectDir,
    dateId,
    dryRun
});

// Show result
if (result.success) {
    if (dryRun) {
        await tp.system.prompt(`DRY RUN: Would archive ${result.fileCount} files to: ${result.destPath}`);
    } else {
        await tp.system.prompt(`Project archived successfully! ${result.fileCount} files moved to: ${result.destPath}`);
    }
} else {
    await tp.system.prompt("Archive failed: " + result.error);
}
-%>
