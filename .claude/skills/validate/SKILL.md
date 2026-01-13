# /validate Skill

Validate context documentation structure and completeness.

## Purpose

Check context files for:
- Structural integrity (required sections present)
- Cross-reference validity (decision IDs exist)
- Quick Reference sync (derived matches canonical)
- Format compliance (markers, session numbers, etc.)

## Output

Validation report with pass/fail for each check:

```
╔════════════════════════════════════════════╗
║       Context Validation Report            ║
╚════════════════════════════════════════════╝

Structure Checks:
  ✓ CONTEXT.md exists and has required sections
  ✓ STATUS.md exists with Quick Reference block
  ✓ DECISIONS.md exists
  ✓ SESSIONS.md exists with valid entries
  ✓ .context-config.json is valid JSON

Cross-Reference Checks:
  ✓ All decision references (D###) exist in DECISIONS.md
  ✗ D999 referenced in STATUS.md but not found in DECISIONS.md

Quick Reference Sync:
  ✓ Project name matches config
  ✓ Phase matches STATUS.md
  ⚠ Focus field outdated (last updated 3 days ago)

Format Compliance:
  ✓ All sessions have BEGIN/END markers
  ✓ Session numbers are sequential
  ✓ TL;DR present in all sessions

Summary: 11/12 checks passed, 1 failed, 1 warning
```

## Execution Steps

### Step 1: Check File Existence

```bash
ERRORS=()
WARNINGS=()

# Required files
REQUIRED_FILES=(
  "context/CONTEXT.md"
  "context/STATUS.md"
  "context/DECISIONS.md"
  "context/SESSIONS.md"
  "context/.context-config.json"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "✓ $file exists"
  else
    echo "✗ $file missing"
    ERRORS+=("Missing file: $file")
  fi
done
```

### Step 2: Validate Config JSON

```bash
if [ -f "context/.context-config.json" ]; then
  if jq . context/.context-config.json > /dev/null 2>&1; then
    echo "✓ Config is valid JSON"

    # Check required fields
    if jq -e '.version' context/.context-config.json > /dev/null 2>&1; then
      echo "✓ Config has version"
    else
      ERRORS+=("Config missing 'version' field")
    fi

    if jq -e '.project.name' context/.context-config.json > /dev/null 2>&1; then
      echo "✓ Config has project.name"
    else
      ERRORS+=("Config missing 'project.name' field")
    fi
  else
    ERRORS+=("Config is not valid JSON")
  fi
fi
```

### Step 3: Validate Cross-References

Check that all decision references exist:

```bash
# Find all D### references in STATUS.md and SESSIONS.md
REFS=$(grep -ohE 'D[0-9]{3}' context/STATUS.md context/SESSIONS.md 2>/dev/null | sort -u)

for ref in $REFS; do
  # Check if decision exists in DECISIONS.md
  # Look for "## D###" or "**D###**" patterns
  if grep -qE "^## $ref|^\*\*$ref\*\*|^### $ref" context/DECISIONS.md 2>/dev/null; then
    echo "✓ $ref exists in DECISIONS.md"
  else
    echo "✗ $ref referenced but not found in DECISIONS.md"
    ERRORS+=("Broken reference: $ref not found in DECISIONS.md")
  fi
done

# Check for orphaned decisions (in DECISIONS.md but never referenced)
DECISIONS=$(grep -oE '^## D[0-9]{3}|^\*\*D[0-9]{3}\*\*' context/DECISIONS.md 2>/dev/null | grep -oE 'D[0-9]{3}' | sort -u)

for decision in $DECISIONS; do
  if ! grep -q "$decision" context/STATUS.md context/SESSIONS.md 2>/dev/null; then
    echo "⚠ $decision in DECISIONS.md never referenced elsewhere"
    WARNINGS+=("Orphaned decision: $decision")
  fi
done
```

### Step 4: Validate Quick Reference Sync

```bash
# Extract Quick Reference block
QR_BLOCK=$(sed -n '/BEGIN AUTO:QUICK_REFERENCE/,/END AUTO:QUICK_REFERENCE/p' context/STATUS.md)

if [ -z "$QR_BLOCK" ]; then
  ERRORS+=("Quick Reference block missing from STATUS.md")
else
  echo "✓ Quick Reference block present"

  # Check project name matches config
  CONFIG_NAME=$(jq -r '.project.name // ""' context/.context-config.json)
  if echo "$QR_BLOCK" | grep -q "$CONFIG_NAME"; then
    echo "✓ Project name matches config"
  else
    WARNINGS+=("Quick Reference project name doesn't match config")
  fi

  # Check Resume point format
  RESUME=$(echo "$QR_BLOCK" | grep -oE 'Resume: .+' | cut -d: -f2- | xargs)
  VALID_VERBS="Add|Build|Complete|Configure|Continue|Create|Debug|Delete|Deploy|Document|Enhance|Extend|Extract|Finish|Fix|Implement|Improve|Integrate|Investigate|Migrate|Move|Optimize|Refactor|Remove|Rename|Replace|Research|Resolve|Review|Rewrite|Set up|Simplify|Test|Update|Upgrade|Validate|Verify|Wire up|Write"

  if echo "$RESUME" | grep -qE "^($VALID_VERBS)"; then
    echo "✓ Resume point starts with valid verb"
  else
    WARNINGS+=("Resume point doesn't start with action verb")
  fi

  if echo "$RESUME" | grep -qE ' (in|at|for|to) '; then
    echo "✓ Resume point includes location"
  else
    WARNINGS+=("Resume point missing location reference")
  fi
fi
```

### Step 5: Validate Session Entries

```bash
# Check for BEGIN/END markers
SESSION_BEGINS=$(grep -c 'BEGIN SESSION' context/SESSIONS.md 2>/dev/null || echo "0")
SESSION_ENDS=$(grep -c 'END SESSION' context/SESSIONS.md 2>/dev/null || echo "0")

if [ "$SESSION_BEGINS" -eq "$SESSION_ENDS" ]; then
  echo "✓ All sessions have matching BEGIN/END markers"
else
  ERRORS+=("Mismatched session markers: $SESSION_BEGINS BEGINs, $SESSION_ENDS ENDs")
fi

# Check for incomplete trailing entry
LAST_LINE=$(tail -20 context/SESSIONS.md | grep -E 'BEGIN SESSION|END SESSION' | tail -1)
if echo "$LAST_LINE" | grep -q 'BEGIN SESSION'; then
  ERRORS+=("Incomplete session entry at end of SESSIONS.md (BEGIN without END)")
fi

# Check session number sequence
SESSION_NUMS=$(grep -oE 'Session [0-9]+' context/SESSIONS.md | grep -oE '[0-9]+' | sort -n)
PREV=0
for num in $SESSION_NUMS; do
  EXPECTED=$((PREV + 1))
  if [ "$num" -ne "$EXPECTED" ] && [ "$PREV" -ne 0 ]; then
    WARNINGS+=("Session number gap: expected $EXPECTED, found $num")
  fi
  PREV=$num
done

if [ ${#WARNINGS[@]} -eq 0 ] || ! echo "${WARNINGS[@]}" | grep -q "Session number"; then
  echo "✓ Session numbers are sequential"
fi

# Check TL;DR presence
SESSIONS_WITH_TLDR=$(grep -c '### TL;DR' context/SESSIONS.md 2>/dev/null || echo "0")
if [ "$SESSION_BEGINS" -gt 0 ] && [ "$SESSIONS_WITH_TLDR" -eq "$SESSION_BEGINS" ]; then
  echo "✓ All sessions have TL;DR"
elif [ "$SESSION_BEGINS" -gt 0 ]; then
  WARNINGS+=("Some sessions missing TL;DR section")
fi
```

### Step 6: Check for Placeholders

```bash
# Count unfilled placeholders
PLACEHOLDER_COUNT=$(grep -cE '\[FILL:[^\]]+\]' context/CONTEXT.md 2>/dev/null || echo "0")

if [ "$PLACEHOLDER_COUNT" -eq 0 ]; then
  echo "✓ No unfilled placeholders in CONTEXT.md"
else
  WARNINGS+=("$PLACEHOLDER_COUNT unfilled [FILL:...] placeholders in CONTEXT.md")
fi
```

### Step 7: Output Summary

```bash
TOTAL_CHECKS=$((PASSED + ${#ERRORS[@]} + ${#WARNINGS[@]}))

echo ""
echo "━━━ Summary ━━━"
echo "  Passed:   $PASSED"
echo "  Failed:   ${#ERRORS[@]}"
echo "  Warnings: ${#WARNINGS[@]}"

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo ""
  echo "Errors (must fix):"
  for err in "${ERRORS[@]}"; do
    echo "  ✗ $err"
  done
fi

if [ ${#WARNINGS[@]} -gt 0 ]; then
  echo ""
  echo "Warnings (should fix):"
  for warn in "${WARNINGS[@]}"; do
    echo "  ⚠ $warn"
  done
fi

if [ ${#ERRORS[@]} -eq 0 ]; then
  echo ""
  echo "✓ Context validation PASSED"
  exit 0
else
  echo ""
  echo "✗ Context validation FAILED"
  exit 1
fi
```

## Verification Criteria

| Check | Requirement |
|-------|-------------|
| Broken refs detected | Injecting `D999` reference causes failure |
| Markers validated | Incomplete session (BEGIN without END) detected |
| Config validated | Invalid JSON causes failure |

## Test Case: D999 Detection

To verify this skill works:

```bash
# Inject broken reference
echo "See decision D999 for details" >> context/STATUS.md

# Run validate
/validate  # Should report: "D999 referenced but not found"

# Remove test reference
git checkout context/STATUS.md
```

## Error Handling

- Missing files: Report which files are missing
- Invalid JSON: Show parse error location
- Broken references: List all broken refs
- Always complete full validation (don't stop at first error)

## Notes

- This skill replaces v4.x `/validate-context` command
- Runs non-destructively (read-only)
- Can be run at any time to check documentation health
- Useful before commits or handoffs
