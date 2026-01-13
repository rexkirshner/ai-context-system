# Synthesis Agent

Merges findings from multiple specialist agents into a unified report.

## Purpose

- Deduplicate findings (same file:line = one finding)
- Merge evidence from different specialists
- Calculate overall grade
- Identify positive patterns
- Produce final AuditReport

## Input

Findings from specialist agents:

```json
{
  "security": [AuditFinding, ...],
  "performance": [AuditFinding, ...],
  "accessibility": [AuditFinding, ...],
  "typescript": [AuditFinding, ...],
  "testing": [AuditFinding, ...]
}
```

## Output

Complete `AuditReport`:

```json
{
  "metadata": { ... },
  "summary": {
    "grade": "B+",
    "criticalCount": 0,
    "highCount": 1,
    "mediumCount": 3,
    "lowCount": 5
  },
  "findings": [/* deduplicated, merged */],
  "positives": [/* good patterns found */]
}
```

## Execution Steps

### Step 1: Collect All Findings

```javascript
// Flatten all findings into single array
const allFindings = [
  ...input.security,
  ...input.performance,
  ...input.accessibility,
  ...input.typescript,
  ...input.testing
];
```

### Step 2: Deduplicate Findings

Per V5_PLANNING.md Appendix B.3:

**Duplicates:** Same file AND same line number.

```javascript
function isDuplicate(a, b) {
  return a.location.file === b.location.file &&
         a.location.line === b.location.line;
}

// Group duplicates
const groups = groupBy(allFindings, f => `${f.location.file}:${f.location.line}`);
```

### Step 3: Merge Duplicates

For each group of duplicates, keep one finding with:

**Tie-break rules (keep the one with):**
1. Highest severity
2. Most specific description
3. Most actionable remediation

**Merge:**
- Combine evidence from all findings
- Keep all unique remediation suggestions
- Preserve verification from most authoritative source

```javascript
function mergeDuplicates(findings) {
  // Sort by severity (critical > high > medium > low > info)
  const severityOrder = { critical: 0, high: 1, medium: 2, low: 3, info: 4 };
  findings.sort((a, b) => severityOrder[a.severity] - severityOrder[b.severity]);

  const primary = findings[0];

  // Merge verification notes
  const allNotes = findings
    .map(f => f.verified.verificationNotes)
    .filter(Boolean)
    .join('; ');

  primary.verified.verificationNotes = allNotes;

  // Combine remediations if different
  const remediations = [...new Set(findings.map(f => f.remediation))];
  if (remediations.length > 1) {
    primary.remediation = remediations.join('\n\nAlternatively: ');
  }

  return primary;
}
```

### Step 4: Calculate Grade

Based on severity counts:

```javascript
function calculateGrade(findings) {
  const counts = {
    critical: findings.filter(f => f.severity === 'critical').length,
    high: findings.filter(f => f.severity === 'high').length,
    medium: findings.filter(f => f.severity === 'medium').length,
    low: findings.filter(f => f.severity === 'low').length
  };

  // Grading rubric
  if (counts.critical > 0) return 'F';
  if (counts.high > 3) return 'D';
  if (counts.high > 1) return 'C';
  if (counts.high > 0) return 'C+';
  if (counts.medium > 5) return 'B-';
  if (counts.medium > 2) return 'B';
  if (counts.medium > 0) return 'B+';
  if (counts.low > 5) return 'A-';
  if (counts.low > 0) return 'A';
  return 'A+';
}
```

**Grade scale:**
| Grade | Meaning |
|-------|---------|
| A+ | Excellent, no issues |
| A | Very good, minor issues only |
| A- | Good, few low-severity issues |
| B+ | Above average, some medium issues |
| B | Average, medium issues present |
| B- | Below average, multiple medium issues |
| C+ | Needs work, one high severity |
| C | Significant issues, multiple high |
| D | Poor, many high severity issues |
| F | Critical issues present |

### Step 5: Identify Positives

Look for good patterns in the codebase:

```javascript
const positives = [];

// Check for TypeScript usage
if (codebaseContext.structure.primaryLanguage === 'typescript') {
  positives.push('Consistent use of TypeScript with strict mode');
}

// Check for test presence
if (codebaseContext.structure.hasTests) {
  positives.push('Test suite present');
}

// Check for CI/CD
if (codebaseContext.structure.hasCi) {
  positives.push('CI/CD pipeline configured');
}

// Check for security headers (if web app)
if (hasSecurityHeaders) {
  positives.push('Security headers properly configured');
}

// Check for dependency management
if (hasLockFile) {
  positives.push('Dependency versions locked');
}
```

### Step 6: Build Summary

```javascript
const summary = {
  grade: calculateGrade(mergedFindings),
  criticalCount: mergedFindings.filter(f => f.severity === 'critical').length,
  highCount: mergedFindings.filter(f => f.severity === 'high').length,
  mediumCount: mergedFindings.filter(f => f.severity === 'medium').length,
  lowCount: mergedFindings.filter(f => f.severity === 'low').length
};
```

### Step 7: Assign Final IDs

Ensure unique IDs across all findings:

```javascript
let idCounter = { SEC: 0, PERF: 0, A11Y: 0, TS: 0, TEST: 0 };

mergedFindings.forEach(finding => {
  const prefix = categoryToPrefix[finding.category];
  idCounter[prefix]++;
  finding.id = `${prefix}-${String(idCounter[prefix]).padStart(3, '0')}`;
});
```

### Step 8: Sort Findings

Order by severity, then by file:

```javascript
mergedFindings.sort((a, b) => {
  const severityOrder = { critical: 0, high: 1, medium: 2, low: 3, info: 4 };
  if (severityOrder[a.severity] !== severityOrder[b.severity]) {
    return severityOrder[a.severity] - severityOrder[b.severity];
  }
  return a.location.file.localeCompare(b.location.file);
});
```

### Step 9: Output Final Report

```json
{
  "metadata": {
    "timestamp": "2026-01-13T10:30:00Z",
    "acsVersion": "5.0.0",
    "projectName": "my-app",
    "agentsRun": ["security-reviewer", "performance-reviewer"],
    "filesScanned": 42,
    "cacheHit": true
  },
  "summary": {
    "grade": "B+",
    "criticalCount": 0,
    "highCount": 1,
    "mediumCount": 3,
    "lowCount": 5
  },
  "findings": [/* sorted, deduplicated, merged */],
  "positives": [
    "Consistent use of TypeScript",
    "Good test coverage",
    "Security headers configured"
  ]
}
```

## Verification Criteria

| Check | Requirement |
|-------|-------------|
| No duplicates | No two findings share same file:line |
| Severity preserved | Highest severity from duplicates kept |
| Grade calculated | Based on severity counts |
| Schema valid | Output validates against AuditReport schema |

## Deduplication Example

**Input:**
```json
[
  { "id": "SEC-001", "file": "api.ts", "line": 15, "severity": "high", "title": "SQL injection" },
  { "id": "PERF-001", "file": "api.ts", "line": 15, "severity": "medium", "title": "Slow query" }
]
```

**Output:**
```json
[
  {
    "id": "SEC-001",
    "file": "api.ts",
    "line": 15,
    "severity": "high",  // highest kept
    "title": "SQL injection",
    "verified": {
      "verificationNotes": "SQL injection risk; Also flagged as slow query"
    },
    "remediation": "Use parameterized queries\n\nAlternatively: Add query caching"
  }
]
```

## Notes

- This agent runs AFTER all specialists complete
- Single point of deduplication ensures clean output
- Grade provides quick summary of codebase health
- Positives balance the report (not just negatives)
