# Migration Guide: v2.1 → v2.2

**Target Audience:** Projects currently using Claude Context System v2.1
**Migration Time:** 5 minutes (automatic) + 10-15 minutes (optional cleanup)
**Difficulty:** Easy (non-breaking, opt-in features)

---

## What's New in v2.2

### v2.2.0 - Critical Bug Fixes

**Philosophy:** "Fix what's broken, keep what works, defer what's risky"

**Fixed:**
- **Git push protection enforcement** - PUSH_APPROVED flag now blocks unauthorized pushes
- **Large SESSIONS.md handling** - Smart loading for files >1000 lines
- **Context folder detection** - Find context/ from subdirectories (up to 2 parent dirs)

**Added:**
- **Deprecation infrastructure** (DEPRECATIONS.md, removal timelines)
- **v2.3.0 removal plan** (/save-context scheduled for removal)

See [CHANGELOG.md](./CHANGELOG.md#220---2025-10-20) for details.

### v2.2.1 - Organization & Structural Neatness

**Philosophy:** "A place for everything, everything in its place"

**Added:**
- **ORGANIZATION.md** - Comprehensive project organization guidelines
- **/organize-docs** - Interactive documentation cleanup wizard
- **Organization validation** - 0-100 scoring in /validate-context
- **Cleanup reminders** - Gentle prompts in /save-full

**Benefits:**
- Reduces cognitive load (know where to find things)
- Professional appearance (clean repositories)
- Better handoffs (clear structure)
- Prevents technical debt (clutter prevention)

See [CHANGELOG.md](./CHANGELOG.md#221---2025-10-20) for details.

---

## Breaking Changes

**None!** v2.2 is 100% backward compatible with v2.1.

All new features are:
- **Automatic** (bug fixes apply when commands run)
- **Opt-in** (organization features available but not required)
- **Non-intrusive** (existing workflows unchanged)

---

## Migration Steps

### Step 1: Update the System

**Run the update command:**

```bash
/update-context-system
```

This will:
- Update all slash commands to v2.2.1
- Download ORGANIZATION.md to `reference/` folder
- Download this migration guide to `reference/`
- Update templates and scripts
- Preserve all your context files

**Time:** 1-2 minutes

---

### Step 2: Adopt Organization Features (Optional)

Organization features are **opt-in**. Adopt them at your own pace.

#### 2a. Add ORGANIZATION.md Guidelines (Recommended)

**Copy the guidelines to your project root:**

```bash
cp reference/ORGANIZATION.md ./ORGANIZATION.md
```

**What it provides:**
- Clear folder structure philosophy
- Naming conventions for historical files
- Maintenance schedule (daily/weekly/monthly)
- Anti-patterns to avoid

**When to do this:**
- Immediately (if you value organization)
- After trying /organize-docs
- When your project feels cluttered

#### 2b. Enable /organize-docs Command (Recommended)

**Add to your config** (`context/.context-config.json`):

```json
{
  "commands": {
    "enabled": [
      "/init-context",
      "/migrate-context",
      "/save",
      "/save-full",
      "/review-context",
      "/code-review",
      "/validate-context",
      "/export-context",
      "/update-context-system",
      "/update-templates",
      "/add-ai-header",
      "/session-summary",
      "/organize-docs"  // ← ADD THIS
    ]
  }
}
```

**What it provides:**
- Interactive cleanup wizard
- Smart file categorization
- Guided filing into organized folders
- Summary of organization actions

**When to do this:**
- When you have loose documentation files
- Before major releases
- Monthly maintenance

#### 2c. Run Organization Cleanup (Optional)

**If your project has accumulated clutter:**

```bash
# 1. Check organization score
/validate-context

# 2. If score < 90, run cleanup wizard
/organize-docs
```

The wizard will:
1. Scan for loose .md files in root and source directories
2. Analyze content and suggest categorization
3. Create organized folder structure (docs/, artifacts/)
4. Guide you through filing each document
5. Provide summary of actions

**Time:** 10-15 minutes (first time), 5 minutes (monthly maintenance)

---

### Step 3: Review Organization Score

**Check your current organization:**

```bash
/validate-context
```

Look for the **Organization Validation (Step 2.8)** section:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  STEP 2.8: FILE ORGANIZATION VALIDATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Organization score: 85/100

⚠️  Documentation sprawl detected: 3 loose file(s) in root
```

**Scoring:**
- 100: Perfect (only essential files in root)
- 90-99: Excellent (minor cleanup recommended)
- 75-89: Good (some reorganization suggested)
- 60-74: Fair (needs attention)
- <60: Poor (run /organize-docs)

---

## Folder Structure Philosophy

v2.2.1 promotes this organization:

```
project-root/
├── README.md                   # Root: Only essentials
├── LICENSE.md
├── SECURITY.md (optional)
├── CONTRIBUTING.md (optional)
├── CHANGELOG.md (optional)
├── ORGANIZATION.md (optional, v2.2.1+)
│
├── context/                    # Active: 5 core files
│   ├── claude.md (or other AI header)
│   ├── CONTEXT.md
│   ├── STATUS.md
│   ├── SESSIONS.md
│   ├── DECISIONS.md
│   └── .context-config.json
│
├── docs/                       # Permanent: Topic-organized
│   ├── setup/
│   ├── development/
│   ├── architecture/
│   └── api/
│
├── artifacts/                  # Historical: Dated work
│   ├── milestones/
│   ├── planning/
│   ├── reviews/
│   └── research/
│
└── [source code directories]
```

**Rules:**
- **Root:** Only essential files (≤ 6 .md files)
- **context/:** Active context system only
- **docs/:** Permanent documentation (organized by topic)
- **artifacts/:** Historical work (dated: YYYY-MM-DD-description.md)
- **Source dirs:** Code only, no documentation

See [ORGANIZATION.md](./ORGANIZATION.md) for full guidelines.

---

## What Happens Automatically

After running `/update-context-system`, these features work automatically:

### Bug Fixes (v2.2.0)

✅ **Git push protection** - /save-full enforces PUSH_APPROVED flag
✅ **Large file handling** - /review-context uses smart loading
✅ **Subdirectory support** - Commands find context/ from nested dirs

### Organization Features (v2.2.1)

✅ **Organization scoring** - /validate-context shows organization score
✅ **Cleanup reminders** - /save-full prompts when loose files > 2 (skippable)
✅ **Smart validation** - Scans for misplaced documentation

**No action required** - These features work immediately.

---

## What Requires Opt-In

These features are available but not mandatory:

❏ **ORGANIZATION.md** - Copy from reference/ to root when ready
❏ **/organize-docs** - Add to config when you want cleanup wizard
❏ **Organization cleanup** - Run /organize-docs monthly for maintenance

**Recommendation:** Adopt organization features if your project:
- Has >5 .md files in root directory
- Has documentation in source directories
- Feels cluttered or hard to navigate
- Will be handed off to others

---

## Rollback (If Needed)

v2.2 is backward compatible, but if you need to rollback:

```bash
# 1. Restore from backup
cp -r .claude-backup-YYYYMMDD-HHMMSS/.claude .
cp -r .claude-backup-YYYYMMDD-HHMMSS/scripts .

# 2. Update version in config
# Edit context/.context-config.json:
# Change "version": "2.2.1" back to "version": "2.1.0"
```

**Note:** Rollback is rarely needed since v2.2 doesn't break anything.

---

## Verification

After migration, verify everything works:

```bash
# 1. Check version
grep '"version"' context/.context-config.json
# Should show: "2.2.1"

# 2. Run validation
/validate-context
# Should pass all checks

# 3. Test commands
/save
# Should complete successfully

# 4. Check organization score
/validate-context
# Look for "Organization score: XX/100"
```

✅ All checks pass? You're successfully migrated to v2.2!

---

## FAQs

### Q: Do I have to reorganize my project?

**A:** No! Organization features are **opt-in**. Your project works fine as-is. Adopt organization features when they provide value to you.

### Q: Will /save-full always nag me about organization?

**A:** No. Cleanup reminders only show when you have >2 loose files in root, and you can easily skip them by saying "skip organization".

### Q: What if I don't want ORGANIZATION.md in my root?

**A:** That's fine! Keep it in `reference/` for your own reference. The organization features work without it.

### Q: Will /save-context be removed?

**A:** Yes, in v2.3.0 (approximately 3 months from v2.2.0 release). Use `/save` (quick) or `/save-full` (comprehensive) instead. See [DEPRECATIONS.md](./DEPRECATIONS.md) for timeline.

### Q: Do I need to update my config manually?

**A:** Only if you want /organize-docs in your slash command list. The command works without being in the list, but won't show up in autocomplete.

### Q: What if migration fails?

**A:**
1. Check `.claude-backup-*` folders for backups
2. Report issue at: https://github.com/rexkirshner/claude-context-system/issues
3. Restore from backup if needed

---

## Summary

**v2.2 Migration:**
- ✅ Automatic bug fixes (no action required)
- ✅ Opt-in organization features (adopt when ready)
- ✅ 100% backward compatible
- ✅ Non-breaking changes
- ⏱️ 5 minutes automatic + 10-15 minutes optional cleanup

**Recommended Actions:**
1. Run `/update-context-system` (required)
2. Copy `ORGANIZATION.md` to root (recommended)
3. Add `/organize-docs` to config (recommended)
4. Run `/organize-docs` if cluttered (optional)
5. Adopt maintenance schedule (optional)

**Resources:**
- [CHANGELOG.md](./CHANGELOG.md) - Full release notes
- [ORGANIZATION.md](./ORGANIZATION.md) - Organization guidelines
- [DEPRECATIONS.md](./DEPRECATIONS.md) - Removal timelines

---

**Questions?** Open an issue: https://github.com/rexkirshner/claude-context-system/issues

**Version:** 2.2.1
**Last Updated:** 2025-10-20
