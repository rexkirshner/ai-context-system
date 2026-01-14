# SEO Reviewer Agent

Reviews codebase for SEO (Search Engine Optimization) issues.

## Agent Contract

```json
{
  "id": "seo",
  "prefix": "SEO",
  "category": "seo",
  "applicability": {
    "always": false,
    "requires": {
      "structure.hasUI": true,
      "structure.projectType:in": ["webapp", "monorepo"]
    },
    "presets": ["prelaunch", "frontend"]
  }
}
```

## File Scope

This agent reads from `uiComponents` file list in scanner output.
Focuses on page components, layouts, and metadata files.

## Purpose

Identify SEO issues with **verification**. Every finding must include evidence of the issue AND confirmation that no proper SEO implementation exists. Framework-aware patterns avoid false positives for Next.js Metadata API, etc.

## Input

- Codebase context from `.claude/cache/codebase-context.json`
- Focus on `uiComponents` files (pages, layouts)
- Check for sitemap.xml, robots.txt presence

## Output

Array of `AuditFinding` objects with `category: "seo"` and `id` prefix `SEO-`.

## SEO Patterns

### High Severity

| Issue | Vuln Pattern | Mitigation Pattern |
|-------|--------------|-------------------|
| Missing title | `<head>` without `<title>` | `<title>\|metadata.*title\|generateMetadata` |
| No meta description | No description meta tag | `meta.*description\|metadata.*description\|generateMetadata` |
| Missing Open Graph | No `og:` tags for social sharing | `og:\|openGraph\|metadata.*openGraph` |

### Medium Severity

| Issue | Vuln Pattern | Mitigation Pattern |
|-------|--------------|-------------------|
| No canonical URL | No `rel="canonical"` | `canonical\|metadata.*canonical\|alternates` |
| Missing structured data | No JSON-LD | `ld\+json\|jsonLd\|application/ld` |
| No lang attribute | `<html>` without `lang` | `lang=\|htmlAttributes.*lang` |

### Low Severity

| Issue | Vuln Pattern | Mitigation Pattern |
|-------|--------------|-------------------|
| No sitemap | Missing sitemap.xml | File exists OR `generateSitemaps\|sitemap.ts` |
| No robots.txt | Missing robots.txt | File exists OR `robots.ts` |
| Missing alt text | `<img>` without `alt` | `alt=` attribute present |

## Execution

### 1. Check Framework

Read `structure.frameworks` from scanner output. Adjust patterns:
- **Next.js App Router**: Check for `metadata` export or `generateMetadata` function
- **Next.js Pages Router**: Check for `Head` component usage
- **Standard HTML**: Check for `<head>` tags directly

### 2. For Each Pattern

1. Search for SEO issue pattern
2. Search for framework-appropriate mitigation
3. **Only flag if mitigation NOT found**

### 3. Verify Every Finding

```json
"verified": {
  "vulnPatternSearched": "[pattern]",
  "mitigationPatternSearched": "[pattern including framework-specific]",
  "mitigationFound": false,
  "verificationNotes": "[why this is a real issue]"
}
```

### 4. Check Global Files

- Verify sitemap.xml or sitemap generation exists
- Verify robots.txt or robots generation exists
- Check for manifest.json/webmanifest

## Guardrails

- **DO** check for framework-specific metadata patterns (Next.js Metadata API)
- **DO** verify at page level (each route should have proper SEO)
- **DO** use lower severity when uncertain
- **DO NOT** flag when using `generateMetadata` (dynamic metadata is valid)
- **DO NOT** flag API routes or non-page components
