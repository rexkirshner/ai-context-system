# Migration Guide: v4.x to v5.x

This guide covers migrating from AI Context System v4.x to v5.x.

## Overview

v5.0 is a major redesign that:
- Simplifies commands (22 → 7 core commands)
- Adds agent-based code review (9 specialist reviewers + orchestration agents)
- Adds skill definitions for modular execution
- Preserves all user content

## Prerequisites

- Currently running ACS v4.0.x, v4.1.x, or v4.2.x
- No uncommitted changes in context files
- Backup of your project (recommended)

## Migration Steps

### 1. Backup (Automatic)

The migration creates a backup at:
```
.claude-backup-YYYYMMDD-HHMMSS/
```

### 2. Run Update

```bash
/update-context-system
```

### 3. Verify

```bash
# Check version
cat VERSION  # Should show current version (5.x.x)

# Check skills installed
ls .claude/skills/*/SKILL.md | wc -l  # Should show 7

# Run health check
/review-context
```

## What Changes

### Commands Renamed

| Old (v4.x) | New (v5.0+) |
|------------|-------------|
| `/save-session` | `/save` |
| `/save-session-full` | `/save-full` |
| `/update-context` | `/update-context-system` |
| `/code-review` | `/code-review` (now with 9 specialist reviewers) |

**Commands that stay the same:**
- `/init-context`
- `/review-context`
- `/validate-context`
- `/export-context`

### New Structure

```
.claude/
├── commands/        # Core commands (md files)
├── skills/          # NEW: Skill definitions for modular execution
│   ├── init/
│   ├── review/
│   ├── save/
│   ├── save-full/
│   ├── validate/
│   ├── export/
│   └── update/
├── agents/          # NEW: Code review agents (9 specialists + orchestrators)
├── hooks/           # NEW: Session automation
├── schemas/         # NEW: JSON validation
└── settings.json    # NEW: Profile config
```

### Configuration

v4.x had 40+ options. v5.0 uses profiles:

| Profile | Description |
|---------|-------------|
| `minimal` | No hooks, quiet output |
| `standard` | Default, balanced |
| `comprehensive` | All features enabled |

## What's Preserved

**All user content is preserved:**
- `context/CONTEXT.md`
- `context/STATUS.md`
- `context/DECISIONS.md`
- `context/SESSIONS.md`

## Rollback

If you need to revert:

```bash
./scripts/rollback.sh
```

This restores your v4.x installation from the backup.

## Troubleshooting

### Skills Not Found

```bash
# Check skills are installed
ls -la .claude/skills/
```

If empty, try re-running `/update-context-system`.

### Context Health Low

```bash
# Run health check
/review-context

# Update Quick Reference
/save
```

### Config Errors

```bash
# Validate config
python3 -m json.tool context/.context-config.json
```

## Breaking Changes

1. **Commands renamed**: Use new skill names
2. **Scripts removed**: Most scripts integrated into skills
3. **Config simplified**: Many options removed
4. **v3.x not supported**: Must upgrade to v4.x first

## Getting Help

- Run `/review` for health check
- Check MIGRATION_SUMMARY.md for specifics
- Report issues: https://github.com/rexkirshner/ai-context-system/issues

## Next Steps

After migration:
1. Run `/review-context` to check health
2. Run `/save` to update Quick Reference
3. Explore new agents with `/code-review`
