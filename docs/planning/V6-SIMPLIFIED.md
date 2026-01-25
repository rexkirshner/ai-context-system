# AI Context System v6.0 — Simplified

**Date:** January 2026
**Status:** Draft
**Author:** Rex Kirshner + Claude

---

## The Pitch

v5.x had 22 commands, 14 agents, and 150KB of shell scripts. It was overengineered.

v6.0 has **3 files** and **3 commands** (2 daily + 1 maintenance). That's it.

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
- If you need to touch files outside Working Set, pause, propose, update Working Set, then proceed

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
- `---` after header and between entries
- Title with `[Area]` prefix for grep
- Three fields: Why, Tradeoff, RevisitWhen

This is the only file that captures *why* decisions were made. Git shows what changed. Code shows what exists. DECISIONS.md captures reasoning.

---

## The Commands

These are Claude Code slash commands — prompt files in `.claude/commands/`, not shell scripts.

### Daily workflow (2 commands)

**`/init-context`** — Creates the three files if they don't exist. Safe to run — never overwrites.

**`/save`** — End of session:
1. Updates STATUS.md (all fields: Objective, Working Set, Next Actions, Blocked On, HeadCommit, LastUpdated)
2. Asks: "Any decisions worth recording?" → If yes, appends to DECISIONS.md

`/save` keeps section headers and field names exactly as specified; content changes, structure doesn't.

### Maintenance (1 command)

**`/update-context-system`** — Updates prompt files and runs migrations. See "Updates & Migration" section.

---

## Staleness (Keep It Simple)

When you start a session:

1. Read STATUS.md
2. If `HeadCommit` doesn't match current HEAD, STATUS might be out of date
3. If `git status` shows uncommitted changes, STATUS might be out of date
4. **If either is true:** Update Objective, Working Set, and Next Actions before coding

No auto-refresh. No complex intersection checks. Just: "does this look current? If not, fix it first."

---

## What We Cut

| v5.x | v6.0 |
|------|------|
| SESSIONS.md | Gone. Git history is enough. |
| CONTEXT.md | Merged into CLAUDE.md |
| 22 commands | 3 commands (+5 optional reviews) |
| 14 agents | Gone (reviews are just prompts now) |
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
mkdir -p /path/to/your/project/.claude
cp -r ai-context-system/.claude/commands /path/to/your/project/.claude/
cp ai-context-system/.claude/VERSION /path/to/your/project/.claude/
rm -rf ai-context-system
```

Then run: `/init-context`

---

## Updates & Migration

### Version Tracking

Each project has `.claude/VERSION` containing the installed version (e.g., `6.0.0`).

### `/update-context-system`

A prompt (not a script) that:

1. Reads current version from `.claude/VERSION`
2. Copies latest prompt files from repo
3. Reads `MIGRATIONS.md` from repo
4. Shows relevant migration steps for your version jump
5. Walks through them interactively

### `MIGRATIONS.md`

Lives in the repo. Contains version-specific migration instructions. Here's the v5.x → v6.0 migration:

---

#### v5.x → v6.0 Migration

**Step 1: Backup**
```bash
cp -r context/ context-backup-v5/
cp -r .claude/ .claude-backup-v5/
```

**Step 2: Delete v5.x artifacts**
```bash
# Context files we're removing
rm -f context/SESSIONS.md
rm -f context/CONTEXT.md
rm -f context/.context-config.json

# Entire directories
rm -rf scripts/
rm -rf templates/

# .claude subdirectories
rm -rf .claude/agents/
rm -rf .claude/skills/
rm -rf .claude/schemas/
rm -rf .claude/hooks/
rm -rf .claude/docs/
rm -f .claude/acs-settings.json
rm -f .claude/.last-update-check

# Old commands (will be replaced)
rm -rf .claude/commands/
```

**Step 3: Install v6.0 commands**
```bash
git clone --branch v6.0.0 --depth 1 https://github.com/rexkirshner/ai-context-system.git
cp -r ai-context-system/.claude/commands .claude/
cp ai-context-system/.claude/VERSION .claude/
rm -rf ai-context-system
```

**Step 4: Transform CLAUDE.md**

Add Session Loop at top, merge content from CONTEXT.md:

```markdown
> **Session Loop**
> 1. Start → Read `context/STATUS.md`
> 2. End → Run `/save`

# Project Name
[content from CONTEXT.md goes here]

## Commands
[extract from CONTEXT.md]

## Constraints
- If you need to touch files outside Working Set, pause, propose, update Working Set, then proceed
[add project-specific constraints]

## Context
- Status: `context/STATUS.md`
- Decisions: `context/DECISIONS.md`

## Notes
[project conventions from CONTEXT.md]
```

**Step 5: Transform STATUS.md**

Rewrite in new format:

```markdown
# Status

SchemaVersion: 1
LastUpdated: [today's date]
HeadCommit: [run: git rev-parse --short HEAD]
Objective: [from old STATUS.md current focus]

## Working Set
- [3-7 files/directories you're currently touching]

## Next Actions
- [items from old STATUS.md]

## Blocked On
- (None)
```

**Step 6: Update DECISIONS.md** (optional)

Add [Area] prefixes for easier grep:
- Change `## 2026-01-24: Chose SQLite` to `## 2026-01-24: [DB] Chose SQLite`

**Step 7: Verify**
```bash
ls -la .claude/commands/  # Should have 8 files
ls -la context/           # Should have STATUS.md and DECISIONS.md only
```

Then run `/save` to confirm the new format works.

**Final structure after migration:**
```
project/
├── CLAUDE.md                    # With Session Loop at top
├── .claude/
│   ├── VERSION                  # Contains "6.0.0"
│   └── commands/
│       ├── init-context.md
│       ├── save.md
│       ├── update-context-system.md
│       ├── review-security.md
│       ├── review-performance.md
│       ├── review-accessibility.md
│       └── review-seo.md
└── context/
    ├── STATUS.md                # New format
    └── DECISIONS.md             # With [Area] prefixes
```

---

Future migrations (v6.0 → v6.1, etc.) will be added to MIGRATIONS.md as needed.

### Why This Design

- **Full control**: Any future change can be documented in MIGRATIONS.md
- **No machinery**: Claude just reads the markdown and acts on it
- **Extensible**: Works for small tweaks and big migrations
- **Prompt, not script**: Follows the "0 scripts" philosophy

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
2. **Minimal commands**: Daily workflow stays at 2 commands; new features fold into `/save` or don't ship
3. **No scripts**: Claude handles logic, not shell scripts
4. **Advisory, not mechanical**: Guidelines agents should follow, not enforcement machinery

---

## Summary

**Keep:**
- 3 files (CLAUDE.md, STATUS.md, DECISIONS.md)
- 3 commands (/init-context, /save, /update-context-system)
- Working Set as containment boundary
- DECISIONS.md with structured format (Why/Tradeoff/RevisitWhen)
- HeadCommit for simple staleness check

**Cut:**
- Staleness detection machinery
- EditScope (Working Set is the containment boundary)
- Secret scanning
- Idempotent save guarantees
- Auto-refresh
- Everything else that adds friction

The value is in the subtraction.
