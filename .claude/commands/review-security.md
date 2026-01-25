---
name: review-security
description: Security audit of the codebase
---

# /review-security

Perform a security review of the codebase.

## Scope

Review the files in the Working Set (from `context/STATUS.md`), or if specified, a particular file/directory.

### Scope Expansion

If the Working Set lacks security-relevant files, expand to include:
- `**/auth/**`, `**/api/**`, `**/middleware/**`
- `**/lib/auth*`, `**/lib/session*`, `**/lib/validation*`
- `**/*.config.*`, `**/env*`

Consider running: `npm audit` (or equivalent) to check dependencies.

## What to Check

### Authentication & Authorization
- Proper authentication on protected routes
- Authorization checks before sensitive operations
- Session management security
- Token handling and storage

### Input Validation
- User input sanitization
- SQL injection prevention
- Command injection prevention
- Path traversal prevention

### Data Protection
- Sensitive data exposure in logs
- Secrets in code or config files
- Proper encryption for sensitive data
- Secure password handling

### API Security
- Rate limiting
- CORS configuration
- Input validation on endpoints
- Error message information leakage

### Dependencies
- Known vulnerabilities in dependencies
- Outdated packages with security issues

### Common Vulnerabilities
- XSS (Cross-Site Scripting)
- CSRF (Cross-Site Request Forgery)
- Insecure direct object references
- Security misconfiguration

## Output Format

```markdown
## Security Review

### Critical Issues
- [Issue]: [Description and location]

### Warnings
- [Issue]: [Description and location]

### Recommendations
- [Suggestion for improvement]

### Checked Areas
- [List of what was reviewed]
```

## Behavior

1. Read STATUS.md to understand current context (if it doesn't exist, suggest running `/init-context` first or ask user to specify scope)
2. Review files in Working Set (or specified scope)
3. Check against security criteria above
4. Produce report in specified format
5. Do NOT make changes - report only

## Done

Provide the security review report.
