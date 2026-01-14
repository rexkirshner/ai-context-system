#!/bin/bash
# test-install-v5.sh - Verify v5.0.0+ installation completeness
#
# Tests that all v5.0.0 components are present after installation.
# Uses portable helpers for consistent cross-platform behavior.
#
# Usage:
#   ./scripts/tests/test-install-v5.sh
#
# Returns:
#   0 if all components present, 1 if any missing

set -e

# Get script directory and source common functions
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../common-functions.sh"

echo "Testing v5.0.0+ installation completeness..."
echo ""

ERRORS=0

# =============================================================================
# Test 1: Agents directory
# =============================================================================
echo "Checking agents..."
EXPECTED_AGENTS=12
ACTUAL_AGENTS=$(count_files ".claude/agents" "*.md")
if [ "$ACTUAL_AGENTS" -eq "$EXPECTED_AGENTS" ]; then
  echo "  ✅ Agents: $ACTUAL_AGENTS/$EXPECTED_AGENTS"
else
  echo "  ❌ Agents: $ACTUAL_AGENTS/$EXPECTED_AGENTS"
  ((ERRORS++))
fi

# Verify key agent files exist
KEY_AGENTS=(
  "code-reviewer.md"
  "security-reviewer.md"
  "performance-reviewer.md"
  "synthesis-agent.md"
)
for agent in "${KEY_AGENTS[@]}"; do
  if [ ! -f ".claude/agents/$agent" ]; then
    echo "     ❌ Missing: $agent"
    ((ERRORS++))
  fi
done

# =============================================================================
# Test 2: Schemas directory
# =============================================================================
echo "Checking schemas..."
EXPECTED_SCHEMAS=7
ACTUAL_SCHEMAS=$(count_files ".claude/schemas" "*.json")
if [ "$ACTUAL_SCHEMAS" -eq "$EXPECTED_SCHEMAS" ]; then
  echo "  ✅ Schemas: $ACTUAL_SCHEMAS/$EXPECTED_SCHEMAS"
else
  echo "  ❌ Schemas: $ACTUAL_SCHEMAS/$EXPECTED_SCHEMAS"
  ((ERRORS++))
fi

# Validate JSON syntax of all schema files
echo "  Validating schema JSON syntax..."
for schema in .claude/schemas/*.json; do
  if [ -f "$schema" ]; then
    if json_validate "$schema"; then
      echo "     ✅ $(basename "$schema") valid"
    else
      echo "     ❌ $(basename "$schema") invalid JSON"
      ((ERRORS++))
    fi
  fi
done

# =============================================================================
# Test 3: Skills directory
# =============================================================================
echo "Checking skills..."
EXPECTED_SKILLS=7
ACTUAL_SKILLS=$(find .claude/skills -name 'SKILL.md' -type f 2>/dev/null | wc -l | tr -d ' ')
if [ "$ACTUAL_SKILLS" -eq "$EXPECTED_SKILLS" ]; then
  echo "  ✅ Skills: $ACTUAL_SKILLS/$EXPECTED_SKILLS"
else
  echo "  ❌ Skills: $ACTUAL_SKILLS/$EXPECTED_SKILLS"
  ((ERRORS++))
fi

# Verify key skill directories exist
KEY_SKILLS=(
  "save"
  "save-full"
  "review"
  "validate"
)
for skill in "${KEY_SKILLS[@]}"; do
  if [ ! -f ".claude/skills/$skill/SKILL.md" ]; then
    echo "     ❌ Missing: $skill/SKILL.md"
    ((ERRORS++))
  fi
done

# =============================================================================
# Test 4: Hooks directory
# =============================================================================
echo "Checking hooks..."
if [ -f ".claude/hooks/session-start.sh" ]; then
  if [ -x ".claude/hooks/session-start.sh" ]; then
    echo "  ✅ session-start.sh exists and is executable"
  else
    echo "  ❌ session-start.sh exists but not executable"
    ((ERRORS++))
  fi
else
  echo "  ❌ session-start.sh missing"
  ((ERRORS++))
fi

# =============================================================================
# Test 5: Core commands
# =============================================================================
echo "Checking core commands..."
CORE_COMMANDS=(
  "init-context.md"
  "save.md"
  "save-full.md"
  "code-review.md"
  "validate-context.md"
)
COMMANDS_OK=0
for cmd in "${CORE_COMMANDS[@]}"; do
  if [ -f ".claude/commands/$cmd" ]; then
    ((COMMANDS_OK++))
  else
    echo "     ❌ Missing: $cmd"
    ((ERRORS++))
  fi
done
echo "  ✅ Core commands: $COMMANDS_OK/${#CORE_COMMANDS[@]}"

# =============================================================================
# Test 6: Core scripts
# =============================================================================
echo "Checking core scripts..."
CORE_SCRIPTS=(
  "common-functions.sh"
  "validate-context.sh"
  "code-review-helpers.sh"
  "update-quick-reference.sh"
)
SCRIPTS_OK=0
for script in "${CORE_SCRIPTS[@]}"; do
  if [ -f "scripts/$script" ] && [ -x "scripts/$script" ]; then
    ((SCRIPTS_OK++))
  else
    echo "     ❌ Missing or not executable: $script"
    ((ERRORS++))
  fi
done
echo "  ✅ Core scripts: $SCRIPTS_OK/${#CORE_SCRIPTS[@]}"

# =============================================================================
# Test 7: VERSION file
# =============================================================================
echo "Checking VERSION file..."
if [ -f "VERSION" ]; then
  VERSION_CONTENT=$(cat VERSION | tr -d ' \n')
  if echo "$VERSION_CONTENT" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "  ✅ VERSION file: $VERSION_CONTENT"
  else
    echo "  ❌ VERSION file has invalid format: $VERSION_CONTENT"
    ((ERRORS++))
  fi
else
  echo "  ❌ VERSION file missing"
  ((ERRORS++))
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ]; then
  echo "PASS: All v5.0.0+ components present"
  exit 0
else
  echo "FAIL: $ERRORS component(s) missing or invalid"
  exit 1
fi
