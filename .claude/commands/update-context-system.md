---
name: update-context-system
description: Update AI Context System to latest version from GitHub
---

# /update-context-system Command

Update your project's AI Context System to the latest version from GitHub using the automated installer script.

## When to Use This Command

- Periodically (monthly) to get latest improvements
- When new features or bug fixes are released
- Before initializing new projects (get latest templates)

**Run periodically** to stay up to date with improvements.

## What This Command Does

1. Downloads latest installer from GitHub
2. Checks if update is needed (compares versions)
3. Backs up existing installation
4. Updates all slash commands (`.claude/commands/*.md`)
5. Updates scripts (validation, helpers)
6. Updates templates for reference
7. Updates configuration schemas
8. Reports everything that changed

## Important: How to Execute This Command

**CRITICAL:** You MUST use the Bash tool to execute all commands in this file. Do NOT describe the commands to the user - EXECUTE them.

Each bash code block in this file should be run using the Bash tool. This is an automated update process.

**CRITICAL WORKING DIRECTORY RULE:**
- User will run this command FROM the project directory
- Do NOT try to cd into the project directory yourself
- All paths in commands are relative to project root
- If Step 0 fails, tell user to cd to correct directory
- Do NOT attempt complex path escaping with spaces
- Trust that user's current directory is correct when they run the command

## Important: Version Check First

**CRITICAL:** This command compares version numbers. If local version matches GitHub version, the command MUST exit immediately without making ANY changes. Only proceed with updates if GitHub version is newer.

## Execution Steps

### Step 0: Load Shared Functions

**ACTION:** Source the common functions library:

```bash
# Load shared utilities (v2.3.0+)
if [ -f "scripts/common-functions.sh" ]; then
  source scripts/common-functions.sh
else
  echo "⚠️  Warning: common-functions.sh not found (using legacy mode)"
fi
```

**Why this matters:** Provides access to `download_with_retry()` for robust network operations and `get_system_version()` for version checking.

---

### Step 0.5: Verify Working Directory

**CRITICAL:** Ensure we're in the correct project directory before proceeding.

```bash
# Check if context/.context-config.json exists
if [ ! -f "context/.context-config.json" ]; then
  echo ""
  echo "❌ ERROR: Not in correct project directory"
  echo ""
  echo "Current directory: $(pwd)"
  echo ""
  echo "This command must be run from the project root directory that contains:"
  echo "  - context/.context-config.json"
  echo "  - .claude/commands/"
  echo ""
  echo "Common issues:"
  echo "  1. Running from parent folder instead of project folder"
  echo "  2. Running from nested subdirectory"
  echo ""

  # Try to detect if we're in a parent folder
  if [ -d "inevitable-eth/context" ] || [ -d "*/context" ]; then
    echo "💡 Detected project in subdirectory!"
    echo ""
    echo "Try:"
    echo "  cd inevitable-eth  (or whatever your project folder is)"
    echo "  /update-context-system"
  fi

  echo ""
  echo "Cancelled. Please cd to the project directory and try again."
  exit 1
fi

echo "✅ Working directory verified"
echo "Project: $(pwd)"
echo ""
```

### Step 1: Check Current Version

**ACTION:** Use the Bash tool to check the current version using shared function:

```bash
CURRENT_VERSION=$(get_system_version)
log_info "📦 Current version: $CURRENT_VERSION"
log_info "🔍 Checking for updates from GitHub..."
```

### Step 2: Run Installer Script

**ACTION:** Use the Bash tool to download and run the installer:

```bash
# Download the latest installer with retry logic
log_info "Downloading latest installer from GitHub..."
if download_with_retry \
  "https://raw.githubusercontent.com/rexkirshner/claude-context-system/main/install.sh" \
  "/tmp/claude-context-install.sh" \
  3 \
  10; then
  log_success "✅ Installer downloaded"

  # Make it executable
  chmod +x /tmp/claude-context-install.sh

  # Run the installer with --yes flag for non-interactive mode
  /tmp/claude-context-install.sh --yes

  # Clean up
  rm -f /tmp/claude-context-install.sh
else
  show_error $EXIT_NETWORK "Failed to download installer" \
    "Check your internet connection" \
    "Verify GitHub is accessible" \
    "Try again later if GitHub is experiencing issues"
  exit 1
fi
```

The installer will:
- Check if you already have the latest version (and exit if you do)
- Back up your existing installation
- Download all latest files
- Update commands, templates, scripts, and configuration
- Verify the installation
- Report what was updated

**After the installer completes:**
- Review the output to see what was updated
- Installer will show version change (if any)
- Installer will list all updated files

### Step 2.5: Archive Feedback and Create Fresh File

**v2.3.1: Feedback System**

**ACTION:** Archive existing feedback (if has content) and create fresh feedback file:

```bash
log_info ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "  Feedback System (v2.3.1+)"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info ""

# v3.0.0 Migration: Rename old feedback file if it exists
if [ -f "context/claude-context-feedback.md" ] && [ ! -f "context/context-feedback.md" ]; then
  log_info "🔄 Migrating feedback file (v2.x → v3.0)..."

  # Check if old file has actual content
  CONTENT_LINES=$(wc -l < "context/claude-context-feedback.md" | tr -d ' ')

  if [ "$CONTENT_LINES" -gt 10 ]; then
    # Has content - archive it
    CURRENT_VERSION=$(get_system_version)
    ARCHIVE_DATE=$(date +%Y-%m-%d)
    mkdir -p artifacts/feedback

    ARCHIVE_FILE="artifacts/feedback/feedback-v${CURRENT_VERSION}-${ARCHIVE_DATE}.md"
    mv "context/claude-context-feedback.md" "$ARCHIVE_FILE"

    log_success "✅ Archived v2.x feedback to $ARCHIVE_FILE"
    log_info "   (Your old feedback preserved)"
  else
    # Just template - remove it
    rm -f "context/claude-context-feedback.md"
    log_verbose "Removed empty v2.x feedback file"
  fi
fi

# Check if feedback file exists and has actual content (not just template)
if [ -f "context/context-feedback.md" ]; then
  # Count lines in Feedback Entries section (between "## Feedback Entries" and "## Examples")
  # Fresh template has ~7 lines, template with entries has 15+
  CONTENT_LINES=$(awk '/^## Feedback Entries$/,/^## Examples/' \
    context/context-feedback.md | wc -l | tr -d ' ')

  if [ "$CONTENT_LINES" -gt 10 ]; then  # Has actual entries beyond template
    # Get current version for archive filename
    CURRENT_VERSION=$(get_system_version)
    ARCHIVE_DATE=$(date +%Y-%m-%d)

    # Create archive directory if needed
    mkdir -p artifacts/feedback

    # Archive with version and date
    ARCHIVE_FILE="artifacts/feedback/feedback-v${CURRENT_VERSION}-${ARCHIVE_DATE}.md"
    mv context/context-feedback.md "$ARCHIVE_FILE"

    log_success "✅ Archived feedback to $ARCHIVE_FILE"
    log_info "   (Feedback from v${CURRENT_VERSION} preserved)"
  else
    log_verbose "Feedback file exists but appears to be just template (no entries)"
    rm -f context/context-feedback.md
  fi
fi

# Create fresh feedback file from template
if [ ! -f "context/context-feedback.md" ]; then
  if [ -f "templates/context-feedback.template.md" ]; then
    cp templates/context-feedback.template.md context/context-feedback.md
    log_success "✅ Created fresh feedback file"
    log_info ""
    log_info "📝 Please share your upgrade experience:"
    log_info "   - Any issues during update?"
    log_info "   - New features working well?"
    log_info "   - Add feedback to context/context-feedback.md"
  else
    log_warn "⚠️  Template not found - will be created on next /init-context"
  fi
fi

log_info ""
```

**Why this matters:**
- Preserves your previous feedback (archived with version number)
- Gives you fresh file for new feedback
- Tracks what version you were using when you had issues
- Helps identify version-specific problems

---

### Step 3: Check Version and Migration Path

**ACTION:** Check current version to determine if migration is needed:

```bash
log_info ""
CURRENT_VERSION=$(get_system_version)

log_info "📦 Current version: $CURRENT_VERSION"
log_info ""

if [[ "$CURRENT_VERSION" == "2.1.0" ]]; then
  echo "🔄 Migration to v2.2.1 available!"
  echo ""
  echo "✨ v2.2.1 includes organization features + bug fixes:"
  echo "   - Bug fixes: Git push protection, large file handling, subdirectory support"
  echo "   - ORGANIZATION.md guidelines (in reference/ folder)"
  echo "   - /organize-docs command (interactive cleanup wizard)"
  echo "   - Organization validation (0-100 scoring)"
  echo "   - Cleanup reminders (gentle, skippable)"
  echo ""
  echo "Migration time: 5 minutes (automatic) + 10-15 minutes (optional cleanup)"
  echo "Difficulty: Easy (non-breaking, opt-in features)"
  echo ""
  echo "📖 Full migration guide:"
  echo "   reference/MIGRATION_GUIDE_v2.1_to_v2.2.md"
  echo "   https://github.com/rexkirshner/ai-context-system/blob/main/MIGRATION_GUIDE_v2.1_to_v2.2.md"
  echo ""
  echo "🎯 Quick adoption (optional):"
  echo "   1. cp reference/ORGANIZATION.md ./ORGANIZATION.md"
  echo "   2. Add /organize-docs to context/.context-config.json enabled commands"
  echo "   3. Run /validate-context to check organization score"
  echo "   4. Run /organize-docs if score < 90"
  echo ""
elif [[ "$CURRENT_VERSION" == "2.0.0" ]]; then
  echo "🔄 Migration to v2.1.0 available!"
  echo ""
  echo "⚠️  v2.1.0 includes file consolidation:"
  echo "   - QUICK_REF.md merged into STATUS.md (auto-generated section)"
  echo "   - Creates claude.md AI header"
  echo "   - Reduces file count: 6 → 5 files"
  echo "   - Adds automated staleness detection"
  echo ""
  echo "Migration time: 10-15 minutes"
  echo "Difficulty: Easy (mostly automatic)"
  echo ""
  echo "📖 Full migration guide:"
  echo "  https://github.com/rexkirshner/ai-context-system/blob/main/MIGRATION_GUIDE_v2.0_to_v2.1.md"
  echo ""
  echo "Quick migration (copy-paste to terminal):"
  echo "  curl -sL https://raw.githubusercontent.com/rexkirshner/ai-context-system/main/MIGRATION_GUIDE_v2.0_to_v2.1.md | grep -A 100 'Run in terminal:' | bash"
  echo ""
elif [[ "$CURRENT_VERSION" == "1.9.0" ]]; then
  echo "🔄 Migration to v2.0.0 available!"
  echo ""
  echo "⚠️  v2.0.0 includes major file structure changes:"
  echo "   - CLAUDE.md → CONTEXT.md"
  echo "   - Creates STATUS.md (single source of truth)"
  echo "   - Creates DECISIONS.md, SESSIONS.md (structured)"
  echo "   - Auto-generates Quick Reference"
  echo ""
  echo "Migration options:"
  echo "  1. MANUAL: Follow MIGRATION_GUIDE.md (recommended)"
  echo "  2. AUTOMATED: Use migration script (backup first)"
  echo ""
  echo "For manual migration, see:"
  echo "  https://github.com/rexkirshner/ai-context-system/blob/main/MIGRATION_GUIDE.md"
  echo ""
elif [[ "$CURRENT_VERSION" < "1.9.0" ]]; then
  echo "🔄 Multi-step migration required..."
  echo ""
  echo "Your version: $CURRENT_VERSION"
  echo "Latest version: 2.2.1"
  echo ""
  echo "Migration path:"
  echo "  1. Upgrade to v1.9.0 first"
  echo "  2. Then upgrade to v2.0.0"
  echo "  3. Then upgrade to v2.1.0"
  echo "  4. Finally upgrade to v2.2.1"
  echo ""
  echo "Start with:"
  echo "  https://github.com/rexkirshner/ai-context-system/releases"
  echo ""
else
  echo "✅ Already on latest version structure"
fi
```

**About v2.0.0 Migration:**

Automated migration with dry-run, backup, and rollback is planned for v2.1. For now, v2.0.0 migration is manual:

1. Read [MIGRATION_GUIDE.md](https://github.com/rexkirshner/ai-context-system/blob/main/MIGRATION_GUIDE.md)
2. Backup your `context/` folder
3. Follow the step-by-step migration process
4. Verify with `/validate-context`

**Why manual for now?**
- v2.0.0 focuses on getting the new structure right
- Automated migration requires extensive testing (10+ real projects)
- Manual migration ensures you understand changes
- v2.1 will add full automation with safety features

### Step 4: Review Template Updates (Optional)

After the installer completes, you may want to review if any template files have significant updates that should be applied to your context files.

**ACTION:** Check for template changes:

```bash
echo ""
echo "📋 Reviewing template updates..."
echo ""

# Compare templates with your context files (if they exist)
if [ -f "context/CONTEXT.md" ] && [ -f "templates/CONTEXT.template.md" ]; then
  echo "ℹ️  CONTEXT.md template available in templates/"
  echo "   Review templates/CONTEXT.template.md for new sections you might want to add"
fi

if [ -f "context/STATUS.md" ] && [ -f "templates/STATUS.template.md" ]; then
  echo "ℹ️  STATUS.md template available in templates/"
  echo "   Review templates/STATUS.template.md for structural improvements"
fi

if [ -f "context/DECISIONS.md" ] && [ -f "templates/DECISIONS.template.md" ]; then
  echo "ℹ️  DECISIONS.md template available in templates/"
  echo "   Review templates/DECISIONS.template.md for new guidelines"
fi

echo ""
echo "💡 Tip: Compare templates with your context files manually to identify"
echo "   useful additions. Your project-specific content remains untouched."
```

Templates are reference files - you choose what to adopt.

### Step 5: Generate Update Report

Provide a clear summary to the user:

```
✅ AI Context System Updated

## Version
[OLD_VERSION] → [NEW_VERSION]

## What Was Updated

**System Files:**
- Slash commands (.claude/commands/) - v2.0.0 command prompts
- Helper scripts (scripts/) - v1.9.0 automation (v2.0 migration in v2.1)
- Templates (templates/) - v2.0.0 file structure
- Configuration schemas (config/) - v2.0.0 schema

**Your Project Files:**
- Version number in context/.context-config.json
- No changes to your context documentation (CONTEXT.md, STATUS.md, etc.)

## Template Updates Available

Review templates/ directory for new reference content you may want to adopt:
- templates/CONTEXT.template.md
- templates/STATUS.template.md (includes Quick Reference section at top in v2.1)
- templates/DECISIONS.template.md
- templates/SESSIONS.template.md
- templates/CODE_MAP.template.md (optional)

## Next Steps

1. Review template files if desired
2. Run /save-context to document this update
3. Continue working with latest system!

---

📚 Full changelog: https://github.com/rexkirshner/ai-context-system/releases
```

## Important Notes

### What Gets Updated

- ✅ All slash commands (always)
- ✅ Scripts and templates (reference files)
- ✅ Configuration schemas
- ✅ Version number in config
- ❌ Never: Your context documentation (you choose what to update)
- ❌ Never: Project-specific content

### Safety

- Installer creates backups before updating
- Your context files (CONTEXT.md, STATUS.md, etc.) are never touched
- Templates are references - you decide what to adopt
- Can restore from backup if needed: `.claude-backup-[timestamp]/`

### Version Management

- Version stored in `context/.context-config.json`
- Format: `major.minor.patch` (e.g., "1.8.0")
- Check GitHub releases for changelog

## Error Handling

**If GitHub is unreachable:**
```
❌ Cannot reach GitHub
- Check internet connection
- Try again later
- Manual update: download from https://github.com/rexkirshner/ai-context-system
```

**If installer fails:**
```
❌ Installation failed
- Check error output above
- Your original files are backed up in .claude-backup-[timestamp]/
- Restore if needed: cp -r .claude-backup-*/.claude .
```

## Success Criteria

Update succeeds when:
- Installer completes without errors
- All files verified
- Version number updated in config
- Update report generated
- User informed of changes

**Perfect update:**
- System files auto-updated
- Project content untouched
- Clear report of what changed
- Ready to continue work immediately

---

**💬 Feedback**: Any feedback on the update process? (Add to `context/context-feedback.md`)

- Did the update go smoothly?
- Any errors or warnings?
- New features working as expected?
- Was feedback properly archived?

---

**Version:** 3.0.0
**Updated:** v2.3.1 - Added feedback system with archive-on-update
