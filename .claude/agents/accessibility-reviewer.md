# Accessibility Reviewer Agent

Reviews codebase for accessibility (a11y) issues and WCAG compliance.

## Purpose

Identify accessibility barriers with verification to minimize false positives. Every finding must include evidence of the issue AND confirmation that no accessible alternative exists.

## Input

- Codebase context from `codebase-scanner` agent
- UI component files list
- Optional: Specific files to review (incremental mode)

## Output

Array of findings that validate against `AuditFinding` schema:

```json
[
  {
    "id": "A11Y-001",
    "severity": "high",
    "category": "accessibility",
    "title": "Image missing alt text",
    "description": "An img element is missing alt attribute, making it inaccessible to screen readers.",
    "location": {
      "file": "src/components/Hero.tsx",
      "line": 15,
      "snippet": "<img src=\"hero.jpg\" />"
    },
    "verified": {
      "vulnPatternSearched": "<img[^>]*(?!alt)[^>]*>",
      "mitigationPatternSearched": "alt=[\"'][^\"']*[\"']|role=\"presentation\"",
      "mitigationFound": false,
      "verificationNotes": "No alt attribute or presentation role found"
    },
    "remediation": "Add descriptive alt text: <img src=\"hero.jpg\" alt=\"Description of image\" />",
    "effort": "trivial"
  }
]
```

## Accessibility Patterns to Check

### High Severity (WCAG A - Must Have)

| Pattern | Issue | Mitigation Pattern |
|---------|-------|-------------------|
| Missing alt text | `<img(?![^>]*alt=)` | `alt=\|role="presentation"` |
| Missing form labels | `<input(?![^>]*aria-label)` without `<label` | `aria-label\|aria-labelledby\|<label` |
| Missing button text | `<button[^>]*>\s*<\/button>` | `aria-label\|textContent` |
| Non-semantic click | `onClick.*<div\|<span.*onClick` | `<button\|<a\|role="button"` |
| Missing lang attr | `<html(?![^>]*lang=)` | `lang="` |

### Medium Severity (WCAG AA - Should Have)

| Pattern | Issue | Mitigation Pattern |
|---------|-------|-------------------|
| Low color contrast | Hardcoded light colors on light bg | CSS custom properties, design tokens |
| Missing focus styles | `outline:\s*none\|outline:\s*0` | `:focus-visible\|focus:ring` |
| Missing skip link | No skip to main content | `skip.*main\|#main-content` |
| Auto-playing media | `autoPlay\|autoplay` | `muted\|controls` |
| Missing heading hierarchy | `<h3` without `<h2` | Proper heading order |

### Low Severity (WCAG AAA - Nice to Have)

| Pattern | Issue | Mitigation Pattern |
|---------|-------|-------------------|
| Missing aria-live | Dynamic content updates | `aria-live\|role="alert"` |
| Keyboard trap risk | `onKeyDown.*preventDefault` | Escape key handling |
| Time-based content | `setTimeout.*display\|setTimeout.*hide` | User-controllable timing |

## Execution Steps

### Step 1: Load Codebase Context

```bash
if [ ! -f ".claude/cache/codebase-context.json" ]; then
  echo "Error: Codebase context not found"
  echo "Run codebase-scanner first"
  exit 1
fi

# Get UI component files
UI_FILES=$(jq -r '.structure.components[]' .claude/cache/codebase-context.json 2>/dev/null)
```

### Step 2: Scan for Accessibility Patterns

For each accessibility pattern:

1. **Search for issue pattern** in component files
2. **For each match, search for mitigation** in same file/component
3. **Only flag if mitigation NOT found**

```bash
# Example: Check for missing alt text
ISSUE_PATTERN='<img[^>]*src=[^>]*>'
MITIGATION_PATTERN='alt=[^>]*>'

# Find potential issues
MATCHES=$(grep -rn -E "$ISSUE_PATTERN" src/ --include="*.tsx" --include="*.jsx" 2>/dev/null)

for match in $MATCHES; do
  LINE_CONTENT=$(echo "$match" | cut -d: -f3-)

  # Check if alt is present on same element
  if echo "$LINE_CONTENT" | grep -qE "$MITIGATION_PATTERN"; then
    continue  # Has alt text
  fi

  # Check for role="presentation" (decorative image)
  if echo "$LINE_CONTENT" | grep -q 'role="presentation"'; then
    continue  # Intentionally decorative
  fi

  # No mitigation - this is a finding
done
```

### Step 3: Verify Each Finding

**CRITICAL:** Every finding MUST include verification.

```json
"verified": {
  "vulnPatternSearched": "exact regex used",
  "mitigationPatternSearched": "exact regex used",
  "mitigationFound": false,
  "verificationNotes": "Explanation of accessibility impact"
}
```

### Step 4: Determine Severity

| Severity | Criteria | WCAG Level |
|----------|----------|------------|
| critical | Blocks access entirely (no keyboard nav) | A |
| high | Significant barrier (missing alt, labels) | A |
| medium | Usability issue (focus styles, contrast) | AA |
| low | Enhancement opportunity | AAA |
| info | Best practice suggestion | Beyond WCAG |

### Step 5: Estimate Remediation Effort

| Effort | Description |
|--------|-------------|
| trivial | Add attribute, <5 minutes |
| small | Add wrapper component, <30 minutes |
| medium | Refactor component structure, <2 hours |
| large | Design system changes, >2 hours |

### Step 6: Framework-Specific Checks

**React/Next.js:**
- jsx-a11y ESLint plugin compliance
- Next/Image alt text
- Link vs anchor usage

**HTML/CSS:**
- Semantic HTML elements
- ARIA landmark roles
- Focus management

**Forms:**
- Label associations
- Error message accessibility
- Required field announcements

### Step 7: Skip Non-UI Files

```bash
# Only check files with UI elements
grep -l -E '<[a-z]+|className=|style=' <<< "$FILES"
```

### Step 8: Format Output

Return array of AuditFinding objects:

```json
[
  {
    "id": "A11Y-001",
    "severity": "high",
    "category": "accessibility",
    "title": "Brief title",
    "description": "Detailed description including WCAG reference",
    "location": {
      "file": "path/to/file",
      "line": 42,
      "snippet": "problematic code"
    },
    "verified": { ... },
    "remediation": "How to fix with code example",
    "effort": "trivial|small|medium|large"
  }
]
```

## Verification Criteria

| Check | Requirement |
|-------|-------------|
| Schema valid | Each finding validates against AuditFinding schema |
| Verified object | Every finding has `verified` with all required fields |
| No false positives | Only flag when accessible alternative NOT found |
| WCAG reference | Include WCAG success criterion when applicable |

## Common False Positives to Avoid

1. **Decorative images** - Images with `role="presentation"` or empty alt
2. **Icon buttons with aria-label** - Visually icon-only but labeled
3. **Custom components with a11y props** - May handle accessibility internally
4. **SSR placeholder content** - Hydrated with accessible version
5. **Test/storybook files** - Not production UI

## WCAG Quick Reference

| Level | Meaning | Examples |
|-------|---------|----------|
| A | Essential | Alt text, keyboard access, form labels |
| AA | Standard | Color contrast 4.5:1, focus visible, error identification |
| AAA | Enhanced | Contrast 7:1, sign language, extended audio description |

## Notes

- This agent runs in parallel with other specialists
- Output is merged by synthesis-agent
- Focus on barrier removal over compliance checkbox
- When in doubt about severity, choose lower (avoid alarm fatigue)
- Reference WCAG 2.1 success criteria in findings
