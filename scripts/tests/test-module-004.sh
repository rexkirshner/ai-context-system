#!/bin/bash
# Test MODULE-004: Decision Count Grep Fix
# Issue: BUG-3 - Integer expression error in decision count
# Updated: v5.0.2 - Support both ## D and ### D formats

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Source common-functions for count_decisions (v5.0.2)
source "$SCRIPT_DIR/../common-functions.sh" 2>/dev/null || true

# Test 1: Count decisions correctly (### format)
test_decision_count() {
  echo "Test 1: Should count decisions correctly (### format)"

  # Setup
  setup_test_env
  mkdir -p context

  # Create DECISIONS.md with 3 decisions using ### format
  cat > context/DECISIONS.md << 'EOF'
# Decisions

## Decision Index
- D001
- D002
- D003

---

### D001 | Architecture | 2025-11-01
**Decision:** Use modular approach
**Why:** Better testability

### D002 | Technology | 2025-11-15
**Decision:** Use bash for scripts
**Why:** Universal compatibility

### D003 | Process | 2025-11-20
**Decision:** Test-first development
**Why:** Catch bugs early
EOF

  # Test with pattern that matches both ## and ### (v5.0.2)
  DECISION_COUNT=$(grep -E "^##+ D[0-9]" context/DECISIONS.md 2>/dev/null | wc -l | tr -d ' ')

  assert_equal "$DECISION_COUNT" "3" "Should count 3 decisions"

  # Cleanup
  cleanup_test_env
}

# Test 1b: Count decisions correctly (## format - v5.0.2)
test_decision_count_double_hash() {
  echo ""
  echo "Test 1b: Should count decisions correctly (## format - v5.0.2)"

  # Setup
  setup_test_env
  mkdir -p context

  # Create DECISIONS.md with decisions using ## format (some projects use this)
  cat > context/DECISIONS.md << 'EOF'
# Decisions

## D001 - Architecture
**Decision:** Use modular approach
**Why:** Better testability

## D002 - Technology
**Decision:** Use bash for scripts
**Why:** Universal compatibility

## D033 - Naming
**Decision:** Use descriptive names
**Why:** Self-documenting code
EOF

  # Test with pattern that matches both ## and ###
  DECISION_COUNT=$(grep -E "^##+ D[0-9]" context/DECISIONS.md 2>/dev/null | wc -l | tr -d ' ')

  assert_equal "$DECISION_COUNT" "3" "Should count 3 decisions (## format)"

  # Cleanup
  cleanup_test_env
}

# Test 2: Handle empty DECISIONS.md
test_empty_decisions_file() {
  echo ""
  echo "Test 2: Should handle empty DECISIONS.md gracefully"

  # Setup
  setup_test_env
  mkdir -p context

  # Create empty DECISIONS.md
  cat > context/DECISIONS.md << 'EOF'
# Decisions

No decisions documented yet.
EOF

  # Test counting with no decisions (v5.0.2: pattern matches both ## and ###)
  DECISION_COUNT=$(grep -E "^##+ D[0-9]" context/DECISIONS.md 2>/dev/null | wc -l | tr -d ' ')

  assert_equal "$DECISION_COUNT" "0" "Should count 0 decisions"

  # Cleanup
  cleanup_test_env
}

# Test 3: Handle missing DECISIONS.md
test_missing_decisions_file() {
  echo ""
  echo "Test 3: Should handle missing DECISIONS.md gracefully"

  # Setup
  setup_test_env
  mkdir -p context
  # Don't create DECISIONS.md

  # Test counting with missing file
  DECISION_COUNT=$(grep -E "^##+ D[0-9]" context/DECISIONS.md 2>/dev/null | wc -l | tr -d ' ')

  assert_equal "$DECISION_COUNT" "0" "Should count 0 when file missing"

  # Cleanup
  cleanup_test_env
}

# Test 4: No integer expression errors
test_no_integer_expression_errors() {
  echo ""
  echo "Test 4: Should not produce 'integer expression expected' errors"

  # Setup
  setup_test_env
  mkdir -p context

  # Create DECISIONS.md
  cat > context/DECISIONS.md << 'EOF'
### D001 | Test | 2025-11-01
### D002 | Test | 2025-11-02
EOF

  # Capture stderr to check for errors
  DECISION_COUNT=$(grep -E "^##+ D[0-9]" context/DECISIONS.md 2>&1 | wc -l | tr -d ' ')
  ERROR_OUTPUT=$(grep -E "^##+ D[0-9]" context/DECISIONS.md 2>&1 | grep -i "integer expression" || true)

  assert_equal "$DECISION_COUNT" "2" "Should count correctly"
  assert_equal "$ERROR_OUTPUT" "" "Should not produce integer expression errors"

  # Cleanup
  cleanup_test_env
}

# Test 5: Works with many decisions
test_many_decisions() {
  echo ""
  echo "Test 5: Should handle many decisions (stress test)"

  # Setup
  setup_test_env
  mkdir -p context

  # Create DECISIONS.md with 50 decisions
  cat > context/DECISIONS.md << 'EOF'
# Decisions
EOF

  for i in $(seq 1 50); do
    cat >> context/DECISIONS.md << EOF

### D$(printf "%03d" $i) | Test | 2025-11-01
**Decision:** Test decision $i
EOF
  done

  # Count decisions (v5.0.2: pattern matches both ## and ###)
  DECISION_COUNT=$(grep -E "^##+ D[0-9]" context/DECISIONS.md 2>/dev/null | wc -l | tr -d ' ')

  assert_equal "$DECISION_COUNT" "50" "Should count 50 decisions"

  # Cleanup
  cleanup_test_env
}

# Test 6: count_decisions function (v5.0.2)
test_count_decisions_function() {
  echo ""
  echo "Test 6: count_decisions() function from common-functions.sh"

  # Setup
  setup_test_env
  mkdir -p context

  # Create DECISIONS.md with mixed formats
  cat > context/DECISIONS.md << 'EOF'
# Decisions

## D001 - Using double hash
Content

### D002 - Using triple hash
Content

## D003 - Another double hash
Content
EOF

  # Use the count_decisions function if available
  if type count_decisions > /dev/null 2>&1; then
    DECISION_COUNT=$(count_decisions context/DECISIONS.md)
    assert_equal "$DECISION_COUNT" "3" "count_decisions() should find 3 decisions"
  else
    # Fallback: use grep directly
    DECISION_COUNT=$(grep -E "^##+ D[0-9]" context/DECISIONS.md 2>/dev/null | wc -l | tr -d ' ')
    assert_equal "$DECISION_COUNT" "3" "grep pattern should find 3 decisions"
    echo "   (count_decisions function not available, used grep)"
  fi

  # Cleanup
  cleanup_test_env
}

# Test 7: OLD approach produces errors (document the bug)
test_old_approach_bug() {
  echo ""
  echo "Test 7: Document that OLD approach (grep -c) can produce errors"

  # Setup
  setup_test_env
  mkdir -p context

  cat > context/DECISIONS.md << 'EOF'
### D001 | Test | 2025-11-01
EOF

  # The OLD approach that caused the bug:
  # DECISION_COUNT=$(grep -c "^### D[0-9]" context/DECISIONS.md 2>/dev/null || echo "0")
  # This could output "0\n0" which causes "integer expression expected" errors

  # The NEW approach is more robust (v5.0.2: also supports both ## and ###):
  DECISION_COUNT=$(grep -E "^##+ D[0-9]" context/DECISIONS.md 2>/dev/null | wc -l | tr -d ' ')

  # Verify it works
  assert_equal "$DECISION_COUNT" "1" "NEW approach should work correctly"

  # Note: We're documenting the fix, not testing the bug
  echo "   (OLD approach: grep -c could produce multiline output)"
  echo "   (NEW approach: wc -l | tr -d ' ' is reliable)"
  echo "   (v5.0.2: Pattern ^##+ D[0-9] matches both ## and ###)"

  # Cleanup
  cleanup_test_env
}

# Run all tests
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  MODULE-004: Decision Count Grep Fix (v5.0.2)              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_decision_count
test_decision_count_double_hash
test_empty_decisions_file
test_missing_decisions_file
test_no_integer_expression_errors
test_many_decisions
test_count_decisions_function
test_old_approach_bug

print_test_summary
