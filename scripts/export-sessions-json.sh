#!/bin/bash

# export-sessions-json.sh
# Exports SESSIONS.md to machine-readable JSON format
# Version: 4.2.0

set -e

# Source common functions for colors, exit codes, and utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/common-functions.sh" ]; then
  source "$SCRIPT_DIR/common-functions.sh"
else
  # Fallback colors if common-functions.sh not available
  GREEN='\033[0;32m'
  BLUE='\033[0;34m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  NC='\033[0m'
fi

# Base directory
BASE_DIR="$(dirname "$SCRIPT_DIR")"
CONTEXT_DIR="${BASE_DIR}/context"

echo -e "${BLUE}📊 Exporting SESSIONS.md to JSON...${NC}"
echo ""

# =============================================================================
# Step 1: Verify SESSIONS.md exists
# =============================================================================

if [ ! -f "$CONTEXT_DIR/SESSIONS.md" ]; then
  log_error "SESSIONS.md not found"
  echo "   Expected: $CONTEXT_DIR/SESSIONS.md"
  echo ""
  echo "Run /init-context first to initialize the context system"
  exit ${EXIT_NOT_FOUND:-1}
fi

# =============================================================================
# Step 2: Get metadata
# =============================================================================

VERSION=$(grep -m 1 '"version":' "$CONTEXT_DIR/.context-config.json" | cut -d'"' -f4 2>/dev/null || echo "1.8.0")
PROJECT_NAME=$(grep -m 1 '"name":' "$CONTEXT_DIR/.context-config.json" | cut -d'"' -f4 2>/dev/null || echo "Unknown Project")
EXPORTED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TOTAL_SESSIONS=$(grep -c "^## Session" "$CONTEXT_DIR/SESSIONS.md" 2>/dev/null || echo "0")

echo "   Project: $PROJECT_NAME"
echo "   Version: $VERSION"
echo "   Total sessions: $TOTAL_SESSIONS"
echo ""

# =============================================================================
# Step 3: Create JSON structure
# =============================================================================

OUTPUT_FILE="$CONTEXT_DIR/.sessions-data.json"

# Start JSON
cat > "$OUTPUT_FILE" <<EOF
{
  "metadata": {
    "version": "$VERSION",
    "exportedAt": "$EXPORTED_AT",
    "projectName": "$PROJECT_NAME",
    "totalSessions": $TOTAL_SESSIONS
  },
  "sessions": [
EOF

# =============================================================================
# Step 4: Parse SESSIONS.md and extract session data
# =============================================================================

echo -e "${BLUE}📝 Parsing sessions...${NC}"

# This is a simplified parser that extracts basic session metadata
# For full parsing, a more sophisticated tool (Python/Node.js) would be better
# This version extracts: session number, date, phase, duration, focus, status

SESSION_COUNT=0

# Extract sessions using awk
awk '
  BEGIN {
    session_count = 0
    in_session = 0
  }

  # Match session header: ## Session N | YYYY-MM-DD | Phase
  /^## Session [0-9]+ \| [0-9]{4}-[0-9]{2}-[0-9]{2}/ {
    # Close previous session JSON if exists
    if (in_session == 1 && session_count > 0) {
      print "    }"
      if (session_count > 1) {
        print "    ,"
      }
    }

    session_count++
    in_session = 1

    # Parse header
    match($0, /Session ([0-9]+)/, session_num)
    match($0, /([0-9]{4}-[0-9]{2}-[0-9]{2})/, session_date)

    # Extract phase (everything after second |)
    phase = $0
    sub(/^## Session [0-9]+ \| [0-9]{4}-[0-9]{2}-[0-9]{2} \| /, "", phase)

    # Start session JSON
    if (session_count > 1) {
      print ","
    }
    print "    {"
    print "      \"sessionNumber\": " session_num[1] ","
    print "      \"date\": \"" session_date[1] "\","
    print "      \"phase\": \"" phase "\","

    next
  }

  # Match duration/focus/status line
  /^\*\*Duration:\*\*/ {
    if (in_session == 1) {
      # Extract duration, focus, status
      match($0, /Duration:\*\* ([^ ]+)/, duration)
      match($0, /Focus:\*\* ([^|]+)/, focus)
      match($0, /Status:\*\* (.+)$/, status)

      # Clean up extracted values
      gsub(/^[ \t]+|[ \t]+$/, "", focus[1])
      gsub(/^[ \t]+|[ \t]+$/, "", status[1])

      print "      \"duration\": \"" duration[1] "\","
      print "      \"focus\": \"" focus[1] "\","
      print "      \"status\": \"" status[1] "\""
    }
    next
  }

  END {
    # Close last session
    if (in_session == 1) {
      print "    }"
    }
  }
' "$CONTEXT_DIR/SESSIONS.md" >> "$OUTPUT_FILE"

# Close sessions array and JSON
cat >> "$OUTPUT_FILE" <<EOF

  ]
}
EOF

# =============================================================================
# Step 5: Validate JSON
# =============================================================================

echo -e "${BLUE}🔍 Validating JSON...${NC}"

if command -v jq &> /dev/null; then
  if jq empty "$OUTPUT_FILE" 2>/dev/null; then
    echo "   ✅ Valid JSON"

    # Pretty-print with jq
    jq '.' "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp"
    mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"

    echo "   ✅ Formatted with jq"
  else
    log_error "Invalid JSON generated"
    echo "   File: $OUTPUT_FILE"
    exit ${EXIT_VALIDATION:-1}
  fi
else
  echo "   ⚠️  jq not installed (skipping validation)"
  echo "   Install jq to validate JSON: brew install jq"
fi

echo ""

# =============================================================================
# Step 6: Summary
# =============================================================================

FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)

echo -e "${GREEN}✅ Export complete!${NC}"
echo ""
echo "   Output: $OUTPUT_FILE"
echo "   Size: $FILE_SIZE"
echo "   Sessions: $TOTAL_SESSIONS"
echo ""
echo "   This JSON file can be consumed by:"
echo "   - Other AI agents for context handoff"
echo "   - Analytics tools"
echo "   - External automation"
echo "   - Multi-agent workflows"
echo ""

# =============================================================================
# Step 7: Offer to validate against schema
# =============================================================================

if [ -f "$BASE_DIR/config/sessions-data-schema.json" ]; then
  if command -v ajv &> /dev/null; then
    echo -e "${BLUE}🔍 Validating against schema...${NC}"
    if ajv validate -s "$BASE_DIR/config/sessions-data-schema.json" -d "$OUTPUT_FILE" 2>/dev/null; then
      echo "   ✅ Schema validation passed"
    else
      echo "   ⚠️  Schema validation warnings (non-critical)"
    fi
    echo ""
  else
    echo "💡 Tip: Install ajv-cli to validate against schema:"
    echo "   npm install -g ajv-cli"
    echo "   ajv validate -s config/sessions-data-schema.json -d context/.sessions-data.json"
    echo ""
  fi
fi

exit ${EXIT_SUCCESS:-0}
