---
description: Comprehensive code review covering performance, security, and organization with git commit
---

> **⚠️ LEGACY WORKFLOW - NOT THE ACTIVE SLASH COMMAND**
>
> This is an alternative/legacy code review approach that includes making fixes during review.
>
> **The active `/code-review` command** is at `.claude-commands/code-review.md` and follows a read-only, analysis-only approach where NO changes are made during review.
>
> This file is kept for reference only to show an alternative workflow where fixes are applied immediately. Most users should use the read-only `/code-review` command instead.

---

You are conducting a comprehensive multi-phase code review. Follow these phases in exact order:

## Phase 1: Performance Review

Examine the entire codebase for performance optimizations while maintaining:
- Human readability
- Code organization
- Upgradability
- Development best practices

**Focus areas:**
1. **React/Next.js optimizations:**
   - Unnecessary re-renders (missing useMemo, useCallback)
   - Inefficient component structures
   - Missing dynamic imports for code splitting
   - Image optimization issues
   - Metadata/SEO optimizations

2. **Build & bundle optimizations:**
   - Unused dependencies
   - Large bundle sizes
   - Missing tree-shaking opportunities
   - Duplicate code that could be abstracted

3. **Runtime performance:**
   - Inefficient algorithms (O(n²) that could be O(n))
   - Unnecessary DOM operations
   - Missing debouncing/throttling
   - Memory leaks (event listeners, timers)

4. **Data fetching & caching:**
   - Missing caching strategies
   - Inefficient data structures
   - Redundant API calls or file reads

**Output for Phase 1:**
- List of performance issues found (with file:line references)
- Implemented fixes with before/after comparisons
- Performance grade (A+ to F)
- Estimated performance impact of changes

---

## Phase 2: Security Review

Conduct an independent security audit identifying vulnerabilities and risks.

**Focus areas:**
1. **XSS (Cross-Site Scripting):**
   - Unsanitized user input
   - Dangerous HTML rendering
   - Missing CSP headers

2. **Injection attacks:**
   - SQL injection risks (if applicable)
   - Command injection in scripts
   - Path traversal vulnerabilities

3. **Authentication & Authorization:**
   - Exposed API keys or secrets
   - Insecure session handling
   - Missing rate limiting

4. **Dependencies:**
   - Known vulnerabilities (run npm audit)
   - Outdated packages with security patches
   - Unnecessary dependencies

5. **Data exposure:**
   - Sensitive data in client bundles
   - Missing input validation
   - Insecure headers

6. **Supply chain:**
   - Malicious package risks
   - Missing integrity checks

**Output for Phase 2:**
- Security issues found (categorized by severity: Critical/High/Medium/Low)
- Implemented fixes with explanations
- Remaining risks that cannot be eliminated (with risk scores 1-10)
- Security grade (A+ to F)
- List of recommendations for future hardening

---

## Phase 3: Organization & Code Quality Review

Clean up code organization to prevent project sprawl and ensure GitHub-ready quality.

**Focus areas:**
1. **File organization:**
   - Misplaced files
   - Inconsistent naming conventions
   - Missing or stale files
   - Duplicate code

2. **Code quality:**
   - Unused imports
   - Dead code
   - Inconsistent formatting
   - Missing error handling
   - Poor variable/function names
   - Overly complex functions that should be split

3. **Documentation:**
   - Missing JSDoc comments for complex functions
   - Outdated comments
   - Missing README sections
   - Unclear code that needs comments

4. **TypeScript quality:**
   - Excessive `any` types
   - Missing type definitions
   - Type assertions that could be avoided

5. **Consistency:**
   - Mixed patterns (e.g., some components use one pattern, others use another)
   - Inconsistent error handling
   - Inconsistent styling approaches

**Output for Phase 3:**
- Organization issues found (with file references)
- Implemented improvements
- Files moved/renamed/deleted
- Code quality grade (A+ to F)

---

## Phase 4: Update Meta-Documentation

After completing all three reviews, run the `/update-docs` slash command to update all meta-documentation (CLAUDE.md, PRD.md, etc.) with the changes made during the review.

---

## Phase 5: Summary Report

Provide a concise summary report in the following format:

```markdown
# Code Review Summary

## Performance Review (Grade: X)
- **Issues found:** [number]
- **Issues fixed:** [number]
- **Key improvements:**
  - [Improvement 1]
  - [Improvement 2]
  - [Improvement 3]

## Security Review (Grade: X)
- **Vulnerabilities found:** [number]
- **Vulnerabilities fixed:** [number]
- **Critical/High severity issues:** [number fixed/remaining]
- **Remaining risks:**
  - [Risk 1] (Score: X/10) - [Brief description]
  - [Risk 2] (Score: X/10) - [Brief description]

## Organization Review (Grade: X)
- **Files reorganized:** [number]
- **Dead code removed:** [lines/files]
- **Key improvements:**
  - [Improvement 1]
  - [Improvement 2]

## Meta-Documentation
✅ Updated via /update-docs command

## Overall Grade: X

## Next Steps
- Ready for git commit
- [Any other recommendations]
```

---

## Phase 6: Git Commit

After the summary is complete and confirmed with the user, create a git commit with all changes:

1. Check git status to see all changes
2. Add all relevant files (exclude any that shouldn't be committed)
3. Create a detailed commit message following this format:

```
Comprehensive code review: Performance, Security & Organization

Performance Improvements:
- [Key improvement 1]
- [Key improvement 2]
- [Key improvement 3]

Security Enhancements:
- [Key fix 1]
- [Key fix 2]

Code Organization:
- [Key cleanup 1]
- [Key cleanup 2]

Meta-Documentation:
- Updated CLAUDE.md, PRD.md, and other meta-docs

Overall grades: Performance [X], Security [X], Organization [X]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**DO NOT push to GitHub** - only commit locally.

---

## Important Guidelines

1. **Be thorough but practical:** Don't create unnecessary complexity in pursuit of perfection
2. **Maintain backwards compatibility:** Don't break existing functionality
3. **Test as you go:** Verify changes don't break the build
4. **Prioritize impact:** Focus on high-impact improvements first
5. **Document trade-offs:** If you choose not to fix something, explain why
6. **Preserve intent:** Don't change code you don't fully understand
7. **Keep it simple:** Simpler code is better than clever code

## Execution Notes

- Work through each phase completely before moving to the next
- For each phase, scan the entire codebase systematically
- Use grep/glob to find patterns across files
- Verify build success after each major change
- Keep track of all changes for the summary report
