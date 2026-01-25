# Migrations

Version-specific migration instructions for the AI Context System.

---

## v5.x → v6.0

**Overview:** v6.0 is a radical simplification - from 22 commands, 14 agents, and 150KB of scripts to 3 files and 7 commands.

### Step 1: Backup

```bash
cp -r context/ context-backup-v5/
cp -r .claude/ .claude-backup-v5/
```

### Step 2: Delete v5.x artifacts

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

### Step 3: Install v6.0 commands

```bash
git clone --branch v6.0.0 --depth 1 https://github.com/rexkirshner/ai-context-system.git
mkdir -p .claude/commands
cp -r ai-context-system/.claude/commands/ .claude/commands/
cp ai-context-system/.claude/VERSION .claude/VERSION
rm -rf ai-context-system
```

### Step 4: Transform CLAUDE.md

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
- Don't refactor unrelated code
- Keep PRs under 300 lines
- If you need to touch files outside Working Set, pause, propose, update Working Set, then proceed
[add project-specific constraints]

## Context
- Status: `context/STATUS.md`
- Decisions: `context/DECISIONS.md`

## Notes
[project conventions from CONTEXT.md]
```

### Step 5: Transform STATUS.md

Rewrite in new format:

```markdown
# Status

SchemaVersion: 1
LastUpdated: [today's date]
HeadCommit: [run: git rev-parse --short HEAD, or "N/A" if not a git repo]
Objective: [from old STATUS.md current focus]

## Working Set
- [3-7 files/directories you're currently touching]

## Next Actions
- [items from old STATUS.md]

## Blocked On
- (None)
```

### Step 6: Update DECISIONS.md (optional)

Add [Area] prefixes for easier grep:
- Change `## 2026-01-24: Chose SQLite` to `## 2026-01-24: [DB] Chose SQLite`

### Step 7: Verify

```bash
ls -la .claude/commands/  # Should have 7 files
ls -la context/           # Should have STATUS.md and DECISIONS.md only
```

Then run `/save` to confirm the new format works.

### Final structure after migration

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

Future migrations (v6.0 → v6.1, etc.) will be added below as needed.
