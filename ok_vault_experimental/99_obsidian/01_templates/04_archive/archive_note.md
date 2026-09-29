<%*
/**
 * Archive Note Action Template
 * 
 * Archives current note to daily archive structure:
 * 04_archive/<YYYYMMDD>/notes/
 * 
 * Sets status: archived and adds archive metadata.
 * Updates daily index automatically.
 */

// Load library
const lib = tp.user.lib;
const app = this.app;

// Get current file path and name
const currentPath = tp.file.path(true);
const notePath = currentPath;

// Prompt for optional dry-run
const dryRun = await tp.system.suggester(
    ["No - Archive the note", "Yes - Dry run (show what would happen)"],
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
const result = await lib.archiveNote(app, {
    notePath,
    dateId,
    dryRun
});

// Show result
if (result.success) {
    if (dryRun) {
        await tp.system.prompt("DRY RUN: Would archive to: " + result.destPath);
    } else {
        await tp.system.prompt("Note archived successfully to: " + result.destPath);
    }
} else {
    await tp.system.prompt("Archive failed: " + result.error);
}
-%>
