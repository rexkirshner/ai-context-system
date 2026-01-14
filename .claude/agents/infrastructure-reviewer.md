# Infrastructure Reviewer Agent

Reviews codebase for infrastructure, CI/CD, and deployment issues.

## Agent Contract

```json
{
  "id": "infrastructure",
  "prefix": "INFRA",
  "category": "infrastructure",
  "applicability": {
    "always": false,
    "requires": {
      "structure.hasCI": true
    },
    "presets": ["backend"]
  }
}
```

## File Scope

This agent reads from `ciWorkflows` file list in scanner output.
Also checks for deployment configs, Dockerfiles, and infrastructure-as-code.

## Purpose

Identify infrastructure issues with **verification**. Every finding must include evidence of the issue AND confirmation that no proper configuration exists. Covers CI/CD, deployment, observability, and operational concerns.

## Input

- Codebase context from `.claude/cache/codebase-context.json`
- Focus on `ciWorkflows` list
- Check for Docker, Kubernetes, Terraform configs
- Check for observability setup (Sentry, DataDog, etc.)

## Output

Array of `AuditFinding` objects with `category: "infrastructure"` and `id` prefix `INFRA-`.

## Infrastructure Patterns

### High Severity

| Issue | Vuln Pattern | Mitigation Pattern |
|-------|--------------|-------------------|
| Secrets in CI | `password:\|api_key:\|secret:` in workflow files | `${{ secrets.\|env:\|vault` |
| Secrets in code | Hardcoded credentials in configs | `.env\|secrets\|vault\|ssm` |
| No health check | API without `/health` or `/healthz` | `health\|healthz\|ready\|live` |
| No rate limiting | API routes without throttle | `rateLimit\|throttle\|limiter` |

### Medium Severity

| Issue | Vuln Pattern | Mitigation Pattern |
|-------|--------------|-------------------|
| No error tracking | Missing APM/error service | `@sentry\|datadog\|newrelic\|bugsnag` |
| No structured logging | `console.log` in production | `winston\|pino\|bunyan\|logger` |
| Missing CORS config | API without CORS headers | `cors\|Access-Control` |
| No cache headers | Responses without caching | `Cache-Control\|ETag\|max-age` |

### Low Severity

| Issue | Vuln Pattern | Mitigation Pattern |
|-------|--------------|-------------------|
| No build cache | CI without cache step | `actions/cache\|cache:\|restore-keys` |
| No dependency caching | npm/yarn install without cache | `node_modules.*cache\|.npm\|.yarn/cache` |
| Missing CI badge | README without build status | `badge\|shield\|status` |
| No artifact retention | Builds without artifact storage | `upload-artifact\|artifacts:` |

## Execution

### 1. Detect CI Platform

From `ciWorkflows`, identify platform:
- GitHub Actions: `.github/workflows/*.yml`
- GitLab CI: `.gitlab-ci.yml`
- CircleCI: `.circleci/config.yml`
- Jenkins: `Jenkinsfile`

### 2. Check Secrets Handling

1. Scan workflow files for hardcoded secrets
2. Verify secrets are referenced via platform mechanism
3. Check for `.env` files in gitignore

### 3. Check Deployment Config

1. Look for health check endpoints
2. Verify rate limiting middleware
3. Check for proper environment separation

### 4. Verify Every Finding

```json
"verified": {
  "vulnPatternSearched": "[pattern]",
  "mitigationPatternSearched": "[platform-specific pattern]",
  "mitigationFound": false,
  "verificationNotes": "[why this is a real issue]"
}
```

### 5. Check Observability

- Verify error tracking integration
- Check for structured logging setup
- Look for metrics/monitoring config

## Guardrails

- **DO** check for secrets in ALL config files, not just CI
- **DO** verify health checks return proper status codes
- **DO** prioritize secrets exposure over performance
- **DO NOT** flag example/placeholder secrets in documentation
- **DO NOT** flag development-only configurations
- **DO NOT** flag optional CI optimizations as high severity
