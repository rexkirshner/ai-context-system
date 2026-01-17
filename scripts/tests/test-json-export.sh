#!/bin/bash
# test-json-export.sh - Comprehensive tests for export-sessions-json.sh
#
# Version: 5.1.0
# Part of: Phase 2 - JSON Export Rewrite
#
# Tests:
# 1. Basic session export
# 2. Code blocks ignored
# 3. Template sections excluded
# 4. Partial dates accepted
# 5. Mixed header formats
# 6. Special characters escaped
# 7. Titles with colons preserved (CRITICAL regression test)
# 8. Multi-paragraph TL;DR handling

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXPORT_SCRIPT="$SCRIPT_DIR/../export-sessions-json.sh"

echo "=============================================="
echo "  JSON Export Tests (v5.1.0)"
echo "=============================================="
echo ""

# Create test directory
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

mkdir -p "$TEST_DIR/context"

# Create minimal .context-config.json
cat > "$TEST_DIR/context/.context-config.json" << 'EOF'
{
  "version": "5.1.0",
  "name": "Test Project"
}
EOF

ERRORS=0

# =============================================================================
# Test 1: Basic sessions
# =============================================================================
echo "Test 1: Basic session export..."
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Session History

## Session 3 | 2026-01-03 | Third Session

### TL;DR
Did the third thing.

### Accomplishments
- Thing 3

## Session 2 | 2026-01-02 | Second Session

### TL;DR
Did the second thing.

## Session 1 | 2026-01-01 | First Session

### TL;DR
Did the first thing.
EOF

"$EXPORT_SCRIPT" "$TEST_DIR/context" > /dev/null 2>&1
if [ -f "$TEST_DIR/context/.sessions-data.json" ]; then
  count=$(jq '.sessions | length' "$TEST_DIR/context/.sessions-data.json" 2>/dev/null || echo "0")
  if [ "$count" -eq 3 ]; then
    echo "  ✓ Basic export: 3 sessions"
  else
    echo "  ✗ Expected 3 sessions, got $count"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "  ✗ JSON file not created"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 2: Code blocks ignored
# =============================================================================
echo "Test 2: Code blocks ignored..."
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
## Session 1 | 2026-01-01 | Real Session

### TL;DR
Real content.

```markdown
## Session 999 | 2099-01-01 | Fake Session
### TL;DR
This should be ignored.
```

More real content.
EOF

"$EXPORT_SCRIPT" "$TEST_DIR/context" > /dev/null 2>&1
count=$(jq '.sessions | length' "$TEST_DIR/context/.sessions-data.json" 2>/dev/null || echo "0")
if [ "$count" -eq 1 ]; then
  echo "  ✓ Code blocks ignored: 1 session (not 2)"
else
  echo "  ✗ Expected 1 session, got $count (code block not ignored)"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 3: Template sections excluded
# =============================================================================
echo "Test 3: Template sections excluded..."
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
## Session 2 | 2026-01-02 | Real

### TL;DR
Real.

## Session 1 | 2026-01-01 | Real

### TL;DR
Real.

## Example Session Format

## Session [N] | [YYYY-MM-DD] | Template
This is a template.

## Session Template

More template content.
EOF

"$EXPORT_SCRIPT" "$TEST_DIR/context" > /dev/null 2>&1
count=$(jq '.sessions | length' "$TEST_DIR/context/.sessions-data.json" 2>/dev/null || echo "0")
if [ "$count" -eq 2 ]; then
  echo "  ✓ Template excluded: 2 sessions"
else
  echo "  ✗ Expected 2 sessions, got $count"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 4: Partial dates accepted
# =============================================================================
echo "Test 4: Partial dates..."
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
## Session 1 | 2024-10 | Partial Date Session

### TL;DR
Has partial date.
EOF

"$EXPORT_SCRIPT" "$TEST_DIR/context" > /dev/null 2>&1
date=$(jq -r '.sessions[0].date' "$TEST_DIR/context/.sessions-data.json" 2>/dev/null || echo "")
if [ "$date" = "2024-10" ]; then
  echo "  ✓ Partial date accepted: $date"
else
  echo "  ✗ Partial date not preserved: got '$date'"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 5: Mixed header formats
# =============================================================================
echo "Test 5: Mixed header formats..."
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
## Session 3 | 2026-01-03 | Pipe Format

### TL;DR
Pipe style.

## Session 2 - 2026-01-02

### TL;DR
Dash style.

## Session 1 | 2026-01-01 | Another Pipe

### TL;DR
More pipe.
EOF

"$EXPORT_SCRIPT" "$TEST_DIR/context" > /dev/null 2>&1
count=$(jq '.sessions | length' "$TEST_DIR/context/.sessions-data.json" 2>/dev/null || echo "0")
if [ "$count" -eq 3 ]; then
  echo "  ✓ Mixed formats: 3 sessions"
else
  echo "  ✗ Expected 3 sessions, got $count"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 6: Special characters escaped
# =============================================================================
echo "Test 6: Special characters..."
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
## Session 1 | 2026-01-01 | Test "Quotes" & More

### TL;DR
Content with "quotes" and \ backslash and	tab.
EOF

"$EXPORT_SCRIPT" "$TEST_DIR/context" > /dev/null 2>&1
if jq . "$TEST_DIR/context/.sessions-data.json" > /dev/null 2>&1; then
  echo "  ✓ Special characters escaped: valid JSON"
else
  echo "  ✗ Invalid JSON from special characters"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 7: CRITICAL - Titles with colons preserved
# =============================================================================
echo "Test 7: Titles with colons (CRITICAL)..."
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
## Session 2 | 2026-01-02 | Feature: User Authentication

### TL;DR
Implemented auth.

## Session 1 | 2026-01-01 | Bug Fix: Database Connection: Timeout Issues

### TL;DR
Fixed DB timeout.
EOF

"$EXPORT_SCRIPT" "$TEST_DIR/context" > /dev/null 2>&1
title1=$(jq -r '.sessions[0].title' "$TEST_DIR/context/.sessions-data.json" 2>/dev/null || echo "")
title2=$(jq -r '.sessions[1].title' "$TEST_DIR/context/.sessions-data.json" 2>/dev/null || echo "")

if [ "$title1" = "Feature: User Authentication" ]; then
  echo "  ✓ Title with single colon preserved"
else
  echo "  ✗ Title truncated at colon: expected 'Feature: User Authentication', got '$title1'"
  ERRORS=$((ERRORS + 1))
fi

if [ "$title2" = "Bug Fix: Database Connection: Timeout Issues" ]; then
  echo "  ✓ Title with multiple colons preserved"
else
  echo "  ✗ Title truncated: expected 'Bug Fix: Database Connection: Timeout Issues', got '$title2'"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 8: Multi-paragraph TL;DR handling
# =============================================================================
echo "Test 8: Multi-paragraph TL;DR..."
cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
## Session 1 | 2026-01-01 | Multi-para Test

### TL;DR
First paragraph of the TL;DR.

Second paragraph continues here.

Third paragraph with more details.

### Accomplishments
- Did stuff
EOF

"$EXPORT_SCRIPT" "$TEST_DIR/context" > /dev/null 2>&1
tldr=$(jq -r '.sessions[0].tldr' "$TEST_DIR/context/.sessions-data.json" 2>/dev/null || echo "")

# Check that both first and third paragraphs are included
if echo "$tldr" | grep -q "First paragraph" && echo "$tldr" | grep -q "Third paragraph"; then
  echo "  ✓ Multi-paragraph TL;DR preserved"
else
  echo "  ✗ Multi-paragraph TL;DR truncated"
  echo "    Got: $tldr"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "=============================================="
if [ $ERRORS -eq 0 ]; then
  echo "  PASS: All 8 JSON export tests passed"
  echo "=============================================="
  exit 0
else
  echo "  FAIL: $ERRORS test(s) failed"
  echo "=============================================="
  exit 1
fi
