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
  "typescript": [AuditFinding, ...],
  "testing": [AuditFinding, ...]
}
```

## Output

Complete `AuditReport`:

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
  "findings": [/* deduplicated, merged */],
  "positives": ["TypeScript strict mode", "Good test coverage"]
}
```

## Execution

### 1. Flatten All Findings

Combine findings from all specialists into single array.

### 2. Deduplicate

**Duplicate:** Same file AND same line number.

For duplicates, merge:
- Keep highest severity
- Combine verification notes
- Combine remediations if different

```
SEC-001 (high) + PERF-001 (medium) at api.ts:15
→ SEC-001 (high) with combined notes
```

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

## Deduplication Example

**Input:**
```
SEC-001: api.ts:15 - SQL injection (high)
PERF-001: api.ts:15 - Slow query (medium)
```

**Output:**
```
SEC-001: api.ts:15 - SQL injection (high)
  notes: "SQL injection risk; Also flagged as slow query"
  remediation: "Use parameterized queries. Also: Add query caching"
```

## Guardrails

- **DO** keep highest severity when deduplicating
- **DO** merge verification notes from all sources
- **DO** include positives (balance the report)
- **DO NOT** lose information when merging
- **DO NOT** produce duplicate file:line entries
