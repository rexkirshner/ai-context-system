---
name: save-full
description: Comprehensive session documentation for breaks and handoffs (10-15 minutes)
---

# /save-full Command

**Comprehensive session documentation** - Creates detailed SESSIONS.md entry with mental models and decision rationale. Use before breaks, handoffs, or milestones.

**For regular session updates, use `/save` (2-3 minutes)**

**Philosophy:**
- Capture TodoWrite state for productivity tracking
- Extract mental models and decision rationale for AI agents
- Update what changed (not everything)
- Grow documentation when complexity demands

**Reference guide:** `.claude/docs/save-context-guide.md` (philosophy, examples, not a checklist)

## When to Use This Command

**Use /save-full (comprehensive) when:**
- Taking break >1 week
- Handing off to another agent/developer
- Major milestone completed
- Want detailed session history entry

**Frequency:** ~3-5 times per 20 sessions (occasional, not every session)

**Target time:** 10-15 minutes

**For regular sessions:** Use `/save` instead (2-3 minutes)

**Rule of thumb:** Most sessions use `/save`. Use `/save-full` when you need comprehensive documentation.

## What This Command Does

**Everything /save does:**
1. Updates STATUS.md (current tasks, blockers, next steps)
2. Auto-generates Quick Reference section in STATUS.md (dashboard)

**PLUS comprehensive documentation:**
3. **Creates SESSIONS.md entry** - Structured 40-60 lines with:
   - What changed and why
   - Problem solved (issue, constraints, approach, rationale)
   - Mental models (current understanding, insights, gotchas)
   - Files modified (with context)
   - Work in progress (precise resume point)
   - TodoWrite state (completed vs. pending)
4. **Updates DECISIONS.md** - If significant decision made
5. **Optional: Exports JSON** - For multi-agent workflows (--with-json flag)

**Purpose:** Comprehensive context for AI agents to review, understand, and take over development.

## Execution Steps

### Step 1: Find and Verify Context Directory

**v2.2.0: Now works from subdirectories!**

```bash
# Find context/ directory (searches up to 2 parent dirs)
find_context_dir() {
  for dir in "context" "../context" "../../context"; do
    if [ -d "$dir" ]; then
      echo "$dir"
      return 0
    fi
  done
  return 1
}

CONTEXT_DIR=$(find_context_dir)

if [ -z "$CONTEXT_DIR" ]; then
  echo "❌ No context/ directory found"
  echo "Searched: ./ ../ ../../"
  echo ""
  echo "Run /init-context from project root first"
  exit 1
fi

echo "✅ Found context at: $CONTEXT_DIR"

# Use $CONTEXT_DIR for all context file operations below
# Example: $CONTEXT_DIR/STATUS.md instead of context/STATUS.md
```

**Why this works:**
- Searches current directory first
- Then parent directory (for `backend/` subdirs)
- Then grandparent (for `backend/src/` subdirs)
- Works from anywhere in project structure

### Step 2: Analyze What Changed

**Option A: Use Helper Script (Recommended)**

```bash
./scripts/save-context-helper.sh
```

This will:
- Auto-detect session number
- Gather git changes (log, status, diff)
- Pre-populate session template with file changes
- Create draft file: `context/.session-N-draft.md`
- You just fill in the [BRACKETED] placeholders (mental models, rationale)

**Option B: Manual Analysis**

Gather information about this session's work:

**Git Analysis:**
```bash
# What happened this session
git log --oneline -10
git status
git diff HEAD

# What's staged
git diff --cached
```

**Session Understanding:**
- What was the focus of this session?
- What files were modified/created?
- What decisions were made?
- What issues were discovered or fixed?
- What's incomplete (WIP)?

### Step 3: Update Core Files (Always)

These files ALWAYS get updated:

#### context/SESSIONS.md - Session History (Structured, Comprehensive)

**Auto-detect session number:**
```bash
LAST_SESSION=$(grep -c "^## Session" context/SESSIONS.md)
NEXT_SESSION=$((LAST_SESSION + 1))
```

**Write a comprehensive, structured session summary** (40-60 lines with depth for AI agents):
```markdown
## Session [N] | YYYY-MM-DD | [Phase Name]

**Duration:** [X]h | **Focus:** [Brief description] | **Status:** ✅/⏳

### Changed
- ✅ [Key accomplishment 1 with context]
- ✅ [Key accomplishment 2 with context]

### Problem Solved
**Issue:** [What problem did this session address?]
**Constraints:** [What limitations existed?]
**Approach:** [How did you solve it? What was your thinking?]
**Why this approach:** [Rationale for the chosen solution]

### Decisions
- **[Decision topic]:** [What and why] → See DECISIONS.md [ID]

### Files
**NEW:** `path/to/file.ts:1-150` - [Purpose and key contents]
**MOD:** `path/to/file.tsx:123-145` - [What changed and why]
**DEL:** `path/to/old-file.ts` - [Why removed]

### Mental Models
**Current understanding:** [Explain your mental model of the system]
**Key insights:** [Insights AI agents should know]
**Gotchas discovered:** [Things that weren't obvious]

### Work In Progress
**Task:** [What's incomplete - be specific]
**Location:** `file.ts:145` in `functionName()`
**Current approach:** [Detailed mental model of what you're doing]
**Why this approach:** [Rationale]
**Next specific action:** [Exact next step]
**Context needed:** [What you need to remember to resume]

### TodoWrite State
**Captured from TodoWrite:**
- ✅ [Completed todo 1]
- [ ] [Incomplete todo - in WIP]

### Next Session
**Priority:** [Most important next action]
**Blockers:** [None / List blockers with details]
```

**Critical for AI Agents:**
- Problem Solved section - shows your thinking process
- Mental Models section - AI understands your approach
- Decisions linked to DECISIONS.md - full rationale
- Structured but comprehensive (40-60 lines, not 10 or 190)

#### context/STATUS.md - Current State (Single Source of Truth)

**Always update:**
- Current phase/focus - reflect where you are now
- Active tasks - update from TodoWrite state
- Work in progress - detailed WIP from current session
- Recent accomplishments - what you completed this session
- Next session priorities - what to do next
- Blockers and recent decisions

**This is the canonical source for "what's happening now"**

#### context/DECISIONS.md - Decision Log (For AI Agents)

**Update when significant decisions made:**

If you made an important technical decision this session:
1. Check if it's already documented
2. If not, add new entry using template format:
   ```markdown
   ## D[ID] - [Decision Title]

   **Date:** YYYY-MM-DD
   **Status:** Accepted
   **Session:** [N]

   ### Context
   [What problem? What constraints?]

   ### Decision
   [What did we decide?]

   ### Rationale
   [WHY this approach?]

   ### Alternatives Considered
   1. **[Alt 1]** - Pros/Cons/Why not

   ### Tradeoffs Accepted
   - ✅ [What we gain]
   - ❌ [What we give up]

   ### When to Reconsider
   [Triggers for revisiting]

   **For AI agents:** [Additional context AI needs]
   ```

3. Update Active Decisions table
4. Link from SESSIONS.md entry

**Critical:** DECISIONS.md enables AI agents to understand WHY you made choices, not just WHAT you implemented.

### Step 4: Update Optional Files (If They Exist)

Only update these if the file already exists:

#### context/PRD.md (if exists)
**Update if:** Product vision/roadmap changed
**Skip if:** Just implementation work

#### context/ARCHITECTURE.md (if exists)
**Update if:** Architectural changes made, new system design decisions
**Skip if:** No design changes

**Note:** These are the only optional files in v1.8.0. Other documentation needs are covered by core files:
- Decisions → DECISIONS.md (core file)
- Code style → CONTEXT.md preferences
- Known issues → STATUS.md blockers section

### Step 5: Update Quick Reference in STATUS.md

**Always update** - auto-generated dashboard section at top of STATUS.md:

**ACTION:** Use Edit tool to update the Quick Reference section in STATUS.md with current data from .context-config.json and STATUS.md content:

```bash
# Extract values from config and STATUS.md
PROJECT_NAME=$(jq -r '.project.name' context/.context-config.json)
CURRENT_PHASE=$(sed -n '/## Current Phase/,/^##/p' context/STATUS.md | grep "^**Phase:**" | sed 's/^**Phase:** //')
# ... (see /save command for full auto-population logic)

# Update Quick Reference section between markers in STATUS.md
# Section is between "## 📊 Quick Reference" and next "---"
```

**Fields auto-populated:**
- Project name, URLs, tech stack → from .context-config.json
- Current phase, status, active tasks → from STATUS.md content
- Documentation health → from last /validate-context run
- Last session → from SESSIONS.md

**Note:** In v2.1.0, Quick Reference is a section IN STATUS.md, not a separate file.

### Step 6: Suggest New Files (When Needed)

**On-demand enhancement** - suggest when complexity demands:

#### Check for ARCHITECTURE.md need:
```bash
FILE_COUNT=$(find src -type f 2>/dev/null | wc -l)
DIR_COUNT=$(find src -type d -maxdepth 2 2>/dev/null | wc -l)

if [ ! -f context/ARCHITECTURE.md ] && [ $FILE_COUNT -gt 20 ] && [ $DIR_COUNT -gt 5 ]; then
  echo "📐 Your architecture is getting complex (20+ files, 5+ directories)"
  echo "   Should I create ARCHITECTURE.md for AI agents to understand system design?"
  echo "   (y/n)"
fi
```

#### Check for PRD.md need:
Ask if:
- Product vision discussed multiple times
- Feature roadmap getting complex
- File doesn't exist yet

**Prompt:** "Product scope is expanding. Should I create PRD.md to document vision and roadmap for AI agent context?"

**v1.8.0 Note:** We only suggest ARCHITECTURE.md and PRD.md on-demand. DECISIONS.md is always created as core file #3.

### Step 7: Cross-Check Consistency

Quick verification that docs tell coherent story:
- Does STATUS.md reflect current reality?
- Are DECISIONS.md entries linked from SESSIONS.md?
- Is Quick Reference section in STATUS.md auto-updated correctly?
- Do files reference each other correctly?

If inconsistencies found → fix them.

### Step 7.5: Export JSON for Multi-Agent Workflows (Optional)

**ACTION:** If user provided `--with-json` flag, export SESSIONS.md to machine-readable JSON:

```bash
if [ "$WITH_JSON" = "true" ]; then
  echo ""
  echo "📊 Exporting JSON..."
  ./scripts/export-sessions-json.sh
  echo "   ✅ .sessions-data.json created"
fi
```

This creates `context/.sessions-data.json` with structured session history for:
- Multi-agent workflows (context handoff)
- External tooling and analytics
- Automated QA and reminders
- AI agent consumption without Markdown parsing

**Usage:** `/save-full --with-json` to include JSON export

**Note:** Optional - only run when you actually need JSON for automation/multi-agent workflows.

### Step 7.6: Git Push Protection - MANDATORY ENFORCEMENT

**🚨 CRITICAL: This is ENFORCED protection, not optional guidance**

**v2.2.0 FIX:** This section now BLOCKS git push operations unless explicitly approved.

#### Layer 1: Check Session Flag (MANDATORY - DO NOT SKIP)

```bash
# CHECK: Was PUSH_APPROVED flag set to true by /review-context?
# This flag is set to FALSE at session start
# It MUST be explicitly set to TRUE by user approval

if [ "${PUSH_APPROVED:-false}" != "true" ]; then
  echo ""
  echo "🚨━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "   GIT PUSH BLOCKED - NO APPROVAL"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "PUSH_APPROVED = false (set by /review-context)"
  echo ""
  echo "User must explicitly say:"
  echo '  - "push"'
  echo '  - "push to github"'
  echo '  - "deploy"'
  echo '  - "go ahead and push"'
  echo ""
  echo "Current action: Committing locally only"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # STOP HERE - Do NOT push
  # Commit locally and ask for approval
  exit 0
fi

echo "✅ PUSH_APPROVED = true (user explicitly approved)"
```

#### Layer 2: Double-Check User's Last Message

```
🚨 CHECKLIST - Answer ALL questions before proceeding:

1. Did user say "push" or "deploy" in their LAST message?
   [ ] Yes, user explicitly said to push
   [ ] No or unclear

2. Will this trigger a production deployment or consume build quota?
   [ ] Yes (requires approval)
   [ ] No

3. Do I have explicit permission for THIS SPECIFIC push?
   [ ] Yes, user approved in last message
   [ ] No or based on general workflow description

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 DECISION LOGIC:

If ANY answer is "No" or "unclear":
  ✅ STOP HERE
  ✅ Commit changes locally: git commit -m "..."
  ✅ Ask user: "Ready to push to GitHub? This will trigger [deployment/build]. Do you approve?"
  ✅ Wait for explicit "yes" / "push" / "approved" response
  ✅ Only then: git push

If ALL answers are "Yes":
  ✅ Verify by re-reading user's exact message
  ✅ Confirm approval is for THIS push (not a workflow description)
  ✅ Extract approval quote for auto-logging (see below)
  ✅ Then: git push

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  REMEMBER:
- General workflow instructions ≠ permission for this specific push
- "Then push to GitHub" in instructions = workflow description, NOT approval
- ALWAYS ask explicitly before every push
- Auto-log approval if granted (see below)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### Layer 3: Auto-Log Git Operations (Codex #7)

**If git operations occurred this session, auto-populate Git Operations section in SESSIONS.md:**

```bash
# Count commits in this session (approximation using recent history)
COMMITS=$(git rev-list --count HEAD@{1}..HEAD 2>/dev/null || echo "0")

# Detect if push occurred
PUSHED="NO"
APPROVAL="Not pushed"

# If push was executed:
if [ $PUSH_EXECUTED = true ]; then
  PUSHED="YES"

  # Extract approval quote from conversation
  # In actual implementation, this would parse the conversation log
  # For now, prompt to capture it:
  echo ""
  echo "📝 Git push executed. What was the user's approval message?"
  echo "   (Paste the exact quote where user approved the push):"
  read -r USER_APPROVAL

  APPROVAL="\"$USER_APPROVAL\" (user message)"
fi

# Add to SESSIONS.md entry in Git Operations section
echo ""
echo "### Git Operations"
echo "**MANDATORY - Auto-logged from conversation**"
echo ""
echo "- **Commits:** $COMMITS commits"
echo "- **Pushed:** $PUSHED"
echo "- **Approval:** $APPROVAL"
```

**Why auto-logging matters:**
- Removes manual copy-paste burden
- Ensures audit trail never missing
- Validates against git push protocol
- Reduces human error
- Provides evidence of approval compliance

#### Layer 4: Session Start Flag (for /review-context)

**At session start, set:**
```bash
PUSH_APPROVED=false
```

This flag must be explicitly set to true with user approval before ANY push.

**Approval phrases (from .context-config.json):**
- "push"
- "deploy"
- "go ahead and push"
- "yes push"

**NOT approval:**
- "save and push" in workflow description
- "then push" in instructions
- Any mention of push without explicit "do it now"

---

### Step 7.7: Organization Reminder ✨ v2.2.1

**PURPOSE:** Encourage clean project structure through gentle reminders

**ACTION:** Check for loose files and suggest organization when appropriate

```bash
# Count loose files in root (excluding allowed ones)
LOOSE_FILES=$(find . -maxdepth 1 -name "*.md" \
  ! -name "README.md" \
  ! -name "SECURITY.md" \
  ! -name "CONTRIBUTING.md" \
  ! -name "LICENSE.md" \
  ! -name "CHANGELOG.md" \
  ! -name "ORGANIZATION.md" \
  2>/dev/null | wc -l)

# Only show reminder if threshold exceeded
if [ "$LOOSE_FILES" -gt 2 ]; then
  echo ""
  echo "🧹━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "     ORGANIZATION REMINDER (v2.2.1)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Detected $LOOSE_FILES loose documentation file(s) in root."
  echo ""
  echo "💡 Good practice: File documentation in organized folders"
  echo ""
  echo "Suggested filing locations:"
  echo "  📁 Active planning     → docs/planning/"
  echo "  📁 Completed work      → artifacts/milestones/"
  echo "  📁 Old proposals       → artifacts/planning/"
  echo "  📁 Architecture docs   → docs/architecture/"
  echo "  📁 Meeting notes       → artifacts/notes/"
  echo ""
  echo "Next steps:"
  echo "  • Run /organize-docs for guided cleanup"
  echo "  • Or say 'skip organization' to continue"
  echo ""
  echo "See ORGANIZATION.md for complete guidelines"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
fi
```

**When this shows:**
- Only when loose files > 2 in root
- After /save-full completes successfully
- Not intrusive - easy to skip

**Why this matters:**
- Professional appearance
- Easier navigation
- Prevents clutter accumulation
- Maintains long-term project health

**Philosophy:**
- Gentle nudges, not enforcement
- Suggests solutions, doesn't block
- Promotes good habits over time
- See ORGANIZATION.md for guidelines

---

### Step 8: Report Updates

Clear, concise summary:

```
✅ Comprehensive Save Complete - Session [N]

**Core Updates:**
- SESSIONS.md - Comprehensive session log (Problem Solved, Mental Models, WIP)
- STATUS.md - Updated current tasks, blockers, next priorities, Quick Reference (auto-generated)
- DECISIONS.md - [Documented Decision D[ID] / No new decisions]
- [.sessions-data.json - Machine-readable export (if --with-json used)]

**Optional Updates:**
- [ARCHITECTURE.md - Updated system design / Skipped]
- [PRD.md - Updated roadmap / Skipped]

**For AI Agents:**
- Mental models captured in SESSIONS.md
- Decision rationale in DECISIONS.md
- [Machine-readable JSON available in .sessions-data.json]
- Full context available for review/takeover

**Time Invested:** ~10-15 minutes (comprehensive documentation)

**Current Status:** [One-sentence project status]

**Next Session:**
- Use /save for quick updates (2-3 min)
- Use /save-full again before next break/handoff
```

## Important Guidelines

### Update Philosophy

**Dual purpose in mind:**
- **For you:** Capture TodoWrite state, update STATUS.md, quick recovery
- **For AI agents:** Mental models, decision rationale, comprehensive context
- Write good session summary (SESSIONS.md 40-60 lines with depth)
- Document decisions with WHY (DECISIONS.md critical for AI)
- Everything else is optional

**Be structured AND comprehensive:**
- Structured format (scannable sections)
- But include depth (mental models, rationale, constraints)
- Include file paths and line numbers
- Capture the "why" not just the "what"
- Document WIP state precisely with mental model
- **Structured ≠ minimal** - AI agents need context

**Grow when needed:**
- Don't create files prematurely
- Suggest ARCHITECTURE/PRD when complexity warrants it
- DECISIONS.md is always core (AI agents need it)

**See:** `.claude/docs/save-context-guide.md` for philosophy, examples, best practices

### What to Always Capture

**Non-negotiable (Core Files):**
- **SESSIONS.md entry** - Comprehensive with mental models (40-60 lines)
- **STATUS.md update** - Current tasks, blockers, next priorities, Quick Reference section (auto-generated)
- **DECISIONS.md entry** - If significant decisions made (WHY)
- **Work in progress** state - Exact resume point with mental model
- **TodoWrite state** - Capture what was completed vs. pending

**Critical for AI agents:**
- Mental models - How you understand the system
- Decision rationale - WHY you chose this approach
- Problem-solving approach - How you tackled the issue
- Constraints - What limitations existed
- Gotchas discovered - Things that weren't obvious

**Can skip:**
- Optional files that didn't change (PRD, ARCHITECTURE)
- Sections that have no updates

### Work-In-Progress Capture (Critical!)

**Be specific about WIP:**
```markdown
**Work In Progress:**
- Implementing JWT refresh logic in `lib/auth.ts:145`
- Current approach: Using jose library for verification
- Next: Add refresh endpoint at `app/api/auth/refresh/route.ts`
- Mental model: Refresh in httpOnly cookie, access in memory
```

**Not this:**
```markdown
**Work In Progress:**
- Working on authentication
```

**Why:** Future Claude (or you) needs exact context to resume.

## Difference from Old Approach

**Old way (v1.6.2):**
- 50-step checklist
- Update all 8 files every time
- Bureaucratic process
- "Documentation for documentation's sake"

**v1.7.0:**
- Write session summary
- Update what changed
- Minimal approach (2 files)

**New way (v2.1.0 - Dual Purpose):**
- **Write comprehensive session summary** (40-60 lines with mental models, mandatory TL;DR)
- **Capture TodoWrite state + mental models for AI agents**
- **Document decision rationale** (DECISIONS.md)
- Update core 4 files (claude.md, CONTEXT, STATUS with auto-generated Quick Reference, DECISIONS)
- **Auto-generate Quick Reference section in STATUS.md**
- Structured but comprehensive
- **Enable AI agent review and takeover**
- **Auto-log git operations** for audit trail

## Success Criteria

✅ SESSIONS.md has comprehensive, structured entry (40-60 lines with mandatory TL;DR)
✅ Mental models captured for AI understanding
✅ TodoWrite state preserved
✅ WIP state captured precisely with mental model
✅ STATUS.md updated as single source of truth
✅ Quick Reference section in STATUS.md auto-generated
✅ DECISIONS.md updated if significant decisions made
✅ Git operations auto-logged in SESSIONS.md
✅ Can resume seamlessly next session
✅ **AI agents can review with full context**
✅ **AI agents can take over development with understanding**

## Time Investment

- Simple session: 3-5 minutes (comprehensive SESSIONS.md + STATUS.md with Quick Reference)
- Complex session with decisions: 5-8 minutes (+ DECISIONS.md entry)
- With new optional file: 8-12 minutes (create ARCHITECTURE/PRD/CODE_MAP)

**Worth every second** - enables perfect session continuity AND AI agent review/takeover.
