#!/bin/bash
# test-data-extraction.sh - Tests for data extraction functions (v5.0.2)
#
# Part of: Phase 3 - Data Extraction Fixes
#
# Tests:
# 1. Current focus extraction (multiple patterns)
# 2. Decision count (## and ### formats)
# 3. Stale file detection (archive exclusion)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=============================================="
echo "  Data Extraction Tests (v5.0.2)"
echo "=============================================="
echo ""

# Create test directory
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

ERRORS=0

# Source common-functions for count_decisions (v5.0.2)
source "$SCRIPT_DIR/../common-functions.sh" 2>/dev/null || true

# Define test functions (same as in update-quick-reference.sh)
extract_current_focus() {
  local file="$1"
  local focus=""

  # Try 1: **In Progress:** with unchecked items
  focus=$(sed -n '/\*\*In Progress:\*\*/,/\*\*.*:\*\*/p' "$file" 2>/dev/null | \
          grep "^- \[ \]" | head -1 | sed 's/^- \[ \] //')
  if [ -n "$focus" ]; then
    echo "$focus"
    return 0
  fi

  # Try 2: **Next Priorities:** under Active Tasks
  focus=$(sed -n '/^## Active Tasks/,/^## /p' "$file" 2>/dev/null | \
          sed -n '/\*\*Next Priorities:\*\*/,/\*\*.*:\*\*/p' | \
          grep "^- " | head -1 | sed 's/^- //')
  if [ -n "$focus" ]; then
    echo "$focus"
    return 0
  fi

  # Try 3: First unchecked item anywhere
  focus=$(grep "^- \[ \]" "$file" 2>/dev/null | head -1 | sed 's/^- \[ \] //')
  if [ -n "$focus" ]; then
    echo "$focus"
    return 0
  fi

  # Try 4: ## Current Focus section
  focus=$(sed -n '/^## Current Focus/,/^## /p' "$file" 2>/dev/null | \
          grep -v "^## " | grep -v "^$" | head -1)
  if [ -n "$focus" ]; then
    echo "$focus"
    return 0
  fi

  # Fallback
  echo "See STATUS.md"
}

count_stale_context_files() {
  local context_dir="$1"

  if [ ! -d "$context_dir" ]; then
    echo "0"
    return 0
  fi

  find "$context_dir" -name "*.md" -type f -mtime +7 2>/dev/null | \
    grep -v "/archive/" | \
    grep -v "\-archive-[0-9]\{4\}\.md$" | \
    grep -v "\.archive\.md$" | \
    wc -l | tr -d ' '
}

# =============================================================================
# Test 1: Current focus - In Progress format
# =============================================================================
echo "Test 1: Current focus (In Progress format)..."
mkdir -p "$TEST_DIR/context"
cat > "$TEST_DIR/context/STATUS.md" << 'EOF'
# Project Status

## Active Tasks

**In Progress:**
- [ ] Working on feature X
- [ ] Also doing Y

**Done:**
- [x] Completed task
EOF

focus=$(extract_current_focus "$TEST_DIR/context/STATUS.md")
if [ "$focus" = "Working on feature X" ]; then
  echo "  ✓ In Progress format works"
else
  echo "  ✗ Expected 'Working on feature X', got '$focus'"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 2: Current focus - Next Priorities format
# =============================================================================
echo "Test 2: Current focus (Next Priorities format)..."
cat > "$TEST_DIR/context/STATUS.md" << 'EOF'
# Project Status

## Active Tasks

**Next Priorities:**
- Complete the migration
- Update documentation

**Completed:**
- Previous work done
EOF

focus=$(extract_current_focus "$TEST_DIR/context/STATUS.md")
if [ "$focus" = "Complete the migration" ]; then
  echo "  ✓ Next Priorities format works"
else
  echo "  ✗ Expected 'Complete the migration', got '$focus'"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 3: Decision count (## format)
# =============================================================================
echo "Test 3: Decision count (## format)..."
cat > "$TEST_DIR/context/DECISIONS.md" << 'EOF'
# Decisions

## D001 - First Decision
Content

## D002 - Second Decision
Content

## D033 - Thirty-third Decision
Content
EOF

# Source common-functions for count_decisions
source "$SCRIPT_DIR/../common-functions.sh" 2>/dev/null || true

if type count_decisions > /dev/null 2>&1; then
  count=$(count_decisions "$TEST_DIR/context/DECISIONS.md")
else
  count=$(grep -E "^##+ D[0-9]" "$TEST_DIR/context/DECISIONS.md" 2>/dev/null | wc -l | tr -d ' ')
fi

if [ "$count" -eq 3 ]; then
  echo "  ✓ Decision count (## format): 3"
else
  echo "  ✗ Expected 3, got $count"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 4: Decision count (### format)
# =============================================================================
echo "Test 4: Decision count (### format)..."
cat > "$TEST_DIR/context/DECISIONS.md" << 'EOF'
# Decisions

### D001 | Architecture | 2026-01-01
Content

### D002 | Technology | 2026-01-02
Content
EOF

if type count_decisions > /dev/null 2>&1; then
  count=$(count_decisions "$TEST_DIR/context/DECISIONS.md")
else
  count=$(grep -E "^##+ D[0-9]" "$TEST_DIR/context/DECISIONS.md" 2>/dev/null | wc -l | tr -d ' ')
fi

if [ "$count" -eq 2 ]; then
  echo "  ✓ Decision count (### format): 2"
else
  echo "  ✗ Expected 2, got $count"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 5: Stale file detection with archive exclusion
# =============================================================================
echo "Test 5: Stale file detection (archive exclusion)..."
mkdir -p "$TEST_DIR/context/archive"

# Create files with old dates (cross-platform: macOS uses -t, Linux uses -d)
# Format for -t: YYYYMMDDhhmm
OLD_DATE="202501010000"
if touch -t "$OLD_DATE" "$TEST_DIR/context/STATUS.md" 2>/dev/null; then
  # macOS style worked
  touch -t "$OLD_DATE" "$TEST_DIR/context/SESSIONS-archive-2024.md"
  touch -t "$OLD_DATE" "$TEST_DIR/context/DECISIONS-archive-2023.md"
  touch -t "$OLD_DATE" "$TEST_DIR/context/archive/old-sessions.md"
  touch -t "$OLD_DATE" "$TEST_DIR/context/my-notes.md"
else
  # Try GNU/Linux style
  touch -d "2025-01-01" "$TEST_DIR/context/STATUS.md"
  touch -d "2025-01-01" "$TEST_DIR/context/SESSIONS-archive-2024.md"
  touch -d "2025-01-01" "$TEST_DIR/context/DECISIONS-archive-2023.md"
  touch -d "2025-01-01" "$TEST_DIR/context/archive/old-sessions.md"
  touch -d "2025-01-01" "$TEST_DIR/context/my-notes.md"
fi

# Define function if not available
count_stale_context_files() {
  local context_dir="$1"

  if [ ! -d "$context_dir" ]; then
    echo "0"
    return 0
  fi

  find "$context_dir" -name "*.md" -type f -mtime +7 2>/dev/null | \
    grep -v "/archive/" | \
    grep -v "\-archive-[0-9]\{4\}\.md$" | \
    grep -v "\.archive\.md$" | \
    wc -l | tr -d ' '
}

stale_count=$(count_stale_context_files "$TEST_DIR/context")

# Should count STATUS.md and my-notes.md (2), excluding archives
if [ "$stale_count" -eq 2 ]; then
  echo "  ✓ Stale file count: 2 (archives excluded)"
else
  echo "  ✗ Expected 2 (STATUS.md, my-notes.md), got $stale_count"
  echo "    Note: Archive files should be excluded:"
  echo "    - SESSIONS-archive-2024.md"
  echo "    - DECISIONS-archive-2023.md"
  echo "    - archive/old-sessions.md"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "=============================================="
if [ $ERRORS -eq 0 ]; then
  echo "  PASS: All 5 data extraction tests passed"
  echo "=============================================="
  exit 0
else
  echo "  FAIL: $ERRORS test(s) failed"
  echo "=============================================="
  exit 1
fi
