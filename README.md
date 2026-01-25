# AI Context System

**Version 6.0.0** — Radical Simplification

> **Externalize AI context. Enable session continuity. Keep it simple.**

---

## The Pitch

v5.x had 22 commands, 14 agents, and 150KB of shell scripts. It was overengineered.

v6.0 has **3 files** and **3 commands** (+ 4 optional review prompts). That's it.

---

## Quick Start

```bash
# Clone and copy to your project
git clone --depth 1 https://github.com/rexkirshner/ai-context-system.git
mkdir -p /path/to/your/project/.claude
cp -r ai-context-system/.claude/commands /path/to/your/project/.claude/
cp ai-context-system/.claude/VERSION /path/to/your/project/.claude/
rm -rf ai-context-system

# In Claude Code, initialize
/init-context
```

---

## The Files

After installation and running `/init-context`:

```
your-project/
├── .claude/
│   ├── VERSION            # Installed version (6.0.0)
│   └── commands/          # 7 slash command prompts
├── CLAUDE.md              # Entry point (auto-loaded by Claude Code)
└── context/
    ├── STATUS.md          # Where we are now
    └── DECISIONS.md       # Why we made choices
```

### CLAUDE.md

Your project's entry point. Contains:
- Session Loop instructions (read STATUS.md at start, run `/save` at end)
- Project description
- Commands (run, test, build)
- Constraints
- Links to context files

### STATUS.md

Current state. Updated every session:
- **Objective**: What you're working toward
- **Working Set**: Files/directories you're touching (3-7 items)
- **Next Actions**: Concrete next steps
- **Blocked On**: Blockers or "(None)"
- **HeadCommit**: Git SHA for staleness detection

### DECISIONS.md

Append-only log of decisions with:
- **Why**: Reason for the decision
- **Tradeoff**: What you gave up
- **RevisitWhen**: Trigger to reconsider

This is the only file that captures *why* decisions were made.

---

## The Commands

### Daily Workflow (2 commands)

**`/init-context`** — Creates the three files if they don't exist. Safe to run—never overwrites.

**`/save`** — End of session:
1. Updates STATUS.md (all fields)
2. Asks: "Any decisions worth recording?" → If yes, appends to DECISIONS.md

### Maintenance (1 command)

**`/update-context-system`** — Updates prompt files from repo and runs migrations.

### Optional Reviews (4 commands)

Use when relevant:
- `/review-security` — Security audit
- `/review-performance` — Performance check
- `/review-accessibility` — Accessibility review
- `/review-seo` — SEO review

They produce reports. They don't edit code.

---

## Workflow

### Session Start
1. Claude Code auto-loads CLAUDE.md
2. Read `context/STATUS.md`
3. If HeadCommit doesn't match current HEAD, STATUS might be stale—update first

### Session End
1. Run `/save`
2. STATUS.md updated, decisions recorded if any

### AI-to-AI Handoff
1. Run `/save` to capture current state
2. New agent reads CLAUDE.md + STATUS.md
3. Picks up exactly where you left off

---

## Philosophy

### Keep It Simple
- **3 files** instead of 8
- **7 commands** instead of 22 (3 core + 4 optional reviews)
- **0 scripts** — Claude handles logic, not shell scripts

### Advisory, Not Mechanical
- Guidelines agents should follow, not enforcement machinery
- Visual inspection over complex validation
- "Use your judgment" over auto-refresh

### Working Set as Boundary
- 3-7 items you're actively touching
- If you need to edit outside, add to Working Set first
- No EditScope machinery—just a simple list

---

## What We Cut (from v5.x)

| v5.x | v6.0 |
|------|------|
| SESSIONS.md | Gone. Git history is enough. |
| CONTEXT.md | Merged into CLAUDE.md |
| 22 commands | 7 commands (3 core + 4 optional reviews) |
| 14 agents | Gone (reviews are just prompts now) |
| 150KB scripts | 0 scripts |
| `/save-full` (10-15 min) | Just `/save` |
| Complex validation | Visual inspection |
| Auto-refresh machinery | "Use your judgment" |

---

## Upgrading from v5.x (or earlier)

See [MIGRATIONS.md](./MIGRATIONS.md) for step-by-step migration instructions.

Quick summary:
1. Backup existing files
2. Delete legacy artifacts (scripts/, templates/, .claude/agents/, etc.)
3. Copy new v6.0 commands
4. Create CLAUDE.md if missing (synthesize from CONTEXT.md, README, package.json)
5. Add Session Loop to existing CLAUDE.md
6. Transform STATUS.md (new simpler format)
7. Optional: Add [Area] prefixes to DECISIONS.md

---

## Requirements

- Claude Code CLI (for slash commands)
- Any project (language/framework agnostic)
- Git (optional - enables HeadCommit staleness detection; works without it)

Works with any AI tool that can read markdown files.

---

## Anti-Bloat Rules

To prevent v6 from becoming v7:

1. **30-second rule**: If a feature can't be used in <30 seconds, it doesn't ship
2. **Minimal commands**: Daily workflow stays at 2 commands
3. **No scripts**: Claude handles logic
4. **Advisory, not mechanical**: Guidelines, not enforcement

---

## License

Use freely for personal or commercial projects.

---

**Remember:** The value is in the subtraction.
