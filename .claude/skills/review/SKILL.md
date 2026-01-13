# /review Skill

Review context health and provide resume point for session continuity.

## Purpose

Calculate health score for context documentation and provide actionable resume point.

## Output Schema

Output must validate against `ContextHealth` schema:

```json
{
  "score": 85,
  "breakdown": {
    "statusFreshness": 18,
    "sessionsFreshness": 20,
    "decisionsCoverage": 15,
    "contextCompleteness": 12,
    "quickReferenceSync": 15,
    "crossReferences": 5
  },
  "warnings": ["STATUS.md not updated in 3 days"],
  "nextAction": "Update STATUS.md with current work",
  "resumePoint": "Continue implementing auth middleware in src/middleware/auth.ts"
}
```

## Execution Steps

### Step 1: Check Prerequisites

```bash
# Verify context exists
if [ ! -d "context" ]; then
  echo "Error: No context/ directory found"
  echo "Run /init to initialize AI Context System"
  exit 1
fi

# Check for required files
REQUIRED_FILES=("context/CONTEXT.md" "context/STATUS.md" "context/SESSIONS.md" "context/.context-config.json")
for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "Error: Missing $file"
    exit 1
  fi
done
```

### Step 2: Calculate Health Score

Calculate each component per V5_PLANNING.md §4.6:

#### 2.1 Status Freshness (max 20)

```bash
# Get days since STATUS.md was modified
STATUS_MTIME=$(stat -f %m context/STATUS.md 2>/dev/null || stat -c %Y context/STATUS.md)
NOW=$(date +%s)
DAYS_SINCE_STATUS=$(( (NOW - STATUS_MTIME) / 86400 ))

# Score: 20 - min(20, daysSinceStatusUpdate * 2)
STATUS_FRESHNESS=$(( 20 - (DAYS_SINCE_STATUS * 2) ))
[ $STATUS_FRESHNESS -lt 0 ] && STATUS_FRESHNESS=0
```

#### 2.2 Sessions Freshness (max 20)

```bash
# Get date from last session entry
LAST_SESSION_DATE=$(grep -oE '## Session [0-9]+ \| [0-9]{4}-[0-9]{2}-[0-9]{2}' context/SESSIONS.md | tail -1 | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')

if [ -n "$LAST_SESSION_DATE" ]; then
  LAST_SESSION_TS=$(date -j -f "%Y-%m-%d" "$LAST_SESSION_DATE" +%s 2>/dev/null || date -d "$LAST_SESSION_DATE" +%s)
  DAYS_SINCE_SESSION=$(( (NOW - LAST_SESSION_TS) / 86400 ))
  SESSIONS_FRESHNESS=$(( 20 - (DAYS_SINCE_SESSION * 2) ))
  [ $SESSIONS_FRESHNESS -lt 0 ] && SESSIONS_FRESHNESS=0
else
  SESSIONS_FRESHNESS=0
fi
```

#### 2.3 Decisions Coverage (max 15)

```bash
# Check if recent session references a decision
# 15 if recent session refs decision, 10 if any decisions exist, 0 otherwise
LAST_SESSION=$(sed -n '/<!-- BEGIN SESSION/,/<!-- END SESSION/p' context/SESSIONS.md | tail -100)

if echo "$LAST_SESSION" | grep -qE 'D[0-9]{3}'; then
  DECISIONS_COVERAGE=15
elif grep -qE '^## D[0-9]{3}|^\*\*D[0-9]{3}' context/DECISIONS.md 2>/dev/null; then
  DECISIONS_COVERAGE=10
else
  DECISIONS_COVERAGE=0
fi
```

#### 2.4 Context Completeness (max 15)

```bash
# Count placeholders and missing required fields
PLACEHOLDER_COUNT=$(grep -cE '\[FILL:[^\]]+\]' context/CONTEXT.md 2>/dev/null || echo "0")

# Check required fields
MISSING_REQUIRED=0

# Project name in config
jq -e '.project.name' context/.context-config.json >/dev/null 2>&1 || ((MISSING_REQUIRED++))

# Project type in config
jq -e '.project.type' context/.context-config.json >/dev/null 2>&1 || ((MISSING_REQUIRED++))

# Primary language in CONTEXT.md
grep -q "Primary Language\|Language:" context/CONTEXT.md 2>/dev/null || ((MISSING_REQUIRED++))

# Score: 15 - (placeholderCount * 3) - (missingRequiredFields * 5), min 0
CONTEXT_COMPLETENESS=$(( 15 - (PLACEHOLDER_COUNT * 3) - (MISSING_REQUIRED * 5) ))
[ $CONTEXT_COMPLETENESS -lt 0 ] && CONTEXT_COMPLETENESS=0
```

#### 2.5 Quick Reference Sync (max 15)

Field-based partial credit (3 points each):

```bash
QR_SYNC=0

# Extract Quick Reference block
QR_BLOCK=$(sed -n '/BEGIN AUTO:QUICK_REFERENCE/,/END AUTO:QUICK_REFERENCE/p' context/STATUS.md)

# Check each field (3 points each)
# 1. Project name matches config
CONFIG_NAME=$(jq -r '.project.name // ""' context/.context-config.json)
if echo "$QR_BLOCK" | grep -q "$CONFIG_NAME"; then
  QR_SYNC=$((QR_SYNC + 3))
fi

# 2. Phase matches STATUS.md "Current Phase"
CURRENT_PHASE=$(grep -oE 'Phase:? [A-Za-z0-9]+' context/STATUS.md | head -1 | cut -d: -f2 | xargs)
if echo "$QR_BLOCK" | grep -q "$CURRENT_PHASE"; then
  QR_SYNC=$((QR_SYNC + 3))
fi

# 3. Focus matches STATUS.md
CURRENT_FOCUS=$(grep -A1 'Current Focus\|## Focus' context/STATUS.md | tail -1 | head -c 50)
if [ -n "$CURRENT_FOCUS" ] && echo "$QR_BLOCK" | grep -qF "${CURRENT_FOCUS:0:20}"; then
  QR_SYNC=$((QR_SYNC + 3))
fi

# 4. Resume point format valid (starts with verb, has location)
RESUME=$(echo "$QR_BLOCK" | grep -oE 'Resume: .+' | cut -d: -f2 | xargs)
if echo "$RESUME" | grep -qE '^(Add|Build|Complete|Configure|Continue|Create|Debug|Delete|Deploy|Document|Enhance|Extend|Extract|Finish|Fix|Implement|Improve|Integrate|Investigate|Migrate|Move|Optimize|Refactor|Remove|Rename|Replace|Research|Resolve|Review|Rewrite|Set up|Simplify|Test|Update|Upgrade|Validate|Verify|Wire up|Write)'; then
  if echo "$RESUME" | grep -qE ' (in|at|for|to) '; then
    QR_SYNC=$((QR_SYNC + 3))
  fi
fi

# 5. Health score present and numeric
if echo "$QR_BLOCK" | grep -qE 'Health: [0-9]+/100'; then
  QR_SYNC=$((QR_SYNC + 3))
fi
```

#### 2.6 Cross References (max 15)

```bash
# Check for broken decision references
CROSS_REFS=15

# Find all D### references in STATUS.md and SESSIONS.md
REFS=$(grep -ohE 'D[0-9]{3}' context/STATUS.md context/SESSIONS.md 2>/dev/null | sort -u)

for ref in $REFS; do
  if ! grep -q "^## $ref\|^\*\*$ref" context/DECISIONS.md 2>/dev/null; then
    CROSS_REFS=$((CROSS_REFS - 5))
  fi
done

[ $CROSS_REFS -lt 0 ] && CROSS_REFS=0
```

### Step 3: Calculate Total Score

```bash
TOTAL_SCORE=$((STATUS_FRESHNESS + SESSIONS_FRESHNESS + DECISIONS_COVERAGE + CONTEXT_COMPLETENESS + QR_SYNC + CROSS_REFS))
```

### Step 4: Generate Warnings

Collect warnings based on scores:

```bash
WARNINGS=()

if [ $STATUS_FRESHNESS -lt 10 ]; then
  WARNINGS+=("STATUS.md not updated in $DAYS_SINCE_STATUS days")
fi

if [ $SESSIONS_FRESHNESS -lt 10 ]; then
  WARNINGS+=("No recent session entries in SESSIONS.md")
fi

if [ $DECISIONS_COVERAGE -eq 0 ]; then
  WARNINGS+=("No decisions documented in DECISIONS.md")
fi

if [ $PLACEHOLDER_COUNT -gt 0 ]; then
  WARNINGS+=("$PLACEHOLDER_COUNT unfilled placeholders in CONTEXT.md")
fi

if [ $QR_SYNC -lt 9 ]; then
  WARNINGS+=("Quick Reference out of sync with context files")
fi
```

### Step 5: Determine Next Action

Based on lowest-scoring component:

```bash
# Find lowest score and recommend action
MIN_SCORE=$STATUS_FRESHNESS
NEXT_ACTION="Update STATUS.md with current work"

if [ $SESSIONS_FRESHNESS -lt $MIN_SCORE ]; then
  MIN_SCORE=$SESSIONS_FRESHNESS
  NEXT_ACTION="Run /save-full to document recent work"
fi

if [ $DECISIONS_COVERAGE -lt $MIN_SCORE ]; then
  MIN_SCORE=$DECISIONS_COVERAGE
  NEXT_ACTION="Document a recent decision in DECISIONS.md"
fi

if [ $CONTEXT_COMPLETENESS -lt $MIN_SCORE ]; then
  MIN_SCORE=$CONTEXT_COMPLETENESS
  NEXT_ACTION="Fill in missing fields in CONTEXT.md"
fi
```

### Step 6: Extract Resume Point

Get resume point from most recent source:

```bash
# Priority: STATUS.md "Next Steps" > SESSIONS.md "Next Steps" > generated
RESUME_POINT=""

# Try STATUS.md first
RESUME_POINT=$(grep -A1 '## Next Steps\|### Next' context/STATUS.md 2>/dev/null | grep -E '^\s*-' | head -1 | sed 's/^[- ]*//')

# If empty, try last session
if [ -z "$RESUME_POINT" ]; then
  RESUME_POINT=$(sed -n '/<!-- BEGIN SESSION/,/<!-- END SESSION/p' context/SESSIONS.md | grep -A3 '### Next Steps' | grep -E '^\s*-' | head -1 | sed 's/^[- ]*//')
fi

# Validate format (must start with verb and have location)
VALID_VERBS="Add|Build|Complete|Configure|Continue|Create|Debug|Delete|Deploy|Document|Enhance|Extend|Extract|Finish|Fix|Implement|Improve|Integrate|Investigate|Migrate|Move|Optimize|Refactor|Remove|Rename|Replace|Research|Resolve|Review|Rewrite|Set up|Simplify|Test|Update|Upgrade|Validate|Verify|Wire up|Write"

if ! echo "$RESUME_POINT" | grep -qE "^($VALID_VERBS)"; then
  RESUME_POINT="Continue work on current tasks in context/STATUS.md"
fi

if ! echo "$RESUME_POINT" | grep -qE ' (in|at|for|to) '; then
  RESUME_POINT="$RESUME_POINT in context/STATUS.md"
fi
```

### Step 7: Output Result

Output as structured display (JSON-compatible for validation):

```
╔════════════════════════════════════════════╗
║         Context Health Report              ║
╚════════════════════════════════════════════╝

Score: [TOTAL]/100 [🟢|🟡|🔴]

Breakdown:
  Status Freshness:    [X]/20
  Sessions Freshness:  [X]/20
  Decisions Coverage:  [X]/15
  Context Completeness: [X]/15
  Quick Reference Sync: [X]/15
  Cross References:    [X]/15

[Warnings if any]

Next Action: [action]

Resume Point: [resume point]
```

Also output JSON for programmatic use:

```json
{
  "score": [total],
  "breakdown": {
    "statusFreshness": [x],
    "sessionsFreshness": [x],
    "decisionsCoverage": [x],
    "contextCompleteness": [x],
    "quickReferenceSync": [x],
    "crossReferences": [x]
  },
  "warnings": [...],
  "nextAction": "[action]",
  "resumePoint": "[resume point]"
}
```

## Score Thresholds

| Score | Status | Indicator |
|-------|--------|-----------|
| 80-100 | Healthy | 🟢 |
| 50-79 | Needs attention | 🟡 |
| 0-49 | Critical | 🔴 |

## Resume Point Format

Resume points MUST:
1. Start with an allowed verb: Add, Build, Complete, Configure, Continue, Create, Debug, Delete, Deploy, Document, Enhance, Extend, Extract, Finish, Fix, Implement, Improve, Integrate, Investigate, Migrate, Move, Optimize, Refactor, Remove, Rename, Replace, Research, Resolve, Review, Rewrite, Set up, Simplify, Test, Update, Upgrade, Validate, Verify, Wire up, Write
2. Include a location preposition (in, at, for, to) followed by file/directory

**Valid examples:**
- `Continue implementing auth middleware in src/middleware/auth.ts`
- `Fix CI pipeline failures in .github/workflows/test.yml`
- `Add OAuth support to src/auth/providers.ts`

## Verification Criteria

| Check | Requirement |
|-------|-------------|
| Schema valid | Output matches ContextHealth schema |
| Score range | 0-100 inclusive |
| Resume format | Starts with verb, contains location |

## Notes

- This skill replaces v4.x `/review-context` and `/session-summary` commands
- Output is both human-readable and machine-parseable
- Can be run at any time to check documentation health
- Resume point helps new sessions start quickly
