# Synthesis Agent

Merges findings from specialist agents into unified report.

## Purpose

- Deduplicate findings (same file:line = one finding)
- Merge evidence from different specialists
- Calculate overall grade
- Identify positive patterns
- Produce final AuditReport

## Input

Specialist outputs conforming to `specialist-output.schema.json`:

```json
{
  "security": { "specialist": "security", "findings": [...], "positives": [...], "summary": {...} },
  "performance": { "specialist": "performance", "findings": [...], "positives": [...], "summary": {...} },
  "accessibility": { "specialist": "accessibility", "findings": [...], "positives": [...], "summary": {...} },
  "seo": { "specialist": "seo", "findings": [...], "positives": [...], "summary": {...} },
  "typescript": { "specialist": "typescript", "findings": [...], "positives": [...], "summary": {...} },
  "testing": { "specialist": "testing", "findings": [...], "positives": [...], "summary": {...} },
  "database": { "specialist": "database", "findings": [...], "positives": [...], "summary": {...} },
  "infrastructure": { "specialist": "infrastructure", "findings": [...], "positives": [...], "summary": {...} },
  "libraries": { "specialist": "libraries", "findings": [...], "positives": [...], "summary": {...} }
}
```

Each specialist's `findings` array contains `AuditFinding` objects per `audit-finding.json` schema.

## Output

Complete `AuditReport` with deduplication stats:

```json
{
  "metadata": { "timestamp": "...", "projectName": "...", "agentsRun": [...] },
  "summary": {
    "grade": "B+",
    "criticalCount": 0,
    "highCount": 1,
    "mediumCount": 3,
    "lowCount": 5
  },
  "findings": [
    {
      "id": "SEC-001-MERGED",
      "severity": "high",
      "title": "Issue at api.ts:15",
      "detectedBy": ["security", "infrastructure"],
      "mergedFrom": ["SEC-001", "INFRA-001"]
    }
  ],
  "groups": [
    {
      "id": "GROUP-SECURITY-0",
      "type": "group",
      "pattern": "Missing error handling",
      "count": 5,
      "files": ["auth.ts", "db.ts", "api.ts"],
      "memberIds": ["SEC-002", "SEC-003", "SEC-004"]
    }
  ],
  "stats": {
    "rawFindings": 136,
    "afterLocationDedup": 67,
    "afterPatternGrouping": 45,
    "reductionPercent": 67
  },
  "positives": ["TypeScript strict mode", "Good test coverage"]
}
```

## Execution

### 1. Flatten All Findings

Combine findings from all specialists into single array.

### 2. Deduplicate (Two-Layer)

**Layer 1: Location-based deduplication** using `dedupe_by_location()`:
- Findings at identical file:line are merged
- Highest severity wins (critical > high > medium > low > info)
- `detectedBy` array lists all detecting agents
- `mergedFrom` array preserves original IDs
- ID gets `-MERGED` suffix

```
SEC-001 (high) + INFRA-001 (medium) at api.ts:15
→ SEC-001-MERGED (high) with detectedBy: ["SEC", "INFRA"]
```

**Layer 2: Pattern-based grouping** using `group_similar_findings()`:
- Groups findings with similar titles (>=3 threshold)
- Creates GROUP-* entries linking related findings
- Original findings remain, groups provide overview

```
5 findings about "Missing error handling in <file>"
→ GROUP-SECURITY-0 with count: 5, memberIds: [...]
```

**Result:** The `synthesize_findings()` function orchestrates both layers.

### 3. Calculate Grade

Use the weighted formula with caps (see `docs/planning/v5.2/grade-calculation.md`):

```javascript
function calculateGrade(findings) {
  let score = 100;

  const counts = {
    critical: findings.filter(f => f.severity === 'critical').length,
    high: findings.filter(f => f.severity === 'high').length,
    medium: findings.filter(f => f.severity === 'medium').length,
    low: findings.filter(f => f.severity === 'low').length
  };

  // Apply deductions with caps
  score -= Math.min(counts.critical * 25, 50);  // max -50
  score -= Math.min(counts.high * 10, 30);      // max -30
  score -= Math.min(counts.medium * 3, 20);     // max -20
  score -= Math.min(counts.low * 1, 10);        // max -10

  score = Math.max(0, score);

  const grade =
    score >= 90 ? 'A' :
    score >= 80 ? 'B' :
    score >= 70 ? 'C' :
    score >= 60 ? 'D' : 'F';

  return { score, grade };
}
```

| Grade | Score Range | Interpretation |
|-------|-------------|----------------|
| A | 90-100 | Excellent - minor issues only |
| B | 80-89 | Good - some improvements needed |
| C | 70-79 | Acceptable - significant work needed |
| D | 60-69 | Poor - major issues to address |
| F | 0-59 | Failing - critical problems |

### 4. Identify Positives

Check codebase context for:
- TypeScript with strict mode → "Consistent use of TypeScript"
- Test suite present → "Test suite configured"
- CI/CD present → "CI/CD pipeline configured"
- Lock file present → "Dependencies locked"
- Security headers → "Security headers configured"

### 5. Assign Final IDs

Ensure unique IDs: `SEC-001`, `SEC-002`, `PERF-001`, etc.

### 6. Sort Findings

Order by: severity (critical first), then file path.

### 7. Generate Report Files

After synthesis completes, automatically generate report files:

1. **Determine filename** using `get_next_audit_filename()`:
   - First audit of day: `audit-YYYY-MM-DD`
   - Subsequent audits: `audit-YYYY-MM-DD-002`, `audit-YYYY-MM-DD-003`, etc.

2. **Generate markdown report** using `generate_audit_markdown()`:
   - Human-readable format
   - Executive summary with grade
   - Findings sorted by severity
   - Positives section
   - Deduplication statistics

3. **Generate JSON report** using `generate_audit_json()`:
   - Machine-readable format
   - Schema-validated against `audit-report.json`
   - Suitable for CI integration

4. **Atomic write strategy**:
   - Write to temp file first (`*.tmp`)
   - Validate content
   - Atomic rename to final location
   - Clean up any stale `.tmp` files on startup

**Output location:** `docs/audits/audit-YYYY-MM-DD.{md,json}`

**Helper script:** `./scripts/generate-audit-report.sh`

## Deduplication Examples

**Same concern (merge):**
```
Input:
  SEC-001: api.ts:15 - Hardcoded secret (high)
  INFRA-001: api.ts:15 - Secret in code (high)

Output:
  SEC-001: api.ts:15 - Hardcoded secret (high)
    notes: "Combined: Hardcoded secret flagged by security and infrastructure review"
```

**Different concerns (keep separate):**
```
Input:
  SEC-001: api.ts:15 - SQL injection (high)
  PERF-001: api.ts:15 - Slow query (medium)

Output:
  SEC-001: api.ts:15 - SQL injection (high)
    seeAlso: "PERF-001"
  PERF-001: api.ts:15 - Slow query (medium)
    seeAlso: "SEC-001"
```

## Guardrails

- **DO** keep highest severity when deduplicating
- **DO** merge verification notes from all sources
- **DO** include positives (balance the report)
- **DO NOT** lose information when merging
- **DO NOT** produce duplicate file:line entries
