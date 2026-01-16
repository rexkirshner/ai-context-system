# v4.0.0 Upgrade Plan - Modular Code Review System

**Created**: 2026-01-05
**Updated**: 2026-01-05
**Status**: IN PROGRESS - Phases 1-2 Complete
**Philosophy**: Specialized depth over generic breadth. Standalone audits. Clear organization.

---

## Decisions Made

- **Version**: 4.0.0 (major release - significant architectural change)
- **Checklists**: Fully integrate into commands, then delete `.claude/checklists/`
- **Legacy support**: None - clean break from old monolithic behavior

---

## Overview

This release transforms `/code-review` from a monolithic command into a modular system of specialized audits. Each audit goes deep into one domain, produces standalone reports, and can be run independently or orchestrated via a master command.

### Key Changes

1. **Modular commands** - 8 specialized audit commands + 1 master orchestrator
2. **New output location** - `docs/audits/` replaces `artifacts/code-reviews/`
3. **Incrementing naming** - `{type}-audit-NN.md` instead of session-based
4. **Platform flags** - Generic commands with platform-specific flags
5. **Standalone reports** - No automatic context system integration
6. **Build gate** - Separate `/build-check` command for pre-push validation

### Source Requirements

Based on real-world audit prompts:
- Prisma/Postgres efficiency audit (database costs, N+1, indexes)
- Vercel efficiency audit (serverless costs, invocations, caching)
- Technical SEO audit (crawlability, metadata, structured data)
- TypeScript build check (pre-push type safety)

---

## Concurrent Implementation with v3.7.0

This plan can be implemented concurrently with v3.7.0 (Friction Reduction). See [Concurrent Implementation Roadmap](#concurrent-implementation-roadmap) at the end of this document.

**Shared Resources:**
- Both plans modify `scripts/common-functions.sh` (no conflicts - different functions)
- Both plans modify VERSION and CHANGELOG.md at release time

**Dependencies:**
- v4.0.0 should be released AFTER v3.7.0
- v4.0.0 Phases 1-12 can be developed in parallel with v3.7.0

---

## Phase 1: Directory Structure & Migration ✅ COMPLETE

**Goal**: Establish new `docs/audits/` structure and migrate existing files
**Risk**: Low
**Value**: Foundation for all subsequent phases

### Checkpoint 1.1: Create directory structure ✅ COMPLETE

- [x] Create `docs/audits/` directory
- [x] Create `docs/audits/archive/` directory
- [x] Create `docs/audits/archive/pre-v4.0.0-migration/` for migration
- [x] Create `docs/audits/INDEX.md` template

**Deliverable**: Directory structure in place ✅

**Verification:** All passing
```bash
# All directories exist
[ -d "docs/audits" ] && echo "PASS" || echo "FAIL"
[ -d "docs/audits/archive" ] && echo "PASS" || echo "FAIL"
[ -d "docs/audits/archive/pre-v4.0.0-migration" ] && echo "PASS" || echo "FAIL"
```

### Checkpoint 1.2: Create INDEX.md template ✅ COMPLETE

```markdown
# Audit History

Track all code audits for this project.

## Recent Audits

| Date | Type | File | Grade | Key Findings |
|------|------|------|-------|--------------|
| YYYY-MM-DD | Security | security-audit-01.md | B+ | 2 high, 5 medium |

## Audit Types

- **Security** - OWASP, auth, input validation, secrets
- **Performance** - Core Web Vitals, bundle, runtime
- **Accessibility** - WCAG compliance
- **SEO** - Technical SEO, metadata, structured data
- **Database** - Query optimization, indexes, N+1
- **Infrastructure** - Serverless costs, caching, builds
- **TypeScript** - Type safety, strictness
- **Testing** - Coverage, quality
- **Comprehensive** - All of the above

## Archive

Historical audits from previous versions are in `archive/`.
```

**Deliverable**: `templates/audits-index.template.md` ✅

**Verification:**
- [x] Template file exists at `templates/audits-index.template.md`
- [x] Template contains all 9 audit types listed
- [x] Template has table structure for recent audits

### Checkpoint 1.3: Migration logic for /update-context-system ✅ COMPLETE

- [x] Add migration step to detect `artifacts/code-reviews/`
- [x] Move all files to `docs/audits/archive/pre-v4.0.0-migration/`
- [x] Create `docs/audits/INDEX.md` if not exists
- [x] Remove empty `artifacts/code-reviews/` directory
- [x] Display migration summary

```bash
# Migration logic
if [ -d "artifacts/code-reviews" ] && [ "$(ls -A artifacts/code-reviews 2>/dev/null)" ]; then
  echo "📦 Migrating code review artifacts..."
  mkdir -p docs/audits/archive/pre-v4.0.0-migration
  mv artifacts/code-reviews/* docs/audits/archive/pre-v4.0.0-migration/
  rmdir artifacts/code-reviews 2>/dev/null || true
  echo "✅ Migrated to docs/audits/archive/pre-v4.0.0-migration/"
fi
```

**Deliverable**: Migration logic in `update-context-system.md` ✅

**Verification:**
```bash
# Test: Create mock old structure
mkdir -p /tmp/test-project/artifacts/code-reviews
echo "old review" > /tmp/test-project/artifacts/code-reviews/review-1.md
cd /tmp/test-project

# Run migration (simulate)
# After migration:
[ -f "docs/audits/archive/pre-v4.0.0-migration/review-1.md" ] && echo "PASS" || echo "FAIL"
[ ! -d "artifacts/code-reviews" ] && echo "PASS" || echo "FAIL"
```

### Checkpoint 1.4: Update .gitignore if needed ✅ COMPLETE

- [x] Ensure `docs/audits/` is NOT gitignored (audits should be tracked)
- [x] Remove any `artifacts/code-reviews` entries if present
- [x] Added .gitkeep files to preserve empty directories

**Deliverable**: Updated `.gitignore` handling ✅

**Verification:**
- [x] `docs/audits/` is NOT in .gitignore
- [x] Running `git status` shows `docs/audits/` files as trackable

---

## Phase 2: Shared Infrastructure ✅ COMPLETE

**Goal**: Create shared utilities for all audit commands
**Risk**: Low
**Value**: Consistency across all audits

### Checkpoint 2.1: Audit naming helper ✅ COMPLETE

- [x] Add `get_next_audit_number()` function to `scripts/common-functions.sh`
- [x] Function signature: `get_next_audit_number <audit_type> <directory>`
- [x] Returns next available number (01, 02, 03...)
- [x] Handles gaps (if 01, 03 exist, returns 04)

```bash
get_next_audit_number() {
  local audit_type="$1"
  local directory="${2:-docs/audits}"
  local max=0

  for file in "$directory/${audit_type}-audit-"*.md; do
    if [ -f "$file" ]; then
      num=$(echo "$file" | grep -oE '[0-9]+' | tail -1)
      [ "$num" -gt "$max" ] && max="$num"
    fi
  done

  printf "%02d" $((max + 1))
}
```

**Deliverable**: Function in `scripts/common-functions.sh` ✅

**Verification:** All tests passing
```bash
source scripts/common-functions.sh

# Test 1: Empty directory returns 01
mkdir -p /tmp/test-audits
result=$(get_next_audit_number "security" "/tmp/test-audits")
[ "$result" = "01" ] && echo "PASS" || echo "FAIL: got $result"

# Test 2: With existing files returns next number
touch /tmp/test-audits/security-audit-01.md
touch /tmp/test-audits/security-audit-02.md
result=$(get_next_audit_number "security" "/tmp/test-audits")
[ "$result" = "03" ] && echo "PASS" || echo "FAIL: got $result"

# Test 3: Different type is independent
result=$(get_next_audit_number "performance" "/tmp/test-audits")
[ "$result" = "01" ] && echo "PASS" || echo "FAIL: got $result"

# Test 4: Handles gaps (01, 03 -> returns 04)
touch /tmp/test-audits/database-audit-01.md
touch /tmp/test-audits/database-audit-03.md
result=$(get_next_audit_number "database" "/tmp/test-audits")
[ "$result" = "04" ] && echo "PASS" || echo "FAIL: got $result"

rm -rf /tmp/test-audits
```

### Checkpoint 2.2: Audit report header template ✅ COMPLETE

- [x] Create standard header format for all audits
- [x] Include: Date, Repository, Auditor, Type, Platform (if applicable)

```markdown
# [Type] Audit ([NN])

| Field | Value |
|-------|-------|
| Date | YYYY-MM-DD |
| Repository | [name] |
| Auditor | Claude Code |
| Type | [Security/Performance/etc.] |
| Platform | [Vercel/Prisma/etc. or N/A] |
| Duration | [time spent] |

**Constraints:** Read-only audit. No modifications made.
```

**Deliverable**: Header template section documented in each command ✅

**Verification:**
- [x] Header format documented in shared location or each command
- [x] All required fields are listed
- [x] "Constraints" line is present

### Checkpoint 2.3: Audit INDEX.md updater ✅ COMPLETE

- [x] Add `update_audit_index()` function
- [x] Appends new audit entry to INDEX.md
- [x] Creates INDEX.md if not exists

**Deliverable**: Function in `scripts/common-functions.sh` ✅

**Verification:**
```bash
source scripts/common-functions.sh

# Test: Updates INDEX.md
mkdir -p /tmp/test-audits
cp templates/audits-index.template.md /tmp/test-audits/INDEX.md

update_audit_index "/tmp/test-audits" "Security" "security-audit-01.md" "B+" "2 high, 5 medium"

# Should have new entry in table
grep "security-audit-01.md" /tmp/test-audits/INDEX.md && echo "PASS" || echo "FAIL"

rm -rf /tmp/test-audits
```

### Checkpoint 2.4: Platform detection helpers ✅ COMPLETE

- [x] Add `detect_database_platform()` - returns prisma|drizzle|typeorm|sequelize|knex|raw|unknown
- [x] Add `detect_hosting_platform()` - returns vercel|aws|cloudflare|netlify|railway|fly|unknown
- [x] Add `detect_framework()` - returns nextjs|remix|astro|nuxt|sveltekit|vite|express|unknown

**Implementation Notes (2026-01-05):**
- Platform detection checks for config files first (prisma/schema.prisma, vercel.json, etc.)
- Falls back to package.json dependency scanning
- All functions return "unknown" if no platform detected

```bash
detect_database_platform() {
  [ -f "prisma/schema.prisma" ] && echo "prisma" && return
  grep -q "drizzle" package.json 2>/dev/null && echo "drizzle" && return
  grep -q "typeorm" package.json 2>/dev/null && echo "typeorm" && return
  echo "unknown"
}
```

**Deliverable**: Functions in `scripts/common-functions.sh`

**Verification:**
```bash
source scripts/common-functions.sh

# Test: Prisma detection
mkdir -p /tmp/test-project/prisma
touch /tmp/test-project/prisma/schema.prisma
cd /tmp/test-project
result=$(detect_database_platform)
[ "$result" = "prisma" ] && echo "PASS" || echo "FAIL: got $result"

# Test: Vercel detection
echo '{"dependencies":{"@vercel/analytics":"1.0"}}' > package.json
result=$(detect_hosting_platform)
[ "$result" = "vercel" ] && echo "PASS" || echo "FAIL: got $result"

# Test: Next.js detection
echo '{"dependencies":{"next":"14.0"}}' > package.json
result=$(detect_framework)
[ "$result" = "nextjs" ] && echo "PASS" || echo "FAIL: got $result"

rm -rf /tmp/test-project
```

---

## Phase 3: Master Command (`/code-review`)

**Goal**: Interactive orchestrator that runs selected audits
**Risk**: Medium
**Value**: High - single entry point for all reviews
**Dependency**: Requires Phases 4-12 completed first

### Checkpoint 3.1: Create interactive selection UI

- [ ] Display checklist of available audits
- [ ] Support "All" selection
- [ ] Show brief description of each audit type
- [ ] Allow multiple selections

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 Code Review - Select Audits to Run
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Which audits would you like to run?

[ ] All (comprehensive - runs all audits)
─────────────────────────────────────────
[ ] Security        OWASP, auth, secrets, input validation
[ ] Performance     Core Web Vitals, bundle size, runtime
[ ] Accessibility   WCAG compliance, keyboard nav, screen readers
[ ] SEO             Metadata, structured data, crawlability
[ ] Database        Query optimization, N+1, indexes, caching
[ ] Infrastructure  Serverless costs, invocations, caching
[ ] TypeScript      Type safety, strictness, any usage
[ ] Testing         Coverage gaps, test quality

Enter selections (comma-separated, e.g., "1,3,5" or "all"):
```

**Deliverable**: Interactive selection in `/code-review` command

**Verification:**
- [ ] Run `/code-review` - selection UI appears
- [ ] Can select individual audits
- [ ] Can select "all"
- [ ] Selection is parsed correctly

### Checkpoint 3.2: Sequential audit execution

- [ ] Run selected audits in sequence
- [ ] Pass any flags to sub-commands
- [ ] Collect results from each
- [ ] Handle failures gracefully (continue with others)

**Deliverable**: Orchestration logic in `/code-review`

**Verification:**
- [ ] Select 2-3 audits, all run in sequence
- [ ] If one audit fails, others still run
- [ ] Flags passed through (e.g., `--prisma`)

### Checkpoint 3.3: Comprehensive report generation

- [ ] Create `comprehensive-audit-NN.md` when running multiple
- [ ] Reference individual audit files (don't duplicate)
- [ ] Include executive summary aggregating all findings
- [ ] Show combined grade/score

```markdown
# Comprehensive Audit (01)

| Field | Value |
|-------|-------|
| Date | 2026-01-05 |
| Audits Run | Security, Performance, Database |
| Overall Grade | B |

## Executive Summary

Ran 3 specialized audits. Key findings:
- **Security**: 2 high priority issues (see security-audit-03.md)
- **Performance**: LCP needs improvement (see performance-audit-02.md)
- **Database**: 5 N+1 patterns detected (see database-audit-01.md)

## Individual Audit Reports

| Type | File | Grade | Critical | High | Medium |
|------|------|-------|----------|------|--------|
| Security | [security-audit-03.md](./security-audit-03.md) | B+ | 0 | 2 | 4 |
| Performance | [performance-audit-02.md](./performance-audit-02.md) | B | 0 | 1 | 6 |
| Database | [database-audit-01.md](./database-audit-01.md) | C+ | 1 | 3 | 5 |

## Prioritized Actions (All Audits)

1. [CRITICAL] Fix N+1 in user dashboard query (database-audit-01.md)
2. [HIGH] Add rate limiting to auth endpoints (security-audit-03.md)
3. [HIGH] Optimize LCP hero image (performance-audit-02.md)
...
```

**Deliverable**: Comprehensive report template and generation logic

**Verification:**
- [ ] Run `/code-review` with 3 audits selected
- [ ] `comprehensive-audit-01.md` created
- [ ] File contains links to individual audit files
- [ ] Executive summary aggregates key findings
- [ ] INDEX.md updated with comprehensive entry

---

## Phase 4: Security Audit (`/code-review-security`)

**Goal**: Deep OWASP-style security audit
**Risk**: Low
**Value**: High

### Checkpoint 4.1: Create command file

- [ ] Create `.claude/commands/code-review-security.md`
- [ ] Port relevant content from existing `code-review.md`
- [ ] Expand with deeper security checks from `.claude/checklists/security.md`
- [ ] Add report template

**Audit scope:**
- Input validation (all entry points)
- SQL injection (query analysis)
- XSS (output encoding, CSP)
- Authentication flows
- Authorization checks
- Session management
- Secrets detection
- Dependency vulnerabilities
- CORS configuration
- Rate limiting

**Deliverable**: `.claude/commands/code-review-security.md`

**Verification:**
- [ ] Command file exists
- [ ] Run `/code-review-security` on test project
- [ ] Report created at `docs/audits/security-audit-01.md`
- [ ] Report has standard header
- [ ] Report covers all OWASP Top 10 categories
- [ ] INDEX.md updated

### Checkpoint 4.2: Verify incrementing naming

- [ ] Run `/code-review-security` again
- [ ] Creates `security-audit-02.md` (not 01)
- [ ] Both audits listed in INDEX.md

**Verification:**
```bash
# After running twice:
[ -f "docs/audits/security-audit-01.md" ] && echo "PASS" || echo "FAIL"
[ -f "docs/audits/security-audit-02.md" ] && echo "PASS" || echo "FAIL"
grep -c "security-audit" docs/audits/INDEX.md  # Should be 2
```

---

## Phase 5: Performance Audit (`/code-review-performance`)

**Goal**: Deep performance analysis
**Risk**: Low
**Value**: High

### Checkpoint 5.1: Create command file

- [ ] Create `.claude/commands/code-review-performance.md`
- [ ] Port from existing checklist
- [ ] Add deeper analysis for:
  - Core Web Vitals (LCP, FID/INP, CLS)
  - Bundle analysis
  - Image optimization
  - Caching strategy
  - Runtime performance
  - Memory leaks
  - Network waterfall

**Deliverable**: `.claude/commands/code-review-performance.md`

**Verification:**
- [ ] Command file exists
- [ ] Run `/code-review-performance` on test project
- [ ] Report created at `docs/audits/performance-audit-01.md`
- [ ] Report includes Core Web Vitals section
- [ ] Report includes bundle analysis section
- [ ] INDEX.md updated

---

## Phase 6: Database Audit (`/code-review-database`)

**Goal**: Deep database efficiency audit (from Prisma prompt)
**Risk**: Low
**Value**: High

### Checkpoint 6.1: Create command file ✅ COMPLETE

- [x] Create `.claude/commands/code-review-database.md`
- [x] Support flags: `--prisma`, `--drizzle`, `--typeorm`, `--raw`
- [x] Auto-detect platform if no flag provided
- [x] Include all patterns from user's Prisma audit prompt

**Audit scope (from user's prompt):**
- Query efficiency (N+1, overfetching, missing select)
- Schema & indexes (missing indexes, compound indexes)
- Connection management (pooling, singleton pattern)
- Caching opportunities (request-scoped, app-level)
- Platform-specific patterns:
  - Prisma: `findMany`, `include` chains, `$queryRaw`
  - Drizzle: Query builder patterns
  - Raw: Parameterized queries, prepared statements

**Report sections:**
1. Executive Summary (top 5 cost drivers)
2. Query Efficiency Findings
3. Schema & Index Findings
4. Connection Management
5. Caching Opportunities
6. Prioritized Actions

**Deliverable**: `.claude/commands/code-review-database.md` ✅

**Verification:**
- [x] Command file exists
- [ ] Run `/code-review-database` on Prisma project
- [ ] Report created at `docs/audits/database-audit-01.md`
- [ ] Platform auto-detected as "prisma"
- [ ] Run `/code-review-database --drizzle` on Drizzle project
- [ ] Platform shows as "drizzle"
- [ ] INDEX.md updated

**Implementation Notes (2026-01-05):**
- Created comprehensive database audit command with 10 execution steps
- Supports Prisma, Drizzle, TypeORM, and raw SQL platforms
- Auto-detection via `detect_database_platform()` helper function
- Fixed glob pattern issue in `get_next_audit_number()` for empty directories
- Report template includes: executive summary, query efficiency, schema analysis, connection management, caching opportunities

---

## Phase 7: Infrastructure Audit (`/code-review-infrastructure`)

**Goal**: Serverless/hosting cost optimization (from Vercel prompt)
**Risk**: Low
**Value**: High

### Checkpoint 7.1: Create command file

- [ ] Create `.claude/commands/code-review-infrastructure.md`
- [ ] Support flags: `--vercel`, `--aws`, `--cloudflare`, `--netlify`
- [ ] Auto-detect platform if no flag provided
- [ ] Include all patterns from user's Vercel audit prompt

**Audit scope (from user's prompt):**
- Runtime analysis (slow handlers, cold starts)
- Invocation patterns (chatty endpoints, polling)
- Bandwidth (large responses, compression)
- Build pipeline (caching, dependencies)
- Asset optimization (images, media)
- Rendering strategy (SSR vs SSG vs ISR)
- External calls (timeouts, retries)
- Logging overhead

**Report sections:**
1. Executive Summary
2. Cost Surface Inventory
3. Findings (with severity, cost driver, evidence)
4. Cross-Cutting Recommendations
5. Measurement Plan

**Deliverable**: `.claude/commands/code-review-infrastructure.md`

**Verification:**
- [ ] Command file exists
- [ ] Run `/code-review-infrastructure` on Vercel project
- [ ] Report created at `docs/audits/infrastructure-audit-01.md`
- [ ] Platform auto-detected as "vercel"
- [ ] Cost Surface Inventory section present
- [ ] INDEX.md updated

---

## Phase 8: SEO Audit (`/code-review-seo`)

**Goal**: Technical SEO audit (from user's prompt)
**Risk**: Low
**Value**: Medium

### Checkpoint 8.1: Create command file

- [ ] Create `.claude/commands/code-review-seo.md`
- [ ] Replace existing `.claude/checklists/seo-review.md` approach
- [ ] Include all patterns from user's SEO audit prompt

**Audit scope (from user's prompt):**
- Crawlability & indexability (robots.txt, sitemap, canonicals)
- Metadata (title, description, OG, Twitter cards)
- Structured data (JSON-LD)
- Content architecture (headings, breadcrumbs, internal links)
- Performance (SEO-relevant)
- Accessibility (SEO-adjacent)
- Technical hygiene (broken links, 404s, redirects)

**Report sections:**
1. Header (framework, rendering mode)
2. Executive Summary
3. Methodology
4. Findings Table (prioritized)
5. Detailed Recommendations
6. Decisions Needed
7. Implementation Roadmap

**Deliverable**: `.claude/commands/code-review-seo.md`

**Verification:**
- [ ] Command file exists
- [ ] Run `/code-review-seo` on test project
- [ ] Report created at `docs/audits/seo-audit-01.md`
- [ ] Report includes metadata analysis
- [ ] Report includes structured data section
- [ ] INDEX.md updated

---

## Phase 9: Accessibility Audit (`/code-review-accessibility`)

**Goal**: WCAG compliance audit
**Risk**: Low
**Value**: Medium

### Checkpoint 9.1: Create command file

- [ ] Create `.claude/commands/code-review-accessibility.md`
- [ ] Expand from existing checklist
- [ ] WCAG 2.1 AA compliance focus

**Audit scope:**
- Perceivable (text alternatives, captions, contrast)
- Operable (keyboard, timing, seizures, navigation)
- Understandable (readable, predictable, input assistance)
- Robust (parsing, name/role/value)

**Deliverable**: `.claude/commands/code-review-accessibility.md`

**Verification:**
- [ ] Command file exists
- [ ] Run `/code-review-accessibility` on test project
- [ ] Report created at `docs/audits/accessibility-audit-01.md`
- [ ] Report organized by WCAG principles (POUR)
- [ ] INDEX.md updated

---

## Phase 10: TypeScript Audit (`/code-review-typescript`)

**Goal**: Type safety and strictness audit
**Risk**: Low
**Value**: Medium

### Checkpoint 10.1: Create command file

- [ ] Create `.claude/commands/code-review-typescript.md`
- [ ] Analyze tsconfig.json settings
- [ ] Find `any` usage patterns
- [ ] Check type coverage
- [ ] Identify unsafe type assertions

**Audit scope:**
- tsconfig strictness (strict, noImplicitAny, strictNullChecks)
- `any` usage (explicit and implicit)
- Type assertions (`as`, `!`)
- Generic constraints
- Utility type usage
- Error handling types

**Deliverable**: `.claude/commands/code-review-typescript.md`

**Verification:**
- [ ] Command file exists
- [ ] Run `/code-review-typescript` on TypeScript project
- [ ] Report created at `docs/audits/typescript-audit-01.md`
- [ ] Report lists tsconfig.json analysis
- [ ] Report lists `any` usage count and locations
- [ ] INDEX.md updated

---

## Phase 11: Testing Audit (`/code-review-testing`)

**Goal**: Test coverage and quality audit
**Risk**: Low
**Value**: Medium

### Checkpoint 11.1: Create command file

- [ ] Create `.claude/commands/code-review-testing.md`
- [ ] Analyze test coverage
- [ ] Identify untested critical paths
- [ ] Assess test quality

**Audit scope:**
- Coverage metrics (lines, branches, functions)
- Critical path coverage (auth, payments, data mutations)
- Test quality (assertions, edge cases, mocking)
- Test organization (naming, structure)
- Missing test types (unit, integration, e2e)

**Deliverable**: `.claude/commands/code-review-testing.md`

**Verification:**
- [ ] Command file exists
- [ ] Run `/code-review-testing` on project with tests
- [ ] Report created at `docs/audits/testing-audit-01.md`
- [ ] Report identifies coverage gaps
- [ ] Report assesses test quality
- [ ] INDEX.md updated

---

## Phase 12: Build Check (`/build-check`)

**Goal**: Pre-push build validation gate
**Risk**: Low
**Value**: High

### Checkpoint 12.1: Create command file

- [ ] Create `.claude/commands/build-check.md`
- [ ] Detect build command from package.json
- [ ] Run build and capture output
- [ ] Parse and display errors
- [ ] Provide fix suggestions for common errors

**Flow:**
1. Detect framework and build command
2. Run build (`npm run build`, `pnpm build`, etc.)
3. If success: "✅ Build passed - safe to push"
4. If failure: Parse errors, show locations, suggest fixes

**Deliverable**: `.claude/commands/build-check.md`

**Verification:**
- [ ] Command file exists
- [ ] Run `/build-check` on passing project → "Build passed" message
- [ ] Run `/build-check` on failing project → errors listed with locations
- [ ] Detects npm/pnpm/yarn correctly

---

## Phase 13: Update Existing Command

**Goal**: Refactor existing `/code-review` to be the master orchestrator
**Risk**: Medium (breaking change to existing behavior)
**Value**: Required for system to work
**Dependency**: Requires Phases 4-12 completed

### Checkpoint 13.1: Replace old behavior (clean break)

- [ ] Remove old monolithic code-review logic entirely
- [ ] No legacy flag or backward compatibility
- [ ] Document breaking change clearly in CHANGELOG

**Verification:**
- [ ] Old `/code-review` monolithic behavior no longer available
- [ ] CHANGELOG documents breaking change

### Checkpoint 13.2: Implement new orchestrator

- [ ] Replace existing content with master command logic
- [ ] Interactive selection UI
- [ ] Sequential execution of selected audits
- [ ] Comprehensive report generation

**Deliverable**: Refactored `.claude/commands/code-review.md`

**Verification:**
- [ ] `/code-review` shows interactive selection UI
- [ ] Can select and run multiple audits
- [ ] Comprehensive report generated when multiple selected

---

## Phase 14: Documentation & Migration

**Goal**: Document new system and provide migration path
**Risk**: Low
**Value**: Required for adoption

### Checkpoint 14.1: Update command philosophy

- [ ] Add section on modular audit system
- [ ] Explain when to use each audit type
- [ ] Document report structure

**Deliverable**: Updated `.claude/docs/command-philosophy.md`

**Verification:**
- [ ] "Modular Audit System" section exists
- [ ] Each audit type has guidance on when to use

### Checkpoint 14.2: Create audit guide

- [ ] Create `.claude/docs/audit-guide.md`
- [ ] Explain each audit type in detail
- [ ] Provide examples and use cases
- [ ] Document flags and options

**Deliverable**: `.claude/docs/audit-guide.md`

**Verification:**
- [ ] File exists
- [ ] All 8 audit types documented
- [ ] Platform flags documented
- [ ] Examples provided

### Checkpoint 14.3: Migration instructions

- [ ] Document in CHANGELOG.md
- [ ] Add to update-context-system migration step
- [ ] Explain directory changes
- [ ] Note behavioral changes

**Deliverable**: Migration documentation

**Verification:**
- [ ] CHANGELOG.md has BREAKING CHANGES section
- [ ] Migration path from v3.x clearly documented

---

## Phase 15: Cleanup

**Goal**: Remove deprecated files and update references
**Risk**: Low
**Value**: Clean codebase

### Checkpoint 15.1: Delete old checklists

- [ ] Verify all checklist content integrated into new commands:
  - `.claude/checklists/security.md` → `/code-review-security`
  - `.claude/checklists/performance.md` → `/code-review-performance`
  - `.claude/checklists/accessibility.md` → `/code-review-accessibility`
  - `.claude/checklists/seo-review.md` → `/code-review-seo`
- [ ] Delete `.claude/checklists/` directory entirely
- [ ] Update any documentation referencing checklists

**Verification:**
```bash
# Checklists directory should not exist
[ ! -d ".claude/checklists" ] && echo "PASS" || echo "FAIL"

# No references to old checklists in codebase
grep -r "\.claude/checklists" . 2>/dev/null | grep -v ".git" && echo "FAIL: found references" || echo "PASS"
```

### Checkpoint 15.2: Remove artifacts/code-reviews references

- [ ] Search codebase for `artifacts/code-reviews`
- [ ] Update all references to `docs/audits`
- [ ] Remove empty directories

**Deliverable**: Clean codebase with no deprecated references

**Verification:**
```bash
# No references to old path
grep -r "artifacts/code-reviews" . 2>/dev/null | grep -v ".git" && echo "FAIL" || echo "PASS"

# Directory should not exist
[ ! -d "artifacts/code-reviews" ] && echo "PASS" || echo "FAIL"
```

---

## Testing Strategy

### Per-Phase Testing

Each command should be tested:
1. **Standalone execution** - Run command, verify report created
2. **Naming increment** - Run twice, verify 01 then 02
3. **Platform detection** - Test auto-detect and explicit flags
4. **Report quality** - Verify all sections populated

### Integration Testing

After all phases:
1. **Master command** - Run `/code-review`, select multiple, verify all reports
2. **Comprehensive report** - Verify references correct, no duplication
3. **Migration** - Test on project with existing `artifacts/code-reviews/`

### Test Script

Create `scripts/tests/test-audit-system.sh`:

```bash
#!/bin/bash
set -e

echo "Testing audit system..."

# Test 1: Directory structure
echo "1. Testing directory structure..."
[ -d "docs/audits" ] || { echo "FAIL: docs/audits missing"; exit 1; }

# Test 2: Naming function
echo "2. Testing naming function..."
source scripts/common-functions.sh
result=$(get_next_audit_number "test" "docs/audits")
[ "$result" = "01" ] || { echo "FAIL: expected 01, got $result"; exit 1; }

# Test 3: Each command exists
echo "3. Testing command files exist..."
for cmd in security performance database infrastructure seo accessibility typescript testing; do
  [ -f ".claude/commands/code-review-${cmd}.md" ] || { echo "FAIL: code-review-${cmd}.md missing"; exit 1; }
done
[ -f ".claude/commands/build-check.md" ] || { echo "FAIL: build-check.md missing"; exit 1; }

echo "All tests passed!"
```

---

## Concurrent Implementation Roadmap

This plan can be implemented alongside v3.7.0. Here's the recommended approach:

```
┌─────────────────────────────────────────────────────────────────────┐
│ MILESTONE A - Foundation (Parallel with v3.7.0 Phase 1)             │
├─────────────────────────────────────────────────────────────────────┤
│ v4.0.0 Phase 1: Directory Structure & Migration                     │
│   • Create docs/audits/ structure                                   │
│   • Create INDEX.md template                                        │
│   • Add migration logic to update-context-system                    │
│                                                                     │
│ v4.0.0 Phase 2: Shared Infrastructure                               │
│   • get_next_audit_number() in common-functions.sh                  │
│   • update_audit_index() in common-functions.sh                     │
│   • Platform detection helpers                                      │
│                                                                     │
│ [v3.7.0 Phase 1 runs in parallel - no conflicts]                    │
├─────────────────────────────────────────────────────────────────────┤
│ VERIFY: All helper functions work, directory structure in place     │
└─────────────────────────────────────────────────────────────────────┘
                                   ↓
┌─────────────────────────────────────────────────────────────────────┐
│ MILESTONE B - Audit Commands (Parallel with v3.7.0 Phases 2-6)      │
├─────────────────────────────────────────────────────────────────────┤
│ v4.0.0 Phases 4-12: Individual audit commands                       │
│   • /code-review-security                                           │
│   • /code-review-performance                                        │
│   • /code-review-database                                           │
│   • /code-review-infrastructure                                     │
│   • /code-review-seo                                                │
│   • /code-review-accessibility                                      │
│   • /code-review-typescript                                         │
│   • /code-review-testing                                            │
│   • /build-check                                                    │
│                                                                     │
│ [v3.7.0 Phases 2-6 run in parallel - no conflicts]                  │
├─────────────────────────────────────────────────────────────────────┤
│ VERIFY: All audit commands work standalone                          │
└─────────────────────────────────────────────────────────────────────┘
                                   ↓
┌─────────────────────────────────────────────────────────────────────┐
│ MILESTONE C - Release v3.7.0 (before v4.0.0 completion)             │
├─────────────────────────────────────────────────────────────────────┤
│ • Update VERSION to 3.7.0                                           │
│ • Update CHANGELOG.md                                               │
│ • Release v3.7.0                                                    │
├─────────────────────────────────────────────────────────────────────┤
│ VERIFY: v3.7.0 released and working                                 │
└─────────────────────────────────────────────────────────────────────┘
                                   ↓
┌─────────────────────────────────────────────────────────────────────┐
│ MILESTONE D - Master Command & Integration                          │
├─────────────────────────────────────────────────────────────────────┤
│ v4.0.0 Phase 3: Master /code-review orchestrator                    │
│   • Interactive selection UI                                        │
│   • Sequential execution                                            │
│   • Comprehensive report generation                                 │
│                                                                     │
│ v4.0.0 Phase 13: Refactor existing code-review.md                   │
│   • Remove monolithic behavior                                      │
│   • Implement orchestrator                                          │
├─────────────────────────────────────────────────────────────────────┤
│ VERIFY: /code-review shows selection, runs sub-commands             │
└─────────────────────────────────────────────────────────────────────┘
                                   ↓
┌─────────────────────────────────────────────────────────────────────┐
│ MILESTONE E - Documentation & Cleanup                               │
├─────────────────────────────────────────────────────────────────────┤
│ v4.0.0 Phase 14: Documentation                                      │
│   • Update command-philosophy.md                                    │
│   • Create audit-guide.md                                           │
│   • Migration documentation                                         │
│                                                                     │
│ v4.0.0 Phase 15: Cleanup                                            │
│   • Delete .claude/checklists/                                      │
│   • Remove old references                                           │
├─────────────────────────────────────────────────────────────────────┤
│ VERIFY: No deprecated files, all docs updated                       │
└─────────────────────────────────────────────────────────────────────┘
                                   ↓
┌─────────────────────────────────────────────────────────────────────┐
│ MILESTONE F - Release v4.0.0                                         │
├─────────────────────────────────────────────────────────────────────┤
│ • Update VERSION to 4.0.0                                           │
│ • Update CHANGELOG.md with BREAKING CHANGES                         │
│ • Test upgrade from v3.7.0                                          │
│ • Release                                                           │
├─────────────────────────────────────────────────────────────────────┤
│ VERIFY: Clean upgrade from v3.7.0, all features work                │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Implementation Order

```
Phase 1 (Directory & Migration)   ← Foundation, do first
    ↓
Phase 2 (Shared Infrastructure)   ← Utilities for all commands
    ↓
Phase 6 (Database Audit)          ← User's existing prompt, highest priority
    ↓
Phase 7 (Infrastructure Audit)    ← User's existing prompt
    ↓
Phase 8 (SEO Audit)               ← User's existing prompt
    ↓
Phase 4 (Security Audit)          ← Expand existing checklist
    ↓
Phase 5 (Performance Audit)       ← Expand existing checklist
    ↓
Phase 9-11 (A11y, TS, Testing)    ← Lower priority
    ↓
Phase 12 (Build Check)            ← Separate gate command
    ↓
Phase 3 (Master Command)          ← Orchestrator (needs sub-commands first)
    ↓
Phase 13-15 (Refactor & Cleanup)  ← Final integration
```

---

## Explicitly NOT Doing

| Feature | Reason |
|---------|--------|
| Context system integration | User chose standalone reports |
| TodoWrite generation | User chose standalone reports |
| KNOWN_ISSUES.md updates | User chose standalone reports |
| Session-based naming | Doesn't support multiple runs per session |
| Real-time monitoring | Out of scope (audit is point-in-time) |
| Legacy flag | User chose clean break |

---

## Success Metrics

### Must Have (Release Blockers)

- [ ] All 8 specialized audit commands work standalone
- [ ] Master command orchestrates correctly
- [ ] Reports saved to `docs/audits/` with correct naming
- [ ] Migration from `artifacts/code-reviews/` works
- [ ] Platform flags work for database/infrastructure

### Should Have

- [ ] INDEX.md updated on each audit
- [ ] Comprehensive report references (not duplicates) individual reports
- [ ] `/build-check` catches TS errors

### Nice to Have

- [ ] Auto-detect platform without flags
- [ ] Audit comparison (vs previous audit of same type)

---

## Changelog Draft

```markdown
## [4.0.0] - TBD

### BREAKING CHANGES

- `/code-review` is now an interactive orchestrator, not a monolithic review
- Reports now saved to `docs/audits/` (was `artifacts/code-reviews/`)
- Removed `.claude/checklists/` directory (integrated into commands)
- No context system integration (KNOWN_ISSUES, STATUS, TodoWrite)
- No legacy flag - clean break from old behavior

### Added - Modular Code Review System

**New Audit Commands:**
- `/code-review-security` - Deep OWASP-style security audit
- `/code-review-performance` - Core Web Vitals, bundle, runtime
- `/code-review-accessibility` - WCAG compliance
- `/code-review-seo` - Technical SEO audit
- `/code-review-database` - Query optimization, N+1, indexes (--prisma, --drizzle)
- `/code-review-infrastructure` - Serverless costs, caching (--vercel, --aws)
- `/code-review-typescript` - Type safety, strictness audit
- `/code-review-testing` - Coverage and quality audit
- `/build-check` - Pre-push build validation gate

**Master Command:**
- `/code-review` now shows interactive selection
- Run individual audits or select multiple
- Comprehensive report references individual audit files

### Changed

**Report Location:**
- Reports now saved to `docs/audits/` (was `artifacts/code-reviews/`)
- Naming: `{type}-audit-NN.md` (incrementing per type)
- Comprehensive: `comprehensive-audit-NN.md`
- Archive: `docs/audits/archive/`

**Migration:**
- Existing `artifacts/code-reviews/*` files moved to `docs/audits/archive/pre-v4.0.0-migration/`
- Automatic migration on `/update-context-system`

### Removed

- Monolithic `/code-review` behavior (use specialized commands)
- Context system integration in code review (standalone reports only)
- Session-based report naming
- `.claude/checklists/` directory (content integrated into commands)
```

---

**Next Steps**: Begin implementation when ready.
