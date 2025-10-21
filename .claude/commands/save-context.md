---
name: save-context
description: "[DEPRECATED in v2.1 - WILL BE REMOVED in v2.3] Use /save or /save-full instead"
---

# /save-context Command

**⚠️ DEPRECATED - SCHEDULED FOR REMOVAL IN v2.3.0**

This command will be **permanently removed** in v2.3.0 (approximately 3 months after v2.2.0).

**Migrate now to:**
- **`/save`** - Quick save (2-3 min): Updates STATUS.md with auto-generated Quick Reference
- **`/save-full`** - Comprehensive save (10-15 min): Everything /save does + SESSIONS.md entry

**Why the change:**
- Naming confusion: users didn't know difference between `/save` and `/save-context`
- Better clarity: `/save` (quick) vs `/save-full` (comprehensive)
- Reduced maintenance: One less command to maintain

**For backward compatibility:** This command still works in v2.2.x but shows this warning

**See:** `DEPRECATIONS.md` for full removal timeline

---

## Original Command (v2.0 and earlier)

Update context documentation to reflect current state AND enable AI agent review/takeover. **Dual purpose:** low overhead for developer, rich context for AI agents.

**Philosophy:**
- Capture TodoWrite state for productivity tracking
- Extract mental models and decision rationale for AI agents
- Update what changed (not everything)
- Grow documentation when complexity demands

**Reference guide:** `.claude/docs/save-context-guide.md` (philosophy, examples, not a checklist)

## When to Use This Command

**Always save:**
- At session end (non-negotiable!)
- Before breaks (even 5-minute breaks)
- After completing work
- After making decisions

**Frequently save:**
- Every 30-60 minutes during active work
- When switching tasks

**Rule of thumb:** If unsure, run it. Better to save too often than lose context.

## What This Command Does

**Dual-purpose approach:**
1. **Captures TodoWrite state** - preserves your productivity tracking
2. **Extracts mental models** - AI agents understand your thinking
3. **Analyzes what changed** - updates only relevant files
4. **Documents decision rationale** - WHY choices were made (DECISIONS.md)
5. **Creates comprehensive session log** - structured with depth for AI (40-60 lines)
6. **Auto-generates Quick Reference in STATUS.md** - dashboard for fast orientation (v2.1: section, not separate file)
7. **Suggests new files** when complexity demands it
8. **Preserves work-in-progress** - exact resume point with mental model

**Not a checklist. Intelligent documentation for both you AND AI agents.**

## Execution Steps

### Step 1: Verify Context Exists

```
If context/ folder missing:
- Automatically run /init-context first
- Then proceed with save

If context/ exists:
- Proceed to Step 2
```

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

### Step 5: Auto-Generate Quick Reference in STATUS.md

**Note:** In v2.1, Quick Reference is a section within STATUS.md, not a separate file.

**Always generate** - provides fast orientation dashboard:

```markdown
# Quick Reference

**Auto-generated by `/save-context`** - Do not edit manually

---

## Project: [Project Name]

**Current:** [Phase] | **Session:** [N] | **Progress:** [X%]

## Tech Stack

- **Framework:** [e.g., Next.js 15]
- **Language:** [e.g., TypeScript]
- **Database:** [e.g., PostgreSQL]

## URLs

- **Production:** [URL]
- **Staging:** [URL]
- **Local:** [URL]
- **Repository:** [GitHub URL]

## Current Focus

**Phase:** [Phase name]
**Active Tasks:** [From STATUS.md]
**Next Priority:** [From STATUS.md]

## Quick Commands

```bash
[dev command]
[test command]
[build command]
```

## Context Navigation

- **Orientation:** `context/CONTEXT.md`
- **Current Status:** `context/STATUS.md`
- **Decision Log:** `context/DECISIONS.md`
- **Session History:** `context/SESSIONS.md`

---

**Last Updated:** [Timestamp]
**Next Session:** See STATUS.md → Work In Progress
```

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
- Is Quick Reference section in STATUS.md accurate?
- Do files reference each other correctly?

If inconsistencies found → fix them.

### Step 7.5: Export JSON for Multi-Agent Workflows

**ACTION:** Export SESSIONS.md to machine-readable JSON:

```bash
./scripts/export-sessions-json.sh
```

This creates `context/.sessions-data.json` with structured session history for:
- Multi-agent workflows (context handoff)
- External tooling and analytics
- Automated QA and reminders
- AI agent consumption without Markdown parsing

**Note:** This step is automatic and takes <1 second.

### Step 8: Report Updates

Clear, concise summary:

```
✅ Context Updated - Session [N]

**Core Updates:**
- SESSIONS.md - Comprehensive session log (Problem Solved, Mental Models, WIP)
- STATUS.md - Updated current tasks, blockers, next priorities
- DECISIONS.md - [Documented Decision D[ID] / No new decisions]
- Quick Reference section in STATUS.md - Auto-generated dashboard
- .sessions-data.json - Machine-readable export for multi-agent workflows

**Optional Updates:**
- [ARCHITECTURE.md - Updated system design / Skipped]
- [PRD.md - Updated roadmap / Skipped]

**For AI Agents:**
- Mental models captured in SESSIONS.md
- Decision rationale in DECISIONS.md
- Machine-readable JSON available in .sessions-data.json
- Full context available for review/takeover

**Current Status:** [One-sentence project status]

**Next Session:** [What to do next - from STATUS.md]
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
- **STATUS.md update** - Current tasks, blockers, next priorities
- **DECISIONS.md entry** - If significant decisions made (WHY)
- **Quick Reference section in STATUS.md** - Auto-generated dashboard
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

**New way (v1.8.0 - Dual Purpose):**
- **Write comprehensive session summary** (40-60 lines with mental models)
- **Capture TodoWrite state + mental models for AI agents**
- **Document decision rationale** (DECISIONS.md)
- Update core 3 files (CONTEXT, STATUS, DECISIONS)
- **Auto-generate Quick Reference section in STATUS.md**
- Structured but comprehensive
- **Enable AI agent review and takeover**

## Success Criteria

✅ SESSIONS.md has comprehensive, structured entry (40-60 lines)
✅ Mental models captured for AI understanding
✅ TodoWrite state preserved
✅ WIP state captured precisely with mental model
✅ STATUS.md updated as single source of truth
✅ DECISIONS.md updated if significant decisions made
✅ Quick Reference section in STATUS.md auto-generated
✅ Can resume seamlessly next session
✅ **AI agents can review with full context**
✅ **AI agents can take over development with understanding**

## Time Investment

- Simple session: 3-5 minutes (comprehensive SESSIONS.md + STATUS.md + Quick Reference section in STATUS.md)
- Complex session with decisions: 5-8 minutes (+ DECISIONS.md entry)
- With new optional file: 8-12 minutes (create ARCHITECTURE/PRD)

**Worth every second** - enables perfect session continuity AND AI agent review/takeover.
