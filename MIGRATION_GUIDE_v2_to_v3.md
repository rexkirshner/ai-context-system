# Migration Guide: v2.x → v3.0.0

**AI Context System** (formerly Claude Context System)

**Target Audience:** Existing users of Claude Context System v2.x

**Time Required:** 5-10 minutes

**Data Loss Risk:** Zero (all content preserved and archived)

---

## Quick Start (TL;DR)

```bash
# 1. Update your local clone (if applicable)
git remote set-url origin https://github.com/rexkirshner/ai-context-system.git
git fetch

# 2. Run update command in your project
/update-context-system

# 3. Done! ✅
```

**That's it.** Everything else is automatic.

---

## What Changed in v3.0.0?

### System Name
- **Old**: Claude Context System
- **New**: AI Context System
- **Why**: Reflects multi-AI support (Claude, Cursor, Aider, Codex, and more)

### Feedback File
- **Old**: `claude-context-feedback.md`
- **New**: `context-feedback.md`
- **Why**: System-focused, not tool-specific

### Repository URL
- **Old**: `github.com/rexkirshner/claude-context-system`
- **New**: `github.com/rexkirshner/ai-context-system`
- **Impact**: GitHub auto-redirects, no action needed

### Version
- **2.3.2** → **3.0.0** (major version bump)

---

## What DIDN'T Change?

### ✅ Your Tool-Specific Files (Unchanged by Design)

**You do NOT need to rename these files:**

- `claude.md` ← Stays as-is (it's Claude's entry point, not the system's)
- `cursor.md` ← Stays as-is (Cursor's entry point)
- `aider.md` ← Stays as-is (Aider's entry point)
- `codex.md` ← Stays as-is (Codex's entry point)

**Why?** These files are named after the **AI tool**, not the system. Think of it like `package.json` - having that file doesn't make your project npm-only.

### ✅ Your Universal Context Files (Unchanged)

- `CONTEXT.md`
- `STATUS.md`
- `DECISIONS.md`
- `SESSIONS.md`
- `CODE_MAP.md` (if you have one)

All your content, decisions, and history stay exactly as-is.

---

## Migration Steps

### Step 1: Update Your Local Clone (Optional)

**Only if you cloned the repo directly** (not via `/update-context-system`):

```bash
cd /path/to/your/project

# Update remote URL
git remote set-url origin https://github.com/rexkirshner/ai-context-system.git

# Fetch latest
git fetch

# Verify
git remote -v
```

**Output should show:**
```
origin  https://github.com/rexkirshner/ai-context-system.git (fetch)
origin  https://github.com/rexkirshner/ai-context-system.git (push)
```

**If you installed via curl/wget:** No action needed - `/update-context-system` handles everything.

---

### Step 2: Run Update Command

```bash
/update-context-system
```

**What it does:**

1. **Downloads v3.0.0** templates and commands
2. **Migrates feedback file**:
   - Checks if `claude-context-feedback.md` has content (>10 lines)
   - If yes: Archives to `artifacts/feedback/feedback-v2.3.2-{date}.md`
   - Creates new `context-feedback.md` from v3.0.0 template
3. **Updates VERSION** to 3.0.0
4. **Preserves all your content** - zero data loss

**Expected output:**
```
🔄 Updating AI Context System...

✅ Downloaded v3.0.0 templates
✅ Migrated feedback file (archived to artifacts/feedback/feedback-v2.3.2-2025-10-21.md)
✅ Created context/context-feedback.md
✅ Updated VERSION to 3.0.0

✅ Update complete! You're now on v3.0.0.
```

---

### Step 3: Verify Migration

```bash
# Check version
cat VERSION
# Should show: 3.0.0

# Check feedback file
ls -la context/
# Should show: context-feedback.md (new)

# Check archived feedback (if you had content)
ls -la artifacts/feedback/
# Should show: feedback-v2.3.2-{date}.md (your old content)

# Verify claude.md unchanged
ls -la context/claude.md
# Should still exist - DO NOT rename this!
```

**Expected state:**
```
context/
├── claude.md                  ← Unchanged (correct!)
├── CONTEXT.md                 ← Unchanged
├── STATUS.md                  ← Unchanged
├── DECISIONS.md               ← Unchanged
├── SESSIONS.md                ← Unchanged
└── context-feedback.md        ← NEW (was claude-context-feedback.md)

artifacts/feedback/
└── feedback-v2.3.2-2025-10-21.md  ← Your old feedback (archived)
```

---

## Common Questions

### Q: Why does my `claude.md` file still exist?

**A:** Because it's **correct**! `claude.md` is Claude's entry point to the system, just like `cursor.md` is Cursor's entry point. The **system** is now called "AI Context System", but the **tool integration files** are still named after their respective tools.

**Analogy:** Having `package.json` doesn't make your project npm-only. You can also use yarn, pnpm, bun. Same here.

### Q: Do I need to update my `claude.md` file?

**A:** NO! Keep it exactly as-is. It's already correct.

### Q: What happens to my feedback?

**A:** It's archived safely:
1. `/update-context-system` checks if your `claude-context-feedback.md` has content
2. If yes, it's archived to `artifacts/feedback/feedback-v2.3.2-{date}.md`
3. A fresh `context-feedback.md` is created from the v3.0.0 template
4. You can still access your old feedback in `artifacts/`

**No data is lost.**

### Q: Will old repository URLs still work?

**A:** YES! GitHub automatically redirects:
- `github.com/rexkirshner/claude-context-system` → `github.com/rexkirshner/ai-context-system`
- All old links, bookmarks, and clones continue working

### Q: What if I have conflicts?

**A:** Very unlikely. The migration only touches:
- Feedback file (archived if has content)
- VERSION file (updated to 3.0.0)
- Templates (refreshed from repo)

Your actual content files (`CONTEXT.md`, `STATUS.md`, etc.) are never modified.

If you do encounter conflicts, resolve them normally:
```bash
git status
git diff
# Resolve conflicts, then:
git add .
git commit
```

### Q: Can I stay on v2.3.2?

**A:** Yes, v2.3.2 is stable and will continue working. However:
- No future updates
- No new features
- Migration becomes harder over time

**Recommendation:** Update now while it's automatic (5 minutes).

### Q: What if the update fails?

**A:** `/update-context-system` includes rollback:
1. Creates backups before changing anything
2. If update fails, your original files are preserved
3. Check `.claude-backup-{timestamp}/` for backups
4. You can manually restore if needed

---

## Troubleshooting

### Issue: "command not found: /update-context-system"

**Cause:** Commands not installed or outdated version

**Solution:**
```bash
# Re-install from new repository
curl -sL https://raw.githubusercontent.com/rexkirshner/ai-context-system/main/install.sh | bash
```

### Issue: Feedback file not migrated

**Cause:** File has <10 lines (considered template-only, not archived)

**Solution:**
```bash
# Manually migrate if desired
mv context/claude-context-feedback.md artifacts/feedback/feedback-v2.3.2-manual.md
cp templates/context-feedback.template.md context/context-feedback.md
```

### Issue: Git remote still shows old URL

**Cause:** Didn't update remote in Step 1

**Solution:**
```bash
git remote set-url origin https://github.com/rexkirshner/ai-context-system.git
git remote -v  # Verify
```

---

## Rollback Instructions

**If you need to revert to v2.3.2:**

```bash
# 1. Check for backup
ls .claude-backup-*/

# 2. Restore from backup
cp -r .claude-backup-{timestamp}/.claude .
cp -r .claude-backup-{timestamp}/templates .
cp -r .claude-backup-{timestamp}/scripts .
cp .claude-backup-{timestamp}/VERSION .

# 3. Restore feedback file
mv context/context-feedback.md context/claude-context-feedback.md

# 4. Verify
cat VERSION
# Should show: 2.3.2

# 5. Update remote (if changed)
git remote set-url origin https://github.com/rexkirshner/claude-context-system.git
```

**Note:** Rollback is rarely needed. Contact maintainers if you encounter issues.

---

## Post-Migration Checklist

After running `/update-context-system`:

- [ ] VERSION shows 3.0.0
- [ ] `context/context-feedback.md` exists
- [ ] Old feedback archived (if had content)
- [ ] `claude.md` still exists (unchanged)
- [ ] `CONTEXT.md`, `STATUS.md`, etc. unchanged
- [ ] All your content preserved
- [ ] Commands work normally

**All checked?** ✅ You're successfully on v3.0.0!

---

## What's Next?

**After migrating:**

1. **Continue using the system normally** - all commands work the same
2. **New feedback goes in** `context/context-feedback.md` (new name)
3. **Enjoy clearer branding** - "AI Context System" reflects multi-AI support
4. **Share feedback** - help improve the system for everyone!

---

## Getting Help

**Issues during migration?**

1. **Check this guide** - most questions answered above
2. **Check CHANGELOG.md** - comprehensive v3.0.0 entry with FAQ
3. **Open GitHub issue**: https://github.com/rexkirshner/ai-context-system/issues
4. **Provide context**:
   - Your v2.x version (from `cat VERSION` before migrating)
   - Error messages
   - Output of `/update-context-system`
   - OS and environment

---

## Summary

**What you need to do:**
1. Run `/update-context-system`
2. Verify migration (check VERSION, new feedback file)
3. Continue using the system

**What happens automatically:**
- Feedback file migrated and archived
- VERSION updated to 3.0.0
- All content preserved
- Zero data loss

**Time required:** 5-10 minutes

**Risk:** Zero (all content archived and preserved)

---

**Welcome to AI Context System v3.0.0!** 🎉

_Originally designed for Claude Code, now supports all AI assistants (Claude, Cursor, Aider, Codex, and more)_
