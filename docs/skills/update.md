# /update

Update AI Context System to latest version.

## Usage

```
/update
```

## Description

Safely updates ACS to the latest version with:
- Automatic backup creation
- Checksum verification
- Migration summary generation
- Rollback support

## Process

1. **Pre-flight**: Check current version and prerequisites
2. **Backup**: Create timestamped backup of current state
3. **Download**: Fetch new version with checksum verification
4. **Install**: Update skills, agents, hooks, schemas
5. **Migrate**: Apply any config migrations
6. **Verify**: Confirm all files installed correctly
7. **Document**: Create MIGRATION_SUMMARY.md

## Backup

Creates `.claude-backup-YYYYMMDD-HHMMSS/` containing:
- All `.claude/` contents
- `scripts/` directory
- `templates/` directory
- `VERSION` file

## Rollback

If update fails or you need to revert:

```bash
./scripts/rollback.sh
```

Or specify a backup:

```bash
./scripts/rollback.sh .claude-backup-20260113-100000
```

## Example

```bash
> /update

Checking for updates...
Current: 5.1.0
Latest:  5.1.1

Creating backup: .claude-backup-20260113-100000

Downloading v5.1.1...
  ✓ Checksum verified

Installing...
  ✓ Skills updated
  ✓ Agents updated
  ✓ Schemas updated

Update complete: v5.1.0 → v5.1.1

See MIGRATION_SUMMARY.md for details.
Rollback: ./scripts/rollback.sh
```

## Safety Features

- **Backup First**: Always creates backup before changes
- **Checksums**: Verifies downloaded files match manifest
- **Atomic**: All-or-nothing installation
- **Rollback**: Easy revert if issues found

## See Also

- [MIGRATION_SUMMARY.md](../migration/guide.md) - Migration guide
- [rollback.sh](../../scripts/rollback.sh) - Rollback script
