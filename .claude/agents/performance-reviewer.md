# Performance Reviewer Agent

Reviews codebase for performance issues.

## Agent Contract

```json
{
  "id": "performance",
  "prefix": "PERF",
  "category": "performance",
  "applicability": {
    "always": false,
    "requires": {
      "structure.hasUI": true
    },
    "presets": ["prelaunch", "frontend"]
  }
}
```

## File Scope

This agent reads from `uiComponents` file list in scanner output for UI performance.
Also checks `files` for data layer and API routes.

## Purpose

Identify performance bottlenecks with **verification**. Every finding must include evidence of the issue AND confirmation that no optimization exists.

## Input

- Codebase context from `.claude/cache/codebase-context.json`
- Focus on data layer, API routes, React components

## Output

Array of `AuditFinding` objects with `category: "performance"` and `id` prefix `PERF-`.

## Performance Patterns

### High Severity

| Issue | Pattern | Mitigation |
|-------|---------|------------|
| N+1 queries | `for.*await.*findOne\|forEach.*await.*query` | `findMany\|include:\|populate` |
| Unbounded queries | `SELECT \*\|findMany\(\)` without limit | `limit\|take\|LIMIT` |
| Missing indexes | Large table scans | `createIndex\|@Index` |

### Medium Severity

| Issue | Pattern | Mitigation |
|-------|---------|------------|
| Sequential awaits | `await.*\n.*await` in loop | `Promise\.all` |
| Missing memoization | Expensive compute in render | `useMemo\|useCallback\|React\.memo` |
| Large imports | `import.*from ['"]lodash['"]` | `import.*from ['"]lodash/` |
| Sync file ops | `readFileSync\|writeFileSync` | `readFile\|writeFile` |

### Low Severity

| Issue | Pattern | Mitigation |
|-------|---------|------------|
| Console in prod | `console\.(log\|time)` | `logger\|winston` |
| No lazy loading | Large component imports | `React\.lazy\|dynamic` |

## Execution

### 1. For Each Pattern

1. Search for performance issue pattern
2. Search for mitigation in same file/module
3. **Only flag if mitigation NOT found**

### 2. Verify Every Finding

```json
"verified": {
  "vulnPatternSearched": "[pattern]",
  "mitigationPatternSearched": "[pattern]",
  "mitigationFound": false,
  "verificationNotes": "[why this impacts performance]"
}
```

### 3. Determine Severity

| Severity | Criteria |
|----------|----------|
| critical | OOM, >10s response times |
| high | >3s delays, noticeable UX impact |
| medium | Slowdowns, should optimize |
| low | Minor inefficiency |

### 4. Skip False Positives

**DO NOT flag:**
- Build scripts (run once)
- Dev-only code (behind NODE_ENV)
- Intentional sequential processing (order matters)
- Already optimized (has caching nearby)

## Guardrails

- **DO** verify mitigation absence before flagging
- **DO** focus on measurable impact
- **DO** use lower severity when uncertain
- **DO NOT** flag theoretical issues without evidence
