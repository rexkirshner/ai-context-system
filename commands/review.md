# /review

Comprehensive code review. Output: `docs/audits/CODE-REVIEW-NN.md`

## Non-Negotiables

- **Read-only.** Do not modify any code, config, or lockfiles.
- **Only allowed writes:** create `docs/audits/` if missing + write the report file.
- **No installs.** Don't run dependency installs or commands that mutate lockfiles/generate artifacts (e.g., `npm install`, `prisma migrate`, `pod install`).
- **No network.** Avoid networked commands unless user explicitly asks.
- **No secrets.** If evidence snippet contains a secret/PII, replace value with `[REDACTED]`, still cite `path:line`, describe the pattern. If unsure whether something is sensitive, err on redacting.

## Allowed Actions

- Reading files
- Searching (ripgrep, grep, glob)
- Listing directories
- Running tests/build commands to verify behavior (if they don't install or mutate)
  - Prefer the fastest non-mutating checks; don't run long suites unless necessary

**Not allowed:** Writing or modifying anything except the report file.

## Stop & Ask

Before proceeding, stop and ask the user if:
- Scope is ambiguous AND "recent changes" can't be determined (no git + no clear directories)
- Repo is enormous AND you can't identify entrypoints (no `package.json`, `pyproject.toml`, `requirements.txt`, `go.mod`, `Cargo.toml`, `pom.xml`, or similar root files)

Don't do random scanning when you can't locate "hot surfaces."

**Hot surfaces** = code paths that run per request/interaction or per job tick (API handlers, DB access, render loops, cron).

## Scope

Ask user what to review:
- **(A) Specific files/directories** — user provides paths
- **(B) Recent changes** — staged + unstaged diff (with rename detection), plus last 1-3 commits
- **(C) Full codebase** — warn if large; use sampling strategy

**Default (if user is vague):** (B) Recent changes.
**If no git:** Sample top-level + `src/` + key configs.

## Large Repo Strategy

If codebase is large:
- Timebox: 20-40 min equivalent effort
- Sample entrypoints, hot paths, repeated patterns
- Prioritize: API handlers, DB layer, rendering boundaries, background jobs
- Note sampling limitations in report

## Review Dimensions

- **Performance** — hot paths, renders, loops, queries, caching, memory, bundle size
- **Cloud-Cost** — serverless patterns, Prisma/db ops, Vercel usage, API call volume
- **Reliability** — timeouts, retries, error boundaries, idempotency
- **Security** — authz/authn, input validation, secrets, injection risks
- **Maintainability** — complexity, duplication, naming, dead code, consistency
- **Docs-Types** — type coverage, comments for complex logic, README accuracy
- **Accessibility** — only if UI exists (semantic HTML, ARIA, keyboard nav)

## Do

1. Identify stack + entrypoints (framework, DB, runtime, deployment)
2. Map hot surfaces: API routes, DB access, rendering boundaries, jobs/cron
3. Scan for obvious hotspots (N+1, unbounded loops, missing pagination, repeated fetches)
4. Deep dive into chosen scope and collect evidence
5. Determine next review number:
   - List existing `docs/audits/CODE-REVIEW-*.md`
   - Extract highest N; next = N+1; zero-pad to 2 digits
   - If none exist, start at 01
6. Write report to `docs/audits/CODE-REVIEW-NN.md` (use today's date in user timezone)
7. Summarize to user (exactly 5 bullets with finding refs — see Chat Summary Format)

## Finding Requirements

For each finding:
- **ID:** F1, F2, F3... (sequential)
- **Priority:** P0 (prod/security), P1 (major perf/cost), P2 (maintainability), P3 (nice-to-have)
- **Dimension:** Performance / Cloud-Cost / Reliability / Security / Maintainability / Docs-Types / Accessibility
- **Effort:** S (< 1 hr), M (1-4 hrs), L (> 4 hrs)
- **Confidence:** High / Med / Low (if suspected but unconfirmed, use Low + explain how to confirm)
- **Evidence:** `path:line` + ≤10-line snippet, OR symbol reference (`path :: export/function :: member`)
- **Impact:** Why it matters (for Cost findings, estimate: Low/Med/High)
- **Suggested fix:** Clear steps (no code changes performed)
- **Verify:** How to prove it's fixed (test, benchmark, query count, bundle analyzer, etc.)

**Secrets in evidence:** Use `[REDACTED]` for value, keep path:line, describe pattern.

**Cap:** Max 12 findings. Merge duplicates into themes.

## Output Format

Write exactly this structure (use ~~~ for inner code blocks):

```markdown
# Code Review #NN

**Date:** YYYY-MM-DD (use today's date)
**Scope:** [what was reviewed]

## Executive Summary
- [3-6 bullets: biggest risks/opportunities]

## Top 5 Actions
1. [Outcome-oriented action, e.g., "Reduce DB queries in X by batching"] (See F1)
2. [Action] (See F3)
3. [Action] (See FN)
4. [Action] (See FN)
5. [Action] (See FN)

## Findings

### F1 [P0] [Security] Title
**Evidence:** `path:line`
~~~
[≤10 line snippet, secrets redacted]
~~~
**Problem:** ...
**Impact:** ...
**Suggested fix:** ...
**Verify:** ...

### F2 [P1] [Performance] Title
**Evidence:** `path:line`
~~~
[snippet]
~~~
**Problem:** ...
**Impact:** ...
**Suggested fix:** ...
**Verify:** ...

## Notes
- [At least 1 "keep doing this" positive pattern]
- [Other good patterns worth keeping]
- [Repeated themes observed]

## Appendix
**Stack detected:** [Framework], [Runtime], [DB/ORM], [Deployment platform]
**Files/areas reviewed:** ...
**Areas skipped (if sampling):** ...
**Assumptions:** ...
```

## Chat Summary Format

After writing the report, reply to user with exactly 5 bullets (include finding refs):
1. [Biggest risk/opportunity #1] (F1)
2. [Biggest risk/opportunity #2] (F3)
3. [Biggest risk/opportunity #3] (FN)
4. [Biggest cost/perf lever, or "None spotted"] (FN if applicable)
5. [What you need from user, or "Nothing needed"]

## Guidance

- Actionable > comprehensive. Every issue should have a clear fix.
- Actions must be outcomes ("Reduce X by Y") not tasks ("Refactor X").
- Skip nitpicks unless they indicate a pattern.
- Praise good patterns when you see them — include at least 1 positive in Notes.
- If unsure about a bug, mark Confidence=Low and propose how to confirm.
