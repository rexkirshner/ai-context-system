---
name: save
description: Quick session save - updates current state only (2-3 minutes)
---

# /save Command

**Quick session save** - Updates current state without comprehensive documentation. Use this for most sessions during continuous work.

**For comprehensive documentation before breaks/handoffs, use `/save-full`**

## When to Use This Command

**Every session (default):**
- End of work session
- Switching tasks
- Quick check-in points

**Target time: 2-3 minutes**

## What This Command Does

1. Auto-extracts git changes (status, diff, staged)
2. Updates STATUS.md (current tasks, blockers, next steps)
3. Auto-generates Quick Reference section in STATUS.md (dashboard)
4. Reports what changed

**Does NOT:**
- Create SESSIONS.md entry (use /save-full for that)
- Update DECISIONS.md (add manually when needed)
- Export JSON (use /export-context when needed)

## Execution Steps

### Step 1: Find Context Folder

**v3.0.0:** Commands now work from subdirectories (backend/, frontend/, etc.)

```bash
# Find context folder (works from project root or subdirectories)
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/find-context-folder.sh" || exit 1
CONTEXT_DIR=$(find_context_folder) || exit 1

echo "✅ Found context at: $CONTEXT_DIR"
```

**Note:** This searches current directory, parent directory, and grandparent directory for context/ folder. Use `$CONTEXT_DIR` variable throughout this command instead of hardcoded `context/`.

### Step 2: Auto-Extract Git Data

**ACTION:** Use Bash tool to extract git information:

```bash
echo "📊 Analyzing changes..."
echo ""

# Get git status
if git rev-parse --git-dir > /dev/null 2>&1; then
  GIT_STATUS=$(git status --short 2>/dev/null || echo "No changes")
  GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

  # Count changes
  NEW_FILES=$(echo "$GIT_STATUS" | grep "^??" | wc -l | tr -d ' ')
  MODIFIED_FILES=$(echo "$GIT_STATUS" | grep "^ M\|^M " | wc -l | tr -d ' ')
  STAGED_FILES=$(echo "$GIT_STATUS" | grep "^A \|^M " | wc -l | tr -d ' ')

  echo "Branch: $GIT_BRANCH"
  echo "New: $NEW_FILES | Modified: $MODIFIED_FILES | Staged: $STAGED_FILES"
  echo ""
else
  echo "⚠️  Not a git repository"
  echo ""
fi
```

### Step 3: Update STATUS.md

**ACTION:** Use Read tool to read current STATUS.md, then use Edit tool to update:

**Prompt user for quick updates:**
```
Current tasks? (comma-separated, or press enter to keep existing):
>

Blockers? (or press enter for none):
>

Next steps? (or press enter to keep existing):
>
```

**Update Work In Progress section:**
```markdown
## Work In Progress

**Current Task:** [What you're working on right now]
**Location:** `file.ts:line` (if applicable)
**Next Action:** [Specific next step when you resume]
**Blockers:** [None / List any blockers]

**Last Updated:** [YYYY-MM-DD HH:MM]
```

**Update Active Tasks section:**
```markdown
## Active Tasks

- [ ] [Task 1]
- [ ] [Task 2]
- [x] [Completed task]

**Priority:** [Next most important task]
```

### Step 4: Auto-Generate Quick Reference in STATUS.md

**ACTION:** Use Read tool to read STATUS.md, .context-config.json, then update Quick Reference section:

**Auto-population logic:**

1. **Project:** From `.context-config.json` → `project.name`
2. **Phase:** From `STATUS.md` → `## Current Phase` section (first line)
3. **Status indicator:**
   - 🔴 Red if `Blockers` section has items
   - 🟡 Yellow if Active Tasks > 5 or any task marked (HIGH)
   - 🟢 Green otherwise
4. **URLs:** From `.context-config.json` → `project.urls.*`
5. **Tech Stack:** From `.context-config.json` → `project.techStack`
6. **Commands:** From `.context-config.json` → `project.commands.*`
7. **Current Focus:** From `STATUS.md` → first item in Active Tasks
8. **Last Session:** From `SESSIONS.md` → most recent `## Session` heading
9. **Documentation Health:** From last `/validate-context` run (cached in temp file)

**Update the Quick Reference section in STATUS.md:**

```bash
# Extract values from config
PROJECT_NAME=$(jq -r '.project.name' $CONTEXT_DIR/.context-config.json 2>/dev/null || echo "[Project Name]")
PROD_URL=$(jq -r '.project.urls.production' $CONTEXT_DIR/.context-config.json 2>/dev/null || echo "N/A")
STAGING_URL=$(jq -r '.project.urls.staging' $CONTEXT_DIR/.context-config.json 2>/dev/null || echo "N/A")
REPO_URL=$(jq -r '.project.urls.repository' $CONTEXT_DIR/.context-config.json 2>/dev/null || echo "N/A")
TECH_STACK=$(jq -r '.project.techStack' $CONTEXT_DIR/.context-config.json 2>/dev/null || echo "[Tech stack]")
DEV_CMD=$(jq -r '.project.commands.dev' $CONTEXT_DIR/.context-config.json 2>/dev/null || echo "npm run dev")
TEST_CMD=$(jq -r '.project.commands.test' $CONTEXT_DIR/.context-config.json 2>/dev/null || echo "npm test")
BUILD_CMD=$(jq -r '.project.commands.build' $CONTEXT_DIR/.context-config.json 2>/dev/null || echo "npm run build")

# Extract from STATUS.md
CURRENT_PHASE=$(sed -n '/## Current Phase/,/^##/p' $CONTEXT_DIR/STATUS.md | grep "^**Phase:**" | sed 's/^**Phase:** //' 2>/dev/null || echo "[Phase]")
ACTIVE_TASK=$(sed -n '/## Active Tasks/,/^##/p' $CONTEXT_DIR/STATUS.md | grep -m1 '^- \[ \]' | sed 's/^- \[ \] //' 2>/dev/null || echo "[No active tasks]")
BLOCKERS=$(sed -n '/## Blockers/,/^##/p' $CONTEXT_DIR/STATUS.md | grep -v "^##" | grep -v "^**" | grep -v "^$" | wc -l 2>/dev/null || echo "0")

# Determine status color
if [ "$BLOCKERS" -gt 0 ]; then
  STATUS_COLOR="🔴 Blocked"
else
  STATUS_COLOR="🟢 Active"
fi

# Get last session from SESSIONS.md
LAST_SESSION=$(grep -m1 '^## Session' $CONTEXT_DIR/SESSIONS.md 2>/dev/null | sed 's/^## //' || echo "No sessions yet")

# Update Quick Reference section in STATUS.md using Edit tool
# Replace content between "## 📊 Quick Reference" and next "---"
```

**Note:** This replaces Step 4 from v2.0. QUICK_REF.md is no longer generated as a separate file.

### Step 5: Report Updates

**ACTION:** Output summary to user:

```
✅ Quick Save Complete

**Updated:**
- STATUS.md - Work in progress, active tasks, and Quick Reference (auto-generated)

**Time:** ~2-3 minutes

**Git Status:** 3 new, 5 modified, 2 staged files on branch main

**Current Focus:** [Brief summary from STATUS.md]

**Quick Reference:** Auto-updated in STATUS.md (project info, URLs, current phase)

**Next Session:**
Run /save again for quick update, or /save-full before breaks/handoffs.

---

💡 Tip: Run /save-full before taking breaks >1 week or handing off to another agent
```

## Important Notes

### This is the Default Command

For **continuous work** (most sessions):
- Use `/save`
- 2-3 minutes
- Updates current state
- No comprehensive session history

For **breaks/handoffs** (occasional):
- Use `/save-full`
- 10-15 minutes
- Creates SESSIONS.md entry
- Comprehensive documentation

### What Gets Updated

**Every /save:**
- ✅ STATUS.md (current tasks, blockers, next steps, Quick Reference section auto-generated)

**Not updated:**
- ❌ SESSIONS.md (use /save-full)
- ❌ DECISIONS.md (update manually when important decision made)

**Note:** In v2.1, QUICK_REF.md has been consolidated into STATUS.md as an auto-generated section at the top.

### Time Investment

**Target:** 2-3 minutes per session

**20 sessions:**
- 17× /save: 34-51 minutes
- 3× /save-full: 30-45 minutes
- **Total: 64-96 minutes** (vs. 100-200 min in v1.8.0)

### When to Use /save-full

Use `/save-full` (comprehensive) when:
- Taking break >1 week
- Handing off to another agent
- Major milestone completed
- Want comprehensive session history entry

Frequency: ~3-5 times per 20 sessions

## Workflow Example

**Typical 20-Session Project:**

```
Session 1-5:   /save (2-3 min each)
Session 6:     /save-full (weekend break coming)
Session 7-12:  /save (2-3 min each)
Session 13:    /save-full (major milestone completed)
Session 14-19: /save (2-3 min each)
Session 20:    /save-full (project handoff)
```

**Time Investment:**
- 17× /save: ~40-50 min
- 3× /save-full: ~30-45 min
- **Total: ~70-95 min** (instead of 100-200 min)

**Savings: 30-50% reduction in overhead**

## Success Criteria

Save succeeds when:
- STATUS.md updated with current state
- Quick Reference section in STATUS.md regenerated
- Completed in 2-3 minutes
- User knows where they left off
- Can resume easily next session

**Perfect save:**
- Quick and painless (no overhead feeling)
- Current state captured
- Ready to resume work
- Comprehensive docs when actually needed (use /save-full)
