---
name: review-accessibility
description: Accessibility review of the codebase
---

# /review-accessibility

Perform an accessibility (a11y) review of the codebase.

## Scope

Review the files in the Working Set (from `context/STATUS.md`), or if specified, a particular file/directory. Focus on UI components and templates.

### Scope Expansion

If the Working Set lacks UI files, expand to include:
- `**/components/**/*.tsx`, `**/components/**/*.jsx`
- `**/app/**/page.tsx`, `**/app/**/layout.tsx`
- `**/pages/**/*.tsx`, `**/pages/**/*.jsx`
- `**/*.css`, `**/*.scss`, `**/styles/**`

Consider running: Lighthouse accessibility audit, axe-core, or pa11y.

## What to Check

### Semantic HTML
- Proper heading hierarchy (h1-h6)
- Semantic elements (nav, main, article, section)
- Lists for list content
- Tables for tabular data

### ARIA & Roles
- ARIA labels on interactive elements
- Proper role attributes
- Live regions for dynamic content
- ARIA states (expanded, selected, etc.)

### Keyboard Navigation
- All interactive elements focusable
- Logical focus order
- Visible focus indicators
- Skip links

### Forms
- Labels associated with inputs
- Error messages accessible
- Required fields indicated
- Autocomplete attributes

### Images & Media
- Alt text on images
- Decorative images marked appropriately
- Video captions/transcripts
- Audio descriptions

### Color & Contrast
- Sufficient color contrast
- Information not conveyed by color alone
- Focus indicators visible

### Motion & Timing
- Reduced motion support
- No auto-playing media
- Adequate time for interactions

## Output Format

```markdown
## Accessibility Review

### Critical Issues (WCAG A)
- [Issue]: [Description and location]

### Important Issues (WCAG AA)
- [Issue]: [Description and location]

### Recommendations (WCAG AAA / Best Practice)
- [Suggestion for improvement]

### Good Patterns Found
- [Pattern]: [Where it's used well]

### Checked Areas
- [List of what was reviewed]
```

## Behavior

1. Read STATUS.md to understand current context (if it doesn't exist, suggest running `/init-context` first or ask user to specify scope)
2. Review UI files in Working Set (or specified scope)
3. Check against accessibility criteria above
4. Produce report in specified format
5. Do NOT make changes - report only

## Done

Provide the accessibility review report.
