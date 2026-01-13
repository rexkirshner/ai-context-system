#!/bin/bash
# test-phase6-migration.sh - Validation tests for Phase 6 migration & update
#
# Tests: rollback.sh, MIGRATION_SUMMARY.md, backup creation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPTS_DIR="$REPO_ROOT/scripts"
TEMPLATES_DIR="$REPO_ROOT/templates"

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
echo "║       Phase 6 Migration Validation         ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Test 1: Rollback script exists and is executable
echo "━━━ Test: Rollback Script ━━━"
echo ""

if [ -f "$SCRIPTS_DIR/rollback.sh" ]; then
    pass "rollback.sh exists"
else
    fail "rollback.sh not found"
fi

if [ -x "$SCRIPTS_DIR/rollback.sh" ]; then
    pass "rollback.sh is executable"
else
    fail "rollback.sh is not executable"
fi

# Check for shebang
if head -1 "$SCRIPTS_DIR/rollback.sh" | grep -q "#!/bin/bash"; then
    pass "rollback.sh has bash shebang"
else
    fail "rollback.sh missing bash shebang"
fi

# Check for set -e
if grep -q "set -e" "$SCRIPTS_DIR/rollback.sh"; then
    pass "rollback.sh uses set -e for error handling"
else
    fail "rollback.sh missing set -e"
fi

# Check for backup directory handling
if grep -q "backup\|BACKUP" "$SCRIPTS_DIR/rollback.sh"; then
    pass "rollback.sh handles backup directories"
else
    fail "rollback.sh missing backup handling"
fi

# Check for user content preservation
if grep -q "CONTEXT.md\|STATUS.md\|DECISIONS.md\|SESSIONS.md" "$SCRIPTS_DIR/rollback.sh"; then
    pass "rollback.sh mentions user content files"
else
    fail "rollback.sh should verify user content preservation"
fi

# Check for confirmation prompt
if grep -q "read\|confirm\|Continue" "$SCRIPTS_DIR/rollback.sh"; then
    pass "rollback.sh has confirmation prompt"
else
    fail "rollback.sh should confirm before destructive action"
fi

echo ""

# Test 2: Migration summary template
echo "━━━ Test: Migration Summary Template ━━━"
echo ""

if [ -f "$TEMPLATES_DIR/MIGRATION_SUMMARY.md" ]; then
    pass "MIGRATION_SUMMARY.md template exists"

    # Check for backup location placeholder
    if grep -q "BACKUP_DIR\|backup" "$TEMPLATES_DIR/MIGRATION_SUMMARY.md"; then
        pass "Template includes backup location"
    else
        fail "Template missing backup location"
    fi

    # Check for rollback command
    if grep -q "rollback" "$TEMPLATES_DIR/MIGRATION_SUMMARY.md"; then
        pass "Template includes rollback command"
    else
        fail "Template missing rollback command"
    fi

    # Check for version placeholders
    if grep -q "FROM_VERSION\|TO_VERSION" "$TEMPLATES_DIR/MIGRATION_SUMMARY.md"; then
        pass "Template has version placeholders"
    else
        fail "Template missing version placeholders"
    fi

    # Check for what changed section
    if grep -q "What Changed\|Changed\|New Structure" "$TEMPLATES_DIR/MIGRATION_SUMMARY.md"; then
        pass "Template documents changes"
    else
        fail "Template missing change documentation"
    fi

    # Check for preserved content section
    if grep -q "Preserved\|Unchanged" "$TEMPLATES_DIR/MIGRATION_SUMMARY.md"; then
        pass "Template documents preserved content"
    else
        fail "Template should document preserved content"
    fi

    # Check for verification section
    if grep -q "Verification\|verify" "$TEMPLATES_DIR/MIGRATION_SUMMARY.md"; then
        pass "Template includes verification steps"
    else
        fail "Template missing verification steps"
    fi
else
    fail "MIGRATION_SUMMARY.md template not found"
fi

echo ""

# Test 3: Rollback script structure
echo "━━━ Test: Rollback Script Structure ━━━"
echo ""

# Check for step-by-step structure
if grep -q "Step 1\|Step 2" "$SCRIPTS_DIR/rollback.sh"; then
    pass "rollback.sh has step-by-step structure"
else
    fail "rollback.sh should have clear steps"
fi

# Check for v5 structure removal
if grep -q "skills\|agents\|hooks\|schemas" "$SCRIPTS_DIR/rollback.sh"; then
    pass "rollback.sh removes v5 structure"
else
    fail "rollback.sh should remove v5 directories"
fi

# Check for restore from backup
if grep -q "Restore\|restore\|cp.*BACKUP" "$SCRIPTS_DIR/rollback.sh"; then
    pass "rollback.sh restores from backup"
else
    fail "rollback.sh should restore from backup"
fi

# Check for summary output
if grep -q "Rollback Complete\|Summary" "$SCRIPTS_DIR/rollback.sh"; then
    pass "rollback.sh provides completion summary"
else
    fail "rollback.sh should provide summary"
fi

echo ""

# Test 4: /update skill references migration
echo "━━━ Test: Update Skill Integration ━━━"
echo ""

UPDATE_SKILL="$REPO_ROOT/.claude/skills/update/SKILL.md"
if [ -f "$UPDATE_SKILL" ]; then
    # Check for backup creation
    if grep -q "backup\|\.claude-backup" "$UPDATE_SKILL"; then
        pass "Update skill creates backups"
    else
        fail "Update skill should create backups"
    fi

    # Check for MIGRATION_SUMMARY reference
    if grep -q "MIGRATION_SUMMARY\|migration.*summary" "$UPDATE_SKILL"; then
        pass "Update skill creates migration summary"
    else
        fail "Update skill should create migration summary"
    fi

    # Check for checksum verification
    if grep -q "checksum\|SHA-256\|sha256" "$UPDATE_SKILL"; then
        pass "Update skill has checksum verification"
    else
        fail "Update skill should verify checksums"
    fi

    # Check for rollback reference
    if grep -q "rollback" "$UPDATE_SKILL"; then
        pass "Update skill references rollback"
    else
        fail "Update skill should reference rollback"
    fi
else
    fail "Update skill not found"
fi

echo ""

# Test 5: Backup naming convention
echo "━━━ Test: Backup Conventions ━━━"
echo ""

# Check rollback.sh uses correct backup pattern
if grep -q "\.claude-backup-" "$SCRIPTS_DIR/rollback.sh"; then
    pass "Uses .claude-backup-* naming convention"
else
    fail "Should use .claude-backup-* naming"
fi

# Check for timestamp in backup name pattern
if grep -q "backup.*[0-9]\|[0-9].*backup" "$SCRIPTS_DIR/rollback.sh"; then
    pass "Backup includes timestamp pattern"
else
    fail "Backup should include timestamp"
fi

echo ""

# Summary
echo "━━━ Summary ━━━"
echo -e "  ${GREEN}Passed:${NC}   $PASSED"
echo -e "  ${RED}Failed:${NC}   $FAILED"
echo ""

if [ "$FAILED" -gt 0 ]; then
    echo -e "${RED}Phase 6 tests FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}Phase 6 tests PASSED${NC}"
    exit 0
fi
