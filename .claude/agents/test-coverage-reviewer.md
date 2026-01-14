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
    "presets": ["prelaunch", "backend"]
  }
}
```

## File Scope

This agent maps source files to test files using standard patterns:
- `[name].test.ts` / `[name].spec.ts`
- `test/[name].test.ts` / `__tests__/[name].test.ts`

## Purpose

Identify untested code with **verification**. Every finding must include evidence of the gap AND confirmation that no tests exist.

## Input

- Codebase context from `.claude/cache/codebase-context.json`
- Source-to-test file mapping
- Coverage reports if available

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
- Skipped tests (`test.skip`, `it.skip`)
- Empty assertions (`expect(true).toBe(true)`)
- Console.log in tests

## Guardrails

- **DO** search test/, __tests__, and *.test.* locations
- **DO** prioritize critical paths over 100% coverage
- **DO** consider indirect testing via integration tests
- **DO NOT** flag type definitions or interfaces
