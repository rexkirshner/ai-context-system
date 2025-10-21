---
name: review-context
description: Verify context documentation accuracy and session continuity readiness
---

# /review-context Command

Verify that all context documentation is accurate, consistent, and complete enough to resume work seamlessly. This is your session start ritual and continuity checkpoint.

**Full guide:** `.claude/docs/review-context-guide.md`

## When to Use This Command

**Primary use:** First thing at session start (always!)

**Other uses:**
- Before major decisions
- When feeling disoriented
- After someone else worked on project
- Before deployment/milestones
- When documentation feels stale

**See:** `.claude/docs/review-context-guide.md` - "When To Use This Command"

## What This Command Does

1. Loads all context documentation
2. Verifies accuracy against current code
3. Checks internal consistency
4. Assesses completeness for resuming work
5. Reports confidence level for continuity
6. Identifies gaps or issues

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

**Why this matters:** Provides access to performance-optimized functions, version checking, progress indicators, and standardized logging.

---

### Step 1: Verify Context Exists

```
If context/ folder missing:
- Report: "No context found. Run /init-context to set up."
- Stop execution

If context/ exists:
- Proceed to Step 1.5
```

### Step 1.5: Check for System Updates

**Check if newer version available on GitHub:**

**ACTION:** Use the Bash tool to check version using shared functions:

```bash
# Get current version (from .context-config.json or fallback to VERSION file)
CURRENT_VERSION=$(get_system_version)

# Fetch latest version from GitHub (with retry logic)
log_verbose "Checking for system updates..."
LATEST_VERSION=$(curl --connect-timeout 5 --max-time 10 -sL \
  https://raw.githubusercontent.com/rexkirshner/claude-context-system/main/VERSION 2>/dev/null | tr -d ' \n')

# Fallback to config file if VERSION file not found
if [ -z "$LATEST_VERSION" ]; then
  LATEST_VERSION=$(curl --connect-timeout 5 --max-time 10 -sL \
    https://raw.githubusercontent.com/rexkirshner/claude-context-system/main/config/.context-config.template.json \
    | grep -m 1 '"version":' | sed 's/.*"version": "\([^"]*\)".*/\1/' 2>/dev/null)
fi

# Compare versions
if [ -n "$LATEST_VERSION" ] && [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
  echo "UPDATE_AVAILABLE|$CURRENT_VERSION|$LATEST_VERSION"
else
  echo "UP_TO_DATE|$CURRENT_VERSION"
fi
```

**After running the check:**

**If output contains "UPDATE_AVAILABLE":**

Parse the versions and ask user:

```
📦 Update Available

Your Claude Context System: v[CURRENT_VERSION]
Latest on GitHub: v[LATEST_VERSION]

Would you like to update now? [Y/n]

(This will run /update-context-system)
```

**If user responds Y or yes:**
- Report: "Running /update-context-system..."
- **ACTION:** Execute the /update-context-system command
- After update completes, resume from Step 2 of this command

**If user responds n or no:**
- Report: "⏭️ Skipping update - continuing with context review"
- Note in final report: "System update available (v[LATEST_VERSION])"
- Continue to Step 2

**If output contains "UP_TO_DATE":**
- Silently continue to Step 2 (no message needed)

**If version check fails (network issue, etc.):**
- Silently continue to Step 2 (don't block review on network)

### Step 1.6: Critical Protocol Reminder

**🚨 Set session flags and remind about critical protocols:**

**ACTION:** Initialize session state and display critical reminders

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚨 CRITICAL PROTOCOL REMINDER - Session Start
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Git Push Permission Protocol:**

RULE: NEVER push to GitHub without explicit user permission.

Why this matters:
- Triggers builds (costs quota/money)
- Deploys to production (user controls timing)
- Trust issue (autonomous actions erode confidence)

SESSION FLAG SET:
PUSH_APPROVED = false

**v2.2.0 ENFORCEMENT:** This flag now BLOCKS git push in /save-full

HOW TO APPROVE (when user explicitly requests push):
1. User says "push", "deploy", or "push to github" in their message
2. Set: PUSH_APPROVED = true
3. Run /save-full (will check flag and allow push)

APPROVAL PHRASES (from .context-config.json):
✅ "push to github"
✅ "deploy this"
✅ "yes push"
✅ "go ahead and push"

NOT APPROVAL:
❌ "save and push" in workflow description
❌ "then push" in instructions
❌ Any mention of push without explicit "do it now"

BEFORE SETTING PUSH_APPROVED=true, ASK:
"Did the user say YES PUSH THIS in their LAST message?"

If NO → Keep PUSH_APPROVED=false, /save-full will block push
If YES → Set PUSH_APPROVED=true, verify by re-reading, auto-log approval

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**This reminder is displayed at session start to prevent git push violations.**

### Step 2: Load All Documentation

Read and parse all context files:

```
Files to load:
- context/CONTEXT.md (v2.0+) or context/CLAUDE.md (pre-v2.0)
- context/STATUS.md (v2.1+ includes Quick Reference section)
- context/DECISIONS.md
- context/SESSIONS.md (see smart loading strategy below)
- context/PRD.md (optional)
- context/CODE_MAP.md (optional, v2.1+)
- context/ARCHITECTURE.md (optional)
- context/CODE_STYLE.md (optional)
- context/KNOWN_ISSUES.md (optional)
- context/.context-config.json
```

**Note any missing files** - will affect confidence score.

#### SESSIONS.md Smart Loading Strategy (v2.2.0)

**Problem:** Large SESSIONS.md files (2000+ lines) cause timeouts or hit token limits

**Solution:** Strategic reading based on file size

```bash
# Check SESSIONS.md size first
log_verbose "Checking SESSIONS.md file size..."
SESSIONS_LINES=$(wc -l < context/SESSIONS.md 2>/dev/null || echo "0")

if [ "$SESSIONS_LINES" -lt 1000 ]; then
  # Small file: Read entirely
  log_info "Reading complete SESSIONS.md ($SESSIONS_LINES lines)"
  # Use Read tool on full file

elif [ "$SESSIONS_LINES" -lt 5000 ]; then
  # Medium file: Strategic reading
  log_info "📚 Medium SESSIONS.md detected ($SESSIONS_LINES lines)"
  log_info "Reading: Session index + last 2 sessions"

  # Read first 300 lines (session index + early sessions)
  # Use Read tool with: offset=0, limit=300

  # Read last 800 lines (most recent 2 sessions)
  # Calculate: offset = SESSIONS_LINES - 800
  # Use Read tool with: offset=(calculated), limit=800

  log_success "✅ Loaded index + recent sessions"
  log_info "💡 Run /session-summary for condensed full history"

else
  # Large file: Index + current session only
  log_info "📚 Large SESSIONS.md detected ($SESSIONS_LINES lines)"
  log_info "Reading: Index + current session only"

  # Read first 200 lines (index)
  # Use Read tool with: offset=0, limit=200

  # Read last 400 lines (current session)
  # Calculate: offset = SESSIONS_LINES - 400
  # Use Read tool with: offset=(calculated), limit=400

  # Show stats
  TOTAL_SESSIONS=$(grep -c "^## Session" context/SESSIONS.md)
  log_info "📊 File Statistics:"
  log_info "  - Total sessions: $TOTAL_SESSIONS"
  log_info "  - Total lines: $SESSIONS_LINES"
  log_info "  - Loaded: Index + latest session"
  log_info ""
  log_info "💡 Use /session-summary for full condensed history"
fi
```

**Why this works:**
- Session index at top shows all session titles
- Most recent session has current WIP state
- Avoids reading middle history (not needed for resuming)
- Prevents timeouts on large files

### Step 3: Check Current Code State

Analyze actual project state:

**Git state:**
```bash
git status
git log --oneline -5
git branch --show-current
git diff HEAD
```

**File system:**
```bash
ls -la
# Check key directories exist as documented
```

**Project info:**
- Read package.json (or equivalent)
- Verify tech stack matches documentation
- Check dependencies match ARCHITECTURE.md

### Step 4: Verify Documentation Accuracy

Check each file against reality:

#### CONTEXT.md Verification

**Getting Started section:**
- [ ] Verify links to STATUS.md, SESSIONS.md, DECISIONS.md work
- [ ] Check that orientation paths (5-min, 30-min) are accurate

**Tech Stack section:**
- [ ] Verify listed technologies match package.json (or equivalent)
- [ ] Check links to DECISIONS.md for rationale are correct

**High-Level Architecture section:**
- [ ] Verify architecture pattern matches actual implementation
- [ ] Check system diagram reflects current structure
- [ ] Confirm key components are accurately described

**Directory Structure section:**
- [ ] Check directories mentioned actually exist
- [ ] Verify file paths are correct
- [ ] Confirm folder structure matches description

**Environment Setup section:**
- [ ] Run listed commands to verify they exist (dev, test, build)
- [ ] Check prerequisites are accurate
- [ ] Verify environment variables section is current

**Issues found:**
- List specific inaccuracies
- Note severity (critical, minor, cosmetic)

#### PRD.md Verification

**Current Status:**
- [ ] Version number makes sense
- [ ] Phase status matches actual progress
- [ ] Timeline aligns with reality

**Progress Log:**
- [ ] Last entry date is recent
- [ ] Logged work matches git history
- [ ] Sessions are numbered correctly

**Implementation Plan:**
- [ ] Completed phases actually complete
- [ ] Current phase reflects actual work
- [ ] Roadmap is still relevant

**Issues found:**
- Note any disconnects from reality

#### ARCHITECTURE.md Verification

**System design:**
- [ ] Described architecture matches code structure
- [ ] Dependencies listed exist in package files
- [ ] Patterns described are actually used

**Data flow:**
- [ ] Matches actual implementation
- [ ] Integration points accurate

**Issues found:**
- Note architectural drift

#### DECISIONS.md Verification

**For each decision:**
- [ ] Decision is actually implemented
- [ ] Code follows documented choice
- [ ] Trade-offs mentioned are accurate

**Check for undocumented decisions:**
- Scan recent commits for major choices
- Look for framework/library additions
- Identify patterns not documented

**Issues found:**
- Missing decisions
- Contradicted decisions
- Outdated decisions

#### KNOWN_ISSUES.md Verification

**For each listed issue:**
- [ ] Issue still exists (check code)
- [ ] Severity is accurate
- [ ] Workaround still works if listed

**Check for resolved issues:**
- Scan git log for fixes
- Test known broken areas
- Verify workarounds

**Check for new issues:**
- Look for TODO comments
- Check for console errors (if applicable)
- Review recent bug reports

**Issues found:**
- Stale issues (already fixed)
- Missing new issues
- Incorrect severities

#### SESSIONS.md Verification

**Last session entry:**
- [ ] Entry exists and is recent
- [ ] Work described matches git log
- [ ] Files mentioned were actually modified
- [ ] WIP state is captured

**Session continuity:**
- [ ] Can identify exact resume point
- [ ] Understand context of last work
- [ ] Know what was in progress

**Issues found:**
- Missing entries
- Incomplete WIP capture
- Gap in session history

#### STATUS.md Verification (v2.1+)

**Quick Reference section (auto-generated):**
- [ ] Project info accurate (name, phase, status)
- [ ] URLs current (production, staging, repository)
- [ ] Tech stack summary matches CONTEXT.md
- [ ] Commands work (dev, test, build)
- [ ] Current focus reflects first active task
- [ ] Last session link works
- [ ] Documentation health timestamp recent

**Active Tasks section:**
- [ ] Tasks are accurate and current
- [ ] Completed items marked done
- [ ] Work In Progress section reflects reality
- [ ] Blockers are current
- [ ] Next session priorities make sense

**Check against actual state:**
- [ ] Matches git status and recent commits
- [ ] WIP location references exist
- [ ] Next actions are actionable

**Issues found:**
- Stale tasks
- Missing recent work
- Incorrect WIP state
- Quick Reference out of sync (needs /save or /save-full)

### Step 5: Check Cross-Document Consistency

Verify documentation tells coherent story:

**Status consistency:**
- [ ] STATUS.md Quick Reference section reflects current state
- [ ] STATUS.md matches latest SESSIONS.md entry
- [ ] Progress matches across docs
- [ ] Dates/versions align

**Technical consistency:**
- [ ] ARCHITECTURE.md reflects DECISIONS.md choices
- [ ] CODE_STYLE.md matches actual code patterns
- [ ] Tech stack consistent across docs

**Issue tracking consistency:**
- [ ] KNOWN_ISSUES.md blockers mentioned in STATUS.md
- [ ] Resolved issues removed from both
- [ ] New issues documented everywhere

**Timeline consistency:**
- [ ] Session numbers sequential in SESSIONS.md
- [ ] Progress log entries match session log
- [ ] Timestamps make sense

**Contradictions found:**
- List specific inconsistencies
- Note impact on continuity
- Identify which doc is correct

### Step 6: Assess Completeness

Evaluate if context is complete enough:

**Critical information present:**
- [ ] Can identify current project phase
- [ ] Know exact last work done
- [ ] Understand WIP state
- [ ] Have clear next actions
- [ ] Know all recent decisions
- [ ] Aware of current issues

**Gap analysis:**
- What information is missing?
- What would help resume work?
- What's unclear or ambiguous?

### Step 7: Calculate Confidence Score

Assess ability to resume work seamlessly:

**Scoring factors:**

- **Documentation completeness:** 0-30 points
  - All files present: 30
  - Missing files: -10 each

- **Accuracy:** 0-30 points
  - No inaccuracies: 30
  - Minor issues: -5 each
  - Major issues: -15 each

- **Consistency:** 0-20 points
  - No contradictions: 20
  - Minor contradictions: -5 each
  - Major contradictions: -10 each

- **Recency:** 0-20 points
  - Last update <1 day: 20
  - Last update 1-3 days: 15
  - Last update 3-7 days: 10
  - Last update >7 days: 0

**Total score:** 0-100

**Confidence levels:**
- 90-100: **Perfect** - Resume immediately with full confidence
- 75-89: **Good** - Resume with minor clarifications needed
- 60-74: **Adequate** - Review gaps before resuming
- 40-59: **Poor** - Significant catch-up required
- 0-39: **Critical** - Run /save-context immediately

### Step 8: Report Results

Provide comprehensive report:

```
📋 Context Review Report

**Confidence Score: [X]/100** - [Level]

[If update was available but skipped in Step 1.5]
📦 **System Update Available:** v[CURRENT] → v[LATEST]
   Run /update-context-system when convenient

✅ **Accurate Documentation:**
- CONTEXT.md - Architecture and setup verified
- STATUS.md - Current state matches reality (Quick Reference up to date)
- SESSIONS.md - Complete WIP capture with TL;DR summaries

⚠️ **Issues Found:**
- KNOWN_ISSUES.md - 2 resolved issues not removed
- DECISIONS.md - Missing recent JWT library choice
- STATUS.md - 1 completed task not marked done

❌ **Critical Gaps:**
- SESSIONS.md last entry 5 days old
- WIP state unclear for current task
- 3 recent commits not documented

**Last Session:** Session 12 - 2025-09-28
**Last Work:** Implementing JWT refresh logic (incomplete)
**Resume Point:** lib/auth.ts:145 - refresh token validation

**Recommendation:**
[If score >= 75] ✅ Ready to resume work immediately
[If score 60-74] ⚠️ Review gaps before continuing
[If score < 60] ❌ Run /save-context first to update

**Next Steps from docs:**
1. [Top priority from STATUS.md]
2. [Second priority]
3. [Third priority]

**Suggested Actions:**
- [If issues found] Update KNOWN_ISSUES.md to remove fixed items
- [If decisions missing] Document JWT library decision
- [If WIP unclear] Check git status and recent commits
- [If update available] Run /update-context-system to get latest improvements
```

### Step 9: Load Context into Working Memory

If confidence score >= 60, actively load context:

**Internalize key information:**
- Current project phase and goals
- Last work session details
- WIP state and exact resume point
- Recent decisions and rationale
- Current issues and blockers
- Immediate next actions

**Prepare for work:**
- Understand user preferences from CONTEXT.md
- Check STATUS.md for current priorities
- Review CODE_STYLE.md standards (if exists)
- Note any critical issues from KNOWN_ISSUES.md (if exists)
- Set mental context for continuation

**If score < 60:**
- Don't load potentially incorrect context
- Wait for /save-context to update first

## Important Guidelines

### Trust But Verify

**Trust the docs when:**
- Recent (last updated <48 hours)
- Consistent across files
- Match git history
- WIP clearly stated

**Verify against code when:**
- Last updated >3 days ago
- Contradictions found
- Major changes in git log
- Feeling uncertain

**See:** `.claude/docs/review-context-guide.md` - "The Trust But Verify Principle"

### Handling Issues

**Minor (score 75-89):** Note for user, proceed with work
**Moderate (score 60-74):** Recommend review before resuming
**Critical (score <60):** Do NOT resume, run /save-context first

**See:** `.claude/docs/review-context-guide.md` - "Common Scenarios"

## Success Criteria

✅ All documentation reviewed
✅ Accuracy verified against code
✅ Confidence score calculated
✅ Clear resume point identified
✅ User knows what to do next

**Perfect outcome:** Score 90-100, can state exact resume point, ready to continue seamlessly

**See:** `.claude/docs/review-context-guide.md` - "Success Criteria"

---

**Version:** 2.3.0
**Updated:** v2.3.0 - Integrated common-functions.sh for version checking, logging, and performance optimization
