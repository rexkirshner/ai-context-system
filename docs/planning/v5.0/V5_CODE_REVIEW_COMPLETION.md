# V5.0 Code Review System Completion Plan

**Version:** 2.0
**Updated:** 2026-01-13
**Status:** Active

---

## Executive Summary

Complete the agent-based code review system that is the core of v5.0. Currently, 5 specialist agents exist but the system lacks 3 specialists, conditional selection, and command integration.

**Current → Target:**
- Specialists: 5 → 8 (add SEO, Database, Infrastructure)
- codebase-scanner: basic → outputs `recommendedReviewers`
- code-reviewer: static → conditional selection based on project type
- /code-review: 550-line monolith → thin wrapper invoking agents

---

## Principles

These principles govern all implementation decisions:

1. **Contracts first.** Define interfaces before building. Components communicate via documented schemas.
2. **Objective verification.** Every task has automated checks using `jq -e` for JSON, not brittle grep.
3. **Golden snapshots.** Expected outputs checked into repo. Drift is detected automatically.
4. **Safe fallback.** If scanner fails or confidence is low, default to security + testing (never no-op).
5. **No bandaids.** Take time to do it right. No quick fixes that become permanent debt.

---

## Part 1: Component Contracts

Define all interfaces upfront. These contracts prevent architectural drift.

### 1.1 codebase-scanner

**Input:** Project root directory

**Output:** `.claude/cache/codebase-context.json`

```json
{
  "schemaVersion": "1.1.0",
  "metadata": {
    "scannedAt": "ISO-8601",
    "commit": "git-sha"
  },
  "structure": {
    "projectType": "webapp|api|cli|library|monorepo",
    "primaryLanguage": "typescript|python|go|rust",
    "frameworks": ["next.js", "prisma"],
    "hasTests": true,
    "hasCI": true,
    "hasDatabase": true,
    "hasUI": true,
    "isServerless": true,
    "isMonorepo": false
  },
  "recommendedReviewers": {
    "always": ["security", "testing"],
    "conditional": [
      { "reviewer": "typescript", "reason": "TypeScript project" }
    ]
  },
  "files": [],
  "securityRelevant": [],
  "databaseFiles": [],
  "uiComponents": [],
  "ciWorkflows": []
}
```

**Exit codes:**
- 0: Success
- 1: Failure (missing project, git error)

**Invariants:**
- `structure.*` fields are always present (use `false` not omission)
- `recommendedReviewers.always` always contains `["security", "testing"]`

---

### 1.2 Specialist Agents (8 total)

**Input:** Path to `codebase-context.json`

**Output:** Array of `AuditFinding` objects (per `.claude/schemas/audit-finding.json`)

**ID Prefixes:**

| Agent | Prefix | Category |
|-------|--------|----------|
| security-reviewer | SEC | security |
| performance-reviewer | PERF | performance |
| accessibility-reviewer | A11Y | accessibility |
| type-safety-reviewer | TS | typescript |
| test-coverage-reviewer | TEST | testing |
| seo-reviewer | SEO | seo |
| database-reviewer | DB | database |
| infrastructure-reviewer | INFRA | infrastructure |

**Invariants:**
- Every finding has `verified` object with pattern searches
- Findings sorted by severity (critical first)

---

### 1.3 code-reviewer (Orchestrator)

**Input:** Flags (`--all`, `--security`, `--prelaunch`, `--incremental`, etc.)

**Output:**
- `docs/audits/audit-YYYY-MM-DD.json` (AuditReport schema)
- `docs/audits/audit-YYYY-MM-DD.md` (human-readable)

**Selection Logic:**

| Input | Specialists Run |
|-------|-----------------|
| `--all` | All 8 |
| `--security` | Only security |
| `--security --database` | security + database |
| `--prelaunch` | security, performance, accessibility, seo |
| `--backend` | security, database, testing, infrastructure |
| `--frontend` | performance, accessibility, seo |
| `--incremental` | Uses `git diff --name-only` to scope (existing V5_PLANNING.md §D.2) |
| (no flags) | `recommendedReviewers.always` + `recommendedReviewers.conditional` |
| (scanner failed) | **Fallback:** security + testing only |

**Exit codes:**
- 0: Completed (findings may exist)
- 1: Tool/execution failure

---

### 1.4 /code-review Command

**Purpose:** Thin wrapper. Parses flags, invokes code-reviewer agent, formats output.

**Must NOT contain:**
- Detailed bash scripts for scanning
- Inline checklists or report templates
- Direct grep/find commands for analysis

**Verification:** Command delegates to agent, doesn't implement logic itself.

---

## Part 2: Golden Snapshots

Expected `recommendedReviewers` output for each fixture repo. These are checked into `test/golden/` and compared on every change.

### 2.1 nextjs-app Fixture

**Project:** Next.js 14 + TypeScript + Prisma + Auth.js

**Expected `recommendedReviewers`:**
```json
{
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
```

**Total reviewers:** 8 (all)

---

### 2.2 python-cli Fixture

**Project:** Python CLI with Click + pytest

**Expected `recommendedReviewers`:**
```json
{
  "always": ["security", "testing"],
  "conditional": []
}
```

**Total reviewers:** 2

---

### 2.3 monorepo Fixture

**Project:** Turborepo with 2 apps, 3 packages

**Expected `recommendedReviewers`:**
```json
{
  "always": ["security", "testing"],
  "conditional": [
    { "reviewer": "typescript", "reason": "TypeScript project" },
    { "reviewer": "infrastructure", "reason": "Has CI workflows" }
  ]
}
```

**Total reviewers:** 4

---

## Part 3: Implementation Tasks

Tasks are atomic and ordered by dependency. Each has objective verification using `jq -e`.

### Phase 1: Scanner Enhancement

#### Task 1.1: Add Project Characteristic Detection

**File:** `.claude/agents/codebase-scanner.md`

**Add detection for:**

| Field | Detection Method |
|-------|------------------|
| `structure.hasDatabase` | prisma/drizzle/typeorm/mongoose/pg/mysql2 in deps |
| `structure.hasUI` | `.tsx`/`.jsx` files exist OR react/vue/svelte in deps |
| `structure.hasCI` | `.github/workflows/` OR `.gitlab-ci.yml` exists |
| `structure.isServerless` | vercel.json OR netlify.toml OR @vercel/* in deps |
| `structure.isMonorepo` | `workspaces` in package.json OR `packages/` dir |

**Verification:**
```bash
# On nextjs-app fixture
jq -e '.structure.hasDatabase == true' .claude/cache/codebase-context.json
jq -e '.structure.hasUI == true' .claude/cache/codebase-context.json
jq -e '.structure.hasCI == true' .claude/cache/codebase-context.json

# On python-cli fixture
jq -e '.structure.hasDatabase == false' .claude/cache/codebase-context.json
jq -e '.structure.hasUI == false' .claude/cache/codebase-context.json
```

**Done when:** All 5 fields present and correct on all 3 fixtures.

---

#### Task 1.2: Add recommendedReviewers Output

**File:** `.claude/agents/codebase-scanner.md`

**Depends on:** Task 1.1

**Logic:**
```
always = ["security", "testing"]

conditional = []
IF structure.primaryLanguage == "typescript": add typescript
IF structure.hasUI: add accessibility, performance
IF structure.hasUI AND structure.projectType == "webapp": add seo
IF structure.hasDatabase: add database
IF structure.hasCI OR structure.isServerless: add infrastructure
```

**Verification:**
```bash
# Structure exists
jq -e '.recommendedReviewers.always | index("security")' .claude/cache/codebase-context.json
jq -e '.recommendedReviewers.always | index("testing")' .claude/cache/codebase-context.json

# Conditional is array
jq -e '.recommendedReviewers.conditional | type == "array"' .claude/cache/codebase-context.json
```

**Done when:** Output matches golden snapshots (Part 2) for all 3 fixtures.

---

#### Task 1.3: Add Specialized File Lists

**File:** `.claude/agents/codebase-scanner.md`

**Depends on:** Task 1.1

**Add fields:**
- `databaseFiles`: Files matching `**/db.ts`, `**/database.ts`, `prisma/schema.prisma`, etc.
- `uiComponents`: Files matching `**/*.tsx`, `**/*.jsx` in `src/`, `components/`, `app/`
- `ciWorkflows`: Files matching `.github/workflows/*.yml`, `.gitlab-ci.yml`

**Verification:**
```bash
# On nextjs-app
jq -e '.databaseFiles | length > 0' .claude/cache/codebase-context.json
jq -e '.uiComponents | length > 0' .claude/cache/codebase-context.json

# On python-cli (should be empty arrays, not missing)
jq -e '.databaseFiles | length == 0' .claude/cache/codebase-context.json
jq -e '.uiComponents | length == 0' .claude/cache/codebase-context.json
```

**Done when:** All 3 lists present (even if empty) on all fixtures.

---

### Phase 2: New Specialist Agents

These can run parallel to Phase 1.

#### Task 2.1: Create seo-reviewer Agent

**File:** `.claude/agents/seo-reviewer.md` (new)

**Applicability:** `structure.projectType == "webapp" AND structure.hasUI == true`

**Patterns:**

| Severity | Issue | Vuln Pattern | Mitigation Pattern |
|----------|-------|--------------|-------------------|
| high | Missing title | `<head>` without `<title>` | `<title>\|Head.*title` |
| high | No meta description | No `meta.*description` | `meta.*name="description"` |
| high | Missing Open Graph | No `og:` tags | `property="og:` |
| medium | No canonical | No `rel="canonical"` | `rel="canonical"` |
| medium | No structured data | No JSON-LD | `application/ld\+json` |
| low | No sitemap | Missing sitemap.xml | File exists |

**Verification:**
```bash
test -f .claude/agents/seo-reviewer.md
grep -q "## Applicability" .claude/agents/seo-reviewer.md
grep -q "## Patterns" .claude/agents/seo-reviewer.md
grep -q "## Guardrails" .claude/agents/seo-reviewer.md
grep -q "SEO-" .claude/agents/seo-reviewer.md  # ID prefix
```

**Done when:** File exists with all required sections.

---

#### Task 2.2: Create database-reviewer Agent

**File:** `.claude/agents/database-reviewer.md` (new)

**Applicability:** `structure.hasDatabase == true`

**Patterns:**

| Severity | Issue | Vuln Pattern | Mitigation Pattern |
|----------|-------|--------------|-------------------|
| critical | SQL injection | `$queryRaw` with `${` interpolation | Parameterized queries |
| high | N+1 queries | `for.*await.*find(One\|Unique)` | `include:\|populate` |
| high | Unbounded fetch | `findMany()` without `take:` | `take:\|limit` |
| high | No transaction | Multiple writes without wrapper | `$transaction` |
| medium | SELECT * | `SELECT *` or no select clause | Specific field selection |
| low | No soft delete | `delete()` on user data | `deletedAt` pattern |

**Verification:**
```bash
test -f .claude/agents/database-reviewer.md
grep -q "## Applicability" .claude/agents/database-reviewer.md
grep -q "## Patterns" .claude/agents/database-reviewer.md
grep -q "DB-" .claude/agents/database-reviewer.md  # ID prefix
```

**Done when:** File exists with all required sections.

---

#### Task 2.3: Create infrastructure-reviewer Agent

**File:** `.claude/agents/infrastructure-reviewer.md` (new)

**Applicability:** `structure.hasCI == true OR structure.isServerless == true`

**Patterns:**

| Severity | Issue | Vuln Pattern | Mitigation Pattern |
|----------|-------|--------------|-------------------|
| high | Secrets in CI | `password:\|api_key:` in workflows | `${{ secrets.` |
| high | No health check | API without `/health` | Health endpoint |
| high | No rate limiting | API without throttle | `rateLimit\|throttle` |
| medium | No error tracking | No Sentry/DataDog | `@sentry\|datadog` |
| medium | No caching | API without Cache-Control | Cache headers |
| low | No build cache | CI without cache step | `actions/cache` |

**Verification:**
```bash
test -f .claude/agents/infrastructure-reviewer.md
grep -q "## Applicability" .claude/agents/infrastructure-reviewer.md
grep -q "## Patterns" .claude/agents/infrastructure-reviewer.md
grep -q "INFRA-" .claude/agents/infrastructure-reviewer.md  # ID prefix
```

**Done when:** File exists with all required sections.

---

### Phase 3: Orchestration

**Depends on:** Phase 1 and Phase 2 complete

#### Task 3.1: Add Selection Logic to code-reviewer

**File:** `.claude/agents/code-reviewer.md`

**Add:**
1. Selection logic table (from Part 1.3)
2. Fallback behavior: If `recommendedReviewers` missing/empty, run security + testing
3. Reference to `--incremental` mode (existing in V5_PLANNING.md Appendix D.2)

**Verification:**
```bash
grep -q "recommendedReviewers" .claude/agents/code-reviewer.md
grep -q "fallback" .claude/agents/code-reviewer.md
grep -q "\-\-all" .claude/agents/code-reviewer.md
grep -q "\-\-prelaunch" .claude/agents/code-reviewer.md
grep -q "\-\-backend" .claude/agents/code-reviewer.md
grep -q "\-\-frontend" .claude/agents/code-reviewer.md
grep -q "\-\-incremental" .claude/agents/code-reviewer.md
```

**Done when:** All flags and fallback documented.

---

#### Task 3.2: Update Specialist Table

**File:** `.claude/agents/code-reviewer.md`

**Update:**
- Workflow diagram to show 8 specialists
- Specialist table with all 8 (add SEO, DB, INFRA rows)
- Add `agentsSkipped` to output metadata

**Verification:**
```bash
grep -q "seo-reviewer" .claude/agents/code-reviewer.md
grep -q "database-reviewer" .claude/agents/code-reviewer.md
grep -q "infrastructure-reviewer" .claude/agents/code-reviewer.md
grep -q "agentsSkipped" .claude/agents/code-reviewer.md
```

**Done when:** All 8 specialists listed.

---

### Phase 4: Command Integration

**Depends on:** Phase 3 complete

#### Task 4.1: Slim /code-review Command

**File:** `.claude/commands/code-review.md`

**Current:** ~550 lines with inline bash, checklists, templates

**Target:** Thin wrapper that:
1. Documents available flags
2. Instructs to invoke code-reviewer agent
3. Formats output

**Verification:**
```bash
# Delegates to agent
grep -q "code-reviewer agent" .claude/commands/code-review.md

# Does NOT contain inline analysis logic
! grep -q "grep -rn" .claude/commands/code-review.md
! grep -q "find app -name" .claude/commands/code-review.md

# No embedded OWASP checklists
! grep -q "A01: Broken Access" .claude/commands/code-review.md
```

**Done when:** Command delegates to agent without implementing analysis logic.

---

#### Task 4.2: Add Deprecation Notices

**Files:** 8 files in `.claude/commands/code-review-*.md`

**Add to each:**
```markdown
> **DEPRECATED:** This command is superseded by the agent-based system.
> Use `/code-review --{type}` instead.
> This file will be removed in v6.0.
```

**Verification:**
```bash
# Count files with deprecation notice
DEPRECATED=$(grep -l "DEPRECATED" .claude/commands/code-review-*.md 2>/dev/null | wc -l)
[ "$DEPRECATED" -eq 8 ]
```

**Done when:** All 8 individual commands have deprecation notice.

---

### Phase 5: Schema Updates

**Depends on:** Phase 2 complete (need to know all categories)

#### Task 5.1: Update AuditFinding Schema

**File:** `.claude/schemas/audit-finding.json`

**Change:** Update category enum to include all 8:
```json
"category": {
  "enum": ["security", "performance", "accessibility", "typescript", "testing", "seo", "database", "infrastructure"]
}
```

**Verification:**
```bash
jq -e '.properties.category.enum | length == 8' .claude/schemas/audit-finding.json
jq -e '.properties.category.enum | index("seo")' .claude/schemas/audit-finding.json
jq -e '.properties.category.enum | index("database")' .claude/schemas/audit-finding.json
jq -e '.properties.category.enum | index("infrastructure")' .claude/schemas/audit-finding.json
```

**Done when:** Schema has all 8 categories.

---

#### Task 5.2: Update AuditReport Schema

**File:** `.claude/schemas/audit-report.json`

**Add fields:**
- `metadata.projectType`: string
- `metadata.agentsSkipped`: array of `{ agent: string, reason: string }`

**Verification:**
```bash
jq -e '.properties.metadata.properties.projectType' .claude/schemas/audit-report.json
jq -e '.properties.metadata.properties.agentsSkipped' .claude/schemas/audit-report.json
```

**Done when:** New fields present in schema.

---

### Phase 6: Documentation

**Depends on:** All other phases complete

#### Task 6.1: Update V5_PLANNING.md

**File:** `docs/planning/v5.0/V5_PLANNING.md`

**Changes:**
- Update AGENTS count: 9 → 12 (8 specialists + 4 support)
- Add seo-reviewer, database-reviewer, infrastructure-reviewer to list
- Update Appendix C feature comparison

**Verification:**
```bash
grep -q "AGENTS (12)" docs/planning/v5.0/V5_PLANNING.md
grep -q "seo-reviewer" docs/planning/v5.0/V5_PLANNING.md
grep -q "database-reviewer" docs/planning/v5.0/V5_PLANNING.md
grep -q "infrastructure-reviewer" docs/planning/v5.0/V5_PLANNING.md
```

**Done when:** Document reflects actual agent count.

---

#### Task 6.2: Create Golden Snapshot Files

**Files:**
- `test/golden/recommended-reviewers-nextjs-app.json`
- `test/golden/recommended-reviewers-python-cli.json`
- `test/golden/recommended-reviewers-monorepo.json`

**Content:** As specified in Part 2.

**Verification:**
```bash
test -f test/golden/recommended-reviewers-nextjs-app.json
test -f test/golden/recommended-reviewers-python-cli.json
test -f test/golden/recommended-reviewers-monorepo.json

# Valid JSON
jq -e '.' test/golden/recommended-reviewers-nextjs-app.json > /dev/null
```

**Done when:** All 3 golden files exist and contain valid JSON.

---

## Part 4: Verification Script

Save as `scripts/tests/test-code-review-completion.sh`:

```bash
#!/bin/bash
set -e

echo "=== V5.0 Code Review Completion Verification ==="
echo ""

PASS=0
FAIL=0

check() {
  if eval "$1" > /dev/null 2>&1; then
    echo "✓ $2"
    ((PASS++))
  else
    echo "✗ $2"
    ((FAIL++))
  fi
}

echo "--- Agent Files (12 expected) ---"
AGENTS="code-reviewer codebase-scanner security-reviewer performance-reviewer accessibility-reviewer type-safety-reviewer test-coverage-reviewer seo-reviewer database-reviewer infrastructure-reviewer synthesis-agent audit-compare"
for agent in $AGENTS; do
  check "test -f .claude/agents/${agent}.md" "$agent exists"
done

echo ""
echo "--- Schema Updates ---"
check "jq -e '.properties.category.enum | length == 8' .claude/schemas/audit-finding.json" "AuditFinding has 8 categories"
check "jq -e '.properties.metadata.properties.agentsSkipped' .claude/schemas/audit-report.json" "AuditReport has agentsSkipped"

echo ""
echo "--- Golden Snapshots ---"
check "test -f test/golden/recommended-reviewers-nextjs-app.json" "nextjs-app snapshot exists"
check "test -f test/golden/recommended-reviewers-python-cli.json" "python-cli snapshot exists"
check "test -f test/golden/recommended-reviewers-monorepo.json" "monorepo snapshot exists"

echo ""
echo "--- Command Integration ---"
check "grep -q 'code-reviewer agent' .claude/commands/code-review.md" "/code-review delegates to agent"
check "! grep -q 'A01: Broken Access' .claude/commands/code-review.md" "/code-review has no inline checklists"

echo ""
echo "--- Deprecation Notices ---"
DEPRECATED=$(grep -l "DEPRECATED" .claude/commands/code-review-*.md 2>/dev/null | wc -l | tr -d ' ')
check "[ '$DEPRECATED' -eq 8 ]" "All 8 old commands deprecated ($DEPRECATED/8)"

echo ""
echo "=== Summary ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

[ "$FAIL" -eq 0 ] && echo "✅ ALL CHECKS PASSED" || echo "❌ SOME CHECKS FAILED"
exit $FAIL
```

---

## Part 5: Task Dependency Graph

```
Phase 1: Scanner Enhancement
  1.1 Project Characteristics ─┬─→ 1.2 recommendedReviewers ─→ Phase 3
                               └─→ 1.3 File Lists

Phase 2: New Specialists (parallel with Phase 1)
  2.1 seo-reviewer ────┐
  2.2 database-reviewer ├─→ Phase 3, Phase 5
  2.3 infrastructure-reviewer ─┘

Phase 3: Orchestration (depends on 1.2, 2.*)
  3.1 Selection Logic ─┬─→ Phase 4
  3.2 Specialist Table ┘

Phase 4: Command Integration (depends on 3.*)
  4.1 Slim /code-review
  4.2 Deprecation Notices (independent)

Phase 5: Schema Updates (depends on 2.*)
  5.1 AuditFinding Categories
  5.2 AuditReport Schema

Phase 6: Documentation (depends on all)
  6.1 Update V5_PLANNING.md
  6.2 Create Golden Snapshots

Critical Path: 1.1 → 1.2 → 3.1 → 4.1
```

---

## Part 6: Success Criteria

**Complete when ALL of the following are true:**

1. `scripts/tests/test-code-review-completion.sh` passes (0 failures)
2. Golden snapshots match actual scanner output on all 3 fixtures
3. `/code-review` invokes agents, not inline logic
4. All 8 old commands have deprecation notices

---

*End of V5.0 Code Review Completion Plan*
