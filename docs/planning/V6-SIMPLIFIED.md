# AI Context System v6.0 — Simplified

**Date:** January 2026
**Status:** Draft
**Author:** Rex Kirshner + Claude

---

## The Pitch

v5.x had 22 commands, 14 agents, and 150KB of shell scripts. It was overengineered.

v6.0 has **3 files** and **2 commands**. That's it.

---

## The Files

```
project/
├── CLAUDE.md              # Entry point (auto-loaded by Claude Code)
└── context/
    ├── STATUS.md          # Where we are now
    └── DECISIONS.md       # Why we made choices
```

### CLAUDE.md

```markdown
> **Session Loop**
> 1. Start → Read `context/STATUS.md`
> 2. End → Run `/save`

# Project Name

One paragraph: what this is, what it does.

## Commands

Run: `npm start`
Test: `npm test`
Build: `npm run build`

## Constraints

- Don't refactor unrelated code
- Keep PRs under 300 lines
- Stay within the Working Set unless you have a good reason to expand

## Context

- Status: `context/STATUS.md`
- Decisions: `context/DECISIONS.md`

## Notes

- [Project-specific conventions]
```

### STATUS.md

```markdown
# Status

SchemaVersion: 1
LastUpdated: 2026-01-24
HeadCommit: a1b2c3d
Objective: Implement user authentication
EditScope: WorkingSetOnly

## Working Set

- src/auth/*
- db/schema.prisma
- tests/auth.test.ts

## Next Actions

- Implement password hashing
- Add session tokens
- Write auth middleware tests

## Blocked On

- (None)
```

**That's the whole format.** A few notes:

- **Working Set** (3-7 items): What files/directories you're touching. Keeps agents from wandering.
- **EditScope**: Either `WorkingSetOnly` (default) or `Unrestricted`. Advisory — agents should respect it, but it's not enforced mechanically.
- **HeadCommit**: Git SHA when STATUS was last saved. If it doesn't match current HEAD, STATUS might be stale.
- **SchemaVersion**: For future compatibility. Ignore it for now.

**Working Set expansion rule:** If you need to edit outside Working Set, first add the path(s) to Working Set and note why (one sentence) in Next Actions.

### DECISIONS.md

```markdown
# Decisions

Append-only log.

---

## 2026-01-24: [DB] SQLite over Postgres
Why: Local-only tool, no server component.
Tradeoff: No concurrent writes.
RevisitWhen: Multi-user mode needed.

---

## 2026-01-20: [API] REST over GraphQL
Why: Team knows REST. GraphQL learning curve not worth it.
Tradeoff: Over-fetching on some endpoints.
RevisitWhen: Mobile client needs arise.
```

**Format:**
- Title with `[Area]` prefix for grep
- Three fields: Why, Tradeoff, RevisitWhen
- Separator: blank line + `---` + blank line

This is the only file that captures *why* decisions were made. Git shows what changed. Code shows what exists. DECISIONS.md captures reasoning.

---

## The Commands

These are Claude Code slash commands — prompt files in `.claude/commands/`, not shell scripts.

### `/init-context`

Creates the three files if they don't exist. Safe to run — never overwrites.

### `/save`

1. Updates STATUS.md (Working Set, Next Actions, Blocked On)
2. Updates HeadCommit to current git HEAD
3. Asks: "Any decisions worth recording?" → If yes, appends to DECISIONS.md

That's it. One command to remember at end of session.

---

## Staleness (Keep It Simple)

When you start a session:

1. Read STATUS.md
2. If `HeadCommit` doesn't match current HEAD, STATUS might be out of date
3. If `git status` shows uncommitted changes, STATUS might be out of date
4. Use your judgment — refresh if the changes look relevant to your work

No auto-refresh. No complex intersection checks. Just: "does this look current?"

---

## What We Cut

| v5.x | v6.0 |
|------|------|
| SESSIONS.md | Gone. Git history is enough. |
| CONTEXT.md | Merged into CLAUDE.md |
| 22 commands | 2 commands |
| 14 agents | 4 optional review prompts |
| 150KB scripts | 0 scripts |
| `/save-full` (10-15 min) | Just `/save` |
| Complex validation | Visual inspection |
| Auto-refresh machinery | "Use your judgment" |
| Secret scanning | Not our job |

---

## Optional: Review Prompts

If you want focused code reviews, these are available as a library:

- `/review-security` — Security audit
- `/review-performance` — Performance check
- `/review-accessibility` — Accessibility review
- `/review-seo` — SEO review

They produce reports. They don't edit code. Use them when relevant.

---

## Install

```bash
git clone --branch v6.0.0 --depth 1 https://github.com/rexkirshner/ai-context-system.git
cp -r ai-context-system/.claude/commands /path/to/your/project/.claude/
rm -rf ai-context-system
```

Then run: `/init-context`

---

## Acceptance Tests

These are how we know v6 works:

### 1. Cold Start (<60 seconds)
New agent opens project, reads CLAUDE.md + STATUS.md, knows what to do next.

### 2. Resume (Zero Clarification)
Agent picks up after previous `/save`. No "what were we doing?" questions.

### 3. Decision Retrieval (<30 seconds)
Agent can explain why a decision was made by searching DECISIONS.md.

### 4. Working Set Respect
Agent does not edit outside Working Set without explicitly stating why and updating Working Set first.

### 5. Multi-Agent Handoff
Agent A does work + `/save`. Agent B resumes without clarifying questions.

---

## Anti-Bloat Rules

To prevent v6 from becoming v7:

1. **30-second rule**: If a feature can't be used in <30 seconds, it doesn't ship
2. **2 commands max**: New commands must replace existing ones
3. **No scripts**: Claude handles logic, not shell scripts
4. **Advisory, not mechanical**: Guidelines agents should follow, not enforcement machinery

---

## Summary

**Keep:**
- 3 files (CLAUDE.md, STATUS.md, DECISIONS.md)
- 2 commands (/init-context, /save)
- Working Set as containment boundary
- DECISIONS.md with structured format (Why/Tradeoff/RevisitWhen)
- HeadCommit for simple staleness check

**Cut:**
- Staleness detection machinery
- EditScope expansion protocol
- Secret scanning
- Idempotent save guarantees
- Auto-refresh
- Everything else that adds friction

The value is in the subtraction.
