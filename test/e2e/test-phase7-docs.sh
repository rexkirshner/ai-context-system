#!/bin/bash
# test-phase7-docs.sh - Validation tests for Phase 7 documentation
#
# Tests: skill docs, migration guide, CHANGELOG

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DOCS_DIR="$REPO_ROOT/docs"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0

pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo -e "  ${RED}✗${NC} $1"
    FAILED=$((FAILED + 1))
}

echo "╔════════════════════════════════════════════╗"
echo "║       Phase 7 Documentation Validation     ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Test 1: Docs directory structure
echo "━━━ Test: Docs Structure ━━━"
echo ""

if [ -d "$DOCS_DIR" ]; then
    pass "docs/ directory exists"
else
    fail "docs/ directory missing"
fi

if [ -d "$DOCS_DIR/skills" ]; then
    pass "docs/skills/ directory exists"
else
    fail "docs/skills/ directory missing"
fi

if [ -d "$DOCS_DIR/migration" ]; then
    pass "docs/migration/ directory exists"
else
    fail "docs/migration/ directory missing"
fi

echo ""

# Test 2: All skills documented
echo "━━━ Test: Skill Documentation ━━━"
echo ""

SKILLS=("init" "review" "save" "save-full" "validate" "export" "update")

for skill in "${SKILLS[@]}"; do
    if [ -f "$DOCS_DIR/skills/$skill.md" ]; then
        pass "Skill documented: $skill"
    else
        fail "Skill not documented: $skill"
    fi
done

echo ""

# Test 3: Skill docs have required sections
echo "━━━ Test: Skill Doc Quality ━━━"
echo ""

for skill in "${SKILLS[@]}"; do
    doc="$DOCS_DIR/skills/$skill.md"
    if [ -f "$doc" ]; then
        # Check for Usage section
        if grep -q "## Usage" "$doc"; then
            pass "$skill.md has Usage section"
        else
            fail "$skill.md missing Usage section"
        fi

        # Check for Description
        if grep -q "## Description" "$doc"; then
            pass "$skill.md has Description section"
        else
            fail "$skill.md missing Description section"
        fi

        # Check for Example
        if grep -q "## Example\|example" "$doc"; then
            pass "$skill.md has Example"
        else
            fail "$skill.md missing Example"
        fi
    fi
done

echo ""

# Test 4: Migration guide
echo "━━━ Test: Migration Guide ━━━"
echo ""

MIGRATION_GUIDE="$DOCS_DIR/migration/guide.md"

if [ -f "$MIGRATION_GUIDE" ]; then
    pass "Migration guide exists"

    # Check for prerequisites
    if grep -q "Prerequisites\|prerequisite" "$MIGRATION_GUIDE"; then
        pass "Guide has prerequisites"
    else
        fail "Guide missing prerequisites"
    fi

    # Check for migration steps
    if grep -q "Migration Steps\|Steps\|Step 1" "$MIGRATION_GUIDE"; then
        pass "Guide has migration steps"
    else
        fail "Guide missing migration steps"
    fi

    # Check for rollback instructions
    if grep -q "Rollback\|rollback" "$MIGRATION_GUIDE"; then
        pass "Guide has rollback instructions"
    else
        fail "Guide missing rollback instructions"
    fi

    # Check for breaking changes
    if grep -q "Breaking\|breaking\|Changed" "$MIGRATION_GUIDE"; then
        pass "Guide documents breaking changes"
    else
        fail "Guide missing breaking changes"
    fi
else
    fail "Migration guide not found"
fi

echo ""

# Test 5: CHANGELOG has v5.0 entry
echo "━━━ Test: CHANGELOG ━━━"
echo ""

CHANGELOG="$REPO_ROOT/CHANGELOG.md"

if [ -f "$CHANGELOG" ]; then
    pass "CHANGELOG.md exists"

    # Check for v5.0.0 entry
    if grep -q "## \[5.0.0\]" "$CHANGELOG"; then
        pass "CHANGELOG has v5.0.0 entry"
    else
        fail "CHANGELOG missing v5.0.0 entry"
    fi

    # Check for Added section
    if grep -q "### Added" "$CHANGELOG"; then
        pass "CHANGELOG has Added section"
    else
        fail "CHANGELOG missing Added section"
    fi

    # Check for skills mentioned
    if grep -q "Skills" "$CHANGELOG"; then
        pass "CHANGELOG mentions Skills"
    else
        fail "CHANGELOG should mention Skills"
    fi

    # Check for agents mentioned
    if grep -q "agents\|Agents" "$CHANGELOG"; then
        pass "CHANGELOG mentions Agents"
    else
        fail "CHANGELOG should mention Agents"
    fi

    # Check for migration section
    if grep -q "Migration\|migration" "$CHANGELOG"; then
        pass "CHANGELOG has Migration section"
    else
        fail "CHANGELOG missing Migration section"
    fi
else
    fail "CHANGELOG.md not found"
fi

echo ""

# Test 6: Cross-references
echo "━━━ Test: Cross-References ━━━"
echo ""

# Check skill docs reference each other
for skill in "${SKILLS[@]}"; do
    doc="$DOCS_DIR/skills/$skill.md"
    if [ -f "$doc" ]; then
        if grep -q "See Also\|see also\|\.md" "$doc"; then
            pass "$skill.md has cross-references"
        else
            fail "$skill.md missing cross-references"
        fi
    fi
done

echo ""

# Summary
echo "━━━ Summary ━━━"
echo -e "  ${GREEN}Passed:${NC}   $PASSED"
echo -e "  ${RED}Failed:${NC}   $FAILED"
echo ""

if [ "$FAILED" -gt 0 ]; then
    echo -e "${RED}Phase 7 tests FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}Phase 7 tests PASSED${NC}"
    exit 0
fi
