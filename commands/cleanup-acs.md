# /cleanup-acs

Remove AI Context System artifacts from this project.

## Flags

- `--dry-run` — Show deletion plan without prompting for confirmation, then exit
- `--force` — Skip confirmation prompt (for CI/automation). Requires explicit flag, never infer.

## Preflight

Before scanning, verify:
1. Run `git rev-parse --show-toplevel` to get repo root (all paths are relative to this)
2. At least one ACS marker exists: `context/`, `.claude/acs-settings.json`, `.claude/VERSION`

If not a git repo: warn that deletions are **irreversible** (cannot be restored).
If no ACS markers found: output **"No ACS artifacts found."** and stop.

## Safety Rules

- **Stay in repo root.** All targets are relative to repo root. Resolve `repo_root` and each candidate via `realpath` (or equivalent) and verify the candidate starts with `repo_root/`. If any path resolves outside, STOP entirely.
- **Don't follow symlinks.** Skip symlink targets during Scan; deletion commands only run on non-symlink paths. Report skipped symlinks as "Skipped — symlink."
- **Always confirm.** Unless `--force` is set, never delete without user typing `DELETE`.
- **Plan before delete.** Always print the deletion plan before asking for confirmation (or before exiting if `--dry-run`).

## Targets

**High-confidence** (directories/files to remove entirely if present):
- `context/`
- `.claude-backup-*/` (migration backups, glob pattern)
- `.claude/commands/`, `.claude/agents/`, `.claude/skills/`, `.claude/schemas/`, `.claude/hooks/`, `.claude/docs/`
- `.claude/VERSION`, `.claude/acs-settings.json`, `.claude/.last-update-check`, `.claude/.install-manifest.json`
- Root-level `install.sh`, `VERSION`

**Conditional** (remove only matching files within, preserve the directory):

| Directory | Pattern match | Content grep (case-insensitive) |
|-----------|---------------|--------------------------------|
| `scripts/` | `acs-*.sh`, `install-acs.sh`, `migrate-*.sh` | — |
| `templates/` | `acs/**` (entire subdir) | `grep -il '\.claude/\|context/' *.md *.json` |
| `config/` | `acs-*.json`, `*context-config*.json` | — |
| `reference/` | `*acs*`, `*context-system*` | `grep -il 'ai-context-system\|acs-settings' *` |
| `artifacts/` | `*acs*`, `*context-system*` | `grep -il 'ai-context-system\|acs-settings' *` |

**Content scanning constraints:**
- Only scan text files: `.md`, `.json`, `.sh`, `.txt`, `.yaml`, `.yml`
- Skip files > 1 MB
- Skip vendor/build subdirs: `node_modules/`, `.git/`, `dist/`, `build/`, `vendor/`
- Grep is non-recursive (current dir only) unless pattern specifies otherwise

If a file doesn't match both pattern AND grep (when grep applies): skip it.

## Keep (never remove)

- `CLAUDE.md`, `AGENTS.md`
- `.claude/settings.local.json`

## Procedure

1. **Preflight** — run checks above; stop if no markers
2. **Scan** — for each target:
   - Check: exists? symlink? git-tracked? modified?
   - Include BOTH tracked and untracked files (use `git status` + filesystem scan)
   - Run grep patterns where specified
   - Flag modified files for warning in plan
3. **Plan** — print deletion plan:
   - Group by high-confidence vs conditional
   - Sort paths lexicographically within each group
   - Include `reason` for each item (e.g., "high-confidence", "matches acs-*.sh", "grep matched: .claude/")
   - Mark untracked items with "(untracked)" — these use `rm`, not `git rm`
   - **Warn about modified files**: If any tracked files have uncommitted changes, list them with "(modified)" and note they will be force-deleted
4. **Confirm**
   - Print summary: "About to remove N files. Type DELETE to confirm."
   - If `--dry-run`: print plan and summary, then exit (no confirmation prompt)
   - If `--force`: proceed to Delete without prompting
   - Otherwise: wait for user to type `DELETE` (case-sensitive, all caps) to proceed
5. **Delete**
   - For git-tracked directories: run `git rm -rf -- <path>` then `rm -rf -- <path>` (git rm leaves empty dir shells on filesystem)
   - For git-tracked files: run `git rm -f -- <path>`
   - For untracked items: run `rm -rf -- <path>`
6. **Empty directories** — after deletions:
   - Recursively find empty subdirs within conditional directories (e.g., `artifacts/feedback/`)
   - Check if top-level conditional dirs (`scripts/`, `templates/`, `config/`, `reference/`, `artifacts/`) are now empty
   - Treat directories containing only `.DS_Store` as empty (delete the `.DS_Store` first)
   - Remove all empty dirs (bottom-up) and note in report as "removed (empty after cleanup)"
7. **Verify** — re-scan to confirm deletion
8. **Report** — structured output (sort paths lexicographically in each section):
   ```
   Removed:
   - path (git rm)
   - path (rm)
   - path (empty after cleanup)

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
