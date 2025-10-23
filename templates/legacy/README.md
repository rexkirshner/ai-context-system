# Legacy Templates (v1.x)

These templates are from AI Context System (formerly Claude Context System) v1.9 and earlier. They are kept for reference during migration from v1.x to v2.0.

## Files in This Folder

- **next-steps.template.md** - Replaced by STATUS.md in v2.0
- **todo.template.md** - Merged into STATUS.md in v2.0

## Why These Are Legacy

**v1.x approach:**
- Separate files for status (CLAUDE.md), next steps (next-steps.md), and todos (todo.md)
- Status duplicated across 3 files
- Files drifted out of sync

**v2.0 improvement:**
- Single source of truth: STATUS.md
- All current state information in one place
- No duplication, no drift

## Using These Files

**If you're migrating from v1.x to v2.0:**
1. Read [MIGRATION_GUIDE.md](../../MIGRATION_GUIDE.md) for migration steps
2. Use these templates as reference for what content to extract
3. Merge content from next-steps.md and todo.md into STATUS.md

**If you're starting a new project:**
- Don't use these templates
- Use `/init-context` which creates v2.0 structure

## See Also

- [MIGRATION_GUIDE.md](../../MIGRATION_GUIDE.md) - v1.x → v2.0 migration steps
- [CHANGELOG.md](../../CHANGELOG.md) - What changed in v2.0
- [../STATUS.template.md](../STATUS.template.md) - v2.0 replacement template
