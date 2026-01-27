# /review

Comprehensive code review. Output: `docs/audits/CODE-REVIEW-NN.md`

## Non-Negotiables

- **Read-only.** Do not modify any code, config, or lockfiles.
- **Only allowed writes:** create `docs/audits/` if missing + write the report file.
- **No secrets.** If evidence snippet contains a secret/PII, replace value with `[REDACTED]`, still cite `path:line`, describe the pattern.

## Stop & Ask

Before proceeding, stop and ask the user if:
- Scope is ambiguous AND "recent changes" can't be determined (no git + no clear directories)
- Repo is enormous AND you can't identify entrypoints (no package.json, no main files found)

Don't do random scanning when you can't locate "hot surfaces."

## Scope

Ask user what to review:
- **(A) Specific files/directories** — user provides paths
- **(B) Recent changes** — uncommitted diff + last 1-3 commits
- **(C) Full codebase** — warn if large; use sampling strategy

**Default (if user is vague):** (B) Recent changes.
**If no git:** Sample top-level + `src/` + key configs.

## Large Repo Strategy

If codebase is large:
- Timebox: 20-40 min equivalent effort
- Sample entrypoints, hot paths, repeated patterns
- Prioritize: API handlers, DB layer, rendering boundaries, background jobs
- Note sampling limitations in report

## Review Dimensions (prioritize by impact)

- **Performance** — hot paths, renders, loops, queries, caching, memory, bundle size
- **Cloud/Cost** — serverless patterns, Prisma/db ops, Vercel usage, API call volume
- **Reliability** — timeouts, retries, error boundaries, idempotency
- **Security** — authz/authn, input validation, secrets, injection risks
- **Maintainability** — complexity, duplication, naming, dead code, consistency
- **Docs/Types** — type coverage, comments for complex logic, README accuracy
- **Accessibility** — only if UI exists (semantic HTML, ARIA, keyboard nav)

## Do

1. Identify stack + entrypoints (framework, DB, runtime, deployment)
2. Map "hot surfaces": API routes, DB access, rendering boundaries, jobs/cron
3. Scan for obvious hotspots (N+1, unbounded loops, missing pagination, repeated fetches)
4. Deep dive into chosen scope and collect evidence
5. Determine next review number:
   - List existing `docs/audits/CODE-REVIEW-*.md`
   - Extract highest N; next = N+1; zero-pad to 2 digits
   - If none exist, start at 01
6. Write report to `docs/audits/CODE-REVIEW-NN.md`
7. Summarize to user (constrained format — see below)

## Finding Requirements (every finding must have evidence)

For each finding include:
- **ID:** F1, F2, F3... (sequential)
- **Priority:** P0 (prod/security), P1 (major perf/cost), P2 (maintainability), P3 (nice-to-have)
- **Effort:** S (< 1 hr), M (1-4 hrs), L (> 4 hrs)
- **Confidence:** High / Med / Low (if suspected but unconfirmed, use Low + explain how to confirm)
- **Evidence:** `path:line` + ≤10-line snippet, OR symbol reference
- **Impact:** Why it matters (for Cost findings, estimate: Low/Med/High)
- **Suggested fix:** Clear steps (no code changes performed)
- **Verify:** How to prove it's fixed (test, benchmark, query count, bundle analyzer, etc.)

**Symbol reference format:** `path :: export/function/ClassName :: member` (+ optional grep pattern)

**Secrets in evidence:** If snippet contains secret/PII, use `[REDACTED]` for value, keep path:line, describe pattern.

**Cap:** Max 12 findings. Merge duplicates into themes.

## Output Format

```markdown
# Code Review #NN

**Date:** YYYY-MM-DD
**Scope:** [what was reviewed]

## Executive Summary
- [3-6 bullets: biggest risks/opportunities]

## Top 5 Actions
1. [Action] (See F1)
2. [Action] (See F3)
3. ...
```
Each action must reference the corresponding finding ID.

```markdown
## Findings

### F1 [P0] Title
**Evidence:** `path:line`
```
[≤10 line snippet, secrets redacted]
```
**Problem:** ...
**Impact:** ...
**Suggested fix:** ...
**Verify:** ...

### F2 [P1] Title
...

## Notes
- Good patterns worth keeping
- Repeated themes observed

## Appendix
**Stack detected:** [Framework], [Runtime], [DB/ORM], [Deployment platform]
**Files/areas reviewed:** ...
**Areas skipped (if sampling):** ...
**Assumptions:** ...
```

## Chat Summary Format

After writing the report, reply to user with exactly:
- 3 bullets: biggest risks/opportunities
- 1 bullet: biggest cost/perf lever (if any)
- 1 bullet: what you need from the user (if anything, otherwise omit)

## Guidance

- Actionable > comprehensive. Every issue should have a clear fix.
- Skip nitpicks unless they indicate a pattern.
- Praise good patterns when you see them.
- If unsure about a bug, mark Confidence=Low and propose how to confirm.
