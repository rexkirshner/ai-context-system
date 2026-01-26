# AI Context System

**Version 6.0** — Radical Simplification

> **Externalize AI context. Enable session continuity. Keep it simple.**

---

## The Pitch

v5.x had 22 commands, 14 agents, and 150KB of shell scripts. It was overengineered.

v6.0 has **3 files** and **8 commands** (3 core + 5 optional reviews). That's it.

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

This creates three files: `CLAUDE.md` (project entry point), `context/STATUS.md` (current state), and `context/DECISIONS.md` (decision log).

---

## The Files

After installation and running `/init-context`:

```
your-project/
├── .claude/
│   ├── VERSION            # Tracks installed version for /update-context-system
│   └── commands/          # 8 slash command prompts
├── CLAUDE.md              # Entry point (auto-loaded by Claude Code)
└── context/
    ├── STATUS.md          # Where we are now
    └── DECISIONS.md       # Why we made choices
```

**Note:** Only `.claude/VERSION` is used. The root `VERSION` file (if present) is for repo tagging only.

### CLAUDE.md

Your project's entry point. Contains:
- **Session Loop**: The core pattern—read STATUS.md at session start to resume context, run `/save` at end to persist it. This enables continuity across sessions and AI-to-AI handoffs.
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

**`/init-context`** — Creates the three files if they don't exist. Never overwrites.

**`/save`** — End of session:
1. Updates STATUS.md (all fields)
2. Autonomously records decisions worth preserving to DECISIONS.md

### Maintenance (1 command)

**`/update-context-system`** — Updates command files from the repo (v6.x → v6.y upgrades only).

### Optional Reviews (5 commands)

Use when relevant:
- `/review-security` — Security audit
- `/review-performance` — Performance check
- `/review-accessibility` — Accessibility review
- `/review-seo` — SEO review
- `/review-cost` — Cost optimization review

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
- **8 commands** instead of 22 (3 core + 5 optional reviews)
- **0 scripts** — Claude handles logic, not shell scripts

### Advisory, Not Mechanical
- Guidelines agents should follow, not enforcement machinery
- Visual inspection over complex validation
- "Use your judgment" over auto-refresh

### Working Set as Boundary
- 3-7 items you're actively touching (enough to be useful, few enough to review at a glance)
- If you need to edit outside, add to Working Set first
- No EditScope machinery—just a simple list

---

## What We Cut (from v5.x)

| v5.x | v6.0 |
|------|------|
| SESSIONS.md | Gone. Git history is enough. |
| CONTEXT.md | Merged into CLAUDE.md |
| 22 commands | 8 commands (3 core + 5 optional reviews) |
| 14 agents | Gone (reviews are just prompts now) |
| 150KB scripts | 0 scripts |
| `/save-full` (10-15 min) | Just `/save` |
| Complex validation | Visual inspection |
| Auto-refresh machinery | "Use your judgment" |

---

## Upgrading from v5.x (or earlier)

See [MIGRATIONS.md](./MIGRATIONS.md) for detailed instructions.

**Quick summary:**

```bash
# Download and run the migration script
curl -O https://raw.githubusercontent.com/rexkirshner/ai-context-system/main/migrate-to-v6.sh
chmod +x migrate-to-v6.sh
./migrate-to-v6.sh
```

The script creates a backup, deletes v5.x artifacts, and installs v6.0 commands. After running, restart Claude Code and ask Claude to migrate your context files to v6.0 format.

---

## Requirements

- Claude Code CLI (for slash commands)
- Any project (language/framework agnostic)
- Git (required for installation and updates; optional for daily use if HeadCommit detection not needed)
- macOS, Linux, or Windows with WSL/Git Bash (commands use `/tmp/` for temp files)

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

MIT License. See [LICENSE](./LICENSE) for details.

---

**Remember:** The value is in the subtraction.
