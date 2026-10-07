#!/bin/bash
# create_daily_note.sh - Automatically create daily note with aggregations
# Usage: ./create_daily_note.sh [YYYY-MM-DD]

set -e

VAULT_ROOT="${VAULT_ROOT:-$(pwd)}"

if [ -n "${DAILY_NOTES_DIR:-}" ]; then
    # Support absolute and vault-relative custom daily directories
    if [[ "${DAILY_NOTES_DIR}" != /* ]]; then
        DAILY_NOTES_DIR="${VAULT_ROOT}/${DAILY_NOTES_DIR}"
    fi
else
    DAILY_NOTES_DIR="${VAULT_ROOT}/02_areas/life/logs/daily"
fi

# Use provided date or today
DATE="${1:-$(date +%Y-%m-%d)}"
if [[ ! "${DATE}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Date must be YYYY-MM-DD" >&2
    exit 2
fi
DATE_ID=$(echo "$DATE" | tr -d '-')
FILENAME="${DATE_ID}.md"
FILEPATH="${DAILY_NOTES_DIR}/${FILENAME}"

# Create directory if it doesn't exist
mkdir -p "${DAILY_NOTES_DIR}"

# Check if note already exists
if [ -e "${FILEPATH}" ] || [ -L "${FILEPATH}" ]; then
    echo "Daily note for ${DATE} already exists: ${FILEPATH}"
    echo "Opening note..."
    # If Obsidian CLI is available, open the note
    if command -v obsidian &> /dev/null; then
        obsidian "${FILEPATH}"
    fi
    exit 0
fi

# Create the daily note with frontmatter and structure
cat > "${FILEPATH}" << EOF
---
title: "daily - ${DATE}"
id: "${DATE_ID}"
created: "${DATE} $(date +%H:%M)"
lang: "en"
tags:
  - "daily"
  - "periodic"
category: "daily"
status: "active"
date: "${DATE}"
---

# Daily Note - ${DATE}

## Priority Tasks

\`\`\`dataview
TABLE status, priority, project
FROM #task
WHERE contains(file.name, "${DATE}") OR contains(due, "${DATE}")
SORT priority DESC, created ASC
LIMIT 10
\`\`\`

## Scheduled Meetings

\`\`\`dataview
TABLE thema, attendees, project
FROM #meeting
WHERE contains(date, "${DATE_ID}")
SORT file.ctime ASC
\`\`\`

## Active Tasks (All Projects)

\`\`\`dataview
TABLE status, project, priority
FROM #task
WHERE status = "active"
SORT priority DESC, created ASC
LIMIT 15
\`\`\`

## Today's Log

### Morning Priorities
1.
2.
3.

### Notes
-

### Achievements
-

### Learnings
-

### Tomorrow
- [ ]

---

EOF

echo "✅ Daily note created: ${FILEPATH}"
echo "Date: ${DATE}"
echo "Opening note..."

# Try to open in Obsidian if available
if command -v obsidian &> /dev/null; then
    obsidian "${FILEPATH}"
elif command -v code &> /dev/null; then
    code "${FILEPATH}"
else
    echo "Tip: Install Obsidian CLI or VS Code to auto-open notes"
fi
