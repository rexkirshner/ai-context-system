# AI Context System v5.0 - First Principles Redesign

**Document Version:** 2.0
**Created:** 2026-01-12
**Last Updated:** 2026-01-12
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
| `/init` | Empty or existing project | context/ with auto-detected values | Config created, <3 placeholders remaining |
| `/review` | Existing context/ | Health score + resume point | Score is 0-100, resume point is actionable |
| `/save-full` | Work session | Session entry in SESSIONS.md | Entry follows schema, Quick Reference updated |

**Gate:** Phase 2+ cannot begin until MVP loop passes all verification criteria.

---

## Part 1: Core Principles

These principles govern all v5.0 development decisions. When in doubt, refer here.

### 1.1 Quality Over Speed

- **No time constraints.** We ship when it's right, not when it's scheduled.
- **No bandaids.** Every fix addresses root cause. If we don't understand why something broke, we don't ship.
- **No quick fixes.** Temporary solutions become permanent debt. Take the time to do it properly.

### 1.2 Maintainability First

- **Single source of truth.** Every piece of data lives in exactly one place.
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

### 2.3 Reduction Summary

| Area | v4.2.1 | v5.0 | Reduction |
|------|--------|------|-----------|
| Commands | 22 | 8 skills | 64% fewer |
| Scripts | 8 (~4,400 lines) | 2 (~600 lines) | 86% less code |
| Templates | 12 | 5 | 58% fewer |
| Config options | 40+ | 3 profiles | 92% simpler |

### 2.4 What's Explicitly Removed

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
│                                                                 │
│  SKILLS (Model-Invoked, Declarative)                           │
│  ├── /init         Initialize project with auto-detection      │
│  ├── /save         Quick session update (STATUS.md)            │
│  ├── /save-full    Comprehensive save (SESSIONS.md entry)      │
│  ├── /review       Start-of-session health check               │
│  ├── /validate     Deep validation and staleness check         │
│  ├── /export       Create handoff package                      │
│  ├── /update       Update ACS version                          │
│  └── /code-review  Launch code review agents                   │
│                                                                 │
│  AGENTS (Task-Delegated, Parallel, Isolated Context)           │
│  ├── code-reviewer         Orchestrator (launches others)      │
│  ├── codebase-scanner      Pre-compute shared context          │
│  ├── security-reviewer     OWASP, auth, injection              │
│  ├── performance-reviewer  CWV, bundle, runtime                │
│  ├── accessibility-reviewer WCAG 2.1 AA                        │
│  ├── type-safety-reviewer  TypeScript strictness               │
│  ├── test-coverage-reviewer Test quality                       │
│  └── synthesis-agent       Deduplicate and merge findings      │
│                                                                 │
│  HOOKS (Event-Driven, Safe-Fail, Debounced)                    │
│  ├── SessionStart   Show health summary (best-effort)          │
│  └── PostToolUse    Track modifications (debounced 5s)         │
│                                                                 │
│  CONTEXT FILES (Externalized AI Memory)                        │
│  ├── CONTEXT.md     Orientation (stable)                       │
│  ├── STATUS.md      Current state (dynamic)                    │
│  ├── DECISIONS.md   Decision log (append-only)                 │
│  └── SESSIONS.md    Session history (append-only)              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Directory Structure

```
project/
├── CLAUDE.md                     # Entry point (auto-loaded by Claude Code)
│
├── context/                      # Core context files
│   ├── CONTEXT.md
│   ├── STATUS.md
│   ├── DECISIONS.md
│   ├── SESSIONS.md
│   ├── .context-config.json
│   └── .todo-state.json          # Persisted TodoWrite state
│
├── .claude/
│   ├── skills/                   # ACS skills
│   │   ├── init/
│   │   │   └── SKILL.md
│   │   ├── save/
│   │   │   └── SKILL.md
│   │   ├── save-full/
│   │   │   └── SKILL.md
│   │   ├── review/
│   │   │   └── SKILL.md
│   │   └── [others]/
│   │
│   ├── agents/                   # Code review agents
│   │   ├── code-reviewer.md
│   │   ├── codebase-scanner.md
│   │   ├── security-reviewer.md
│   │   └── [specialist agents]/
│   │
│   ├── hooks/                    # Automation (safe-fail)
│   │   └── session-start.sh
│   │
│   └── settings.json             # Hook configuration
│
├── docs/
│   └── audits/                   # Code review reports
│       └── INDEX.md
│
└── artifacts/
    └── exports/                  # Handoff packages
```

### 3.3 Execution Flow

**v4.x (Sequential, Manual):**
```
User → Slash Command → Claude reads markdown → Calls bash scripts → Output in conversation
```

**v5.0 (Parallel, Automated):**
```
User → Skill auto-invoked → Claude follows instructions
                         → Delegates to agents (parallel)
                         → Hooks fire automatically
                         → Structured output (JSON schemas)
```

---

## Part 4: Contracts & Schemas

All component interfaces are defined by JSON schemas. This enables reliable AI-to-AI handoffs and automated validation.

### 4.1 Context Health Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "ContextHealth",
  "description": "Health check output from /review skill",
  "type": "object",
  "required": ["score", "breakdown", "nextAction"],
  "properties": {
    "score": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100,
      "description": "Overall health score"
    },
    "breakdown": {
      "type": "object",
      "properties": {
        "statusFreshness": { "type": "integer", "minimum": -20, "maximum": 20 },
        "sessionsFreshness": { "type": "integer", "minimum": -20, "maximum": 20 },
        "decisionsFreshness": { "type": "integer", "minimum": -20, "maximum": 20 },
        "contextFreshness": { "type": "integer", "minimum": -20, "maximum": 20 },
        "quickReferenceSync": { "type": "integer", "minimum": -20, "maximum": 20 },
        "gitState": { "type": "integer", "minimum": -20, "maximum": 20 },
        "crossReferences": { "type": "integer", "minimum": -20, "maximum": 20 }
      }
    },
    "warnings": {
      "type": "array",
      "items": { "type": "string" }
    },
    "nextAction": {
      "type": "string",
      "description": "Single most important next action"
    },
    "resumePoint": {
      "type": "string",
      "description": "Where to continue work"
    }
  }
}
```

### 4.2 Audit Finding Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "AuditFinding",
  "description": "Single finding from a code review agent",
  "type": "object",
  "required": ["id", "severity", "category", "title", "location", "verified"],
  "properties": {
    "id": {
      "type": "string",
      "pattern": "^[A-Z]+-[0-9]+$",
      "description": "Unique ID like SEC-001, PERF-003"
    },
    "severity": {
      "type": "string",
      "enum": ["critical", "high", "medium", "low", "info"]
    },
    "category": {
      "type": "string",
      "enum": ["security", "performance", "accessibility", "typescript", "testing", "other"]
    },
    "title": {
      "type": "string",
      "maxLength": 100
    },
    "description": {
      "type": "string"
    },
    "location": {
      "type": "object",
      "properties": {
        "file": { "type": "string" },
        "line": { "type": "integer" },
        "snippet": { "type": "string" }
      },
      "required": ["file"]
    },
    "verified": {
      "type": "object",
      "description": "Verification step results",
      "properties": {
        "vulnPatternSearched": { "type": "string" },
        "mitigationPatternSearched": { "type": "string" },
        "mitigationFound": { "type": "boolean" },
        "verificationNotes": { "type": "string" }
      },
      "required": ["vulnPatternSearched", "mitigationPatternSearched", "mitigationFound"]
    },
    "remediation": {
      "type": "string",
      "description": "How to fix"
    },
    "effort": {
      "type": "string",
      "enum": ["trivial", "small", "medium", "large"]
    }
  }
}
```

### 4.3 Audit Report Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "AuditReport",
  "description": "Complete audit report from code-reviewer orchestrator",
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
        "duration": { "type": "string" }
      }
    },
    "summary": {
      "type": "object",
      "properties": {
        "grade": { "type": "string", "pattern": "^[A-F][+-]?$" },
        "criticalCount": { "type": "integer" },
        "highCount": { "type": "integer" },
        "mediumCount": { "type": "integer" },
        "lowCount": { "type": "integer" },
        "topIssues": {
          "type": "array",
          "maxItems": 3,
          "items": { "type": "string" }
        }
      }
    },
    "findings": {
      "type": "array",
      "items": { "$ref": "#/definitions/AuditFinding" }
    },
    "positives": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Things done well"
    }
  }
}
```

### 4.4 Session Entry Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "SessionEntry",
  "description": "Single session entry for SESSIONS.md",
  "type": "object",
  "required": ["number", "date", "tldr", "focus"],
  "properties": {
    "number": { "type": "integer", "minimum": 1 },
    "date": { "type": "string", "format": "date" },
    "focus": { "type": "string", "maxLength": 100 },
    "tldr": {
      "type": "string",
      "minLength": 50,
      "maxLength": 300,
      "description": "2-3 sentence summary (mandatory)"
    },
    "accomplishments": {
      "type": "array",
      "items": { "type": "string" }
    },
    "decisions": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "id": { "type": "string" },
          "summary": { "type": "string" }
        }
      }
    },
    "filesChanged": {
      "type": "array",
      "items": { "type": "string" }
    },
    "mentalModels": {
      "type": "string",
      "description": "Current understanding and insights"
    },
    "nextSteps": {
      "type": "array",
      "items": { "type": "string" }
    },
    "gitOperations": {
      "type": "object",
      "properties": {
        "commits": { "type": "integer" },
        "pushed": { "type": "boolean" },
        "branch": { "type": "string" }
      }
    }
  }
}
```

### 4.5 Handoff Package Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "HandoffPackage",
  "description": "Export for AI-to-AI or developer handoff",
  "type": "object",
  "required": ["metadata", "summary", "contextFiles", "nextSteps"],
  "properties": {
    "metadata": {
      "type": "object",
      "properties": {
        "exportedAt": { "type": "string", "format": "date-time" },
        "acsVersion": { "type": "string" },
        "projectName": { "type": "string" },
        "exportedBy": { "type": "string" }
      }
    },
    "summary": {
      "type": "object",
      "properties": {
        "projectState": { "type": "string", "maxLength": 500 },
        "criticalDecisions": { "type": "array", "items": { "type": "string" } },
        "activeBlockers": { "type": "array", "items": { "type": "string" } }
      }
    },
    "contextFiles": {
      "type": "object",
      "properties": {
        "context": { "type": "string" },
        "status": { "type": "string" },
        "decisions": { "type": "string" },
        "recentSessions": { "type": "array", "items": { "type": "string" } }
      }
    },
    "nextSteps": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Prioritized list of what to do next"
    }
  }
}
```

---

## Part 5: Implementation Phases

Each phase has explicit inputs, outputs, and a Definition of Done with objectively verifiable checkpoints.

### Phase 0: Foundation

**Purpose:** Set up infrastructure before building any features.

**Inputs:** None (starting fresh)

**Outputs:**
- [ ] JSON schemas in `.claude/schemas/`
- [ ] Fixture repos for testing (3 types: Next.js app, Python CLI, monorepo)
- [ ] Golden file tests for expected outputs
- [ ] Quality gate script that runs all verifications

**Definition of Done:**
1. ✅ All 5 JSON schemas from Part 4 exist and are valid JSON Schema draft-07
2. ✅ 3 fixture repos created in `test/fixtures/` with realistic project structures
3. ✅ `test/golden/` contains expected outputs for Quick Reference, session entry, audit report
4. ✅ `scripts/verify-phase.sh 0` passes with exit code 0

**Verification Commands:**
```bash
# Schema validation
npx ajv validate -s .claude/schemas/context-health.json -d /dev/null

# Fixture repos exist
ls test/fixtures/nextjs-app test/fixtures/python-cli test/fixtures/monorepo

# Golden files exist
ls test/golden/quick-reference.md test/golden/session-entry.md test/golden/audit-report.json

# Phase gate passes
./scripts/verify-phase.sh 0
```

---

### Phase 1: MVP Loop

**Purpose:** Prove the redesign works with core workflow.

**Inputs:** Phase 0 complete

**Outputs:**
- [ ] `/init` skill with auto-detection
- [ ] `/review` skill with health score
- [ ] `/save-full` skill with session entry

**Definition of Done:**
1. ✅ `/init` on fixture repo produces `context/` with <3 unfilled placeholders
2. ✅ `/review` outputs valid `ContextHealth` JSON with score 0-100
3. ✅ `/save-full` produces session entry matching `SessionEntry` schema
4. ✅ Quick Reference in STATUS.md matches golden file format
5. ✅ End-to-end test: init → work → save-full → review shows health score ≥80

**Verification Commands:**
```bash
# Test /init auto-detection
cd test/fixtures/nextjs-app
claude --skill init
grep -c "\[FILL:" context/CONTEXT.md  # Must be <3

# Test /review health score
claude --skill review --output-json | jq '.score'  # Must be 0-100

# Test /save-full schema compliance
claude --skill save-full --output-json > /tmp/session.json
npx ajv validate -s .claude/schemas/session-entry.json -d /tmp/session.json

# Phase gate
./scripts/verify-phase.sh 1
```

**Gate:** Phase 2 cannot begin until all Phase 1 checkpoints pass.

---

### Phase 2: Additional Skills

**Purpose:** Complete the skill set with remaining core functionality.

**Inputs:** Phase 1 complete

**Outputs:**
- [ ] `/save` skill (quick update, STATUS.md only)
- [ ] `/validate` skill (deep health check)
- [ ] `/export` skill (handoff package)
- [ ] `/update` skill (ACS version update)

**Definition of Done:**
1. ✅ `/save` updates STATUS.md Quick Reference without touching SESSIONS.md
2. ✅ `/validate` checks cross-references and reports broken links
3. ✅ `/export` produces valid `HandoffPackage` JSON
4. ✅ `/update` creates backup, downloads new version, produces MIGRATION_SUMMARY.md
5. ✅ All skills have matching golden file tests

**Verification Commands:**
```bash
# /save only touches STATUS.md
claude --skill save
git diff --name-only  # Should only show context/STATUS.md

# /validate catches broken references
echo "See D999" >> context/STATUS.md  # Invalid decision reference
claude --skill validate | grep -q "D999 not found"

# /export schema compliance
claude --skill export --output-json > /tmp/handoff.json
npx ajv validate -s .claude/schemas/handoff-package.json -d /tmp/handoff.json

# Phase gate
./scripts/verify-phase.sh 2
```

---

### Phase 3: Code Review Agents

**Purpose:** Build parallel code review system.

**Inputs:** Phase 2 complete

**Outputs:**
- [ ] `codebase-scanner.md` agent (shared context)
- [ ] `security-reviewer.md` agent (prototype specialist)
- [ ] `code-reviewer.md` orchestrator
- [ ] `synthesis-agent.md` (deduplication)
- [ ] Verification step enforcement

**Definition of Done:**
1. ✅ `codebase-scanner` produces `.claude/cache/codebase-context.json`
2. ✅ `security-reviewer` outputs findings matching `AuditFinding` schema
3. ✅ Every finding includes `verified` object with pattern searches
4. ✅ Orchestrator launches scanner first, then specialists in parallel
5. ✅ Synthesis agent merges duplicate findings (same file:line = one finding)
6. ✅ Final report matches `AuditReport` schema

**Verification Commands:**
```bash
# Codebase scanner produces cache
claude --agent codebase-scanner
test -f .claude/cache/codebase-context.json

# Security reviewer findings are verified
claude --agent security-reviewer --output-json | jq '.findings[0].verified'
# Must have vulnPatternSearched, mitigationPatternSearched, mitigationFound

# Orchestrator runs parallel
time claude --skill code-review  # Should be faster than sequential

# No duplicate findings
claude --skill code-review --output-json | jq '[.findings[].location | "\(.file):\(.line)"] | unique | length == length'

# Phase gate
./scripts/verify-phase.sh 3
```

---

### Phase 4: Remaining Agents

**Purpose:** Complete specialist agent set.

**Inputs:** Phase 3 complete

**Outputs:**
- [ ] `performance-reviewer.md`
- [ ] `accessibility-reviewer.md`
- [ ] `type-safety-reviewer.md`
- [ ] `test-coverage-reviewer.md`
- [ ] `audit-compare.md` (baseline comparison)

**Definition of Done:**
1. ✅ Each specialist produces findings matching `AuditFinding` schema
2. ✅ Each specialist includes verification step
3. ✅ `audit-compare` reads previous report and shows trend
4. ✅ `/code-review --quick` runs in <3 minutes (critical issues only)
5. ✅ `/code-review --incremental` only scans changed files

**Verification Commands:**
```bash
# All specialists produce valid findings
for agent in performance accessibility type-safety test-coverage; do
  claude --agent ${agent}-reviewer --output-json | \
    npx ajv validate -s .claude/schemas/audit-finding.json -d -
done

# Quick mode is fast
time timeout 180 claude --skill code-review --quick

# Incremental only scans changed files
git diff --name-only > /tmp/changed.txt
claude --skill code-review --incremental --output-json | \
  jq '.metadata.filesScanned' | \
  xargs -I {} test {} -le $(wc -l < /tmp/changed.txt)

# Phase gate
./scripts/verify-phase.sh 4
```

---

### Phase 5: Hooks (Safe-Fail)

**Purpose:** Add automation without introducing friction.

**Inputs:** Phase 4 complete

**Outputs:**
- [ ] `session-start.sh` hook (health summary)
- [ ] Hook configuration in `.claude/settings.json`
- [ ] "minimal" profile that disables all hooks

**Definition of Done:**
1. ✅ SessionStart hook runs on session start and prints health summary
2. ✅ Hook failure (exit code 1) prints warning but doesn't block
3. ✅ Hook timeout (>2s) is killed and warns
4. ✅ `profile: minimal` in config disables all hooks
5. ✅ Hooks are idempotent (running twice produces same result)

**Verification Commands:**
```bash
# Hook runs and produces output
claude --test-hook session-start | grep -q "Health:"

# Hook failure doesn't block
echo "exit 1" > .claude/hooks/session-start.sh
claude --test-hook session-start  # Should warn but not fail

# Hook timeout is handled
echo "sleep 10" > .claude/hooks/session-start.sh
timeout 5 claude --test-hook session-start  # Should timeout gracefully

# Minimal profile disables hooks
echo '{"profile": "minimal"}' > context/.context-config.json
claude --test-hook session-start  # Should skip

# Phase gate
./scripts/verify-phase.sh 5
```

---

### Phase 6: Migration & Rollback

**Purpose:** Safe upgrade path from v4.x with rollback capability.

**Inputs:** Phase 5 complete

**Outputs:**
- [ ] `/update` skill with full migration logic
- [ ] `MIGRATION_SUMMARY.md` generation
- [ ] One-command rollback
- [ ] Backward-compatible aliases for old commands

**Definition of Done:**
1. ✅ `/update` creates timestamped backup before any changes
2. ✅ `MIGRATION_SUMMARY.md` lists: what changed, backup location, rollback command
3. ✅ `claude --rollback` restores from backup
4. ✅ Old command names work as aliases (with deprecation warning)
5. ✅ v4.x config auto-migrates to v5.0 profile

**Verification Commands:**
```bash
# Backup created
claude --skill update
test -d .claude-backup-*

# Migration summary exists and is complete
grep -q "Backup location:" MIGRATION_SUMMARY.md
grep -q "Rollback command:" MIGRATION_SUMMARY.md

# Rollback works
claude --rollback
test -f .claude/commands/save.md  # Old v4 structure restored

# Aliases work with warning
claude --skill init-context 2>&1 | grep -q "deprecated"

# Phase gate
./scripts/verify-phase.sh 6
```

---

### Phase 7: Documentation & Polish

**Purpose:** Production-ready documentation and final polish.

**Inputs:** Phase 6 complete

**Outputs:**
- [ ] Updated acs-docs website
- [ ] CHANGELOG.md entry for v5.0
- [ ] README.md updates
- [ ] Troubleshooting guide

**Definition of Done:**
1. ✅ acs-docs builds without errors
2. ✅ All commands documented with examples
3. ✅ Migration guide complete
4. ✅ CHANGELOG.md has comprehensive v5.0 entry
5. ✅ No broken links in documentation

**Verification Commands:**
```bash
# Docs build
cd acs-docs && npm run build

# All skills documented
for skill in init save save-full review validate export update code-review; do
  test -f docs/skills/${skill}.md
done

# No broken links
npx linkinator docs/ --recurse

# Phase gate
./scripts/verify-phase.sh 7
```

---

### Phase 8: Release

**Purpose:** Ship v5.0.0.

**Inputs:** Phase 7 complete, all gates passed

**Outputs:**
- [ ] Tagged release v5.0.0
- [ ] GitHub release with notes
- [ ] Updated install.sh

**Definition of Done:**
1. ✅ All phase gates (0-7) pass
2. ✅ Version bumped to 5.0.0 in VERSION file
3. ✅ Git tag v5.0.0 created and pushed
4. ✅ GitHub release published
5. ✅ `curl install.sh | bash` installs v5.0.0

**Verification Commands:**
```bash
# All phases pass
for i in $(seq 0 7); do
  ./scripts/verify-phase.sh $i || exit 1
done

# Version correct
grep -q "5.0.0" VERSION

# Install works
curl -sL https://raw.githubusercontent.com/.../install.sh | bash
claude --version | grep -q "5.0.0"
```

---

## Part 6: Quality Gates & Testing

### 6.1 Test Types

| Test Type | Purpose | Location | When Run |
|-----------|---------|----------|----------|
| Schema validation | Verify JSON outputs | `test/schemas/` | Every phase |
| Golden file tests | Verify output format | `test/golden/` | Every phase |
| Fixture repo tests | Integration testing | `test/fixtures/` | Phase 1+ |
| Hook simulation | Test hook behavior | `test/hooks/` | Phase 5 |
| Migration tests | Test upgrade path | `test/migration/` | Phase 6 |

### 6.2 Fixture Repositories

Three realistic project structures for testing:

**`test/fixtures/nextjs-app/`**
- Next.js 14 with TypeScript
- Prisma database
- Auth.js authentication
- Tailwind CSS
- Tests: 10-15 files spanning multiple patterns

**`test/fixtures/python-cli/`**
- Python CLI tool
- Click framework
- pytest tests
- pyproject.toml configuration

**`test/fixtures/monorepo/`**
- Turborepo structure
- 2 apps, 3 packages
- Shared configuration
- Cross-package dependencies

### 6.3 Golden Files

Expected outputs for comparison:

```
test/golden/
├── quick-reference.md          # STATUS.md Quick Reference format
├── session-entry.md            # SESSIONS.md entry format
├── audit-report.json           # Full audit report
├── audit-finding.json          # Single finding
├── context-health.json         # Health check output
└── handoff-package.json        # Export package
```

### 6.4 Phase Gate Script

```bash
#!/bin/bash
# scripts/verify-phase.sh
# Usage: ./scripts/verify-phase.sh <phase-number>

PHASE=$1

case $PHASE in
  0) # Foundation
    npx ajv validate -s .claude/schemas/*.json
    test -d test/fixtures/nextjs-app
    test -d test/fixtures/python-cli
    test -d test/fixtures/monorepo
    test -d test/golden
    ;;
  1) # MVP Loop
    # Run init, check placeholders
    # Run review, validate health schema
    # Run save-full, validate session schema
    ;;
  # ... phases 2-7
esac

echo "Phase $PHASE: ✅ PASSED"
```

---

## Part 7: Migration & Rollback

### 7.1 Upgrade Flow

```
v4.x Project
     │
     ▼
┌────────────────────────────────────┐
│  1. Create timestamped backup      │
│     .claude-backup-YYYYMMDD-HHMMSS │
└────────────────────────────────────┘
     │
     ▼
┌────────────────────────────────────┐
│  2. Download v5.0 components       │
│     - Skills                       │
│     - Agents                       │
│     - Hooks                        │
│     - Schemas                      │
└────────────────────────────────────┘
     │
     ▼
┌────────────────────────────────────┐
│  3. Migrate configuration          │
│     - 40+ options → profile        │
│     - Preserve custom settings     │
└────────────────────────────────────┘
     │
     ▼
┌────────────────────────────────────┐
│  4. Generate MIGRATION_SUMMARY.md  │
│     - What changed                 │
│     - Backup location              │
│     - Rollback command             │
└────────────────────────────────────┘
     │
     ▼
v5.0 Project
```

### 7.2 MIGRATION_SUMMARY.md Template

```markdown
# Migration Summary: v4.x → v5.0

**Migrated:** 2026-01-15 14:30:00
**Previous Version:** 4.2.1
**New Version:** 5.0.0

## What Changed

### Removed
- 14 slash commands (replaced by 8 skills)
- 6 bash scripts (replaced by skills/agents)
- context-feedback.md (content in SESSIONS.md)

### Added
- .claude/skills/ (8 skills)
- .claude/agents/ (8 agents)
- .claude/schemas/ (5 JSON schemas)
- .claude/hooks/ (automation)

### Modified
- .context-config.json (simplified to profile)
- STATUS.md (enhanced Quick Reference)

## Backup Location

All original files backed up to:
```
.claude-backup-20260115-143000/
├── .claude/commands/     # All 22 commands
├── scripts/              # All 8 scripts
├── context/              # Config backup
└── VERSION               # Previous version
```

## Rollback Command

To revert to v4.x:
```bash
claude --rollback
# Or manually:
rm -rf .claude && mv .claude-backup-20260115-143000/.claude .
```

## Deprecated Aliases

These old commands still work (with warning) for 6 months:
- /init-context → /init
- /save-context → /save
- /review-context → /review
- /validate-context → /validate
- /export-context → /export
- /update-context-system → /update
```

### 7.3 Breaking Changes

| Change | Impact | Migration |
|--------|--------|-----------|
| Commands → Skills | Old names deprecated | Aliases for 6 months |
| Scripts removed | Can't call directly | Use skills/agents |
| Config simplified | Old options ignored | Auto-migrate to profile |
| context-feedback.md removed | File deleted | Content preserved in SESSIONS.md |
| v3.x support dropped | Can't upgrade from v3 | Must upgrade to v4 first |

---

## Part 8: Success Metrics

### 8.1 Quantitative

| Metric | v4.x Baseline | v5.0 Target | Verification |
|--------|---------------|-------------|--------------|
| Commands | 22 | 8 | `ls .claude/skills | wc -l` |
| Script lines | ~4,400 | ~600 | `wc -l scripts/*.sh` |
| Templates | 12 | 5 | `ls templates | wc -l` |
| Config options | 40+ | 3 profiles | Schema check |
| Code review time | Sequential | 3-5x faster | Timed test |
| False positive rate | 35% | <15% | Manual audit of findings |

### 8.2 Qualitative

| Goal | Verification |
|------|--------------|
| New users productive in <5 min | User testing with fresh project |
| Daily workflow uses ≤3 commands | Usage telemetry (opt-in) |
| Code reviews find real issues | Manual review of findings |
| Architecture is maintainable | New contributor can add skill in <1 hour |
| System is upgradable | Migration test passes |

---

## Part 9: Open Questions (Resolved)

| Question | Decision | Rationale |
|----------|----------|-----------|
| Multi-AI support? | Defer to v5.1 | Focus on Claude Code excellence first |
| Backward compat duration? | 6 months | Balance support burden vs user needs |
| MCP integration? | Defer to v5.1 | Not needed for core functionality |
| Team features? | Defer to v5.1 | Complexity, needs enterprise validation |
| Test approach? | Golden files + fixtures | Matches new architecture |

---

## Appendix A: Hook Safety Requirements

### A.1 Safe-Fail Rules

1. **Never block.** If hook exits non-zero, warn and continue.
2. **Timeout after 2 seconds.** Kill and warn if exceeded.
3. **No side effects on failure.** Failed hook must not leave partial state.
4. **Idempotent.** Running twice produces same result.
5. **Respect profile.** `minimal` profile disables all hooks.

### A.2 Debouncing

PostToolUse hooks are debounced:
- **Delay:** 5 seconds after last Edit/Write
- **Batch:** Multiple edits = single hook invocation
- **Skip:** Don't run if same file edited within window

### A.3 Hook Template

```bash
#!/bin/bash
# .claude/hooks/session-start.sh
# Safe-fail hook for session start

set -o pipefail

# Timeout protection (2s max)
timeout 2 bash -c '
  # Your hook logic here
  echo "Health: checking..."
' || {
  echo "⚠️ Hook timed out or failed (continuing anyway)"
  exit 0  # Always exit 0 to not block
}
```

---

## Appendix B: Verification Step Enforcement

All code review findings MUST include verification:

```json
{
  "verified": {
    "vulnPatternSearched": "dangerouslySetInnerHTML",
    "mitigationPatternSearched": "DOMPurify|sanitize|escape",
    "mitigationFound": false,
    "verificationNotes": "No sanitization found in component"
  }
}
```

### Verification Process

1. **Search for vulnerability pattern** in codebase
2. **Search for mitigation pattern** in same file/module
3. **If mitigation found:** Verify it covers the vulnerability
4. **Only flag if:** Mitigation missing OR doesn't cover vulnerability
5. **Skip test files:** Unless explicitly reviewing tests

### Deduplication Rules

Findings are considered duplicates if:
- Same file AND same line number
- Same vulnerability pattern AND same file

Synthesis agent merges duplicates, keeping:
- Highest severity
- Most detailed description
- All unique remediation suggestions

---

## Appendix C: Feature Comparison

| Feature | v4.2.1 | v5.0 |
|---------|--------|------|
| **Core Files** | 5 | 4 |
| **Commands** | 22 slash commands | 8 skills |
| **Code Review** | 9 manual commands | 1 orchestrator + 7 agents |
| **Scripts** | 8 bash files | 2 bash + hooks |
| **Templates** | 12 files | 5 files |
| **Configuration** | 40+ options | 3 profiles |
| **Execution** | Sequential | Parallel |
| **Automation** | Manual | Hooks (safe-fail) |
| **Interfaces** | Freeform markdown | JSON schemas |
| **Testing** | 42 bash tests | Golden files + fixtures |

---

*End of v5.0 Planning Document*
