# Migration Guide

**Claude Context System Migration Guide**

---

## Latest: v1.9.0 → v2.0.0

**Current version: v2.0.0**

### Migration Status

**Automated Migration:** Planned for v2.1 (dry-run, backup, rollback)
**Current (v2.0):** Manual migration (follow steps below)

### Quick Migration (Manual Process)

**Step 1:** Update system files
```bash
/update-context-system
# This updates templates and commands to v2.0.0
```

**Step 2:** Backup your context
```bash
cp -r context/ context-backup-$(date +%Y%m%d)/
```

**Step 3:** Manual file migration
```bash
# Rename CLAUDE.md → CONTEXT.md
mv context/CLAUDE.md context/CONTEXT.md

# Extract current status from CONTEXT.md into new STATUS.md
# (Use STATUS.template.md as guide)

# Create DECISIONS.md from template
cp templates/DECISIONS.template.md context/DECISIONS.md

# Create QUICK_REF.md from template
cp templates/QUICK_REF.template.md context/QUICK_REF.md

# Update .context-config.json version to 2.0.0
# Add counters and metrics sections (see config template)
```

**Step 4:** Verify migration
```bash
/validate-context
```

**Why Manual?**
- v2.0.0 focuses on getting the new structure right
- Automated migration requires testing on 10+ real projects
- Manual ensures you understand the changes
- v2.1 will add full automation with safety features

### What Changed in v2.0.0

**File Structure:**
```
Old (v1.9.0):              New (v2.0.0):
- CLAUDE.md          →     - CONTEXT.md
- next-steps.md      →     - STATUS.md (single source)
- todo.md            →     - (optional - merge to STATUS.md)
- SESSIONS.md        →     - SESSIONS.md (structured format)
                     →     - QUICK_REF.md (auto-generated)
                     →     - DECISIONS.md (always created)
```

**Key Improvements (v2.0):**
1. **Status duplication eliminated** - STATUS.md is single source of truth
2. **All promised files created** - No more missing QUICK_REF.md or SESSIONS.md
3. **SESSIONS.md scannable** - Structured format with Changed/Decisions/Files sections
4. **Two-tier workflow** - `/save` (2-3 min quick) vs `/save-full` (10-15 min comprehensive)

**Planned for v2.1:**
- Migration safety (dry-run, automatic backups, rollback)
- Progress auto-calculation from STATUS.md checkboxes
- Decision ID auto-increment

**See:** [CHANGELOG.md](./CHANGELOG.md) for complete v2.0.0 changes

---

## Previous: v1.7.0/v1.8.0 → v1.9.0

**Note:** If you're on v1.7 or v1.8, upgrade to v1.9 first, then to v2.0.

This guide helps you upgrade from v1.7.0 or v1.8.0 to v1.9.0 with the two-tier workflow.

---

## What Changed in v1.9.0

### The Core Problem We Solved

**Real-world AI agent feedback** identified a critical issue:
> "How often do you actually lose context vs. how often do you update docs?"

**The Frequency Mismatch:**
- Update docs: **20× per project** (every session)
- Recover context: **3-4× per project** (occasional breaks)
- Overhead/benefit ratio: **5:1** (unfavorable)
- Result: **Negative ROI** - pay 100-200 min, save 12-20 min

### The Solution: Two-Tier Workflow

**v1.9.0 introduces a two-tier approach:**

| Tier | Command | Time | When to Use | Frequency |
|------|---------|------|-------------|-----------|
| Quick | `/save` | 2-3 min | Most sessions | 17× per 20 sessions |
| Comprehensive | `/save-full` | 10-15 min | Before breaks/handoffs | 3-5× per 20 sessions |

**Expected Impact:**
- **v1.8.0 overhead:** 100-200 minutes per 20 sessions
- **v1.9.0 overhead:** 70-95 minutes per 20 sessions
- **Savings:** 50-60% reduction in overhead

**Philosophy Shift:**
```
v1.8.0: Comprehensive documentation every session
v1.9.0: Minimal continuous updates + comprehensive on-demand
```

---

## Breaking Changes

### Command Rename

**`/save-context` → `/save-full`**

The old `/save-context` command has been **renamed to `/save-full`** to clarify its purpose:
- Use for **comprehensive documentation** before breaks/handoffs
- Takes 10-15 minutes
- Creates detailed SESSIONS.md entry with mental models

**New `/save` command:**
- Use for **quick updates** during continuous work
- Takes 2-3 minutes
- Updates STATUS.md and QUICK_REF.md

**Migration:** Your existing `/save-context` calls will need to be updated to either `/save` or `/save-full` depending on your intent.

### Workflow Changes

**Old workflow (v1.8.0):**
```bash
# Every session
/save-context  # 5-10 minutes every time
```

**New workflow (v1.9.0):**
```bash
# Most sessions (quick)
/save          # 2-3 minutes

# Occasional (comprehensive)
/save-full     # 10-15 minutes before breaks/handoffs
```

---

## Upgrade Instructions

### Automatic Upgrade (Recommended)

**If you already have v1.7.0 or v1.8.0 installed:**

1. **Navigate to your project directory:**
   ```bash
   cd /path/to/your/project
   ```

2. **Run the update command:**
   ```bash
   /update-context-system
   ```

3. **The installer will automatically:**
   - Download latest version from GitHub
   - Check if you need an update
   - Back up your existing installation
   - Update all slash commands
   - Run migration script (`scripts/migrate-to-1-9-0.sh`)
   - Clean up legacy files
   - Update configuration version

4. **Review the output** to see what was updated

**That's it!** The migration script handles everything automatically.

---

## What the Migration Script Does

The `scripts/migrate-to-1-9-0.sh` script performs these actions:

### 1. Detects Current Version

```bash
Current version: 1.8.0
Target version: 1.9.0
Upgrade path: 1.8.0 → 1.9.0
```

### 2. Cleans Up Legacy System Files (SAFE)

**Files removed automatically:**
- `.claude/commands/init-context-full.md` (obsolete in v1.8.0)
- `.claude/commands/quick-save-context.md` (obsolete in v1.8.0)
- `.claude/commands/save-context.md` (renamed to save-full.md)
- `templates/CLAUDE.template.md` (replaced by CONTEXT.template.md)

**Important:** These are **system files only** - your project documentation is never touched.

### 3. Renames Commands

```bash
save-context.md → save-full.md
```

### 4. Suggests User Content Updates (OPTIONAL)

The script **suggests** but does **not** automatically apply these:

**If you have `CLAUDE.md`:**
```bash
📝 Recommendation: Rename CLAUDE.md → CONTEXT.md
   Your content is preserved, just the filename changed in v1.8.0
   Run: mv context/CLAUDE.md context/CONTEXT.md
```

**If you have `tasks/` directory:**
```bash
📝 Recommendation: Consolidate tasks/ directory into STATUS.md
   v1.8.0+ uses STATUS.md as single source for current tasks
   Your tasks/next-steps.md content should move to STATUS.md
```

**If your SESSIONS.md uses old format:**
```bash
📝 Recommendation: Update SESSIONS.md to structured format
   v1.8.0+ uses structured sections (Changed, Problem Solved, Mental Models)
   See: templates/SESSIONS.template.md for examples
```

### 5. Updates Configuration Version

```bash
context/.context-config.json: "version": "1.7.0" → "version": "1.9.0"
```

---

## Manual Upgrade (If Needed)

**If automatic upgrade fails or you prefer manual control:**

### Step 1: Backup Your Current Installation

```bash
# From your project root
cp -r .claude .claude-backup-$(date +%Y%m%d-%H%M%S)
cp -r context context-backup-$(date +%Y%m%d-%H%M%S)
```

### Step 2: Download v1.9.0

```bash
# Clone or download from GitHub
git clone https://github.com/rexkirshner/claude-context-system.git

# Or download specific version
curl -L https://github.com/rexkirshner/claude-context-system/archive/v1.9.0.tar.gz | tar xz
```

### Step 3: Update System Files

```bash
# Copy new commands
cp -r claude-context-system/.claude/commands/* .claude/commands/

# Copy new scripts
cp -r claude-context-system/scripts/* scripts/

# Copy new templates
cp -r claude-context-system/templates/* templates/
```

### Step 4: Run Migration Script

```bash
./scripts/migrate-to-1-9-0.sh
```

### Step 5: Clean Up

```bash
rm -rf claude-context-system
```

---

## Post-Migration Checklist

After upgrading, verify everything is working:

- [ ] **Check version:**
  ```bash
  grep '"version"' context/.context-config.json
  # Should show: "version": "1.9.0"
  ```

- [ ] **Verify new commands exist:**
  ```bash
  ls .claude/commands/
  # Should include: save.md, save-full.md
  # Should NOT include: save-context.md
  ```

- [ ] **Test quick save:**
  ```bash
  /save
  # Should complete in 2-3 minutes
  ```

- [ ] **Test comprehensive save:**
  ```bash
  /save-full
  # Should complete in 10-15 minutes, create SESSIONS.md entry
  ```

- [ ] **Review context files:**
  ```bash
  ls context/
  # Should show: CONTEXT.md (or CLAUDE.md), STATUS.md, DECISIONS.md, etc.
  ```

---

## Recommended User Content Updates

These are **optional** but **recommended** for full v1.9.0 compatibility:

### 1. Rename CLAUDE.md → CONTEXT.md

**If you're on v1.7.0 or earlier:**

```bash
mv context/CLAUDE.md context/CONTEXT.md
```

**Why:** v1.8.0+ uses CONTEXT.md as the standard filename. The content is the same, just the name changed for clarity.

### 2. Consolidate tasks/ Directory

**If you have `context/tasks/` folder:**

```bash
# 1. Read current tasks
cat context/tasks/next-steps.md
cat context/tasks/todo.md

# 2. Add them to STATUS.md under "## Current Tasks"

# 3. Archive or remove tasks/ folder
mv context/tasks context/tasks-archived
```

**Why:** v1.8.0+ uses STATUS.md as the single source of truth for current state. No duplication.

### 3. Update SESSIONS.md Format

**If your SESSIONS.md entries are prose-style:**

See `templates/SESSIONS.template.md` for the new structured format:

```markdown
## [2025-10-06] Description of Session

### Changed
- What was modified/added/removed

### Problem Solved
- Issue and how we solved it

### Mental Models
- Current thinking, approach, next steps

### Files
- List of files changed

### WIP
- Work in progress
```

**Why:** Structured format is easier to scan and provides depth for AI agents.

---

## New Workflow: Daily Usage

### Most Sessions (Quick Update)

```bash
# At end of session or when switching tasks
/save
```

**Takes:** 2-3 minutes

**Updates:**
- STATUS.md (current tasks, blockers, next steps)
- QUICK_REF.md (auto-generated dashboard)

**Use for:**
- End of work session
- Switching tasks
- Quick check-in points

### Occasional (Comprehensive Documentation)

```bash
# Before breaks, handoffs, or milestones
/save-full
```

**Takes:** 10-15 minutes

**Updates:**
- Everything `/save` does
- PLUS: Creates detailed SESSIONS.md entry
- PLUS: Documents mental models and decision rationale

**Use for:**
- Taking break >1 week
- Handing off to another agent/developer
- Major milestone completed
- Want detailed session history entry

**Frequency:** ~3-5 times per 20 sessions

---

## Troubleshooting

### "Command not found: /save"

**Cause:** Update didn't complete or commands not in correct location

**Fix:**
```bash
# Verify .claude/commands exists
ls .claude/commands/

# If missing save.md, re-run update
/update-context-system
```

### "Migration script not found"

**Cause:** Scripts directory not updated

**Fix:**
```bash
# Check if script exists
ls scripts/migrate-to-1-9-0.sh

# If missing, copy from repo
cp claude-context-system/scripts/migrate-to-1-9-0.sh scripts/
chmod +x scripts/migrate-to-1-9-0.sh
./scripts/migrate-to-1-9-0.sh
```

### "Already on v1.9.0" but commands are old

**Cause:** Version was updated but files weren't

**Fix:**
```bash
# Force re-download of commands
rm -rf .claude/commands/*
/update-context-system
```

### Want to roll back to v1.8.0

**If you backed up before upgrading:**

```bash
# Restore from backup
rm -rf .claude
cp -r .claude-backup-TIMESTAMP .claude

# Restore context if needed
rm -rf context
cp -r context-backup-TIMESTAMP context
```

**If you didn't back up:**

```bash
# Clone v1.8.0 from GitHub
git clone --branch v1.8.0 https://github.com/rexkirshner/claude-context-system.git
cp -r claude-context-system/.claude .
rm -rf claude-context-system
```

---

## What Gets Updated vs. Preserved

### System Files (Auto-Updated)

✅ **Updated automatically:**
- `.claude/commands/*.md` (all slash commands)
- `scripts/*.sh` (helper scripts)
- `templates/*.md` (reference templates)
- `context/.context-config.json` (version number only)

### User Content (Never Touched)

❌ **Never modified automatically:**
- `context/CONTEXT.md` (or CLAUDE.md)
- `context/STATUS.md`
- `context/DECISIONS.md`
- `context/SESSIONS.md`
- `context/PRD.md`
- `context/ARCHITECTURE.md`
- Any other custom documentation

**Your project documentation is sacred** - only system files are updated.

---

## FAQ

### Do I need to update my existing projects?

**Yes, if you want:**
- Faster workflow (50-60% less overhead)
- Two-tier save system
- Latest bug fixes and improvements

**No, if:**
- v1.7.0 or v1.8.0 is working fine for you
- You don't mind the extra overhead

### Will this break my current workflow?

**Minor adjustments needed:**
- Use `/save` for quick updates (new habit)
- Use `/save-full` before breaks (old `/save-context` behavior)

**Everything else stays the same** - same documentation files, same structure.

### Can I still use `/save-context`?

**No** - the command was renamed to `/save-full`.

**Why?** To clarify the distinction:
- `/save` = quick (2-3 min)
- `/save-full` = comprehensive (10-15 min)

### How often should I use `/save` vs. `/save-full`?

**Recommended frequency for 20-session project:**
- `/save`: 17 times (most sessions)
- `/save-full`: 3-5 times (before breaks/handoffs)

**Use `/save-full` when:**
- Taking break >1 week
- Handing off to someone else
- Major milestone reached
- Want comprehensive history entry

### What if I have multiple projects?

**Update each project independently:**

```bash
cd project-1
/update-context-system

cd ../project-2
/update-context-system
```

Each project maintains its own version.

### Can I upgrade from v1.6.0 or earlier?

**Yes**, but you'll also get v1.7.0 and v1.8.0 changes:

**v1.7.0:**
- Progressive enhancement (3 core files vs. 8 files)
- Minimal start, grow naturally

**v1.8.0:**
- Dual purpose (session continuity + AI agent review)
- DECISIONS.md added back
- Structured SESSIONS.md format

**v1.9.0:**
- Two-tier workflow

The migration script handles all versions gracefully.

---

## Support

**Issues or Questions?**
- Check: [SETUP_GUIDE.md](./SETUP_GUIDE.md)
- Read: [README.md](./README.md)
- Review: [PRD.md](./PRD.md)
- GitHub: https://github.com/rexkirshner/claude-context-system

**Backup Everything** before major changes!

---

## Summary

**v1.9.0 in one sentence:**
> Same powerful context preservation, 50-60% less overhead through two-tier workflow.

**To upgrade:**
```bash
/update-context-system
```

**New daily workflow:**
```bash
/save          # Quick update (most sessions)
/save-full     # Comprehensive (before breaks)
```

**That's it!** Enjoy faster, more efficient context management.

---

📚 **Full changelog:** [CHANGELOG.md](./CHANGELOG.md)
