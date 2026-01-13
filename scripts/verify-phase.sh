#!/bin/bash
# verify-phase.sh - Verify v5.0 implementation phase outputs
# Part of AI Context System v5.0
#
# Usage: ./scripts/verify-phase.sh <phase_number>
# Returns: 0 if all checks pass, 1 if any check fails

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Find repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Print functions
pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo -e "  ${RED}✗${NC} $1"
    FAILED=$((FAILED + 1))
}

warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

section() {
    echo ""
    echo "━━━ $1 ━━━"
}

# Phase verification functions

verify_phase_0() {
    section "Phase 0: Foundation"

    # Check 1: JSON schemas exist and are valid
    echo "Checking JSON schemas..."

    local schemas=(
        "context-health.json"
        "audit-finding.json"
        "audit-report.json"
        "session-entry.json"
        "handoff-package.json"
    )

    local schema_dir="$REPO_ROOT/.claude/schemas"

    if [ ! -d "$schema_dir" ]; then
        fail "Schema directory does not exist: $schema_dir"
    else
        for schema in "${schemas[@]}"; do
            if [ -f "$schema_dir/$schema" ]; then
                # Validate JSON syntax
                if python3 -m json.tool "$schema_dir/$schema" > /dev/null 2>&1; then
                    pass "Schema valid: $schema"
                else
                    fail "Schema invalid JSON: $schema"
                fi
            else
                fail "Schema missing: $schema"
            fi
        done
    fi

    # Check 2: Fixture repos exist
    echo ""
    echo "Checking fixture repositories..."

    local fixtures=("nextjs-app" "python-cli" "monorepo")
    local fixture_dir="$REPO_ROOT/test/fixtures"

    if [ ! -d "$fixture_dir" ]; then
        fail "Fixture directory does not exist: $fixture_dir"
    else
        for fixture in "${fixtures[@]}"; do
            if [ -d "$fixture_dir/$fixture" ]; then
                pass "Fixture exists: $fixture"
            else
                fail "Fixture missing: $fixture"
            fi
        done
    fi

    # Check 3: Golden files exist
    echo ""
    echo "Checking golden files..."

    local golden_files=(
        "quick-reference.md"
        "session-entry.md"
        "audit-report.json"
    )
    local golden_dir="$REPO_ROOT/test/golden"

    if [ ! -d "$golden_dir" ]; then
        fail "Golden directory does not exist: $golden_dir"
    else
        for golden in "${golden_files[@]}"; do
            if [ -f "$golden_dir/$golden" ]; then
                pass "Golden file exists: $golden"
            else
                fail "Golden file missing: $golden"
            fi
        done
    fi

    # Check 4: This script runs (meta-check - always passes if we get here)
    echo ""
    echo "Checking verify-phase.sh..."
    pass "verify-phase.sh executable and running"
}

verify_phase_1() {
    section "Phase 1: MVP Loop"

    # Check skills exist
    echo "Checking MVP skills..."

    local skills=("init" "review" "save-full")
    local skill_dir="$REPO_ROOT/.claude/skills"

    for skill in "${skills[@]}"; do
        if [ -f "$skill_dir/$skill/SKILL.md" ]; then
            pass "Skill exists: $skill"
        else
            fail "Skill missing: $skill"
        fi
    done

    # Run end-to-end tests
    echo ""
    echo "Running MVP loop e2e tests..."

    local e2e_test="$REPO_ROOT/test/e2e/test-mvp-loop.sh"
    if [ -f "$e2e_test" ] && [ -x "$e2e_test" ]; then
        if "$e2e_test" > /dev/null 2>&1; then
            pass "MVP loop e2e tests pass"
        else
            fail "MVP loop e2e tests fail (run test/e2e/test-mvp-loop.sh for details)"
        fi
    else
        warn "E2e test script not found or not executable"
    fi
}

verify_phase_2() {
    section "Phase 2: Additional Skills"

    echo "Checking additional skills..."

    local skills=("save" "validate" "export" "update")
    local skill_dir="$REPO_ROOT/.claude/skills"

    for skill in "${skills[@]}"; do
        if [ -f "$skill_dir/$skill/SKILL.md" ]; then
            pass "Skill exists: $skill"
        else
            fail "Skill missing: $skill"
        fi
    done

    # Run Phase 2 e2e tests
    echo ""
    echo "Running Phase 2 skill tests..."

    local e2e_test="$REPO_ROOT/test/e2e/test-phase2-skills.sh"
    if [ -f "$e2e_test" ] && [ -x "$e2e_test" ]; then
        if "$e2e_test" > /dev/null 2>&1; then
            pass "Phase 2 skill tests pass"
        else
            fail "Phase 2 skill tests fail (run test/e2e/test-phase2-skills.sh for details)"
        fi
    else
        warn "Phase 2 e2e test script not found or not executable"
    fi
}

verify_phase_3() {
    section "Phase 3: Code Review Agents"

    echo "Checking code review agents..."

    local agents=("codebase-scanner" "security-reviewer" "code-reviewer" "synthesis-agent")
    local agent_dir="$REPO_ROOT/.claude/agents"

    for agent in "${agents[@]}"; do
        if [ -f "$agent_dir/$agent.md" ]; then
            pass "Agent exists: $agent"
        else
            fail "Agent missing: $agent"
        fi
    done

    # Run Phase 3 e2e tests
    echo ""
    echo "Running Phase 3 agent tests..."

    local e2e_test="$REPO_ROOT/test/e2e/test-phase3-agents.sh"
    if [ -f "$e2e_test" ] && [ -x "$e2e_test" ]; then
        if "$e2e_test" > /dev/null 2>&1; then
            pass "Phase 3 agent tests pass"
        else
            fail "Phase 3 agent tests fail (run test/e2e/test-phase3-agents.sh for details)"
        fi
    else
        warn "Phase 3 e2e test script not found or not executable"
    fi
}

verify_phase_4() {
    section "Phase 4: Remaining Agents"

    echo "Checking remaining agents..."

    local agents=("performance-reviewer" "accessibility-reviewer" "type-safety-reviewer" "test-coverage-reviewer" "audit-compare")
    local agent_dir="$REPO_ROOT/.claude/agents"

    for agent in "${agents[@]}"; do
        if [ -f "$agent_dir/$agent.md" ]; then
            pass "Agent exists: $agent"
        else
            fail "Agent missing: $agent"
        fi
    done

    # Run Phase 4 e2e tests
    echo ""
    echo "Running Phase 4 agent tests..."

    local e2e_test="$REPO_ROOT/test/e2e/test-phase4-agents.sh"
    if [ -f "$e2e_test" ] && [ -x "$e2e_test" ]; then
        if "$e2e_test" > /dev/null 2>&1; then
            pass "Phase 4 agent tests pass"
        else
            fail "Phase 4 agent tests fail (run test/e2e/test-phase4-agents.sh for details)"
        fi
    else
        warn "Phase 4 e2e test script not found or not executable"
    fi
}

verify_phase_5() {
    section "Phase 5: Hooks"

    echo "Checking hooks..."

    local hook_dir="$REPO_ROOT/.claude/hooks"

    if [ -f "$hook_dir/session-start.sh" ]; then
        pass "Hook exists: session-start.sh"

        # Check executable
        if [ -x "$hook_dir/session-start.sh" ]; then
            pass "Hook is executable"
        else
            fail "Hook not executable"
        fi
    else
        fail "Hook missing: session-start.sh"
    fi

    # Check settings.json
    if [ -f "$REPO_ROOT/.claude/settings.json" ]; then
        pass "Settings file exists: settings.json"
    else
        fail "Settings file missing: settings.json"
    fi

    # Run Phase 5 e2e tests
    echo ""
    echo "Running Phase 5 hook tests..."

    local e2e_test="$REPO_ROOT/test/e2e/test-phase5-hooks.sh"
    if [ -f "$e2e_test" ] && [ -x "$e2e_test" ]; then
        if "$e2e_test" > /dev/null 2>&1; then
            pass "Phase 5 hook tests pass"
        else
            fail "Phase 5 hook tests fail (run test/e2e/test-phase5-hooks.sh for details)"
        fi
    else
        warn "Phase 5 e2e test script not found or not executable"
    fi
}

verify_phase_6() {
    section "Phase 6: Migration & Update"

    # Check rollback script exists
    if [ -f "$REPO_ROOT/scripts/rollback.sh" ]; then
        pass "Rollback script exists"
    else
        fail "Rollback script missing"
    fi

    # TODO: Add migration tests
    warn "Migration tests not yet implemented"
}

verify_phase_7() {
    section "Phase 7: Documentation"

    # Check docs exist
    if [ -d "$REPO_ROOT/docs" ]; then
        pass "Docs directory exists"
    else
        fail "Docs directory missing"
    fi

    # Check CHANGELOG
    if [ -f "$REPO_ROOT/CHANGELOG.md" ]; then
        if grep -q "5.0" "$REPO_ROOT/CHANGELOG.md"; then
            pass "CHANGELOG has v5.0 entry"
        else
            fail "CHANGELOG missing v5.0 entry"
        fi
    else
        fail "CHANGELOG.md missing"
    fi
}

verify_phase_8() {
    section "Phase 8: Release"

    # Run all phase verifications
    for i in {0..7}; do
        echo ""
        echo "Running Phase $i verification..."
        "verify_phase_$i"
    done

    # Check VERSION
    if [ -f "$REPO_ROOT/VERSION" ]; then
        local version=$(cat "$REPO_ROOT/VERSION")
        if [ "$version" = "5.0.0" ]; then
            pass "VERSION is 5.0.0"
        else
            fail "VERSION is $version, expected 5.0.0"
        fi
    else
        fail "VERSION file missing"
    fi
}

# Main execution
main() {
    local phase="$1"

    if [ -z "$phase" ]; then
        echo "Usage: ./scripts/verify-phase.sh <phase_number>"
        echo ""
        echo "Phases:"
        echo "  0 - Foundation (schemas, fixtures, golden files)"
        echo "  1 - MVP Loop (init, review, save-full)"
        echo "  2 - Additional Skills (save, validate, export, update)"
        echo "  3 - Code Review Agents"
        echo "  4 - Remaining Agents"
        echo "  5 - Hooks"
        echo "  6 - Migration & Update"
        echo "  7 - Documentation"
        echo "  8 - Release (all phases)"
        exit 1
    fi

    echo "╔════════════════════════════════════════════╗"
    echo "║    AI Context System v5.0 Verification     ║"
    echo "╚════════════════════════════════════════════╝"
    echo ""
    echo "Repository: $REPO_ROOT"
    echo "Phase: $phase"

    case "$phase" in
        0) verify_phase_0 ;;
        1) verify_phase_1 ;;
        2) verify_phase_2 ;;
        3) verify_phase_3 ;;
        4) verify_phase_4 ;;
        5) verify_phase_5 ;;
        6) verify_phase_6 ;;
        7) verify_phase_7 ;;
        8) verify_phase_8 ;;
        *)
            echo "Error: Invalid phase number: $phase"
            exit 1
            ;;
    esac

    # Summary
    echo ""
    echo "━━━ Summary ━━━"
    echo -e "  ${GREEN}Passed:${NC}   $PASSED"
    echo -e "  ${RED}Failed:${NC}   $FAILED"
    echo -e "  ${YELLOW}Warnings:${NC} $WARNINGS"
    echo ""

    if [ "$FAILED" -gt 0 ]; then
        echo -e "${RED}Phase $phase verification FAILED${NC}"
        exit 1
    else
        echo -e "${GREEN}Phase $phase verification PASSED${NC}"
        exit 0
    fi
}

main "$@"
