# AI Context System v3.5.0 - Upgrade Proposal

**Date:** 2025-11-28
**Current Version:** 3.4.0
**Proposed Version:** 3.5.0
**Type:** MINOR - Bug fixes + Performance + Experience improvements

---

## Executive Summary

This upgrade proposal addresses **real-world feedback from 4 production projects** using AI Context System v3.4.0. The focus is on **fixing bugs, improving performance, and enhancing user experience** without adding unnecessary features or technical debt.

**Key Statistics:**
- **6 Critical Bugs** identified and need fixing
- **3 Performance bottlenecks** affecting long-running projects
- **15+ Experience improvements** validated across multiple projects
- **Zero feature bloat** - only addressing real user pain points

**Upgrade Philosophy:**
> Fix what's broken. Improve what slows users down. Make good experiences great. Don't add complexity for the sake of upgrading.

**Development Approach:**
> **Modular, Test-First Development** - Each fix is an isolated module with unit tests written before implementation. Modules can be developed in parallel, tested independently, and rolled back without affecting others. No "big bang" integration. Zero dependencies (except one intentional pair). Maximum quality, minimum risk.

**Key Implementation Features:**
- ✅ **24 Independent Modules** - Each self-contained and testable
- ✅ **Test-Driven Development** - Write tests BEFORE code
- ✅ **Quality Gates** - Can't merge without passing all tests
- ✅ **Parallel Development** - Multiple developers can work simultaneously
- ✅ **Safe Rollback** - Revert any module without breaking others
- ✅ **CI/CD Ready** - Automated testing on every commit
- ✅ **4 Test Levels** - Unit, Integration, Cross-Platform, Manual
- ✅ **Security Testing** - Command injection, path traversal checks

---

## 🎯 Implementation Progress

**Status:** ✅ COMPLETE (11/11 modules - All critical + performance modules done!)
**Started:** 2025-11-28
**Completed:** 2025-11-28
**Test Success Rate:** 100% (101/101 tests passing across 3 test levels)
**Phase:** Implementation & Testing Complete - Ready for Deployment!

### ✅ Completed Modules

**CRITICAL MODULES (7/7 COMPLETE - 100%):**
- ✅ **MODULE-001:** Version detection in `/init-context` (5/5 tests ✓) - Commit `50cddf9`
- ✅ **MODULE-002:** Version detection in `/update-context-system` (8/8 tests ✓) - Commit `4fd9b62`
- ✅ **MODULE-003:** Shell-compatible version check (8/8 tests ✓) - Commit `7bc2108`
- ✅ **MODULE-004:** Decision count grep fix (7/7 tests ✓) - Commit `4ae9fee`
- ✅ **MODULE-005:** ORGANIZATION.md download fix (4/4 tests ✓) - Commit `3003cef`
- ✅ **MODULE-006:** Smart SESSIONS.md loading (8/8 tests ✓) - Commit `9eef341`
- ✅ **MODULE-007:** Context folder auto-detection (6/6 tests ✓) - Commit `4033e82`

**PERFORMANCE MODULES (4/4 COMPLETE - 100%):**
- ✅ **MODULE-101:** SESSIONS.md archiving core logic (9/9 tests ✓) - Commit `62b31cb`
- ✅ **MODULE-102:** Auto-trigger archiving in /save-full (7/7 tests ✓) - Commit `6e73476`
- ✅ **MODULE-103:** Code review auto-report generation (8/8 tests ✓) - Commit `5adf017`
- ✅ **MODULE-104:** Cross-document consistency automation (8/8 tests ✓) - Commit `50ebb69`

**EXPERIENCE MODULES:**
- ⏳ 14 modules (deferred - critical/performance first)

### 📊 Quality Metrics

**Test Coverage:**
- Unit tests: 78/78 passing (11 modules, 100%)
- Integration tests: 12/12 passing (cross-module verification)
- Manual verification: 11/11 passing (actual execution)
- **Total: 101/101 tests passing (100%)**
- Cross-platform verified: bash 3.2+, zsh, sh (all ✓)
- Zero test failures
- Zero regressions

**Commits:**
- Feature commits: 11
- Test infrastructure: 3 (test-helpers.sh, test fixes, comprehensive suite)
- Total lines changed: ~3900 lines
- Files modified: 13 command files, 4 helper scripts, 1 installer
- Test files: 14 total (11 module tests + 3 test runners)

**Bugs Fixed:**
- ✅ BUG-1: Hardcoded version (3 fixes across modules 001-002)
- ✅ BUG-2: zsh parsing error (module 003)
- ✅ BUG-3: Integer expression error (module 004)
- ✅ BUG-4: Installation fails on small file (module 005)
- ✅ BUG-5: Token limit crash (module 006)
- ✅ BUG-6: Commands fail from subdirectories (module 007)

**Performance Improvements:**
- ✅ PERF-1: Large SESSIONS.md files (modules 101-102 - archiving foundation + auto-trigger)
- ✅ PERF-2: Manual report creation friction (module 103 - auto-generate code review reports)
- ✅ PERF-3: Manual consistency checking (module 104 - automated cross-document verification)

**Quality Gates Passed:**
- ✅ Unit tests written BEFORE implementation
- ✅ All tests passing before commit
- ✅ Manual verification complete
- ✅ Documentation updated inline
- ✅ Modular isolation verified
- ✅ Rollback strategy documented
- ✅ Bash 3.2 compatibility verified

### 🎯 Next Steps

**✅ CRITICAL + PERFORMANCE COMPLETE** - All 11 modules implemented and tested!

**✅ COMPREHENSIVE TESTING COMPLETE:**
1. ✅ Unit tests: 78/78 passing (all modules tested in isolation)
2. ✅ Integration tests: 12/12 passing (cross-module verification)
3. ✅ Manual verification: 11/11 passing (actual script execution)
4. ✅ Cross-platform: bash 3.2+ compatibility confirmed
5. ✅ Regression testing: no existing features broken

**Total: 101/101 tests passing (100%)** - Commit `f2e0073`

**Later (Experience Modules - 14 total):**
- Optional UX improvements
- Can be implemented in future releases if needed
- Not required for v3.5.0 release

**Ready For:** Version bump, release preparation, deployment

---

## Feedback Analysis Summary

**Sources Analyzed:**
- Project A: Web application (Portfolio tracker, 11 sessions)
- Project B: Content platform (Prompt library, 16 sessions)
- Project C: Professional website (Project Alpha, 9 sessions)
- Project D: AI Context System itself (dogfooding)

**Total Feedback Items:** 60+ entries
**Valid for v3.5.0:** 24 items
**Deferred to Future:** 12 items
**User-Specific (Not Applicable):** 24 items

---

## Category 1: Critical Bugs (MUST FIX)

### BUG-1: `/init-context` Hardcoded Version Number

**Severity:** 🟡 Moderate (confusing UX, incorrect documentation from start)
**Reported By:** Project D (Context System itself)
**Frequency:** Affects all new installations

**Problem:**
- Config template (`config/.context-config.template.json`) has hardcoded `"version": "3.0.0"`
- When users install v3.4.0, their config shows v3.0.0
- Creates version mismatch confusion
- `/review-context` reports false positive "update available"

**Impact:**
- Users think they need to update when already current
- Documentation starts with incorrect version
- Erodes trust in version checking

**Root Cause:**
```json
// config/.context-config.template.json (line 2, line 242)
{
  "version": "3.0.0",  // ❌ Hardcoded
  // ...
  "metadata": {
    "configVersion": "3.0.0"  // ❌ Hardcoded
  }
}
```

**Solution:**
```bash
# In .claude/commands/init-context.md (Step 5)
# Detect system version and substitute in config
SYSTEM_VERSION=$(cat VERSION 2>/dev/null || echo "unknown")
cp config/.context-config.template.json context/.context-config.json
sed -i.bak "s/\"3.0.0\"/\"$SYSTEM_VERSION\"/g" context/.context-config.json
rm context/.context-config.json.bak
echo "✅ Configuration created with version $SYSTEM_VERSION"
```

**Files to Change:**
- `.claude/commands/init-context.md` - Add version detection step
- `config/.context-config.template.json` - Consider placeholder approach
- `.claude/commands/update-context-system.md` - Ensure version updates config

**Test Cases:**
1. Install v3.4.0 → config shows 3.4.0 ✅
2. Run /review-context → no false update warning ✅
3. Upgrade 3.4.0 → 3.5.0 → config updates correctly ✅

---

### BUG-2: `/review-context` Version Check Shell Parsing Error

**Severity:** 🟡 Moderate (blocks version checking feature)
**Reported By:** Project B (Project Beta)
**Frequency:** macOS/zsh users (significant user base)

**Problem:**
```bash
# Current implementation fails on macOS zsh:
CURRENT_VERSION=$(get_system_version)
# Error: (eval):1: parse error near `)'
```

**Impact:**
- Version check completely broken on macOS
- Users miss update notifications
- Breaks non-critically, review continues but feature lost

**Root Cause:**
- `get_system_version` function from `common-functions.sh` has zsh incompatibility
- Function may not be properly sourced/exported
- Complex function call when simple file read would work

**Solution:**
```bash
# Replace complex function with simple file read
CURRENT_VERSION=$(cat VERSION 2>/dev/null || grep -m 1 '"version":' context/.context-config.json | sed 's/.*"version": "\([^"]*\)".*/\1/' 2>/dev/null || echo "unknown")

# Fallback chain:
# 1. Try VERSION file (most reliable)
# 2. Try config file (backup)
# 3. Default to "unknown" (graceful degradation)
```

**Why This Fix Is Better:**
- No function dependency
- Works on bash, zsh, sh
- Clear fallback chain
- Handles missing files gracefully

**Files to Change:**
- `.claude/commands/review-context.md` - Step 1.5 version check
- `scripts/common-functions.sh` - Document zsh incompatibility or fix function

**Test Cases:**
1. macOS zsh → version check succeeds ✅
2. Linux bash → version check succeeds ✅
3. Missing VERSION file → falls back to config ✅
4. Both missing → returns "unknown" without error ✅

---

### BUG-3: `/review-context` Decision Count Grep Error

**Severity:** 🟢 Minor (cosmetic, functionality works)
**Reported By:** Project B (Project Beta)

**Problem:**
```bash
# Produces integer expression error:
(eval):[:17: integer expression expected: 0\n0
# grep -c outputs "0\n0" instead of "0"
```

**Impact:**
- Ugly error messages during review
- Correct count still produced, but noisy output

**Solution:**
```bash
# Current:
DECISION_COUNT=$(grep -c "^### D[0-9]" "$CONTEXT_DIR/DECISIONS.md" 2>/dev/null || echo "0")

# Fixed:
DECISION_COUNT=$(grep "^### D[0-9]" "$CONTEXT_DIR/DECISIONS.md" 2>/dev/null | wc -l | tr -d ' ')

# Or:
DECISION_COUNT=$(grep -c "^### D[0-9]" "$CONTEXT_DIR/DECISIONS.md" 2>/dev/null | head -1 || echo "0")
```

**Files to Change:**
- `.claude/commands/review-context.md` - Step 2.7 decision documentation check

---

### BUG-4: Installation Script - ORGANIZATION.md Download Failure

**Severity:** 🟢 Minor (doesn't block install, but creates uncertainty)
**Reported By:** Project B (Project Beta), Project C (Project Alpha)

**Problem:**
```bash
# During install.sh:
Downloading: reference/ORGANIZATION.md
Error: file too small: 14 bytes
Installation completed with errors
```

**Impact:**
- Users uncertain if install succeeded
- "Completed with errors" is alarming even if non-critical

**Root Cause:**
- ORGANIZATION.md on GitHub may be placeholder/stub
- Installer has minimum file size check (14 bytes triggers failure)
- File is optional but failure looks critical

**Solution:**

**Option 1: Fix the file**
```bash
# Ensure ORGANIZATION.md has real content (>100 bytes)
# Update reference/ORGANIZATION.md on GitHub
```

**Option 2: Make it truly optional**
```bash
# In install.sh:
OPTIONAL_FILES="reference/ORGANIZATION.md"
# Skip size check for optional files
# Don't count in error tally
```

**Option 3: Remove from manifest**
```bash
# If file isn't essential, don't download it
# User can create their own ORGANIZATION.md
```

**Recommendation:** Option 1 + Option 2 (fix file AND make optional)

**Files to Change:**
- `install.sh` - Optional files handling
- `reference/ORGANIZATION.md` - Ensure real content

---

### BUG-5: Large SESSIONS.md File Handling in `/review-context`

**Severity:** 🟡 Moderate (blocks review on mature projects)
**Reported By:** Project A (Project Gamma, 28K tokens after 6 sessions)

**Problem:**
```
File content (28105 tokens) exceeds maximum allowed tokens (25000)
Read tool fails during /review-context execution
```

**Impact:**
- Manual intervention required (offset/limit parameters)
- Breaks "follow the command" flow
- Gets worse over time (more sessions = larger file)
- Will become critical for projects with 20+ sessions

**Current Workaround:**
```bash
# User has to manually:
Read SESSIONS.md offset=1 limit=500    # First chunk
Read SESSIONS.md offset=2650 limit=500 # Last chunk
```

**Solution Implemented in v3.3.0 (But Needs Documentation):**
The command already has smart loading strategy:
- <1000 lines: full read
- 1000-5000 lines: strategic (index + recent)
- >5000 lines: minimal (index + current only)

**But This Doesn't Work for Token Limits!**

**Enhanced Solution:**
```bash
# Step 2.3: Read SESSIONS.md (Smart Loading)

# First, check file size
FILE_SIZE=$(wc -l < "$CONTEXT_DIR/SESSIONS.md" 2>/dev/null || echo "0")

if [ "$FILE_SIZE" -lt 1000 ]; then
  # Small file: read fully
  Read context/SESSIONS.md
elif [ "$FILE_SIZE" -lt 5000 ]; then
  # Medium file: strategic read
  # Read first 300 lines (index + early sessions)
  Read context/SESSIONS.md limit=300
  # Read last 500 lines (most recent session)
  Read context/SESSIONS.md offset=$((FILE_SIZE - 500)) limit=500
else
  # Large file: minimal read
  # Read first 200 lines (index only)
  Read context/SESSIONS.md limit=200
  # Read last 300 lines (current session only)
  Read context/SESSIONS.md offset=$((FILE_SIZE - 300)) limit=300
fi

echo "📖 Read SESSIONS.md (smart loading: $FILE_SIZE lines)"
```

**Why This Works:**
- Automatically handles any file size
- No manual intervention
- Most important content: index (top) + recent session (bottom)
- Scales to 100+ session projects

**Files to Change:**
- `.claude/commands/review-context.md` - Step 2.3 SESSIONS.md loading
- Add warning in report if file is very large (>5000 lines)

---

### BUG-6: Context Folder Location Detection

**Severity:** 🟢 Minor (usability issue in monorepos/subdirectories)
**Reported By:** Project A (Project Gamma)

**Problem:**
```bash
# When working directory is backend/ or frontend/:
ls -la context/
# Error: Context folder does not exist

# Context is actually at ../context/
```

**Impact:**
- Commands fail when run from subdirectories
- Monorepos and multi-directory projects affected
- Manual path adjustment required

**Solution:**
```bash
# Create scripts/find-context-folder.sh (ALREADY EXISTS!)
# Just need to use it consistently across all commands

find_context_folder() {
  if [ -d "context" ]; then
    echo "context"
  elif [ -d "../context" ]; then
    echo "../context"
  elif [ -d "../../context" ]; then
    echo "../../context"
  else
    # Search up to 5 levels
    for i in {1..5}; do
      PREFIX=$(printf '../%.0s' $(seq 1 $i))
      if [ -d "${PREFIX}context" ]; then
        echo "${PREFIX}context"
        return 0
      fi
    done
    echo "❌ Context folder not found. Run /init-context first."
    exit 1
  fi
}

CONTEXT_DIR=$(find_context_folder)
```

**Files to Change:**
- Audit all commands for context/ references
- Replace with `$(find_context_folder)` or source `scripts/find-context-folder.sh`
- Commands to update: `/save`, `/save-full`, `/review-context`, `/validate-context`, `/export-context`

---

## Category 2: Performance Improvements

### PERF-1: SESSIONS.md Archiving Strategy

**Severity:** 🟡 Moderate (critical for long-running projects)
**Reported By:** Project B (Project Beta, 16 sessions), Project C (Project Alpha, 9 sessions)
**Frequency:** All projects eventually hit this

**Problem:**
- SESSIONS.md grows indefinitely (50+ lines per session)
- After 20+ sessions: 1000+ lines, hard to navigate
- After 50+ sessions: 2500+ lines, token limit issues
- No built-in archiving mechanism

**Impact:**
- File becomes unwieldy
- Context load times increase
- Hard to find specific sessions
- Eventually hits token limits

**Solution: Hybrid Archiving Approach**

**Automatic Archiving (Recommended):**
```bash
# Trigger in /save-full when SESSIONS.md > 2000 lines

# Step 0.5: Check if archiving needed
LINE_COUNT=$(wc -l < context/SESSIONS.md)
if [ "$LINE_COUNT" -gt 2000 ]; then
  echo "📦 SESSIONS.md is large ($LINE_COUNT lines). Archiving old sessions..."

  # Create archive file
  ARCHIVE_FILE="context/SESSIONS-archive-$(date +%Y).md"

  # Move sessions 1-(N-10) to archive
  # Keep last 10 sessions in main file

  # Extract sessions to archive (implementation details below)
  # Update main SESSIONS.md to keep only recent 10
  # Add reference to archive in main file

  echo "✅ Archived old sessions to $ARCHIVE_FILE"
  echo "   Main SESSIONS.md now has last 10 sessions only"
fi
```

**Manual Archiving (User Control):**
```bash
# New command: /archive-sessions
# Prompts user:
# "Archive sessions older than N? (keep last 10) [y/N]"
# Creates SESSIONS-archive-YYYY.md
# Updates main SESSIONS.md
```

**Archive File Structure:**
```markdown
# Archived Sessions - 2025

**Archived:** 2025-11-28
**Sessions:** 1-11
**See:** [SESSIONS.md](./SESSIONS.md) for recent sessions

---

## Session Index (Archived)
[Full session index with links]

---

[Full session entries 1-11]
```

**Main SESSIONS.md Structure After Archiving:**
```markdown
# Sessions

**📦 Archived Sessions:** See [SESSIONS-archive-2025.md](./SESSIONS-archive-2025.md) for sessions 1-11

## Session Index

**Recent Sessions:**
- Session 12 | 2025-11-20 | Feature X
- Session 13 | 2025-11-22 | Bug Fix Y
[...sessions 12-21]

**Archived Sessions:**
- Sessions 1-11: See archive file

---

[Full entries for sessions 12-21 only]
```

**Benefits:**
- Keeps main file under 1000 lines
- Complete history preserved
- Easy navigation (clear archive references)
- Scales to 100+ sessions

**Implementation Details:**
1. Detect line count threshold (2000 lines = ~35-40 sessions)
2. Calculate sessions to archive (all except last 10)
3. Extract session entries by parsing `## Session N |` headers
4. Create archive file with full entries
5. Update main SESSIONS.md with archive reference + recent sessions only
6. Maintain complete session index in both files

**Files to Change:**
- `.claude/commands/save-full.md` - Add archiving check (Step 0.5)
- Create `.claude/commands/archive-sessions.md` - New manual command
- Update `templates/SESSIONS.template.md` - Document archiving

**Test Cases:**
1. Project with 40 sessions → archives sessions 1-30, keeps 31-40 ✅
2. Archive file has complete sessions 1-30 ✅
3. Main file has reference to archive ✅
4. Session index updated in both files ✅

---

### PERF-2: `/code-review` Auto-Generate Report Document

**Severity:** 🟡 Moderate (major UX improvement, prevents lost reviews)
**Reported By:** Project B (Project Beta)
**Frequency:** Every code review

**Problem:**
- `/code-review` produces excellent analysis in chat
- User must manually ask for report document
- "let's create a full detailed report document, put it in artifacts/code-reviews"
- Manual step adds friction and inconsistency

**Impact:**
- Reviews lost when chat scrolls away
- No historical tracking of reviews
- Inconsistent report formatting
- Manual work after comprehensive analysis

**Current Behavior:**
```bash
/code-review
# Outputs comprehensive analysis to chat ✅
# Grade: B+ with detailed findings ✅
# Recommendations provided ✅
# BUT: No file created ❌
```

**Expected Behavior:**
```bash
/code-review
# Outputs comprehensive analysis to chat ✅
# Grade: B+ with detailed findings ✅
# Recommendations provided ✅
# Automatically creates artifacts/code-reviews/session-N-review.md ✅
# Notifies: "📄 Detailed report saved to artifacts/code-reviews/session-14-review.md" ✅
```

**Solution:**
```bash
# In .claude/commands/code-review.md (after analysis)

# Step 6: Save Report to Artifacts
echo "💾 Saving detailed report..."

# Determine session number
SESSION_NUM=$(grep -c "^## Session" context/SESSIONS.md || echo "unknown")

# Create artifacts/code-reviews/ if needed
mkdir -p artifacts/code-reviews

# Generate report file
REPORT_FILE="artifacts/code-reviews/session-${SESSION_NUM}-review.md"

# Write comprehensive report (use v3.4.0 enhanced format)
cat > "$REPORT_FILE" << 'EOF'
# Code Review Report - Session $SESSION_NUM

**Date:** $(date +%Y-%m-%d)
**Grade:** [GRADE]
**Reviewer:** AI Context System v3.5.0

---

## Executive Summary

[Analysis summary]

---

## Findings

[Detailed findings with smart grouping]

---

## Recommendations

[Actionable recommendations]

---

## Review History

- Previous review: [link if exists]
- Next review: [placeholder]

EOF

echo "✅ Report saved: $REPORT_FILE"
echo ""
echo "📄 Detailed report available at: $REPORT_FILE"
```

**Enhanced: Integrate v3.4.0 Features**
The report should include:
- Smart issue grouping ✅ (already in v3.4.0)
- Auto-generated TodoWrite tasks ✅ (already in v3.4.0)
- KNOWN_ISSUES.md integration ✅ (already in v3.4.0)
- STATUS.md auto-update ✅ (already in v3.4.0)
- Review history (INDEX.md) ✅ (already in v3.4.0)
- **NEW:** Automatic report file creation

**Files to Change:**
- `.claude/commands/code-review.md` - Add Step 6 (Save Report)
- Use existing `scripts/code-review-helpers.sh` functions
- Template: Use format from real session-14-review.md as reference

**Benefits:**
- Zero manual work
- Consistent formatting
- Historical tracking
- Easy comparison between reviews
- Completes the v3.4.0 vision

---

### PERF-3: Cross-Document Consistency Automation

**Severity:** 🟢 Minor (improves quality, not blocking)
**Reported By:** Project A (Project Gamma)

**Problem:**
- `/review-context` says "Check cross-document consistency"
- But verification is mostly manual visual comparison
- Easy to miss discrepancies (tech stack, dates, phase)

**Example Manual Checks:**
```markdown
- [ ] STATUS.md Quick Reference reflects current state
- [ ] STATUS.md matches latest SESSIONS.md entry
- [ ] Progress matches across docs
- [ ] Dates/versions align
```

**Solution: Automated Consistency Checks**
```bash
# In /review-context Step 2.8: Cross-Document Consistency

echo "🔍 Automated consistency checks..."

# 1. Last Updated Dates
CONTEXT_DATE=$(grep "Last Updated:" context/CONTEXT.md | sed 's/.*: //')
STATUS_DATE=$(grep "Last Updated:" context/STATUS.md | sed 's/.*: //')
SESSIONS_DATE=$(grep "Last Updated:" context/SESSIONS.md | sed 's/.*: //')

echo "Last Updated Dates:"
echo "  CONTEXT.md:  $CONTEXT_DATE"
echo "  STATUS.md:   $STATUS_DATE"
echo "  SESSIONS.md: $SESSIONS_DATE"

# Check alignment (STATUS and SESSIONS should be close)
# Warn if CONTEXT is >30 days behind STATUS

# 2. Current Phase
CONTEXT_PHASE=$(grep "Phase:" context/CONTEXT.md | sed 's/.*Phase: //')
STATUS_PHASE=$(grep "Phase:" context/STATUS.md | sed 's/.*Phase: //')

if [ "$CONTEXT_PHASE" != "$STATUS_PHASE" ]; then
  echo "⚠️  Phase drift detected:"
  echo "    CONTEXT.md: $CONTEXT_PHASE"
  echo "    STATUS.md:  $STATUS_PHASE"
fi

# 3. Tech Stack Validation
# Extract tech stack from CONTEXT.md
# Verify against package.json, requirements.txt, etc.

# 4. Session Count
SESSION_COUNT=$(grep -c "^## Session" context/SESSIONS.md)
CONFIG_COUNT=$(grep "sessionCount" context/.context-config.json | sed 's/.*: //' | tr -d ',')

if [ "$SESSION_COUNT" != "$CONFIG_COUNT" ]; then
  echo "⚠️  Session count mismatch:"
  echo "    SESSIONS.md: $SESSION_COUNT sessions"
  echo "    Config:      $CONFIG_COUNT sessions"
fi
```

**Files to Change:**
- `.claude/commands/review-context.md` - Enhance Step 2.8 with automation

**Benefits:**
- Catches drift automatically
- Specific, actionable warnings
- No manual comparison needed

---

## Category 3: Experience Improvements

### EXP-1: `reference/` Folder Should Be `docs/reference/`

**Severity:** 🟢 Minor (organization quality)
**Reported By:** Project B (Project Beta), Project C (Project Alpha)
**Frequency:** All new installations

**Problem:**
- Installation creates `reference/` at project root
- ORGANIZATION.md (if exists) recommends `docs/reference/`
- Inconsistent with standard project structure conventions
- Clutters root directory

**Expected Structure:**
```
project-root/
├── docs/
│   ├── reference/        # ✅ Clear it's documentation
│   ├── planning/
│   └── guides/
├── src/
├── context/
└── README.md
```

**Current Structure:**
```
project-root/
├── reference/            # ❌ What is this? Clutters root
├── docs/                 # User creates separately
├── context/
└── README.md
```

**Solution:**
```bash
# In install.sh:
# Change:
REFERENCE_DIR="reference"

# To:
REFERENCE_DIR="docs/reference"

# Ensure docs/ directory exists:
mkdir -p docs/reference

# Copy reference files:
cp -r ai-context-system/reference/* docs/reference/
```

**Migration for Existing Users:**
```bash
# In /update-context-system:
# Check if old location exists
if [ -d "reference" ] && [ ! -d "docs/reference" ]; then
  echo "📦 Moving reference/ to docs/reference/ (recommended structure)"
  mkdir -p docs
  mv reference docs/
  echo "✅ Migrated: reference/ → docs/reference/"
fi
```

**Files to Change:**
- `install.sh` - Change destination directory
- `.claude/commands/update-context-system.md` - Add migration step
- Update any documentation referencing `reference/` path

---

### EXP-2: `/review-context` Auto-Trigger `/save` for Stale Quick Reference

**Severity:** 🟢 Minor (nice quality of life)
**Reported By:** Project B (Project Beta)

**Problem:**
- `/review-context` finds STATUS.md Quick Reference has template placeholders
- Docks confidence score points
- User has to manually run `/save` to fix
- Two commands when one would do

**Solution:**
```bash
# In /review-context final report (Step 8)

if [[ "$ISSUES" == *"Quick Reference contains template placeholders"* ]]; then
  echo ""
  echo "💡 Quick Fix Available:"
  echo "Your STATUS.md Quick Reference contains template placeholders."
  echo "I can run /save now to populate it automatically."
  echo ""
  read -p "Run /save to fix this? [Y/n] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
    echo "Running /save..."
    # Execute /save command
    # Rerun confidence score check
    echo "✅ Quick Reference updated. Confidence score improved."
  fi
fi
```

**Benefits:**
- One-click fix for deterministic issue
- Teaches users about auto-generation feature
- Improves confidence score immediately
- Reduces friction

**Files to Change:**
- `.claude/commands/review-context.md` - Add interactive fix option

---

### EXP-3: ARCHITECTURE.md Integration in `/save-full`

**Severity:** 🟢 Minor (improves documentation completeness)
**Reported By:** Project B (Project Beta)

**Problem:**
- ARCHITECTURE.md not mentioned in `/save-full` workflow
- Easy to forget updating after architectural changes
- Not part of 10-step process
- Becomes stale

**Solution:**
```markdown
## Step 5.5/10: Review ARCHITECTURE.md (if exists)

Check if architectural changes warrant update:

**Trigger points:**
- Added new system/module?
- Changed data model significantly?
- Introduced new architectural pattern?
- Modified system boundaries or dependencies?

**If yes, update ARCHITECTURE.md with:**
- New system components and their responsibilities
- Updated architecture diagrams (if applicable)
- Modified data flows or integration points
- Changed technology stack components

**If no architectural changes:** Skip this step

**If ARCHITECTURE.md doesn't exist but project is complex (>20 files):**
Consider creating it. Run `/init-context` includes guidance on when ARCHITECTURE.md is beneficial.
```

**Files to Change:**
- `.claude/commands/save-full.md` - Add optional Step 5.5

---

### EXP-4: Decision Documentation Prompts

**Severity:** 🟢 Minor (improves decision tracking)
**Reported By:** Project B (Project Beta), Project C (Project Alpha)

**Problem:**
- Easy to forget documenting decisions during flow of work
- DECISIONS.md guidance comes late in workflow
- Have to backfill decisions (context not fresh)

**Solution 1: Enhanced /save-full Prompt**
```markdown
## Step 5: Update DECISIONS.md (if applicable)

**STOP and ask yourself:**
"Did I make any architectural decisions this session?"

**Examples of decisions:**
- Library/framework choices (chose X over Y)
- Performance strategies (caching approach, indexing)
- Data model changes (added field, changed relationship)
- Security approaches (authentication method, encryption)
- Process changes (deployment, testing, workflow)
- Design patterns (hooks vs classes, microservices vs monolith)

**If yes:** Document using D0XX format

**Format:**
### D0XX | [Category] | [Date]
**Decision:** [What you decided]
**Why:** [Rationale and constraints]
**Alternatives Considered:** [What you didn't choose and why]
**Trade-offs:** [Benefits vs costs]
**Status:** ✅ Implemented / 🔄 In Progress / ❌ Rejected

**If unsure:** Ask yourself "Would future developers wonder why I did this?"
```

**Solution 2: Add to CLAUDE.md Header**
```markdown
## 🔔 Decision Documentation Reminder

When making architectural choices, ask yourself:
"Should I document this in DECISIONS.md?"

**Document if:**
- This is something future developers will wonder about
- You considered alternatives
- There are trade-offs involved
- The decision has long-term impact

**Tip:** Document decisions WHILE making them (context is fresh)
```

**Files to Change:**
- `.claude/commands/save-full.md` - Enhance Step 5 with checklist
- `templates/claude.md.template` - Add decision reminder

---

### EXP-5: Session Navigation Index (Auto-Generated)

**Severity:** 🟢 Minor (nice-to-have for 20+ session projects)
**Reported By:** Project B (Project Beta), Project C (Project Alpha)

**Problem:**
- Hard to find specific sessions by topic/feature
- Manual search through SESSIONS.md
- Session Index table exists in template but not actively maintained

**Solution:**
```bash
# Auto-generate session index during /save-full

# Step 2.5: Update Session Index
echo "📑 Generating session index..."

# Extract session headers and TL;DRs
SESSIONS=$(grep -A 2 "^## Session" context/SESSIONS.md)

# Parse into index format
# Group by: Feature, Issue Type, Decision

# Write to top of SESSIONS.md
cat > context/SESSIONS.tmp << 'EOF'
# Sessions

## Session Index (Auto-Generated)

**By Feature:**
[Auto-extracted from session TL;DRs and tags]

**By Issue Type:**
[Auto-extracted from session content]

**By Decision:**
[Auto-extracted from DECISIONS.md cross-references]

---

[Existing session entries]
EOF

mv context/SESSIONS.tmp context/SESSIONS.md
```

**Simpler Alternative:**
```bash
# Just generate a flat index with links
# No complex categorization

## Session Index

- Session 16 | 2025-11-27 | Type System Enhancements (#session-16)
- Session 15 | 2025-11-25 | Security Fixes C1-C6 (#session-15)
- Session 14 | 2025-11-23 | Code Quality Improvements (#session-14)
[...]
```

**Files to Change:**
- `.claude/commands/save-full.md` - Add index generation (optional)
- Or create separate `/generate-session-index` command

**Recommendation:** Start with simple flat index. Add categorization in v3.6.0 if users request it.

---

### EXP-6: Mental Models "Apply This When..." Enhancement

**Severity:** 🟢 Minor (makes patterns actionable)
**Reported By:** Project A (Project Gamma)

**Problem:**
- Mental Models section documents patterns well
- But doesn't explain when to apply pattern vs when not to
- AI agents might misapply patterns

**Solution:**
```markdown
### Mental Models

**Current understanding:**
[Existing mental model description]

**Apply This When:**
- Pattern: [Name of pattern]
- Use when: [Specific scenarios]
- DON'T use when: [Anti-patterns, exceptions]
- Example: [Next feature that should use this pattern]
- Benefit: [Why this pattern works here]

**Example:**
**React Hooks Architecture:**
- Pattern: Custom hooks encapsulate data fetching + state management
- Use when: Adding new data sources (wallets, entities, prices)
- DON'T use when: One-off operations, non-reusable logic, side effects
- Example: Next step would be `usePrices()` hook, not inline fetch
- Benefit: Easier testing, component reusability, clear separation of concerns
```

**Files to Change:**
- `templates/SESSIONS.template.md` - Update Mental Models section template
- `.claude/commands/save-full.md` - Include "Apply This When" guidance

---

### EXP-7: Separate Key Insights from Gotchas

**Severity:** 🟢 Minor (knowledge organization)
**Reported By:** Project A (Project Gamma)

**Problem:**
- Mental Models section mixes transferable patterns with one-time gotchas
- Hard to distinguish timeless learnings from session-specific issues

**Solution:**
```markdown
### Mental Models

**Current understanding:**
[Architecture and system understanding]

**Key Insights (Transferable Patterns):**
- Pattern: [Name]
  - Principle: [Core concept]
  - Apply to: [Where this works]
  - Benefit: [Why it matters]

**Example:**
- Pattern: toast.promise() for async operations
  - Principle: Declarative loading/success/error states
  - Apply to: Any user-triggered async operation
  - Benefit: Consistent UX, less boilerplate

**Gotchas Discovered (Session-Specific):**
- [Technical issue specific to this implementation]
- [Edge case found during this work]
- [Quirk of this tool/library]
```

**Files to Change:**
- `templates/SESSIONS.template.md` - Split into two subsections
- `.claude/commands/save-full.md` - Explain distinction

---

### EXP-8: `/init-context` Auto-Organize Existing Docs

**Severity:** 🟢 Minor (reduces manual cleanup)
**Reported By:** Project C (Project Alpha)

**Problem:**
- PRD.md exists in project root during `/init-context`
- After init, user has to manually move to `docs/planning/`
- System doesn't check for misplaced docs during setup

**Solution:**
```bash
# In /init-context Step 1: Check for Existing Documentation

echo "🔍 Checking for existing documentation..."

# Check for common docs in root
FOUND_DOCS=""
[ -f "PRD.md" ] && FOUND_DOCS="$FOUND_DOCS PRD.md"
[ -f "PRD-v1.md" ] && FOUND_DOCS="$FOUND_DOCS PRD-v1.md"
[ -f "ARCHITECTURE.md" ] && FOUND_DOCS="$FOUND_DOCS ARCHITECTURE.md"

if [ -n "$FOUND_DOCS" ]; then
  echo "📦 Found documentation files in root:"
  echo "$FOUND_DOCS"
  echo ""
  echo "Would you like me to organize these into docs/ structure?"
  read -p "Organize now? [Y/n] " -n 1 -r

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    mkdir -p docs/planning
    [ -f "PRD.md" ] && mv PRD.md docs/planning/ && echo "  ✅ Moved PRD.md → docs/planning/"
    [ -f "PRD-v1.md" ] && mv PRD-v1.md docs/planning/ && echo "  ✅ Moved PRD-v1.md → docs/planning/"
  fi
fi
```

**Files to Change:**
- `.claude/commands/init-context.md` - Add Step 1 organizational check

---

### EXP-9: Cross-Project Session Documentation Guidance

**Severity:** 🟢 Minor (helps multi-project workflows)
**Reported By:** Project C (Project Alpha, Session 9 spanned two projects)

**Problem:**
- Session worked across two separate projects
- AI Context System is project-specific
- Had to choose which project's SESSIONS.md to use
- Other project has no record of session

**Solution: Document Best Practices**
```markdown
# In templates/SESSIONS.template.md

## Cross-Project Work

**When session spans multiple projects:**

**Option 1: Cross-Reference (Recommended)**
```
# In secondary-project/context/SESSIONS.md

## Session N | YYYY-MM-DD | Cross-Project Integration
**Type:** Cross-project work (primary: other-project)
**See:** [other-project SESSIONS.md](../other-project/context/SESSIONS.md#session-n)

### Changes to This Project
- [List changes specific to this project]

### Git Operations
- N commits (all pushed)
```

**Option 2: Duplicate Documentation**
- Write full session entry in both projects
- Mark which was "primary" vs "secondary"

**Option 3: Monorepo Context**
- If projects are related, consider single context/ at monorepo root
- Individual projects link to shared context
```

**Files to Change:**
- `templates/SESSIONS.template.md` - Add cross-project guidance section
- `.claude/docs/usage-examples.md` - Add cross-project example

---

### EXP-10: `/maintenance-mode` Command

**Severity:** 🟢 Minor (structured transition)
**Reported By:** Project C (Project Alpha)

**Problem:**
- No structured way to transition project to maintenance mode
- Manual editing of STATUS.md sections
- Easy to forget monitoring actions or restarting guidance

**Solution: Create New Command**
```markdown
# .claude/commands/maintenance-mode.md

Transition project to maintenance mode with structured documentation.

## Steps

**1. Update STATUS.md**
- Change status: 🔵 Maintenance Mode
- Change phase: "Production & Complete"
- Replace "Active Tasks" with "Monitoring Actions"
- Add "Restarting Development" section

**2. Prompt for Monitoring Actions**
- Google Analytics setup? [y/N]
- Search Console monitoring? [y/N]
- Uptime monitoring? [y/N]
- Security updates? [y/N]

**3. Run /save-full**
- Document final session
- Capture maintenance mode mental model

**4. Report**
- Show what changed
- Confirm maintenance mode active
```

**Files to Create:**
- `.claude/commands/maintenance-mode.md` - New command
- Update `.context-config.json` template - Add to enabled commands

---

### EXP-11: TodoWrite Usage Guidelines

**Severity:** 🟢 Minor (clarifies when to use)
**Reported By:** Project C (Project Alpha)

**Problem:**
- Unclear when to use TodoWrite vs git commits for tracking
- Session 7-8 used TodoWrite actively
- Session 9 didn't use it, relied on commits
- Both worked, but inconsistent

**Solution: Add Guidance to CLAUDE.md**
```markdown
## TodoWrite Usage Guidelines

**Use TodoWrite when:**
- User provides explicit task list ("add X, Y, and Z")
- Complex feature requiring 5+ steps
- Planning phase with clear deliverables
- Need to track progress visibility for user
- Work will span multiple hours/sessions

**Git commits are sufficient when:**
- Tasks emerge from user feedback
- Quick iterations (1-2 hour sessions)
- Each commit is a natural checkpoint
- User is actively engaged (seeing progress live)
- Organic task discovery (not pre-planned)

**Both approaches:**
- Captured in SESSIONS.md by /save-full
- Provide clear history
- Support session continuity
```

**Files to Change:**
- `templates/claude.md.template` - Add TodoWrite guidance
- `.claude/docs/usage-examples.md` - Add examples of both approaches

---

### EXP-12: Enhanced Actionable Recommendations in `/review-context`

**Severity:** 🟢 Minor (improves usability)
**Reported By:** Project A (Project Gamma)

**Problem:**
- Report provides confidence score and general recommendations
- Could be more specific with actionable next steps
- Doesn't prioritize required vs optional actions

**Solution:**
```markdown
## Final Report Enhancement

**Recommendation:** [Overall assessment]

**Required Actions (Before Resuming Work):**
1. Run `/save` to update STATUS.md Quick Reference (5 days stale)
2. Update CONTEXT.md lines 5-6 (current status outdated)
3. Commit pending changes in SESSIONS.md and STATUS.md

**Optional Actions (Quality Improvements):**
1. Document JWT library decision in DECISIONS.md (DEC-007)
2. Archive SESSIONS.md (28K tokens - consider moving sessions 1-3)
3. Update .context-config.json sessionCount (currently 0, should be 6)

**To resume work immediately:**
```bash
/save    # Updates Quick Reference
# Then continue with [next priority from STATUS.md]
```

**Benefits:**
- Clear prioritization
- Specific commands with exact parameters
- Line numbers for manual edits
- Immediate path forward

**Files to Change:**
- `.claude/commands/review-context.md` - Enhance report format

---

### EXP-13: Context Customization - Auto-Populate Fields

**Severity:** 🟢 Minor (saves 5-10 minutes during init)
**Reported By:** Project B (Project Beta)

**Problem:**
- `/init-context` creates files with many `[FILL: ...]` placeholders
- Manual hunt-and-replace for project name, owner, type, tech stack
- Tedious for new projects without much existing content

**Solution:**
```bash
# In /init-context Step 4.5: Smart Customization

echo "🔍 Detecting project information..."

# Extract from package.json if exists
if [ -f "package.json" ]; then
  PROJECT_NAME=$(grep '"name"' package.json | sed 's/.*"name": "\([^"]*\)".*/\1/')
  echo "  Detected project name: $PROJECT_NAME"
fi

# Extract from README.md if exists
if [ -f "README.md" ]; then
  FIRST_HEADING=$(grep "^# " README.md | head -1 | sed 's/^# //')
  [ -z "$PROJECT_NAME" ] && PROJECT_NAME="$FIRST_HEADING"
fi

# Prompt for missing info
if [ -z "$PROJECT_NAME" ]; then
  read -p "Project name: " PROJECT_NAME
fi

read -p "Project type (web-app/cli/library/api): " PROJECT_TYPE
read -p "Your name: " OWNER_NAME

# Substitute in templates
sed -i.bak "s/\[FILL: Project Name\]/$PROJECT_NAME/g" context/CONTEXT.md
sed -i.bak "s/\[FILL: Your Name\]/$OWNER_NAME/g" context/.context-config.json
# ... etc

echo "✅ Auto-populated project information"
```

**Files to Change:**
- `.claude/commands/init-context.md` - Add smart detection step
- Balance: Don't over-automate, some placeholders are intentional

---

### EXP-14: `/init-context` Progress Visualization

**Severity:** 🟢 Minor (UX polish)
**Reported By:** Project C (Project Alpha)

**Problem:**
- Multi-step process but no clear progress indicator
- Hard to know how far through init process you are
- No dry-run mode to preview changes

**Solution:**
```bash
# Add progress indicators

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  AI Context System v3.5.0 - Project Initialization        ║"
echo "║  Step 1/7: Pre-flight checks                              ║"
echo "╚════════════════════════════════════════════════════════════╝"

# After each major step:
echo "[✓] Step 1/7 complete"
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Step 2/7: Creating directory structure                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
```

**Also Add:**
```bash
# Dry-run mode
/init-context --dry-run

# Outputs:
"Dry-run mode: No files will be created"
"Would create:"
"  ✓ context/ directory"
"  ✓ context/CONTEXT.md"
"  ✓ context/STATUS.md"
"  ..."
```

**Files to Change:**
- `.claude/commands/init-context.md` - Add progress indicators
- Support `--dry-run` flag

---

### EXP-15: Session Momentum Section (Optional)

**Severity:** 🟢 Minor (nice-to-have for handoffs)
**Reported By:** Project C (Project Alpha)

**Problem:**
- When resuming from summary, hard to know session pace/style
- AI agent doesn't know if user prefers detailed explanations or rapid iteration
- Communication style not preserved across sessions

**Solution:**
```markdown
# In session summaries (optional addition)

## Session Momentum

**Velocity:** High (fixed 3 issues, 4 commits in 45 minutes)
**Blocking:** None (dev server running, build passing)
**Next 30 min focus:** CSS refactoring (utilities.css creation)
**User engagement level:** Active (responding to all changes)
**Communication style:** Prefers concise explanations, rapid iteration
```

**Benefits:**
- AI agent can match pace/style of previous work
- Knows whether to ask questions or proceed autonomously
- Maintains consistent communication across sessions

**Files to Change:**
- This is for Claude's internal summaries, not SESSIONS.md
- Could add to `.claude/docs/usage-examples.md` as optional practice

---

## Category 4: Deferred to Future Versions

These are valid suggestions but out of scope for v3.5.0 (bug fixes + performance + experience). Consider for v3.6.0 or later:

### DEFERRED-1: Decision Detection in Git Commits
**Reason:** Complex feature requiring commit message parsing and interactive prompts. Good idea but adds significant complexity.

**Future:** v3.6.0 - Advanced decision tracking features

---

### DEFERRED-2: Basic Functionality Checks in `/review-context`
**Reason:** Too project-specific (pytest, npm, database). Could add overhead and false positives.

**Future:** v3.6.0 - Optional project health checks

---

### DEFERRED-3: Push Violation Detection
**Reason:** Enforcement is AI agent behavior, not system issue. Push protection protocol already exists.

**Future:** If pattern continues, address in AI agent behavior guidelines

---

### DEFERRED-4: Enhanced Git Operations Section
**Reason:** Nice-to-have but not blocking. Current version works well.

**Future:** v3.6.0 - Comprehensive git integration improvements

---

### DEFERRED-5: More Complex Session Index Categorization
**Reason:** Start with simple flat index. Add categorization if users request.

**Future:** v3.6.0 - If feedback shows need for "by feature" / "by decision" grouping

---

## Implementation Plan - Modular Approach

**Philosophy:** Each module is an isolated, independently testable unit of work. Modules can be developed in any order, merged independently, and rolled back without affecting others.

**Workflow for Each Module:**
1. Write unit test FIRST (test-driven development)
2. Implement the change
3. Run unit test → must pass
4. Run integration test → must pass
5. Manual verification → must pass
6. Commit to feature branch
7. Only after ALL verifications pass: merge to main

**Quality Gates:**
- ❌ If unit test fails → fix implementation, do not proceed
- ❌ If integration test fails → check for unexpected dependencies, fix
- ❌ If manual verification fails → implementation incomplete, do not merge
- ✅ All gates passed → safe to merge

---

## Module Catalog

### CRITICAL MODULES (Must-Fix Bugs)

---

### **MODULE-001: Version Detection in `/init-context`**

**Issue:** BUG-1 - Hardcoded version 3.0.0 in config template
**Priority:** HIGH | **Effort:** 1 hour | **Risk:** Low

**Scope:**
- Add version detection to `/init-context` command
- Substitute actual version in config file during initialization

**Files Changed:**
- `.claude/commands/init-context.md` (1 file, ~10 lines added)

**Dependencies:**
- None (completely isolated change)

**Unit Test:**
```bash
# Test: scripts/tests/test-module-001.sh
test_version_detection_init_context() {
  # Setup
  echo "3.5.0" > VERSION
  mkdir -p context config

  # Execute
  /init-context

  # Verify
  CONFIG_VERSION=$(grep '"version":' context/.context-config.json | head -1 | sed 's/.*"\([0-9.]*\)".*/\1/')
  assert_equal "$CONFIG_VERSION" "3.5.0" "Config version should match VERSION file"

  # Cleanup
  rm -rf context VERSION
}
```

**Implementation:**
```bash
# Add to init-context.md after Step 4 (before creating config):

## Step 4.5: Detect System Version
echo "🔍 Detecting system version..."
SYSTEM_VERSION=$(cat VERSION 2>/dev/null || echo "unknown")
echo "   System version: $SYSTEM_VERSION"

# Modify Step 5 (Create Configuration):
cp config/.context-config.template.json context/.context-config.json
sed -i.bak "s/\"3.0.0\"/\"$SYSTEM_VERSION\"/g" context/.context-config.json
rm context/.context-config.json.bak
echo "✅ Configuration created with version $SYSTEM_VERSION"
```

**Manual Verification:**
1. Run `/init-context` in test project
2. Check `context/.context-config.json` line 2: `"version": "3.5.0"`
3. Check line 242: `"configVersion": "3.5.0"`
4. Both should match VERSION file
5. ✅ PASS if versions match, ❌ FAIL otherwise

**Rollback Strategy:**
```bash
# Revert single file:
git checkout .claude/commands/init-context.md
# No other files affected, safe rollback
```

**Integration Impact:**
- None. This module doesn't affect other modules.

---

### **MODULE-002: Version Detection in `/update-context-system`**

**Issue:** BUG-1 - Config version not updated during system upgrade
**Priority:** HIGH | **Effort:** 30 min | **Risk:** Low

**Scope:**
- Ensure `/update-context-system` updates config version during upgrade

**Files Changed:**
- `.claude/commands/update-context-system.md` (1 file, ~8 lines added)

**Dependencies:**
- None (isolated)

**Unit Test:**
```bash
# Test: scripts/tests/test-module-002.sh
test_version_update_on_upgrade() {
  # Setup: Create project with old version
  echo "3.4.0" > VERSION
  mkdir -p context
  echo '{"version": "3.4.0"}' > context/.context-config.json

  # Simulate upgrade
  echo "3.5.0" > VERSION
  /update-context-system

  # Verify
  CONFIG_VERSION=$(grep '"version":' context/.context-config.json | head -1 | sed 's/.*"\([0-9.]*\)".*/\1/')
  assert_equal "$CONFIG_VERSION" "3.5.0" "Config should update to new version"

  # Cleanup
  rm -rf context VERSION
}
```

**Implementation:**
```bash
# Add to update-context-system.md in "Update Configuration" step:

## Step 7.5: Update Config Version
SYSTEM_VERSION=$(cat VERSION 2>/dev/null || echo "unknown")
if [ "$SYSTEM_VERSION" != "unknown" ]; then
  sed -i.bak "s/\"version\": \"[^\"]*\"/\"version\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
  sed -i.bak "s/\"configVersion\": \"[^\"]*\"/\"configVersion\": \"$SYSTEM_VERSION\"/g" context/.context-config.json
  rm context/.context-config.json.bak
  echo "✅ Updated config version to $SYSTEM_VERSION"
fi
```

**Manual Verification:**
1. Create project with v3.4.0 config
2. Run `/update-context-system`
3. Check config version updated to 3.5.0
4. ✅ PASS if updated, ❌ FAIL otherwise

**Rollback Strategy:**
```bash
git checkout .claude/commands/update-context-system.md
```

**Integration Impact:**
- None. Independent of MODULE-001.

---

### **MODULE-003: Shell-Compatible Version Check**

**Issue:** BUG-2 - zsh parsing error in `/review-context`
**Priority:** HIGH | **Effort:** 30 min | **Risk:** Low

**Scope:**
- Replace complex function call with simple file read
- Test on bash, zsh, sh

**Files Changed:**
- `.claude/commands/review-context.md` (1 file, Step 1.5 replacement)

**Dependencies:**
- None

**Unit Test:**
```bash
# Test: scripts/tests/test-module-003.sh
test_version_check_bash() {
  echo "3.5.0" > VERSION
  bash -c 'CURRENT_VERSION=$(cat VERSION 2>/dev/null || echo "unknown"); echo $CURRENT_VERSION' | grep -q "3.5.0"
  assert_success "Bash version check should work"
}

test_version_check_zsh() {
  echo "3.5.0" > VERSION
  zsh -c 'CURRENT_VERSION=$(cat VERSION 2>/dev/null || echo "unknown"); echo $CURRENT_VERSION' | grep -q "3.5.0"
  assert_success "Zsh version check should work"
}

test_version_check_fallback() {
  rm VERSION 2>/dev/null
  mkdir -p context
  echo '{"version": "3.5.0"}' > context/.context-config.json
  CURRENT_VERSION=$(cat VERSION 2>/dev/null || grep -m 1 '"version":' context/.context-config.json | sed 's/.*"version": "\([^"]*\)".*/\1/' 2>/dev/null || echo "unknown")
  assert_equal "$CURRENT_VERSION" "3.5.0" "Should fall back to config"
}
```

**Implementation:**
```bash
# Replace in review-context.md Step 1.5:

# OLD (fails on zsh):
CURRENT_VERSION=$(get_system_version)

# NEW (shell-compatible):
CURRENT_VERSION=$(cat VERSION 2>/dev/null || grep -m 1 '"version":' context/.context-config.json | sed 's/.*"version": "\([^"]*\)".*/\1/' 2>/dev/null || echo "unknown")
```

**Manual Verification:**
1. Run `/review-context` on macOS (zsh): ✅ No parse errors
2. Run `/review-context` on Linux (bash): ✅ No parse errors
3. Test with missing VERSION file: ✅ Falls back to config
4. Test with both missing: ✅ Shows "unknown" gracefully

**Rollback Strategy:**
```bash
git checkout .claude/commands/review-context.md
```

**Integration Impact:**
- None

---

### **MODULE-004: Decision Count Grep Fix**

**Issue:** BUG-3 - Integer expression error in decision count
**Priority:** LOW | **Effort:** 15 min | **Risk:** Low

**Scope:**
- Fix grep output parsing to avoid newline issues

**Files Changed:**
- `.claude/commands/review-context.md` (1 file, 1 line change)

**Dependencies:**
- None

**Unit Test:**
```bash
# Test: scripts/tests/test-module-004.sh
test_decision_count() {
  mkdir -p context
  cat > context/DECISIONS.md << 'EOF'
### D001 | Test | 2025-01-01
### D002 | Test | 2025-01-02
### D003 | Test | 2025-01-03
EOF

  # Test the fix
  DECISION_COUNT=$(grep "^### D[0-9]" context/DECISIONS.md 2>/dev/null | wc -l | tr -d ' ')
  assert_equal "$DECISION_COUNT" "3" "Should count 3 decisions"

  # Cleanup
  rm -rf context
}
```

**Implementation:**
```bash
# In review-context.md Step 2.7:

# OLD:
DECISION_COUNT=$(grep -c "^### D[0-9]" "$CONTEXT_DIR/DECISIONS.md" 2>/dev/null || echo "0")

# NEW:
DECISION_COUNT=$(grep "^### D[0-9]" "$CONTEXT_DIR/DECISIONS.md" 2>/dev/null | wc -l | tr -d ' ')
```

**Manual Verification:**
1. Run `/review-context` with DECISIONS.md containing 5 decisions
2. Check output: ✅ No "integer expression expected" errors
3. Count is correct: ✅ Shows "5 decisions"

**Rollback Strategy:**
```bash
git checkout .claude/commands/review-context.md
```

**Integration Impact:**
- None

---

### **MODULE-005: ORGANIZATION.md Download Fix**

**Issue:** BUG-4 - Installation fails on small file
**Priority:** MEDIUM | **Effort:** 45 min | **Risk:** Low

**Scope:**
- Populate ORGANIZATION.md with real content (>100 bytes)
- Mark as optional in installer

**Files Changed:**
- `reference/ORGANIZATION.md` (populate content)
- `install.sh` (mark optional, skip size check)

**Dependencies:**
- None

**Unit Test:**
```bash
# Test: scripts/tests/test-module-005.sh
test_organization_file_size() {
  FILE_SIZE=$(wc -c < reference/ORGANIZATION.md)
  assert_greater_than "$FILE_SIZE" "100" "ORGANIZATION.md should be >100 bytes"
}

test_optional_file_handling() {
  # Simulate failed download
  OPTIONAL_FILES="reference/ORGANIZATION.md"
  # Should not count in error tally
  # Should not block installation
  assert_success "Optional file failure should not block install"
}
```

**Implementation:**

**Part 1: Populate ORGANIZATION.md:**
```markdown
# Project Organization Guide

This guide explains the AI Context System's recommended project structure.

## Core Structure

\`\`\`
project-root/
├── context/           # AI Context System documentation
├── docs/              # Project documentation
│   ├── reference/     # Reference materials
│   ├── planning/      # PRDs, proposals, planning docs
│   └── guides/        # User guides, tutorials
├── artifacts/         # Generated outputs
├── scripts/           # Automation scripts
└── [your project files]
\`\`\`

[... 200+ more bytes of content ...]
```

**Part 2: Update install.sh:**
```bash
# Add optional files list
OPTIONAL_FILES=(
  "reference/ORGANIZATION.md"
)

# In download function:
is_optional() {
  local file="$1"
  for opt in "${OPTIONAL_FILES[@]}"; do
    [[ "$file" == "$opt" ]] && return 0
  done
  return 1
}

# Skip size check for optional files:
if is_optional "$file"; then
  echo "   (optional file, skipping size check)"
fi
```

**Manual Verification:**
1. Run `install.sh`
2. ✅ No "file too small" error for ORGANIZATION.md
3. ✅ Installation completes successfully
4. ✅ ORGANIZATION.md has useful content

**Rollback Strategy:**
```bash
git checkout reference/ORGANIZATION.md install.sh
```

**Integration Impact:**
- None

---

### **MODULE-006: Smart SESSIONS.md Loading**

**Issue:** BUG-5 - Token limit crash on large files
**Priority:** HIGH | **Effort:** 2 hours | **Risk:** Medium

**Scope:**
- Add file size detection
- Implement chunked reading strategy
- Handle 1K, 5K, 10K+ line files

**Files Changed:**
- `.claude/commands/review-context.md` (1 file, Step 2.3 replacement)

**Dependencies:**
- None

**Unit Test:**
```bash
# Test: scripts/tests/test-module-006.sh
test_small_sessions_file() {
  # 500 lines - should read full
  create_sessions_file 500
  result=$(load_sessions_smart)
  assert_contains "$result" "Read SESSIONS.md fully" "Small file should read fully"
}

test_medium_sessions_file() {
  # 2000 lines - should use strategic reading
  create_sessions_file 2000
  result=$(load_sessions_smart)
  assert_contains "$result" "strategic" "Medium file should use strategic reading"
}

test_large_sessions_file() {
  # 6000 lines - should use minimal reading
  create_sessions_file 6000
  result=$(load_sessions_smart)
  assert_contains "$result" "minimal" "Large file should use minimal reading"
}
```

**Implementation:**
```bash
# Replace Step 2.3 in review-context.md:

## Step 2.3: Load SESSIONS.md (Smart Loading)

FILE_SIZE=$(wc -l < "$CONTEXT_DIR/SESSIONS.md" 2>/dev/null || echo "0")

if [ "$FILE_SIZE" -lt 1000 ]; then
  echo "📖 Loading SESSIONS.md fully ($FILE_SIZE lines)"
  Read context/SESSIONS.md

elif [ "$FILE_SIZE" -lt 5000 ]; then
  echo "📖 Loading SESSIONS.md strategically ($FILE_SIZE lines)"
  echo "   Reading: Session index + recent session"
  Read context/SESSIONS.md limit=300
  Read context/SESSIONS.md offset=$((FILE_SIZE - 500)) limit=500

else
  echo "📖 Loading SESSIONS.md minimally ($FILE_SIZE lines - very large)"
  echo "   Reading: Session index + current session only"
  Read context/SESSIONS.md limit=200
  Read context/SESSIONS.md offset=$((FILE_SIZE - 300)) limit=300
  echo ""
  echo "⚠️  SESSIONS.md is very large ($FILE_SIZE lines)"
  echo "   Consider archiving old sessions with /archive-sessions"
fi
```

**Manual Verification:**
1. Test with 500-line SESSIONS.md: ✅ Reads fully
2. Test with 3000-line SESSIONS.md: ✅ Strategic reading
3. Test with 7000-line SESSIONS.md: ✅ Minimal reading + warning
4. No token limit errors in any case: ✅

**Rollback Strategy:**
```bash
git checkout .claude/commands/review-context.md
# Well-isolated change, safe to revert
```

**Integration Impact:**
- None. Does not affect other modules.

---

### **MODULE-007: Context Folder Auto-Detection**

**Issue:** BUG-6 - Commands fail from subdirectories
**Priority:** MEDIUM | **Effort:** 1.5 hours | **Risk:** Low

**Scope:**
- Use existing `scripts/find-context-folder.sh` across all commands
- Audit and fix 5 commands

**Files Changed:**
- `.claude/commands/save.md` (add context detection)
- `.claude/commands/save-full.md` (add context detection)
- `.claude/commands/review-context.md` (add context detection)
- `.claude/commands/validate-context.md` (add context detection)
- `.claude/commands/export-context.md` (add context detection)

**Dependencies:**
- Requires `scripts/find-context-folder.sh` (already exists)

**Unit Test:**
```bash
# Test: scripts/tests/test-module-007.sh
test_context_detection_from_root() {
  mkdir -p context
  cd project-root
  CONTEXT_DIR=$(find_context_folder)
  assert_equal "$CONTEXT_DIR" "context" "Should find context from root"
}

test_context_detection_from_subdirectory() {
  mkdir -p backend context
  cd backend
  CONTEXT_DIR=$(find_context_folder)
  assert_equal "$CONTEXT_DIR" "../context" "Should find context from subdir"
}

test_context_detection_failure() {
  cd /tmp/no-context-here
  CONTEXT_DIR=$(find_context_folder 2>&1 || echo "FAILED")
  assert_contains "$CONTEXT_DIR" "not found" "Should fail gracefully"
}
```

**Implementation:**
```bash
# Add to beginning of each command file:

## Step 0: Locate Context Folder
source scripts/find-context-folder.sh
CONTEXT_DIR=$(find_context_folder)

# Then use $CONTEXT_DIR throughout instead of hardcoded "context/"
```

**Manual Verification:**
1. Create project with `backend/` subdirectory
2. `cd backend`
3. Run `/save`: ✅ Finds ../context/
4. Run `/review-context`: ✅ Finds ../context/
5. All 5 commands work from subdirectories: ✅

**Rollback Strategy:**
```bash
git checkout .claude/commands/save.md
git checkout .claude/commands/save-full.md
git checkout .claude/commands/review-context.md
git checkout .claude/commands/validate-context.md
git checkout .claude/commands/export-context.md
# Revert all 5 files if issues found
```

**Integration Impact:**
- None. Additive change only.

---

## PERFORMANCE MODULES

---

### **MODULE-101: SESSIONS.md Archiving Core Logic**

**Issue:** PERF-1 - Large SESSIONS.md files
**Priority:** HIGH | **Effort:** 3 hours | **Risk:** MEDIUM

**Scope:**
- Create archiving helper script
- Extract sessions 1-N to archive file
- Update main SESSIONS.md to keep last 10

**Files Changed:**
- `scripts/archive-sessions-helper.sh` (NEW file, ~200 lines)

**Dependencies:**
- None (isolated script)

**Unit Test:**
```bash
# Test: scripts/tests/test-module-101.sh
test_archive_sessions() {
  # Setup: Create SESSIONS.md with 40 sessions
  create_test_sessions 40

  # Execute archiving
  bash scripts/archive-sessions-helper.sh --keep 10

  # Verify
  assert_file_exists "context/SESSIONS-archive-2025.md" "Archive file should be created"

  SESSION_COUNT=$(grep -c "^## Session" context/SESSIONS.md)
  assert_equal "$SESSION_COUNT" "10" "Main file should have 10 sessions"

  ARCHIVE_COUNT=$(grep -c "^## Session" context/SESSIONS-archive-2025.md)
  assert_equal "$ARCHIVE_COUNT" "30" "Archive should have 30 sessions"

  # Verify no data loss
  TOTAL=$((SESSION_COUNT + ARCHIVE_COUNT))
  assert_equal "$TOTAL" "40" "No sessions should be lost"
}

test_archive_idempotent() {
  # Running twice should not create duplicates
  bash scripts/archive-sessions-helper.sh --keep 10
  bash scripts/archive-sessions-helper.sh --keep 10

  SESSION_COUNT=$(grep -c "^## Session" context/SESSIONS.md)
  assert_equal "$SESSION_COUNT" "10" "Should still have 10 sessions"
}

test_archive_backup() {
  # Should create backup before modifying
  bash scripts/archive-sessions-helper.sh --keep 10
  assert_file_exists "context/SESSIONS.md.backup" "Backup should exist"
}
```

**Implementation:**
```bash
# Create scripts/archive-sessions-helper.sh

#!/bin/bash
# Archive old sessions from SESSIONS.md

KEEP_RECENT=10  # Keep last N sessions
BACKUP=true     # Create backup before modifying

# [Implementation: 200 lines of careful file parsing and archiving]
# See detailed implementation in MODULE-101 spec document
```

**Manual Verification:**
1. Create test project with 40 sessions
2. Run: `bash scripts/archive-sessions-helper.sh --keep 10`
3. Check main SESSIONS.md: ✅ Has 10 most recent sessions
4. Check archive file: ✅ Has 30 old sessions
5. Total count: ✅ 40 sessions (no data loss)
6. Backup created: ✅ SESSIONS.md.backup exists

**Rollback Strategy:**
```bash
# If archiving fails:
cp context/SESSIONS.md.backup context/SESSIONS.md
rm context/SESSIONS-archive-*.md
# Restore from automatic backup
```

**Integration Impact:**
- Used by MODULE-102 (archiving trigger)
- But can be tested independently

---

### **MODULE-102: Auto-Trigger Archiving in `/save-full`**

**Issue:** PERF-1 - Automatic archiving trigger
**Priority:** HIGH | **Effort:** 1 hour | **Risk:** Low

**Scope:**
- Add check in `/save-full` for large SESSIONS.md
- Trigger archiving if >2000 lines
- Optional (prompt user)

**Files Changed:**
- `.claude/commands/save-full.md` (add Step 0.5)

**Dependencies:**
- MODULE-101 (requires archive-sessions-helper.sh)

**Unit Test:**
```bash
# Test: scripts/tests/test-module-102.sh
test_archiving_trigger() {
  # Create large SESSIONS.md (2500 lines)
  create_test_sessions 45  # ~2500 lines

  # Run /save-full with auto-yes
  echo "y" | /save-full

  # Verify archiving was triggered
  assert_file_exists "context/SESSIONS-archive-2025.md" "Archiving should trigger"
}

test_archiving_skip_small_files() {
  # Create small SESSIONS.md (500 lines)
  create_test_sessions 8  # ~500 lines

  # Run /save-full
  /save-full

  # Verify archiving was NOT triggered
  assert_file_not_exists "context/SESSIONS-archive-2025.md" "Should not archive small files"
}
```

**Implementation:**
```bash
# Add to save-full.md:

## Step 0.5: Check if Archiving Needed
LINE_COUNT=$(wc -l < context/SESSIONS.md 2>/dev/null || echo "0")

if [ "$LINE_COUNT" -gt 2000 ]; then
  echo ""
  echo "📦 SESSIONS.md is large ($LINE_COUNT lines)"
  echo "   Archiving old sessions improves performance."
  echo ""
  read -p "Archive sessions 1-N (keep last 10)? [Y/n] " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
    bash scripts/archive-sessions-helper.sh --keep 10
    echo "✅ Archived old sessions"
  else
    echo "Skipping archiving (file will continue growing)"
  fi
fi
```

**Manual Verification:**
1. Create project with 2500-line SESSIONS.md
2. Run `/save-full`
3. Prompt appears: ✅ "Archive sessions?"
4. Answer yes: ✅ Archiving completes
5. Main file now smaller: ✅ <1000 lines

**Rollback Strategy:**
```bash
git checkout .claude/commands/save-full.md
# Does not affect MODULE-101 (independent)
```

**Integration Impact:**
- Depends on MODULE-101
- **Must test MODULE-101 first before MODULE-102**

---

### **MODULE-103: Code Review Auto-Report Generation**

**Issue:** PERF-2 - Manual report creation friction
**Priority:** MEDIUM | **Effort:** 2 hours | **Risk:** Low

**Scope:**
- Auto-create report in artifacts/code-reviews/
- Use existing code-review-helpers.sh functions
- Maintain v3.4.0 smart grouping features

**Files Changed:**
- `.claude/commands/code-review.md` (add Step 7: Save Report)

**Dependencies:**
- Requires `scripts/code-review-helpers.sh` (already exists in v3.4.0)

**Unit Test:**
```bash
# Test: scripts/tests/test-module-103.sh
test_code_review_report_creation() {
  # Run code review
  /code-review

  # Verify report created
  assert_file_exists "artifacts/code-reviews/session-*-review.md" "Report should be created"

  # Verify report content
  REPORT=$(cat artifacts/code-reviews/session-*-review.md)
  assert_contains "$REPORT" "# Code Review Report" "Should have header"
  assert_contains "$REPORT" "Grade:" "Should include grade"
  assert_contains "$REPORT" "## Findings" "Should include findings"
}

test_report_filename() {
  mkdir -p context
  echo "## Session 14" >> context/SESSIONS.md

  /code-review

  assert_file_exists "artifacts/code-reviews/session-14-review.md" "Filename should include session number"
}
```

**Implementation:**
```bash
# Add to code-review.md after analysis:

## Step 7: Save Report to Artifacts

echo ""
echo "💾 Saving detailed report..."

# Detect session number
SESSION_NUM=$(grep -c "^## Session" context/SESSIONS.md 2>/dev/null || echo "unknown")

# Create directory
mkdir -p artifacts/code-reviews

# Generate report
REPORT_FILE="artifacts/code-reviews/session-${SESSION_NUM}-review.md"

cat > "$REPORT_FILE" << EOF
# Code Review Report - Session $SESSION_NUM

**Date:** $(date +%Y-%m-%d)
**Grade:** [GRADE]
**Reviewer:** AI Context System v3.5.0

---

## Executive Summary

[Summary from analysis]

---

## Findings

[Detailed findings with smart grouping from v3.4.0]

---

## Recommendations

[Actionable recommendations]

---

## Review History

- Previous review: [link if exists]

EOF

echo "✅ Report saved: $REPORT_FILE"
echo ""
echo "📄 Detailed report available at: $REPORT_FILE"
```

**Manual Verification:**
1. Run `/code-review` on test project
2. Check artifacts/code-reviews/: ✅ Report file created
3. Check report content: ✅ Has grade, findings, recommendations
4. Check filename: ✅ Includes session number
5. Run again: ✅ Creates separate report (no overwrite)

**Rollback Strategy:**
```bash
git checkout .claude/commands/code-review.md
rm artifacts/code-reviews/session-*-review.md  # If needed
```

**Integration Impact:**
- None. Additive feature.
- Does not affect v3.4.0 smart grouping (uses existing helpers)

---

### **MODULE-104: Cross-Document Consistency Automation**

**Issue:** PERF-3 - Manual consistency checking
**Priority:** LOW | **Effort:** 2 hours | **Risk:** Low

**Scope:**
- Auto-extract dates, phases, tech stack
- Compare across files
- Report discrepancies

**Files Changed:**
- `.claude/commands/review-context.md` (enhance Step 2.8)

**Dependencies:**
- None

**Unit Test:**
```bash
# Test: scripts/tests/test-module-104.sh
test_date_consistency() {
  # Setup files with different dates
  echo "Last Updated: 2025-11-01" > context/CONTEXT.md
  echo "Last Updated: 2025-11-28" > context/STATUS.md

  # Run consistency check
  result=$(check_consistency)

  assert_contains "$result" "⚠️" "Should warn about date drift"
  assert_contains "$result" "27 days" "Should calculate gap"
}

test_phase_consistency() {
  echo "Phase: Development" > context/CONTEXT.md
  echo "Phase: Production" > context/STATUS.md

  result=$(check_consistency)

  assert_contains "$result" "Phase drift detected" "Should detect phase mismatch"
}
```

**Implementation:**
```bash
# Enhance review-context.md Step 2.8:

## Step 2.8: Automated Cross-Document Consistency

echo "🔍 Checking cross-document consistency..."

# 1. Date consistency
CONTEXT_DATE=$(grep "Last Updated:" context/CONTEXT.md | sed 's/.*: //')
STATUS_DATE=$(grep "Last Updated:" context/STATUS.md | sed 's/.*: //')
SESSIONS_DATE=$(grep "Last Updated:" context/SESSIONS.md | sed 's/.*: //')

echo "Last Updated Dates:"
echo "  CONTEXT.md:  $CONTEXT_DATE"
echo "  STATUS.md:   $STATUS_DATE"
echo "  SESSIONS.md: $SESSIONS_DATE"

# Calculate drift (STATUS vs CONTEXT)
# [Implementation: date math]

# 2. Phase consistency
CONTEXT_PHASE=$(grep "Phase:" context/CONTEXT.md | sed 's/.*Phase: //')
STATUS_PHASE=$(grep "Phase:" context/STATUS.md | sed 's/.*Phase: //')

if [ "$CONTEXT_PHASE" != "$STATUS_PHASE" ]; then
  echo "⚠️  Phase drift detected:"
  echo "    CONTEXT.md: $CONTEXT_PHASE"
  echo "    STATUS.md:  $STATUS_PHASE"
fi

# 3. Session count
SESSION_COUNT=$(grep -c "^## Session" context/SESSIONS.md)
echo "Session count: $SESSION_COUNT"
```

**Manual Verification:**
1. Create files with mismatched phases
2. Run `/review-context`
3. Check output: ✅ Detects phase drift
4. Check output: ✅ Shows date gaps
5. Check output: ✅ Reports session count

**Rollback Strategy:**
```bash
git checkout .claude/commands/review-context.md
```

**Integration Impact:**
- None. Additive reporting only.

---

## EXPERIENCE MODULES (Lower Priority)

**Note:** These modules follow the same pattern. Each is:
- Isolated and independently testable
- Has unit tests written first
- Can be merged individually
- Can be deferred without blocking critical/performance modules

### Summary of Experience Modules:
- **MODULE-201:** docs/reference/ location (30 min)
- **MODULE-202:** /review-context auto-trigger /save (1 hour)
- **MODULE-203:** ARCHITECTURE.md in /save-full (30 min)
- **MODULE-204:** Decision prompts (1 hour)
- **MODULE-205:** Session index auto-gen (2 hours)
- **MODULE-206:** Mental Models enhancement (1 hour)
- **MODULE-207:** Key Insights separation (30 min)
- **MODULE-208:** TodoWrite guidelines (30 min)
- **MODULE-209:** Enhanced recommendations (1 hour)
- **MODULE-210:** Init auto-organize (1 hour)
- **MODULE-211:** Cross-project guidance (30 min)
- **MODULE-212:** Maintenance mode command (2 hours)
- **MODULE-213:** Auto-populate fields (1.5 hours)
- **MODULE-214:** Progress visualization (1 hour)

**Each follows the same rigorous pattern:**
1. Unit test first
2. Isolated implementation
3. Manual verification
4. Clear rollback
5. No integration dependencies

---

## Development Workflow

### Day 1-2: Critical Modules (MUST FIX)
**Order:** Can be done in parallel by different developers

**Track 1:**
- MODULE-001 → Unit test → Implement → Verify → Commit
- MODULE-002 → Unit test → Implement → Verify → Commit
- MODULE-003 → Unit test → Implement → Verify → Commit

**Track 2:**
- MODULE-004 → Unit test → Implement → Verify → Commit
- MODULE-005 → Unit test → Implement → Verify → Commit

**Track 3:**
- MODULE-006 → Unit test → Implement → Verify → Commit
- MODULE-007 → Unit test → Implement → Verify → Commit

**Integration Test After Day 2:**
- Run all unit tests: Must all pass
- Test on fresh install: All bugs fixed
- Test upgrade path: v3.4.0 → v3.5.0 works

---

### Day 3-4: Performance Modules

**IMPORTANT:** MODULE-102 depends on MODULE-101
**Order:**
1. MODULE-101 (archiving core) → test thoroughly → commit
2. MODULE-102 (auto-trigger) → test with MODULE-101 → commit
3. MODULE-103 (code review report) → independent → commit
4. MODULE-104 (consistency) → independent → commit

**Integration Test After Day 4:**
- Test archiving with 40-session project
- Test code review auto-report
- Test consistency checks

---

### Day 5+: Experience Modules (Optional)

**These can be done in ANY order:**
- Pick highest value modules first (201-204)
- Implement one at a time
- Test individually
- Commit immediately after verification

**Defer if needed:**
- Experience modules can be deferred to v3.5.1 if time constrained
- Critical and Performance modules are priority

---

## Quality Gates Checklist

### Before Merging ANY Module:
- [ ] Unit test written FIRST
- [ ] Unit test PASSES
- [ ] Manual verification PASSES
- [ ] No regressions (existing tests still pass)
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] CHANGELOG entry added

### Before Merging to Main:
- [ ] ALL unit tests pass
- [ ] Integration tests pass
- [ ] Cross-platform tested (macOS, Linux)
- [ ] Shell compatibility tested (bash, zsh)
- [ ] No breaking changes
- [ ] Version updated
- [ ] Documentation complete

---

## Rollback Strategy

### Individual Module Rollback:
```bash
# Revert specific module
git revert <commit-hash>

# Or revert file changes
git checkout HEAD~1 .claude/commands/[file].md
```

### Full v3.5.0 Rollback:
```bash
# Revert to v3.4.0
git checkout tags/v3.4.0

# Or cherry-pick specific fixes
git cherry-pick <working-module-commits>
```

### Safe Rollback Guarantees:
- Each module is isolated → safe to revert individually
- No module dependencies (except 101↔102) → can remove without cascade
- All changes are additive → removing doesn't break existing features
- Backwards compatible → users can stay on v3.4.0 if needed

---

## Estimated Timeline (Modular Approach)

**Critical Modules (Day 1-2):** 6 hours
- 7 modules can be done in parallel
- With 2-3 developers: 1-2 days
- With 1 developer: 2 days

**Performance Modules (Day 3-4):** 8 hours
- 4 modules, 1 dependency (101→102)
- With 2 developers: 1 day
- With 1 developer: 2 days

**Experience Modules (Day 5+):** 13.5 hours
- 14 modules, all independent
- Can be parallelized or deferred
- With 2 developers: 2-3 days
- With 1 developer: 3-4 days

**Total (All Modules):**
- **Best case (parallel):** 4-5 days
- **Worst case (serial):** 7-8 days
- **Recommended (critical + performance only):** 3-4 days

---

## Success Criteria

### Module-Level Success:
✅ Unit test passes
✅ Manual verification passes
✅ Integration test passes (no conflicts)
✅ Code review approved
✅ Merged to main

### Release-Level Success:
✅ All critical modules complete and tested
✅ All performance modules complete and tested
✅ Cross-platform testing passes
✅ No regressions from v3.4.0
✅ Documentation complete
✅ Beta testers approve

---

## Key Benefits of Modular Approach

✅ **Isolated Changes:** Each module is self-contained
✅ **Parallel Development:** Multiple developers can work simultaneously
✅ **Early Testing:** Test each module as it's built
✅ **Safe Rollback:** Revert individual modules without affecting others
✅ **Flexible Timeline:** Can ship critical modules first, defer others
✅ **Quality Focused:** Test-first development catches bugs early
✅ **Clear Progress:** Know exactly which modules are done
✅ **Low Risk:** No "big bang" integration at the end

---

## Testing Strategy - Modular Test-First Approach

### Philosophy
**Test-Driven Development:** Write tests BEFORE implementing each module. No module passes verification without passing its tests.

### Test Organization
```
scripts/tests/
├── test-module-001.sh  # Version detection /init-context
├── test-module-002.sh  # Version detection /update
├── test-module-003.sh  # Shell compatibility
├── test-module-004.sh  # Decision count fix
├── test-module-005.sh  # ORGANIZATION.md
├── test-module-006.sh  # Smart SESSIONS loading
├── test-module-007.sh  # Context folder detection
├── test-module-101.sh  # Archiving core logic
├── test-module-102.sh  # Archiving trigger
├── test-module-103.sh  # Code review report
├── test-module-104.sh  # Consistency automation
├── test-module-2XX.sh  # Experience modules
├── run-all-tests.sh    # Master test runner
└── test-helpers.sh     # Shared assertions
```

### Test Levels

#### 1. Unit Tests (Per Module)
**Run:** After implementing each module
**Purpose:** Verify module works in isolation
**Coverage:** Each module has 3-5 unit tests

**Example (MODULE-001):**
```bash
# scripts/tests/test-module-001.sh

source test-helpers.sh

test_version_detection_init_context() {
  setup_test_env
  echo "3.5.0" > VERSION

  /init-context

  CONFIG_VERSION=$(extract_version context/.context-config.json)
  assert_equal "$CONFIG_VERSION" "3.5.0"

  cleanup_test_env
}

test_version_detection_missing_file() {
  setup_test_env
  rm VERSION

  /init-context

  CONFIG_VERSION=$(extract_version context/.context-config.json)
  assert_equal "$CONFIG_VERSION" "unknown"

  cleanup_test_env
}

run_tests
```

**Pass Criteria:** All unit tests for module pass (100%)

---

#### 2. Integration Tests (Per Module)
**Run:** After unit tests pass
**Purpose:** Verify module works with existing system
**Coverage:** Check for conflicts with v3.4.0 features

**Example (MODULE-001):**
```bash
# scripts/tests/test-module-001-integration.sh

test_version_detection_preserves_config() {
  # Create full v3.4.0 config with all settings
  setup_v340_config

  # Run new version detection logic
  /init-context

  # Verify version updated but other settings preserved
  assert_config_setting_unchanged "owner"
  assert_config_setting_unchanged "preferences.workflow"
  assert_equal "$(extract_version context/.context-config.json)" "3.5.0"
}

test_no_regression_existing_projects() {
  # Simulate existing v3.4.0 project
  setup_existing_project_v340

  # Upgrade to v3.5.0
  /update-context-system

  # Verify no features broken
  assert_command_works "/save"
  assert_command_works "/review-context"
  assert_command_works "/save-full"
}
```

**Pass Criteria:** No regressions, new feature works with existing features

---

#### 3. Cross-Platform Tests (Per Module)
**Run:** After integration tests pass
**Purpose:** Verify module works on all platforms
**Coverage:** macOS, Linux (Ubuntu/Debian), Windows WSL

**Example (MODULE-003):**
```bash
# scripts/tests/test-module-003-cross-platform.sh

test_shell_compatibility_bash() {
  bash -c 'source .claude/commands/review-context.md; run_version_check'
  assert_success "Version check should work in bash"
}

test_shell_compatibility_zsh() {
  zsh -c 'source .claude/commands/review-context.md; run_version_check'
  assert_success "Version check should work in zsh"
}

test_shell_compatibility_sh() {
  sh -c 'source .claude/commands/review-context.md; run_version_check'
  assert_success "Version check should work in sh"
}
```

**Pass Criteria:** Works on bash 4+, zsh 5+, sh

---

#### 4. Manual Verification (Per Module)
**Run:** After all automated tests pass
**Purpose:** Human verification of UX and edge cases
**Coverage:** Real-world usage scenarios

**Checklist for Each Module:**
```markdown
### MODULE-XXX Manual Verification

**Tester:** [Name]
**Date:** [YYYY-MM-DD]
**Platform:** [macOS 14.x / Ubuntu 22.04 / Windows WSL]

**Test Cases:**
- [ ] Test case 1: [description] → PASS/FAIL
- [ ] Test case 2: [description] → PASS/FAIL
- [ ] Test case 3: [description] → PASS/FAIL
- [ ] Edge case 1: [description] → PASS/FAIL
- [ ] Edge case 2: [description] → PASS/FAIL

**Issues Found:** [list or "none"]
**Overall Result:** PASS / FAIL / BLOCKED
**Notes:** [any observations]
```

**Pass Criteria:** All test cases PASS, zero blocking issues

---

### Master Test Suite

#### Run All Module Tests
```bash
#!/bin/bash
# scripts/tests/run-all-tests.sh

FAILED_MODULES=()

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  AI Context System v3.5.0 - Test Suite                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Critical Modules
for module in 001 002 003 004 005 006 007; do
  echo "Testing MODULE-$module..."
  if bash scripts/tests/test-module-$module.sh; then
    echo "✅ MODULE-$module PASSED"
  else
    echo "❌ MODULE-$module FAILED"
    FAILED_MODULES+=("MODULE-$module")
  fi
  echo ""
done

# Performance Modules
for module in 101 102 103 104; do
  echo "Testing MODULE-$module..."
  if bash scripts/tests/test-module-$module.sh; then
    echo "✅ MODULE-$module PASSED"
  else
    echo "❌ MODULE-$module FAILED"
    FAILED_MODULES+=("MODULE-$module")
  fi
  echo ""
done

# Report
echo "════════════════════════════════════════════════════════════"
if [ ${#FAILED_MODULES[@]} -eq 0 ]; then
  echo "✅ ALL TESTS PASSED"
  exit 0
else
  echo "❌ FAILURES:"
  for module in "${FAILED_MODULES[@]}"; do
    echo "   - $module"
  done
  exit 1
fi
```

---

### Regression Test Suite

**Purpose:** Ensure v3.5.0 doesn't break v3.4.0 functionality

```bash
# scripts/tests/test-regression-v350.sh

test_save_command_still_works() {
  setup_v340_project
  /save
  assert_file_exists "context/STATUS.md"
  assert_file_updated "context/STATUS.md" "within 10 seconds"
}

test_save_full_command_still_works() {
  setup_v340_project
  /save-full
  assert_file_exists "context/SESSIONS.md"
  assert_contains "$(cat context/SESSIONS.md)" "## Session"
}

test_code_review_v340_features_work() {
  setup_v340_project
  /code-review
  # v3.4.0 features: smart grouping, TodoWrite, KNOWN_ISSUES
  assert_file_exists "context/KNOWN_ISSUES.md"
  # v3.5.0 addition: auto-report
  assert_file_exists "artifacts/code-reviews/*.md"
}
```

**Pass Criteria:** All v3.4.0 features still work as expected

---

### Performance Testing

**Purpose:** Ensure new features don't degrade performance

```bash
# scripts/tests/test-performance-v350.sh

test_large_sessions_performance() {
  # Create 10,000 line SESSIONS.md
  create_large_sessions_file 10000

  # Time the review-context command
  start_time=$(date +%s)
  /review-context
  end_time=$(date +%s)

  duration=$((end_time - start_time))
  assert_less_than "$duration" "120" "Should complete in <2 minutes"
}

test_archiving_performance() {
  # Create 100 sessions
  create_test_sessions 100

  # Time archiving
  start_time=$(date +%s)
  bash scripts/archive-sessions-helper.sh --keep 10
  end_time=$(date +%s)

  duration=$((end_time - start_time))
  assert_less_than "$duration" "30" "Should complete in <30 seconds"
}
```

**Pass Criteria:** No performance regressions, meets SLA targets

---

### Security Testing

**Purpose:** Ensure no security vulnerabilities introduced

```bash
# scripts/tests/test-security-v350.sh

test_no_command_injection_in_version_detection() {
  # Malicious VERSION file
  echo '3.5.0; rm -rf /' > VERSION

  # Should not execute malicious code
  /init-context

  assert_directory_exists "/" "Should not have deleted anything"
}

test_no_path_traversal_in_context_detection() {
  # Malicious path
  CONTEXT_DIR="../../../etc"

  # Should reject invalid path
  result=$(find_context_folder 2>&1 || echo "FAILED")
  assert_contains "$result" "not found"
}

test_no_code_execution_in_sed_commands() {
  # Malicious config value
  echo '{"version": "3.5.0$(malicious_command)"}' > context/.context-config.json

  # Should not execute embedded commands
  /update-context-system

  assert_not_contains "$(cat context/.context-config.json)" "malicious_command"
}
```

**Pass Criteria:** No command injection, path traversal, or code execution vulnerabilities

---

### Continuous Integration (CI) Setup

**GitHub Actions Workflow:**
```yaml
# .github/workflows/test-v350.yml

name: AI Context System v3.5.0 Tests

on: [push, pull_request]

jobs:
  test-modules:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
        shell: [bash, zsh]

    steps:
      - uses: actions/checkout@v3

      - name: Run Module Tests
        shell: ${{ matrix.shell }}
        run: bash scripts/tests/run-all-tests.sh

      - name: Run Regression Tests
        shell: ${{ matrix.shell }}
        run: bash scripts/tests/test-regression-v350.sh

      - name: Run Performance Tests
        shell: ${{ matrix.shell }}
        run: bash scripts/tests/test-performance-v350.sh

      - name: Run Security Tests
        shell: ${{ matrix.shell }}
        run: bash scripts/tests/test-security-v350.sh

  integration-test:
    needs: test-modules
    runs-on: ubuntu-latest

    steps:
      - name: Install v3.4.0
        run: ./install.sh

      - name: Upgrade to v3.5.0
        run: /update-context-system

      - name: Verify Upgrade
        run: |
          VERSION=$(cat VERSION)
          [ "$VERSION" = "3.5.0" ]
```

---

### Quality Gates

**Module Cannot Merge Unless:**
- [ ] Unit tests pass (100%)
- [ ] Integration tests pass (100%)
- [ ] Cross-platform tests pass (bash, zsh, sh)
- [ ] Manual verification complete (PASS)
- [ ] No regressions found
- [ ] Performance tests pass
- [ ] Security tests pass
- [ ] Code review approved
- [ ] Documentation updated

**Release Cannot Ship Unless:**
- [ ] ALL critical modules pass all quality gates
- [ ] ALL performance modules pass all quality gates
- [ ] Full regression suite passes
- [ ] Cross-platform testing complete (macOS, Linux, Windows WSL)
- [ ] Beta testing complete (3+ real projects, 7+ days)
- [ ] CHANGELOG updated
- [ ] Migration guide written
- [ ] Security review complete

---

### Manual Testing Checklist (Final Verification)

**Critical Path Testing:**
- [ ] Fresh install v3.5.0 → `/init-context` → config has 3.5.0
- [ ] Upgrade v3.4.0 → v3.5.0 → all features work
- [ ] Run `/review-context` on macOS zsh → no errors
- [ ] Test 5000-line SESSIONS.md → smart loading works
- [ ] Run `/save-full` on 40-session project → archiving prompt appears
- [ ] Run `/code-review` → report auto-created in artifacts/
- [ ] Work from backend/ subdirectory → all commands find context/

**Edge Case Testing:**
- [ ] Missing VERSION file → graceful fallback
- [ ] Missing context/ folder → clear error message
- [ ] Empty SESSIONS.md → commands work
- [ ] Malformed config → validation catches issues
- [ ] Network interruption during update → recoverable
- [ ] Disk full during archiving → backup preserved

**Cross-Platform Verification:**
- [ ] macOS 14+ (zsh, bash)
- [ ] Ubuntu 22.04+ (bash)
- [ ] Debian 11+ (bash)
- [ ] Windows 11 WSL2 (bash)
- [ ] macOS Intel vs ARM → both work

**Browser Compatibility (for documentation):**
- [ ] Chrome/Edge → markdown renders correctly
- [ ] Safari → markdown renders correctly
- [ ] Firefox → markdown renders correctly
- [ ] Mobile browsers → documentation readable

---

### Test Coverage Targets

**Code Coverage:** 90%+ of modified code
**Command Coverage:** 100% of commands tested
**Platform Coverage:** 100% of supported platforms
**Shell Coverage:** bash 4+, zsh 5+, sh (POSIX)

**Coverage Report:**
```bash
# Generate coverage report
bash scripts/tests/generate-coverage-report.sh

# Output:
MODULE-001: 100% (5/5 tests passing)
MODULE-002: 100% (4/4 tests passing)
MODULE-003: 100% (6/6 tests passing)
...
TOTAL: 98% (122/124 tests passing)
```

---

### Test Maintenance

**After Each Module:**
1. Add unit tests to test-module-XXX.sh
2. Add integration tests if needed
3. Update run-all-tests.sh to include new module
4. Document any new test helpers
5. Update CI workflow if needed

**Monthly:**
1. Review test coverage
2. Add tests for found bugs
3. Remove obsolete tests
4. Optimize slow tests
5. Update cross-platform matrix

---

## Summary: Testing Strategy Benefits

✅ **Test-First:** Catch bugs before they're written
✅ **Modular:** Test each module independently
✅ **Automated:** Run full suite in <5 minutes
✅ **Cross-Platform:** Verify on all supported platforms
✅ **Regression-Safe:** Ensure v3.4.0 features still work
✅ **Performance:** No degradation under load
✅ **Secure:** No vulnerabilities introduced
✅ **CI/CD:** Automated testing on every commit
✅ **Quality Gates:** Can't merge without passing tests

---

## Documentation Updates

### Files to Update
1. **CHANGELOG.md** - Add v3.5.0 section with all changes
2. **README.md** - Update version number, highlight key improvements
3. **MIGRATION_GUIDE_v3.4_to_v3.5.md** - Create migration guide
4. **.claude/docs/usage-examples.md** - Add new examples
5. **templates/*.md** - Update with new sections/guidance
6. **VERSION** - Update to 3.5.0

### Key Documentation Additions
- SESSIONS.md archiving guide
- TodoWrite usage guidelines
- Cross-project session documentation examples
- Mental Models enhancement examples
- Decision documentation best practices

---

## Breaking Changes

**None.** All changes are backwards compatible.

**Migration Notes:**
- Existing projects on v3.4.0 can upgrade seamlessly
- SESSIONS.md archiving is optional (triggered automatically when needed)
- Old commands continue to work exactly as before
- New features are additive, not replacing

---

## Success Metrics

### How We'll Know v3.5.0 Is Successful

**Bug Fixes:**
- [ ] Zero reports of hardcoded version issues
- [ ] Zero reports of shell parsing errors on macOS
- [ ] Zero reports of large SESSIONS.md blocking /review-context

**Performance:**
- [ ] Projects with 50+ sessions report smooth experience
- [ ] `/review-context` completes in <2 minutes regardless of file size
- [ ] `/code-review` users report improved workflow (no manual report creation)

**Experience:**
- [ ] New users report cleaner project structure (docs/reference/)
- [ ] Users report forgetting to document decisions less often
- [ ] Session navigation improves for long-running projects

**Adoption:**
- [ ] No regressions (no features break)
- [ ] Positive feedback from beta testers
- [ ] Upgrade rate from v3.4.0 → v3.5.0 > 80% within 30 days

---

## Release Plan

### Beta Testing (1 week)
1. Install v3.5.0-beta on 3 internal projects
2. Run through common workflows (init, save, save-full, review, code-review)
3. Test edge cases (large files, subdirectories, cross-platform)
4. Gather feedback, fix critical issues

### Release Candidate (3 days)
1. Create v3.5.0-rc1
2. Test installation on fresh projects
3. Test upgrade from v3.4.0
4. Verify all documentation updates
5. Run automated test suite

### Production Release
1. Tag v3.5.0 in Git
2. Update VERSION file
3. Update install.sh to point to v3.5.0
4. Publish CHANGELOG.md
5. Announce release
6. Monitor for issues (first 48 hours)

---

## Risk Assessment

### Low Risk ✅
- Template updates (backwards compatible)
- Documentation improvements (additive)
- New optional commands (don't affect existing workflow)
- Shell script improvements (well-tested patterns)

### Medium Risk ⚠️
- SESSIONS.md archiving (file manipulation, must not lose data)
  - **Mitigation:** Extensive testing, backups before archiving
- Version detection logic (must work across environments)
  - **Mitigation:** Test on macOS, Linux, Windows WSL
- Large file handling (token limit edge cases)
  - **Mitigation:** Test with 1K, 5K, 10K line files

### High Risk 🔴
- **None.** All changes are incremental and well-isolated.

---

## Conclusion

AI Context System v3.5.0 represents a **quality-focused upgrade** addressing real user pain points from production usage. The upgrade:

✅ **Fixes 6 bugs** that caused confusion and blocked features
✅ **Improves performance** for long-running projects (20+ sessions)
✅ **Enhances experience** with 15 UX improvements
✅ **Adds zero bloat** - every change solves a real problem
✅ **Maintains backwards compatibility** - seamless upgrade

**Implementation is straightforward** (~27.5 hours), **testing is comprehensive**, and **risk is low**. This upgrade will make AI Context System more reliable, faster, and more pleasant to use—without adding unnecessary complexity.

**Recommendation: Proceed with v3.5.0 implementation.**

---

## Appendix A: Feedback Statistics

**Total Feedback Items:** 62
**By Category:**
- 🐛 Bugs: 6
- 💡 Improvements: 28
- ✨ Feature Requests: 8
- 👍 Praise: 20

**By Severity:**
- 🔴 Critical: 0
- 🟡 Moderate: 10
- 🟢 Minor: 52

**By Project:**
- Project A (Project Gamma): 17 items
- Project B (Project Beta): 22 items
- Project C (Project Alpha): 20 items
- Project D (Context System): 3 items

**Resolution:**
- Included in v3.5.0: 24 items (39%)
- Deferred to v3.6.0+: 12 items (19%)
- User-specific (not applicable): 6 items (10%)
- Praise (no action needed): 20 items (32%)

---

## Appendix B: User Quotes

> "The /init-context command documentation is exceptionally thorough and well-structured. This sets a high bar for AI-executable documentation!"
> — Project B User

> "Mental Models in SESSIONS.md is THE killer feature. Without it, agents might 'refactor away' intentional design decisions."
> — Project A User

> "After /save-full, project has professional-grade documentation for resuming months later. Context System ROI: Extremely High ✅"
> — Project C User

> "Would have saved me 30+ minutes if /code-review auto-created the report document"
> — Project B User

> "SESSIONS.md was flagged as 'too large to include' - will become problematic for very long-running projects"
> — Project B User

---

**Document Version:** 2.1 (Implementation In Progress)
**Author:** AI Context System Team
**Date:** 2025-11-28
**Last Updated:** 2025-11-28 (Progress Update)
**Status:** ⏳ IN PROGRESS - 3/11 Critical Modules Complete
**Approach:** Test-Driven Modular Development

## Revision History

**v2.1 (2025-11-28 - Progress Update):**
- ✅ MODULE-001 complete: Version detection in /init-context (5/5 tests)
- ✅ MODULE-002 complete: Version detection in /update-context-system (8/8 tests)
- ✅ MODULE-003 complete: Shell-compatible version check (8/8 tests)
- 📊 Quality: 100% test success rate (21/21 passing)
- 🎯 Next: MODULE-004 (Decision count grep fix)

**v2.0 (2025-11-28):**
- Complete redesign with modular, step-by-step approach
- Added test-first development methodology
- Each module isolated with clear unit tests
- Comprehensive quality gates and verification
- Zero dependencies between modules (except 101↔102)
- Clear rollback strategies for each module
- Parallel development enabled
- CI/CD integration included

**v1.0 (2025-11-28):**
- Initial proposal with phase-based approach
