# /cleanup-acs

Remove AI Context System artifacts from this project.

## Preflight

Before scanning, verify:
1. We're in a git repo (run `git rev-parse --show-toplevel`)
2. At least one ACS marker exists: `context/`, `.claude/acs-settings.json`, `.claude/VERSION`

If not a git repo: warn but continue (deletions won't be reversible via git).
If no ACS markers found: output **"No ACS artifacts found."** and stop.

## Targets

**High-confidence** (safe to remove if present):
- `context/`
- `.claude/commands/`, `.claude/agents/`, `.claude/skills/`, `.claude/schemas/`, `.claude/hooks/`, `.claude/docs/`
- `.claude/VERSION`, `.claude/acs-settings.json`, `.claude/.last-update-check`
- Root-level `install.sh`, `VERSION`

**Conditional** (common names — only remove if they contain ACS content):
- `scripts/` — remove only if contains ACS scripts (e.g., `acs-*.sh`, `install-acs.sh`)
- `templates/` — remove only if contains `.claude/` or `context/` templates
- `config/` — remove only if contains `acs-*.json` or ACS config files
- `reference/`, `artifacts/` — remove only if contains ACS documentation or outputs

If unsure whether a conditional dir is ACS-only: skip it and note in report.

## Keep (never remove)

- `CLAUDE.md`, `AGENTS.md`
- `.claude/settings.local.json`

## Procedure

1. **Preflight** — run checks above
2. **Scan** — for each target, check: exists? git-tracked?
3. **Plan** — list what will be deleted (high-confidence vs conditional)
4. **Delete**
   - Use `git rm -r` for git-tracked items
   - Use `rm -rf` for untracked items
5. **Verify** — re-scan to confirm deletion
6. **Report** — structured output:
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
   ```

If nothing to remove after preflight: **"No ACS artifacts found."**

**Restore:** Run `git restore` or `git checkout` to undo tracked deletions.
