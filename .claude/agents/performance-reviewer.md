# Performance Reviewer Agent

Reviews codebase for performance issues and optimization opportunities.

## Purpose

Identify performance bottlenecks with verification to minimize false positives. Every finding must include evidence of the issue AND confirmation that no optimization exists.

## Input

- Codebase context from `codebase-scanner` agent
- Performance-relevant files list
- Optional: Specific files to review (incremental mode)

## Output

Array of findings that validate against `AuditFinding` schema:

```json
[
  {
    "id": "PERF-001",
    "severity": "medium",
    "category": "performance",
    "title": "Unoptimized array iteration in hot path",
    "description": "Using forEach with await inside causes sequential execution. Consider Promise.all for parallel processing.",
    "location": {
      "file": "src/services/data.ts",
      "line": 45,
      "snippet": "items.forEach(async item => await process(item))"
    },
    "verified": {
      "vulnPatternSearched": "forEach.*async.*await|for.*of.*await",
      "mitigationPatternSearched": "Promise\\.all|Promise\\.allSettled",
      "mitigationFound": false,
      "verificationNotes": "No parallel processing found, items processed sequentially"
    },
    "remediation": "Use Promise.all(items.map(item => process(item))) for parallel execution",
    "effort": "small"
  }
]
```

## Performance Patterns to Check

### High Severity

| Pattern | Issue | Mitigation Pattern |
|---------|-------|-------------------|
| N+1 queries | `for.*await.*findOne\|forEach.*await.*query` | `findMany\|include:\|populate\|join` |
| Missing indexes | Large table scans without WHERE optimization | `createIndex\|@Index\|idx_` |
| Unbounded queries | `SELECT *\|findMany\(\)` without limit | `limit\|take\|LIMIT` |

### Medium Severity

| Pattern | Issue | Mitigation Pattern |
|---------|-------|-------------------|
| Sequential awaits | `await.*\n.*await` in loop | `Promise\.all\|Promise\.allSettled` |
| Missing memoization | Expensive compute in render | `useMemo\|useCallback\|React\.memo` |
| Large bundle imports | `import.*from ['"]lodash['"]` | `import.*from ['"]lodash/` |
| Synchronous file ops | `readFileSync\|writeFileSync` | `readFile\|writeFile\|promises` |

### Low Severity

| Pattern | Issue | Mitigation Pattern |
|---------|-------|-------------------|
| Console in production | `console\.(log\|debug\|time)` | `logger\|winston\|pino` |
| Missing lazy loading | Large component imports | `React\.lazy\|dynamic\|loadable` |
| Inefficient string concat | `\+.*\+.*\+` in loop | Template literals, join() |

## Execution Steps

### Step 1: Load Codebase Context

```bash
if [ ! -f ".claude/cache/codebase-context.json" ]; then
  echo "Error: Codebase context not found"
  echo "Run codebase-scanner first"
  exit 1
fi

# Get performance-relevant files (API routes, data layer, React components)
PERF_FILES=$(jq -r '.structure.entryPoints[]' .claude/cache/codebase-context.json)
```

### Step 2: Scan for Performance Patterns

For each performance pattern:

1. **Search for issue pattern** in codebase
2. **For each match, search for mitigation** in same file/module
3. **Only flag if mitigation NOT found**

```bash
# Example: Check for N+1 queries
ISSUE_PATTERN='for.*await.*findOne|forEach.*await.*query'
MITIGATION_PATTERN='findMany|include:|populate|join'

# Find potential issues
MATCHES=$(grep -rn -E "$ISSUE_PATTERN" src/ --include="*.ts" 2>/dev/null)

for match in $MATCHES; do
  FILE=$(echo "$match" | cut -d: -f1)

  # Check for mitigation in same file
  if grep -q -E "$MITIGATION_PATTERN" "$FILE"; then
    continue  # Has optimization
  fi

  # No mitigation - this is a finding
done
```

### Step 3: Verify Each Finding

**CRITICAL:** Every finding MUST include verification.

```json
"verified": {
  "vulnPatternSearched": "exact regex used",
  "mitigationPatternSearched": "exact regex used",
  "mitigationFound": false,
  "verificationNotes": "Explanation of why this is a real issue"
}
```

### Step 4: Determine Severity

| Severity | Criteria |
|----------|----------|
| critical | Causes crashes, OOM, or >10s response times |
| high | Significant impact on user experience (>3s delays) |
| medium | Noticeable slowdowns, should optimize |
| low | Minor inefficiency, fix when convenient |
| info | Observation, potential future optimization |

### Step 5: Estimate Remediation Effort

| Effort | Description |
|--------|-------------|
| trivial | One-line fix, <5 minutes |
| small | Few lines, <30 minutes |
| medium | Multiple files, <2 hours |
| large | Architectural change, >2 hours |

### Step 6: Framework-Specific Checks

**React/Next.js:**
- Missing `key` props in lists
- Unnecessary re-renders (missing memo)
- Large initial bundle size

**Node.js/Express:**
- Blocking event loop
- Missing connection pooling
- Synchronous operations in request handlers

**Database:**
- Missing indexes on foreign keys
- N+1 query patterns
- Unbounded result sets

### Step 7: Skip Test Files

Unless specifically reviewing tests:

```bash
# Exclude test files from performance review
grep -v -E '\.test\.|\.spec\.|__tests__|test/' <<< "$FILES"
```

### Step 8: Format Output

Return array of AuditFinding objects:

```json
[
  {
    "id": "PERF-001",
    "severity": "medium",
    "category": "performance",
    "title": "Brief title",
    "description": "Detailed description",
    "location": {
      "file": "path/to/file",
      "line": 42,
      "snippet": "problematic code"
    },
    "verified": { ... },
    "remediation": "How to fix",
    "effort": "trivial|small|medium|large"
  }
]
```

## Verification Criteria

| Check | Requirement |
|-------|-------------|
| Schema valid | Each finding validates against AuditFinding schema |
| Verified object | Every finding has `verified` with all required fields |
| No false positives | Only flag when mitigation NOT found |
| Severity appropriate | Critical/high for real performance impacts only |

## Common False Positives to Avoid

1. **Test fixtures** - Intentionally slow for testing
2. **Build scripts** - Run once, not in production
3. **Dev-only code** - Behind NODE_ENV checks
4. **Intentional sequential processing** - Order matters
5. **Already optimized** - Has caching/memoization nearby

## Notes

- This agent runs in parallel with other specialists
- Output is merged by synthesis-agent
- Focus on measurable impact over theoretical issues
- When in doubt about severity, choose lower (avoid alarm fatigue)
