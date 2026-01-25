# Migrations

Version-specific migration instructions for the AI Context System.

---

## v5.x → v6.0 (or any pre-v6 version)

**Overview:** v6.0 is a radical simplification - from 22 commands, 14 agents, and 150KB of scripts to 3 files and 7 commands.

This migration handles upgrades from ANY pre-v6 version (v3.x, v4.x, v5.x).

**Note:** If `context/` doesn't exist at all, that's fine—skip the context-related cleanup steps and let `/init-context` create it fresh after migration.

### Step 1: Backup

```bash
# Backup everything we might modify
cp -r context/ context-backup-pre-v6/ 2>/dev/null || true
cp -r .claude/ .claude-backup-pre-v6/ 2>/dev/null || true
cp CLAUDE.md CLAUDE.md.backup-pre-v6 2>/dev/null || true
```

### Step 2: Delete legacy artifacts (except files needed for synthesis)

**Important:** Keep `context/CONTEXT.md` for now - we need it in Step 4 to create CLAUDE.md.

```bash
# === Context directory cleanup (keep CONTEXT.md for now) ===
rm -f context/SESSIONS.md
rm -f context/.context-config.json
rm -f context/cursor.md
rm -f context/aider.md
rm -f context/codex.md
rm -f context/generic-ai-header.md
# NOTE: Keep context/CONTEXT.md until after Step 4

# === Root directory cleanup ===
rm -rf scripts/
rm -rf templates/
rm -rf config/
rm -rf test/
rm -rf reference/
rm -f install.sh

# === Docs directory cleanup (keep docs/planning/ if desired) ===
rm -rf docs/audits/
rm -rf docs/skills/
rm -rf docs/migration/
rm -rf docs/archive/

# === Artifacts cleanup ===
rm -rf artifacts/

# === .claude directory cleanup ===
rm -rf .claude/agents/
rm -rf .claude/skills/
rm -rf .claude/schemas/
rm -rf .claude/hooks/
rm -rf .claude/docs/
rm -f .claude/acs-settings.json
rm -f .claude/.last-update-check

# === Old commands (will be replaced) ===
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

**Alternative if git clone fails:** Download the release zip from GitHub releases, extract it, and copy the files manually.

### Step 4: Create or Transform CLAUDE.md

**If CLAUDE.md does NOT exist**, create it by synthesizing from available sources:

1. Read `context/CONTEXT.md` (if it exists) for project info
2. Read `package.json`, `README.md`, or other project files for context
3. Create CLAUDE.md using this template:

```markdown
> **Session Loop**
> 1. Start → Read `context/STATUS.md`
> 2. End → Run `/save`

# [Project Name]

[One paragraph describing the project - synthesize from CONTEXT.md, README.md, or package.json]

## Commands

Run: `[detect from package.json scripts, Makefile, etc.]`
Test: `[detect from package.json scripts, Makefile, etc.]`
Build: `[detect from package.json scripts, Makefile, etc.]`

## Constraints

- Don't refactor unrelated code
- Keep PRs under 300 lines
- If you need to touch files outside Working Set, pause, propose, update Working Set, then proceed

## Context

- Status: `context/STATUS.md`
- Decisions: `context/DECISIONS.md`

## Notes

- [Extract any project conventions from CONTEXT.md or existing docs]
```

**If CLAUDE.md DOES exist**, prepend the Session Loop and add the Context section:

1. Add at the very top:
   ```markdown
   > **Session Loop**
   > 1. Start → Read `context/STATUS.md`
   > 2. End → Run `/save`

   ```

2. Add the Context section (if not present):
   ```markdown
   ## Context

   - Status: `context/STATUS.md`
   - Decisions: `context/DECISIONS.md`
   ```

3. Review `context/CONTEXT.md` and merge useful content into CLAUDE.md:
   - **Project description** → Add to the paragraph after the title
   - **Tech stack/dependencies** → Add to the Notes section
   - **Development conventions** → Add to the Notes section
   - **Architecture notes** → Add to the Notes section
   - Skip anything redundant or obsolete

4. **After CLAUDE.md is created/updated**, delete CONTEXT.md:
   ```bash
   rm -f context/CONTEXT.md
   ```

### Step 5: Transform STATUS.md

If `context/STATUS.md` exists, rewrite it in the new format.

**Extract from old STATUS.md:**
- Current objective/focus
- Any work in progress items
- Next steps / action items
- Blockers

**Create new format:**

```markdown
# Status

SchemaVersion: 1
LastUpdated: [today's date YYYY-MM-DD]
HeadCommit: [run: git rev-parse --short HEAD, or "N/A" if not a git repo]
Objective: [extracted from old STATUS.md]

## Working Set

- [3-7 files/directories currently being worked on]
- [Extract from old STATUS.md work in progress]

## Next Actions

- [Extract from old STATUS.md next steps]

## Blocked On

- [Extract blockers, or "(None)" if clear]
```

**If STATUS.md doesn't exist**, create it with placeholder values:

```markdown
# Status

SchemaVersion: 1
LastUpdated: [today's date]
HeadCommit: [run: git rev-parse --short HEAD, or "N/A"]
Objective: TBD

## Working Set

- TBD

## Next Actions

- TBD

## Blocked On

- (None)
```

### Step 6: Ensure DECISIONS.md exists

If `context/DECISIONS.md` doesn't exist, create it:

```markdown
# Decisions

Append-only log.

---
```

If it exists, optionally add [Area] prefixes for easier grep:
- Change `## 2026-01-24: Chose SQLite` to `## 2026-01-24: [DB] Chose SQLite`

### Step 7: Final cleanup and verification

Verify context/ only has the required files:

```bash
ls context/
# Should show only: STATUS.md, DECISIONS.md
```

Remove any stragglers that might have been missed:

```bash
rm -f context/SESSIONS.md context/CONTEXT.md context/.context-config.json 2>/dev/null
rm -f context/cursor.md context/aider.md context/codex.md 2>/dev/null
rm -f context/generic-ai-header.md 2>/dev/null
```

### Step 8: Verify

```bash
# Should have 7 files
ls -la .claude/commands/

# Should have only STATUS.md and DECISIONS.md
ls -la context/

# Should be 6.0.0
cat .claude/VERSION

# CLAUDE.md should exist with Session Loop at top
head -5 CLAUDE.md
```

Then run `/save` to confirm everything works.

### Final structure after migration

```
project/
├── CLAUDE.md                    # With Session Loop at top
├── .claude/
│   ├── VERSION                  # Contains "6.0.0"
│   ├── settings.local.json      # (if exists - user settings, preserved)
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
    └── DECISIONS.md             # With optional [Area] prefixes
```

### Rollback (if needed)

If migration fails, restore from backups:

```bash
rm -rf context/ .claude/ CLAUDE.md
mv context-backup-pre-v6/ context/
mv .claude-backup-pre-v6/ .claude/
mv CLAUDE.md.backup-pre-v6 CLAUDE.md
```

---

## Troubleshooting

### "CLAUDE.md doesn't exist and I have no CONTEXT.md"

Create CLAUDE.md manually using the template in Step 4. Fill in:
- Project name from `package.json`, directory name, or README
- Commands from `package.json` scripts or Makefile
- Any known constraints or conventions

### "My STATUS.md has a different format"

The v6.0 format is simpler. Extract key information (objective, current work, next steps, blockers) and reformat. Don't worry about losing v5.x fields like Quick Reference - they're no longer needed.

### "I want to keep my artifacts/"

If you have v5.x audit reports in `artifacts/` that you want to preserve, back them up before running the migration:

```bash
cp -r artifacts/ artifacts-backup/
```

The migration will delete `artifacts/` since v6.0 doesn't use it.

---

Future migrations (v6.0 → v6.1, etc.) will be added below as needed.
