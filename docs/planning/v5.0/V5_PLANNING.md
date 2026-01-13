# AI Context System v5.0 - First Principles Redesign

**Document Version:** 3.0
**Created:** 2026-01-12
**Last Updated:** 2026-01-13
**Status:** Planning

---

## Executive Summary

Version 5.0 represents a fundamental reimagining of the AI Context System. Rather than patching v4.x, we're redesigning from first principles with three core insights:

1. **Claude Code has evolved** - Skills, agents, hooks, and MCP servers enable capabilities that didn't exist when ACS was designed
2. **AI-to-AI handoffs are the primary use case** - The system should be optimized for AI agents, not human developers
3. **Less is more** - v4.x has accumulated tech debt (22 commands, 8 scripts, 12 templates) that creates friction

**Vision:** A lean, agent-native context system that leverages Claude Code's built-in architecture rather than fighting it.

### MVP Definition (Must Ship First)

Before building the full system, we must prove the redesign works with three skills working end-to-end:

| Skill | Input | Output | Verification |
|-------|-------|--------|--------------|
| `/init` | Empty or existing project | context/ with auto-detected values | Config created, `grep -cE '\[FILL:[^\]]+\]'` returns <3 |
| `/review` | Existing context/ | Health score + resume point | Score 0-100 per algorithm in §4.6, resume point matches §4.8 format |
| `/save-full` | Work session | Session entry in SESSIONS.md | Entry validates against SessionEntry schema |

**Gate:** Phase 2+ cannot begin until MVP loop passes all verification criteria on all 3 fixture repos.

---

## Part 1: Core Principles

These principles govern all v5.0 development decisions. When in doubt, refer here.

### 1.1 Quality Over Speed

- **No time constraints.** We ship when it's right, not when it's scheduled.
- **No bandaids.** Every fix addresses root cause. If we don't understand why something broke, we don't ship.
- **No quick fixes.** Temporary solutions become permanent debt. Take the time to do it properly.

### 1.2 Maintainability First

- **Single source of truth.** Every piece of data lives in exactly one place (see §2.3 Canonical vs Derived).
- **Explicit over implicit.** If behavior isn't obvious from reading the code, add comments or restructure.
- **Small, focused components.** Each skill/agent/hook does one thing well.

### 1.3 Testability

- **Every feature has a verification criterion.** If we can't objectively test it, we don't build it.
- **Golden file tests for outputs.** STATUS.md Quick Reference, session entries, audit reports all have expected formats.
- **Fixture repos for integration.** Real project structures, not mocked data.

### 1.4 Safe Failure

- **Hooks never block.** If a hook fails, it warns and continues. Never interrupt the user's workflow.
- **Graceful degradation.** If a component fails, the system still works (just with reduced functionality).
- **Clear error messages.** One line describing what failed, one line suggesting fix, link to docs.

### 1.5 Contracts Between Components

- **JSON schemas for all interfaces.** Skills, agents, and hooks communicate via defined structures.
- **Version your schemas.** Breaking changes require schema version bump.
- **Validate at boundaries.** Check inputs match schema before processing.

### 1.6 Lean Implementation

- **No speculative features.** Build what's needed now, not what might be needed later.
- **Prefer deletion over addition.** If in doubt, leave it out.
- **Implementation details in code, not planning docs.** This document specifies WHAT, not HOW.

---

## Part 2: What We Keep vs Remove

### 2.1 Core Philosophy (Keep Exactly)

| Concept | Why It Works |
|---------|--------------|
| **Session Continuity** | Primary design goal - zero context loss |
| **Externalized AI Context** | Makes reasoning visible and reviewable |
| **Minimal Overhead** | Core system = 4 files, complexity-driven expansion |
| **User Control** | Explicit approval for destructive actions |
| **DECISIONS.md** | WHY choices were made (critical for AI) |
| **TL;DR Requirement** | Mandatory 2-3 sentence summaries |
| **Append-Only SESSIONS.md** | Simple, reliable, no data loss |

### 2.2 Core Files (Keep with Refinement)

```
context/
├── CONTEXT.md           # Orientation (rarely changes)
├── STATUS.md            # Current state + Quick Reference
├── DECISIONS.md         # Decision log with rationale
├── SESSIONS.md          # Session history with mental models
└── .context-config.json # Simple configuration
```

**Changes from v4.x:**
- Remove `context-feedback.md` (fold into SESSIONS.md)
- Simplify templates (more auto-detection, fewer placeholders)
- CLAUDE.md stays at project root (auto-loaded by Claude Code)

### 2.3 Canonical vs Derived Sources

| File/Section | Type | Regenerable From | Update Frequency |
|--------------|------|------------------|------------------|
| CONTEXT.md | **Canonical** | - | Rarely (project changes) |
| DECISIONS.md | **Canonical** | - | On each decision |
| SESSIONS.md | **Canonical** | - | End of each session |
| .context-config.json | **Canonical** | - | On config changes |
| STATUS.md (body) | **Canonical** | - | During work |
| STATUS.md Quick Reference | **Derived** | CONTEXT.md + STATUS.md + SESSIONS.md + git | On /save, /review |
| Health reports | **Derived** | All canonical sources | On /review |
| Export packages | **Derived** | All canonical sources | On /export |
| Audit reports | **Derived** | Codebase scan | On /code-review |

**Rule:** Derived views MUST be fully regenerable from canonical sources. Golden file tests verify this.

### 2.4 Reduction Summary

| Area | v4.2.1 | v5.0 | Reduction |
|------|--------|------|-----------|
| Commands | 22 | 8 skills | 64% fewer |
| Scripts | 8 (~4,400 lines) | 2 (~600 lines) | 86% less code |
| Templates | 12 | 5 | 58% fewer |
| Config options | 40+ | 3 profiles | 92% simpler |

### 2.5 What's Explicitly Removed

| Removed | Reason | Alternative |
|---------|--------|-------------|
| `/organize-docs` | Rare usage | Manual or agent task |
| `/session-summary` | Redundant | Fold into `/review` |
| `/update-templates` | Confusing | Fold into `/update` |
| `/add-ai-header` | Rare usage | Fold into `/init` |
| `/build-check` | Project-specific | User's own scripts |
| `context-feedback.md` | Overhead | Feedback in SESSIONS.md |
| v3.x migration scripts | Tech debt | v3 users upgrade to v4 first |
| 8 code review commands | Fragmented | Single `/code-review` with agents |

---

## Part 3: Architecture

### 3.1 Component Types

```
┌─────────────────────────────────────────────────────────────────┐
│                     AI CONTEXT SYSTEM v5.0                      │
├─────────────────────────────────────────────────────────────────┤
│  SKILLS (8)           │  AGENTS (8)          │  HOOKS (2)       │
│  ├── /init            │  ├── code-reviewer   │  ├── SessionStart│
│  ├── /save            │  ├── codebase-scanner│  └── PostToolUse │
│  ├── /save-full       │  ├── security-reviewer                  │
│  ├── /review          │  ├── performance-reviewer               │
│  ├── /validate        │  ├── accessibility-reviewer             │
│  ├── /export          │  ├── type-safety-reviewer               │
│  ├── /update          │  ├── test-coverage-reviewer             │
│  └── /code-review     │  └── synthesis-agent                    │
├─────────────────────────────────────────────────────────────────┤
│  CONTEXT FILES (4)                                              │
│  ├── CONTEXT.md (stable)    ├── DECISIONS.md (append-only)     │
│  ├── STATUS.md (dynamic)    └── SESSIONS.md (append-only)      │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Directory Structure

```
project/
├── CLAUDE.md                     # Entry point (auto-loaded)
├── context/                      # Core context files
│   ├── CONTEXT.md, STATUS.md, DECISIONS.md, SESSIONS.md
│   ├── .context-config.json
│   └── .todo-state.json          # Persisted TodoWrite state
├── .claude/
│   ├── skills/{name}/SKILL.md    # 8 skills
│   ├── agents/{name}.md          # 8 agents
│   ├── hooks/session-start.sh    # Safe-fail hooks
│   ├── schemas/*.json            # 5 JSON schemas
│   └── settings.json             # Hook configuration
├── docs/audits/                  # Code review reports
└── artifacts/exports/            # Handoff packages
```

### 3.3 Execution Flow

**v4.x:** User → Command → Claude reads markdown → Calls bash scripts → Output
**v5.0:** User → Skill → Claude follows instructions → Delegates to agents (parallel) → Structured output (JSON)

---

## Part 4: Contracts & Schemas

All component interfaces are defined by JSON schemas. Every schema includes `$id` and `schemaVersion` for forward compatibility.

### 4.1 Context Health Schema

```json
{
  "$id": "https://acs.rexkirshner.com/schemas/context-health.json",
  "schemaVersion": "1.0.0",
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "ContextHealth",
  "type": "object",
  "required": ["score", "breakdown", "nextAction", "resumePoint"],
  "properties": {
    "score": { "type": "integer", "minimum": 0, "maximum": 100 },
    "breakdown": {
      "type": "object",
      "properties": {
        "statusFreshness": { "type": "integer", "minimum": 0, "maximum": 20 },
        "sessionsFreshness": { "type": "integer", "minimum": 0, "maximum": 20 },
        "decisionsCoverage": { "type": "integer", "minimum": 0, "maximum": 15 },
        "contextCompleteness": { "type": "integer", "minimum": 0, "maximum": 15 },
        "quickReferenceSync": { "type": "integer", "minimum": 0, "maximum": 15 },
        "crossReferences": { "type": "integer", "minimum": 0, "maximum": 15 }
      }
    },
    "warnings": { "type": "array", "items": { "type": "string" } },
    "nextAction": { "type": "string" },
    "resumePoint": { "type": "string", "pattern": "^[A-Z][a-z]+ .+ (in|at) .+$" }
  }
}
```

### 4.2 Audit Finding Schema

```json
{
  "$id": "https://acs.rexkirshner.com/schemas/audit-finding.json",
  "schemaVersion": "1.0.0",
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "AuditFinding",
  "type": "object",
  "required": ["id", "severity", "category", "title", "location", "verified"],
  "properties": {
    "id": { "type": "string", "pattern": "^[A-Z]+-[0-9]+$" },
    "severity": { "type": "string", "enum": ["critical", "high", "medium", "low", "info"] },
    "category": { "type": "string", "enum": ["security", "performance", "accessibility", "typescript", "testing", "other"] },
    "title": { "type": "string", "maxLength": 100 },
    "description": { "type": "string" },
    "location": {
      "type": "object",
      "required": ["file"],
      "properties": {
        "file": { "type": "string" },
        "line": { "type": "integer" },
        "snippet": { "type": "string" }
      }
    },
    "verified": {
      "type": "object",
      "required": ["vulnPatternSearched", "mitigationPatternSearched", "mitigationFound"],
      "properties": {
        "vulnPatternSearched": { "type": "string" },
        "mitigationPatternSearched": { "type": "string" },
        "mitigationFound": { "type": "boolean" },
        "verificationNotes": { "type": "string" }
      }
    },
    "remediation": { "type": "string" },
    "effort": { "type": "string", "enum": ["trivial", "small", "medium", "large"] }
  }
}
```

### 4.3 Audit Report Schema

```json
{
  "$id": "https://acs.rexkirshner.com/schemas/audit-report.json",
  "schemaVersion": "1.0.0",
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "AuditReport",
  "type": "object",
  "required": ["metadata", "summary", "findings"],
  "properties": {
    "metadata": {
      "type": "object",
      "properties": {
        "timestamp": { "type": "string", "format": "date-time" },
        "acsVersion": { "type": "string" },
        "projectName": { "type": "string" },
        "agentsRun": { "type": "array", "items": { "type": "string" } },
        "filesScanned": { "type": "integer" },
        "cacheHit": { "type": "boolean" }
      }
    },
    "summary": {
      "type": "object",
      "properties": {
        "grade": { "type": "string", "pattern": "^[A-F][+-]?$" },
        "criticalCount": { "type": "integer" },
        "highCount": { "type": "integer" },
        "mediumCount": { "type": "integer" },
        "lowCount": { "type": "integer" }
      }
    },
    "findings": { "type": "array", "items": { "$ref": "audit-finding.json" } },
    "positives": { "type": "array", "items": { "type": "string" } }
  }
}
```

### 4.4 Session Entry Schema

```json
{
  "$id": "https://acs.rexkirshner.com/schemas/session-entry.json",
  "schemaVersion": "1.0.0",
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "SessionEntry",
  "type": "object",
  "required": ["number", "date", "tldr", "focus"],
  "properties": {
    "number": { "type": "integer", "minimum": 1 },
    "date": { "type": "string", "format": "date" },
    "focus": { "type": "string", "maxLength": 100 },
    "tldr": { "type": "string", "minLength": 50, "maxLength": 300 },
    "accomplishments": { "type": "array", "items": { "type": "string" } },
    "decisions": { "type": "array", "items": { "type": "object", "properties": { "id": { "type": "string" }, "summary": { "type": "string" } } } },
    "filesChanged": { "type": "array", "items": { "type": "string" } },
    "mentalModels": { "type": "string" },
    "nextSteps": { "type": "array", "items": { "type": "string" } },
    "gitOperations": { "type": "object", "properties": { "commits": { "type": "integer" }, "pushed": { "type": "boolean" }, "branch": { "type": "string" } } }
  }
}
```

### 4.5 Handoff Package Schema

```json
{
  "$id": "https://acs.rexkirshner.com/schemas/handoff-package.json",
  "schemaVersion": "1.0.0",
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "HandoffPackage",
  "type": "object",
  "required": ["metadata", "summary", "contextFiles", "nextSteps"],
  "properties": {
    "metadata": { "type": "object", "properties": { "exportedAt": { "type": "string", "format": "date-time" }, "acsVersion": { "type": "string" }, "projectName": { "type": "string" } } },
    "summary": { "type": "object", "properties": { "projectState": { "type": "string", "maxLength": 500 }, "criticalDecisions": { "type": "array", "items": { "type": "string" } }, "activeBlockers": { "type": "array", "items": { "type": "string" } } } },
    "contextFiles": { "type": "object", "properties": { "context": { "type": "string" }, "status": { "type": "string" }, "decisions": { "type": "string" }, "recentSessions": { "type": "array", "items": { "type": "string" } } } },
    "nextSteps": { "type": "array", "items": { "type": "string" } }
  }
}
```

### 4.6 Health Score Algorithm

The health score is computed deterministically from context file state:

| Component | Max Points | Calculation |
|-----------|------------|-------------|
| **statusFreshness** | 20 | `20 - min(20, daysSinceStatusUpdate * 2)` |
| **sessionsFreshness** | 20 | `20 - min(20, daysSinceLastSession * 2)` |
| **decisionsCoverage** | 15 | `15` if recent session refs decision, else `10` if any decisions exist, else `0` |
| **contextCompleteness** | 15 | `15 - (placeholderCount * 3)`, min 0 |
| **quickReferenceSync** | 15 | `15` if QR matches STATUS.md state, else `0` |
| **crossReferences** | 15 | `15 - (brokenRefs * 5)`, min 0 |
| **Total** | **100** | Sum of all components |

**Thresholds:**
- 80-100: Healthy (green)
- 50-79: Needs attention (yellow)
- 0-49: Critical (red)

**Verification:** Golden file test with known inputs produces expected score.

### 4.7 Placeholder Specification

Placeholders are detected by the regex pattern: `\[FILL:[^\]]+\]`

**Examples:**
- `[FILL: Project name]` ← Counted
- `[FILL:description]` ← Counted
- `[TODO: something]` ← NOT counted (different prefix)
- `[FILL]` ← NOT counted (no colon)

**Verification:** `grep -cE '\[FILL:[^\]]+\]' context/CONTEXT.md` returns placeholder count.

### 4.8 Resume Point Format

Resume points MUST match this pattern: `^[A-Z][a-z]+ .+ (in|at) .+$`

**Valid examples:**
- `Continue implementing auth middleware in src/middleware/auth.ts`
- `Review the failing tests at tests/api/users.test.ts:45`
- `Fix the validation error in components/Form.tsx`

**Invalid examples:**
- `auth middleware` ← No verb, no location
- `Continue working` ← No specific location
- `src/file.ts` ← No verb, no action

**Verification:** Resume point matches regex pattern.

### 4.9 Profile Configuration Schema

```json
{
  "$id": "https://acs.rexkirshner.com/schemas/context-config.json",
  "schemaVersion": "1.0.0",
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "ContextConfig",
  "type": "object",
  "required": ["version", "profile"],
  "properties": {
    "version": { "type": "string", "pattern": "^[0-9]+\\.[0-9]+\\.[0-9]+$" },
    "profile": { "type": "string", "enum": ["minimal", "standard", "full"] },
    "project": { "type": "object", "properties": { "name": { "type": "string" }, "type": { "type": "string" } } },
    "custom": { "type": "object", "additionalProperties": true }
  }
}
```

**Profile Toggle Matrix:**

| Feature | minimal | standard | full |
|---------|---------|----------|------|
| SessionStart hook | ❌ | ✅ | ✅ |
| PostToolUse hook | ❌ | ❌ | ✅ |
| Auto Quick Reference | ❌ | ✅ | ✅ |
| Verbose health output | ❌ | ❌ | ✅ |
| Incremental code review | ❌ | ✅ | ✅ |
| Parallel agents | ✅ | ✅ | ✅ |

**Rule:** Profile changes MUST NOT break schema outputs. Only verbosity/automation differs.

---

## Part 5: Implementation Phases

Each phase has explicit outputs and a Definition of Done with objectively verifiable checkpoints.

### Phase 0: Foundation

**Purpose:** Test infrastructure before building features.

| Output | Verification |
|--------|--------------|
| 5 JSON schemas in `.claude/schemas/` | `npx ajv validate -s .claude/schemas/*.json` passes |
| 3 fixture repos in `test/fixtures/` | `ls test/fixtures/{nextjs-app,python-cli,monorepo}` succeeds |
| Golden files in `test/golden/` | Files exist for quick-reference, session-entry, audit-report |
| `scripts/verify-phase.sh` | `./scripts/verify-phase.sh 0` exits 0 |

**Gate:** All outputs verified before Phase 1.

---

### Phase 1: MVP Loop

**Purpose:** Prove the core workflow works.

| Output | Verification |
|--------|--------------|
| `/init` skill | On fixture repo: `grep -cE '\[FILL:[^\]]+\]'` returns <3 |
| `/review` skill | Output validates against ContextHealth schema, score 0-100 |
| `/save-full` skill | Session entry validates against SessionEntry schema |
| End-to-end test | init → work → save-full → review shows score ≥80 |

**Gate:** All verifications pass on ALL 3 fixture repos before Phase 2.

---

### Phase 2: Additional Skills

**Purpose:** Complete core skill set.

| Output | Verification |
|--------|--------------|
| `/save` | `git diff --name-only` shows only `context/STATUS.md` |
| `/validate` | Detects injected broken reference `D999` |
| `/export` | Output validates against HandoffPackage schema |
| `/update` | Creates backup dir, produces MIGRATION_SUMMARY.md |

**Gate:** All skills have passing golden file tests.

---

### Phase 3: Code Review Agents

**Purpose:** Build parallel code review system.

| Output | Verification |
|--------|--------------|
| `codebase-scanner` agent | Produces `.claude/cache/codebase-context.json` |
| `security-reviewer` agent | Findings validate against AuditFinding schema |
| `code-reviewer` orchestrator | Runs scanner first, then specialists in parallel |
| `synthesis-agent` | Merges duplicates (same file:line = one finding) |
| Final report | Validates against AuditReport schema |

**Gate:** Every finding includes `verified` object with pattern searches.

---

### Phase 4: Remaining Agents

**Purpose:** Complete specialist agent set.

| Output | Verification |
|--------|--------------|
| 4 specialist agents | Each produces valid AuditFinding |
| `audit-compare` | Reads previous report, shows trend |
| `--quick` mode | Completes in <3 minutes |
| `--incremental` mode | Only scans files in `git diff --name-only` |

**Gate:** All specialists include verification step.

---

### Phase 5: Hooks (Safe-Fail)

**Purpose:** Add automation without friction.

| Output | Verification |
|--------|--------------|
| `session-start.sh` hook | Runs on session start, prints health summary |
| Hook failure handling | Exit code 1 → warning printed, execution continues |
| Hook timeout | >2s → killed with warning |
| `minimal` profile | Disables all hooks |

**Gate:** Hooks are idempotent (running twice = same result).

---

### Phase 6: Migration & Update

**Purpose:** Safe upgrade path with rollback.

| Output | Verification |
|--------|--------------|
| Backup creation | Timestamped `.claude-backup-*` directory created |
| MIGRATION_SUMMARY.md | Contains backup location + rollback command |
| Rollback script | `./scripts/rollback.sh` restores v4.x structure |
| Command aliases | Old names work with deprecation warning |
| Checksum verification | Downloaded files match manifest SHA-256 |

**Gate:** Full upgrade → rollback cycle on fixture repo preserves all user content.

---

### Phase 7: Documentation

**Purpose:** Production-ready docs.

| Output | Verification |
|--------|--------------|
| acs-docs website | `npm run build` succeeds |
| All skills documented | `test -f docs/skills/{name}.md` for each |
| Migration guide | Complete with examples |
| CHANGELOG.md | v5.0 entry present |

**Gate:** `npx linkinator docs/ --recurse` finds no broken links.

---

### Phase 8: Release

**Purpose:** Ship v5.0.0.

| Output | Verification |
|--------|--------------|
| All phase gates pass | `for i in 0..7; ./scripts/verify-phase.sh $i` |
| VERSION = 5.0.0 | `cat VERSION` |
| Git tag v5.0.0 | `git tag -l v5.0.0` |
| Install works | `curl install.sh \| bash` then `claude --version` shows 5.0.0 |

---

## Part 6: Quality Gates & Testing

### 6.1 Test Types

| Type | Purpose | Location | When |
|------|---------|----------|------|
| Schema validation | Verify JSON outputs | `test/schemas/` | Every phase |
| Golden file tests | Verify output format | `test/golden/` | Every phase |
| Fixture repo tests | Integration | `test/fixtures/` | Phase 1+ |
| Migration tests | Upgrade/rollback | `test/migration/` | Phase 6 |

### 6.2 Fixture Repositories

| Fixture | Stack | Files | Purpose |
|---------|-------|-------|---------|
| `nextjs-app` | Next.js 14, TS, Prisma, Auth.js | 10-15 | Web app patterns |
| `python-cli` | Python, Click, pytest | 5-10 | CLI patterns |
| `monorepo` | Turborepo, 2 apps, 3 packages | 20+ | Complex structure |

### 6.3 Golden Files

```
test/golden/
├── quick-reference.md       # Expected STATUS.md Quick Reference
├── session-entry.md         # Expected SESSIONS.md entry format
├── audit-report.json        # Expected code review output
├── context-health.json      # Expected /review output
└── handoff-package.json     # Expected /export output
```

---

## Part 7: Migration Strategy

### 7.1 Supported Upgrade Paths

| From | To | Support | Action |
|------|-----|---------|--------|
| v4.2.x | v5.0 | ✅ Full | Automated migration |
| v4.1.x | v5.0 | ✅ Full | Automated migration |
| v4.0.x | v5.0 | ✅ Full | Automated migration |
| v3.x | v5.0 | ❌ None | Must upgrade to v4.x first |
| No ACS | v5.0 | N/A | Use `/init` |

### 7.2 Migration Phases

| Phase | Steps | Verification |
|-------|-------|--------------|
| **Pre-flight** | Detect version, validate v4.x, check uncommitted changes, validate files | VERSION matches `4.*`, all context files exist |
| **Backup** | Create timestamped backup of .claude/, scripts/, templates/, VERSION | `diff -rq` shows no differences from originals |
| **Content** | Preserve CONTEXT/DECISIONS/SESSIONS, archive context-feedback.md | Canonical files unchanged, feedback in SESSIONS.md |
| **Config** | Read old config, map to profile, write new config | `jq .` parses successfully |
| **Structure** | Remove commands/, create skills/, agents/, hooks/, schemas/ | File counts match expected |
| **Cleanup** | Remove deprecated files, update .gitignore | No old files remain |
| **Validate** | Verify files accessible, skills loadable, health check | /review produces valid output |
| **Document** | Generate MIGRATION_SUMMARY.md, update VERSION, log to SESSIONS.md | Files exist with correct content |

### 7.3 Migration Verification Checklist

| Check | Command | Expected |
|-------|---------|----------|
| Backup complete | `diff -rq .claude $BACKUP/.claude` | No output |
| Skills installed | `ls .claude/skills/*/SKILL.md \| wc -l` | 8 |
| Agents installed | `ls .claude/agents/*.md \| wc -l` | 8 |
| Schemas installed | `ls .claude/schemas/*.json \| wc -l` | 5 |
| Config valid | `jq . context/.context-config.json` | Valid JSON |
| Old commands removed | `ls .claude/commands/ 2>&1` | "No such file" |
| User content preserved | `wc -l context/SESSIONS.md` | Same as before |
| VERSION updated | `cat VERSION` | 5.0.0 |

### 7.4 Rollback

**Trigger:** Any critical failure during migration or user request.

**Command:** `./scripts/rollback.sh [backup-dir]`

**Actions:**
1. Remove v5.0 structure (.claude/skills, agents, hooks, schemas)
2. Restore v4.x structure from backup
3. Restore VERSION file
4. Remove MIGRATION_SUMMARY.md

**Guarantee:** User content (CONTEXT.md, DECISIONS.md, SESSIONS.md) is NEVER modified during migration or rollback.

### 7.5 Breaking Changes

| Change | v4.x | v5.0 | Migration |
|--------|------|------|-----------|
| Commands → Skills | `.claude/commands/*.md` | `.claude/skills/*/SKILL.md` | Aliases for 6 months |
| Scripts | 10 files | 2 files | Backup preserved |
| Config | 40+ options | 3 profiles | Auto-mapped |
| context-feedback.md | Separate file | Removed | Archived to SESSIONS.md |
| v3.x support | Migration scripts | Not supported | Must upgrade to v4 first |

---

## Part 8: Security & Integrity

### 8.1 Update Verification

**Problem:** curl-from-GitHub is convenient but risky.

**Solution:** Manifest with SHA-256 checksums.

```json
{
  "version": "5.0.0",
  "files": {
    ".claude/skills/init/SKILL.md": "sha256:abc123...",
    ".claude/skills/save/SKILL.md": "sha256:def456...",
    ".claude/agents/code-reviewer.md": "sha256:ghi789...",
    ...
  }
}
```

**Verification steps:**
1. Download manifest from pinned tag + commit SHA
2. Download each file
3. Compute SHA-256 of downloaded content
4. Compare to manifest
5. Fail if ANY mismatch

### 8.2 Staged Apply Pattern

**Never modify project files directly during update.**

1. Download all files to temp directory
2. Verify all checksums
3. Create backup of existing installation
4. Atomically swap: `mv .claude .claude-old && mv temp/.claude .claude`
5. On failure: `mv .claude-old .claude`

### 8.3 Concurrency Protection

**Problem:** Multiple agents or rapid skill invocations could corrupt append-only logs.

**Solution:** File locking for SESSIONS.md and DECISIONS.md writes.

```bash
# Acquire lock
exec 200>context/.sessions.lock
flock -x 200

# Write to file
echo "$SESSION_ENTRY" >> context/SESSIONS.md

# Lock released automatically on script exit
```

**Session number enforcement:**
1. Read last session number: `grep -oE "^## Session [0-9]+" SESSIONS.md | tail -1 | grep -oE "[0-9]+"`
2. New session = last + 1
3. If mismatch detected, abort with error

### 8.4 Partial Write Protection

**Problem:** Process killed mid-write leaves corrupted file.

**Solution:** Write to temp, then atomic rename.

```bash
# Write complete entry to temp file
cat > context/.sessions.tmp << EOF
$SESSION_ENTRY
EOF

# Atomic append
cat context/.sessions.tmp >> context/SESSIONS.md
rm context/.sessions.tmp
```

---

## Part 9: Success Metrics

### 9.1 Quantitative

| Metric | v4.x Baseline | v5.0 Target | Verification |
|--------|---------------|-------------|--------------|
| Skills | 22 commands | 8 | `ls .claude/skills \| wc -l` |
| Script lines | ~4,400 | ~600 | `wc -l scripts/*.sh` |
| Templates | 12 | 5 | `ls templates \| wc -l` |
| Config options | 40+ | 3 profiles | Schema check |
| False positive rate | ~35% | <15% | Manual audit |

### 9.2 Qualitative

| Goal | Verification |
|------|--------------|
| New users productive in <5 min | User testing |
| Daily workflow uses ≤3 skills | Usage telemetry (opt-in) |
| Code reviews find real issues | Manual audit |
| New contributor adds skill in <1 hour | Onboarding test |
| Migration preserves all data | Automated test |

---

## Part 10: Open Questions (Resolved)

| Question | Decision | Rationale |
|----------|----------|-----------|
| Multi-AI support? | Defer to v5.1 | Focus on Claude Code first |
| Backward compat duration? | 6 months | Balance support vs burden |
| MCP integration? | Defer to v5.1 | Not needed for core |
| Team features? | Defer to v5.1 | Needs enterprise validation |

---

## Appendix A: Hook Safety & Constraints

### A.1 Safe-Fail Rules

1. **Never block.** Exit non-zero → warn and continue.
2. **Timeout 2 seconds.** Kill and warn if exceeded.
3. **No side effects on failure.** Failed hook must not leave partial state.
4. **Idempotent.** Running twice = same result.
5. **Respect profile.** `minimal` profile disables all hooks.

### A.2 Hook Constraints

| Allowed | Forbidden |
|---------|-----------|
| Read context files | Network requests |
| Read git status | Heavy git operations (log, blame) |
| Simple computation | File writes (except designated cache) |
| Print to stdout | Interactive prompts |

### A.3 Debouncing (PostToolUse only)

- **Delay:** 5 seconds after last Edit/Write
- **Batch:** Multiple edits = single hook invocation
- **Skip:** Don't run if same file edited within window

---

## Appendix B: Verification & Deduplication

### B.1 Verification Step

Every audit finding MUST include:

```json
{
  "verified": {
    "vulnPatternSearched": "dangerouslySetInnerHTML",
    "mitigationPatternSearched": "DOMPurify|sanitize|escape",
    "mitigationFound": false,
    "verificationNotes": "No sanitization in component"
  }
}
```

### B.2 Verification Process

1. Search for vulnerability pattern in codebase
2. Search for mitigation pattern in same file/module
3. If mitigation found: verify it covers the vulnerability
4. Only flag if: mitigation missing OR doesn't cover
5. Skip test files unless explicitly reviewing tests

### B.3 Deduplication Rules

**Duplicates:** Same file AND same line number.

**Tie-break rules (keep the one with):**
1. Highest severity
2. Most specific description
3. Most actionable remediation

**Merge:**
- Combine evidence from all duplicate findings
- Keep all unique remediation suggestions

---

## Appendix C: Feature Comparison

| Feature | v4.2.1 | v5.0 |
|---------|--------|------|
| Core Files | 5 | 4 |
| Commands | 22 | 8 skills |
| Code Review | 9 commands | 1 + 7 agents |
| Scripts | 8 files | 2 files |
| Templates | 12 | 5 |
| Config | 40+ options | 3 profiles |
| Execution | Sequential | Parallel |
| Automation | Manual | Hooks |
| Interfaces | Markdown | JSON schemas |

---

## Appendix D: Cache Invalidation

### D.1 Codebase Context Cache

**File:** `.claude/cache/codebase-context.json`

**Stale when:**
- `git rev-parse HEAD` differs from cached commit
- Any file in `git status --porcelain` output
- Cache file older than 24 hours

**Invalidation check:**
```bash
CACHED_COMMIT=$(jq -r '.commit' .claude/cache/codebase-context.json)
CURRENT_COMMIT=$(git rev-parse HEAD)
[ "$CACHED_COMMIT" != "$CURRENT_COMMIT" ] && echo "stale"
```

### D.2 Incremental Mode File Selection

For `--incremental` code review:

1. Get changed files: `git diff --name-only HEAD~1`
2. Filter to scannable types: `*.ts, *.tsx, *.js, *.jsx, *.py, etc.`
3. Scan only those files
4. Merge with cached findings for unchanged files

---

*End of v5.0 Planning Document*
