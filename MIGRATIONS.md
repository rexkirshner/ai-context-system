# Migrations

Version-specific migration instructions for the AI Context System.

---

## Two Upgrade Paths

| From | To | Method |
|------|-----|--------|
| Pre-v6 (v5.x, v4.x, etc.) | v6.0+ | Run `migrate-to-v6.sh` script |
| v6.x | v6.y | Run `/update-context-system` command |

**Important:** These paths are mutually exclusive. Use the correct one for your situation.

---

## Upgrading from Pre-v6 (v5.x, v4.x, etc.)

If you're on a pre-v6 version, you must use the migration script. The `/update-context-system` command will not work.

### How to Identify Pre-v6

You're on pre-v6 if you have any of:
- `scripts/` directory
- `.claude/agents/` directory
- `context/SESSIONS.md` file
- STATUS.md with `## Quick Reference` or `## Current Phase` section

Note: A missing `.claude/VERSION` file alone doesn't indicate pre-v6 (fresh projects also lack it). Look for the artifacts above.

### Migration Steps

**Before you start:** Commit your files to git. The script doesn't create backups — use `git checkout` to rollback if needed.

**1. Download and run the migration script:**

```bash
curl -O https://raw.githubusercontent.com/rexkirshner/ai-context-system/main/migrate-to-v6.sh
chmod +x migrate-to-v6.sh
./migrate-to-v6.sh
```

**2. Restart Claude Code** (exit and reopen)

**3. Complete the migration with Claude:**

The script keeps your old context files so Claude can extract valuable information. Copy and paste this prompt:

> Complete the v6.0 migration:
> 1. Read context/SESSIONS.md and context/CONTEXT.md (if they exist)
> 2. Extract any valuable project context, decisions, or history
> 3. Update context/STATUS.md to v6.0 format
> 4. Update context/DECISIONS.md to v6.0 format (preserve existing decisions)
> 5. Delete the old files (if they exist): context/SESSIONS.md, context/CONTEXT.md
> 6. Verify with /save

**4. Verify with `/save`**

### What the Script Does

1. **Verifies pre-v6 installation** — Refuses to run on fresh or v6.0+ projects
2. **Deletes v5.x infrastructure** (no valuable content):
   - `scripts/`, `templates/`, `config/`, `test/`, `reference/`, `artifacts/`
   - `.claude/agents/`, `.claude/skills/`, `.claude/schemas/`, `.claude/hooks/`, `.claude/docs/`
   - `install.sh`, `VERSION` (root level)
3. **Keeps context files for migration:**
   - `context/SESSIONS.md`, `context/CONTEXT.md` — Claude extracts value, then deletes
   - `context/STATUS.md`, `context/DECISIONS.md` — Claude updates to v6.0 format
4. **Downloads v6.0 commands** from GitHub
5. **Deletes itself** — The script is no longer needed

**No backup is created.** Use `git checkout` to rollback if needed.

### Context File Formats

**STATUS.md v6.0 format:**

```markdown
# Status

SchemaVersion: 1
LastUpdated: YYYY-MM-DD
HeadCommit: [git SHA or N/A]
Objective: [current goal]

## Working Set

- [3-7 files/directories being touched]

## Next Actions

- [concrete next steps]

## Blocked On

- (None)
```

**DECISIONS.md v6.0 format:**

```markdown
# Decisions

Append-only log.

---

## YYYY-MM-DD: [Area] Decision Title
Why: [reason for the decision]
Tradeoff: [what we gave up]
RevisitWhen: [trigger to revisit]
```

### If Something Goes Wrong

Use git to restore the previous state:

```bash
# Restore all deleted files
git checkout -- .

# Or restore specific files
git checkout -- context/ .claude/ CLAUDE.md
```

---

## Upgrading from v6.x to v6.y

For projects already on v6.0+, use the built-in command:

```bash
/update-context-system
```

That's it. The command:
1. Checks current version
2. Downloads latest v6.x commands
3. Updates `.claude/commands/` and `.claude/VERSION`
4. Reports success

No migration steps needed for v6.x → v6.y upgrades.

---

## Schema Versioning

STATUS.md includes `SchemaVersion: 1` to enable future format changes.

**Current schema (v1):** Introduced in v6.0. If we change the STATUS.md format in a future release, we'll increment to SchemaVersion 2 and document the transformation here.

**Philosophy:** Schema changes should be rare. The v6.x → v6.y upgrade path handles command updates; schema migrations (if ever needed) would be documented here.

---

## Troubleshooting

### "/update-context-system says I'm on pre-v6"

This is correct. The command only handles v6.x → v6.y upgrades. Use the migration script instead:

```bash
curl -O https://raw.githubusercontent.com/rexkirshner/ai-context-system/main/migrate-to-v6.sh
chmod +x migrate-to-v6.sh
./migrate-to-v6.sh
```

### "/save says STATUS.md is in v5.x format"

Your context files need migration. Either:

1. **Run the migration script** (if you haven't yet)
2. **Manually update STATUS.md** to v6.0 format (see format above)

### "migrate-to-v6.sh says I'm already on v6.x"

Correct. You don't need the migration script. Use `/update-context-system` for v6.x → v6.y upgrades.

### "migrate-to-v6.sh says no v5.x installation detected"

This means you don't have any v5.x artifacts. Either:
- This is a fresh project — use `/init-context` to set up
- You already migrated — use `/update-context-system` for future upgrades

### "I want to migrate context files manually"

After running the migration script (or if you manually installed v6.0 commands), transform your context files:

**STATUS.md:** Extract objective, working files, next steps, and blockers from old format. Create new format with SchemaVersion: 1.

**DECISIONS.md:** If using verbose v5.x format (Context, Decision, Rationale, Alternatives, etc.), condense each entry to the simple format (Why, Tradeoff, RevisitWhen). Add [Area] prefixes for searchability.

---

## Final Structure After Migration

```
project/
├── CLAUDE.md                    # With Session Loop at top
├── .claude/
│   ├── VERSION                  # Contains "6.0.x"
│   ├── settings.local.json      # (if exists - user settings, preserved)
│   └── commands/
│       ├── init-context.md
│       ├── save.md
│       ├── update-context-system.md
│       ├── review-security.md
│       ├── review-performance.md
│       ├── review-accessibility.md
│       ├── review-seo.md
│       └── review-cost.md
└── context/
    ├── STATUS.md                # v6.0 format
    └── DECISIONS.md             # v6.0 format
```
