# AI Context System v6.0 Proposal

## The Radical Simplification

**Date:** January 2025
**Status:** Proposal (Updated with Agent-Native Feedback)
**Author:** Rex Kirshner + Claude (Opus 4.5)

---

## Executive Summary

After extensive development of the AI Context System (currently v5.2.1), we're proposing a fundamental pivot: strip the system down to its essential value and eliminate everything else.

**Current state:** 22+ commands, 14 agents, 150KB of shell scripts, elaborate session logging, complex validation systems.

**Proposed state:** 2-3 core files, 2 commands, no in-repo script framework, minimal overhead.

**Key insight from feedback:** Don't just make it "slimmer docs" — make it **agent-native**. The files should act like a tiny, predictable API that any agent can parse and act on reliably.

The goal is to deliver 80% of the value with 5% of the complexity.

---

## Part 1: What We Built

### Current System Overview (v5.x)

The AI Context System grew into a comprehensive toolkit:

**File Structure:**
```
project/
├── .claude/
│   ├── skills/          # 7 modular skills
│   ├── agents/          # 14 specialized review agents
│   ├── commands/        # 22 slash commands
│   ├── schemas/         # JSON validation schemas
│   ├── hooks/           # Session automation
│   └── docs/            # Comprehensive guides
├── scripts/
│   ├── common-functions.sh    # 150KB of utilities
│   ├── save-full-helper.sh
│   ├── validate-context.sh
│   └── ... (15+ scripts)
├── templates/           # 20+ template files
├── CLAUDE.md
└── context/
    ├── .context-config.json
    ├── CONTEXT.md       # Project orientation
    ├── STATUS.md        # Current state
    ├── DECISIONS.md     # Decision log
    └── SESSIONS.md      # Session history
```

**Commands:**
- `/init-context`, `/migrate-context` - Setup
- `/save`, `/save-full` - Maintenance (2-3 min vs 10-15 min)
- `/review-context` - Session start verification
- `/code-review` + 8 specialized variants - AI peer review
- `/export-context`, `/validate-context` - Collaboration
- `/update-context-system`, `/update-templates` - Maintenance

**Agents:**
- security-reviewer, performance-reviewer, accessibility-reviewer
- database-reviewer, infrastructure-reviewer, seo-reviewer
- test-coverage-reviewer, type-safety-reviewer
- code-reviewer (main), codebase-scanner, cost-optimizer
- synthesis-agent, library-adoption-reviewer, audit-compare

### The Original Vision

The system aimed to solve four problems:

1. **Session Continuity** - Never lose context between AI sessions
2. **Externalized AI Context** - Make AI reasoning visible to humans
3. **Human-AI Collaboration** - Full visibility into AI thinking
4. **AI-to-AI Collaboration** - Seamless handoffs between agents

---

## Part 2: What We Learned

### The Hard Truths

After honest evaluation, several assumptions didn't hold up:

#### 1. "Externalizing AI Reasoning" Is Mostly Marketing

Claude doesn't have persistent mental models. Each session starts blank. When the system "captures AI mental models," it's really just generating documentation. The framing sounds novel, but it's fundamentally just "write good docs."

**What's actually happening:** Text goes into files. Future Claude sessions read those files. That's it. No special "loading into Claude's mind."

#### 2. Session Logging Has Diminishing Returns

SESSIONS.md captures play-by-play of each session. But:
- Git already captures what changed and when
- Commit messages explain why (if written well)
- Important decisions should be in DECISIONS.md anyway
- Session #47 from three weeks ago is rarely relevant

The maintenance cost (updating every session) exceeds the marginal value over git history.

#### 3. Complexity Creates Friction

- `/save-full` takes 10-15 minutes - so users skip it
- 22 commands is overwhelming - users don't know which to use
- 150KB of shell scripts is a maintenance burden
- The elaborate structure discourages adoption

**The irony:** A system designed to reduce friction added friction.

#### 4. Context Windows Are Large Now

Claude can read the codebase directly. The elaborate context packaging may have made more sense when context windows were smaller. Now? Just point Claude at the relevant files.

#### 5. Most of the Infrastructure Is Unused

14 review agents, but most projects need 2-3. Elaborate validation, but a quick skim of STATUS.md tells you if it's stale. Export systems, but copy-paste works fine.

We built for every edge case. Most users need the common case.

### What Actually Works

Despite the overengineering, some things proved genuinely valuable:

#### 1. DECISIONS.md - The Clear Winner

This captures something nothing else does: **why** choices were made.

- "We chose SQLite over Postgres because this is local-only"
- "We went with REST instead of GraphQL because the team knows it"
- "We're not using TypeScript because this is a quick prototype"

Git shows what changed. Code shows what exists. Only DECISIONS.md captures the reasoning that would otherwise live in someone's head and be lost.

**Key insight:** Append-only works. You add decisions as you make them. You rarely edit old ones. Low friction, high value.

#### 2. STATUS.md - For Session Continuity

A simple snapshot of "where we are right now":
- Current focus
- Blockers
- Next steps

When you return to a project after days/weeks, this orients you in seconds. But it needs to be simple - 5 bullet points, not elaborate sections.

#### 3. Focused Review Prompts - As a Library

Having a well-crafted `/review-security` prompt saves time. You don't rewrite the checklist each time. For web projects, `/review-seo` is useful. For APIs, `/review-performance`.

**Key insight:** These are a library, not a mandatory workflow. You pull the ones relevant to your project. You don't run all 14 on every review.

#### 4. CLAUDE.md - Already Built Into Claude Code

Claude Code auto-loads CLAUDE.md at project root. This is the natural entry point. We should lean into this, not duplicate it with CONTEXT.md.

---

## Part 3: The New System

### Design Principles

1. **Minimal viable structure** - Only what's proven valuable
2. **Low friction** - If it takes more than 30 seconds, it won't get done
3. **No in-repo script framework** - No 150KB utilities; Claude handles logic
4. **Library, not framework** - Use what you need, ignore the rest
5. **Agent-native** - Files act like a predictable API, not prose
6. **Schema-first** - Structured data at the top, prose below

### Anti-Bloat Guardrails

To prevent v6 from becoming v7-bloat, we codify these rules:

1. **30-second rule:** If a feature can't be used in <30 seconds, it doesn't ship
2. **Core command cap:** Core stays at 2 commands; new commands must replace existing ones
3. **Library, not workflow:** Anything requiring orchestration/multi-step becomes an optional prompt, not core
4. **Verbosity limits:**
   - STATUS.md: ≤12 total bullets
   - DECISIONS.md: ≤6 lines per entry
   - CLAUDE.md: Agent Contract + project notes only, no long descriptions

### File Structure

```
project/
├── CLAUDE.md                    # Entry point (already auto-loaded)
└── context/
    ├── DECISIONS.md             # Append-only decision log
    └── STATUS.md                # Current state (structured handoff)
```

That's it. Three files.

**Optional additions for larger projects:**
```
└── context/
    ├── ARCHITECTURE.md          # If system design is complex
    └── decisions/               # If DECISIONS.md gets huge (100+ entries)
        ├── 2024-q1.md
        └── 2024-q2.md
```

### CLAUDE.md (Agent Contract)

The key change: make CLAUDE.md explicitly **agent-operational**, not just a project overview.

```markdown
# Project Name

[One paragraph: what this is, who it's for]

## Agent Contract

| Key | Value |
|-----|-------|
| Run | `npm start` |
| Test | `npm test` |
| Lint | `npm run lint` |
| Build | `npm run build` |

**Constraints:**
- No database migrations without approval
- Don't refactor unrelated code
- Keep PRs focused (<300 lines when possible)

**Working Agreement:**
- Update STATUS.md on session end (run `/save`)
- Log non-obvious decisions to DECISIONS.md

## Context

- **Decisions:** `context/DECISIONS.md`
- **Status:** `context/STATUS.md`

## Notes

[Project-specific conventions, gotchas, or preferences]
```

This prevents "agent guesswork" — any agent can reliably answer:
- How do I run this?
- What are the rules?
- What must I not do?

### STATUS.md (Structured Handoff)

Schema-first design. Fixed key block at top for reliable parsing:

```markdown
# Status

| Key | Value |
|-----|-------|
| Last updated | 2025-01-24 |
| Objective | Implement user authentication |

## Working Set
- src/auth/*
- db/schema.prisma
- tests/auth.test.ts

## Constraints
- Auth must work offline
- No external auth providers yet

## Next Actions
- Implement password hashing
- Add session tokens
- Write auth middleware tests

## Blocked On
- (None)
```

**Key additions from feedback:**

1. **Working Set** (3-7 paths) - What files/modules we're touching right now. Massively reduces "agent wandering."

2. **Objective** - One sentence. What are we trying to accomplish?

3. **Constraints** - Active limitations for this work phase.

**Staleness rule:** If `Last updated` is older than 7 days (or since last commit), agent must refresh STATUS before proceeding. `/save` enforces this.

**Verbosity limits:**
- Working Set: 3-7 items
- Next Actions: ≤3 items
- Total bullets: ≤12

### DECISIONS.md (Actionable Format)

Minimal but structured for agent utility:

```markdown
# Decisions

Append-only log. Format: Date, Title, Why, Tradeoff, Revisit trigger.

---

## 2025-01-24: Chose SQLite over Postgres

**Why:** Local-only tool, no server component. Ships as single file.

**Tradeoff:** No concurrent writes, limited scaling.

**Revisit when:** Multi-user mode or hosted deployment.

---

## 2025-01-20: REST API, not GraphQL

**Why:** Team has REST experience. GraphQL learning curve not worth it.

**Tradeoff:** Over-fetching on some endpoints.

**Revisit when:** Mobile client needs arise (bandwidth matters more).

---
```

**Key additions from feedback:**
- **Tradeoff** - What we gave up
- **Revisit when** - Trigger condition for reconsidering

Still tiny (≤6 lines per entry), but way more actionable for future agents.

### Commands

**Core (2 commands):**

| Command | Purpose | Time |
|---------|---------|------|
| `/init-context` | Create CLAUDE.md + context/ folder with templates | 30 sec |
| `/save` | Update STATUS.md, prompt for decisions, enforce staleness | 1 min |

**Key insight:** `/save` is the only "end session" action. It includes the decision prompt. Agents shouldn't have to remember multiple commands.

**`/save` behavior:**
1. Update STATUS.md (working set, next actions, blockers)
2. Prompt: "Any non-obvious decisions made this session?"
3. If yes, append to DECISIONS.md with structured format
4. Check staleness and warn if STATUS was >7 days old

**Review Library (optional, à la carte):**

| Command | When to Use |
|---------|-------------|
| `/review-security` | Any project handling user data |
| `/review-performance` | Before launch, or when things feel slow |
| `/review-accessibility` | Web projects |
| `/review-seo` | Public web projects |

**Scope-aware reviews:** Each review prompt starts by asking the agent to limit scope to:
- The Working Set paths in STATUS.md
- The git diff / recent commits
- Or a user-provided target

This keeps reviews fast and relevant (no "audit the whole world").

### What Gets Cut

| Component | Reason for Removal |
|-----------|-------------------|
| SESSIONS.md | Git history + DECISIONS.md covers this |
| CONTEXT.md | Merged into CLAUDE.md |
| `/decision` | Merged into `/save` |
| `.claude/skills/` | Overkill - simple commands suffice |
| `.claude/agents/` | 14 agents → 4 review prompts |
| `.claude/hooks/` | Added complexity without clear value |
| `.claude/schemas/` | No validation needed for simple structure |
| `scripts/` (all 150KB) | Claude handles logic, no shell scripts needed |
| `/save-full` | Too slow - regular `/save` is enough |
| `/export-context` | Copy-paste works fine |
| `/validate-context` | Visual inspection is sufficient |
| `/migrate-context` | One-time migration script instead |
| Config files | Sensible defaults, no configuration needed |

---

## Part 4: Migration Path

### For New Users

**Option A: One-command install (convenience)**
```bash
# Pin to release tag for reproducibility
curl -sL https://github.com/rexkirshner/ai-context-system/releases/download/v6.0.0/install.sh | bash

# Initialize
/init-context
```

**Option B: Manual install (primary, recommended)**
```bash
# Clone and copy only what you need
git clone --depth 1 https://github.com/rexkirshner/ai-context-system.git
cp -r ai-context-system/.claude/commands /path/to/your/project/.claude/
rm -rf ai-context-system

# Initialize
/init-context
```

**Note on install.sh:** We say "no in-repo script framework" but ship an installer. The distinction:
- ❌ No 150KB utility libraries running during normal use
- ✅ One tiny installer for setup convenience (optional)

Creates three files. Done.

### For Existing Users (v5.x → v6.0)

#### Migration: Dry Run First

```bash
/upgrade-to-v6 --dry-run
```

Shows what will happen without making changes:

```
AI Context System: v6.0 Migration Preview (DRY RUN)

Will backup:
  context/ → context-backup-v5/
  .claude/ → .claude-backup-v5/

Will merge:
  CONTEXT.md → CLAUDE.md (Agent Contract format)

Will simplify:
  STATUS.md → Structured handoff format

Will archive:
  SESSIONS.md → context-backup-v5/

Will remove:
  scripts/

Run without --dry-run to execute.
```

#### Migration: Execute

```bash
/upgrade-to-v6
```

**The migration is idempotent** — safe to run multiple times. It detects existing backups and skips re-backup. It detects already-migrated files and skips re-migration.

**Step 1: Backup (if not already done)**
```
context/ → context-backup-v5/
.claude/ → .claude-backup-v5/
scripts/ → (deleted, no backup needed - it's in git)
```

**Step 2: Merge CONTEXT.md into CLAUDE.md**

Extract and restructure:
- Project description → One paragraph at top
- Tech stack → Agent Contract table
- Run/test/build commands → Agent Contract
- Constraints → Agent Contract Constraints section
- Project conventions → Notes section

Add if missing:
- Agent Contract with working agreement

**Step 3: Transform STATUS.md**

Convert to structured handoff format:
- Add key-value table header
- Extract or create Working Set from recent git activity
- Consolidate to ≤12 bullets total
- Add Objective (inferred from current focus)

Discard:
- Quick Reference (was auto-generated)
- Elaborate sections
- Session cross-references

**Step 4: Enhance DECISIONS.md**

For each existing entry, prompt to add (optional):
- Tradeoff (if not present)
- Revisit trigger (if not present)

Or leave as-is — old format still readable.

**Step 5: Archive SESSIONS.md**

```
context/SESSIONS.md → context-backup-v5/SESSIONS.md
```

Not deleted (in case user wants history), but removed from active context.

**Step 6: Clean Up .claude/**

Replace entire `.claude/` folder with minimal version:
```
.claude/
└── commands/
    ├── init-context.md
    ├── save.md
    ├── upgrade-to-v6.md
    ├── review-security.md
    ├── review-performance.md
    ├── review-accessibility.md
    └── review-seo.md
```

**Step 7: Remove scripts/**

```bash
rm -rf scripts/
```

**Step 8: Update VERSION**

```
6.0.0
```

#### Migration Output

```
AI Context System: Migrated to v6.0

Backup created:
  ✓ context-backup-v5/
  ✓ .claude-backup-v5/

Changes made:
  ✓ Merged CONTEXT.md into CLAUDE.md (Agent Contract format)
  ✓ Transformed STATUS.md (structured handoff)
  ✓ Archived SESSIONS.md
  ✓ Replaced .claude/ with minimal commands
  ✓ Removed scripts/

Your active context:
  - CLAUDE.md (with Agent Contract)
  - context/DECISIONS.md (unchanged or enhanced)
  - context/STATUS.md (structured handoff)

Commands:
  /save        - Update status + prompt for decisions
  /review-*    - Focused code reviews (security, performance, etc.)

The full v5 backup is in context-backup-v5/ if you need anything.
```

### Breaking Changes

| v5.x | v6.0 | Migration |
|------|------|-----------|
| `/save-full` | Removed | Use `/save` |
| `/save` + `/decision` | Merged | `/save` does both |
| `/review-context` | Removed | Just read STATUS.md |
| `/export-context` | Removed | Copy files manually |
| `/validate-context` | Removed | Visual inspection |
| `/migrate-context` | Removed | Not needed for simple structure |
| SESSIONS.md | Archived | History preserved in backup |
| CONTEXT.md | Merged | Content moved to CLAUDE.md |
| 14 review agents | 4 review prompts | Focused set retained |

---

## Part 5: Agent Usability Tests

These are the acceptance criteria for v6.0. If these tests fail, the system isn't agent-native enough.

### Test 1: Cold Start (<60 seconds)

**Scenario:** A fresh agent opens the project for the first time.

**Pass criteria:** Agent can answer "What do I do next?" by reading only CLAUDE.md + STATUS.md in <60 seconds.

**How to verify:**
1. Open project in new Claude session
2. Time how long until agent states the current objective and next action
3. Must not require additional file reads or questions

### Test 2: Resume (Zero Clarification)

**Scenario:** Agent picks up work after a previous session ended with `/save`.

**Pass criteria:** Agent can resume correctly without asking "What were we doing?"

**How to verify:**
1. End session with `/save`
2. Start new session
3. Agent should immediately know: objective, working set, next actions
4. No clarification questions needed

### Test 3: Decision Retrieval (<30 seconds)

**Scenario:** Agent needs to understand why a key decision was made.

**Pass criteria:** Agent can explain the decision rationale by searching DECISIONS.md in <30 seconds.

**How to verify:**
1. Ask "Why did we choose X over Y?"
2. Agent finds and explains the decision (Why + Tradeoff + Revisit trigger)
3. Must not require grepping git history or asking the user

### Test 4: Scope Containment

**Scenario:** Agent is asked to review or modify code.

**Pass criteria:** Agent limits work to Working Set paths unless explicitly asked to expand.

**How to verify:**
1. Ask for a code review
2. Agent should ask "Review the working set, or something else?"
3. Agent should not audit the entire codebase unprompted

---

## Part 6: Documentation

### New README.md

The README should be dramatically shorter:

```markdown
# AI Context System

Minimal, agent-native context management for AI-assisted development.

## What It Does

Three files that enable session continuity:

- **CLAUDE.md** - Agent contract (how to run, what not to do)
- **STATUS.md** - Structured handoff (objective, working set, next actions)
- **DECISIONS.md** - Why you made choices (append-only log)

## Install

**Manual (recommended):**
\`\`\`bash
git clone --depth 1 https://github.com/rexkirshner/ai-context-system.git
cp -r ai-context-system/.claude/commands /path/to/your/project/.claude/
rm -rf ai-context-system
\`\`\`

**One-command:**
\`\`\`bash
curl -sL https://github.com/.../releases/download/v6.0.0/install.sh | bash
\`\`\`

Then: `/init-context`

## Commands

| Command | What It Does |
|---------|--------------|
| `/init-context` | Create context files |
| `/save` | Update STATUS, prompt for decisions |

## Optional: Code Reviews

Focused, scope-aware review prompts:

- `/review-security` - Security audit (working set or diff)
- `/review-performance` - Performance check
- `/review-accessibility` - Accessibility review
- `/review-seo` - SEO review

## That's It

No elaborate workflows. No 15-minute save sessions.

Ending a session? Run `/save`.
Starting a session? Read STATUS.md.
```

### Upgrade Guide

```markdown
# Upgrading from v5.x to v6.0

## What Changed

v6.0 is a radical simplification, redesigned to be agent-native.

**Core philosophy shift:**
- v5: "Externalize AI reasoning" (prose-heavy, human-focused)
- v6: "Agent harness" (schema-first, predictable API)

**Removed:**
- SESSIONS.md (git history is enough)
- CONTEXT.md (merged into CLAUDE.md)
- All shell scripts (150KB → 0)
- 14 agents → 4 review prompts
- /save-full, /decision, /export-context, /validate-context

**Added:**
- Agent Contract in CLAUDE.md
- Working Set in STATUS.md
- Tradeoff + Revisit fields in DECISIONS.md
- Staleness enforcement (7-day rule)
- Scope-aware reviews

## How to Upgrade

Preview first:
\`\`\`bash
/upgrade-to-v6 --dry-run
\`\`\`

Then execute:
\`\`\`bash
/upgrade-to-v6
\`\`\`

Your v5 files are backed up to `context-backup-v5/`.

## New Workflow

1. Work on your project
2. Ending session? → `/save`
3. Starting session? → Agent reads STATUS.md automatically
```

---

## Part 7: Implementation Plan

### Phase 1: Build v6.0 Core

1. Write new minimal command files:
   - `init-context.md` - Creates CLAUDE.md (with Agent Contract) + context/ folder
   - `save.md` - Updates STATUS.md, prompts for decisions, enforces staleness

2. Write focused review prompts (scope-aware):
   - `review-security.md`
   - `review-performance.md`
   - `review-accessibility.md`
   - `review-seo.md`

3. Create new templates:
   - `CLAUDE.md.template` (with Agent Contract)
   - `DECISIONS.md.template` (Why/Tradeoff/Revisit)
   - `STATUS.md.template` (structured handoff)

4. Write new install.sh:
   - Pin to release tag
   - Minimal (just copies files)
   - Checksum verification (optional but recommended)

### Phase 2: Build Migration

1. Write `/upgrade-to-v6` command:
   - Implement --dry-run flag
   - Make idempotent (safe to run twice)
   - Handle edge cases (missing files, custom structures)

2. Test migration with existing projects:
   - Test on 3+ real v5 projects
   - Verify backup/restore works
   - Verify idempotency

### Phase 3: Documentation

1. Rewrite README.md (short, agent-focused)
2. Write upgrade guide
3. Update or sunset acs-docs site

### Phase 4: Validation

1. Run Agent Usability Tests (cold start, resume, decision retrieval, scope containment)
2. Time each test, must meet thresholds
3. Iterate if tests fail

### Phase 5: Release

1. Tag v6.0.0
2. Create GitHub release with install.sh
3. Update install URL
4. Announce breaking changes clearly

---

## Part 8: Open Questions (Resolved)

### Should we keep the review commands?

**Resolution:** Yes. Keep 4 focused reviews as a library. Make them scope-aware (Working Set or diff).

### Should `/save` auto-prompt for decisions?

**Resolution:** Yes. `/save` is the only end-session command. It includes decision prompt. Reduces cognitive load.

### What about very large DECISIONS.md files?

**Resolution:** Single file by default. Document escape hatch (split by quarter) for projects with 100+ entries.

### Should we rename the project?

**Resolution:** Keep "AI Context System" for continuity. The v6.0 version bump and "agent-native" framing signal the change.

### What about the install.sh inconsistency?

**Resolution:** Clarify the principle: "no in-repo script framework" (no 150KB utilities during normal use). One tiny installer for setup convenience is fine. Make manual install the primary documented path.

---

## Conclusion

The AI Context System tried to solve real problems but grew too complex. v6.0 applies radical subtraction while adding agent-native structure.

**v6.0 keeps what works:**
- DECISIONS.md for capturing rationale (enhanced with Tradeoff + Revisit)
- STATUS.md for session continuity (enhanced with Working Set + Objective)
- CLAUDE.md as the entry point (enhanced with Agent Contract)
- Focused review prompts as a library (enhanced with scope-awareness)

**v6.0 cuts everything else:**
- SESSIONS.md, CONTEXT.md
- 150KB of shell scripts
- 14 agents → 4 prompts
- 22 commands → 2 commands

**v6.0 adds agent-native design:**
- Schema-first files (structured data at top)
- Predictable API (fixed keys, consistent format)
- Staleness enforcement
- Scope-aware reviews
- Usability tests as acceptance criteria

The result: a system that agents can reliably parse and act on, simple enough that people will actually use it.

---

## Appendix: File Templates

### CLAUDE.md.template

```markdown
# [Project Name]

[One paragraph: what this is, who it's for, what problem it solves]

## Agent Contract

| Key | Value |
|-----|-------|
| Run | `command here` |
| Test | `command here` |
| Lint | `command here` |
| Build | `command here` |

**Constraints:**
- [e.g., No database migrations without approval]
- [e.g., Don't refactor unrelated code]
- [e.g., Keep PRs under 300 lines when possible]

**Working Agreement:**
- Run `/save` at session end
- Log non-obvious decisions to DECISIONS.md

## Context

| File | Purpose |
|------|---------|
| `context/STATUS.md` | Current objective, working set, next actions |
| `context/DECISIONS.md` | Why choices were made |

## Notes

[Project-specific conventions, gotchas, or preferences]
```

### STATUS.md.template

```markdown
# Status

| Key | Value |
|-----|-------|
| Last updated | YYYY-MM-DD |
| Objective | [One sentence: what we're trying to accomplish] |

## Working Set
- [path/to/file/or/directory]
- [3-7 items currently being touched]

## Constraints
- [Active limitations for this work phase]

## Next Actions
- [Action 1]
- [Action 2]
- [Action 3 max]

## Blocked On
- (None)
```

### DECISIONS.md.template

```markdown
# Decisions

Append-only log. Each entry: Date, Title, Why, Tradeoff, Revisit trigger.

---

<!-- Add new decisions below -->
```

### Decision Entry Format

```markdown
## YYYY-MM-DD: [Decision Title]

**Why:** [Brief rationale - 1-2 sentences]

**Tradeoff:** [What we gave up]

**Revisit when:** [Trigger condition for reconsidering]
```
