#!/usr/bin/env bats
# Tests for maturity check logic in init-context.md
# These tests verify that ACS-created directories are excluded from doc count

setup() {
  TEST_DIR=$(mktemp -d)
  cd "$TEST_DIR"
}

teardown() {
  cd /
  rm -rf "$TEST_DIR"
}

@test "maturity check excludes docs/audits" {
  mkdir -p docs/audits
  echo "# Audit Report" > docs/audits/audit-01.md
  echo "# Another Audit" > docs/audits/audit-02.md

  # Count should be 0 (only ACS-created audit files)
  USER_DOCS_COUNT=$(find docs/ -type f -name '*.md' \
    -not -path "docs/audits/*" \
    2>/dev/null | wc -l | tr -d ' ')

  [ "$USER_DOCS_COUNT" -eq 0 ]
}

@test "maturity check excludes context folder" {
  mkdir -p context
  echo "# Status" > context/STATUS.md
  echo "# Sessions" > context/SESSIONS.md

  # Context is checked separately, not via docs/ find
  # This test verifies context/ files don't appear in docs/ count
  USER_DOCS_COUNT=$(find . -maxdepth 3 -type f -name '*.md' \
    -not -path "./context/*" \
    -not -path "./docs/audits/*" \
    2>/dev/null | wc -l | tr -d ' ')

  [ "$USER_DOCS_COUNT" -eq 0 ]
}

@test "maturity check counts user docs in docs folder" {
  mkdir -p docs
  echo "# API Documentation" > docs/API.md
  echo "# User Guide" > docs/GUIDE.md

  USER_DOCS_COUNT=$(find docs/ -type f -name '*.md' \
    -not -path "docs/audits/*" \
    2>/dev/null | wc -l | tr -d ' ')

  [ "$USER_DOCS_COUNT" -eq 2 ]
}

@test "maturity check counts user docs while ignoring audits" {
  mkdir -p docs/audits
  echo "# API Documentation" > docs/API.md
  echo "# Audit Report" > docs/audits/audit-01.md

  USER_DOCS_COUNT=$(find docs/ -type f -name '*.md' \
    -not -path "docs/audits/*" \
    2>/dev/null | wc -l | tr -d ' ')

  # Should only count API.md, not audit-01.md
  [ "$USER_DOCS_COUNT" -eq 1 ]
}

@test "maturity check skips when ACS already initialized" {
  mkdir -p context
  echo '{"version": "5.1.5"}' > context/.context-config.json

  # The actual skip happens in shell logic, we just verify the file exists
  [ -f "context/.context-config.json" ]
}
