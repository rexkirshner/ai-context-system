# Audit Compare Agent

Compares current audit with previous reports to show trends.

## Purpose

Track code health over time:
- Grade changes (improved/regressed)
- New findings since last audit
- Resolved findings
- Trend direction

## Input

- Current AuditReport (from code-reviewer)
- Previous AuditReport (from `docs/audits/archive/`)

## Output

```json
{
  "comparison": {
    "currentDate": "2026-01-13",
    "previousDate": "2026-01-10",
    "gradeChange": { "from": "C+", "to": "B+", "direction": "improved" },
    "findingsChange": { "resolved": 3, "new": 1, "unchanged": 4 }
  },
  "severityTrend": {
    "critical": { "from": 1, "to": 0, "direction": "improved" },
    "high": { "from": 3, "to": 1, "direction": "improved" }
  },
  "resolvedFindings": [{ "id": "SEC-001", "title": "Fixed issue" }],
  "newFindings": [{ "id": "PERF-002", "title": "New issue" }]
}
```

## Execution

### 1. Find Previous Report

Look in `docs/audits/archive/` for most recent `.json` file.

If no previous report exists, output "No previous audit for comparison."

### 2. Compare Grades

```
Grade order: F < D < C < C+ < B- < B < B+ < A- < A < A+

B+ > C+ → "improved"
B+ < A- → "regressed"
B+ = B+ → "unchanged"
```

### 3. Compare Findings

Create fingerprint for each finding: `file:line:category`

- **New:** In current but not previous
- **Resolved:** In previous but not current
- **Unchanged:** In both

### 4. Calculate Severity Trends

For each severity level, compare counts:
- fewer → "improved"
- more → "regressed"
- same → "unchanged"

### 5. Display Summary

```
╔════════════════════════════════════════════╗
║           Audit Comparison                  ║
╚════════════════════════════════════════════╝

Grade: C+ → B+ (⬆️ Improved)

Changes:
  ✓ Resolved: 3 findings
  ⚠ New:      1 finding

Severity Trend:
  Critical: 1 → 0 (⬇️)
  High:     3 → 1 (⬇️)

Top Resolution: SEC-001 - Hardcoded API key ✓
```

## Trend Indicators

| Symbol | Meaning |
|--------|---------|
| ⬆️ | Improved (fewer issues, better grade) |
| ⬇️ | Regressed (more issues, worse grade) |
| ➡️ | Unchanged |

## Guardrails

- **DO** use fingerprint (file:line:category) for matching
- **DO** show both resolved and new findings
- **DO NOT** compare if no previous report exists
- **DO NOT** mark as resolved if just moved to different line
