# Accessibility Reviewer Agent

Reviews codebase for accessibility (a11y) issues.

## Agent Contract

```json
{
  "id": "accessibility",
  "prefix": "A11Y",
  "category": "accessibility",
  "applicability": {
    "always": false,
    "requires": {
      "structure.hasUI": true
    },
    "presets": ["prelaunch", "frontend"]
  }
}
```

## File Scope

This agent reads from `uiComponents` file list in scanner output.
Focuses on `.tsx` and `.jsx` files.

## Purpose

Identify accessibility barriers with **verification**. Every finding must include evidence of the issue AND confirmation that no accessible alternative exists.

## Input

- Codebase context from `.claude/cache/codebase-context.json`
- Focus on React/UI components (`.tsx`, `.jsx`)

## Output

Array of `AuditFinding` objects with `category: "accessibility"` and `id` prefix `A11Y-`.

## Accessibility Patterns

### High Severity (WCAG A - Required)

| Issue | Pattern | Mitigation |
|-------|---------|------------|
| Missing alt text | `<img(?![^>]*alt=)` | `alt=\|role="presentation"` |
| Missing form labels | `<input(?![^>]*aria-label)` | `aria-label\|<label` |
| Empty buttons | `<button[^>]*>\s*<\/button>` | `aria-label\|textContent` |
| Non-semantic click | `onClick.*<div\|<span.*onClick` | `<button\|role="button"` |
| Missing lang | `<html(?![^>]*lang=)` | `lang="` |

### Medium Severity (WCAG AA - Standard)

| Issue | Pattern | Mitigation |
|-------|---------|------------|
| No focus styles | `outline:\s*none` | `:focus-visible\|focus:ring` |
| Auto-play media | `autoPlay` | `muted\|controls` |
| Missing skip link | No skip to main | `skip.*main\|#main-content` |

### Low Severity (WCAG AAA - Enhanced)

| Issue | Pattern | Mitigation |
|-------|---------|------------|
| Missing aria-live | Dynamic updates | `aria-live\|role="alert"` |
| Keyboard trap | `onKeyDown.*preventDefault` | Escape handling |

## Execution

### 1. For Each Pattern

1. Search for accessibility issue pattern in components
2. Search for mitigation on same element/component
3. **Only flag if mitigation NOT found**

### 2. Verify Every Finding

```json
"verified": {
  "vulnPatternSearched": "[pattern]",
  "mitigationPatternSearched": "[pattern]",
  "mitigationFound": false,
  "verificationNotes": "[WCAG criterion violated]"
}
```

### 3. Map Severity to WCAG

| Severity | WCAG Level |
|----------|------------|
| critical | A - Blocks access entirely |
| high | A - Significant barrier |
| medium | AA - Usability issue |
| low | AAA - Enhancement |

### 4. Skip False Positives

**DO NOT flag:**
- Decorative images (`role="presentation"`, empty alt)
- Icon buttons with aria-label
- SSR placeholders (hydrated with a11y)
- Test/storybook files

## WCAG Quick Reference

| Level | Requirement |
|-------|-------------|
| A | Alt text, keyboard access, form labels |
| AA | 4.5:1 contrast, focus visible, error identification |
| AAA | 7:1 contrast, extended descriptions |

## Guardrails

- **DO** reference WCAG success criteria in findings
- **DO** check for aria-* attributes as mitigation
- **DO** focus on barrier removal over compliance
- **DO NOT** flag decorative images without alt
