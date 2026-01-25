---
name: update-context-system
description: Updates context system prompt files from repo and runs migrations
---

# /update-context-system

Update the AI Context System to a newer version.

## Steps

### 1. Check Current Version

Read `.claude/VERSION` to get the current installed version.

If `.claude/VERSION` doesn't exist, assume pre-v6 (v5.x or earlier).

### 2. Get Latest Version

Clone the latest release:

```bash
git clone --depth 1 https://github.com/rexkirshner/ai-context-system.git /tmp/acs-update
```

Read the version from `/tmp/acs-update/.claude/VERSION`.

### 3. Compare Versions

If current version equals latest version:
- Report "Already up to date (v[version])"
- Clean up: `rm -rf /tmp/acs-update`
- Exit

### 4. Backup Current Files

```bash
cp -r .claude/ .claude-backup-[current-version]/
cp -r context/ context-backup-[current-version]/ 2>/dev/null || true
cp CLAUDE.md CLAUDE.md.backup-[current-version] 2>/dev/null || true
```

### 5. Copy New Command Files

Remove old commands and copy new ones:

```bash
rm -rf .claude/commands/
cp -r /tmp/acs-update/.claude/commands/ .claude/commands/
cp /tmp/acs-update/.claude/VERSION .claude/VERSION
```

### 6. Run Migrations

Read `/tmp/acs-update/MIGRATIONS.md` from the repo.

Find the migration section for your version jump (e.g., "v5.x → v6.0").

**For pre-v6 → v6.0 migrations, the key steps are:**

1. **Delete legacy artifacts** (scripts/, templates/, .claude/agents/, etc.)
2. **Create CLAUDE.md if missing** - synthesize from CONTEXT.md, README, package.json
3. **Add Session Loop to CLAUDE.md** if it exists but doesn't have it
4. **Transform STATUS.md** to new format
5. **Ensure DECISIONS.md exists**
6. **Clean up context/** - remove SESSIONS.md, CONTEXT.md, config files

Walk through each step interactively:
- Show what needs to be done
- Ask for confirmation before destructive changes
- Execute the step
- Report result

**Important:** If CLAUDE.md doesn't exist:
- Check for `context/CONTEXT.md` and use it as a source
- Check `package.json` for project name and scripts
- Check `README.md` for project description
- Create CLAUDE.md with Session Loop using the template from MIGRATIONS.md

### 7. Cleanup

```bash
rm -rf /tmp/acs-update
```

### 8. Verify

Run these checks:
- `ls -la .claude/commands/` - Should have 7 files
- `cat .claude/VERSION` - Should show new version
- `ls -la context/` - Should have only STATUS.md and DECISIONS.md
- `head -5 CLAUDE.md` - Should show Session Loop at top

## Error Handling

- **Git clone fails**: Check network connection, suggest trying again later
- **Repo not found**: Verify the repository URL is correct
- **Permission denied**: Check write permissions on .claude/ directory
- **CLAUDE.md missing and no CONTEXT.md**: Create from template, ask user for project details
- **Migration step fails**: Stop, report error, offer to restore from backup

If any step fails, clean up `/tmp/acs-update` before exiting.

## Rollback

If migration fails and user wants to restore:

```bash
rm -rf .claude/ context/ CLAUDE.md
mv .claude-backup-[version]/ .claude/
mv context-backup-[version]/ context/
mv CLAUDE.md.backup-[version] CLAUDE.md
```

## Done

Report:
- Previous version (or "pre-v6" if no VERSION file)
- New version
- Files created (especially if CLAUDE.md was created)
- Migration steps performed
- Any manual steps still needed
