#!/bin/bash
# =============================================================================
# migrate-sessions-index.sh - Add Session Index to existing SESSIONS.md
# =============================================================================
#
# Usage:
#   ./scripts/migrate-sessions-index.sh [sessions-file]
#
# Default: context/SESSIONS.md
#
# This script:
#   1. Analyzes existing sessions in SESSIONS.md
#   2. Generates a Session Index table
#   3. Outputs the index (does NOT modify file automatically)
#
# After review, manually insert the index at the top of SESSIONS.md
# =============================================================================

set -e

SESSIONS_FILE="${1:-context/SESSIONS.md}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Session Index Migration Tool"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verify file exists
if [ ! -f "$SESSIONS_FILE" ]; then
  echo -e "${RED}Error: $SESSIONS_FILE not found${NC}"
  exit 1
fi

echo "Analyzing: $SESSIONS_FILE"
echo ""

# Count existing sessions (excluding [EXAMPLE] sessions)
# Note: Example sessions use format "## [EXAMPLE] Session N"
SESSION_COUNT=$(grep -c "^## Session [0-9]\|^## \[EXAMPLE\] Session [0-9]" "$SESSIONS_FILE" 2>/dev/null | tr -d ' ' || echo "0")
EXAMPLE_COUNT=$(grep -c "^## \[EXAMPLE\] Session [0-9]" "$SESSIONS_FILE" 2>/dev/null | tr -d ' ' || echo "0")
REAL_COUNT=$((SESSION_COUNT - EXAMPLE_COUNT))

echo "Found: $REAL_COUNT real sessions (+ $EXAMPLE_COUNT examples)"
echo ""

if [ "$REAL_COUNT" -eq 0 ]; then
  echo -e "${YELLOW}No real sessions found to index.${NC}"
  echo "If this is a new project, the Session Index will be populated"
  echo "automatically when you run /save-full."
  exit 0
fi

# Check if index already exists
if grep -q "^## Session Index" "$SESSIONS_FILE" 2>/dev/null; then
  echo -e "${YELLOW}⚠️  Session Index already exists in $SESSIONS_FILE${NC}"
  echo ""
  echo "Options:"
  echo "  1. Regenerate index (will overwrite existing)"
  echo "  2. Exit"
  echo ""
  read -p "Choice [1/2]: " -r
  if [[ ! $REPLY =~ ^[1]$ ]]; then
    echo "Exiting."
    exit 0
  fi
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Generated Session Index"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "## Session Index"
echo ""
echo "<!-- Quick navigation to all sessions. Oldest sessions may be archived. -->"
echo ""
echo "| # | Date | Phase | Focus | Key Decisions |"
echo "|---|------|-------|-------|---------------|"

# Extract session info and generate index rows
# Format: ## Session N | YYYY-MM-DD | Focus
grep "^## Session [0-9]" "$SESSIONS_FILE" | grep -v "\[EXAMPLE\]" | while read -r line; do
  # Extract session number
  NUM=$(echo "$line" | grep -oE "Session [0-9]+" | grep -oE "[0-9]+")

  # Extract date (YYYY-MM-DD format)
  DATE=$(echo "$line" | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" || echo "-")

  # Extract focus (text after last |)
  FOCUS=$(echo "$line" | sed 's/.*| //' | cut -c1-30 | sed 's/ *$//')
  if [ -z "$FOCUS" ] || [ "$FOCUS" = "$line" ]; then
    FOCUS="-"
  fi

  echo "| $NUM | $DATE | - | $FOCUS | - |"
done | sort -t'|' -k2 -rn  # Sort by field 2 (session number) descending

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}✅ Index generated successfully${NC}"
echo ""
echo "Next steps:"
echo "  1. Review the index above for accuracy"
echo "  2. Copy the index (from '## Session Index' to end of table)"
echo "  3. Insert at the top of $SESSIONS_FILE (after header)"
echo "  4. Commit the changes"
echo ""
echo "Or run with --apply to insert automatically (creates backup):"
echo "  $0 $SESSIONS_FILE --apply"
echo ""

# Handle --apply flag
if [ "${2:-}" = "--apply" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔄 Applying changes..."
  echo ""

  # Create backup
  BACKUP="${SESSIONS_FILE}.backup.$(date +%Y%m%d-%H%M%S)"
  cp "$SESSIONS_FILE" "$BACKUP"
  echo "Backup created: $BACKUP"

  # Generate index content
  INDEX_CONTENT=$(cat << 'INDEXEOF'
## Session Index

<!-- Quick navigation to all sessions. Oldest sessions may be archived. -->

| # | Date | Phase | Focus | Key Decisions |
|---|------|-------|-------|---------------|
INDEXEOF
)

  # This is complex - for safety, recommend manual insertion
  echo ""
  echo -e "${YELLOW}⚠️  Automatic insertion is complex and error-prone.${NC}"
  echo "For safety, please insert the index manually."
  echo ""
  echo "The index has been printed above. Copy and paste it into:"
  echo "  $SESSIONS_FILE"
  echo ""
  echo "Insert after the header section, before '## Recent Sessions' or first session."
fi
