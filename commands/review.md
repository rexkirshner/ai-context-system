# /review

Comprehensive code review. Output: `docs/audits/CODE-REVIEW-[N].md`

## First: Ask Scope

- Specific files/directories (user provides paths)
- Recent changes (uncommitted or recent commits)
- Full codebase (warn if large)

## Review For

- **Performance** — renders, loops, queries, caching, memory, bundle size
- **Cloud/Cost** — serverless efficiency, Prisma ops, Vercel choices, API calls
- **Maintainability** — clarity, complexity, naming, dead code, consistency
- **Documentation** — comments for complex logic, README, types
- **Security** — validation, auth, secrets (if applicable)
- **Accessibility** — semantic HTML, ARIA, keyboard nav (if applicable)

## Do

1. Ask user for scope
2. Read the code
3. Find next review number from `docs/audits/`
4. Create directory if needed
5. Write `docs/audits/CODE-REVIEW-[N].md`
6. Summarize key findings to user

## Output Format

```markdown
# Code Review #N

**Date:** YYYY-MM-DD
**Scope:** [what was reviewed]

## Summary
[2-3 sentences]

## Critical Issues
### [Title]
**File:** `path:line` | **Problem:** ... | **Fix:** ...

## Recommendations
### [Title]
**File:** `path` | **Current:** ... | **Suggested:** ... | **Why:** ...

## Notes
[Patterns observed, good code, etc.]
```

**Guidance:** Actionable fixes. Prioritize by impact. Skip nitpicks. Praise good patterns.
