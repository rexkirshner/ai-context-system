#!/bin/bash
# test-schema-validation.sh - Validate all JSON schemas are well-formed
# Tests that schemas are valid JSON and have required meta-fields

set -e

echo "=== Schema Validation Tests ==="
echo ""

PASS=0
FAIL=0

check() {
  if eval "$1" > /dev/null 2>&1; then
    echo "✓ $2"
    PASS=$((PASS + 1))
  else
    echo "✗ $2"
    FAIL=$((FAIL + 1))
  fi
}

SCHEMA_DIR=".claude/schemas"

echo "--- Schema Files Exist ---"
SCHEMAS=(
  "agent-contract.json"
  "audit-finding.json"
  "audit-report.json"
  "context-health.json"
  "handoff-package.json"
  "session-entry.json"
  "settings.json"
)

for schema in "${SCHEMAS[@]}"; do
  check "test -f '$SCHEMA_DIR/$schema'" "$schema exists"
done

echo ""
echo "--- Valid JSON Syntax ---"
for schema in "${SCHEMAS[@]}"; do
  check "jq empty '$SCHEMA_DIR/$schema'" "$schema is valid JSON"
done

echo ""
echo "--- Required Meta-Fields ---"
for schema in "${SCHEMAS[@]}"; do
  # Check for $id (schema identifier)
  check "jq -e '.[\"\$id\"]' '$SCHEMA_DIR/$schema'" "$schema has \$id"

  # Check for $schema (JSON Schema version)
  check "jq -e '.[\"\$schema\"]' '$SCHEMA_DIR/$schema'" "$schema has \$schema"

  # Check for title
  check "jq -e '.title' '$SCHEMA_DIR/$schema'" "$schema has title"
done

echo ""
echo "--- Schema-Specific Validation ---"

# Agent Contract schema
check "jq -e '.properties.id' '$SCHEMA_DIR/agent-contract.json'" "agent-contract has id property"
check "jq -e '.properties.applicability' '$SCHEMA_DIR/agent-contract.json'" "agent-contract has applicability property"
check "jq -e '.required | contains([\"id\", \"prefix\", \"category\"])' '$SCHEMA_DIR/agent-contract.json'" "agent-contract requires id, prefix, category"

# Audit Finding schema
check "jq -e '.properties.severity' '$SCHEMA_DIR/audit-finding.json'" "audit-finding has severity property"
check "jq -e '.properties.location' '$SCHEMA_DIR/audit-finding.json'" "audit-finding has location property"
check "jq -e '.properties.verified' '$SCHEMA_DIR/audit-finding.json'" "audit-finding has verified property"

# Audit Report schema
check "jq -e '.properties.findings' '$SCHEMA_DIR/audit-report.json'" "audit-report has findings property"
check "jq -e '.properties.metadata' '$SCHEMA_DIR/audit-report.json'" "audit-report has metadata property"
check "jq -e '.properties.metadata.properties.agentsSkipped' '$SCHEMA_DIR/audit-report.json'" "audit-report tracks skipped agents"

# Settings schema
check "jq -e '.properties.profile' '$SCHEMA_DIR/settings.json'" "settings has profile property"

echo ""
echo "=== Summary ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "✅ ALL SCHEMA VALIDATION TESTS PASSED"
else
  echo "❌ SOME TESTS FAILED"
fi

exit $FAIL
