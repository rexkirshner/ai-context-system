# AI Context System

**Version 7.0** — The End

---

## The Short Version

This project started as a simple idea, grew into a 22-command monster, got simplified to 8 commands, and finally became what it should have been from the start: **4 global commands** that make your AI context files better over time.

```bash
./install.sh
```

This installs 4 commands to `~/.claude/commands/` (Claude Code) and `~/.codex/prompts/` (OpenAI Codex). No per-project setup. No versions to track. No migration paths.

---

## The Commands

| Command | Purpose |
|---------|---------|
| `/update-context` | Extract permanent learnings from this session into CLAUDE.md and AGENTS.md |
| `/save-session` | Record what happened this session to `docs/sessions/SESSION-NNN.md` |
| `/review` | Comprehensive code review to `docs/audits/CODE-REVIEW-NN.md` |
| `/cleanup-acs` | Remove old AI Context System artifacts from a project |

That's it. Four commands. All global. Works with both Claude Code and OpenAI Codex.

---

## The Philosophy

**CLAUDE.md auto-loads. That's the leverage point.**

Both Claude Code and OpenAI Codex automatically read their context files (CLAUDE.md and AGENTS.md respectively) at session start. This is the one reliable mechanism. Build on what works.

**What belongs in context files:**
- Commands: how to run, test, build, deploy
- Constraints: what to do / not do
- Patterns: architecture, naming, conventions
- Quirks: non-obvious gotchas
- Preferences: workflow choices that affect this repo

**What doesn't belong:**
- Current task (just tell the AI)
- Temporary state (it'll figure it out)
- Information available from the codebase (it can read files)

**Session continuity:**
- Context file + codebase + telling the AI what you're working on
- That's enough. The Session Loop was solving a non-problem.

---

## The Story

### It Started Simple

The itch: copy/pasting the same CLAUDE.md content into every project. The realization that Claude Code reads CLAUDE.md automatically. The question: what if we could maintain continuity between sessions?

### It Got Complicated (v1-v5)

The philosophy (flawed):
> "I don't know what Claude Code needs to be effective, so I'll make everything available and let Claude pick what's useful."

What this led to:
- 22 commands
- 14 agents (9 specialist reviewers)
- 150KB+ of shell scripts
- JSON schemas for validation
- Multiple context files (SESSIONS.md, CONTEXT.md, STATUS.md, DECISIONS.md)
- Two-layer deduplication
- Weighted grade calculation with severity caps (A-F scale)
- Auto-archival when files exceed 2000 lines
- 80 unit tests across 11 modules

We were solving problems that didn't exist.

### We Tried to Simplify (v6)

Cut from 22 commands to 8. Removed all agents and scripts. Kept CLAUDE.md, STATUS.md, DECISIONS.md. Added a "Session Loop" pattern.

Still 8 commands. Still per-project installation. Still migration paths and version tracking.

### The Honest Conversation

> "I am really concerned that we are not in a good place right now."

Three concerns:
1. Pre-v6 versions left clutter everywhere
2. No good migration path
3. v6 might just be "slimmed down clutter" - still not doing anything useful

The hard question:
> "Is any of this actually helping Claude?"

The uncomfortable admission:
> "The actual issue is that I can't really understand what Claude Code needs in order to be effective."

We built a system to solve a problem we didn't understand.

### What We Actually Know

**Verified:**
- CLAUDE.md auto-loads (Claude Code)
- AGENTS.md auto-loads (OpenAI Codex)
- Instructions in these files are followed

**Uncertain:**
- Does Claude read STATUS.md unprompted? (Session Loop is just an instruction)
- Is "externalized context" even the right approach?
- Is session continuity actually a problem?

### The Answer

One command to make context files better over time. A few utilities for common tasks. No framework. No installation per-project. No versions.

---

## What `/update-context` Does

Run it before `/compact` or when context is long.

**Extracts permanent learnings:**
- Commands that work
- Constraints discovered
- Patterns and conventions
- Quirks
- User preferences

**Ignores ephemeral stuff:**
- Current task
- Temporary state
- Session-specific context

**Updates both files:**
- Adds new learnings
- Updates outdated info
- Keeps it concise
- Mirrors CLAUDE.md ↔ AGENTS.md (byte-for-byte identical)

---

## Cleaning Up Old Versions

If you have ACS artifacts in your projects:

```
/cleanup-acs
```

This removes:
- `context/` directory
- `.claude/commands/`, `.claude/agents/`, `.claude/skills/`, etc.
- `.claude/VERSION`, `.claude/acs-settings.json`
- Old install scripts and templates

It keeps:
- `CLAUDE.md`, `AGENTS.md` (your actual context)
- `.claude/settings.local.json` (Claude Code settings)

---

## Lessons Learned

1. **Start with the problem, not the solution.** We built tools hoping they'd reveal the problem. They didn't.

2. **Test your assumptions.** We never verified that Claude read STATUS.md or that externalized context helped.

3. **Complexity is not free.** Every file, command, and pattern has maintenance cost.

4. **Build on what you know works.** Context files auto-load. That's verified. Build there.

5. **Simple beats comprehensive.** Four commands beat 22. One file beats five.

6. **Sometimes the answer is "do less."** The best version of ACS is almost nothing.

---

## Version History

| Version | Commands | Agents | Scripts | Context Files |
|---------|----------|--------|---------|---------------|
| v5.x | 22 | 14 | 150KB+ | 5-8 |
| v6.0 | 8 | 0 | 0 | 3 |
| v7.0 | 4 (global) | 0 | 1 | 1-2 |

---

## License

MIT License. See [LICENSE](./LICENSE) for details.

---

**The value is in the subtraction.**
