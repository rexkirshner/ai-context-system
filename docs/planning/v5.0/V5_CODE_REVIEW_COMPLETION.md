# V5.0 Code Review System Completion Plan

**Document Version:** 1.0
**Created:** 2026-01-13
**Status:** Active

---

## Executive Summary

The v5.0 agent-based code review system is partially implemented. This document provides a detailed plan to complete it with objectively verifiable criteria for each task.

### Current State

| Component | Planned | Implemented | Gap |
|-----------|---------|-------------|-----|
| Specialist agents | 8 | 5 | Missing SEO, Database, Infrastructure |
| Conditional selection | Yes | No | codebase-scanner doesn't output recommendedReviewers |
| Command integration | Yes | No | /code-review doesn't invoke agents |
| Old commands | Deprecated | Active | 8 detailed commands still primary system |

### Target State

```
/code-review (thin wrapper)
    → code-reviewer (orchestrator)
        → codebase-scanner (context + recommendedReviewers)
        → 8 specialists (conditional, parallel)
        → synthesis-agent (merge + grade)
        → audit-compare (optional trends)
    → Structured output (JSON + Markdown)
```

---

## Part 1: Gap Analysis

### 1.1 What Exists (Working)

| Agent | File | Status |
|-------|------|--------|
| code-reviewer | `.claude/agents/code-reviewer.md` | Exists, needs update |
| codebase-scanner | `.claude/agents/codebase-scanner.md` | Exists, needs enhancement |
| security-reviewer | `.claude/agents/security-reviewer.md` | Complete |
| performance-reviewer | `.claude/agents/performance-reviewer.md` | Complete |
| accessibility-reviewer | `.claude/agents/accessibility-reviewer.md` | Complete |
| type-safety-reviewer | `.claude/agents/type-safety-reviewer.md` | Complete |
| test-coverage-reviewer | `.claude/agents/test-coverage-reviewer.md` | Complete |
| synthesis-agent | `.claude/agents/synthesis-agent.md` | Complete |
| audit-compare | `.claude/agents/audit-compare.md` | Complete |

### 1.2 What's Missing

| Component | Description | Priority |
|-----------|-------------|----------|
| seo-reviewer agent | Metadata, OG tags, structured data | High |
| database-reviewer agent | N+1, injection, indexes, transactions | High |
| infrastructure-reviewer agent | CI secrets, health checks, caching | Medium |
| recommendedReviewers output | codebase-scanner enhancement | Critical |
| Conditional selection logic | code-reviewer enhancement | Critical |
| Command integration | /code-review uses agents | Critical |

### 1.3 What Should Be Deprecated

| File | Reason | Action |
|------|--------|--------|
| `.claude/commands/code-review-security.md` | Replaced by agent | Add deprecation notice |
| `.claude/commands/code-review-performance.md` | Replaced by agent | Add deprecation notice |
| `.claude/commands/code-review-accessibility.md` | Replaced by agent | Add deprecation notice |
| `.claude/commands/code-review-seo.md` | Replaced by agent | Add deprecation notice |
| `.claude/commands/code-review-database.md` | Replaced by agent | Add deprecation notice |
| `.claude/commands/code-review-infrastructure.md` | Replaced by agent | Add deprecation notice |
| `.claude/commands/code-review-typescript.md` | Replaced by agent | Add deprecation notice |
| `.claude/commands/code-review-testing.md` | Replaced by agent | Add deprecation notice |

---

## Part 2: Implementation Phases

### Phase A: Foundation Enhancement

**Purpose:** Enable conditional specialist selection by enhancing codebase-scanner output.

**Dependency:** None (can start immediately)

#### Task A1: Add Project Characteristic Detection

**File:** `.claude/agents/codebase-scanner.md`

**Input:** Current codebase-scanner agent

**Output:** Enhanced detection for:
- `hasDatabase` - Prisma, Drizzle, TypeORM, Mongoose, pg, mysql2 in deps
- `hasUI` - .tsx/.jsx files OR react/vue/svelte in deps
- `isServerless` - vercel.json, netlify.toml, or @vercel/* in deps
- `isMonorepo` - workspaces in package.json OR packages/ dir

**Verification Criteria:**
```bash
# Test on nextjs-app fixture (has Prisma, React, is webapp)
grep -q '"hasDatabase": true' .claude/cache/codebase-context.json
grep -q '"hasUI": true' .claude/cache/codebase-context.json

# Test on python-cli fixture (no DB, no UI)
grep -q '"hasDatabase": false' .claude/cache/codebase-context.json
grep -q '"hasUI": false' .claude/cache/codebase-context.json
```

**Definition of Done:**
- [ ] Detection logic documented in agent
- [ ] All 4 new fields present in output schema
- [ ] Correct detection on all 3 fixture repos

---

#### Task A2: Add recommendedReviewers Output

**File:** `.claude/agents/codebase-scanner.md`

**Input:** Task A1 complete

**Output:** New `recommendedReviewers` section in codebase-context.json:
```json
{
  "recommendedReviewers": {
    "always": ["security", "testing"],
    "conditional": [
      { "reviewer": "typescript", "reason": "TypeScript project" },
      { "reviewer": "accessibility", "reason": "Has UI components" },
      { "reviewer": "performance", "reason": "Web application" },
      { "reviewer": "seo", "reason": "Public webapp with UI" },
      { "reviewer": "database", "reason": "Uses Prisma ORM" },
      { "reviewer": "infrastructure", "reason": "Has CI workflows" }
    ]
  }
}
```

**Verification Criteria:**
```bash
# recommendedReviewers section exists
jq '.recommendedReviewers' .claude/cache/codebase-context.json | grep -q 'always'

# nextjs-app should recommend all 8
jq '.recommendedReviewers.conditional | length' .claude/cache/codebase-context.json
# Expected: 6 (conditional) + 2 (always) = 8 total

# python-cli should recommend only 2-3
# Expected: security, testing, (maybe typescript if .py typed)
```

**Definition of Done:**
- [ ] recommendedReviewers schema documented
- [ ] Selection logic matches project type matrix
- [ ] Correct recommendations on all 3 fixture repos

---

#### Task A3: Add Specialized File Lists

**File:** `.claude/agents/codebase-scanner.md`

**Input:** Task A1 complete

**Output:** New file list sections:
```json
{
  "databaseFiles": ["lib/db.ts", "prisma/schema.prisma"],
  "uiComponents": ["components/**/*.tsx"],
  "ciWorkflows": [".github/workflows/*.yml"]
}
```

**Verification Criteria:**
```bash
# Database files detected on nextjs-app
jq '.databaseFiles | length' .claude/cache/codebase-context.json
# Expected: >= 1

# UI components detected
jq '.uiComponents | length' .claude/cache/codebase-context.json
# Expected: >= 1
```

**Definition of Done:**
- [ ] File lists documented in schema
- [ ] Specialists can use these lists to focus their search
- [ ] Correct file lists on fixture repos

---

### Phase B: New Specialist Agents

**Purpose:** Create the 3 missing specialist agents.

**Dependency:** None (can run parallel with Phase A)

#### Task B1: Create SEO Reviewer Agent

**File:** `.claude/agents/seo-reviewer.md` (new)

**Applicability:** `projectType === "webapp" AND hasUI === true`

**Patterns to Detect:**

| Severity | Issue | Vulnerability Pattern | Mitigation Pattern |
|----------|-------|----------------------|-------------------|
| high | Missing title | `<head>` without `<title>` | `<title>\|Head.*title` |
| high | No meta description | Missing `meta.*description` | `meta.*name="description"` |
| high | Missing Open Graph | No `og:title`, `og:image` | `property="og:` |
| medium | No canonical | Missing `rel="canonical"` | `rel="canonical"` |
| medium | Images without alt | `<img(?![^>]*alt=)` | `alt=` |
| medium | No structured data | Missing JSON-LD | `application/ld\+json` |
| low | No sitemap | Missing sitemap.xml | File exists |
| low | No robots.txt | Missing robots.txt | File exists |

**Verification Criteria:**
```bash
# Agent file exists
test -f .claude/agents/seo-reviewer.md

# Has required sections
grep -q "## Applicability" .claude/agents/seo-reviewer.md
grep -q "## Patterns" .claude/agents/seo-reviewer.md
grep -q "## Guardrails" .claude/agents/seo-reviewer.md

# ID prefix is SEO
grep -q 'id.*prefix.*SEO' .claude/agents/seo-reviewer.md
```

**Definition of Done:**
- [ ] Agent file created with standard structure
- [ ] Applicability condition documented
- [ ] All patterns have vulnerability + mitigation
- [ ] Guardrails section present
- [ ] Follows AuditFinding schema

---

#### Task B2: Create Database Reviewer Agent

**File:** `.claude/agents/database-reviewer.md` (new)

**Applicability:** `hasDatabase === true`

**Patterns to Detect:**

| Severity | Issue | Vulnerability Pattern | Mitigation Pattern |
|----------|-------|----------------------|-------------------|
| critical | SQL injection | `\$queryRaw\`.*\$\{(?!Prisma)` | Parameterized queries |
| critical | NoSQL injection | `find\(.*\$where` | Sanitize input |
| high | N+1 queries | `for.*await.*find(One\|Unique)` | `include:\|populate` |
| high | Unbounded fetch | `findMany\(\)` without `take:` | Add `take:` limit |
| high | No transaction | Multiple writes without wrapper | `\$transaction` |
| medium | SELECT * | `SELECT \*\|select: undefined` | Select specific fields |
| medium | Missing index | Large table without index | `@@index\|createIndex` |
| low | No soft delete | `delete\(` on user data | `deletedAt` pattern |

**Verification Criteria:**
```bash
# Agent file exists
test -f .claude/agents/database-reviewer.md

# Has required sections
grep -q "## Applicability" .claude/agents/database-reviewer.md
grep -q "## Patterns" .claude/agents/database-reviewer.md

# ID prefix is DB
grep -q 'id.*prefix.*DB' .claude/agents/database-reviewer.md
```

**Definition of Done:**
- [ ] Agent file created with standard structure
- [ ] Covers Prisma, Drizzle, raw SQL patterns
- [ ] Critical patterns for injection
- [ ] Follows AuditFinding schema

---

#### Task B3: Create Infrastructure Reviewer Agent

**File:** `.claude/agents/infrastructure-reviewer.md` (new)

**Applicability:** `hasCI === true OR isServerless === true`

**Patterns to Detect:**

| Severity | Issue | Vulnerability Pattern | Mitigation Pattern |
|----------|-------|----------------------|-------------------|
| high | Secrets in CI | `password:\|api_key:` in workflows | `\$\{\{ secrets\.` |
| high | No health check | API without `/health` | Health endpoint exists |
| high | No rate limiting | API routes without throttle | `rateLimit\|throttle` |
| medium | No error tracking | Missing Sentry/DataDog | `@sentry\|datadog` |
| medium | Cold start risk | Large imports in serverless | Dynamic imports |
| medium | No caching headers | API without Cache-Control | Cache headers present |
| low | No build cache | CI without cache step | `actions/cache` |
| low | Large Docker image | No multi-stage build | Multi-stage Dockerfile |

**Verification Criteria:**
```bash
# Agent file exists
test -f .claude/agents/infrastructure-reviewer.md

# Has required sections
grep -q "## Applicability" .claude/agents/infrastructure-reviewer.md
grep -q "## Patterns" .claude/agents/infrastructure-reviewer.md

# ID prefix is INFRA
grep -q 'id.*prefix.*INFRA' .claude/agents/infrastructure-reviewer.md
```

**Definition of Done:**
- [ ] Agent file created with standard structure
- [ ] Covers GitHub Actions, Vercel, Docker
- [ ] Critical patterns for secrets exposure
- [ ] Follows AuditFinding schema

---

### Phase C: Orchestration Integration

**Purpose:** Wire up the code-reviewer to use conditional selection.

**Dependency:** Phase A complete

#### Task C1: Add Selection Logic to Code Reviewer

**File:** `.claude/agents/code-reviewer.md`

**Input:** codebase-context.json with recommendedReviewers

**Logic:**
```
IF --all flag:
  Run ALL 8 specialists

ELSE IF specific flags (--security, --database):
  Run ONLY specified specialists

ELSE IF preset flag:
  --prelaunch → security, performance, accessibility, seo
  --backend → security, database, testing, infrastructure
  --frontend → performance, accessibility, seo

ELSE (no flags):
  Run recommendedReviewers.always (security, testing)
  Run each in recommendedReviewers.conditional
```

**Verification Criteria:**
```bash
# Selection logic documented
grep -q "recommendedReviewers" .claude/agents/code-reviewer.md
grep -q "\-\-all" .claude/agents/code-reviewer.md
grep -q "\-\-prelaunch" .claude/agents/code-reviewer.md
grep -q "\-\-backend" .claude/agents/code-reviewer.md
grep -q "\-\-frontend" .claude/agents/code-reviewer.md
```

**Definition of Done:**
- [ ] Selection logic documented in agent
- [ ] All presets defined
- [ ] Reads from recommendedReviewers
- [ ] Fallback behavior specified

---

#### Task C2: Update Specialist Count and Workflow

**File:** `.claude/agents/code-reviewer.md`

**Changes:**
- Update workflow diagram to show 8 specialists
- Add SEO, Database, Infrastructure to specialist table
- Document parallel execution of all selected specialists
- Add `agentsSkipped` to report metadata (with reasons)

**Verification Criteria:**
```bash
# Shows 8 specialists
grep -q "seo-reviewer" .claude/agents/code-reviewer.md
grep -q "database-reviewer" .claude/agents/code-reviewer.md
grep -q "infrastructure-reviewer" .claude/agents/code-reviewer.md

# Has ID prefix table with all 8
grep -c "SEO\|DB\|INFRA\|SEC\|PERF\|A11Y\|TS\|TEST" .claude/agents/code-reviewer.md
# Expected: >= 8
```

**Definition of Done:**
- [ ] Workflow diagram updated
- [ ] Specialist table complete (8 rows)
- [ ] agentsSkipped documented
- [ ] Parallel execution specified

---

### Phase D: Command Integration

**Purpose:** Make /code-review invoke the agent-based system.

**Dependency:** Phase C complete

#### Task D1: Slim Down /code-review Command

**File:** `.claude/commands/code-review.md`

**Current:** ~550 lines with detailed bash scripts, checklists, report templates

**Target:** ~80 lines - thin wrapper that:
1. Parses flags (--all, --security, --prelaunch, etc.)
2. Invokes code-reviewer agent with parsed flags
3. Displays formatted results

**Verification Criteria:**
```bash
# File is significantly smaller
wc -l .claude/commands/code-review.md
# Expected: < 150 lines

# Contains agent invocation instruction
grep -q "code-reviewer agent" .claude/commands/code-review.md

# Does NOT contain detailed bash scripts
grep -c "grep -rn" .claude/commands/code-review.md
# Expected: 0 or very few
```

**Definition of Done:**
- [ ] Command reduced to thin wrapper
- [ ] Flag parsing documented
- [ ] Agent invocation specified
- [ ] Old bash scripts removed

---

#### Task D2: Add Deprecation Notices to Old Commands

**Files:** 8 files in `.claude/commands/code-review-*.md`

**Change:** Add deprecation notice to each:
```markdown
> **DEPRECATED:** This command is superseded by the agent-based system.
> Use `/code-review --security` instead.
> This file will be removed in v6.0.
```

**Verification Criteria:**
```bash
# All 8 files have deprecation notice
for f in .claude/commands/code-review-*.md; do
  grep -q "DEPRECATED" "$f" || echo "Missing: $f"
done
# Expected: no output (all have notice)
```

**Definition of Done:**
- [ ] All 8 individual commands have deprecation notice
- [ ] Notice includes replacement command
- [ ] Notice includes removal timeline (v6.0)

---

### Phase E: Schema Updates

**Purpose:** Update schemas to reflect complete system.

**Dependency:** Phase B complete

#### Task E1: Update AuditFinding Category Enum

**File:** `.claude/schemas/audit-finding.json`

**Change:** Add new categories:
```json
"category": {
  "type": "string",
  "enum": ["security", "performance", "accessibility", "typescript", "testing", "seo", "database", "infrastructure"]
}
```

**Verification Criteria:**
```bash
# Schema has all 8 categories
jq '.properties.category.enum | length' .claude/schemas/audit-finding.json
# Expected: 8
```

**Definition of Done:**
- [ ] All 8 categories in enum
- [ ] Schema validates

---

#### Task E2: Update AuditReport Schema

**File:** `.claude/schemas/audit-report.json`

**Changes:**
- Add `projectType` to metadata
- Add `agentsSkipped` array with reasons
- Add `byCategory` breakdown to summary

**Verification Criteria:**
```bash
# New fields present
jq '.properties.metadata.properties | keys' .claude/schemas/audit-report.json | grep -q "projectType"
jq '.properties.metadata.properties | keys' .claude/schemas/audit-report.json | grep -q "agentsSkipped"
```

**Definition of Done:**
- [ ] projectType field added
- [ ] agentsSkipped field added
- [ ] byCategory field added
- [ ] Schema validates

---

### Phase F: Documentation Updates

**Purpose:** Update V5_PLANNING.md and related docs to reflect reality.

**Dependency:** All other phases complete

#### Task F1: Update V5_PLANNING.md Architecture Diagram

**File:** `docs/planning/v5.0/V5_PLANNING.md`

**Changes:**
- Update AGENTS count from 9 to 12 (8 specialists + 4 support)
- Add SEO, Database, Infrastructure to agent list
- Update Appendix C feature comparison

**Verification Criteria:**
```bash
# Shows 12 agents
grep -q "AGENTS (12)" docs/planning/v5.0/V5_PLANNING.md

# Lists all specialists
grep -q "seo-reviewer" docs/planning/v5.0/V5_PLANNING.md
grep -q "database-reviewer" docs/planning/v5.0/V5_PLANNING.md
grep -q "infrastructure-reviewer" docs/planning/v5.0/V5_PLANNING.md
```

**Definition of Done:**
- [ ] Architecture diagram accurate
- [ ] All agents listed
- [ ] Appendix C updated

---

#### Task F2: Update Agent Documentation Index

**File:** `.claude/docs/code-review-guide.md` (if exists) or create

**Content:**
- List all 12 agents with purpose
- Document conditional selection
- Document presets
- Provide usage examples

**Verification Criteria:**
```bash
# All agents documented
grep -c "reviewer" .claude/docs/code-review-guide.md
# Expected: >= 8
```

**Definition of Done:**
- [ ] All 12 agents documented
- [ ] Selection logic explained
- [ ] Examples provided

---

## Part 3: Verification Checklist

### Final System Verification

Run these checks to verify the complete system:

```bash
#!/bin/bash
# v5.0 Code Review Completion Verification

echo "=== Agent Files ==="
AGENTS=(
  "code-reviewer"
  "codebase-scanner"
  "security-reviewer"
  "performance-reviewer"
  "accessibility-reviewer"
  "type-safety-reviewer"
  "test-coverage-reviewer"
  "seo-reviewer"
  "database-reviewer"
  "infrastructure-reviewer"
  "synthesis-agent"
  "audit-compare"
)

for agent in "${AGENTS[@]}"; do
  if [ -f ".claude/agents/${agent}.md" ]; then
    echo "✓ ${agent}"
  else
    echo "✗ ${agent} MISSING"
  fi
done

echo ""
echo "=== Codebase Scanner Output ==="
if [ -f ".claude/cache/codebase-context.json" ]; then
  jq -e '.recommendedReviewers' .claude/cache/codebase-context.json > /dev/null && \
    echo "✓ recommendedReviewers present" || \
    echo "✗ recommendedReviewers MISSING"

  jq -e '.structure.hasDatabase' .claude/cache/codebase-context.json > /dev/null && \
    echo "✓ hasDatabase present" || \
    echo "✗ hasDatabase MISSING"
else
  echo "✗ codebase-context.json not found (run codebase-scanner first)"
fi

echo ""
echo "=== Schema Validation ==="
jq -e '.properties.category.enum | length == 8' .claude/schemas/audit-finding.json > /dev/null && \
  echo "✓ AuditFinding has 8 categories" || \
  echo "✗ AuditFinding categories incomplete"

echo ""
echo "=== Command Integration ==="
LINES=$(wc -l < .claude/commands/code-review.md)
if [ "$LINES" -lt 150 ]; then
  echo "✓ /code-review is thin wrapper ($LINES lines)"
else
  echo "⚠ /code-review may still have old content ($LINES lines)"
fi

echo ""
echo "=== Deprecation Notices ==="
DEPRECATED=0
for f in .claude/commands/code-review-*.md; do
  grep -q "DEPRECATED" "$f" && ((DEPRECATED++))
done
echo "✓ $DEPRECATED/8 commands have deprecation notice"
```

---

## Part 4: Dependency Graph

```
Phase A: Foundation Enhancement
├── A1: Project Characteristic Detection
├── A2: recommendedReviewers Output (depends on A1)
└── A3: Specialized File Lists (depends on A1)

Phase B: New Specialist Agents (parallel with A)
├── B1: SEO Reviewer
├── B2: Database Reviewer
└── B3: Infrastructure Reviewer

Phase C: Orchestration Integration (depends on A)
├── C1: Selection Logic (depends on A2)
└── C2: Update Workflow (depends on B1, B2, B3)

Phase D: Command Integration (depends on C)
├── D1: Slim Down /code-review (depends on C1, C2)
└── D2: Deprecation Notices (independent)

Phase E: Schema Updates (depends on B)
├── E1: AuditFinding Categories
└── E2: AuditReport Schema

Phase F: Documentation (depends on all)
├── F1: Update V5_PLANNING.md
└── F2: Agent Documentation Index

Critical Path: A1 → A2 → C1 → C2 → D1
```

---

## Part 5: Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Old commands still used | High | Medium | Deprecation notices + documentation |
| Conditional selection wrong | Medium | High | Test on all 3 fixture repos |
| New agents have gaps | Medium | Medium | Use command patterns as reference |
| Breaking existing audits | Low | High | Keep old commands functional |

---

## Part 6: Success Criteria

### Minimum Viable Completion

- [ ] 12 agent files exist and have standard structure
- [ ] codebase-scanner outputs recommendedReviewers
- [ ] code-reviewer uses conditional selection
- [ ] /code-review invokes agents
- [ ] All 8 old commands have deprecation notice

### Full Completion

- [ ] All verification scripts pass
- [ ] Tested on all 3 fixture repos
- [ ] V5_PLANNING.md updated
- [ ] Documentation complete

---

*End of V5.0 Code Review Completion Plan*
