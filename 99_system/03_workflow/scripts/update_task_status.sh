#!/bin/bash
# update_task_status.sh - Bulk update task status in project
# Usage: ./update_task_status.sh <project_path> <old_status> <new_status>

set -e

VAULT_ROOT="${VAULT_ROOT:-$(pwd)}"

# Check arguments
if [ $# -lt 3 ]; then
    echo "Usage: $0 <project_path> <old_status> <new_status>"
    echo ""
    echo "Example: $0 01_projects/website_relaunch active completed"
    echo ""
    echo "Common statuses: active, pending, blocked, completed, archived"
    exit 1
fi

PROJECT_PATH="${VAULT_ROOT}/$1"
OLD_STATUS="$2"
NEW_STATUS="$3"

# Validate project path
if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ Error: Project directory not found: $PROJECT_PATH"
    exit 1
fi

echo "🔄 Updating task status in project..."
echo "   Project: $1"
echo "   Change: ${OLD_STATUS} → ${NEW_STATUS}"
echo ""

UPDATED_COUNT=0

# Find all task files in project
while IFS= read -r -d '' file; do
    # Check if file has task category
    if grep -q 'category: "task"' "$file" || grep -q "category: 'task'" "$file"; then
        # Check if file has the old status
        if grep -q "status: \"${OLD_STATUS}\"" "$file" || grep -q "status: '${OLD_STATUS}'" "$file"; then
            # Update status in file
            sed -i.bak "s/status: [\"']${OLD_STATUS}[\"']/status: \"${NEW_STATUS}\"/" "$file"

            # Add to progression log
            timestamp=$(date +"%Y-%m-%d %H:%M")

            # Append to progression log section if it exists
            if grep -q "## Progression Log" "$file"; then
                sed -i.bak "/## Progression Log/a\\
\\
**${timestamp}**: Status changed from \`${OLD_STATUS}\` to \`${NEW_STATUS}\` (bulk update)" "$file"
            fi

            # Remove backup
            rm "${file}.bak"

            rel_path="${file#"${VAULT_ROOT}"/}"
            echo "  ✅ Updated: ${rel_path}"
            UPDATED_COUNT=$((UPDATED_COUNT + 1))
        fi
    fi
done < <(find "$PROJECT_PATH" -name "*.md" -type f -print0)

echo ""
echo "✅ Updated ${UPDATED_COUNT} task(s) in project"
