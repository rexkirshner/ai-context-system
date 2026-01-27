# /cleanup-acs

Remove all AI Context System artifacts from this project.

## What to Remove

**Context files (all versions):**
- `context/` directory (STATUS.md, DECISIONS.md, SESSIONS.md, CONTEXT.md, etc.)

**ACS commands and config:**
- `.claude/commands/` (if contains ACS commands like save.md, init-context.md, etc.)
- `.claude/VERSION`
- `.claude/acs-settings.json`
- `.claude/.last-update-check`

**v5.x infrastructure:**
- `.claude/agents/`
- `.claude/skills/`
- `.claude/schemas/`
- `.claude/hooks/`
- `.claude/docs/`
- `scripts/`
- `templates/`
- `config/`
- `test/` (if ACS test directory)
- `reference/`
- `artifacts/`
- `install.sh` (root level)
- `VERSION` (root level)

## What to Keep

- `CLAUDE.md` — This is your project instructions file. Keep it.
- `.claude/settings.local.json` — Your Claude Code settings. Keep it.
- Any non-ACS files in `.claude/`

## Instructions

1. **Scan** the project for ACS artifacts from the lists above
2. **List** what was found:
   ```
   Found ACS artifacts:
   - context/ (4 files)
   - .claude/commands/ (8 files)
   - .claude/VERSION
   ```
3. **Delete** each artifact found
4. **Report** what was removed:
   ```
   Removed:
   ✓ context/ (deleted)
   ✓ .claude/commands/ (deleted)
   ✓ .claude/VERSION (deleted)

   Kept:
   - CLAUDE.md
   - .claude/settings.local.json

   ACS cleanup complete.
   ```

## If Nothing Found

```
No ACS artifacts found in this project.
```

## Notes

- This removes ALL versions of ACS (v1 through v6+)
- CLAUDE.md is preserved — edit or delete it manually if you don't want it
- This is a one-way operation, use git to restore if needed
