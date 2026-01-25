---
name: review-seo
description: SEO review of the codebase
---

# /review-seo

Perform an SEO review of the codebase.

## Scope

Review the files in the Working Set (from `context/STATUS.md`), or if specified, a particular file/directory. Focus on pages, templates, and routing.

### Scope Expansion

If the Working Set lacks SEO-relevant files, expand to include:
- `**/app/**/page.tsx`, `**/app/**/layout.tsx`
- `**/pages/**/*.tsx`, `**/pages/**/*.jsx`
- `**/components/**/Head*`, `**/components/**/Meta*`
- `**/public/robots.txt`, `**/public/sitemap*`
- `**/next.config.*`, `**/next-sitemap.config.*`

Consider running: Lighthouse SEO audit, Google Search Console, or screaming frog.

## What to Check

### Meta Tags
- Title tags (unique, descriptive, <60 chars)
- Meta descriptions (unique, compelling, <160 chars)
- Canonical URLs
- Open Graph / social meta tags
- Robots meta directives

### Structure & Markup
- Proper heading hierarchy
- Structured data (JSON-LD, Schema.org)
- Semantic HTML
- Breadcrumbs

### URLs & Routing
- Clean, readable URLs
- Proper 301 redirects
- 404 handling
- URL parameters handling

### Performance (SEO impact)
- Core Web Vitals considerations
- Image optimization
- Lazy loading
- Critical rendering path

### Content
- Unique content per page
- Proper content hierarchy
- Internal linking structure
- Alt text for images

### Technical SEO
- XML sitemap
- Robots.txt
- Hreflang for internationalization
- Mobile responsiveness
- HTTPS

## Output Format

```markdown
## SEO Review

### Critical Issues
- [Issue]: [Description and location]

### Important Issues
- [Issue]: [Description and location]

### Recommendations
- [Suggestion for improvement]

### Good Patterns Found
- [Pattern]: [Where it's used well]

### Checked Areas
- [List of what was reviewed]
```

## Behavior

1. Read STATUS.md to understand current context (if it doesn't exist, suggest running `/init-context` first or ask user to specify scope)
2. Review relevant files in Working Set (or specified scope)
3. Check against SEO criteria above
4. Produce report in specified format
5. Do NOT make changes - report only

## Done

Provide the SEO review report.
