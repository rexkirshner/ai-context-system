#!/bin/bash
# Archive old decisions from DECISIONS.md
# Version: See VERSION file at repository root
#
# Usage:
#   ./archive-decisions-helper.sh [--keep N] [--context DIR]
#
# Options:
#   --keep N        Keep N most recent decisions (default: 50)
#   --context DIR   Context directory (default: context)
#   --no-backup     Skip backup creation (not recommended)
#   --dry-run       Show what would be done without making changes
#   --force         Skip confirmation prompts (for automation)

set -e

# Source common functions for colors and exit codes (if available)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/common-functions.sh" ]; then
  source "$SCRIPT_DIR/common-functions.sh"
fi

# Cleanup function to remove temp files on exit
cleanup() {
  rm -f "$TEMP_FILE" "$ARCHIVE_TEMP" 2>/dev/null
}
trap cleanup EXIT ERR

# Default values
KEEP_RECENT=50
CONTEXT_DIR="context"
CREATE_BACKUP=true
DRY_RUN=false
FORCE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --keep)
      KEEP_RECENT="$2"
      shift 2
      ;;
    --context)
      CONTEXT_DIR="$2"
      if [ ! -d "$CONTEXT_DIR" ]; then
        echo "Error: Context directory does not exist: $CONTEXT_DIR" >&2
        exit 1
      fi
      shift 2
      ;;
    --no-backup)
      CREATE_BACKUP=false
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --force)
      FORCE=true
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Usage: $0 [--keep N] [--context DIR] [--no-backup] [--dry-run] [--force]" >&2
      exit 1
      ;;
  esac
done

# File paths
DECISIONS_FILE="$CONTEXT_DIR/DECISIONS.md"
BACKUP_FILE="$DECISIONS_FILE.backup"
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
# v5.1.0: Archive to subdirectory to keep context/ clean
ARCHIVE_DIR="$CONTEXT_DIR/.decisions-archive"
ARCHIVE_FILE="$ARCHIVE_DIR/decisions-archive-$TIMESTAMP.md"
TEMP_FILE="$DECISIONS_FILE.tmp"

# Validate inputs
if [ ! -f "$DECISIONS_FILE" ]; then
  echo "Error: $DECISIONS_FILE not found" >&2
  exit 1
fi

if ! [[ "$KEEP_RECENT" =~ ^[0-9]+$ ]]; then
  echo "Error: --keep must be a number" >&2
  exit 1
fi

echo "AI Context System - Decision Archiving"
echo "======================================="
echo "   Decisions file: $DECISIONS_FILE"
echo "   Keep recent: $KEEP_RECENT decisions"
echo "   Archive file: $ARCHIVE_FILE"
echo ""

# Count total decisions (## D### - format)
TOTAL_DECISIONS=$(grep -cE "^## D[0-9]+ -" "$DECISIONS_FILE" 2>/dev/null || echo "0")

if [ "$TOTAL_DECISIONS" -eq 0 ]; then
  echo "No decisions found in $DECISIONS_FILE"
  exit 0
fi

echo "Found $TOTAL_DECISIONS total decisions"

# Check if archiving is needed
if [ "$TOTAL_DECISIONS" -le "$KEEP_RECENT" ]; then
  echo "No archiving needed ($TOTAL_DECISIONS decisions <= $KEEP_RECENT keep)"
  exit 0
fi

DECISIONS_TO_ARCHIVE=$((TOTAL_DECISIONS - KEEP_RECENT))
echo "Will archive $DECISIONS_TO_ARCHIVE old decisions"
echo ""

if [ "$DRY_RUN" = true ]; then
  echo "DRY RUN - No changes will be made"
  echo "   Would keep last $KEEP_RECENT decisions"
  echo "   Would archive first $DECISIONS_TO_ARCHIVE decisions to $ARCHIVE_FILE"
  exit 0
fi

# Create backup
if [ "$CREATE_BACKUP" = true ]; then
  echo "Creating backup..."
  cp "$DECISIONS_FILE" "$BACKUP_FILE"
  echo "   Backup saved: $BACKUP_FILE"
fi

echo "Processing DECISIONS.md..."

# Find where decisions start (after the header/index section)
# Look for the first "## D###" pattern
FIRST_DECISION_LINE=$(grep -nE "^## D[0-9]+ -" "$DECISIONS_FILE" | head -1 | cut -d: -f1)

if [ -z "$FIRST_DECISION_LINE" ]; then
  echo "Error: Could not find decision entries" >&2
  exit 1
fi

# Extract header (everything before first decision)
HEADER_END=$((FIRST_DECISION_LINE - 1))
head -n "$HEADER_END" "$DECISIONS_FILE" > "$TEMP_FILE"

# Find decision boundaries - get line numbers where "## D### -" appears
DECISION_LINES=()
while IFS= read -r line; do
  DECISION_LINES+=("$line")
done < <(grep -nE "^## D[0-9]+ -" "$DECISIONS_FILE" | cut -d: -f1)

if [ "${#DECISION_LINES[@]}" -ne "$TOTAL_DECISIONS" ]; then
  echo "Error: Decision count mismatch (found ${#DECISION_LINES[@]}, expected $TOTAL_DECISIONS)" >&2
  rm -f "$TEMP_FILE"
  exit 1
fi

# Calculate which decisions to keep (last N)
KEEP_START_INDEX=$((TOTAL_DECISIONS - KEEP_RECENT))

# Extract decisions to archive
# v5.1.0: Create archive subdirectory if it doesn't exist
if [ ! -d "$ARCHIVE_DIR" ]; then
  mkdir -p "$ARCHIVE_DIR"
  echo "Created archive directory: $ARCHIVE_DIR"
fi
echo "Creating archive file..."

# Get first and last decision IDs for archive header
FIRST_DECISION_LINE_CONTENT=$(sed -n "${DECISION_LINES[0]}p" "$DECISIONS_FILE")
FIRST_DECISION_ID=$(echo "$FIRST_DECISION_LINE_CONTENT" | grep -oE 'D[0-9]+' | head -1)

LAST_ARCHIVED_LINE_CONTENT=$(sed -n "${DECISION_LINES[$((KEEP_START_INDEX - 1))]}p" "$DECISIONS_FILE")
LAST_ARCHIVED_ID=$(echo "$LAST_ARCHIVED_LINE_CONTENT" | grep -oE 'D[0-9]+' | head -1)

# Create archive file
ARCHIVE_TEMP="$ARCHIVE_FILE.tmp"
cat > "$ARCHIVE_TEMP" << EOF
# Archived Decisions ($(date +%Y-%m-%d))

This file contains archived decisions from DECISIONS.md.

**Archived:** $TIMESTAMP
**Decisions:** $FIRST_DECISION_ID through $LAST_ARCHIVED_ID

---

EOF

# Extract old decisions for archive
FILE_LINES=$(wc -l < "$DECISIONS_FILE" | tr -d ' ')
for i in $(seq 0 $((KEEP_START_INDEX - 1))); do
  DECISION_START="${DECISION_LINES[$i]}"

  # Find end of this decision (start of next decision, or end of file)
  if [ $((i + 1)) -lt "$TOTAL_DECISIONS" ]; then
    DECISION_END=$((${DECISION_LINES[$((i + 1))]} - 1))
  else
    DECISION_END=$FILE_LINES
  fi

  # Extract decision
  sed -n "${DECISION_START},${DECISION_END}p" "$DECISIONS_FILE" >> "$ARCHIVE_TEMP"

  # Only add separator if not last decision in archive
  if [ $i -lt $((KEEP_START_INDEX - 1)) ]; then
    echo "" >> "$ARCHIVE_TEMP"
  fi
done

mv "$ARCHIVE_TEMP" "$ARCHIVE_FILE"
echo "   Archived $DECISIONS_TO_ARCHIVE decisions to $ARCHIVE_FILE"

# Build new DECISIONS.md with header and last N decisions
echo "Keeping last $KEEP_RECENT decisions..."

# Now rebuild the index with only the kept decisions
# First, collect the decision IDs and info we're keeping
KEPT_DECISIONS_INFO=()
for i in $(seq "$KEEP_START_INDEX" $((TOTAL_DECISIONS - 1))); do
  DECISION_LINE="${DECISION_LINES[$i]}"
  DECISION_HEADER=$(sed -n "${DECISION_LINE}p" "$DECISIONS_FILE")

  # Extract ID (D###)
  DECISION_ID=$(echo "$DECISION_HEADER" | grep -oE 'D[0-9]+' | head -1)

  # Extract title (everything after "D### - ")
  DECISION_TITLE=$(echo "$DECISION_HEADER" | sed -E 's/^## D[0-9]+ - //')

  # Find status line within this decision
  if [ $((i + 1)) -lt "$TOTAL_DECISIONS" ]; then
    DECISION_END_LINE=$((${DECISION_LINES[$((i + 1))]} - 1))
  else
    DECISION_END_LINE=$FILE_LINES
  fi

  # Extract status from **Status:** line
  STATUS=$(sed -n "${DECISION_LINE},${DECISION_END_LINE}p" "$DECISIONS_FILE" | grep -E '^\*\*Status:\*\*' | head -1 | sed -E 's/\*\*Status:\*\* *//')

  # Extract date from **Date:** line
  DATE=$(sed -n "${DECISION_LINE},${DECISION_END_LINE}p" "$DECISIONS_FILE" | grep -E '^\*\*Date:\*\*' | head -1 | sed -E 's/\*\*Date:\*\* *//')

  KEPT_DECISIONS_INFO+=("$DECISION_ID|$DATE|$DECISION_TITLE|$STATUS")
done

# Write new header with updated index
cat > "$TEMP_FILE" << 'HEADER'
# DECISIONS.md

**Decision log** - WHY choices were made. **Critical for AI agent review and takeover.**

**For current status:** See `STATUS.md`
**For session history:** See `SESSIONS.md`

---

## Decision Index

Quick reference to all decisions. **Keep this updated** - AI agents use this for navigation in large files.

| ID | Date | Topic | Status |
|----|------|-------|--------|
HEADER

# Add index entries for kept decisions
for info in "${KEPT_DECISIONS_INFO[@]}"; do
  IFS='|' read -r id date title status <<< "$info"
  echo "| $id | $date | $title | $status |" >> "$TEMP_FILE"
done

cat >> "$TEMP_FILE" << 'FOOTER'

> **For large files:** When DECISIONS.md exceeds 2000 lines, AI agents load this index + recent decisions only. Keep index current!

---

FOOTER

# Now add the kept decisions
for i in $(seq "$KEEP_START_INDEX" $((TOTAL_DECISIONS - 1))); do
  DECISION_START="${DECISION_LINES[$i]}"

  # Find end of this decision
  if [ $((i + 1)) -lt "$TOTAL_DECISIONS" ]; then
    DECISION_END=$((${DECISION_LINES[$((i + 1))]} - 1))
  else
    DECISION_END=$FILE_LINES
  fi

  # Extract decision
  sed -n "${DECISION_START},${DECISION_END}p" "$DECISIONS_FILE" >> "$TEMP_FILE"

  # Only add separator if not last decision
  if [ $i -lt $((TOTAL_DECISIONS - 1)) ]; then
    echo "" >> "$TEMP_FILE"
  fi
done

# Replace original file
if [ -f "$TEMP_FILE" ] && [ -s "$TEMP_FILE" ]; then
  mv "$TEMP_FILE" "$DECISIONS_FILE"
else
  echo "Error: Generated DECISIONS.md is empty or missing" >&2
  echo "   Backup is at: $BACKUP_FILE" >&2
  exit 1
fi

echo ""
echo "======================================="
echo "Archiving complete!"
echo ""
echo "Summary:"
echo "   Main file: $KEEP_RECENT decisions (kept)"
echo "   Archive file: $DECISIONS_TO_ARCHIVE decisions (archived)"
echo "   Total: $TOTAL_DECISIONS decisions (no data loss)"
echo ""
echo "Backup: $BACKUP_FILE"
echo "Archive: $ARCHIVE_FILE"
echo ""
echo "To restore from backup: cp $BACKUP_FILE $DECISIONS_FILE"
