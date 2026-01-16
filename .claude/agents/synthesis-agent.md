# Synthesis Agent

Merges findings from specialist agents into unified report.

## Purpose

- Deduplicate findings (same file:line = one finding)
- Merge evidence from different specialists
- Calculate overall grade
- Identify positive patterns
- Produce final AuditReport

## Input

Findings from all specialist agents:

```json
{
  "security": [AuditFinding, ...],
  "performance": [AuditFinding, ...],
  "accessibility": [AuditFinding, ...],
  "seo": [AuditFinding, ...],
  "typescript": [AuditFinding, ...],
  "testing": [AuditFinding, ...],
  "database": [AuditFinding, ...],
  "infrastructure": [AuditFinding, ...]
}
```

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

| Condition | Grade |
|-----------|-------|
| Any critical | F |
| >3 high | D |
| >1 high | C |
| 1 high | C+ |
| >5 medium | B- |
| >2 medium | B |
| >0 medium | B+ |
| >5 low | A- |
| >0 low | A |
| 0 issues | A+ |

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
