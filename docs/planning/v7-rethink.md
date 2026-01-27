# v7 Rethink: Radical Simplification

**Date:** 2026-01-27
**Status:** Exploration - capturing direction before potential context loss

## The Problem with Current Approach

The AI Context System was built on a flawed premise: "I don't know what Claude Code needs to be effective, so I'll make everything available and let Claude pick what's useful."

This led to:
- v5.x: 22 commands, 14 agents, 150KB scripts, schemas, hooks
- v6.x: Slimmed to 8 commands, 3 files, but still potentially "slimmed down clutter"

Core uncertainty: **Is any of this actually helping Claude?**

## What We Know Works

**CLAUDE.md auto-loads.** Claude Code reads it at session start. Instructions there ARE followed. This is the one reliable mechanism.

**Git history exists.** Commits document what happened and (if messages are good) why.

## What's Uncertain

- Does Claude read STATUS.md unprompted? (Session Loop is just an instruction that may be ignored)
- Is "externalized context" even the right approach?
- Are we solving a problem that doesn't exist?

## New Direction: One Command

Instead of multiple files and ceremony, what if we had:

**One file:** CLAUDE.md (auto-loads, guaranteed to be seen)

**One command:** "Update CLAUDE.md to be as useful as possible"

Run before compaction to capture permanent project learnings.

### What the Command Does

**Inputs:**
- Current conversation (what happened this session)
- Current CLAUDE.md (what's already there)

**Extracts permanent learnings:**
- Commands that work (npm run dev, etc.)
- Constraints discovered ("don't modify X because Y")
- Patterns/conventions used in this codebase
- Quirks ("auth is in a weird place because...")
- User preferences ("small commits", "no emojis")

**Ignores ephemeral stuff:**
- What we're currently working on
- Temporary state ("tests are failing")
- Session-specific context

**Updates CLAUDE.md:**
- Adds new learnings to appropriate sections
- Updates outdated info
- Keeps it concise - instructions, not documentation

### What About Decisions?

User already has Claude commit liberally. Git history IS the decision log.

CLAUDE.md instruction:
```markdown
## Commits
- Commit after every logical unit of work
- Message format: what (why)
- The commit history is our documentation
```

No separate DECISIONS.md needed.

### What About Session Continuity?

Maybe it doesn't matter. When you start a new session:
- Claude reads CLAUDE.md (auto-loads)
- Claude has access to the codebase
- Claude can read git history
- You tell Claude what you want to work on

The "Session Loop" and STATUS.md may have been solving a non-problem.

## Proposed Structure

```
project/
├── CLAUDE.md           # The one file (auto-loads)
└── .claude/
    └── commands/
        └── save.md     # The one command (or maybe /update-claude-md?)
```

That's it. No context/ directory. No STATUS.md. No DECISIONS.md. No Session Loop.

## Open Questions

1. What sections should CLAUDE.md have?
2. How do we prevent it from growing unboundedly?
3. What's the right heuristic for "permanent vs ephemeral"?
4. Should the command be /save or something else?
5. Do we need any other commands at all?

## The Test

Before committing to this direction, we should test:
1. Does the current Session Loop actually work? (Does Claude read STATUS.md unprompted?)
2. Would a well-crafted CLAUDE.md alone be enough?
3. Is there actually a continuity problem we're solving?

## Next Steps

- Decide if this direction is worth pursuing
- If yes, prototype the single command
- Test on real projects
- Deprecate v6 complexity if v7 works
