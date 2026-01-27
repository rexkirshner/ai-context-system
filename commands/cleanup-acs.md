# /cleanup-acs

Remove AI Context System artifacts from this project.

## Preflight

Before scanning, verify:
1. Run `git rev-parse --show-toplevel` to get repo root (all paths are relative to this)
2. At least one ACS marker exists: `context/`, `.claude/acs-settings.json`, `.claude/VERSION`

If not a git repo: warn that deletions are **irreversible** (cannot be restored).
If no ACS markers found: output **"No ACS artifacts found."** and stop.

## Safety Rules

- **Stay in repo root.** All targets are relative to repo root. If any path resolves outside repo root, STOP entirely (this indicates a bug or symlink traversal).
- **Don't follow symlinks.** If a target is a symlink, skip it and report as "Skipped — symlink."
- **Always confirm.** Never delete without user typing `DELETE`, regardless of git status.
- **Plan before delete.** Always print the deletion plan before asking for confirmation.

## Targets

**High-confidence** (directories/files to remove entirely if present):
- `context/`
- `.claude/commands/`, `.claude/agents/`, `.claude/skills/`, `.claude/schemas/`, `.claude/hooks/`, `.claude/docs/`
- `.claude/VERSION`, `.claude/acs-settings.json`, `.claude/.last-update-check`
- Root-level `install.sh`, `VERSION`

**Conditional** (remove only ACS files within, not the directory itself):
- `scripts/` — delete only: `acs-*.sh`, `install-acs.sh`, `migrate-*.sh`
- `templates/` — delete only: files referencing `.claude/` or `context/` in content, or `acs/` subdirs
- `config/` — delete only: `acs-*.json`, `context-config.json`
- `reference/`, `artifacts/` — delete only: files with "acs" or "context-system" in name or content

**Content scanning constraints** (for rules that check file content):
- Only scan text files (`.md`, `.json`, `.sh`, `.txt`, `.yaml`, `.yml`)
- Skip files > 1 MB
- Skip vendor/build dirs inside conditional paths: `node_modules/`, `.git/`, `dist/`, `build/`, `vendor/`

If unsure whether a file is ACS-related: skip it and note in report.

## Keep (never remove)

- `CLAUDE.md`, `AGENTS.md`
- `.claude/settings.local.json`

## Procedure

1. **Preflight** — run checks above; stop if no markers
2. **Scan** — for each target: exists? symlink? git-tracked?
3. **Plan** — print deletion plan grouped by high-confidence vs conditional
4. **Confirm** — ask user to type `DELETE` to proceed; if not received, stop after plan
5. **Delete**
   - Use `git rm -r` for git-tracked items
   - Use `rm -rf` for untracked items (never follows symlinks due to step 2)
6. **Verify** — re-scan to confirm deletion
7. **Report** — structured output:
   ```
   Removed:
   - path (git rm)
   - path (rm)

   Kept:
   - CLAUDE.md
   - .claude/settings.local.json

   Skipped:
   - path — reason

   Not found:
   - path

   Totals: removed=N kept=N skipped=N not_found=N
   ```

If scan finds 0 deletable items: **"No ACS artifacts found."**

**Restore:** `git restore` or `git checkout` undoes tracked deletions. Untracked deletions cannot be restored via git.
