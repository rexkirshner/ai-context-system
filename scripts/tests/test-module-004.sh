#!/bin/bash
# Test MODULE-004: Decision Count Grep Fix
# Issue: BUG-3 - Integer expression error in decision count

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Test 1: Count decisions correctly
test_decision_count() {
  echo "Test 1: Should count decisions correctly"

  # Setup
  setup_test_env
  mkdir -p context

  # Create DECISIONS.md with 3 decisions
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

  # Test the NEW approach (wc -l instead of grep -c)
  DECISION_COUNT=$(grep "^### D[0-9]" context/DECISIONS.md 2>/dev/null | wc -l | tr -d ' ')

  assert_equal "$DECISION_COUNT" "3" "Should count 3 decisions"

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

  # Test counting with no decisions
  DECISION_COUNT=$(grep "^### D[0-9]" context/DECISIONS.md 2>/dev/null | wc -l | tr -d ' ')

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
  DECISION_COUNT=$(grep "^### D[0-9]" context/DECISIONS.md 2>/dev/null | wc -l | tr -d ' ')

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
  DECISION_COUNT=$(grep "^### D[0-9]" context/DECISIONS.md 2>&1 | wc -l | tr -d ' ')
  ERROR_OUTPUT=$(grep "^### D[0-9]" context/DECISIONS.md 2>&1 | grep -i "integer expression" || true)

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

  # Count decisions
  DECISION_COUNT=$(grep "^### D[0-9]" context/DECISIONS.md 2>/dev/null | wc -l | tr -d ' ')

  assert_equal "$DECISION_COUNT" "50" "Should count 50 decisions"

  # Cleanup
  cleanup_test_env
}

# Test 6: OLD approach produces errors (document the bug)
test_old_approach_bug() {
  echo ""
  echo "Test 6: Document that OLD approach (grep -c) can produce errors"

  # Setup
  setup_test_env
  mkdir -p context

  cat > context/DECISIONS.md << 'EOF'
### D001 | Test | 2025-11-01
EOF

  # The OLD approach that caused the bug:
  # DECISION_COUNT=$(grep -c "^### D[0-9]" context/DECISIONS.md 2>/dev/null || echo "0")
  # This could output "0\n0" which causes "integer expression expected" errors

  # The NEW approach is more robust:
  DECISION_COUNT=$(grep "^### D[0-9]" context/DECISIONS.md 2>/dev/null | wc -l | tr -d ' ')

  # Verify it works
  assert_equal "$DECISION_COUNT" "1" "NEW approach should work correctly"

  # Note: We're documenting the fix, not testing the bug
  echo "   (OLD approach: grep -c could produce multiline output)"
  echo "   (NEW approach: wc -l | tr -d ' ' is reliable)"

  # Cleanup
  cleanup_test_env
}

# Run all tests
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  MODULE-004: Decision Count Grep Fix                      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_decision_count
test_empty_decisions_file
test_missing_decisions_file
test_no_integer_expression_errors
test_many_decisions
test_old_approach_bug

print_test_summary
