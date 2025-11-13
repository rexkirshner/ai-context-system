# AI Context System - Immediate Action Checklist
## Critical Fixes from Project 1 & Project 2 Feedback

**Generated**: 2025-11-12 (Updated with Project 2 insights)
**Priority**: IMMEDIATE ACTION REQUIRED
**NEW**: Multi-developer support now critical priority

---

## 🚨 HOTFIX v3.2.3 (Do Today)

### 1. Fix install.sh Manifest
**File**: `ai-context-system/install.sh`

```bash
# REMOVE these non-existent files from arrays:
- "MIGRATION_GUIDE_v2.0_to_v2.1.md"
- "MIGRATION_GUIDE_v2.1_to_v2.2.md"
- "save-context-guide.md"

# Should only include files that actually exist in repo
```

### 2. Fix Validation Logic
**File**: `ai-context-system/install.sh`

Add size check to validation:
```bash
# Replace basic validation with:
if [[ $(stat -f%z "$file" 2>/dev/null || stat -c%s "$file") -lt 50 ]]; then
  echo "❌ Invalid file: $file (too small)"
  rm -f "$file"
  return 1
fi
```

---

## 🔴 CRITICAL SAFETY (This Week)

### 3. Protect Against Data Loss
**File**: All commands that delete files

Add to top of organize-docs.md and similar:
```markdown
⚠️ CRITICAL: NEVER delete untracked files without explicit permission
- Check if file is in .gitignore (may be sensitive)
- Show size and sample contents
- Require specific confirmation: "yes delete [filename]"
```

### 4. Fix Session Numbering
**File**: `scripts/common-functions.sh`

Add these functions:
```bash
get_next_session_number() {
  local context_dir="${1:-context}"
  local count=$(grep -c "^## Session" "$context_dir/SESSIONS.md" 2>/dev/null || echo "0")
  echo $((count + 1))
}
```

Update both `/code-review` and `/save-full` to use this function.

### 5. Fix Template Markers
**File**: All `templates/*.template.md` files

Add clear markers:
```markdown
<!-- REQUIRED SECTION: DO NOT REMOVE -->
## Section Name
[FILL_HERE: Your content]
<!-- END REQUIRED SECTION -->
```

Change all `[placeholders]` to `[FILL_HERE: description]`

---

## 📋 Testing Checklist

Before releasing v3.2.3:

- [ ] Test installation on clean system
- [ ] Verify no 404 stub files created
- [ ] Test with AI agent (Claude/GPT-4) on init-context
- [ ] Verify session numbers consistent across commands
- [ ] Test deletion protection (should require explicit confirmation)
- [ ] Run full installation and check file sizes
- [ ] Verify all template sections preserved during init

---

## 👥 NEW: Multi-Developer Support (Week 2)

### 6. Implement /sync-commits
**Priority**: CRITICAL for teams

```bash
# Core functionality
sync_commits() {
  # Find last documented commit in SESSIONS.md
  LAST=$(grep -oP 'Commit: \K[a-f0-9]{7}' SESSIONS.md | tail -1)

  # Get undocumented commits
  git log $LAST..HEAD --format="%h|%an|%s" | while read commit; do
    # Parse and generate session entry
    # Show preview for approval
  done
}
```

### 7. Add /note Command
**File**: `.claude/commands/note.md`

```markdown
Quick documentation update without full session

Steps:
1. Get note text from user
2. Append to SESSIONS.md "Quick Notes" section
3. Update STATUS.md timestamp
4. Skip full session structure
```

### 8. Add Drift Detection
**File**: `.claude/commands/review-context.md`

Add new step:
```bash
# Step 1.6: Check for undocumented commits
DRIFT=$(git rev-list --count $LAST_DOC..HEAD)
if [ $DRIFT -gt 0 ]; then
  echo "⚠️ $DRIFT undocumented commits found"
  echo "Run /sync-commits to document"
fi
```

---

## 🎯 Quick Wins (Can Do Now)

### Documentation Updates

1. **Add to each command file header**:
```markdown
<!--
AI AGENT NOTICE: This file contains instructions for you to execute.
Read each step and run the bash commands sequentially.
This is NOT a directly executable slash command.
-->
```

2. **Add to README.md**:
```markdown
## AI Agent Usage

If you're an AI agent using this system:
1. Templates have [FILL_HERE: ...] placeholders - only replace these
2. Never remove sections marked "REQUIRED SECTION"
3. Always ask before deleting untracked files
4. Session numbers come from SESSIONS.md count
```

---

## 📊 Success Metrics

Track these after fixes:

| Metric | Current | Target | How to Measure |
|--------|---------|--------|----------------|
| Init Success Rate | ~50% | >95% | AI agent tests |
| Installation Integrity | 89% | 100% | File validation |
| Data Loss Events | 1 reported | 0 | User feedback |
| Session Number Match | Unknown | 100% | Cross-reference artifacts |
| Template Preservation | ~60% | >90% | Structure validation |
| **Multi-Dev Commits** | Manual | 100% auto | /sync-commits usage |
| **Attribution Clarity** | Unclear | 100% | Developer field in headers |
| **Update Time (minor)** | 2-3 min | <30 sec | /note command timing |

---

## 🚀 Implementation Order

**Day 1 (Hotfix)**:
1. Fix install.sh manifest ⏱️ 30 min
2. Add validation size checks ⏱️ 30 min
3. Test installation ⏱️ 1 hour
4. Release v3.2.3 ⏱️ 30 min

**Day 2-3 (Safety)**:
1. Add deletion protection ⏱️ 2 hours
2. Fix session numbering ⏱️ 2 hours
3. Test with AI agents ⏱️ 2 hours

**Day 4-5 (Templates)**:
1. Update all template markers ⏱️ 3 hours
2. Create validation script ⏱️ 2 hours
3. Test initialization ⏱️ 2 hours

---

## ⚠️ Breaking Changes to Communicate

### For v3.2.3:
- None (backward compatible)

### For v3.3.0:
- Session numbering may change (provide migration script)
- Templates have new required markers (won't break existing projects)
- More deletion confirmations required (safety improvement)

---

## 📝 Release Notes Template

```markdown
# v3.2.3 - Critical Installation Fix

## Fixed
- Installation no longer creates 404 stub files
- Validation properly detects failed downloads
- Session numbering consistency improved

## Security
- Added protection against unintended file deletion
- Untracked files now require explicit confirmation

## For AI Agents
- Clearer template placeholders
- Better initialization instructions
- Consistent session numbering

This is a critical update. All users should upgrade immediately.
```

---

*Use this checklist to implement fixes systematically. Check off items as completed.*