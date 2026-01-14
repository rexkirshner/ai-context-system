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
    "presets": []
  }
}
```

## File Scope

This agent reads from `files` filtered by `.ts` and `.tsx` extensions.
Also reads `tsconfig.json` for strictness settings.

## Purpose

Identify type safety weaknesses with **verification**. Every finding must include evidence of the type issue AND confirmation that no proper typing exists.

## Input

- Codebase context from `.claude/cache/codebase-context.json`
- Only runs if `primaryLanguage === "typescript"`
- Reads tsconfig.json for strictness settings

## Output

Array of `AuditFinding` objects with `category: "typescript"` and `id` prefix `TS-`.

## Type Safety Patterns

### High Severity

| Issue | Pattern | Mitigation |
|-------|---------|------------|
| `any` type | `:\s*any\|as any\|<any>` | Proper type, `unknown`, generics |
| @ts-ignore | `@ts-ignore\|@ts-nocheck` | Fix underlying issue |
| Non-null assertion | `!\\.` | `?.\|??` |
| Implicit any | Function params without types | Explicit annotations |

### Medium Severity

| Issue | Pattern | Mitigation |
|-------|---------|------------|
| Type assertion | `as [A-Z]` (not `as unknown`) | Type guards, `satisfies` |
| Missing return type | `function.*\{` without `:` return | Explicit return type |
| Loose equality | `==\s*null` | `=== null \|\| === undefined` |

### Low Severity

| Issue | Pattern | Mitigation |
|-------|---------|------------|
| `object` type | `:\s*object[,)]` | Specific interface |
| `Function` type | `:\s*Function` | Specific signature |
| Missing type imports | `import {` | `import type` |

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
