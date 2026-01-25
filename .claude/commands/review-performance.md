---
name: review-performance
description: Performance review of the codebase
---

# /review-performance

Perform a performance review of the codebase.

## Scope

Review the files in the Working Set (from `context/STATUS.md`), or if specified, a particular file/directory.

### Scope Expansion

If the Working Set lacks performance-critical files, expand to include:
- `**/api/**`, `**/lib/**`, `**/utils/**`
- `**/components/**` (for render performance)
- `**/prisma/**`, `**/*database*` (for query patterns)
- `next.config.*`, `vite.config.*` (for build config)

Consider running: Bundle analyzer, React DevTools Profiler, or Lighthouse performance audit.

## What to Check

### Database & Queries
- N+1 query patterns
- Missing indexes
- Inefficient queries
- Connection pooling

### Memory & Resources
- Memory leaks
- Large object allocations
- Resource cleanup
- Caching opportunities

### Algorithms & Data Structures
- Inefficient algorithms (O(n^2) when O(n) possible)
- Inappropriate data structures
- Unnecessary iterations
- Redundant computations

### Network & I/O
- Unnecessary API calls
- Missing request batching
- Large payload sizes
- Blocking I/O in hot paths

### Frontend (if applicable)
- Bundle size concerns
- Render performance
- Unnecessary re-renders
- Image optimization

### Async & Concurrency
- Blocking operations
- Parallelization opportunities
- Race conditions
- Deadlock potential

## Output Format

```markdown
## Performance Review

### Critical Issues
- [Issue]: [Description, location, and impact]

### Optimization Opportunities
- [Area]: [Suggestion and expected benefit]

### Good Patterns Found
- [Pattern]: [Where it's used well]

### Checked Areas
- [List of what was reviewed]
```

## Behavior

1. Read STATUS.md to understand current context (if it doesn't exist, suggest running `/init-context` first or ask user to specify scope)
2. Review files in Working Set (or specified scope)
3. Check against performance criteria above
4. Produce report in specified format
5. Do NOT make changes - report only

## Done

Provide the performance review report.
