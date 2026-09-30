# Vault Automation Scripts

This directory contains shell scripts for automating common vault operations and workflows.

## 📋 Available Scripts

### 1. create_daily_note.sh

**Purpose**: Automatically create daily notes with aggregated information from projects, tasks, and meetings.

**Usage**:
```bash
./create_daily_note.sh [YYYY-MM-DD]
```

**Features**:
- Creates daily note with current date (or specified date)
- Includes Dataview queries for:
  - Priority tasks for the day
  - Scheduled meetings
  - Active tasks from all projects
- Pre-structured sections for morning priorities, notes, achievements, learnings
- Automatic file creation in `02_areas/life/logs/daily/` with Neovim-compatible `YYYYMMDD.md` names and IDs
- Auto-opens note if Obsidian CLI or VS Code is available

**Examples**:
```bash
# Create today's daily note
./create_daily_note.sh

# Create daily note for specific date
./create_daily_note.sh 2025-11-15

# Set custom vault root
VAULT_ROOT=/path/to/vault ./create_daily_note.sh
```

**Environment Variables**:
- `VAULT_ROOT`: Path to vault root (default: current directory)
- `DAILY_NOTES_DIR`: Optional custom daily notes directory (absolute or vault-relative)

---

### 2. archive_inactive.sh

**Purpose**: Bulk archive notes and projects based on status and age criteria.

**Usage**:
```bash
./archive_inactive.sh [OPTIONS]
```

**Options**:
- `--dry-run`: Preview what would be archived without making changes
- `--older-than DAYS`: Only archive items older than specified days (default: 90)
- `--status STATUS`: Filter by status (default: "completed")

**Features**:
- Searches `01_projects/` and `02_areas/` for eligible notes
- Updates frontmatter with archive metadata
- Moves files to `04_archive/<YYYYMMDD>/notes/`
- Preserves original folder structure
- Dry-run mode for safe testing

**Examples**:
```bash
# Dry run to see what would be archived
./archive_inactive.sh --dry-run

# Archive completed items older than 90 days
./archive_inactive.sh

# Archive items with specific status older than 60 days
./archive_inactive.sh --status "done" --older-than 60

# Archive recently completed items (older than 30 days)
./archive_inactive.sh --status "completed" --older-than 30
```

**Archive Structure**:
```
04_archive/
└── YYYYMMDD/
    └── notes/
        ├── note1.md
        ├── note2.md
        └── ...
```

---

### 3. update_task_status.sh

**Purpose**: Bulk update task statuses within a project.

**Usage**:
```bash
./update_task_status.sh <project_path> <old_status> <new_status>
```

**Arguments**:
1. `project_path`: Relative path to project directory (e.g., `01_projects/website_relaunch`)
2. `old_status`: Current status to replace
3. `new_status`: New status to set

**Features**:
- Updates all tasks with matching status in project
- Adds entry to Progression Log with timestamp
- Only affects files with `category: "task"`
- Safe backup creation before modification

**Common Statuses**:
- `active`
- `pending`
- `blocked`
- `completed`
- `archived`

**Examples**:
```bash
# Mark all active tasks as completed
./update_task_status.sh 01_projects/website_relaunch active completed

# Move pending tasks to active
./update_task_status.sh 01_projects/api_integration pending active

# Archive all completed tasks
./update_task_status.sh 01_projects/old_project completed archived
```

**What It Does**:
1. Finds all `.md` files in project directory
2. Filters to only task files (`category: "task"`)
3. Updates status in frontmatter
4. Adds progression log entry
5. Reports count of updated tasks

---

## 🚀 Quick Start

### Setup

1. **Make scripts executable**:
```bash
chmod +x *.sh
```

2. **Set vault root** (optional):
```bash
export VAULT_ROOT=/path/to/your/vault
```

3. **Add to PATH** (optional):
```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:/path/to/vault/99_system/03_workflow/scripts"
```

### Integration with Daily Workflow

**Morning Routine**:
```bash
# Create today's daily note
./create_daily_note.sh
```

**Weekly Routine**:
```bash
# Preview what could be archived
./archive_inactive.sh --dry-run

# Archive if satisfied with preview
./archive_inactive.sh
```

**Project Completion**:
```bash
# Mark all tasks as completed
./update_task_status.sh 01_projects/my_project active completed

# Archive the project (using Obsidian template or manually)
```

---

## 🔧 Configuration

### Environment Variables

All scripts support these environment variables:

- **VAULT_ROOT**: Path to vault root directory
  ```bash
  export VAULT_ROOT="/home/user/Documents/my_vault"
  ```

### Script Variables

You can modify default values at the top of each script:

**archive_inactive.sh**:
```bash
OLDER_THAN_DAYS=90      # Default age threshold
STATUS_FILTER="completed"  # Default status to archive
```

---

## 📁 File Structure

Scripts expect this vault structure:

```
vault/
├── 00_knowledge/
├── 01_projects/
│   └── project_name/
│       └── tasks/
├── 02_areas/
│   ├── 03_daily/        # Daily notes
│   └── 03_weekly/       # Weekly notes
├── 04_archive/
│   └── YYYYMMDD/
│       ├── notes/
│       └── projects/
└── 99_system/
    └── 03_workflow/
        └── scripts/      # This directory
```

---

## 🔒 Safety Features

### Dry Run Mode
All destructive operations support `--dry-run`:
```bash
./archive_inactive.sh --dry-run
```

### Backups
Scripts create `.bak` files before modifications:
```bash
# Original file is backed up to:
note.md.bak
```

### Validation
- Scripts check for required directories
- Validate frontmatter before processing
- Report errors clearly

---

## 🐛 Troubleshooting

### Script Won't Execute

**Problem**: Permission denied

**Solution**:
```bash
chmod +x script_name.sh
```

### Vault Not Found

**Problem**: VAULT_ROOT not set correctly

**Solution**:
```bash
# Set explicitly
export VAULT_ROOT="/path/to/vault"

# Or run from vault directory
cd /path/to/vault
./99_system/03_workflow/scripts/script_name.sh
```

### Date Command Issues

**Problem**: Date parsing errors on macOS

**Solution**: Scripts include macOS-compatible date commands
```bash
# Linux
date -d "30 days ago" +%Y-%m-%d

# macOS (automatically handled in scripts)
date -v-30d +%Y-%m-%d
```

### Frontmatter Not Updating

**Problem**: Status not changing in files

**Solution**:
- Ensure frontmatter uses proper YAML format
- Check for consistent quote usage (`"` or `'`)
- Verify `category: "task"` exists in task files

---

## 🔄 Integration with Obsidian

### Templater Integration

These scripts complement Obsidian templates:

1. **Daily Notes**: Script creates structure, Templater fills dynamic content
2. **Archiving**: Scripts for bulk operations, templates for single items
3. **Status Updates**: Scripts for bulk updates, manual for individual tasks

### Dataview Queries

Scripts create files that work with Dataview:
- Proper frontmatter structure
- Consistent date formats
- Standard status values

---

## 📚 Best Practices

### Regular Execution

**Daily**:
```bash
./create_daily_note.sh
```

**Weekly**:
```bash
# Check what could be archived
./archive_inactive.sh --dry-run --older-than 60
```

**Monthly**:
```bash
# Archive completed items
./archive_inactive.sh --older-than 90

# Archive done items
./archive_inactive.sh --status "done" --older-than 90
```

### Before Bulk Operations

1. **Always run dry-run first**:
```bash
./archive_inactive.sh --dry-run
```

2. **Backup important data**:
```bash
cp -r 01_projects 01_projects.backup
```

3. **Test on single project first**:
```bash
./update_task_status.sh 01_projects/test_project active completed
```

---

## 🛠️ Customization

### Adding Custom Scripts

1. Create new script in this directory
2. Make it executable: `chmod +x new_script.sh`
3. Follow the pattern of existing scripts
4. Update this README

### Modifying Existing Scripts

**Template for new features**:
```bash
#!/bin/bash
# your_script.sh - Description

set -e  # Exit on error

VAULT_ROOT="${VAULT_ROOT:-$(pwd)}"

# Your code here
```

---

## 📝 Contributing

When adding or modifying scripts:

1. **Document changes** in this README
2. **Add examples** of usage
3. **Include error handling**
4. **Support dry-run mode** for destructive operations
5. **Test on multiple platforms** (Linux, macOS)

---

## 🔗 Related Documentation

- **Templates**: `../../01_templates/CHANGELOG.md`
- **Library Functions**: `../../_scripts/README.md`
- **Workflow Guide**: `../WORKFLOW_GUIDE.md`

---

## 📋 Script Checklist

When creating daily workflow:

- [ ] Run `create_daily_note.sh` in morning
- [ ] Update task statuses throughout day
- [ ] Weekly: Run archive dry-run
- [ ] Monthly: Execute archive for old items
- [ ] Quarterly: Bulk update project statuses

---

**Version**: 1.0  
**Last Updated**: 2025-11-11  
**Maintainer**: Vault Automation Team
