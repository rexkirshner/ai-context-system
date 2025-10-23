# GitHub Repository Rename Instructions

**Purpose:** Complete the AI Context System rebrand by renaming the GitHub repository

**Time Required:** ~15 minutes

**Risk Level:** LOW (GitHub provides automatic redirects, zero downtime)

---

## Pre-Flight Checklist

✅ All local changes committed (v3.2.0)
✅ Redirect repository content created (REDIRECT_REPO_README.md, REDIRECT_REPO_INSTALL.sh)
✅ CHANGELOG updated with v3.2.0 entry
✅ VERSION file updated to 3.2.0

---

## Step 1: Push Current Changes to GitHub

```bash
# Push v3.2.0 commit to main branch
git push origin main

# Verify push succeeded
git log -1 --oneline
# Should show: "v3.2.0: Complete AI Context System rebrand"
```

**Expected Result:** v3.2.0 commit live on GitHub at old URL (claude-context-system)

---

## Step 2: Rename Main Repository on GitHub

### 2.1 Navigate to Repository Settings

1. Go to: https://github.com/rexkirshner/claude-context-system
2. Click **Settings** (top right, requires admin access)
3. Scroll to **"Danger Zone"** section (bottom of settings page)

### 2.2 Rename Repository

1. Find **"Rename repository"** section
2. Click **"Rename"** button
3. In the popup dialog:
   - **Current name:** `claude-context-system`
   - **New name:** `ai-context-system`
4. Read the warning (GitHub will set up redirects automatically)
5. Type `rexkirshner/ai-context-system` to confirm
6. Click **"I understand, rename repository"**

**Expected Result:**
- Repository renamed to `ai-context-system`
- GitHub creates automatic redirects from old URLs
- All old URLs (git, web, raw) continue working via redirect

### 2.3 Verify Rename

Test that these URLs redirect correctly:
- https://github.com/rexkirshner/claude-context-system → redirects to ai-context-system
- https://raw.githubusercontent.com/rexkirshner/claude-context-system/main/README.md → redirects

**Both should redirect automatically!**

---

## Step 3: Update Local Git Remote

```bash
# Update your local repository to point to new URL
git remote set-url origin https://github.com/rexkirshner/ai-context-system.git

# Verify change
git remote -v
# Should show:
# origin  https://github.com/rexkirshner/ai-context-system.git (fetch)
# origin  https://github.com/rexkirshner/ai-context-system.git (push)

# Test connection
git fetch
# Should work without errors
```

**Expected Result:** Local repository now points to new URL

---

## Step 4: Create New Redirect Repository

### 4.1 Create New Repository

1. Go to: https://github.com/new
2. Fill in repository details:
   - **Owner:** rexkirshner
   - **Repository name:** `claude-context-system`
   - **Description:** ⚠️ MOVED → This project has been renamed to AI Context System
   - **Visibility:** Public
   - **Initialize:** ✅ Add README file
   - **License:** Same as main repo (if applicable)
3. Click **"Create repository"**

### 4.2 Populate Redirect Repository

```bash
# Clone the new redirect repository
cd /tmp
git clone https://github.com/rexkirshner/claude-context-system.git
cd claude-context-system

# Copy redirect content from main repository
cp /Users/rexkirshner/coding/claude-context-system/REDIRECT_REPO_README.md README.md
cp /Users/rexkirshner/coding/claude-context-system/REDIRECT_REPO_INSTALL.sh install.sh

# Make install script executable
chmod +x install.sh

# Stage, commit, and push
git add README.md install.sh
git commit -m "Add repository redirect notice and smart installer redirect"
git push origin main

# Clean up
cd ..
rm -rf claude-context-system
```

### 4.3 Verify Redirect Repository

1. Visit: https://github.com/rexkirshner/claude-context-system
2. Verify README shows migration notice
3. Test redirect installer:
   ```bash
   curl -sL https://raw.githubusercontent.com/rexkirshner/claude-context-system/main/install.sh | bash
   ```
   Should redirect to ai-context-system installer

**Expected Result:**
- Old repository URL shows migration notice
- Old installer automatically redirects to new installer

---

## Step 5: Create Git Tag and Release

### 5.1 Create Git Tag

```bash
# Navigate to main repository (renamed)
cd /Users/rexkirshner/coding/claude-context-system

# Create annotated tag
git tag -a v3.2.0 -m "$(cat <<'EOF'
AI Context System v3.2.0 - Rebrand Complete

**REBRAND COMPLETION** - Repository rename finished

## What's New

**Repository Renamed:**
- Old: github.com/rexkirshner/claude-context-system
- New: github.com/rexkirshner/ai-context-system
- Impact: GitHub auto-redirects, zero breaking changes

**All References Updated:**
- install.sh, update-context-system.md, README.md
- scripts/common-functions.sh, templates/legacy/README.md
- VERSION (3.1.1 → 3.2.0)
- CHANGELOG with v3.2.0 entry

**Backward Compatibility:**
- ✅ GitHub automatic redirects from old URLs
- ✅ Fresh installs work with new URLs
- ✅ Existing users: zero action required
- ✅ /update-context-system automatically uses new URL

**Redirect Repository:**
- New repo at old URL with migration notice
- Smart redirect installer script

## Migration

### For All Users (v2.x, v3.0.x, v3.1.x):
```bash
/update-context-system  # Automatically uses new repository
```

### For Developers (optional but recommended):
```bash
git remote set-url origin https://github.com/rexkirshner/ai-context-system.git
```

## Why the Rename?

System now supports Claude, Cursor, Aider, Codex, and more.
New name reflects universal AI support.

Full changelog: CHANGELOG.md
EOF
)"

# Push tag to GitHub
git push origin v3.2.0

# Verify tag
git tag -l v3.2.0
```

**Expected Result:** Tag v3.2.0 created and pushed to GitHub

### 5.2 Create GitHub Release

```bash
# Create release using gh CLI
gh release create v3.2.0 \
  --title "v3.2.0 - AI Context System Rebrand Complete" \
  --notes "$(cat <<'EOF'
# AI Context System v3.2.0 - Rebrand Complete

**REBRAND COMPLETION RELEASE** - Repository renamed, all references updated

## 🎉 What's New

### Repository Renamed
- **Old**: `github.com/rexkirshner/claude-context-system`
- **New**: `github.com/rexkirshner/ai-context-system`
- **Impact**: GitHub provides automatic redirects from all old URLs
- **User Action**: None required (redirects work automatically!)

### All References Updated
Repository URLs updated in:
- `install.sh` - Main installer script
- `.claude/commands/update-context-system.md` - Update command
- `README.md` - Documentation and rebrand announcement
- `scripts/common-functions.sh` - Default repository URL
- `templates/legacy/README.md` - Historical reference clarified

### Version Bump
- **3.1.1 → 3.2.0** (minor bump)
- Completes the v3.0.0 rebrand announcement

### Redirect Repository
A new repository at the old URL provides:
- Migration notice pointing to new location
- Smart redirect installer script
- Seamless experience for users finding old URL

---

## 🚀 Migration Instructions

### For All Users (Any Version: v2.x, v3.0.x, v3.1.x)

```bash
cd /path/to/your/project
/update-context-system  # Automatically downloads from new URL
```

**That's it!** No other action required.

### For Developers/Contributors (Optional but Recommended)

Update your local git remote to use the new URL:

```bash
git remote set-url origin https://github.com/rexkirshner/ai-context-system.git
git remote -v  # Verify the change
```

This is optional because GitHub redirects work automatically, but using the new URL directly is cleaner.

### For Fresh Installs

```bash
curl -sL https://raw.githubusercontent.com/rexkirshner/ai-context-system/main/install.sh | bash
```

---

## ✅ Backward Compatibility

### For Fresh Installs
✅ All new installs use `ai-context-system` URLs

### For Existing Users
✅ **GitHub automatic redirects handle everything:**
- Old bookmark URLs → Redirected automatically
- Old git clone/pull → Works via redirect
- Old curl commands → Works via redirect
- Zero breaking changes!

### For Developers
⚠️ **Optional (not required)**: Update git remote URL:
```bash
git remote set-url origin https://github.com/rexkirshner/ai-context-system.git
```
Git operations work without this (via redirect), but updating is cleaner.

---

## 🤔 Why the Rename?

The system was originally built for Claude Code but now supports:
- **Claude Code** (Anthropic)
- **Cursor** (AI-powered IDE)
- **Aider** (AI pair programmer)
- **OpenAI Codex** (GPT-4 coding)
- **And more...**

The new name "AI Context System" reflects this universal AI support.

---

## 📝 What Stayed the Same

**Preserved Historical References:**
- CHANGELOG.md keeps old entries (SEO + historical accuracy)
- planning/v3.0.0/* docs unchanged (historical documentation)

**All User Content:**
- ✅ All context files unchanged
- ✅ All user data preserved
- ✅ All commands work identically
- ✅ Zero breaking changes for end users

---

## 📊 Files Changed

**Modified (7 files):**
- install.sh
- .claude/commands/update-context-system.md
- README.md
- scripts/common-functions.sh
- templates/legacy/README.md
- VERSION
- CHANGELOG.md

**Added (2 files):**
- REDIRECT_REPO_README.md (for redirect repository)
- REDIRECT_REPO_INSTALL.sh (for redirect repository)

**Total Changes:** ~270 lines modified/added

---

## 🔗 Links

- **New Repository**: https://github.com/rexkirshner/ai-context-system
- **Old Repository** (redirect): https://github.com/rexkirshner/claude-context-system
- **Changelog**: [CHANGELOG.md](./CHANGELOG.md)
- **Migration Guide**: [MIGRATION_GUIDE_v2_to_v3.md](./MIGRATION_GUIDE_v2_to_v3.md)

---

## 💡 Questions?

See the [main repository](https://github.com/rexkirshner/ai-context-system) for:
- Full documentation
- Issue tracker
- Latest releases
- Migration guides

---

**Impact:** Repository rebrand complete, backward compatibility preserved, zero breaking changes.

🤖 *Generated with [Claude Code](https://claude.com/claude-code)*
EOF
)"
```

**Expected Result:** GitHub release v3.2.0 created with comprehensive notes

---

## Step 6: Verification Checklist

### 6.1 Test All URLs

Test that these work:

**Old URLs (should redirect):**
```bash
# Old repository web URL
open https://github.com/rexkirshner/claude-context-system

# Old raw content URL
curl -sL https://raw.githubusercontent.com/rexkirshner/claude-context-system/main/VERSION

# Old installer
curl -sL https://raw.githubusercontent.com/rexkirshner/claude-context-system/main/install.sh | bash
```

**New URLs (direct):**
```bash
# New repository web URL
open https://github.com/rexkirshner/ai-context-system

# New raw content URL
curl -sL https://raw.githubusercontent.com/rexkirshner/ai-context-system/main/VERSION

# New installer
curl -sL https://raw.githubusercontent.com/rexkirshner/ai-context-system/main/install.sh | bash
```

### 6.2 Verify Git Operations

```bash
# Test git clone from old URL (should redirect)
cd /tmp
git clone https://github.com/rexkirshner/claude-context-system.git test-redirect
cd test-redirect
git remote -v
# Should show ai-context-system URL!
cd ..
rm -rf test-redirect

# Test git clone from new URL (direct)
git clone https://github.com/rexkirshner/ai-context-system.git test-direct
cd test-direct
git remote -v
# Should show ai-context-system URL
cd ..
rm -rf test-direct
```

### 6.3 Verify Release

1. Visit: https://github.com/rexkirshner/ai-context-system/releases/latest
2. Verify v3.2.0 release exists
3. Verify release notes are comprehensive
4. Verify tag v3.2.0 exists

### 6.4 Verify Redirect Repository

1. Visit: https://github.com/rexkirshner/claude-context-system
2. Verify README shows migration notice
3. Verify install.sh exists
4. Test installer redirect:
   ```bash
   curl -sL https://raw.githubusercontent.com/rexkirshner/claude-context-system/main/install.sh | bash
   ```

---

## Success Criteria

✅ Main repository renamed to ai-context-system
✅ Old URL redirects to new URL (web and git)
✅ Redirect repository created at old URL
✅ Git tag v3.2.0 created and pushed
✅ GitHub release v3.2.0 created with notes
✅ Local git remote updated to new URL
✅ All tests passing (URLs, git ops, installer)

---

## Rollback Plan (If Needed)

If something goes wrong:

1. **Rename repository back to old name:**
   - Settings → Danger Zone → Rename
   - Change back to `claude-context-system`
   - GitHub supports renaming multiple times

2. **Delete redirect repository:**
   - Go to redirect repo settings
   - Danger Zone → Delete repository
   - Confirm deletion

3. **Remove tag and release:**
   ```bash
   git tag -d v3.2.0
   git push origin :refs/tags/v3.2.0
   gh release delete v3.2.0 --yes
   ```

4. **Revert local git remote:**
   ```bash
   git remote set-url origin https://github.com/rexkirshner/claude-context-system.git
   ```

---

## Timeline

- ⏱️ Step 1 (Push): 1 minute
- ⏱️ Step 2 (Rename): 2 minutes
- ⏱️ Step 3 (Update local): 1 minute
- ⏱️ Step 4 (Redirect repo): 5 minutes
- ⏱️ Step 5 (Tag & Release): 3 minutes
- ⏱️ Step 6 (Verification): 3 minutes
- **Total: ~15 minutes**

---

## Notes

- **GitHub redirects are automatic** - no configuration needed
- **Redirects are permanent** - as long as new repo name doesn't change
- **Zero downtime** - all operations happen instantly
- **Zero data loss** - rename doesn't affect content
- **Works for all protocols** - HTTP(S), Git, SSH

---

## Questions?

If you encounter any issues:
1. Check GitHub status: https://www.githubstatus.com/
2. Review GitHub docs on renaming: https://docs.github.com/en/repositories/creating-and-managing-repositories/renaming-a-repository
3. Contact GitHub support if redirects aren't working

---

**Ready to proceed?** Start with Step 1!
