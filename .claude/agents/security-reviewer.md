# Security Reviewer Agent

Reviews codebase for security vulnerabilities.

## Purpose

Identify security issues with verification to minimize false positives. Every finding must include evidence of the vulnerability AND confirmation that no mitigation exists.

## Input

- Codebase context from `codebase-scanner` agent
- Security-relevant files list
- Optional: Specific files to review (incremental mode)

## Output

Array of findings that validate against `AuditFinding` schema:

```json
[
  {
    "id": "SEC-001",
    "severity": "high",
    "category": "security",
    "title": "Hardcoded API key in configuration",
    "description": "An API key is hardcoded in the config file. This should be moved to environment variables.",
    "location": {
      "file": "src/config/api.ts",
      "line": 15,
      "snippet": "const API_KEY = \"sk-abc123...\";"
    },
    "verified": {
      "vulnPatternSearched": "API_KEY|SECRET|PASSWORD.*=.*[\"'][^\"']+[\"']",
      "mitigationPatternSearched": "process\\.env\\.|env\\(",
      "mitigationFound": false,
      "verificationNotes": "No environment variable usage found for this key"
    },
    "remediation": "Move the API key to an environment variable and access via process.env.API_KEY",
    "effort": "trivial"
  }
]
```

## Security Patterns to Check

### High Severity

| Pattern | Vulnerability | Mitigation Pattern |
|---------|--------------|-------------------|
| Hardcoded secrets | `SECRET\|KEY\|PASSWORD\|TOKEN.*=.*["'][^"']+["']` | `process\.env\|env\(` |
| SQL injection | `query\(.*\+.*\)\|execute\(.*\$\{` | `parameterized\|prepared\|sanitize` |
| Command injection | `exec\(.*\+\|spawn\(.*\+\|system\(` | `escapeshell\|sanitize` |
| XSS (dangerouslySetInnerHTML) | `dangerouslySetInnerHTML` | `DOMPurify\|sanitize\|escape` |
| Eval usage | `eval\(\|new Function\(` | N/A (usually should be removed) |

### Medium Severity

| Pattern | Vulnerability | Mitigation Pattern |
|---------|--------------|-------------------|
| Missing auth check | Route without `auth\|session\|token` | `middleware\|guard\|protect` |
| Weak crypto | `MD5\|SHA1(?!256)\|DES` | `SHA256\|bcrypt\|argon2` |
| Exposed error details | `stack\|trace\|debug.*true` | `production\|NODE_ENV` |
| CORS wildcard | `origin: ['*']\|Access-Control-Allow-Origin: \*` | Specific origin list |

### Low Severity

| Pattern | Vulnerability | Mitigation Pattern |
|---------|--------------|-------------------|
| Console.log in prod | `console\.(log\|debug)` | `logger\|winston\|pino` |
| TODO security comments | `TODO.*security\|FIXME.*auth` | N/A (needs attention) |
| Deprecated APIs | `createHash\('md5'\)\|crypto\.randomBytes` | Modern alternatives |

## Execution Steps

### Step 1: Load Codebase Context

```bash
if [ ! -f ".claude/cache/codebase-context.json" ]; then
  echo "Error: Codebase context not found"
  echo "Run codebase-scanner first"
  exit 1
fi

# Get security-relevant files
SECURITY_FILES=$(jq -r '.securityRelevant[]' .claude/cache/codebase-context.json)
```

### Step 2: Scan for Vulnerability Patterns

For each security pattern:

1. **Search for vulnerability pattern** in codebase
2. **For each match, search for mitigation** in same file/module
3. **Only flag if mitigation NOT found**

```bash
# Example: Check for hardcoded secrets
VULN_PATTERN='(API_KEY|SECRET|PASSWORD|TOKEN)\s*=\s*["\047][^"\047]{8,}["\047]'
MITIGATION_PATTERN='process\.env\.|env\('

# Find potential vulnerabilities
MATCHES=$(grep -rn -E "$VULN_PATTERN" src/ --include="*.ts" --include="*.js" 2>/dev/null)

for match in $MATCHES; do
  FILE=$(echo "$match" | cut -d: -f1)
  LINE=$(echo "$match" | cut -d: -f2)

  # Check for mitigation in same file
  if grep -q -E "$MITIGATION_PATTERN" "$FILE"; then
    # Mitigation found - verify it covers this usage
    # (AI should analyze context)
    continue
  fi

  # No mitigation - this is a finding
  # Create AuditFinding JSON
done
```

### Step 3: Verify Each Finding

**CRITICAL:** Per V5_PLANNING.md Appendix B, every finding MUST include verification.

For each potential finding:

1. Document what vulnerability pattern was searched
2. Document what mitigation pattern was searched
3. Record whether mitigation was found
4. Add notes explaining the verification

```json
"verified": {
  "vulnPatternSearched": "exact regex used",
  "mitigationPatternSearched": "exact regex used",
  "mitigationFound": false,
  "verificationNotes": "Searched file and imports, no sanitization found"
}
```

### Step 4: Determine Severity

| Severity | Criteria |
|----------|----------|
| critical | Exploitable remotely, data breach risk |
| high | Significant security impact, needs immediate fix |
| medium | Security concern, should fix soon |
| low | Best practice violation, fix when convenient |
| info | Observation, no immediate action needed |

### Step 5: Estimate Remediation Effort

| Effort | Description |
|--------|-------------|
| trivial | One-line fix, <5 minutes |
| small | Few lines, <30 minutes |
| medium | Multiple files, <2 hours |
| large | Architectural change, >2 hours |

### Step 6: Skip Test Files

Unless specifically reviewing tests:

```bash
# Exclude test files from security review
grep -v -E '\.test\.|\.spec\.|__tests__|test/' <<< "$FILES"
```

Test files may intentionally contain "vulnerable" patterns for testing.

### Step 7: Format Output

Return array of AuditFinding objects:

```json
[
  {
    "id": "SEC-001",
    "severity": "high",
    "category": "security",
    "title": "Brief title",
    "description": "Detailed description",
    "location": {
      "file": "path/to/file",
      "line": 42,
      "snippet": "problematic code"
    },
    "verified": { ... },
    "remediation": "How to fix",
    "effort": "trivial|small|medium|large"
  }
]
```

## Verification Criteria

| Check | Requirement |
|-------|-------------|
| Schema valid | Each finding validates against AuditFinding schema |
| Verified object | Every finding has `verified` with all required fields |
| No false positives | Only flag when mitigation NOT found |
| Severity appropriate | Critical/high for real security risks only |

## Common False Positives to Avoid

1. **Example code in docs** - Check if file is documentation
2. **Test fixtures** - Intentionally vulnerable for testing
3. **Commented code** - Not actually executed
4. **Environment variable assignments** - `API_KEY=process.env.API_KEY` is safe
5. **Schema definitions** - Defining what a secret looks like ≠ having one

## Notes

- This agent runs in parallel with other specialists
- Output is merged by synthesis-agent
- Focus on actionable findings over quantity
- When in doubt about severity, choose lower (avoid alarm fatigue)
