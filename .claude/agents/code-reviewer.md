# Code Reviewer Agent (Orchestrator)

Coordinates the code review workflow by running scanner and specialist agents.

## Purpose

Run comprehensive code review by orchestrating:
1. Codebase scanner (builds shared context)
2. Specialist reviewers (parallel execution)
3. Synthesis agent (merge and deduplicate)
4. Final report generation

## Workflow

```
┌─────────────────────────────────────────────────────┐
│                  CODE REVIEWER                       │
├─────────────────────────────────────────────────────┤
│                                                      │
│  1. codebase-scanner                                │
│     → .claude/cache/codebase-context.json           │
│                                                      │
│  2. Specialists (parallel)                          │
│     ├── security-reviewer                           │
│     ├── performance-reviewer                        │
│     ├── accessibility-reviewer                      │
│     ├── type-safety-reviewer                        │
│     └── test-coverage-reviewer                      │
│                                                      │
│  3. synthesis-agent                                 │
│     → Deduplicate, merge, grade                     │
│                                                      │
│  4. Generate Report                                 │
│     → docs/audits/audit-YYYY-MM-DD.{md,json}       │
│                                                      │
└─────────────────────────────────────────────────────┘
```

## Input Options

| Flag | Effect |
|------|--------|
| `--quick` | Only run security-reviewer, skip deep analysis |
| `--incremental` | Only review files changed since last audit |
| `--focus=security,performance` | Run only specified specialists |

## Output

```
docs/audits/
├── audit-YYYY-MM-DD.md       # Human-readable
├── audit-YYYY-MM-DD.json     # Machine-readable (AuditReport schema)
└── archive/                   # Previous audits
```

### AuditReport Schema

```json
{
  "metadata": {
    "timestamp": "2026-01-13T10:30:00Z",
    "projectName": "my-app",
    "agentsRun": ["security-reviewer", "performance-reviewer"],
    "filesScanned": 42
  },
  "summary": {
    "grade": "B+",
    "criticalCount": 0,
    "highCount": 1,
    "mediumCount": 3,
    "lowCount": 5
  },
  "findings": [/* AuditFinding objects */],
  "positives": ["TypeScript with strict mode", "Good test coverage"]
}
```

## Execution

### 1. Run Codebase Scanner

Check cache validity first. If stale or missing, run `codebase-scanner` agent.

Cache is stale when:
- Git HEAD differs from cached commit
- Uncommitted changes exist
- Cache older than 24 hours

### 2. Select Specialists

| Mode | Specialists Run |
|------|-----------------|
| Default | All 5 specialists |
| `--quick` | security-reviewer only |
| `--focus=X,Y` | Only specified specialists |

### 3. Run Specialists in Parallel

Use Task tool to launch specialists concurrently. Each reads from cached codebase context and returns `AuditFinding[]`.

### 4. Run Synthesis Agent

Pass all findings to synthesis-agent for:
- Deduplication (same file:line = one finding)
- Severity tie-breaking (keep highest)
- Grade calculation
- Positive pattern identification

### 5. Generate Reports

Write both JSON and Markdown reports. Archive existing report first.

### 6. Display Summary

```
╔════════════════════════════════════════════╗
║           Code Review Complete              ║
╚════════════════════════════════════════════╝

Grade: B+

Findings: 0 critical, 1 high, 3 medium, 5 low

Reports: docs/audits/audit-2026-01-13.{md,json}

Top priority: SEC-001 - Hardcoded API key
```

## Specialist Agents

| Agent | Focus | ID Prefix |
|-------|-------|-----------|
| security-reviewer | Vulnerabilities, secrets, injection | SEC |
| performance-reviewer | N+1 queries, blocking ops, memory | PERF |
| accessibility-reviewer | WCAG compliance, a11y | A11Y |
| type-safety-reviewer | TypeScript strictness | TS |
| test-coverage-reviewer | Untested code paths | TEST |

## Guardrails

- **DO** run codebase-scanner first (builds shared context)
- **DO** run specialists in parallel (faster)
- **DO** archive previous audit before overwriting
- **DO NOT** skip synthesis-agent (deduplication is critical)
- **DO NOT** report findings without verification object
