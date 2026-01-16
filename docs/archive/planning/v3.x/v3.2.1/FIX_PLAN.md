# v3.2.1 Fix Plan

**Release Type:** Patch release (bug fixes and critical improvements)
**Target Date:** ASAP
**Focus:** Address all issues found during dogfooding (installation + /save-full testing)

---

## Issues to Address

### CRITICAL (Must Fix - Bugs)

#### 1. BUG-001: Session Number Detection
- **File:** `scripts/save-context-helper.sh`
- **Issue:** Counts template/example sessions as real sessions
- **Current:** Detects "Session 6" for first real session
- **Impact:** Affects ALL first-time users
- **Fix:** Update grep pattern to exclude templates/examples
```bash
# Current (WRONG):
LAST_SESSION=$(grep -c "^## Session" context/SESSIONS.md)

# Fixed (CORRECT):
LAST_SESSION=$(sed -n '1,/^## Example/p' context/SESSIONS.md | \
               grep "^## Session [0-9]" | grep -v "Template" | wc -l | tr -d ' ')
```
- **Estimate:** 10 minutes

#### 2. BUG-002: Context Folder Detection
- **Files:** `scripts/save-context-helper.sh`, potentially other commands
- **Issue:** Commands assume you're in correct directory, fail otherwise
- **Impact:** Commands fail from subdirectories
- **Fix:** Use existing `scripts/find-context-folder.sh` or implement search logic
- **Estimate:** 30 minutes

#### 3. Quick Reference Auto-Generation NOT Implemented
- **Files:** `/save` and `/save-full` commands
- **Issue:** Documentation says "auto-generated" but code doesn't exist
- **Impact:** False advertising, 15+ manual fields to populate
- **Fix:** Implement extraction from .context-config.json and STATUS.md
- **Estimate:** 1-2 hours

**Critical Priority Subtotal:** ~2.5 hours

---

### HIGH PRIORITY (Should Fix - Major Friction)

#### 4. Meta-Project Git Detection Messaging
- **File:** `scripts/save-context-helper.sh`
- **Issue:** "Not a git repository" doesn't distinguish no-git vs. meta-project
- **Fix:** Detect sub-repos and adjust message
```bash
if [ -d .git ]; then
  echo "   ✅ Git repository detected"
elif find . -maxdepth 2 -name ".git" -type d 2>/dev/null | grep -q .; then
  echo "   ℹ️  Meta-project detected (sub-repos have git)"
else
  echo "   ⏭️  Not a git repository (skipping git data)"
fi
```
- **Estimate:** 15 minutes

#### 5. Interactive Init Mode
- **File:** `.claude/commands/init-context.md`
- **Issue:** Manual .context-config.json editing required for edge cases
- **Fix:** Add `--interactive` flag with prompts
- **Estimate:** 2-3 hours

#### 6. Meta-Project Template Support
- **Files:** New templates needed
- **Issue:** Templates assume single-project structure
- **Fix:** Create `CONTEXT.template-meta-project.md` and corresponding config
- **Estimate:** 1-2 hours

**High Priority Subtotal:** ~4-5.5 hours

---

### MEDIUM PRIORITY (Nice to Have)

#### 7. Post-Install Auto-Init Prompt
- **File:** `install.sh`
- **Issue:** Two-step process (install → manually run /init-context)
- **Fix:** Add optional prompt at end of install.sh
- **Estimate:** 30 minutes

#### 8. Multiple .claude Warning for Meta-Projects
- **File:** `.claude/commands/init-context.md`
- **Issue:** Warning designed for accidents, but legitimate for meta-projects
- **Fix:** Detect meta-project and adjust warning
- **Estimate:** 20 minutes

#### 9. Draft File Pre-Population for Non-Git Projects
- **File:** `scripts/save-context-helper.sh`
- **Issue:** No file changes detected in meta-projects
- **Fix:** Detect file changes via timestamps or prompt user
- **Estimate:** 45 minutes

**Medium Priority Subtotal:** ~1.5 hours

---

### LOW PRIORITY (Future/v3.3.0)

#### 10. TodoWrite State Capture
- **Estimate:** 1 hour

#### 11. Move Git Push Protocol to Separate Doc
- **Estimate:** 30 minutes

#### 12. Fix Step Numbering in Commands
- **Estimate:** 15 minutes

#### 13. Completion Checklist
- **Estimate:** 20 minutes

**Low Priority Subtotal:** ~2 hours

---

## Scope Decision for v3.2.1

### Option A: Critical Only (Minimal Patch)
- Fixes: 1, 2, 3
- **Time:** ~2.5 hours
- **Impact:** Fixes bugs and false advertising
- **Recommendation:** If need quick release

### Option B: Critical + High Priority (Recommended)
- Fixes: 1, 2, 3, 4, 5, 6
- **Time:** ~7-8 hours
- **Impact:** Fixes bugs + major UX improvements
- **Recommendation:** Best balance for patch release

### Option C: Critical + High + Medium (Comprehensive)
- Fixes: 1-9
- **Time:** ~9-10 hours
- **Impact:** Addresses all dogfooding feedback
- **Recommendation:** If want comprehensive fix release

### Option D: Everything (Full v3.3.0)
- Fixes: 1-13
- **Time:** ~11-12 hours
- **Impact:** Complete overhaul
- **Recommendation:** Better as v3.3.0 feature release

---

## Recommendation

**For v3.2.1:** Go with **Option B** (Critical + High Priority)

**Rationale:**
- Fixes all critical bugs (session detection, context folder detection, auto-generation)
- Adds major UX improvements (interactive init, meta-project support)
- Appropriate scope for patch release
- Addresses all dogfooding pain points
- ~8 hours is reasonable for patch release

**Defer to v3.3.0:**
- Low priority items (nice-to-haves)
- Post-install auto-init (convenience feature)
- TodoWrite capture (automation enhancement)

---

## Implementation Order

1. ✅ **Session number detection** (10 min) - Quick win, critical bug
2. ✅ **Context folder detection** (30 min) - Critical bug
3. ✅ **Meta-project git messaging** (15 min) - Quick improvement
4. ✅ **Quick Reference auto-generation** (2 hours) - Major feature completion
5. ✅ **Interactive init mode** (3 hours) - Major UX improvement
6. ✅ **Meta-project templates** (2 hours) - Complete meta-project support

**Total:** ~8 hours

---

## Testing Plan

1. Test session detection with fresh SESSIONS.md
2. Test context folder detection from subdirectories
3. Test Quick Reference auto-generation
4. Test interactive init mode
5. Test meta-project template installation
6. Full dogfooding test (install → init → save-full)

---

## Files to Modify

1. `scripts/save-context-helper.sh` - Session detection, git messaging, context detection
2. `.claude/commands/save.md` - Quick Reference auto-generation
3. `.claude/commands/save-full.md` - Quick Reference auto-generation
4. `.claude/commands/init-context.md` - Interactive mode, meta-project detection
5. `templates/CONTEXT.template-meta-project.md` - NEW
6. `templates/.context-config.template-meta-project.json` - NEW (optional)
7. `VERSION` - 3.2.0 → 3.2.1
8. `CHANGELOG.md` - Document all fixes

---

## Success Criteria

- [ ] Session number detection works correctly for fresh installations
- [ ] Commands work from any subdirectory (context folder auto-detected)
- [ ] Quick Reference auto-populated from .context-config.json
- [ ] Interactive init mode prompts for project details
- [ ] Meta-project templates available and documented
- [ ] All dogfooding issues addressed
- [ ] Zero regressions in existing functionality
