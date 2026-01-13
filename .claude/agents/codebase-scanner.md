# Codebase Scanner Agent

Builds cached context for code review specialists.

## Purpose

Scan codebase once and cache results. Other agents read from cache instead of re-scanning, significantly improving review performance.

## Output

`.claude/cache/codebase-context.json`:

```json
{
  "metadata": {
    "scannedAt": "2026-01-13T10:30:00Z",
    "commit": "abc123",
    "filesScanned": 42,
    "linesScanned": 5280
  },
  "structure": {
    "projectType": "app",
    "primaryLanguage": "typescript",
    "frameworks": ["next.js", "react"],
    "hasTests": true,
    "hasCi": true
  },
  "files": [
    {
      "path": "src/app/page.tsx",
      "language": "typescript",
      "lines": 45,
      "exports": ["default"],
      "complexity": "low"
    }
  ],
  "dependencies": {
    "production": ["next", "react", "prisma"],
    "development": ["typescript", "jest"]
  },
  "entryPoints": ["src/app/layout.tsx", "src/app/page.tsx"],
  "securityRelevant": ["src/lib/auth.ts", "src/middleware.ts"]
}
```

## Execution

### 1. Check Cache Validity

Cache is **valid** if:
- File exists at `.claude/cache/codebase-context.json`
- Cached commit matches `git rev-parse HEAD`
- No uncommitted changes (`git status --porcelain` is empty)

If valid, skip scan and return cached data.

### 2. Detect Project Structure

| Field | Detection |
|-------|-----------|
| projectType | Has `src/app/` = app, has `bin/` = cli, has `lib/` only = library |
| primaryLanguage | Most common extension in `src/` |
| frameworks | Check package.json dependencies for next, react, express, etc. |
| hasTests | `test/` or `__tests__/` or `*.test.*` files exist |
| hasCi | `.github/workflows/` or `.gitlab-ci.yml` exists |

### 3. Scan Files

For each scannable file (`.ts`, `.tsx`, `.js`, `.jsx`, `.py`, `.rs`, `.go`):

| Field | How to Get |
|-------|------------|
| path | Relative path from root |
| language | From extension |
| lines | Count non-blank lines |
| exports | Parse `export` statements |
| complexity | low (<50 lines), medium (50-200), high (>200) |

**Skip:**
- `node_modules/`, `vendor/`, `.git/`
- Build outputs: `dist/`, `build/`, `.next/`
- Generated: `*.min.js`, `*.bundle.js`, `*.d.ts`

### 4. Identify Security-Relevant Files

Flag files matching:
- `*auth*`, `*login*`, `*session*`, `*token*`
- `.env*`, `*secret*`, `*credential*`
- `*/api/*`, `*middleware*`

### 5. Extract Dependencies

From `package.json`, `requirements.txt`, `Cargo.toml`, or `go.mod`.

### 6. Find Entry Points

- Next.js: `src/app/**/page.tsx`, `src/app/**/layout.tsx`
- Express: `src/index.ts`, `src/routes/*.ts`
- CLI: `src/cli.ts`, `src/main.ts`

### 7. Write Cache

```
mkdir -p .claude/cache
```

Write JSON to `.claude/cache/codebase-context.json`.

## Cache Invalidation

| Condition | Action |
|-----------|--------|
| HEAD changed | Rescan |
| Uncommitted changes | Rescan |
| Cache >24 hours old | Rescan |
| Cache missing | Scan |

## Performance

- Target: <30 seconds for typical project
- Skip binary files and generated code
- Cache aggressively

## Guardrails

- **DO** check cache validity before scanning
- **DO** skip node_modules and build outputs
- **DO** include security-relevant file list
- **DO NOT** read file contents (just metadata)
- **DO NOT** scan binary files
