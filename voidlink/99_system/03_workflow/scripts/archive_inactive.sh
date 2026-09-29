#!/bin/bash
# archive_inactive.sh - Archive notes and projects by status
# Usage: ./archive_inactive.sh [--dry-run] [--older-than DAYS]

set -e

VAULT_ROOT="${VAULT_ROOT:-$(pwd)}"
ARCHIVE_ROOT="${VAULT_ROOT}/04_archive"
DATE_ID=$(date +%Y%m%d)

# Default values
DRY_RUN=false
OLDER_THAN_DAYS=90
STATUS_FILTER="completed"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --older-than)
            OLDER_THAN_DAYS="$2"
            shift 2
            ;;
        --status)
            STATUS_FILTER="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--dry-run] [--older-than DAYS] [--status STATUS]"
            exit 1
            ;;
    esac
done

echo "🔍 Searching for notes to archive..."
echo "   Status filter: ${STATUS_FILTER}"
echo "   Older than: ${OLDER_THAN_DAYS} days"
echo "   Dry run: ${DRY_RUN}"
echo ""

# Calculate cutoff date
CUTOFF_DATE=$(date -d "${OLDER_THAN_DAYS} days ago" +%Y-%m-%d 2>/dev/null || date -v-"${OLDER_THAN_DAYS}"d +%Y-%m-%d)

# Function to extract frontmatter field
get_frontmatter_field() {
    local file="$1"
    local field="$2"

    awk -v field="$field" '
        BEGIN { in_fm=0; }
        /^---$/ {
            if (NR==1) { in_fm=1; next; }
            else if (in_fm) { exit; }
        }
        in_fm && $0 ~ "^" field ":" {
            sub("^" field ": *", "");
            gsub(/"/, "");
            print;
            exit;
        }
    ' "$file"
}

# Function to update frontmatter status
update_frontmatter_status() {
    local file="$1"
    local temp_file="${file}.tmp"

    awk '
        BEGIN { in_fm=0; fm_done=0; }
        /^---$/ {
            if (NR==1) { in_fm=1; print; next; }
            else if (in_fm) {
                in_fm=0; fm_done=1;
                if (!status_found) {
                    print "status: \"archived\"";
                    print "archived_on: \"'"$(date +"%Y-%m-%d %H:%M")"'\"";
                    print "archived_by: \"script\"";
                }
                print; next;
            }
        }
        in_fm && /^status:/ {
            print "status: \"archived\"";
            print "archived_on: \"'"$(date +"%Y-%m-%d %H:%M")"'\"";
            print "archived_by: \"script\"";
            status_found=1;
            next;
        }
        { print; }
    ' "$file" > "$temp_file"

    mv "$temp_file" "$file"
}

# Find and process files
ARCHIVED_COUNT=0

# Search in projects and areas
for dir in "01_projects" "02_areas"; do
    if [ ! -d "${VAULT_ROOT}/${dir}" ]; then
        continue
    fi

    while IFS= read -r -d '' file; do
        # Skip index files
        if [[ $(basename "$file") == "00_index.md" ]]; then
            continue
        fi

        # Get status and date from frontmatter
        status=$(get_frontmatter_field "$file" "status")
        created=$(get_frontmatter_field "$file" "created")

        # Check if status matches and file is old enough
        if [[ "$status" == "$STATUS_FILTER" || "$status" == "done" || "$status" == "closed" ]]; then
            # Extract date portion (handle various formats)
            file_date=$(echo "$created" | cut -d' ' -f1)

            if [[ "$file_date" < "$CUTOFF_DATE" ]]; then
                rel_path="${file#"${VAULT_ROOT}"/}"

                if [ "$DRY_RUN" = true ]; then
                    echo "  [DRY-RUN] Would archive: ${rel_path}"
                else
                    # Create archive directory structure
                    archive_dir="${ARCHIVE_ROOT}/${DATE_ID}/notes"
                    mkdir -p "$archive_dir"

                    # Update frontmatter
                    update_frontmatter_status "$file"

                    # Move file
                    filename=$(basename "$file")
                    mv "$file" "${archive_dir}/${filename}"

                    echo "  ✅ Archived: ${rel_path} → ${archive_dir}/${filename}"
                    ARCHIVED_COUNT=$((ARCHIVED_COUNT + 1))
                fi
            fi
        fi
    done < <(find "${VAULT_ROOT}/${dir}" -name "*.md" -type f -print0)
done

echo ""
if [ "$DRY_RUN" = true ]; then
    echo "📋 Dry run complete. Would archive ${ARCHIVED_COUNT} files."
    echo "   Run without --dry-run to actually archive."
else
    echo "✅ Archived ${ARCHIVED_COUNT} files to ${ARCHIVE_ROOT}/${DATE_ID}/"
fi
