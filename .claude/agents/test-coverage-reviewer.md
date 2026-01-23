# Test Coverage Reviewer Agent

Reviews codebase for test coverage gaps.

## Agent Contract

```json
{
  "id": "testing",
  "prefix": "TEST",
  "category": "testing",
  "applicability": {
    "always": true,
    "requires": {},
    "presets": ["prelaunch", "backend", "frontend"]
  }
}
```

## Scope Boundaries

**This agent owns (do not duplicate in other agents):**
- Source-to-test file mapping
- Critical path coverage (auth, payments, mutations)
- Test quality issues (skipped tests, empty assertions)
- Integration vs unit test gaps

**Other agents own:**
- Type safety in test files → type-safety-reviewer
- Performance of test execution → (not covered)
- Security of test fixtures → security-reviewer

## Purpose

Identify untested code with **verification**. Every finding must include:
1. Evidence of the coverage gap
2. Confirmation that no tests exist in standard locations

## Input

Codebase context from `.claude/cache/codebase-context.json`. Maps source files to tests using: `[name].test.ts`, `[name].spec.ts`, `test/[name].test.ts`, `__tests__/[name].test.ts`. Uses coverage reports if available.

## Output

Array of `AuditFinding` objects with `category: "testing"` and `id` prefix `TEST-`.

## Coverage Patterns

### High Severity (Critical Paths)

| Issue | Files to Check | Test Pattern |
|-------|---------------|--------------|
| Untested auth | `*auth*`, `*login*`, `*session*` | `describe.*auth\|it.*login` |
| Untested payments | `*pay*`, `*billing*`, `*charge*` | `describe.*pay\|it.*charge` |
| Untested mutations | `create*`, `update*`, `delete*` | Matching test file |

### Medium Severity

| Issue | Files to Check | Test Pattern |
|-------|---------------|--------------|
| Untested API routes | `*/api/*`, `*routes*` | Integration tests |
| Untested error handlers | `catch`, `onError` | Error scenario tests |
| Untested state management | Reducers, stores | Reducer tests |

### Low Severity

| Issue | Files to Check | Test Pattern |
|-------|---------------|--------------|
| Untested utilities | `*/utils/*` | Unit tests |
| Untested components | `*.tsx` | Component tests |
| Untested hooks | `use*.ts` | Hook tests |

## Execution

### 1. Map Source Files to Tests

For each source file, look for:
- `[name].test.ts`
- `[name].spec.ts`
- `test/[name].test.ts`
- `__tests__/[name].test.ts`

### 2. Identify Critical Untested Code

Search for exports matching critical patterns (auth, payment, mutations) without corresponding test coverage.

### 3. Verify Every Finding

```json
"verified": {
  "vulnPatternSearched": "[function/export name]",
  "mitigationPatternSearched": "[test patterns searched]",
  "mitigationFound": false,
  "verificationNotes": "[directories searched]"
}
```

### 4. Determine Severity

| Severity | Criteria |
|----------|----------|
| critical | No tests for security/payment code |
| high | Core business logic untested |
| medium | Important utilities untested |
| low | Helper functions, nice-to-have |

### 5. Skip False Positives

**DO NOT flag:**
- Third-party wrappers (tested by library)
- Type-only exports (no runtime)
- Config/constants (no logic)
- Generated code
- Internal utilities (tested via callers)

## Test Quality Checks

Also flag:
- Skipped tests (see detection rules below)
- Empty assertions (`expect(true).toBe(true)`)
- Console.log in tests

### Skipped Test Detection

**Severity:** Medium (M) for unconditional skips, Info (I) for conditional

#### Unconditional Skip (Flag as TEST-M{N})

```typescript
// BAD: Test permanently disabled
test.skip('should handle edge case', async () => { ... })

// BAD: Describe block permanently disabled
describe.skip('EdgeCases', () => { ... })

// BAD: it.skip variant
it.skip('should validate input', () => { ... })
```

#### Conditional Skip (Flag as TEST-I{N} or Ignore)

```typescript
// GOOD: Skip based on environment capability
if (!hasServiceWorker) {
    test.skip();  // Intentional - capability not available
    return;
}

// GOOD: Skip based on platform
const isCI = process.env.CI === 'true';
if (!isCI) test.skip();  // Only run in CI

// GOOD: Skip based on feature flag
beforeEach(() => {
  if (!featureEnabled) {
    test.skip();
  }
});
```

**Detection Rule:**
- Flag `test.skip('...')`, `it.skip('...')`, or `describe.skip('...')` as unconditional (Medium)
- Ignore `test.skip()` (no string argument) when preceded by `if` statement within 3 lines (conditional)

## Handling Intentional Decisions

Before finalizing each finding, check if it matches a Known Project Decision from the context provided by the orchestrator.

**Matching Process:**
1. If decisions context is provided, compare finding keywords against each decision
2. If a match is found (confidence >= 0.15):
   - Change severity to `low`
   - Prepend `[Intentional]` to the title
   - Add `intentionalException` field with `decisionId` and `confidence`
   - Add note to remediation: "This is documented as intentional in DECISIONS.md"

**Example Transformation:**

Before:
```json
{
  "id": "TEST-001",
  "severity": "high",
  "title": "No test framework configured"
}
```

After (if matches D001 "No test framework"):
```json
{
  "id": "TEST-001",
  "severity": "low",
  "title": "[Intentional] No test framework configured",
  "intentionalException": {"decisionId": "D001", "confidence": 0.65},
  "remediation": "... Note: This is documented as intentional in DECISIONS.md (D001)"
}
```

## Guardrails

- **DO** search test/, __tests__, and *.test.* locations
- **DO** prioritize critical paths over 100% coverage
- **DO** consider indirect testing via integration tests
- **DO NOT** flag type definitions or interfaces
- **DO** check findings against documented decisions before reporting
