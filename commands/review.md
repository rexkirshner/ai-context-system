# /review

Comprehensive code review. Creates a detailed audit report.

## Scope

Ask the user what to review:
- **Specific files/directories** — User provides paths
- **Recent changes** — Look at uncommitted changes or recent commits
- **Full codebase** — Everything (warn: may take a while for large projects)

## What to Review

Examine the code for:

### Performance & Efficiency
- Unnecessary re-renders, computations, or loops
- N+1 queries and database inefficiencies
- Missing caching opportunities
- Bundle size and lazy loading
- Memory leaks

### Cloud Resources & Cost
- **Serverless:** Cold starts, function duration, edge vs serverless placement
- **Vercel-specific:** ISR/SSR/SSG choices, image optimization, bandwidth
- **Database:** Connection pooling, query efficiency, Prisma operations
- **External APIs:** Unnecessary calls, missing batching, rate limit handling

### Maintainability
- Code clarity and readability
- Function/component complexity (too long, too many responsibilities)
- Naming (variables, functions, files)
- Dead code, unused imports
- Consistent patterns across codebase

### Documentation
- Missing or outdated comments for complex logic
- README accuracy
- API documentation (if applicable)
- Type definitions and interfaces

### Security (if applicable)
- Input validation
- Authentication/authorization gaps
- Secrets handling
- OWASP top 10 basics

### Accessibility (if applicable)
- Semantic HTML
- ARIA labels
- Keyboard navigation
- Color contrast

## Output Format

Create a report at `docs/audits/CODE-REVIEW-[NUMBER].md`:

```markdown
# Code Review #[NUMBER]

**Date:** YYYY-MM-DD
**Scope:** [what was reviewed]

## Summary

[2-3 sentence overview of findings]

## Critical Issues

[Issues that should be fixed immediately]

### [Issue Title]
**File:** `path/to/file.ts:123`
**Problem:** [What's wrong]
**Fix:** [How to fix it]

## Recommendations

[Non-critical improvements, ordered by impact]

### [Recommendation Title]
**File:** `path/to/file.ts`
**Current:** [What it does now]
**Suggested:** [What it should do]
**Why:** [Benefit of the change]

## Notes

[Anything else worth mentioning - patterns observed, praise for good code, etc.]
```

## Instructions

1. **Ask** user for scope (files, recent changes, or full codebase)
2. **Read** the specified files/directories
3. **Analyze** against all review categories
4. **Determine** the next review number (check `docs/audits/` for existing reviews)
5. **Create** `docs/audits/` directory if it doesn't exist
6. **Write** the report to `docs/audits/CODE-REVIEW-[NUMBER].md`
7. **Summarize** key findings to the user

## Keep It Actionable

- Every issue should have a clear fix
- Prioritize by impact (critical first, nice-to-haves last)
- Don't nitpick style unless it hurts readability
- Praise good patterns when you see them
