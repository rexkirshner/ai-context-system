# v7 Rethink: Radical Simplification

**Date:** 2026-01-27
**Status:** Implemented

## The Problem with Current Approach

The AI Context System was built on a flawed premise: "I don't know what Claude Code needs to be effective, so I'll make everything available and let Claude pick what's useful."

This led to:
- v5.x: 22 commands, 14 agents, 150KB scripts, schemas, hooks
- v6.x: Slimmed to 8 commands, 3 files, but still potentially "slimmed down clutter"

Core uncertainty: **Is any of this actually helping Claude?**

## What We Know Works

**Context files auto-load.** Both Claude Code (CLAUDE.md) and OpenAI Codex (AGENTS.md) read their respective files at session start. Instructions there ARE followed. This is the one reliable mechanism.

**Git history exists.** Commits document what happened and (if messages are good) why.

## What's Uncertain

- Does Claude read STATUS.md unprompted? (Session Loop is just an instruction that may be ignored)
- Is "externalized context" even the right approach?
- Are we solving a problem that doesn't exist?

## The Solution: Two Commands

Instead of a framework, we have two global commands that work with any project:

### `/update-context`

Updates CLAUDE.md and AGENTS.md with permanent learnings from the session.

**What it extracts (permanent):**
- Commands that work (npm run dev, etc.)
- Constraints discovered ("don't modify X because Y")
- Patterns/conventions used in this codebase
- Quirks ("auth is in a weird place because...")
- User preferences ("small commits", "no emojis")

**What it ignores (ephemeral):**
- What we're currently working on
- Temporary state ("tests are failing")
- Session-specific context

**Heuristic:** If it affects how future sessions should work, it's permanent.

**Dual-tool support:** Keeps CLAUDE.md and AGENTS.md mirrored so projects work with both Claude Code and OpenAI Codex.

### `/cleanup-acs`

Removes all AI Context System artifacts (v1-v6) from a project:
- context/ directory
- .claude/commands/, .claude/VERSION
- v5.x infrastructure (scripts/, agents/, schemas/, etc.)

Preserves CLAUDE.md (the actual instructions file).

## What About Decisions?

Git history IS the decision log. Liberal commits with good messages capture the "why."

No separate DECISIONS.md needed.

## What About Session Continuity?

Maybe it doesn't matter. When you start a new session:
- AI reads CLAUDE.md/AGENTS.md (auto-loads)
- AI has access to the codebase
- AI can read git history
- You tell it what you want to work on

The "Session Loop" and STATUS.md were solving a non-problem.

## Final Structure

```
~/.claude/commands/          # Claude Code global commands
├── cleanup-acs.md
└── update-context.md

~/.codex/prompts/            # OpenAI Codex global commands
├── cleanup-acs.md
└── update-context.md

project/
├── CLAUDE.md                # Claude Code instructions (auto-loads)
└── AGENTS.md                # OpenAI Codex instructions (auto-loads, mirrored)
```

That's it. No context/ directory. No STATUS.md. No DECISIONS.md. No Session Loop. No framework.

## Installation

```bash
git clone https://github.com/rexkirshner/ai-context-system.git
cd ai-context-system
./install.sh
```

Installs to both `~/.claude/commands/` and `~/.codex/prompts/`.

## Key Insights

1. **You can't solve a problem you don't understand by adding complexity**
2. **"Make everything available" doesn't work** - more noise, not more signal
3. **Build on what you know works** - context files auto-load, that's the leverage point
4. **Simple beats comprehensive** - two commands beat 22
5. **Tool-agnostic is better** - support Claude Code AND OpenAI Codex with the same approach
