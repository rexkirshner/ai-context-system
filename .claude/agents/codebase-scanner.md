# Codebase Scanner Agent

Builds cached context for code review specialists.

## Purpose

Scan codebase once and cache results. Other agents read from cache instead of re-scanning, significantly improving review performance.

## File Discovery

**Preferred method:** `git ls-files` (when `isGitRepo: true`)
- Respects `.gitignore` automatically
- Excludes untracked files (junk, temp files)
- Predictable and fast

**Fallback method:** Filesystem scan (when not a git repo)
- Must explicitly exclude directories listed below

**Always exclude from all scans:**
- `node_modules/`, `vendor/`, `.git/`
- Build outputs: `dist/`, `build/`, `.next/`, `out/`
- Generated files: `*.min.js`, `*.bundle.js`, `*.d.ts`
- Lock files: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml` (except for dependency detection)
- Binary files

## Output

`.claude/cache/codebase-context.json`:

```json
{
  "schemaVersion": "1.2.0",
  "metadata": {
    "scannedAt": "2026-01-13T10:30:00Z",
    "commit": "abc123",
    "isGitRepo": true,
    "filesScanned": 42,
    "linesScanned": 5280
  },
  "structure": {
    "projectType": "webapp",
    "primaryLanguage": "typescript",
    "frameworks": ["next.js", "react"],
    "hasTests": true,
    "hasCI": true,
    "hasDatabase": true,
    "hasUI": true,
    "isServerless": false,
    "isMonorepo": false
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
  "securityRelevant": ["src/lib/auth.ts", "src/middleware.ts"],
  "databaseFiles": ["prisma/schema.prisma", "src/lib/db.ts"],
  "uiComponents": ["src/components/Button.tsx", "src/app/page.tsx"],
  "ciWorkflows": [".github/workflows/ci.yml"]
}
```

**Invariants:**
- All `structure.*` fields are always present (use `false`, not omission)
- All specialized file lists are always present (use `[]`, not omission)
- `metadata.isGitRepo` reflects whether git commands succeeded

## Execution

### 1. Check Cache Validity

Cache is **valid** if:
- File exists at `.claude/cache/codebase-context.json`
- Cached commit matches `git rev-parse HEAD`
- No uncommitted changes (`git status --porcelain` is empty)

If valid, skip scan and return cached data.

### 2. Detect Project Structure

| Field | Detection Method |
|-------|------------------|
| `projectType` | `webapp` if has UI + routes, `api` if routes only, `cli` if has `bin/`, `library` if has `lib/` only, `monorepo` if workspaces |
| `primaryLanguage` | Most common extension in `src/` (`typescript`, `python`, `go`, `rust`, `unknown`) |
| `frameworks` | Check package.json deps for next, react, vue, svelte, express, fastify, prisma, etc. |
| `hasTests` | `test/` or `__tests__/` or `*.test.*` or `*.spec.*` files exist |
| `hasCI` | `.github/workflows/` OR `.gitlab-ci.yml` OR `.circleci/` exists |
| `hasDatabase` | prisma, drizzle, typeorm, mongoose, sequelize, pg, mysql2 in deps |
| `hasUI` | `.tsx`/`.jsx` files exist OR react/vue/svelte in deps |
| `isServerless` | `vercel.json` OR `netlify.toml` OR `serverless.yml` exists |
| `isMonorepo` | `workspaces` in package.json OR `pnpm-workspace.yaml` exists |
| `metadata.isGitRepo` | `git rev-parse --git-dir` succeeds |

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

### 4. Build Specialized File Lists

Agents use these lists instead of repo-wide grep to reduce noise and improve performance.

| Field | Patterns | Description |
|-------|----------|-------------|
| `securityRelevant` | `*auth*`, `*login*`, `*session*`, `*token*`, `.env*`, `*secret*`, `*credential*`, `*/api/*`, `*middleware*` | Files for security review |
| `databaseFiles` | `prisma/schema.prisma`, `**/db.ts`, `**/database.ts`, `**/migrations/*`, `*.sql` | Files for database review |
| `uiComponents` | `**/*.tsx`, `**/*.jsx` in `src/`, `components/`, `app/` | Files for UI review (accessibility, SEO) |
| `ciWorkflows` | `.github/workflows/*.yml`, `.gitlab-ci.yml`, `.circleci/config.yml` | Files for infrastructure review |

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
