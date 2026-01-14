# V5.0 Code Review System Completion Plan

**Version:** 5.0
**Updated:** 2026-01-13
**Status:** Active

---

## Executive Summary

Complete the agent-based code review system with **self-declaring agents**. Each specialist agent declares when it should run, making the system extensible without modifying central configuration.

**Current → Target:**
- Specialists: 5 → 8 (add SEO, Database, Infrastructure)
- Agent architecture: hardcoded → **self-declaring** (each agent declares applicability)
- code-reviewer: static selection → **dynamic discovery** with validation
- /code-review: 550-line monolith → thin wrapper invoking agents

**Key Architectural Guarantee:**
Adding or removing a specialist = **one file**. No central registry to update.

---

## Principles

1. **Self-declaration.** Agents declare their own identity and applicability. No central registry.
2. **Single source of truth.** Agent metadata lives in the agent file, not duplicated elsewhere.
3. **Contracts first.** Define interfaces before building. Components communicate via documented schemas.
4. **Validated discovery.** Contracts are validated against schema during discovery. Invalid = skipped with reason.
5. **Unique identities.** Duplicate agent IDs are a hard failure, not silent undefined behavior.
6. **Scoped scanning.** Agents use scanner's specialized file lists, not repo-wide grep.
7. **Safe fallback.** If no agents match or parsing fails, default to security + testing.
8. **Objective verification.** Every task has automated checks. No "looks good to me."
9. **No bandaids.** Take time to do it right. No quick fixes that become permanent debt.

---

## Part 1: Architecture Overview

### The Self-Declaration Model

```
┌─────────────────────────────────────────────────────────────────┐
│                         /code-review                             │
│                    (thin wrapper, invokes agent)                 │
└─────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                       code-reviewer                              │
│                      (orchestrator agent)                        │
│                                                                  │
│  1. Run codebase-scanner → get project facts                    │
│  2. Discover all *-reviewer.md files                            │
│  3. Extract & validate Agent Contracts (schema check)           │
│  4. Enforce unique IDs (fail on duplicates)                     │
│  5. Match applicability conditions → select agents              │
│  6. Run selected specialists (they use scanner's file lists)    │
│  7. Pass to synthesis-agent → dedupe, grade                     │
│  8. Output audit-NN.{json,md}                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Why Self-Declaration?

| Operation | Old (Centralized) | New (Self-Declaring) |
|-----------|-------------------|----------------------|
| Add agent | Update 5 files | Create 1 file |
| Remove agent | Update 5 files | Delete 1 file |
| Change applicability | Edit code-reviewer | Edit that agent |
| See what runs when | Read code-reviewer | Read each agent |

### Validation & Safety

| Scenario | Behavior |
|----------|----------|
| Contract fails schema validation | Agent skipped, reason in `agentsSkipped` |
| Duplicate agent IDs | Hard failure with clear error |
| No agents selected | Fallback to security + testing |
| Agent uses invalid condition operator | Contract fails validation |

---

## Part 2: Agent Contract Standard

Every specialist agent includes a **contract block** that declares its identity and applicability.

### 2.1 Contract Schema

```json
{
  "id": "seo",
  "prefix": "SEO",
  "category": "seo",
  "applicability": {
    "always": false,
    "requires": {
      "structure.hasUI": true,
      "structure.projectType": "webapp"
    },
    "presets": ["prelaunch", "frontend"]
  }
}
```

### 2.2 Contract Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique identifier, lowercase, used in `--{id}` flag. **Must be unique across all agents.** |
| `prefix` | string | Finding ID prefix (e.g., "SEC", "PERF"). Uppercase. |
| `category` | string | Category for findings, typically matches `id`. |
| `applicability.always` | boolean | If true, always runs regardless of project type. |
| `applicability.requires` | object | Conditions that must match scanner output. |
| `applicability.presets` | array | Preset flags that include this agent. |

### 2.3 Condition Matching

The `requires` object supports **three matching modes**:

#### Equality (default)
```json
"structure.hasUI": true
"structure.projectType": "webapp"
```
Matches when `scanner.structure.hasUI === true`.

#### Contains (for arrays)
```json
"structure.frameworks:contains": "next.js"
```
Matches when `scanner.structure.frameworks.includes("next.js")`.

#### In (for enum-like fields)
```json
"structure.projectType:in": ["webapp", "monorepo"]
```
Matches when `["webapp", "monorepo"].includes(scanner.structure.projectType)`.

**All conditions must match** (AND logic) for the agent to be selected in auto mode.

### 2.4 Preset Definitions

| Preset | Description | Use Case |
|--------|-------------|----------|
| `prelaunch` | Pre-deployment checklist | Before going live |
| `frontend` | UI/UX focused | React/Vue apps |
| `backend` | API/server focused | Express/FastAPI |
| `quick` | Minimal security check | Quick PR review |

### 2.5 Contract Location

The contract MUST be:
- In a section titled `## Agent Contract`
- In a fenced code block marked ` ```json`
- The first JSON block in that section
- Valid against `.claude/schemas/agent-contract.json`

---

## Part 3: Component Contracts

### 3.1 codebase-scanner

**Purpose:** Scan project and output facts. Does NOT recommend agents.

**Input:** Project root directory

**Output:** `.claude/cache/codebase-context.json`

```json
{
  "schemaVersion": "1.2.0",
  "metadata": {
    "scannedAt": "ISO-8601",
    "commit": "git-sha-or-null",
    "isGitRepo": true,
    "filesScanned": 42
  },
  "structure": {
    "projectType": "webapp|api|cli|library|monorepo",
    "primaryLanguage": "typescript|python|go|rust|unknown",
    "frameworks": ["next.js", "prisma"],
    "hasTests": true,
    "hasCI": true,
    "hasDatabase": true,
    "hasUI": true,
    "isServerless": true,
    "isMonorepo": false
  },
  "files": [],
  "dependencies": {},
  "securityRelevant": [],
  "databaseFiles": [],
  "uiComponents": [],
  "ciWorkflows": []
}
```

**Specialized File Lists:** (agents use these instead of repo-wide grep)

| Field | Contents | Used By |
|-------|----------|---------|
| `securityRelevant` | Auth, session, API files | security-reviewer |
| `databaseFiles` | ORM schemas, migrations, queries | database-reviewer |
| `uiComponents` | `.tsx`, `.jsx` in components/ | accessibility-reviewer, seo-reviewer |
| `ciWorkflows` | GitHub Actions, GitLab CI files | infrastructure-reviewer |

**File Discovery:**
- Use `git ls-files` when `isGitRepo: true`
- Fall back to filesystem scan otherwise
- Always ignore: `node_modules/`, `dist/`, `build/`, `.next/`, `vendor/`, `.git/`

**Invariants:**
- All `structure.*` fields always present (use `false`, not omission)
- All specialized file lists always present (use `[]`, not omission)

---

### 3.2 code-reviewer (Orchestrator)

**Purpose:** Discover agents, validate contracts, select and run specialists.

**Input:** Flags and options

**Output:**
- `docs/audits/audit-NN.json` (AuditReport schema)
- `docs/audits/audit-NN.md` (human-readable)

#### Discovery Algorithm

```
1. Find all files matching .claude/agents/*-reviewer.md
2. For each file:
   a. Extract JSON from ## Agent Contract section
   b. Validate against agent-contract.json schema
   c. If invalid: add to agentsSkipped with reason, continue
   d. If valid: add to discovered agents
3. Check for duplicate IDs:
   a. If any duplicates found: HARD FAIL with error listing duplicates
```

#### Selection Algorithm

```
1. Parse user flags

2. If --all:
     selected = all discovered agents

3. Else if preset flag (--prelaunch, --frontend, --backend, --quick):
     selected = agents where preset in applicability.presets

4. Else if specific flags (--security, --seo, etc.):
     selected = agents where id matches any flag

5. Else (auto mode):
     For each agent:
       If applicability.always == true: include
       Else if ALL requires conditions match scanner output: include

6. If selected is empty:
     selected = [security, testing]  # Safe fallback
     Log warning about fallback activation
```

#### Condition Evaluation

```
For each condition in requires:
  Parse key and operator:
    "field": value           → equality: scanner[field] === value
    "field:contains": value  → contains: scanner[field].includes(value)
    "field:in": [values]     → in: values.includes(scanner[field])

  If operator unknown: condition fails (contract invalid)
  If field missing in scanner: condition fails (not selected)
```

#### Preset Contents

| Preset | Agents Included |
|--------|-----------------|
| `--prelaunch` | security, testing, performance, accessibility, seo |
| `--frontend` | security, performance, accessibility, seo |
| `--backend` | security, testing, database, infrastructure |
| `--quick` | security |
| `--all` | All 8 specialists |

#### Output Naming

Format: `audit-NN.{json,md}` where NN is zero-padded next available number.

```
Scan docs/audits/ for existing audit-*.json
Find highest NN, increment by 1
If none exist, start at 01
```

---

### 3.3 synthesis-agent

**Input:** Arrays of `AuditFinding` from all specialists

**Output:** Deduplicated, merged `AuditReport`

**Deduplication Rules:**
- **Duplicate:** Same `file` AND same `line` from different specialists
- **Resolution:** Keep highest severity, merge `verificationNotes`, combine `remediation`
- **Ownership:** Finding keeps the ID prefix of the highest-severity source

**Sorting Order:** severity → category → file path → finding id (deterministic)

**Grade Calculation:**

| Condition | Grade |
|-----------|-------|
| Any critical | F |
| >3 high | D |
| >1 high | C |
| 1 high | C+ |
| >5 medium | B- |
| >2 medium | B |
| >0 medium | B+ |
| >5 low | A- |
| >0 low | A |
| 0 issues | A+ |

---

## Part 4: Specialist Agent Contracts

### 4.1 Existing Specialists (need contract added)

#### security-reviewer

```json
{
  "id": "security",
  "prefix": "SEC",
  "category": "security",
  "applicability": {
    "always": true,
    "requires": {},
    "presets": ["prelaunch", "frontend", "backend", "quick"]
  }
}
```

**File list:** Uses `securityRelevant` from scanner.

---

#### performance-reviewer

```json
{
  "id": "performance",
  "prefix": "PERF",
  "category": "performance",
  "applicability": {
    "always": false,
    "requires": {
      "structure.hasUI": true
    },
    "presets": ["prelaunch", "frontend"]
  }
}
```

**File list:** Uses `uiComponents` from scanner.

---

#### accessibility-reviewer

```json
{
  "id": "accessibility",
  "prefix": "A11Y",
  "category": "accessibility",
  "applicability": {
    "always": false,
    "requires": {
      "structure.hasUI": true
    },
    "presets": ["prelaunch", "frontend"]
  }
}
```

**File list:** Uses `uiComponents` from scanner.

---

#### type-safety-reviewer

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

**File list:** Uses `files` filtered by `.ts`/`.tsx` extension.

---

#### test-coverage-reviewer

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

**File list:** Uses `files` filtered for test patterns.

---

### 4.2 New Specialists (to create)

#### seo-reviewer

```json
{
  "id": "seo",
  "prefix": "SEO",
  "category": "seo",
  "applicability": {
    "always": false,
    "requires": {
      "structure.hasUI": true,
      "structure.projectType:in": ["webapp", "monorepo"]
    },
    "presets": ["prelaunch", "frontend"]
  }
}
```

**File list:** Uses `uiComponents` from scanner.

**Framework-aware patterns:**

| Severity | Issue | Vuln Pattern | Mitigation Pattern |
|----------|-------|--------------|-------------------|
| high | Missing title | `<head>` without `<title>` | `<title>\|metadata.*title\|generateMetadata` |
| high | No meta description | No description meta | `meta.*description\|metadata.*description` |
| high | Missing Open Graph | No `og:` tags | `og:\|openGraph\|metadata.*openGraph` |
| medium | No canonical | No `rel="canonical"` | `canonical\|metadata.*canonical\|alternates` |
| low | No sitemap | Missing sitemap.xml | File exists OR `generateSitemaps` |

---

#### database-reviewer

```json
{
  "id": "database",
  "prefix": "DB",
  "category": "database",
  "applicability": {
    "always": false,
    "requires": {
      "structure.hasDatabase": true
    },
    "presets": ["backend"]
  }
}
```

**File list:** Uses `databaseFiles` from scanner.

**Patterns:**

| Severity | Issue | Vuln Pattern | Mitigation Pattern |
|----------|-------|--------------|-------------------|
| critical | SQL injection | `$queryRaw` with `${` | Parameterized queries |
| high | N+1 queries | `for.*await.*find` | `include:\|populate` |
| high | Unbounded fetch | `findMany()` without `take:` | `take:\|limit` |
| medium | SELECT * | `SELECT *` | Specific field selection |

---

#### infrastructure-reviewer

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

**File list:** Uses `ciWorkflows` from scanner.

**Patterns:**

| Severity | Issue | Vuln Pattern | Mitigation Pattern |
|----------|-------|--------------|-------------------|
| high | Secrets in CI | `password:\|api_key:` in workflows | `${{ secrets.` |
| high | No health check | API without `/health` | Health endpoint |
| medium | No error tracking | No Sentry/DataDog | `@sentry\|datadog` |
| low | No build cache | CI without cache step | `actions/cache` |

---

## Part 5: Implementation Tasks

### Phase 1: Schemas

Create/update JSON schemas that define contracts.

---

#### Task 1.1: Create Agent Contract Schema

**File:** `.claude/schemas/agent-contract.json` (new)

**Content:**
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Agent Contract",
  "description": "Self-declaration contract for specialist agents",
  "type": "object",
  "properties": {
    "id": {
      "type": "string",
      "pattern": "^[a-z][a-z0-9-]*$",
      "description": "Unique identifier, lowercase"
    },
    "prefix": {
      "type": "string",
      "pattern": "^[A-Z][A-Z0-9]*$",
      "description": "Finding ID prefix, uppercase"
    },
    "category": {
      "type": "string",
      "description": "Category for findings"
    },
    "applicability": {
      "type": "object",
      "properties": {
        "always": {
          "type": "boolean",
          "description": "If true, always runs"
        },
        "requires": {
          "type": "object",
          "description": "Conditions for auto-selection"
        },
        "presets": {
          "type": "array",
          "items": { "type": "string" },
          "description": "Presets that include this agent"
        }
      },
      "required": ["always", "requires", "presets"]
    }
  },
  "required": ["id", "prefix", "category", "applicability"]
}
```

**Verification:**
```bash
test -f .claude/schemas/agent-contract.json && \
jq -e '.properties.id.pattern' .claude/schemas/agent-contract.json && \
jq -e '.properties.applicability.required | length == 3' .claude/schemas/agent-contract.json
```

**Done when:** Schema file exists with all required fields.

---

#### Task 1.2: Update AuditFinding Schema

**File:** `.claude/schemas/audit-finding.json`

**Change:** `category` from enum to string

```json
"category": {
  "type": "string",
  "description": "Category matching the agent ID that produced this finding"
}
```

**Verification:**
```bash
jq -e '.properties.category.type == "string"' .claude/schemas/audit-finding.json && \
! jq -e '.properties.category.enum' .claude/schemas/audit-finding.json 2>/dev/null
```

**Done when:** Category is string type, not enum.

---

#### Task 1.3: Update AuditReport Schema

**File:** `.claude/schemas/audit-report.json`

**Add fields:**
```json
"metadata": {
  "properties": {
    "schemaVersion": { "type": "string" },
    "agentsRun": {
      "type": "array",
      "items": { "type": "string" }
    },
    "agentsSkipped": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "agent": { "type": "string" },
          "reason": { "type": "string" }
        },
        "required": ["agent", "reason"]
      }
    }
  }
}
```

**Verification:**
```bash
jq -e '.properties.metadata.properties.schemaVersion' .claude/schemas/audit-report.json && \
jq -e '.properties.metadata.properties.agentsSkipped.items.properties.reason' .claude/schemas/audit-report.json
```

**Done when:** Both new fields present with correct structure.

---

### Phase 2: Scanner Enhancement

Update scanner to output specialized file lists.

---

#### Task 2.1: Add Structure Detection Fields

**File:** `.claude/agents/codebase-scanner.md`

**Add to detection table:**

| Field | Detection Method |
|-------|------------------|
| `structure.hasDatabase` | prisma/drizzle/typeorm/mongoose/sequelize in deps |
| `structure.hasUI` | `.tsx`/`.jsx` files exist OR react/vue/svelte in deps |
| `structure.hasCI` | `.github/workflows/` OR `.gitlab-ci.yml` OR `.circleci/` exists |
| `structure.isServerless` | vercel.json OR netlify.toml OR serverless.yml exists |
| `structure.isMonorepo` | `workspaces` in package.json OR `pnpm-workspace.yaml` exists |
| `metadata.isGitRepo` | `git rev-parse --git-dir` succeeds |

**Verification:**
```bash
grep -q "hasDatabase" .claude/agents/codebase-scanner.md && \
grep -q "hasUI" .claude/agents/codebase-scanner.md && \
grep -q "hasCI" .claude/agents/codebase-scanner.md && \
grep -q "isServerless" .claude/agents/codebase-scanner.md && \
grep -q "isMonorepo" .claude/agents/codebase-scanner.md && \
grep -q "isGitRepo" .claude/agents/codebase-scanner.md
```

**Done when:** All 6 detection fields documented.

---

#### Task 2.2: Add Specialized File Lists

**File:** `.claude/agents/codebase-scanner.md`

**Add section documenting:**

| Field | Pattern | Description |
|-------|---------|-------------|
| `securityRelevant` | `*auth*`, `*session*`, `*token*`, `*/api/*`, `*middleware*` | Files for security review |
| `databaseFiles` | `prisma/schema.prisma`, `**/db.ts`, `**/database.ts`, `**/migrations/*` | Files for database review |
| `uiComponents` | `**/*.tsx`, `**/*.jsx` in `src/`, `components/`, `app/` | Files for UI review |
| `ciWorkflows` | `.github/workflows/*.yml`, `.gitlab-ci.yml`, `.circleci/config.yml` | Files for infra review |

**Verification:**
```bash
grep -q "securityRelevant" .claude/agents/codebase-scanner.md && \
grep -q "databaseFiles" .claude/agents/codebase-scanner.md && \
grep -q "uiComponents" .claude/agents/codebase-scanner.md && \
grep -q "ciWorkflows" .claude/agents/codebase-scanner.md
```

**Done when:** All 4 specialized file lists documented with patterns.

---

#### Task 2.3: Add File Discovery Method

**File:** `.claude/agents/codebase-scanner.md`

**Add section:**

```markdown
## File Discovery

**Preferred method:** `git ls-files` (when `isGitRepo: true`)
- Respects .gitignore
- Excludes untracked files
- Predictable, fast

**Fallback method:** Filesystem scan (when not a git repo)
- Must explicitly exclude: node_modules/, dist/, build/, .next/, vendor/, .git/

**Always exclude from all lists:**
- Binary files
- Lock files (except for dependency detection)
- Generated files (*.min.js, *.bundle.js)
```

**Verification:**
```bash
grep -q "git ls-files" .claude/agents/codebase-scanner.md && \
grep -q "node_modules" .claude/agents/codebase-scanner.md && \
grep -q "isGitRepo" .claude/agents/codebase-scanner.md
```

**Done when:** File discovery method documented with exclusions.

---

### Phase 3: Migrate Existing Specialists

Add Agent Contract to each existing specialist.

---

#### Task 3.1: Add Contract to security-reviewer

**File:** `.claude/agents/security-reviewer.md`

**Add after first paragraph:**

```markdown
## Agent Contract

```json
{
  "id": "security",
  "prefix": "SEC",
  "category": "security",
  "applicability": {
    "always": true,
    "requires": {},
    "presets": ["prelaunch", "frontend", "backend", "quick"]
  }
}
```

## File Scope

This agent reads from `securityRelevant` file list in scanner output.
Falls back to repo-wide scan only if list is empty.
```

**Verification:**
```bash
grep -q "## Agent Contract" .claude/agents/security-reviewer.md && \
grep -q "securityRelevant" .claude/agents/security-reviewer.md && \
sed -n '/## Agent Contract/,/```$/p' .claude/agents/security-reviewer.md | \
  sed -n '/```json/,/```/p' | sed '1d;$d' | \
  jq -e '.id == "security" and .applicability.always == true'
```

**Done when:** Contract present, validated, and file scope documented.

---

#### Task 3.2: Add Contract to performance-reviewer

**File:** `.claude/agents/performance-reviewer.md`

**Contract:** See Part 4.1 (performance)

**Add file scope:** Uses `uiComponents` from scanner.

**Verification:**
```bash
grep -q "## Agent Contract" .claude/agents/performance-reviewer.md && \
grep -q "uiComponents" .claude/agents/performance-reviewer.md && \
sed -n '/## Agent Contract/,/```$/p' .claude/agents/performance-reviewer.md | \
  sed -n '/```json/,/```/p' | sed '1d;$d' | \
  jq -e '.id == "performance"'
```

**Done when:** Contract and file scope documented.

---

#### Task 3.3: Add Contract to accessibility-reviewer

**File:** `.claude/agents/accessibility-reviewer.md`

**Contract:** See Part 4.1 (accessibility)

**Add file scope:** Uses `uiComponents` from scanner.

**Verification:**
```bash
grep -q "## Agent Contract" .claude/agents/accessibility-reviewer.md && \
grep -q "uiComponents" .claude/agents/accessibility-reviewer.md && \
sed -n '/## Agent Contract/,/```$/p' .claude/agents/accessibility-reviewer.md | \
  sed -n '/```json/,/```/p' | sed '1d;$d' | \
  jq -e '.id == "accessibility"'
```

**Done when:** Contract and file scope documented.

---

#### Task 3.4: Add Contract to type-safety-reviewer

**File:** `.claude/agents/type-safety-reviewer.md`

**Contract:** See Part 4.1 (typescript)

**Add file scope:** Uses `files` filtered by `.ts`/`.tsx` extension.

**Verification:**
```bash
grep -q "## Agent Contract" .claude/agents/type-safety-reviewer.md && \
sed -n '/## Agent Contract/,/```$/p' .claude/agents/type-safety-reviewer.md | \
  sed -n '/```json/,/```/p' | sed '1d;$d' | \
  jq -e '.id == "typescript"'
```

**Done when:** Contract documented.

---

#### Task 3.5: Add Contract to test-coverage-reviewer

**File:** `.claude/agents/test-coverage-reviewer.md`

**Contract:** See Part 4.1 (testing)

**Verification:**
```bash
grep -q "## Agent Contract" .claude/agents/test-coverage-reviewer.md && \
sed -n '/## Agent Contract/,/```$/p' .claude/agents/test-coverage-reviewer.md | \
  sed -n '/```json/,/```/p' | sed '1d;$d' | \
  jq -e '.id == "testing" and .applicability.always == true'
```

**Done when:** Contract documented.

---

### Phase 4: Create New Specialists

Create three new specialist agents with contracts.

---

#### Task 4.1: Create seo-reviewer Agent

**File:** `.claude/agents/seo-reviewer.md` (new)

**Required sections:**
1. Title and description
2. Agent Contract (from Part 4.2)
3. File Scope (uses `uiComponents`)
4. Purpose
5. Patterns table (framework-aware)
6. Execution steps
7. Guardrails

**Verification:**
```bash
test -f .claude/agents/seo-reviewer.md && \
grep -q "## Agent Contract" .claude/agents/seo-reviewer.md && \
grep -q "## File Scope" .claude/agents/seo-reviewer.md && \
grep -q "uiComponents" .claude/agents/seo-reviewer.md && \
grep -q "generateMetadata" .claude/agents/seo-reviewer.md && \
grep -q "projectType:in" .claude/agents/seo-reviewer.md && \
sed -n '/## Agent Contract/,/```$/p' .claude/agents/seo-reviewer.md | \
  sed -n '/```json/,/```/p' | sed '1d;$d' | \
  jq -e '.id == "seo"'
```

**Done when:** File exists with valid contract, file scope, and framework-aware patterns.

---

#### Task 4.2: Create database-reviewer Agent

**File:** `.claude/agents/database-reviewer.md` (new)

**Required sections:**
1. Title and description
2. Agent Contract (from Part 4.2)
3. File Scope (uses `databaseFiles`)
4. Purpose
5. Patterns table
6. Execution steps
7. Guardrails

**Verification:**
```bash
test -f .claude/agents/database-reviewer.md && \
grep -q "## Agent Contract" .claude/agents/database-reviewer.md && \
grep -q "## File Scope" .claude/agents/database-reviewer.md && \
grep -q "databaseFiles" .claude/agents/database-reviewer.md && \
grep -q "SQL injection\|N+1" .claude/agents/database-reviewer.md && \
sed -n '/## Agent Contract/,/```$/p' .claude/agents/database-reviewer.md | \
  sed -n '/```json/,/```/p' | sed '1d;$d' | \
  jq -e '.id == "database"'
```

**Done when:** File exists with valid contract and file scope.

---

#### Task 4.3: Create infrastructure-reviewer Agent

**File:** `.claude/agents/infrastructure-reviewer.md` (new)

**Required sections:**
1. Title and description
2. Agent Contract (from Part 4.2)
3. File Scope (uses `ciWorkflows`)
4. Purpose
5. Patterns table
6. Execution steps
7. Guardrails

**Verification:**
```bash
test -f .claude/agents/infrastructure-reviewer.md && \
grep -q "## Agent Contract" .claude/agents/infrastructure-reviewer.md && \
grep -q "## File Scope" .claude/agents/infrastructure-reviewer.md && \
grep -q "ciWorkflows" .claude/agents/infrastructure-reviewer.md && \
grep -q "secrets\|health" .claude/agents/infrastructure-reviewer.md && \
sed -n '/## Agent Contract/,/```$/p' .claude/agents/infrastructure-reviewer.md | \
  sed -n '/```json/,/```/p' | sed '1d;$d' | \
  jq -e '.id == "infrastructure"'
```

**Done when:** File exists with valid contract and file scope.

---

### Phase 5: Orchestration

Update code-reviewer to dynamically discover and validate agents.

---

#### Task 5.1: Add Discovery Algorithm

**File:** `.claude/agents/code-reviewer.md`

**Add section:**

```markdown
## Agent Discovery

1. Find all files: `.claude/agents/*-reviewer.md`
2. For each file:
   - Look for `## Agent Contract` section
   - Extract first JSON code block after that heading
   - Validate JSON against `.claude/schemas/agent-contract.json`
   - If valid: add to discovered agents
   - If invalid: add to `agentsSkipped` with parse error
3. **Uniqueness check:** If any two agents have same `id`, HARD FAIL
   - Error: "Duplicate agent ID 'X' found in: file1.md, file2.md"
```

**Verification:**
```bash
grep -q "Agent Discovery" .claude/agents/code-reviewer.md && \
grep -q "\*-reviewer.md" .claude/agents/code-reviewer.md && \
grep -q "Duplicate agent ID\|unique\|HARD FAIL" .claude/agents/code-reviewer.md && \
grep -q "agentsSkipped" .claude/agents/code-reviewer.md
```

**Done when:** Discovery algorithm documented with uniqueness check.

---

#### Task 5.2: Add Selection Logic

**File:** `.claude/agents/code-reviewer.md`

**Add section with:**
- Selection algorithm (from Part 3.2)
- Condition evaluation (equality, contains, in)
- Preset table
- Fallback behavior

**Verification:**
```bash
grep -q "Selection Algorithm\|selection logic" .claude/agents/code-reviewer.md && \
grep -q ":contains\|:in" .claude/agents/code-reviewer.md && \
grep -q "\-\-prelaunch" .claude/agents/code-reviewer.md && \
grep -q "\-\-frontend" .claude/agents/code-reviewer.md && \
grep -q "\-\-backend" .claude/agents/code-reviewer.md && \
grep -q "fallback.*security.*testing\|security.*testing.*fallback" .claude/agents/code-reviewer.md
```

**Done when:** Selection logic with operators and fallback documented.

---

#### Task 5.3: Update Workflow Diagram

**File:** `.claude/agents/code-reviewer.md`

**Update to show:**
1. "Discover *-reviewer.md files" step
2. "Validate contracts against schema" step
3. "Check for duplicate IDs" step
4. "Match applicability" step
5. Generic "Selected Specialists" (not hardcoded list)

**Verification:**
```bash
grep -q "Discover\|discover" .claude/agents/code-reviewer.md && \
grep -q "Validate\|validate" .claude/agents/code-reviewer.md && \
grep -q "duplicate\|Duplicate" .claude/agents/code-reviewer.md
```

**Done when:** Workflow shows dynamic discovery with validation.

---

#### Task 5.4: Update Output Naming

**File:** `.claude/agents/code-reviewer.md`

**Change output section:**
- Format: `audit-NN.{json,md}` (not date-based)
- NN is zero-padded (01, 02, ... 99)
- Algorithm: scan existing, find max, increment

**Verification:**
```bash
grep -q "audit-NN\|audit-[0-9]" .claude/agents/code-reviewer.md && \
grep -q "increment\|next available" .claude/agents/code-reviewer.md && \
! grep -q "audit-YYYY-MM-DD" .claude/agents/code-reviewer.md
```

**Done when:** Output naming uses incrementing numbers.

---

### Phase 6: Command Integration

Update command to delegate to agent system.

---

#### Task 6.1: Slim /code-review Command

**File:** `.claude/commands/code-review.md`

**Target structure:**
```markdown
# /code-review

Run comprehensive code review using the agent-based system.

## Usage

/code-review [options]

## Options

| Flag | Effect |
|------|--------|
| --all | Run all specialists |
| --prelaunch | Pre-deployment check |
| --frontend | UI-focused review |
| --backend | API-focused review |
| --quick | Security only |
| --security | Just security |
| --incremental | Changed files only |

## Execution

Invoke the `code-reviewer` agent which will:
1. Run codebase-scanner
2. Discover and validate specialist agents
3. Select appropriate specialists
4. Run selected specialists in parallel
5. Synthesize and deduplicate findings
6. Output report to docs/audits/
```

**Verification:**
```bash
grep -q "code-reviewer agent\|code-reviewer.*agent" .claude/commands/code-review.md && \
grep -q "\-\-prelaunch" .claude/commands/code-review.md && \
! grep -q "grep -rn" .claude/commands/code-review.md && \
! grep -q "find app -name" .claude/commands/code-review.md && \
! grep -q "A01: Broken Access" .claude/commands/code-review.md && \
! grep -q "OWASP" .claude/commands/code-review.md
```

**Done when:** Command delegates to agent, no inline analysis logic.

---

#### Task 6.2: Add Deprecation Notices

**Files:** `.claude/commands/code-review-*.md` (8 files)

**Add to top of each:**
```markdown
> **DEPRECATED:** This command is superseded by the agent-based system.
> Use `/code-review --{type}` instead. Example: `/code-review --security`
> This file will be removed in v6.0.
```

**Verification:**
```bash
DEPRECATED=$(grep -l "DEPRECATED" .claude/commands/code-review-*.md 2>/dev/null | wc -l | tr -d ' ')
[ "$DEPRECATED" -eq 8 ]
```

**Done when:** All 8 individual commands have deprecation notice.

---

### Phase 7: Verification & Documentation

Final validation and documentation updates.

---

#### Task 7.1: Create Verification Script

**File:** `scripts/tests/test-code-review-completion.sh` (new)

See Part 7 for full script content.

**Verification:**
```bash
test -f scripts/tests/test-code-review-completion.sh && \
test -x scripts/tests/test-code-review-completion.sh
```

**Done when:** Script exists and is executable.

---

#### Task 7.2: Run Verification Script

**Action:** Execute and fix any failures.

**Verification:**
```bash
./scripts/tests/test-code-review-completion.sh
# Exit code must be 0
```

**Done when:** All checks pass.

---

#### Task 7.3: Update V5_PLANNING.md

**File:** `docs/planning/v5.0/V5_PLANNING.md`

**Changes:**
- Update agent count
- Document self-declaration architecture
- Add new agents to list

**Verification:**
```bash
grep -q "seo-reviewer" docs/planning/v5.0/V5_PLANNING.md && \
grep -q "database-reviewer" docs/planning/v5.0/V5_PLANNING.md && \
grep -q "infrastructure-reviewer" docs/planning/v5.0/V5_PLANNING.md
```

**Done when:** Document reflects actual system.

---

## Part 6: Task Dependency Graph

```
Phase 1: Schemas (no dependencies)
  1.1 agent-contract.json ─────┐
  1.2 audit-finding.json ──────┼─→ Phase 3, Phase 4, Phase 5
  1.3 audit-report.json ───────┘

Phase 2: Scanner (no dependencies)
  2.1 Structure detection ─────┐
  2.2 Specialized file lists ──┼─→ Phase 3, Phase 4
  2.3 File discovery method ───┘

Phase 3: Migrate Existing (depends on 1.1, 2.2)
  3.1 security-reviewer ───────┐
  3.2 performance-reviewer ────┤
  3.3 accessibility-reviewer ──├─→ Phase 5
  3.4 type-safety-reviewer ────┤
  3.5 test-coverage-reviewer ──┘

Phase 4: Create New (depends on 1.1, 2.2)
  4.1 seo-reviewer ────────────┐
  4.2 database-reviewer ───────├─→ Phase 5
  4.3 infrastructure-reviewer ─┘

Phase 5: Orchestration (depends on 3.*, 4.*)
  5.1 Discovery algorithm ─────┐
  5.2 Selection logic ─────────┼─→ Phase 6
  5.3 Workflow diagram ────────┤
  5.4 Output naming ───────────┘

Phase 6: Command Integration (depends on 5.*)
  6.1 Slim /code-review
  6.2 Deprecation notices (independent)

Phase 7: Verification (depends on all)
  7.1 Create script ───────────┐
  7.2 Run script ──────────────┼─→ DONE
  7.3 Update V5_PLANNING.md ───┘

Parallelizable:
  - Phase 1 and Phase 2 (no dependencies)
  - Phase 3 and Phase 4 (both depend on 1,2)
  - Tasks within each phase

Critical Path: 1.1 → 3.1 → 5.1 → 6.1 → 7.2
```

---

## Part 7: Verification Script

Save as `scripts/tests/test-code-review-completion.sh`:

```bash
#!/bin/bash
set -e

echo "=== V5.0 Code Review Completion Verification ==="
echo ""

PASS=0
FAIL=0

check() {
  if eval "$1" > /dev/null 2>&1; then
    echo "✓ $2"
    ((PASS++))
  else
    echo "✗ $2"
    ((FAIL++))
  fi
}

# Helper: extract contract JSON from agent file
extract_contract() {
  local file="$1"
  sed -n '/## Agent Contract/,/^## /p' "$file" | \
    sed -n '/```json/,/```/p' | \
    sed '1d;$d'
}

# Helper: validate contract has required fields and expected id
validate_contract() {
  local file="$1"
  local expected_id="$2"
  extract_contract "$file" | \
    jq -e ".id == \"$expected_id\" and has(\"prefix\") and has(\"category\") and has(\"applicability\")" > /dev/null 2>&1
}

echo "--- Phase 1: Schema Files ---"
check "test -f .claude/schemas/agent-contract.json" "agent-contract.json exists"
check "jq -e '.properties.applicability.required | length == 3' .claude/schemas/agent-contract.json" "agent-contract schema has required fields"
check "jq -e '.properties.category.type == \"string\"' .claude/schemas/audit-finding.json" "audit-finding.category is string"
check "jq -e '.properties.metadata.properties.agentsSkipped' .claude/schemas/audit-report.json" "audit-report has agentsSkipped"

echo ""
echo "--- Phase 2: Scanner Updates ---"
check "grep -q 'hasDatabase' .claude/agents/codebase-scanner.md" "Scanner detects hasDatabase"
check "grep -q 'hasUI' .claude/agents/codebase-scanner.md" "Scanner detects hasUI"
check "grep -q 'hasCI' .claude/agents/codebase-scanner.md" "Scanner detects hasCI"
check "grep -q 'isGitRepo' .claude/agents/codebase-scanner.md" "Scanner tracks isGitRepo"
check "grep -q 'git ls-files' .claude/agents/codebase-scanner.md" "Scanner documents git ls-files"
check "grep -q 'securityRelevant' .claude/agents/codebase-scanner.md" "Scanner has securityRelevant list"
check "grep -q 'databaseFiles' .claude/agents/codebase-scanner.md" "Scanner has databaseFiles list"
check "grep -q 'uiComponents' .claude/agents/codebase-scanner.md" "Scanner has uiComponents list"
check "grep -q 'ciWorkflows' .claude/agents/codebase-scanner.md" "Scanner has ciWorkflows list"

echo ""
echo "--- Phase 3 & 4: Specialist Agent Files ---"
SPECIALISTS="security performance accessibility type-safety test-coverage seo database infrastructure"
for name in $SPECIALISTS; do
  check "test -f .claude/agents/${name}-reviewer.md" "${name}-reviewer exists"
done

echo ""
echo "--- Agent Contracts ---"
check "validate_contract .claude/agents/security-reviewer.md security" "security contract valid"
check "validate_contract .claude/agents/performance-reviewer.md performance" "performance contract valid"
check "validate_contract .claude/agents/accessibility-reviewer.md accessibility" "accessibility contract valid"
check "validate_contract .claude/agents/type-safety-reviewer.md typescript" "typescript contract valid"
check "validate_contract .claude/agents/test-coverage-reviewer.md testing" "testing contract valid"
check "validate_contract .claude/agents/seo-reviewer.md seo" "seo contract valid"
check "validate_contract .claude/agents/database-reviewer.md database" "database contract valid"
check "validate_contract .claude/agents/infrastructure-reviewer.md infrastructure" "infrastructure contract valid"

echo ""
echo "--- Agent Uniqueness (no duplicate IDs) ---"
ALL_IDS=$(for f in .claude/agents/*-reviewer.md; do extract_contract "$f" 2>/dev/null | jq -r '.id // empty'; done | sort)
UNIQUE_IDS=$(echo "$ALL_IDS" | uniq)
check "[ \"$ALL_IDS\" = \"$UNIQUE_IDS\" ]" "All agent IDs are unique"

echo ""
echo "--- File Scope Documentation ---"
check "grep -q 'securityRelevant\|File Scope' .claude/agents/security-reviewer.md" "security-reviewer documents file scope"
check "grep -q 'databaseFiles\|File Scope' .claude/agents/database-reviewer.md" "database-reviewer documents file scope"
check "grep -q 'uiComponents\|File Scope' .claude/agents/seo-reviewer.md" "seo-reviewer documents file scope"
check "grep -q 'ciWorkflows\|File Scope' .claude/agents/infrastructure-reviewer.md" "infrastructure-reviewer documents file scope"

echo ""
echo "--- Phase 5: Code Reviewer Updates ---"
check "grep -qi 'discover\|discovery' .claude/agents/code-reviewer.md" "code-reviewer has discovery"
check "grep -q 'duplicate\|Duplicate\|unique' .claude/agents/code-reviewer.md" "code-reviewer checks uniqueness"
check "grep -q ':contains\|:in' .claude/agents/code-reviewer.md" "code-reviewer supports condition operators"
check "grep -q 'fallback' .claude/agents/code-reviewer.md" "code-reviewer has fallback"
check "grep -q 'agentsSkipped' .claude/agents/code-reviewer.md" "code-reviewer tracks skipped agents"
check "grep -q 'audit-NN\|incrementing\|next available' .claude/agents/code-reviewer.md" "code-reviewer uses incrementing output"

echo ""
echo "--- Framework-Aware SEO ---"
check "grep -q 'generateMetadata' .claude/agents/seo-reviewer.md" "SEO reviewer handles Next.js metadata"
check "grep -q 'projectType:in' .claude/agents/seo-reviewer.md" "SEO reviewer uses :in operator"

echo ""
echo "--- Phase 6: Command Integration ---"
check "grep -q 'code-reviewer' .claude/commands/code-review.md" "/code-review mentions code-reviewer"
check "! grep -q 'A01: Broken Access' .claude/commands/code-review.md" "/code-review has no OWASP checklists"
check "! grep -q 'grep -rn' .claude/commands/code-review.md" "/code-review has no inline grep"

echo ""
echo "--- Deprecation Notices ---"
DEPRECATED=$(grep -l "DEPRECATED" .claude/commands/code-review-*.md 2>/dev/null | wc -l | tr -d ' ')
check "[ '$DEPRECATED' -eq 8 ]" "All 8 old commands deprecated ($DEPRECATED/8)"

echo ""
echo "--- Extensibility Test ---"
# Create temporary agent, verify it would be discovered, clean up
TEMP_AGENT=".claude/agents/i18n-reviewer.md"
cat > "$TEMP_AGENT" << 'TEMPEOF'
# i18n Reviewer Agent

Temporary test agent.

## Agent Contract

```json
{
  "id": "i18n",
  "prefix": "I18N",
  "category": "i18n",
  "applicability": {
    "always": false,
    "requires": {},
    "presets": ["prelaunch"]
  }
}
```
TEMPEOF

check "validate_contract '$TEMP_AGENT' i18n" "Temp i18n-reviewer has valid contract"
check "ls .claude/agents/*-reviewer.md | grep -q i18n" "Temp agent discoverable by glob"
rm -f "$TEMP_AGENT"
check "! test -f '$TEMP_AGENT'" "Temp agent cleaned up"

echo ""
echo "=== Summary ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "✅ ALL CHECKS PASSED"
  echo ""
  echo "Extensibility verified: Adding i18n-reviewer required only creating one file."
else
  echo "❌ SOME CHECKS FAILED"
fi

exit $FAIL
```

---

## Part 8: Success Criteria

**Complete when ALL of the following are true:**

1. `scripts/tests/test-code-review-completion.sh` passes with 0 failures
2. All 8 specialists have valid Agent Contracts
3. All specialists document which scanner file list they use
4. code-reviewer discovers agents dynamically
5. code-reviewer validates contracts against schema
6. code-reviewer fails hard on duplicate IDs
7. code-reviewer supports `:contains` and `:in` operators
8. `/code-review` invokes agent, no inline logic
9. All 8 old commands have deprecation notices
10. Extensibility test passes (temp agent discovered)

---

## Appendix A: Deferred to v5.1

These items were considered but deferred as premature for v5.0:

| Item | Reason for Deferral |
|------|---------------------|
| Fingerprint-based deduplication | Needs real-world data on duplicate patterns |
| Schema compatibility versioning (minSchemaVersion) | No version drift yet to handle |
| Atomic file locking for audit-NN | Low probability edge case |
| Per-agent timeouts/concurrency limits | Runtime concern, not design concern |

---

## Appendix B: Key Changes from v4.0

| v4.0 | v5.0 |
|------|------|
| Equality-only condition matching | Added `:contains` and `:in` operators |
| No uniqueness enforcement | Duplicate IDs = hard failure |
| No contract validation | Contracts validated against schema |
| Agents scan repo-wide | Agents use scanner's specialized file lists |
| Conceptual extensibility test | Automated extensibility test in script |

---

## Appendix C: Contract Extraction Helper

For programmatic contract extraction:

```bash
# Extract contract JSON from agent file
extract_contract() {
  local file="$1"
  sed -n '/## Agent Contract/,/^## /p' "$file" | \
    sed -n '/```json/,/```/p' | \
    sed '1d;$d'
}

# Validate contract has all required fields
validate_contract() {
  local file="$1"
  extract_contract "$file" | \
    jq -e 'has("id") and has("prefix") and has("category") and has("applicability")'
}

# Get agent ID from file
get_agent_id() {
  local file="$1"
  extract_contract "$file" | jq -r '.id'
}

# Check for duplicate IDs across all agents
check_unique_ids() {
  local ids=""
  for f in .claude/agents/*-reviewer.md; do
    local id=$(get_agent_id "$f")
    if echo "$ids" | grep -q "^$id$"; then
      echo "ERROR: Duplicate ID '$id' in $f"
      return 1
    fi
    ids="$ids$id"$'\n'
  done
  return 0
}
```

---

## Appendix D: Condition Operator Examples

```json
// Equality (default)
"structure.hasUI": true
"structure.primaryLanguage": "typescript"

// Contains (for arrays)
"structure.frameworks:contains": "next.js"
"structure.frameworks:contains": "prisma"

// In (for enum-like fields)
"structure.projectType:in": ["webapp", "monorepo"]
"structure.primaryLanguage:in": ["typescript", "javascript"]
```

Evaluation pseudocode:
```
function evaluateCondition(key, value, scannerOutput):
  if key contains ":contains":
    field = key.split(":")[0]
    return scannerOutput[field].includes(value)

  if key contains ":in":
    field = key.split(":")[0]
    return value.includes(scannerOutput[field])

  // Default: equality
  return scannerOutput[key] === value
```

---

*End of V5.0 Code Review Completion Plan*
