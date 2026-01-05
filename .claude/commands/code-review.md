---
name: code-review
description: Master code review orchestrator - select and run specialized audits
---

# /code-review Command

Master orchestrator for modular code reviews. Select one or more specialized audits to run, or run a comprehensive review covering all areas.

## CRITICAL RULES

1. **NEVER make code changes during review** - This is analysis only
2. **Take your time** - No rushing, no time pressure
3. **Use specialized commands** - Each audit type has its own detailed command
4. **Aggregate results** - Combine findings into a unified summary

## Available Audit Types

| Audit | Command | Description | When to Use |
|-------|---------|-------------|-------------|
| Security | `/code-review-security` | OWASP Top 10, auth, injection, XSS | Before production, after auth changes |
| Performance | `/code-review-performance` | Core Web Vitals, bundle, runtime | Before launch, after major features |
| Accessibility | `/code-review-accessibility` | WCAG 2.1 AA compliance | Before public launch, after UI changes |
| SEO | `/code-review-seo` | Metadata, structured data, crawlability | Public web apps, content sites |
| Database | `/code-review-database` | N+1, indexes, query optimization | After schema changes, slow queries |
| Infrastructure | `/code-review-infrastructure` | Serverless costs, caching, builds | Monthly cost reviews, scaling prep |
| TypeScript | `/code-review-typescript` | Type safety, strict mode, any usage | Before enabling strict, tech debt cleanup |
| Testing | `/code-review-testing` | Coverage, quality, CI integration | Before major releases, quality gates |

## Quick Reference

```bash
# Run single audit
/code-review-security

# Run multiple audits (this command)
/code-review --security --performance

# Run all audits
/code-review --all

# Run pre-production audits
/code-review --prelaunch
```

## Usage Patterns

### Pattern 1: Interactive Selection

When run without arguments, present an interactive menu:

```
Code Review Orchestrator

Select audits to run (enter numbers separated by commas, or 'all'):

1. Security      - OWASP Top 10, authentication, injection, XSS
2. Performance   - Core Web Vitals, bundle analysis, runtime
3. Accessibility - WCAG 2.1 AA, keyboard navigation, screen readers
4. SEO           - Metadata, structured data, crawlability
5. Database      - N+1 detection, indexes, query optimization
6. Infrastructure- Serverless costs, caching, build times
7. TypeScript    - Type safety, strict mode, any usage
8. Testing       - Coverage, test quality, CI integration

Presets:
A. All audits (comprehensive)
P. Pre-launch (Security + Performance + Accessibility + SEO)
B. Backend focus (Security + Database + Testing)
F. Frontend focus (Performance + Accessibility + SEO)

Selection: >
```

### Pattern 2: Command Line Arguments

Support these argument patterns:

```bash
# Individual audits
/code-review --security
/code-review --performance --accessibility

# Presets
/code-review --all          # Run all 8 audits
/code-review --prelaunch    # Security, Performance, A11y, SEO
/code-review --backend      # Security, Database, Testing
/code-review --frontend     # Performance, Accessibility, SEO

# Platform-specific (passed to sub-commands)
/code-review --database --prisma
/code-review --infrastructure --vercel
```

## Execution Steps

### Step 0: Parse Arguments or Show Menu

**If arguments provided:**
```
Code Review: Running selected audits

Selected: Security, Performance, Accessibility
Platform flags: --vercel (passed to infrastructure)

Starting in sequence...
```

**If no arguments:**
Show interactive menu (Pattern 1 above).

### Step 1: Run Selected Audits

For each selected audit, run the corresponding command:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Audit 1/3: Security
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Run /code-review-security]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Audit 2/3: Performance
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Run /code-review-performance]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Audit 3/3: Accessibility
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Run /code-review-accessibility]
```

**Important:** Each sub-command saves its own report to `docs/audits/{type}-audit-NN.md`.

### Step 2: Generate Summary Report

After all audits complete, create a combined summary:

```bash
# Get next audit number for combined report
source scripts/common-functions.sh
NUM=$(get_next_audit_number "combined" "docs/audits")
REPORT_FILE="docs/audits/combined-audit-${NUM}.md"
```

**Summary report structure:**

```markdown
# Combined Audit Report (NN)

| Field | Value |
|-------|-------|
| Date | YYYY-MM-DD |
| Repository | [name] |
| Auditor | Claude Code |
| Type | Combined |
| Audits Run | Security, Performance, Accessibility |
| Duration | [total time] |

---

## Executive Summary

**Overall Grade:** [weighted average]

| Audit | Grade | Critical | High | Medium | Low |
|-------|-------|----------|------|--------|-----|
| Security | B | 1 | 2 | 3 | 1 |
| Performance | A | 0 | 1 | 2 | 4 |
| Accessibility | C | 2 | 3 | 5 | 2 |
| **Total** | **B** | **3** | **6** | **10** | **7** |

---

## Critical Issues Across All Audits

### From Security Audit
- **SEC-C1:** SQL injection in search API
  - Location: `app/api/search/route.ts:45`
  - Fix: Use parameterized queries

### From Accessibility Audit
- **A11Y-C1:** Keyboard navigation blocked on dropdown
  - Location: `components/Dropdown.tsx:23`
  - Fix: Add keyboard handlers

- **A11Y-C2:** Missing form labels
  - Location: `components/LoginForm.tsx:15`
  - Fix: Add htmlFor associations

---

## High Priority Issues

[Summarize all HIGH priority from each audit]

---

## Individual Audit Reports

| Audit | Report File | Grade |
|-------|-------------|-------|
| Security | [security-audit-01.md](./security-audit-01.md) | B |
| Performance | [performance-audit-01.md](./performance-audit-01.md) | A |
| Accessibility | [accessibility-audit-01.md](./accessibility-audit-01.md) | C |

---

## Prioritized Remediation

### Immediate (This Week)

1. **[SEC-C1]** Fix SQL injection
2. **[A11Y-C1]** Fix keyboard navigation
3. **[A11Y-C2]** Add form labels

### This Sprint

[High priority items from all audits]

### This Month

[Medium priority items]

---

## Overall Recommendations

1. **Security:** Focus on input validation across API routes
2. **Performance:** No critical issues, maintain current practices
3. **Accessibility:** Significant keyboard and ARIA work needed

---

**Generated by:** Claude Code
**Audit Type:** Combined
**Version:** 4.0.0
```

### Step 3: Update INDEX.md

```bash
source scripts/common-functions.sh
update_audit_index "docs/audits" "Combined" "combined-audit-${NUM}.md" "[Grade]" "Security + Performance + Accessibility"
```

### Step 4: Report Completion

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Code Review Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Audits Completed: 3/3

| Audit | Grade | Critical | High |
|-------|-------|----------|------|
| Security | B | 1 | 2 |
| Performance | A | 0 | 1 |
| Accessibility | C | 2 | 3 |

Overall Grade: B

Reports saved:
- docs/audits/security-audit-01.md
- docs/audits/performance-audit-01.md
- docs/audits/accessibility-audit-01.md
- docs/audits/combined-audit-01.md (summary)

Critical Issues Found: 3
1. [SEC-C1] SQL injection in search API
2. [A11Y-C1] Keyboard navigation blocked
3. [A11Y-C2] Missing form labels

Next Steps:
1. Review combined-audit-01.md for full summary
2. Address critical issues immediately
3. Re-run affected audits after fixes

No changes were made during these audits.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Preset Definitions

### --prelaunch (Pre-Production)

Essential audits before going live:
- Security (prevent vulnerabilities)
- Performance (ensure fast load times)
- Accessibility (comply with ADA/WCAG)
- SEO (search engine ready)

### --backend (Backend Focus)

For API and data-focused projects:
- Security (auth, injection, secrets)
- Database (queries, indexes, N+1)
- Testing (coverage, quality)

### --frontend (Frontend Focus)

For UI-heavy applications:
- Performance (Core Web Vitals)
- Accessibility (WCAG compliance)
- SEO (metadata, structure)

### --all (Comprehensive)

Run all 8 audit types. Best for:
- Major releases
- Annual reviews
- New team onboarding
- Quality certifications

## Grading Calculation

Combined grade is weighted by severity:

| Audit | Weight | Rationale |
|-------|--------|-----------|
| Security | 1.5x | Critical for production |
| Performance | 1.0x | User experience |
| Accessibility | 1.2x | Legal compliance |
| SEO | 0.8x | Marketing value |
| Database | 1.0x | Data integrity |
| Infrastructure | 0.8x | Cost optimization |
| TypeScript | 0.8x | Maintainability |
| Testing | 1.0x | Quality assurance |

Formula: `(sum of weighted grades) / (sum of weights)`

## Error Handling

**If an audit fails:**
```
⚠️ Audit Error: Performance

Error: Could not run bundle analysis (webpack not configured)

Options:
1. Skip this audit and continue
2. Abort all audits
3. Retry with different options

Selection: >
```

**If audit takes too long:**
```
⚠️ Long Running: Database Audit

This audit is taking longer than expected.
Large codebases may take 10-15 minutes.

Options:
1. Continue waiting
2. Reduce scope (sample 50% of files)
3. Abort this audit

Selection: >
```

## When to Use This Command

**Use /code-review when:**
- You need multiple types of audits
- Preparing for a major release
- Want a comprehensive quality overview
- Setting quality baselines

**Use individual commands when:**
- You know exactly what audit you need
- Focused on one area (e.g., just security)
- Following up on specific findings
- Time is limited

## Migration from v3.x

If you previously used the monolithic `/code-review`:

| Old Behavior | New Approach |
|--------------|--------------|
| Single long report | Multiple focused reports + summary |
| artifacts/code-reviews/ | docs/audits/ |
| session-N-review.md | {type}-audit-NN.md |
| One checklist file | Built into each command |

The new system provides:
- More focused, actionable reports
- Better organization by audit type
- Easier to re-run specific audits
- Clearer remediation paths

---

**Version:** 4.0.0
