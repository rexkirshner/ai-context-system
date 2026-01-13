# Codebase Scanner Agent

Scans the codebase to build context for code review agents.

## Purpose

Create a cached representation of the codebase structure that other review agents can use. This avoids each agent re-scanning the same files.

## Input

- Project root directory
- Optional: List of files to scan (for incremental mode)

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
      "imports": ["react", "@/lib/auth"],
      "exports": ["default"],
      "functions": ["Home"],
      "complexity": "low"
    }
  ],
  "dependencies": {
    "production": ["next", "react", "prisma"],
    "development": ["typescript", "jest", "eslint"]
  },
  "entryPoints": [
    "src/app/layout.tsx",
    "src/app/page.tsx"
  ],
  "securityRelevant": [
    "src/lib/auth.ts",
    "src/middleware.ts",
    ".env.example"
  ]
}
```

## Execution Steps

### Step 1: Initialize Scan

```bash
mkdir -p .claude/cache

# Get current commit
COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
```

### Step 2: Detect Project Structure

```bash
# Detect project type
if [ -f "package.json" ]; then
  PROJECT_TYPE="node"
  # Check for frameworks
  if grep -q '"next"' package.json; then
    FRAMEWORK="next.js"
  elif grep -q '"react"' package.json; then
    FRAMEWORK="react"
  fi
elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
  PROJECT_TYPE="python"
elif [ -f "Cargo.toml" ]; then
  PROJECT_TYPE="rust"
elif [ -f "go.mod" ]; then
  PROJECT_TYPE="go"
fi

# Detect primary language by file count
PRIMARY_LANG=$(find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.rs" -o -name "*.go" \) | \
  sed 's/.*\.//' | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')
```

### Step 3: Scan Files

For each scannable file:

1. **Identify language** from extension
2. **Count lines** (excluding blank and comments)
3. **Extract imports** (language-specific patterns)
4. **Extract exports** (language-specific patterns)
5. **List functions/classes** (top-level definitions)
6. **Estimate complexity** (cyclomatic or simple heuristic)

**Scannable file types:**
- TypeScript/JavaScript: `.ts`, `.tsx`, `.js`, `.jsx`
- Python: `.py`
- Rust: `.rs`
- Go: `.go`
- Config: `.json`, `.yaml`, `.toml` (limited scan)

**Skip:**
- `node_modules/`, `vendor/`, `.git/`
- Build outputs: `dist/`, `build/`, `.next/`
- Generated files: `*.min.js`, `*.bundle.js`

### Step 4: Identify Security-Relevant Files

Flag files that reviewers should examine closely:

```bash
SECURITY_FILES=()

# Authentication/authorization
SECURITY_FILES+=($(find . -type f \( -name "*auth*" -o -name "*login*" -o -name "*session*" -o -name "*token*" \) | grep -v node_modules))

# Environment/config
SECURITY_FILES+=($(find . -type f \( -name ".env*" -o -name "*secret*" -o -name "*credential*" \) | grep -v node_modules))

# API routes
SECURITY_FILES+=($(find . -type f -path "*/api/*" | grep -v node_modules))

# Middleware
SECURITY_FILES+=($(find . -type f -name "*middleware*" | grep -v node_modules))
```

### Step 5: Extract Dependencies

```bash
# Node.js
if [ -f "package.json" ]; then
  PROD_DEPS=$(jq -r '.dependencies | keys[]' package.json 2>/dev/null)
  DEV_DEPS=$(jq -r '.devDependencies | keys[]' package.json 2>/dev/null)
fi

# Python
if [ -f "requirements.txt" ]; then
  DEPS=$(grep -v '^#' requirements.txt | cut -d'=' -f1 | cut -d'>' -f1 | cut -d'<' -f1)
fi
```

### Step 6: Identify Entry Points

```bash
ENTRY_POINTS=()

# Next.js
if [ -d "src/app" ]; then
  ENTRY_POINTS+=($(find src/app -name "page.tsx" -o -name "layout.tsx"))
fi

# Express/API
if [ -d "src/routes" ] || [ -d "src/api" ]; then
  ENTRY_POINTS+=($(find src -name "index.ts" -o -name "routes.ts"))
fi

# CLI
if [ -f "src/cli.ts" ] || [ -f "src/main.ts" ]; then
  ENTRY_POINTS+=("src/cli.ts" "src/main.ts")
fi
```

### Step 7: Build Output JSON

Construct the codebase-context.json using gathered data.

**AI Implementation Note:** Use jq or careful string building to create valid JSON. Escape special characters in file paths and content.

### Step 8: Write Cache

```bash
# Write to cache file
cat > .claude/cache/codebase-context.json << EOF
{
  "metadata": {
    "scannedAt": "$TIMESTAMP",
    "commit": "$COMMIT",
    "filesScanned": $FILE_COUNT,
    "linesScanned": $LINE_COUNT
  },
  ...
}
EOF

echo "✓ Codebase context cached: .claude/cache/codebase-context.json"
```

## Cache Invalidation

Per V5_PLANNING.md §D.1, cache is stale when:

1. `git rev-parse HEAD` differs from cached commit
2. Any file in `git status --porcelain` output
3. Cache file older than 24 hours

```bash
# Check if cache is valid
is_cache_valid() {
  if [ ! -f ".claude/cache/codebase-context.json" ]; then
    return 1
  fi

  CACHED_COMMIT=$(jq -r '.metadata.commit' .claude/cache/codebase-context.json)
  CURRENT_COMMIT=$(git rev-parse HEAD 2>/dev/null)

  if [ "$CACHED_COMMIT" != "$CURRENT_COMMIT" ]; then
    return 1
  fi

  # Check for uncommitted changes
  if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    return 1
  fi

  return 0
}
```

## Incremental Mode

For `--incremental` flag:

```bash
# Get changed files
CHANGED_FILES=$(git diff --name-only HEAD~1 2>/dev/null)

# Filter to scannable types
SCAN_FILES=$(echo "$CHANGED_FILES" | grep -E '\.(ts|tsx|js|jsx|py|rs|go)$')

# Only scan these files, merge with existing cache
```

## Verification Criteria

| Check | Requirement |
|-------|-------------|
| Output exists | `.claude/cache/codebase-context.json` created |
| Valid JSON | `jq .` parses successfully |
| Metadata present | `scannedAt`, `commit`, `filesScanned` fields |
| Files array | At least one file in scannable directories |

## Performance

- Should complete in <30 seconds for typical projects
- Use parallel file reading where possible
- Cache aggressively to avoid re-scanning

## Notes

- This agent is run FIRST before any specialist reviewers
- Output is consumed by: security-reviewer, performance-reviewer, etc.
- Incremental mode only scans changed files
- Cache is shared across all review agents
