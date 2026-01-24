# AI Context System v6.0 Proposal

## The Radical Simplification

**Date:** January 2025
**Status:** Proposal
**Author:** Rex Kirshner + Claude (Opus 4.5)

---

## Executive Summary

After extensive development of the AI Context System (currently v5.2.1), we're proposing a fundamental pivot: strip the system down to its essential value and eliminate everything else.

**Current state:** 22+ commands, 14 agents, 150KB of shell scripts, elaborate session logging, complex validation systems.

**Proposed state:** 2-3 core files, 3-5 commands, zero shell scripts, minimal overhead.

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
3. **No shell scripts** - Pure markdown, Claude handles the logic
4. **Library, not framework** - Use what you need, ignore the rest

### File Structure

```
project/
├── CLAUDE.md                    # Entry point (already auto-loaded)
└── context/
    ├── DECISIONS.md             # Append-only decision log
    └── STATUS.md                # Current focus (5 bullet points)
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

### CLAUDE.md (Enhanced)

Merges what was useful from CONTEXT.md:

```markdown
# Project Name

[One paragraph: what this is, who it's for]

## Tech Stack
- [Key technologies]

## Key Decisions
See context/DECISIONS.md

## Current Status
See context/STATUS.md

## Project-Specific Notes
[Anything Claude needs to know: conventions, gotchas, preferences]
```

### DECISIONS.md (Simplified)

Append-only log. No elaborate template:

```markdown
# Decisions

## 2025-01-24: Chose SQLite over Postgres
Local-only tool, no server component. SQLite is simpler, ships as single file.

## 2025-01-20: REST API, not GraphQL
Team has REST experience. GraphQL learning curve not worth it for this scope.

## 2025-01-18: No TypeScript
Quick prototype. Will reconsider if project grows beyond MVP.
```

Format: `## YYYY-MM-DD: [Decision Title]` followed by brief rationale. That's it.

### STATUS.md (Minimal)

```markdown
# Status

**Last updated:** 2025-01-24

## Current Focus
- Implementing user authentication

## Blocked On
- Waiting for API keys from client

## Next Up
- Add password reset flow
- Write tests for auth module
```

No Quick Reference. No elaborate sections. Just current state.

### Commands

**Core (3 commands):**

| Command | Purpose | Time |
|---------|---------|------|
| `/init-context` | Create CLAUDE.md + context/ folder with templates | 30 sec |
| `/save` | Update STATUS.md, prompt for any new decisions | 1 min |
| `/decision` | Add a new entry to DECISIONS.md | 30 sec |

**Review Library (optional, à la carte):**

| Command | When to Use |
|---------|-------------|
| `/review-security` | Any project handling user data |
| `/review-performance` | Before launch, or when things feel slow |
| `/review-accessibility` | Web projects |
| `/review-seo` | Public web projects |

Each review command is a standalone prompt. No orchestration, no synthesis agent. Run the ones relevant to your project.

### What Gets Cut

| Component | Reason for Removal |
|-----------|-------------------|
| SESSIONS.md | Git history + DECISIONS.md covers this |
| CONTEXT.md | Merged into CLAUDE.md |
| `.claude/skills/` | Overkill - simple commands suffice |
| `.claude/agents/` | 14 agents → 4-5 review prompts |
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

```bash
# One-command install (new, simplified)
curl -sL https://raw.githubusercontent.com/rexkirshner/ai-context-system/main/install.sh | bash

# Initialize
/init-context
```

Creates three files. Done.

### For Existing Users (v5.x → v6.0)

#### Migration Script Behavior

```bash
/upgrade-to-v6
```

The upgrade command will:

**Step 1: Backup**
```
context/ → context-backup-v5/
.claude/ → .claude-backup-v5/
scripts/ → (deleted, no backup needed - it's in git)
```

**Step 2: Merge CONTEXT.md into CLAUDE.md**

Extract key sections from CONTEXT.md:
- Project description → CLAUDE.md header
- Tech stack → CLAUDE.md Tech Stack section
- Project-specific conventions → CLAUDE.md Notes section

Discard:
- Redundant orientation content
- References to old structure

**Step 3: Simplify STATUS.md**

Keep:
- Current focus
- Blockers
- Next steps

Discard:
- Quick Reference (was auto-generated, not needed)
- Elaborate sections
- Session cross-references

**Step 4: Keep DECISIONS.md As-Is**

This file is already in the right format. No changes needed.

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
    ├── decision.md
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
  - context-backup-v5/
  - .claude-backup-v5/

Changes made:
  ✓ Merged CONTEXT.md into CLAUDE.md
  ✓ Simplified STATUS.md
  ✓ Archived SESSIONS.md
  ✓ Replaced .claude/ with minimal commands
  ✓ Removed scripts/

Your active context:
  - CLAUDE.md (enhanced)
  - context/DECISIONS.md (unchanged)
  - context/STATUS.md (simplified)

New commands:
  /save        - Update status, prompt for decisions
  /decision    - Add a decision
  /review-*    - Focused code reviews (security, performance, etc.)

The full v5 backup is in context-backup-v5/ if you need anything.
```

### Breaking Changes

| v5.x | v6.0 | Migration |
|------|------|-----------|
| `/save-full` | Removed | Use `/save` |
| `/review-context` | Removed | Just read STATUS.md |
| `/export-context` | Removed | Copy files manually |
| `/validate-context` | Removed | Visual inspection |
| `/migrate-context` | Removed | Not needed for simple structure |
| SESSIONS.md | Archived | History preserved in backup |
| CONTEXT.md | Merged | Content moved to CLAUDE.md |
| 14 review agents | 4 review prompts | Focused set retained |

---

## Part 5: Documentation

### New README.md

The README should be dramatically shorter:

```markdown
# AI Context System

Minimal context management for AI-assisted development.

## What It Does

Two files that solve session continuity:

- **DECISIONS.md** - Why you made choices (append-only log)
- **STATUS.md** - Where you are right now (5 bullet points)

## Install

\`\`\`bash
curl -sL https://raw.githubusercontent.com/rexkirshner/ai-context-system/main/install.sh | bash
\`\`\`

## Commands

| Command | What It Does |
|---------|--------------|
| `/init-context` | Create context files |
| `/save` | Update STATUS.md |
| `/decision` | Log a decision |

## Optional: Code Reviews

Focused review prompts when you need them:

- `/review-security` - Security audit
- `/review-performance` - Performance check
- `/review-accessibility` - Accessibility review
- `/review-seo` - SEO review

## That's It

No elaborate workflows. No 15-minute save sessions.
Just capture decisions and current status.

When you return to a project, read STATUS.md and keep going.
```

### Upgrade Guide

A simple page for v5 users:

```markdown
# Upgrading from v5.x to v6.0

## What Changed

v6.0 is a radical simplification. We removed 90% of the system
and kept what actually works.

**Removed:**
- SESSIONS.md (git history is enough)
- CONTEXT.md (merged into CLAUDE.md)
- All shell scripts
- 14 agents → 4 review prompts
- /save-full, /export-context, /validate-context

**Kept:**
- DECISIONS.md (the most valuable part)
- STATUS.md (simplified)
- Code review prompts (focused set)

## How to Upgrade

Run: `/upgrade-to-v6`

Your v5 files are backed up to `context-backup-v5/`.

## New Workflow

1. Work on your project
2. Made a non-obvious decision? → `/decision`
3. Ending session? → `/save`
4. Starting session? → Read STATUS.md
```

---

## Part 6: Implementation Plan

### Phase 1: Build v6.0 Core

1. Write new minimal command files:
   - `init-context.md`
   - `save.md`
   - `decision.md`

2. Write focused review prompts:
   - `review-security.md`
   - `review-performance.md`
   - `review-accessibility.md`
   - `review-seo.md`

3. Create new templates:
   - `CLAUDE.md.template` (enhanced)
   - `DECISIONS.md.template` (simplified)
   - `STATUS.md.template` (minimal)

4. Write new install.sh (simplified)

### Phase 2: Build Migration

1. Write `/upgrade-to-v6` command
2. Test migration with existing projects
3. Handle edge cases (missing files, custom structures)

### Phase 3: Documentation

1. Rewrite README.md
2. Write upgrade guide
3. Update acs-docs site (or simplify dramatically)

### Phase 4: Release

1. Tag v6.0.0
2. Update install URL
3. Announce breaking changes clearly

---

## Part 7: Open Questions

### Should we keep the review commands?

**Argument for:** Useful library, low maintenance, proven value.

**Argument against:** Even simpler without them. Users can just ask Claude directly.

**Recommendation:** Keep 4 focused reviews. They're standalone prompts with no dependencies.

### Should `/save` auto-prompt for decisions?

**Option A:** `/save` just updates STATUS.md. Separate `/decision` command.

**Option B:** `/save` asks "Any decisions worth logging?" and appends to DECISIONS.md if yes.

**Recommendation:** Option B. Reduces friction, captures decisions in the natural workflow.

### What about very large DECISIONS.md files?

**Option A:** Single file forever, use search.

**Option B:** Document pattern for splitting by quarter/year when needed.

**Recommendation:** Option A with documented escape hatch to Option B for large projects.

### Should we rename the project?

Current name emphasizes "AI" - but the simplified system is really just "good docs."

**Options:**
- Keep "AI Context System" - established, recognizable
- "Context System" - simpler
- "Decision Log" - describes what it actually is
- Something new entirely

**Recommendation:** Keep "AI Context System" for continuity. The v6.0 version bump signals the change.

---

## Conclusion

The AI Context System tried to solve real problems but grew too complex. The solution is not iteration - it's subtraction.

v6.0 keeps what works:
- DECISIONS.md for capturing rationale
- STATUS.md for session continuity
- Focused review prompts as a library

Everything else goes.

The result: a system simple enough that people will actually use it.

---

## Appendix: File Templates

### CLAUDE.md.template

```markdown
# [Project Name]

[One paragraph: what this is, who it's for, what problem it solves]

## Tech Stack

- **Language:**
- **Framework:**
- **Database:**
- **Hosting:**

## Context

- **Decisions:** See `context/DECISIONS.md`
- **Current Status:** See `context/STATUS.md`

## Notes

[Project-specific conventions, gotchas, or preferences for Claude]
```

### DECISIONS.md.template

```markdown
# Decisions

Append-only log of non-obvious decisions and their rationale.

Format: `## YYYY-MM-DD: Decision Title` followed by brief explanation.

---

<!-- Add new decisions at the bottom -->
```

### STATUS.md.template

```markdown
# Status

**Last updated:** YYYY-MM-DD

## Current Focus

-

## Blocked On

- (None)

## Next Up

-
```
