# Code Reviewer Agent (Orchestrator)

Orchestrates the code review process by running scanner and specialist agents.

## Purpose

Coordinate the code review workflow:
1. Run codebase-scanner first (builds shared context)
2. Run specialist reviewers in parallel
3. Collect and merge results via synthesis-agent
4. Produce final AuditReport

## Input

- Project root directory
- Optional flags:
  - `--quick`: Skip deep analysis, faster results
  - `--incremental`: Only review changed files
  - `--focus=security,performance`: Run only specified specialists

## Output

Final `AuditReport` saved to `docs/audits/`:

```
docs/audits/
├── audit-YYYY-MM-DD.md       # Human-readable report
├── audit-YYYY-MM-DD.json     # Machine-readable (AuditReport schema)
└── archive/                   # Previous audits
```

## Execution Flow

```
┌─────────────────────────────────────────────────────────┐
│                    CODE REVIEWER                         │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Step 1: Run Codebase Scanner                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │ codebase-scanner                                 │   │
│  │ → .claude/cache/codebase-context.json           │   │
│  └──────────────────────────────────────────────────┘   │
│                          │                               │
│                          ▼                               │
│  Step 2: Run Specialists (Parallel)                     │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐          │
│  │ security-  │ │ performance│ │ type-      │ ...      │
│  │ reviewer   │ │ -reviewer  │ │ safety     │          │
│  └────────────┘ └────────────┘ └────────────┘          │
│        │              │              │                   │
│        └──────────────┼──────────────┘                  │
│                       ▼                                  │
│  Step 3: Synthesize Results                             │
│  ┌──────────────────────────────────────────────────┐   │
│  │ synthesis-agent                                  │   │
│  │ → Deduplicate, merge, grade                      │   │
│  └──────────────────────────────────────────────────┘   │
│                          │                               │
│                          ▼                               │
│  Step 4: Generate Report                                │
│  ┌──────────────────────────────────────────────────┐   │
│  │ docs/audits/audit-YYYY-MM-DD.{md,json}          │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Specialist Agents

| Agent | Focus | Priority |
|-------|-------|----------|
| security-reviewer | Security vulnerabilities | High |
| performance-reviewer | Performance issues | Medium |
| accessibility-reviewer | A11y compliance | Medium |
| type-safety-reviewer | TypeScript strictness | Low |
| test-coverage-reviewer | Test coverage gaps | Low |

**Phase 3 includes:** security-reviewer, code-reviewer, codebase-scanner, synthesis-agent
**Phase 4 adds:** performance-reviewer, accessibility-reviewer, type-safety-reviewer, test-coverage-reviewer

## Execution Steps

### Step 1: Check Prerequisites

```bash
# Ensure we're in a valid project
if [ ! -d ".git" ] && [ ! -f "package.json" ]; then
  echo "Warning: Not in a recognized project root"
fi

# Create output directory
mkdir -p docs/audits/archive

# Archive previous audit if exists
TODAY=$(date +%Y-%m-%d)
if [ -f "docs/audits/audit-$TODAY.json" ]; then
  mv "docs/audits/audit-$TODAY.json" "docs/audits/archive/"
  mv "docs/audits/audit-$TODAY.md" "docs/audits/archive/" 2>/dev/null
fi
```

### Step 2: Run Codebase Scanner

```bash
echo "Scanning codebase..."

# Check cache validity
if is_cache_valid; then
  echo "Using cached codebase context"
else
  # Run scanner agent
  # (This is executed by the AI following codebase-scanner.md instructions)
fi
```

### Step 3: Determine Specialists to Run

```bash
# Default: all specialists
SPECIALISTS=("security-reviewer" "performance-reviewer" "accessibility-reviewer" "type-safety-reviewer" "test-coverage-reviewer")

# --focus flag limits specialists
if [ -n "$FOCUS" ]; then
  SPECIALISTS=($(echo "$FOCUS" | tr ',' ' '))
fi

# --quick mode: only high-priority
if [ "$QUICK" = true ]; then
  SPECIALISTS=("security-reviewer")
fi
```

### Step 4: Run Specialists in Parallel

**AI Implementation:**
Use Claude's Task tool to run multiple specialists concurrently:

```
Task 1: security-reviewer → security_findings[]
Task 2: performance-reviewer → performance_findings[]
Task 3: accessibility-reviewer → accessibility_findings[]
...
```

Each specialist:
- Reads from `.claude/cache/codebase-context.json`
- Returns array of AuditFinding objects
- Operates independently

### Step 5: Collect Results

Gather findings from all specialists:

```json
{
  "security": [...],
  "performance": [...],
  "accessibility": [...],
  "typescript": [...],
  "testing": [...]
}
```

### Step 6: Run Synthesis Agent

Pass all findings to synthesis-agent for:
- Deduplication (same file:line = one finding)
- Merging evidence from multiple specialists
- Calculating overall grade
- Generating summary

### Step 7: Build Final Report

Create AuditReport:

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
  "findings": [...],
  "positives": [
    "Consistent use of TypeScript",
    "Good test coverage",
    "Security headers configured"
  ]
}
```

### Step 8: Generate Markdown Report

Create human-readable `audit-YYYY-MM-DD.md`:

```markdown
# Code Review Audit

**Date:** 2026-01-13
**Grade:** B+
**Files Scanned:** 42

## Summary

- **Critical:** 0
- **High:** 1
- **Medium:** 3
- **Low:** 5

## High Severity Findings

### SEC-001: Hardcoded API key

**File:** src/config/api.ts:15
**Effort:** Trivial

An API key is hardcoded...

**Remediation:** Move to environment variable...

---

## Positives

- Consistent use of TypeScript
- Good test coverage
...
```

### Step 9: Output Summary

```
╔════════════════════════════════════════════╗
║           Code Review Complete              ║
╚════════════════════════════════════════════╝

Grade: B+

Findings:
  Critical: 0
  High:     1
  Medium:   3
  Low:      5

Reports:
  docs/audits/audit-2026-01-13.md
  docs/audits/audit-2026-01-13.json

Top priority: Fix SEC-001 (hardcoded API key)
```

## Verification Criteria

| Check | Requirement |
|-------|-------------|
| Scanner runs first | Cache exists before specialists run |
| Parallel execution | Specialists don't wait for each other |
| Report valid | Output validates against AuditReport schema |
| All findings verified | Every finding has `verified` object |

## Quick Mode (--quick)

- Only runs security-reviewer
- Skips deep analysis
- Target: Complete in <3 minutes
- Use for: Quick sanity checks

## Incremental Mode (--incremental)

- Only scans files in `git diff --name-only`
- Merges with cached findings for unchanged files
- Use for: CI/CD pipelines, pre-commit checks

## Notes

- This is the main entry point for code review
- Replaces v4.x `/code-review` and specialist commands
- Parallel execution significantly speeds up review
- Results are cached to avoid redundant scanning
