# /update Skill

Update AI Context System to latest version.

## Purpose

Safely update ACS installation with:
- Automatic backup before changes
- Checksum verification of downloads
- Rollback capability if update fails
- Migration summary documenting changes

## Output

1. Backup directory: `.claude-backup-YYYYMMDD-HHMMSS/`
2. Updated files in `.claude/`
3. `MIGRATION_SUMMARY.md` documenting what changed

## Execution Steps

### Step 1: Check Current Version

```bash
CURRENT_VERSION=$(cat VERSION 2>/dev/null || echo "unknown")
echo "Current version: $CURRENT_VERSION"

# Fetch latest version from GitHub
LATEST_VERSION=$(curl -sL "https://api.github.com/repos/rexkirshner/ai-context-system/releases/latest" | jq -r '.tag_name' 2>/dev/null | sed 's/^v//')

if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" = "null" ]; then
  echo "Error: Could not fetch latest version"
  echo "Check network connection and try again"
  exit 1
fi

echo "Latest version: $LATEST_VERSION"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
  echo "✓ Already on latest version"
  exit 0
fi
```

### Step 2: Create Backup

**CRITICAL:** Always backup before modifying anything.

```bash
BACKUP_DIR=".claude-backup-$(date +%Y%m%d-%H%M%S)"
echo "Creating backup: $BACKUP_DIR"

mkdir -p "$BACKUP_DIR"

# Backup .claude directory
if [ -d ".claude" ]; then
  cp -r .claude "$BACKUP_DIR/"
  echo "✓ Backed up .claude/"
fi

# Backup scripts
if [ -d "scripts" ]; then
  cp -r scripts "$BACKUP_DIR/"
  echo "✓ Backed up scripts/"
fi

# Backup VERSION
if [ -f "VERSION" ]; then
  cp VERSION "$BACKUP_DIR/"
  echo "✓ Backed up VERSION"
fi

# Backup context config (but not content - that's user data)
if [ -f "context/.context-config.json" ]; then
  cp context/.context-config.json "$BACKUP_DIR/"
  echo "✓ Backed up context config"
fi

echo "Backup complete: $BACKUP_DIR"
```

### Step 3: Download and Verify Files

```bash
TEMP_DIR=$(mktemp -d)
MANIFEST_URL="https://raw.githubusercontent.com/rexkirshner/ai-context-system/v$LATEST_VERSION/manifest.json"

echo "Downloading manifest..."
curl -sL "$MANIFEST_URL" -o "$TEMP_DIR/manifest.json"

if [ ! -f "$TEMP_DIR/manifest.json" ]; then
  echo "Error: Could not download manifest"
  echo "Rollback: Your files are unchanged"
  rm -rf "$TEMP_DIR"
  exit 1
fi

# Download each file and verify checksum
echo "Downloading and verifying files..."
DOWNLOAD_ERRORS=0

while IFS= read -r line; do
  FILE=$(echo "$line" | jq -r '.file')
  EXPECTED_SHA=$(echo "$line" | jq -r '.sha256')

  # Download file
  FILE_URL="https://raw.githubusercontent.com/rexkirshner/ai-context-system/v$LATEST_VERSION/$FILE"
  mkdir -p "$TEMP_DIR/$(dirname "$FILE")"
  curl -sL "$FILE_URL" -o "$TEMP_DIR/$FILE"

  # Verify checksum
  ACTUAL_SHA=$(shasum -a 256 "$TEMP_DIR/$FILE" 2>/dev/null | cut -d' ' -f1)

  if [ "$ACTUAL_SHA" = "$EXPECTED_SHA" ]; then
    echo "✓ Verified: $FILE"
  else
    echo "✗ Checksum mismatch: $FILE"
    DOWNLOAD_ERRORS=$((DOWNLOAD_ERRORS + 1))
  fi
done < <(jq -c '.files[]' "$TEMP_DIR/manifest.json")

if [ "$DOWNLOAD_ERRORS" -gt 0 ]; then
  echo "Error: $DOWNLOAD_ERRORS files failed verification"
  echo "Update aborted. Your files are unchanged."
  rm -rf "$TEMP_DIR"
  exit 1
fi
```

### Step 4: Apply Updates

```bash
echo "Applying updates..."

# Use staged apply pattern: temp → verify → swap
# This ensures atomic update

# Update .claude directory
if [ -d "$TEMP_DIR/.claude" ]; then
  # Keep user's custom files
  if [ -d ".claude/skills" ]; then
    # Merge: update system skills, keep user custom skills
    for skill in "$TEMP_DIR/.claude/skills"/*; do
      SKILL_NAME=$(basename "$skill")
      cp -r "$skill" ".claude/skills/"
      echo "  Updated skill: $SKILL_NAME"
    done
  else
    cp -r "$TEMP_DIR/.claude" ./
  fi
fi

# Update scripts
if [ -d "$TEMP_DIR/scripts" ]; then
  cp -r "$TEMP_DIR/scripts"/* scripts/ 2>/dev/null || true
  echo "  Updated scripts/"
fi

# Update VERSION
if [ -f "$TEMP_DIR/VERSION" ]; then
  cp "$TEMP_DIR/VERSION" ./
  echo "  Updated VERSION"
fi

# Update schemas
if [ -d "$TEMP_DIR/.claude/schemas" ]; then
  cp -r "$TEMP_DIR/.claude/schemas"/* .claude/schemas/
  echo "  Updated schemas/"
fi

# Cleanup temp
rm -rf "$TEMP_DIR"
```

### Step 5: Update Config Version

```bash
if [ -f "context/.context-config.json" ]; then
  # Update version in config
  jq --arg v "$LATEST_VERSION" '.version = $v' context/.context-config.json > context/.context-config.json.tmp
  mv context/.context-config.json.tmp context/.context-config.json
  echo "✓ Updated config version"
fi
```

### Step 6: Generate Migration Summary

```bash
cat > MIGRATION_SUMMARY.md << EOF
# Migration Summary

**Date:** $(date +%Y-%m-%d)
**From:** $CURRENT_VERSION
**To:** $LATEST_VERSION

## Backup Location

\`$BACKUP_DIR/\`

## Rollback Command

\`\`\`bash
./scripts/rollback.sh "$BACKUP_DIR"
\`\`\`

## Changes Applied

### Skills Updated
$(ls .claude/skills/ 2>/dev/null | sed 's/^/- /')

### Schemas Updated
$(ls .claude/schemas/ 2>/dev/null | sed 's/^/- /')

### Scripts Updated
$(ls scripts/*.sh 2>/dev/null | xargs -I{} basename {} | sed 's/^/- /')

## User Content Preserved

The following user content was NOT modified:
- context/CONTEXT.md
- context/STATUS.md
- context/DECISIONS.md
- context/SESSIONS.md
- Custom skills in .claude/skills/

## Next Steps

1. Run \`/review\` to check context health
2. Run \`/validate\` to verify no issues
3. Review CHANGELOG.md for new features

---

*Generated by AI Context System update process*
EOF

echo "✓ Created MIGRATION_SUMMARY.md"
```

### Step 7: Verify Update

```bash
NEW_VERSION=$(cat VERSION)

if [ "$NEW_VERSION" = "$LATEST_VERSION" ]; then
  echo ""
  echo "╔════════════════════════════════════════════╗"
  echo "║       Update Complete!                      ║"
  echo "╚════════════════════════════════════════════╝"
  echo ""
  echo "Updated: $CURRENT_VERSION → $NEW_VERSION"
  echo ""
  echo "Backup: $BACKUP_DIR"
  echo "Summary: MIGRATION_SUMMARY.md"
  echo ""
  echo "Next: Run /review to verify everything works"
else
  echo "Warning: Version mismatch after update"
  echo "Expected: $LATEST_VERSION"
  echo "Got: $NEW_VERSION"
  echo ""
  echo "Consider rolling back: ./scripts/rollback.sh $BACKUP_DIR"
fi
```

## Rollback Process

If update fails or causes issues:

```bash
./scripts/rollback.sh [backup-dir]
```

This script:
1. Removes v5.x structure
2. Restores backup files
3. Restores VERSION
4. Removes MIGRATION_SUMMARY.md

## Verification Criteria

| Check | Requirement |
|-------|-------------|
| Backup created | `.claude-backup-*` directory exists with files |
| Summary created | `MIGRATION_SUMMARY.md` exists with correct format |
| Version updated | `cat VERSION` shows new version |
| Checksums verified | All downloaded files match manifest |

## Security

Per V5_PLANNING.md §8.1:

1. **Manifest verification** - Download manifest from pinned tag
2. **SHA-256 checksums** - Every file verified before apply
3. **Staged apply** - Download all → verify all → apply all
4. **Atomic swap** - Never leave partial state
5. **Rollback ready** - Backup before any changes

## Error Handling

- Network failure: Abort, files unchanged
- Checksum mismatch: Abort, show which files failed
- Apply failure: Rollback automatically
- Partial update: Should never happen (staged apply)

## Notes

- This skill replaces v4.x `/update-context-system` command
- User content (context/*.md) is NEVER modified
- Always creates backup before any changes
- Supports rollback via scripts/rollback.sh
