#!/bin/bash
# session-start.sh - AI Context System session start hook
# Part of AI Context System v5.0
#
# Runs at the start of each Claude Code session.
# Prints context health summary to help orient the AI.
#
# SAFETY:
# - Exit code 1 = warning, no blocking
# - Timeout: 2 seconds
# - Idempotent: Safe to run multiple times
# - No writes to canonical content

set -e

# Detect context directory
CONTEXT_DIR=""
if [ -d "context" ]; then
    CONTEXT_DIR="context"
elif [ -d ".context" ]; then
    CONTEXT_DIR=".context"
fi

# Exit silently if no context system
if [ -z "$CONTEXT_DIR" ]; then
    exit 0
fi

# Check profile - exit if minimal
SETTINGS_FILE=".claude/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
    PROFILE=$(jq -r '.profile // "standard"' "$SETTINGS_FILE" 2>/dev/null || echo "standard")
    if [ "$PROFILE" = "minimal" ]; then
        exit 0
    fi
fi

# Check if STATUS.md exists
STATUS_FILE="$CONTEXT_DIR/STATUS.md"
if [ ! -f "$STATUS_FILE" ]; then
    echo "ACS: No STATUS.md found. Run /init to set up context."
    exit 0
fi

# Calculate basic health indicators
WARNINGS=()

# Check 1: STATUS.md freshness (last modified)
STATUS_AGE_DAYS=0
if command -v stat &> /dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        STATUS_MTIME=$(stat -f %m "$STATUS_FILE" 2>/dev/null || echo 0)
    else
        STATUS_MTIME=$(stat -c %Y "$STATUS_FILE" 2>/dev/null || echo 0)
    fi
    NOW=$(date +%s)
    STATUS_AGE_DAYS=$(( (NOW - STATUS_MTIME) / 86400 ))
fi

if [ "$STATUS_AGE_DAYS" -gt 7 ]; then
    WARNINGS+=("STATUS.md is $STATUS_AGE_DAYS days old")
fi

# Check 2: Quick Reference presence
if ! grep -q "BEGIN AUTO:QUICK_REFERENCE" "$STATUS_FILE" 2>/dev/null; then
    WARNINGS+=("Quick Reference block missing")
fi

# Check 3: Current Focus present
if ! grep -q "Current Focus" "$STATUS_FILE" 2>/dev/null && ! grep -q "current focus" "$STATUS_FILE" 2>/dev/null; then
    WARNINGS+=("No Current Focus section")
fi

# Check 4: SESSIONS.md exists
SESSIONS_FILE="$CONTEXT_DIR/SESSIONS.md"
if [ ! -f "$SESSIONS_FILE" ]; then
    WARNINGS+=("SESSIONS.md missing")
fi

# Check 5: Unclosed session markers
if [ -f "$SESSIONS_FILE" ]; then
    BEGINS=$(grep -c "BEGIN SESSION" "$SESSIONS_FILE" 2>/dev/null || true)
    BEGINS="${BEGINS:-0}"
    ENDS=$(grep -c "END SESSION" "$SESSIONS_FILE" 2>/dev/null || true)
    ENDS="${ENDS:-0}"
    if [ "$BEGINS" -gt "$ENDS" ]; then
        WARNINGS+=("Unclosed session marker in SESSIONS.md")
    fi
fi

# Output summary
echo ""
echo "ACS: Context health check"
echo "------------------------"

if [ ${#WARNINGS[@]} -eq 0 ]; then
    echo "Status: Healthy"

    # Extract current focus if available
    FOCUS=$(grep -A1 -i "current focus" "$STATUS_FILE" 2>/dev/null | tail -1 | sed 's/^[[:space:]]*//' | head -c 60)
    if [ -n "$FOCUS" ] && [ "$FOCUS" != "---" ]; then
        echo "Focus: $FOCUS"
    fi
else
    echo "Status: Needs attention (${#WARNINGS[@]} issue(s))"
    for warning in "${WARNINGS[@]}"; do
        echo "  - $warning"
    done
    echo ""
    echo "Run /review for detailed health report"
fi

echo ""
exit 0
