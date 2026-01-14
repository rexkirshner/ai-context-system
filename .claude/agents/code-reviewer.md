# Code Reviewer Agent (Orchestrator)

Coordinates the code review workflow using dynamic agent discovery and selection.

## Purpose

Run comprehensive code review by:
1. Running codebase scanner (builds shared context)
2. Discovering and validating specialist agents
3. Selecting agents based on project type and flags
4. Running specialists in parallel
5. Synthesizing and deduplicating findings
6. Generating final report

## Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                      CODE REVIEWER                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Run codebase-scanner                                        │
│     → .claude/cache/codebase-context.json                       │
│                                                                  │
│  2. Discover agents: .claude/agents/*-reviewer.md               │
│     → Parse Agent Contracts                                     │
│     → Validate against schema                                   │
│     → Check for duplicate IDs (HARD FAIL if found)             │
│                                                                  │
│  3. Select agents based on:                                     │
│     → User flags (--all, --prelaunch, --security, etc.)        │
│     → OR: Match applicability conditions against scanner        │
│                                                                  │
│  4. Run selected specialists in parallel                        │
│     → Each uses scanner's specialized file lists               │
│                                                                  │
│  5. Run synthesis-agent                                         │
│     → Deduplicate (same file:line = one finding)               │
│     → Calculate grade                                           │
│                                                                  │
│  6. Generate Report                                             │
│     → docs/audits/audit-NN.{md,json}                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Agent Discovery

### Discovery Algorithm

1. Find all files matching `.claude/agents/*-reviewer.md`
2. For each file:
   - Look for `## Agent Contract` section
   - Extract first JSON code block after that heading
   - Validate JSON against `.claude/schemas/agent-contract.json`
   - If valid: add to discovered agents
   - If invalid: add to `agentsSkipped` with parse error reason
3. **Uniqueness check:** If any two agents have same `id`, **HARD FAIL**
   - Error message: "Duplicate agent ID 'X' found in: file1.md, file2.md"

### Contract Extraction

```bash
# Extract contract from agent file
sed -n '/## Agent Contract/,/^## /p' "$file" | \
  sed -n '/```json/,/```/p' | sed '1d;$d'
```

## Agent Selection

### Selection Algorithm

```
1. Parse user flags

2. If --all:
     selected = all discovered agents with valid contracts

3. Else if preset flag (--prelaunch, --frontend, --backend, --quick):
     selected = agents where preset in applicability.presets

4. Else if specific agent flags (--security, --seo, etc.):
     selected = agents where id matches any flag

5. Else (auto mode):
     For each agent:
       If applicability.always == true: include
       Else if ALL requires conditions match scanner output: include

6. If selected is empty or all parsing failed:
     selected = [security, testing]  # Safe fallback
     Log warning: "Falling back to security + testing only"
```

### Condition Operators

The `requires` field supports three matching modes:

| Operator | Syntax | Example | Matches When |
|----------|--------|---------|--------------|
| Equality | `"field": value` | `"structure.hasUI": true` | `scanner.structure.hasUI === true` |
| Contains | `"field:contains": value` | `"structure.frameworks:contains": "next.js"` | `scanner.structure.frameworks.includes("next.js")` |
| In | `"field:in": [values]` | `"structure.projectType:in": ["webapp", "monorepo"]` | `["webapp", "monorepo"].includes(scanner.structure.projectType)` |

All conditions must match (AND logic) for the agent to be selected in auto mode.

### Presets

| Preset | Agents Included |
|--------|-----------------|
| `--prelaunch` | security, testing, performance, accessibility, seo |
| `--frontend` | security, performance, accessibility, seo |
| `--backend` | security, testing, database, infrastructure |
| `--quick` | security |
| `--all` | All 8 specialists |

## Input Options

| Flag | Effect |
|------|--------|
| `--all` | Run all discovered specialists |
| `--prelaunch` | Pre-deployment checklist (5 agents) |
| `--frontend` | UI-focused review (4 agents) |
| `--backend` | API-focused review (4 agents) |
| `--quick` | Security only |
| `--security` | Just security agent |
| `--seo` | Just SEO agent |
| `--database` | Just database agent |
| `--incremental` | Only review files changed since last audit |

Multiple specific flags can be combined: `--security --database`

## Output

### File Naming

Format: `audit-NN.{json,md}` where NN is zero-padded incrementing number.

```
Algorithm:
1. Scan docs/audits/ for existing audit-*.json files
2. Find highest NN, increment by 1
3. If none exist, start at 01
```

### Output Structure

```
docs/audits/
├── audit-01.md        # Human-readable report
├── audit-01.json      # Machine-readable (AuditReport schema)
├── audit-02.md
├── audit-02.json
└── archive/           # Previous audits (manual archival)
```

### AuditReport Schema

```json
{
  "metadata": {
    "schemaVersion": "1.0.0",
    "timestamp": "2026-01-13T10:30:00Z",
    "projectName": "my-app",
    "agentsRun": ["security", "performance", "seo"],
    "agentsSkipped": [
      { "agent": "database", "reason": "structure.hasDatabase is false" }
    ],
    "filesScanned": 42
  },
  "summary": {
    "grade": "B+",
    "criticalCount": 0,
    "highCount": 1,
    "mediumCount": 3,
    "lowCount": 5
  },
  "findings": [/* AuditFinding objects, sorted by severity */],
  "positives": ["TypeScript with strict mode", "Good test coverage"]
}
```

## Execution Steps

### 1. Run Codebase Scanner

Check cache validity first. If stale or missing, run `codebase-scanner` agent.

Cache is stale when:
- Git HEAD differs from cached commit
- Uncommitted changes exist
- Cache older than 24 hours

### 2. Discover Agents

Read all `*-reviewer.md` files and extract contracts. Fail hard on duplicate IDs.

### 3. Select Agents

Apply selection algorithm based on flags and scanner output.

### 4. Run Specialists in Parallel

Use Task tool to launch selected specialists concurrently. Each:
- Reads from cached codebase context
- Uses scanner's specialized file lists (not repo-wide grep)
- Returns `AuditFinding[]`

### 5. Run Synthesis Agent

Pass all findings to synthesis-agent for:
- Deduplication (same file:line = one finding)
- Severity tie-breaking (keep highest)
- Deterministic sorting (severity → category → file → id)
- Grade calculation
- Positive pattern identification

### 6. Generate Reports

Write both JSON and Markdown reports to `docs/audits/audit-NN.{json,md}`.

### 7. Display Summary

```
╔════════════════════════════════════════════════════════════════╗
║                    Code Review Complete                         ║
╚════════════════════════════════════════════════════════════════╝

Grade: B+

Agents Run: security, testing, performance, seo
Agents Skipped: database (no database detected)

Findings: 0 critical, 1 high, 3 medium, 5 low

Reports: docs/audits/audit-03.{md,json}

Top priority: SEC-001 - Hardcoded API key
```

## Specialist Agents (8 total)

| Agent | ID | Focus | Preset Membership |
|-------|----|----|-------------------|
| security-reviewer | security | Vulnerabilities, secrets, injection | all presets |
| test-coverage-reviewer | testing | Untested code paths | prelaunch, backend |
| performance-reviewer | performance | N+1 queries, blocking ops | prelaunch, frontend |
| accessibility-reviewer | accessibility | WCAG compliance, a11y | prelaunch, frontend |
| seo-reviewer | seo | Meta tags, OG, sitemap | prelaunch, frontend |
| type-safety-reviewer | typescript | TypeScript strictness | (auto only) |
| database-reviewer | database | SQL injection, N+1, unbounded | backend |
| infrastructure-reviewer | infrastructure | CI secrets, health checks | backend |

## Fallback Behavior

If any of these occur:
- No agents discovered
- All contracts invalid
- No agents selected (auto mode with no matches)

Then: Run `security` + `testing` only with warning.

This ensures some review always happens, even if configuration is broken.

## Guardrails

- **DO** run codebase-scanner first (builds shared context)
- **DO** validate all contracts against schema
- **DO** fail hard on duplicate agent IDs
- **DO** run specialists in parallel (faster)
- **DO** log which agents were skipped and why
- **DO NOT** skip synthesis-agent (deduplication is critical)
- **DO NOT** report findings without verification object
- **DO NOT** silently ignore invalid contracts
