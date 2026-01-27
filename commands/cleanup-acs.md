# /cleanup-acs

Remove all AI Context System artifacts from this project.

## Remove

- `context/` directory
- `.claude/commands/`, `.claude/agents/`, `.claude/skills/`, `.claude/schemas/`, `.claude/hooks/`, `.claude/docs/`
- `.claude/VERSION`, `.claude/acs-settings.json`, `.claude/.last-update-check`
- `scripts/`, `templates/`, `config/`, `reference/`, `artifacts/`
- Root-level `install.sh`, `VERSION`

## Keep

- `CLAUDE.md`, `AGENTS.md` (your instruction files)
- `.claude/settings.local.json` (Claude Code settings)

## Do

1. Scan for artifacts listed above
2. List what was found
3. Delete them
4. Report: what was removed, what was kept

If nothing found: "No ACS artifacts found."

**Note:** Use git to restore if needed.
