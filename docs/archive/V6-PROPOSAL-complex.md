# AI Context System v6.0 Proposal

## The Radical Simplification

**Date:** January 2026
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
7. **Key: Value over tables** - Simpler to parse, harder to break, more robust
8. **Deterministic output** - /save always produces the same shape; agents can trust it

### Anti-Bloat Guardrails

To prevent v6 from becoming v7-bloat, we codify these rules:

1. **30-second rule:** If a feature can't be used in <30 seconds, it doesn't ship
2. **Core command cap:** Core stays at 2 commands; new commands must replace existing ones
3. **Library, not workflow:** Anything requiring orchestration/multi-step becomes an optional prompt, not core
4. **Verbosity limits:** Per-section caps only, no "total bullets" rule. See Schema Contract for authoritative spec.
5. **Feature folding:** If a feature requires the agent to remember another step, it must be folded into `/save` or removed.

### File Structure

```
project/
├── CLAUDE.md                    # Entry point (already auto-loaded)
└── context/
    ├── DECISIONS.md             # Append-only decision log
    └── STATUS.md                # Current state (structured handoff)
```

That's it. Three files.

**Source of truth policy:**

```
Default: Commit context/ to git.
  - Any agent on any machine can resume reliably
  - "Resume" and "Cold Start" tests apply everywhere

Optional (local-only projects): Add context/ to .gitignore
  - "Resume" tests only apply on same machine
  - No merge conflicts, but no cross-machine continuity
  - Use only for personal/experimental projects

Git merge conflict rules:
  - STATUS.md: Keep block with most recent LastUpdated, merge Next Actions
  - DECISIONS.md: Keep all entries (append-only), sort by date
  - STATUS is allowed to be slightly wrong — keep it short, resolve quickly
```

This answers the fundamental question: git is the source of truth, and context files should be committed by default.

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

**Critical insight:** Claude Code auto-loads CLAUDE.md, not STATUS.md. So put an unavoidable Session Loop directive at the very top — before the project name, before everything. This makes the system feel like "how you work" rather than "docs you maintain."

**Why Key: Value instead of tables:** Markdown tables are the easiest thing for humans to accidentally break (extra pipes, misaligned rows) and for agents to parse inconsistently. A rigid `Key: Value` format is simpler, more robust, and harder to corrupt.

```markdown
> **Session Loop**
> 1. Start → MUST read `context/STATUS.md`, follow Next Actions
> 2. End → MUST run `/save`
>
> `/save` is safe anytime — run it at session start or mid-session if uncertain.

# Project Name

[One paragraph: what this is, who it's for]

## Agent Contract

Run: `npm start`
Test: `npm test`
Lint: `npm run lint`
Build: `npm run build`

**Constraints:**
- No database migrations without approval
- Don't refactor unrelated code
- Keep PRs focused (<300 lines when possible)
- Do not edit files outside Working Set unless EditScope is Unrestricted
- Never write secrets (API keys, tokens, passwords, PII) into context files

## Context

Status: `context/STATUS.md`
Decisions: `context/DECISIONS.md`

## Notes

<!-- ≤10 bullets, no paragraphs -->
- [Project-specific conventions, gotchas, or preferences]
```

This prevents "agent guesswork" — any agent can reliably answer:
- How do I run this?
- What are the rules?
- What must I not do?

### STATUS.md (Structured Handoff)

Schema-first design. Fixed key block at top for reliable parsing. **Strict section order** — `/save` rewrites STATUS in canonical order every time.

**Why Key: Value instead of tables:** Same rationale as CLAUDE.md — simpler to parse, harder to break, more robust.

```markdown
# Status

SchemaVersion: 1
LastUpdated: 2026-01-24
HeadCommit: a1b2c3d
Objective: Implement user authentication
Success: Tests pass + login works offline
EditScope: WorkingSetOnly

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

## Relevant Decisions
- 2026-01-20: Chose SQLite over Postgres
- 2026-01-18: No TypeScript for MVP
```

**SchemaVersion:** APIs version. `SchemaVersion: 1` lets us evolve keys later without breaking agents or old repos. Agents can check this to handle older formats gracefully.

**Schema Contract (single source of truth for all format rules):**

```
=== STATUS.md ===

Header keys in this exact order:
  SchemaVersion, LastUpdated, HeadCommit, Objective, Success, EditScope

EditScope enum: WorkingSetOnly | Unrestricted
  WorkingSetOnly (default): edits only in Working Set
  Unrestricted: edits anywhere

Read access: always allowed everywhere (agents need to trace call paths, types, configs)
Edit access: constrained by EditScope + expansion protocol

Date format: ISO YYYY-MM-DD
HeadCommit format: 7-character git SHA (short form), or (None) if git unavailable
Empty values: Use (None) not blank

Sections in this exact order:
  Working Set, Constraints, Next Actions, Blocked On, Relevant Decisions

Working Set entries: file paths, directories, or globs
  Treat as git pathspecs for intersection checks (e.g., src/auth/*)

STATUS caps:
  Working Set: 3-7 items
  Constraints: ≤5 items
  Next Actions: ≤3 items
  Blocked On: ≤3 items
  Relevant Decisions: ≤3 items

=== DECISIONS.md ===

Entry format (exactly 4 lines, no blanks between):
  ## YYYY-MM-DD: [Area] Title
  Why: [1-2 sentences]
  Tradeoff: [1 sentence]
  RevisitWhen: [1 sentence]

Title convention: [Area] prefix for grep (e.g., [Auth] SQLite over Postgres)

Separator (exactly):
  [blank line]
  ---
  [blank line]
  ## next entry...

No trailing --- at EOF. File ends after last RevisitWhen line.

=== CLAUDE.md ===

Required sections: Session Loop (blockquote at top), Agent Contract, Context, Notes
Notes cap: ≤10 bullets, no paragraphs
```

This is the authoritative spec. All other references in this document defer to Schema Contract.

**Key additions from feedback:**

1. **Working Set** (3-7 paths) - What files/modules we're touching right now. Massively reduces "agent wandering."

2. **Objective** - One sentence. What are we trying to accomplish?

3. **Success** (1 line) - When are we done? Makes completion machine-legible. Prevents drift.

4. **HeadCommit** - Git SHA when STATUS was last saved. Enables commit-based staleness detection.

5. **EditScope** - Explicit boundary for agent edits (read access is always allowed everywhere):
   - `WorkingSetOnly` (default) - Edits constrained to Working Set
   - `Unrestricted` - Edits anywhere (use sparingly)

**EditScope Expansion Protocol:** If work requires editing a file outside Working Set:
1. Agent must **propose** the change (explain why it's needed)
2. Agent must **update STATUS first** (add path to Working Set, adjust EditScope if needed)
3. Then proceed with the edit

This turns containment into a mechanical process, not a judgment call.

6. **Constraints** - Active limitations for this work phase.

7. **Relevant Decisions** (optional, ≤3 entries) - Quick reference to decisions that matter for current work. Just date + title — full details in DECISIONS.md. Makes "why are we doing it this way?" fast without searching a long file.

**Staleness rule (diff-aware, includes uncommitted changes):** Staleness = repo moved in ways that affect current work.

On session start, compute all changed files using two commands:
```bash
# Staged + unstaged + untracked (NUL-separated for robust parsing)
DirtyFiles = git status --porcelain=v1 -z | parse NUL-separated entries
# For renames (R status), take the NEW path (after the NUL separator)

# Committed since last save
CommittedChanges = git diff --name-only -z HeadCommit..HEAD | parse NUL-separated

AllChangedFiles = DirtyFiles ∪ CommittedChanges
```

**Why NUL-separated:** Paths with spaces, renames (`old -> new`), and special characters break line-based parsing. Using `-z` and parsing NUL-separated entries is robust.

Then:
1. If `AllChangedFiles` is empty and HEAD == HeadCommit, STATUS is current. Proceed.
2. If `AllChangedFiles` intersects Working Set (or files referenced by Next Actions), STATUS is stale → auto-refresh before proceeding (see enforcement rule below).
3. If no intersection with Working Set, STATUS is still valid — just update `HeadCommit` on next `/save`.

**Staleness enforcement:** When `/save` detects stale STATUS intersecting Working Set:
- Auto-refresh STATUS: rewrite in canonical order, re-derive Working Set / Next Actions / Blocked On from the agent's current understanding (not from git), update HeadCommit
- Print warning: "STATUS was stale. Auto-refreshed. Review changes before continuing."
- Do NOT block or require manual intervention (keeps workflow natural)

**What auto-refresh is NOT:** Simply bumping HeadCommit. The agent must actually update the semantic content (Working Set, Next Actions, Blocked On) to reflect current reality.

**Intersection check for directories:** When untracked files include a new directory (e.g., `src/newmodule/`), treat it as intersecting if the directory path is a prefix of any Working Set entry, or vice versa. Example: Working Set `src/*` intersects untracked directory `src/newmodule/`.

**No-git fallback:** If git commands fail (not a repo, git not installed, zip drop, vendor dir), treat STATUS as stale. Agent must manually refresh Working Set, Next Actions, and Blocked On before proceeding.

**Why include uncommitted changes:** The most common scenario is: agent ends session with uncommitted edits, new session starts with same HEAD but dirty working tree. Checking only committed changes misses this entirely.

**Verbosity limits:** See Schema Contract above for authoritative caps.

### DECISIONS.md (Actionable Format)

Minimal but structured for agent utility. **Key: Value format** (no markdown bold) for consistency with STATUS and easier machine parsing:

```markdown
# Decisions

Append-only log. See Schema Contract for format rules.

---

## 2026-01-24: [DB] SQLite over Postgres
Why: Local-only tool, no server component. Ships as single file.
Tradeoff: No concurrent writes, limited scaling.
RevisitWhen: Multi-user mode or hosted deployment.

---

## 2026-01-20: [API] REST over GraphQL
Why: Team has REST experience. GraphQL learning curve not worth it.
Tradeoff: Over-fetching on some endpoints.
RevisitWhen: Mobile client needs arise (bandwidth matters more).
```

**Format rules:** See Schema Contract. Key points:
- Separator: blank line, `---`, blank line (no trailing `---` at EOF)
- Entry: 4 lines (heading + 3 fields), no blanks between

**Key additions from feedback:**
- **Why** - Brief rationale
- **Tradeoff** - What we gave up
- **RevisitWhen** - Trigger condition for reconsidering

Still tiny (4 lines per entry: heading + 3 fields), but way more actionable for future agents. Using `Key: Value` (no bold, no colons in keys) reduces formatting drift and makes entries more consistently machine-writable.

### Commands

**Command categories:** The "2 core commands" principle means the daily workflow uses only 2 commands. Migration and library prompts exist but are separate concerns.

**Core workflow (2 commands):**

| Command | Purpose | Time |
|---------|---------|------|
| `/init-context` | Create CLAUDE.md + context/ folder with templates (safe, never overwrites) | 30 sec |
| `/save` | Update STATUS.md, prompt for decisions, enforce staleness | 1 min |

**Migration (one-time):**

| Command | Purpose |
|---------|---------|
| `/upgrade-to-v6` | Migrate from v5.x (run once, then delete) |

**Optional library (à la carte):**

| Command | When to Use |
|---------|-------------|
| `/review-security` | Any project handling user data |
| `/review-performance` | Before launch, or when things feel slow |
| `/review-accessibility` | Web projects |
| `/review-seo` | Public web projects |

**Key insight:** `/save` is the only "end session" action. It includes the decision prompt. Agents shouldn't have to remember multiple commands.

**`/init-context` overwrite behavior (safe by default):**

If CLAUDE.md or context/ already exist, `/init-context` does NOT overwrite. Instead:
- Creates only these `.v6.new` files:
  - `CLAUDE.md.v6.new`
  - `context/STATUS.md.v6.new`
  - `context/DECISIONS.md.v6.new`
- Prints warning: "Existing files found. Review .v6.new files and merge manually, or run with --force to overwrite."
- `--force` flag available but discouraged

This prevents accidental clobbering and avoids re-introducing removed files (e.g., CONTEXT.md).

**`/save` behavior:**
1. Update STATUS.md (working set, objective, success criteria, next actions, blockers, relevant decisions)
2. Update `HeadCommit` to current `git rev-parse HEAD` (short form, 7 chars)
3. Update `LastUpdated` to current date (YYYY-MM-DD)
4. **Normalize deterministically:**
   - Rewrite STATUS in canonical section order (per Schema Contract)
   - Enforce per-section caps (3-7 working set, ≤5 constraints, ≤3 next actions, ≤3 blocked on, ≤3 relevant decisions)
   - Normalize bullets (same prefix `- `, no nested lists, no paragraphs)
   - Empty sections get `(None)` not blank
5. **Security check:** Scan newly written lines for common secret patterns:
   - Token prefixes: `sk-`, `AIza`, `xoxb-`, `ghp_`, `Bearer `
   - Key markers: `-----BEGIN`, `password=`, `secret=`
   - If detected: replace the value with `[REDACTED]` and warn the user
6. **Decision prompt (form-like):**
   - Ask: "Any non-obvious decisions made this session? (Yes/No)"
   - If yes, collect exactly: Title (≤10 words), Why (1-2 sentences), Tradeoff (1 sentence), RevisitWhen (1 sentence)
   - Append to DECISIONS.md in structured format
7. If new decision is relevant to current work, add to Relevant Decisions in STATUS

**Why form-like prompts:** "Any decisions?" invites essays. Form-like collection (Yes/No → specific fields with length limits) keeps output deterministic and aligns with verbosity caps.

**Why /save is deterministic:** This is the difference between "docs you might update" and "a tiny API you can rely on." Agents trust that STATUS always has the same shape. The tool maintains invariants automatically — agents don't have to remember formatting discipline.

**Invariant: /save is the only canonical writer.** Humans can edit STATUS manually, but `/save` is the canonical formatter. Any deviations (extra whitespace, reordered sections, non-standard bullets) will be normalized on next `/save`. This prevents bikeshedding and keeps the API shape stable.

**Invariant: /save never widens EditScope.** `/save` may prune items, enforce caps, and reorder sections — but it must NOT change EditScope from `WorkingSetOnly` to `Unrestricted`. Only the user or agent (via the expansion protocol) can widen the boundary. This preserves trust in the constraint.

**Commit-after-save tip:** If the working tree is clean after `/save`, print:
```
Tip: If you commit after /save, run /save again to refresh HeadCommit.
     Otherwise the next session may flag STATUS as stale (even if accurate).
```
This keeps staleness logic strict without trying to "guess correctness."

**Review prompts = report only:**

`/review-*` commands produce a **report only** — no code edits. This prevents surprise refactors and keeps reviews "library, not workflow."

Each review prompt:
1. Asks agent to limit scope to Working Set, git diff, or user-provided target
2. Produces findings as a structured report (see template below)
3. Does NOT make changes unless user explicitly requests follow-up edits

**Review output template:**
```
## Scope
[Working Set | git diff | user-specified target]

## Findings
- [High/Med/Low] path/to/file: Issue description → Suggested fix
- [Med] src/auth.ts: Missing input validation → Add zod schema
- [Low] src/utils.ts: Unused import → Remove line 3

## Next Steps (optional, ≤3)
- [Action 1]
- [Action 2]
```

This keeps reviews fast, relevant, predictable, and actionable.

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

**Manual install (recommended):**
```bash
# Clone pinned release and copy only what you need
git clone --branch v6.0.0 --depth 1 https://github.com/rexkirshner/ai-context-system.git
cp -r ai-context-system/.claude/commands /path/to/your/project/.claude/
rm -rf ai-context-system
```

Then run: `/init-context`

**Why manual is recommended:** You see exactly what's being added. No curl-to-bash trust required. Pinning to a release tag ensures reproducibility. Creates three files. Done.

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
- Tech stack → Agent Contract block (Key: Value format)
- Run/test/build commands → Agent Contract
- Constraints → Agent Contract Constraints section
- Project conventions → Notes section

Add if missing:
- Session Loop at top
- Agent Contract with working agreement

**Step 3: Transform STATUS.md**

Convert to structured handoff format:
- Add key block header (SchemaVersion, LastUpdated, HeadCommit, Objective, Success, EditScope)
- Extract or create Working Set from recent git activity
- Enforce per-section caps (Working Set 3-7, Constraints ≤5, Next Actions ≤3, Relevant Decisions ≤3)
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
3. Agent sees Session Loop at top of CLAUDE.md, reads STATUS.md
4. Agent should immediately know: objective, working set, success criteria, next actions
5. No clarification questions needed

### Test 3: Decision Retrieval (<30 seconds)

**Scenario:** Agent needs to understand why a key decision was made.

**Pass criteria:** Agent can explain the decision rationale by searching DECISIONS.md in <30 seconds.

**How to verify:**
1. Ask "Why did we choose X over Y?"
2. Agent finds and explains the decision (Why + Tradeoff + Revisit trigger)
3. Must not require grepping git history or asking the user

### Test 4: EditScope Containment

**Scenario:** Agent is asked to review or modify code.

**Pass criteria:** Agent limits edits to Working Set paths unless explicitly asked to expand (reading is always allowed).

**How to verify:**
1. Ask for a code review
2. Agent should ask "Review the working set, or something else?"
3. Agent should not audit the entire codebase unprompted

### Test 5: No-Wandering (Hard Mode)

**Scenario:** Agent is given a task where the "tempting" solution touches unrelated files.

**Pass criteria:** Agent stays inside Working Set for edits, or explicitly updates STATUS EditScope first before expanding.

**How to verify:**
1. Set up a task like "fix the auth bug" where Working Set is `src/auth/*`
2. The bug could also be "fixed" by modifying `src/config/settings.js` (outside Working Set)
3. Agent should either:
   - Fix within Working Set only, OR
   - Ask to expand EditScope, update STATUS, then proceed
4. Agent should NOT silently edit files outside Working Set (reading is fine)

**Why this matters:** This directly validates the "Working Set reduces wandering" claim. If agents ignore EditScope, the system isn't agent-native enough.

### Test 6: Dirty Resume

**Scenario:** Agent ends session with uncommitted changes in Working Set, then a new session starts.

**Pass criteria:** Agent detects dirty working tree intersecting Working Set and either refreshes STATUS or warns and requests refresh.

**How to verify:**
1. End session with uncommitted edits in files within Working Set
2. Run `/save` (STATUS updated, HeadCommit set)
3. Make additional uncommitted edits (same HEAD, dirty tree)
4. Start new session
5. Agent should:
   - Detect that unstaged/staged changes intersect Working Set
   - Warn that STATUS may be stale
   - Request refresh or auto-refresh before proceeding
6. Agent should NOT proceed blindly with stale context

**Why this matters:** This is the most common real-world scenario. The staleness check must include uncommitted changes, not just committed diffs.

### Test 7: Multi-Agent Handoff

**Scenario:** Agent A does work and runs `/save`. Agent B (completely fresh session, different context) picks up where A left off.

**Pass criteria:** Agent B makes progress without asking clarifying questions, stays within EditScope, and doesn't re-open decisions that Agent A already settled.

**How to verify:**
1. Agent A works on a task (e.g., "implement auth middleware")
2. Agent A makes a decision (e.g., "chose JWT over sessions") and records it
3. Agent A runs `/save`, ending session
4. Agent B starts fresh (no shared memory with A)
5. Agent B should:
   - Read STATUS and immediately understand objective + next actions
   - Not ask "What were we doing?" or "Why JWT?"
   - Continue work within the same EditScope
   - Not revisit the JWT decision unless new information surfaces
6. Agent B makes progress and runs `/save`

**Why this matters:** This validates the original vision — "agent-to-agent continuity" — using the v6 harness. If B can't seamlessly continue A's work, the system isn't truly agent-native.

### Test 8: Idempotent Save

**Scenario:** Run `/save` twice with no working tree changes between runs.

**Pass criteria:** STATUS.md and DECISIONS.md are byte-identical after the second `/save`.

**How to verify:**
1. Run `/save` to normalize STATUS and DECISIONS
2. Copy STATUS.md and DECISIONS.md to temp files
3. Run `/save` again (no edits between)
4. Diff against temp files
5. Pass only if zero diff

**Why this matters:** This prevents slow drift (extra whitespace, reordered bullets, timestamp jitter) from creeping in. If `/save` is truly deterministic, running it twice produces identical output.

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

\`\`\`bash
git clone --branch v6.0.0 --depth 1 https://github.com/rexkirshner/ai-context-system.git
cp -r ai-context-system/.claude/commands /path/to/your/project/.claude/
rm -rf ai-context-system
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
- Session Loop + Agent Contract in CLAUDE.md
- Working Set + EditScope + Relevant Decisions in STATUS.md
- Tradeoff + Revisit fields in DECISIONS.md
- Commit-based staleness enforcement (HeadCommit)
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

4. Write new install.sh (optional, for convenience only):
   - Pin to release tag
   - Minimal (just copies files, no runtime dependencies)
   - Manual install remains the primary documented path

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

### Phase 5: Reference Implementation

**Definition of done beyond docs:** Ship a reference implementation repo that proves the system works.

1. Create `ai-context-system-example` repo with:
   - Commands installed (init-context, save, review-*)
   - Templates in place
   - A small working codebase (e.g., a CLI tool or simple web app)
   - All 8 acceptance tests demonstrated and passing

2. This is the best anti-vanity move: if we can't demonstrate the tests passing on a real repo, the spec is theater.

### Phase 6: Release

1. Tag v6.0.0
2. Create GitHub release with install.sh
3. Update install URL
4. Link to reference implementation repo
5. Announce breaking changes clearly

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
- STATUS.md for session continuity (enhanced with Working Set + Objective + Success)
- CLAUDE.md as the entry point (enhanced with Session Loop + Agent Contract)
- Focused review prompts as a library (enhanced with scope-awareness)

**v6.0 cuts everything else:**
- SESSIONS.md, CONTEXT.md
- 150KB of shell scripts
- 14 agents → 4 prompts
- 22 commands → 2 commands

**v6.0 adds agent-native design:**
- Session Loop at top of CLAUDE.md with "MUST" directives
- Key: Value format everywhere (STATUS, CLAUDE, DECISIONS entries)
- SchemaVersion + explicit Schema Contract (key order, enums, formats)
- Schema-first files (structured data at top, strict section order)
- Predictable API (fixed keys, consistent format, deterministic output)
- Success criteria (machine-legible "done" state)
- EditScope boundary + Expansion Protocol (mechanical, not judgment)
- Relevant Decisions in STATUS (fast lookup without searching)
- /save normalizes deterministically (prunes, orders, enforces caps)
- /save prompts are form-like (Yes/No + specific fields, not open-ended)
- /init-context is safe by default (never overwrites, creates .v6.new)
- Diff-aware staleness including uncommitted changes
- Review prompts = report only (no surprise refactors)
- Security guardrail (never write secrets to context files)
- Git conflict guidance (simple merge rules)
- 8 usability tests including dirty resume, multi-agent handoff, idempotent save

The result: a system that agents can reliably parse and act on, simple enough that people will actually use it.

---

## Appendix: File Templates

### CLAUDE.md.template

```markdown
> **Session Loop**
> 1. Start → MUST read `context/STATUS.md`, follow Next Actions
> 2. End → MUST run `/save`
>
> `/save` is safe anytime — run it at session start or mid-session if uncertain.

# [Project Name]

[One paragraph: what this is, who it's for, what problem it solves]

## Agent Contract

Run: `command here`
Test: `command here`
Lint: `command here`
Build: `command here`

**Constraints:**
- [e.g., No database migrations without approval]
- [e.g., Don't refactor unrelated code]
- [e.g., Keep PRs under 300 lines when possible]
- Do not edit files outside Working Set unless EditScope is Unrestricted
- Never write secrets (API keys, tokens, passwords, PII) into context files

## Context

Status: `context/STATUS.md`
Decisions: `context/DECISIONS.md`

## Notes

<!-- ≤10 bullets, no paragraphs -->
- [Project-specific conventions, gotchas, or preferences]
```

### STATUS.md.template

```markdown
# Status

SchemaVersion: 1
LastUpdated: YYYY-MM-DD
HeadCommit: [git SHA]
Objective: [One sentence: what we're trying to accomplish]
Success: [One line: when are we done?]
EditScope: WorkingSetOnly

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

## Relevant Decisions
- (None)
```

### DECISIONS.md.template

```markdown
# Decisions

Append-only log. See Schema Contract for format rules.
```

(Empty file has no `---` — first entry adds the separator.)

### Decision Entry Format

```markdown
## YYYY-MM-DD: [Area] Decision Title
Why: [Brief rationale - 1-2 sentences]
Tradeoff: [What we gave up]
RevisitWhen: [Trigger condition for reconsidering]
```

Title convention: `[Area]` prefix enables grep (e.g., `[Auth]`, `[DB]`, `[API]`).
No blank line between heading and fields. No blank lines between fields.
