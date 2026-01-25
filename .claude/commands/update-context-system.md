---
name: update-context-system
description: Updates context system prompt files from repo and runs migrations
---

# /update-context-system

Update the AI Context System to a newer version.

## Steps

### 1. Check Current Version

Read `.claude/VERSION` to get the current installed version.

If `.claude/VERSION` doesn't exist, assume v5.x or earlier.

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
```

### 5. Copy New Files

Remove old commands and copy new ones to ensure a clean state:

```bash
rm -rf .claude/commands/
cp -r /tmp/acs-update/.claude/commands/ .claude/commands/
cp /tmp/acs-update/.claude/VERSION .claude/VERSION
```

### 6. Run Migrations

Read `/tmp/acs-update/MIGRATIONS.md` from the repo.

Find migration steps for your version jump (e.g., v5.x → v6.0, v6.0 → v6.1).

Walk through each applicable migration step interactively:
- Show what needs to be done
- Ask for confirmation before destructive changes
- Execute the step
- Report result

### 7. Cleanup

```bash
rm -rf /tmp/acs-update
```

### 8. Verify

- List files in `.claude/commands/`
- Show new version from `.claude/VERSION`
- Confirm migration completed

## Error Handling

- **Git clone fails**: Check network connection, suggest trying again later
- **Repo not found**: Verify the repository URL is correct
- **Permission denied**: Check write permissions on .claude/ directory
- **Migration step fails**: Stop, report error, suggest manual intervention

If any step fails, clean up `/tmp/acs-update` before exiting.

## Done

Report:
- Previous version
- New version
- Migration steps performed
- Any manual steps still needed
