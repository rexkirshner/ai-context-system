# Audit Compare Agent

Compares current audit results with previous reports to show trends.

## Purpose

Track code health over time by comparing audits. Shows:
- Grade changes (improved/regressed)
- New findings since last audit
- Resolved findings
- Trend direction

## Input

- Current `AuditReport` (from code-reviewer)
- Previous `AuditReport` (from `docs/audits/archive/` or latest)
- Optional: Specific previous report path

## Output

Comparison summary:

```json
{
  "comparison": {
    "currentDate": "2026-01-13",
    "previousDate": "2026-01-10",
    "gradeChange": {
      "from": "C+",
      "to": "B+",
      "direction": "improved"
    },
    "findingsChange": {
      "resolved": 3,
      "new": 1,
      "unchanged": 4
    },
    "severityTrend": {
      "critical": { "from": 1, "to": 0, "direction": "improved" },
      "high": { "from": 3, "to": 1, "direction": "improved" },
      "medium": { "from": 4, "to": 3, "direction": "improved" },
      "low": { "from": 2, "to": 4, "direction": "regressed" }
    }
  },
  "newFindings": [
    { "id": "PERF-002", "title": "New performance issue", "severity": "low" }
  ],
  "resolvedFindings": [
    { "id": "SEC-001", "title": "Hardcoded API key", "severity": "critical" },
    { "id": "SEC-002", "title": "SQL injection risk", "severity": "high" },
    { "id": "SEC-003", "title": "Missing auth check", "severity": "high" }
  ]
}
```

## Execution Steps

### Step 1: Find Previous Report

```bash
AUDIT_DIR="docs/audits"
ARCHIVE_DIR="$AUDIT_DIR/archive"

# Get latest archived report
PREVIOUS_REPORT=$(ls -t "$ARCHIVE_DIR"/*.json 2>/dev/null | head -1)

if [ -z "$PREVIOUS_REPORT" ]; then
  echo "No previous audit found for comparison"
  exit 0
fi

echo "Comparing with: $PREVIOUS_REPORT"
```

### Step 2: Load Both Reports

```javascript
const current = JSON.parse(fs.readFileSync(currentPath));
const previous = JSON.parse(fs.readFileSync(previousPath));
```

### Step 3: Compare Grades

```javascript
const gradeOrder = ['F', 'D', 'C', 'C+', 'B-', 'B', 'B+', 'A-', 'A', 'A+'];

function compareGrades(from, to) {
  const fromIndex = gradeOrder.indexOf(from);
  const toIndex = gradeOrder.indexOf(to);

  if (toIndex > fromIndex) return 'improved';
  if (toIndex < fromIndex) return 'regressed';
  return 'unchanged';
}

const gradeChange = {
  from: previous.summary.grade,
  to: current.summary.grade,
  direction: compareGrades(previous.summary.grade, current.summary.grade)
};
```

### Step 4: Compare Findings

```javascript
// Create finding fingerprints (file:line:category)
function getFingerprint(finding) {
  return `${finding.location.file}:${finding.location.line}:${finding.category}`;
}

const previousFingerprints = new Set(
  previous.findings.map(getFingerprint)
);
const currentFingerprints = new Set(
  current.findings.map(getFingerprint)
);

// Find new findings (in current but not previous)
const newFindings = current.findings.filter(
  f => !previousFingerprints.has(getFingerprint(f))
);

// Find resolved findings (in previous but not current)
const resolvedFindings = previous.findings.filter(
  f => !currentFingerprints.has(getFingerprint(f))
);

// Find unchanged findings
const unchangedCount = current.findings.filter(
  f => previousFingerprints.has(getFingerprint(f))
).length;
```

### Step 5: Calculate Severity Trends

```javascript
const severityLevels = ['critical', 'high', 'medium', 'low'];

const severityTrend = {};

for (const severity of severityLevels) {
  const fromCount = previous.summary[`${severity}Count`] || 0;
  const toCount = current.summary[`${severity}Count`] || 0;

  let direction;
  if (toCount < fromCount) direction = 'improved';
  else if (toCount > fromCount) direction = 'regressed';
  else direction = 'unchanged';

  severityTrend[severity] = {
    from: fromCount,
    to: toCount,
    direction
  };
}
```

### Step 6: Generate Summary Output

```markdown
# Audit Comparison

**Current:** 2026-01-13 | **Previous:** 2026-01-10

## Grade Change

| Previous | Current | Trend |
|----------|---------|-------|
| C+ | B+ | ⬆️ Improved |

## Severity Trends

| Severity | Previous | Current | Change |
|----------|----------|---------|--------|
| Critical | 1 | 0 | ⬇️ -1 |
| High | 3 | 1 | ⬇️ -2 |
| Medium | 4 | 3 | ⬇️ -1 |
| Low | 2 | 4 | ⬆️ +2 |

## Resolved Issues (3)

- [x] ~~SEC-001: Hardcoded API key~~ (critical)
- [x] ~~SEC-002: SQL injection risk~~ (high)
- [x] ~~SEC-003: Missing auth check~~ (high)

## New Issues (1)

- [ ] PERF-002: New performance issue (low)
```

### Step 7: Display Comparison

```
╔════════════════════════════════════════════╗
║           Audit Comparison                  ║
╚════════════════════════════════════════════╝

Grade: C+ → B+ (⬆️ Improved)

Changes:
  ✓ Resolved: 3 findings
  ⚠ New:      1 finding
  − Unchanged: 4 findings

Severity Trend:
  Critical:  1 → 0 (⬇️ -1)
  High:      3 → 1 (⬇️ -2)
  Medium:    4 → 3 (⬇️ -1)
  Low:       2 → 4 (⬆️ +2)

Top Resolution:
  SEC-001: Hardcoded API key (critical) - FIXED ✓
```

## Trend Indicators

| Symbol | Meaning |
|--------|---------|
| ⬆️ | Improved (fewer issues, better grade) |
| ⬇️ | Regressed (more issues, worse grade) |
| ➡️ | Unchanged |
| ✓ | Issue resolved |
| ⚠ | New issue |

## Historical Tracking

If multiple previous reports exist:

```bash
# Get last 5 audits
HISTORY=$(ls -t "$ARCHIVE_DIR"/*.json | head -5)

# Build trend data
for report in $HISTORY; do
  GRADE=$(jq -r '.summary.grade' "$report")
  DATE=$(jq -r '.metadata.timestamp' "$report" | cut -d'T' -f1)
  echo "$DATE: $GRADE"
done
```

Output:
```
Grade History:
  2026-01-13: B+
  2026-01-10: C+
  2026-01-05: C
  2026-01-01: D
  2025-12-28: D

Trend: ⬆️ Improving (4 consecutive improvements)
```

## Verification Criteria

| Check | Requirement |
|-------|-------------|
| Previous report found | Valid JSON in archive |
| Fingerprint matching | Same file:line:category |
| Grade comparison | Valid grade values |
| Count accuracy | Matches actual finding counts |

## Notes

- Run after code-reviewer completes
- Archives previous report before comparing
- Shows actionable summary of progress
- Useful for tracking technical debt reduction
- Integration with CI/CD for trend reporting
