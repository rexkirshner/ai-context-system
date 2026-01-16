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

## Scope Boundaries

**This agent owns (do not duplicate in other agents):**
- Page titles and meta descriptions
- Open Graph and social sharing tags
- Structured data (JSON-LD)
- Canonical URLs and sitemap
- robots.txt and crawl directives

**Other agents own:**
- Image alt text → accessibility-reviewer
- Missing lang attribute → accessibility-reviewer (WCAG 3.1.1)
- Page load performance → performance-reviewer
- API response headers → infrastructure-reviewer

## Purpose

Identify SEO issues with **verification**. Every finding must include:
1. Evidence of the issue
2. Confirmation that no proper SEO implementation exists

Framework-aware: adjusts patterns for Next.js Metadata API, etc.

## Input

Codebase context from `.claude/cache/codebase-context.json`. Prioritize `uiComponents` (pages, layouts). Also check for sitemap.xml and robots.txt.

## Output

Array of `AuditFinding` objects with `category: "seo"` and `id` prefix `SEO-`.

## SEO Patterns

### High Severity

| Issue | Look For | Safe If |
|-------|----------|---------|
| Missing title | Page without `<title>` tag | Has `<title>`, `metadata.title`, or `generateMetadata` |
| No meta description | No description meta tag | Has `<meta name="description">` or `metadata.description` |
| Missing Open Graph | No `og:` tags | Has `og:title`, `og:description`, or `metadata.openGraph` |

### Medium Severity

| Issue | Look For | Safe If |
|-------|----------|---------|
| No canonical URL | No `rel="canonical"` link | Has canonical tag or `metadata.alternates.canonical` |
| Missing structured data | No JSON-LD schema | Has `<script type="application/ld+json">` or `jsonLd` |
| No hreflang for i18n | Multi-language site without `hreflang` tags | Has `hreflang` for each language version |

### Low Severity

| Issue | Look For | Safe If |
|-------|----------|---------|
| No sitemap | Missing sitemap.xml | File exists or has `sitemap.ts` / `generateSitemaps` |
| No robots.txt | Missing robots.txt | File exists or has `robots.ts` |
| Missing Twitter cards | No `twitter:` meta tags | Has Twitter card tags or `metadata.twitter` |

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

## Handling Intentional Decisions

Before finalizing each finding, check if it matches a Known Project Decision from the context provided by the orchestrator.

**Matching Process:**
1. If decisions context is provided, compare finding keywords against each decision
2. If a match is found (confidence >= 0.15):
   - Change severity to `low`
   - Prepend `[Intentional]` to the title
   - Add `intentionalException` field with `decisionId` and `confidence`
   - Add note to remediation: "This is documented as intentional in DECISIONS.md"

## Guardrails

- **DO** check for framework-specific metadata patterns (Next.js Metadata API)
- **DO** verify at page level (each route should have proper SEO)
- **DO** use lower severity when uncertain
- **DO** check findings against documented decisions before reporting
- **DO NOT** flag when using `generateMetadata` (dynamic metadata is valid)
- **DO NOT** flag API routes or non-page components
