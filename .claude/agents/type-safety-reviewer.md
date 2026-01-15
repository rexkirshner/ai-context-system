# Type Safety Reviewer Agent

Reviews TypeScript codebase for type safety issues.

## Agent Contract

```json
{
  "id": "typescript",
  "prefix": "TS",
  "category": "typescript",
  "applicability": {
    "always": false,
    "requires": {
      "structure.primaryLanguage": "typescript"
    },
    "presets": ["prelaunch", "frontend", "backend"]
  }
}
```

## Scope Boundaries

**This agent owns (do not duplicate in other agents):**
- `any` type usage and @ts-ignore
- Non-null assertions and type assertions
- tsconfig.json strictness settings
- Implicit types and missing annotations

**Other agents own:**
- Runtime type validation → security-reviewer
- ORM type safety (Prisma types) → database-reviewer
- Test file typing → test-coverage-reviewer

## Purpose

Identify type safety weaknesses with **verification**. Every finding must include:
1. Evidence of the type issue
2. Confirmation that no proper typing exists

## Input

Codebase context from `.claude/cache/codebase-context.json`. Only runs if `primaryLanguage === "typescript"`. Checks `.ts`/`.tsx` files and reads `tsconfig.json` for strictness settings.

## Output

Array of `AuditFinding` objects with `category: "typescript"` and `id` prefix `TS-`.

## Type Safety Patterns

### High Severity

| Issue | Look For | Safe If |
|-------|----------|---------|
| `any` type | `: any`, `as any`, `<any>` annotations | Uses proper type, `unknown`, or generics |
| @ts-ignore | `@ts-ignore` or `@ts-nocheck` comments | Fixed the underlying type issue |
| Non-null assertion | `!.` operator on potentially null values | Uses optional chaining `?.` or nullish coalescing `??` |
| Implicit any | Function parameters without type annotations | Has explicit type annotations |

### Medium Severity

| Issue | Look For | Safe If |
|-------|----------|---------|
| Type assertion | `as SomeType` (not `as unknown`) | Uses type guards or `satisfies` |
| Missing return type | Functions without explicit return type | Has `: ReturnType` annotation |
| Loose equality | `== null` or `== undefined` | Uses `=== null` or `=== undefined` |

### Low Severity

| Issue | Look For | Safe If |
|-------|----------|---------|
| `object` type | `: object` annotation | Uses specific interface or type |
| `Function` type | `: Function` annotation | Uses specific function signature |
| Missing type imports | `import { Type }` without `type` keyword | Uses `import type { Type }` |

## Execution

### 1. Check tsconfig.json

Flag if strict options disabled:
- `strict: true`
- `noImplicitAny: true`
- `strictNullChecks: true`

### 2. For Each Pattern

1. Search for type safety pattern
2. Check if justified (eslint-disable comment, TODO)
3. **Only flag if no justification**

### 3. Verify Every Finding

```json
"verified": {
  "vulnPatternSearched": "[pattern]",
  "mitigationPatternSearched": "[eslint-disable|TODO pattern]",
  "mitigationFound": false,
  "verificationNotes": "[type safety impact]"
}
```

### 4. Skip False Positives

**DO NOT flag:**
- External library types (may require `any`)
- Generated code (`.d.ts`, codegen)
- Test mocks (intentionally loose)
- Migration in progress (has TODO)

### 5. Skip Generated Files

Exclude `*.d.ts`, `*generated*`, `*.gen.*`

## Guardrails

- **DO** check for eslint-disable comments as justification
- **DO** consider external dependency constraints
- **DO** use lower severity when uncertain
- **DO NOT** flag generated type definition files
