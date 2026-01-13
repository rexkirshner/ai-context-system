# Migration Guide: v4.x to v5.0

This guide covers migrating from AI Context System v4.x to v5.0.

## Overview

v5.0 is a major redesign that:
- Replaces commands with skills
- Adds agent-based code review
- Simplifies configuration
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
/update
```

### 3. Verify

```bash
# Check version
cat VERSION  # Should show 5.0.0

# Check skills installed
ls .claude/skills/*/SKILL.md | wc -l  # Should show 7

# Run health check
/review
```

## What Changes

### Commands → Skills

| Old (v4.x) | New (v5.0) |
|------------|------------|
| `/init-context` | `/init` |
| `/save-session` | `/save` |
| `/save-session-full` | `/save-full` |
| `/validate-context` | `/validate` |
| `/export-context` | `/export` |
| `/update-context` | `/update` |
| `/code-review` | `code-reviewer` agent |
| `/review-context` | `/review` |

### New Structure

```
.claude/
├── skills/          # NEW: Skill definitions
│   ├── init/
│   ├── review/
│   ├── save/
│   ├── save-full/
│   ├── validate/
│   ├── export/
│   └── update/
├── agents/          # NEW: Code review agents
├── hooks/           # NEW: Session automation
├── schemas/         # NEW: JSON validation
├── settings.json    # NEW: Profile config
└── commands/        # REMOVED
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

If empty, try re-running `/update`.

### Context Health Low

```bash
# Run health check
/review

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
- Report issues: https://github.com/anthropics/claude-code/issues

## Next Steps

After migration:
1. Run `/review` to check health
2. Run `/save` to update Quick Reference
3. Explore new agents with `/code-review`
