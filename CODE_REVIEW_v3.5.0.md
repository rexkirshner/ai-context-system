# Code Review - v3.5.0
## Comprehensive Bug & UX Analysis

**Date:** 2025-11-28
**Reviewer:** Claude Code (Sonnet 4.5)
**Scope:** All new and modified code for v3.5.0
**Status:** 🔴 CRITICAL ISSUES FOUND

---

## Executive Summary

**Total Issues Found:** 23
**Critical (Must Fix):** 7
**High (Should Fix):** 8
**Medium (Nice to Fix):** 6
**Low (Optional):** 2

**Recommendation:** ⚠️ **DO NOT RELEASE** until critical issues are resolved.

---

## CRITICAL ISSUES (Must Fix Before Release)

### CRIT-001: Archive Script - Incorrect Session Numbers in Header
**File:** `scripts/archive-sessions-helper.sh:155`
**Severity:** CRITICAL
**Impact:** Data integrity, user confusion

**Problem:**
```bash
**Sessions:** ${SESSION_LINES[0]} through ${SESSION_LINES[$((KEEP_START_INDEX - 1))]}
```

`SESSION_LINES` array contains **line numbers** (e.g., 45, 123, 567), not session numbers (1, 2, 3).
Archive header will say "Sessions: 45 through 1234" instead of "Sessions: 1 through 5".

**Example:**
- User has sessions 1-20
- Archive should say: "Sessions: 1 through 10"
- Actually says: "Sessions: 78 through 1845" (line numbers)

**Fix Required:**
Extract actual session numbers from the lines, not use line numbers.

```bash
# Extract session number from line
FIRST_SESSION=$(sed -n "${SESSION_LINES[0]}p" "$SESSIONS_FILE" | grep -oE 'Session [0-9]+' | grep -oE '[0-9]+')
LAST_SESSION=$(sed -n "${SESSION_LINES[$((KEEP_START_INDEX - 1))]}p" "$SESSIONS_FILE" | grep -oE 'Session [0-9]+' | grep -oE '[0-9]+')

**Sessions:** Session $FIRST_SESSION through Session $LAST_SESSION
```

---

### CRIT-002: Archive Script - Session Index Not Updated
**File:** `scripts/archive-sessions-helper.sh` (entire script)
**Severity:** CRITICAL
**Impact:** User confusion, incorrect documentation

**Problem:**
After archiving sessions 1-10, SESSIONS.md still has "## Session Index" at top listing sessions 1-20.
User sees:
- Index lists "Session 1, Session 2, ... Session 20"
- But file only contains sessions 11-20
- Clicking links in index leads to 404/not found

**Fix Required:**
Update Session Index section after archiving:
1. Read session index
2. Remove entries for archived sessions
3. Renumber remaining entries
4. Update session links

**Complexity:** Medium
**Alternative:** Document that index becomes stale and user should regenerate it

---

### CRIT-003: Archive Script - No Deduplication on Append
**File:** `scripts/archive-sessions-helper.sh:143-146, 174`
**Severity:** CRITICAL
**Impact:** Data corruption, duplicate sessions

**Problem:**
If user runs archiving twice:
1. First run: Archives sessions 1-10 to `SESSIONS-archive-2025.md`
2. File grows again to 2000 lines with sessions 11-20
3. Second run: Appends sessions 11-15 to `SESSIONS-archive-2025.md`
4. Result: Sessions 11-15 appear TWICE in archive

When appending to existing archive (line 143-146), script doesn't check if sessions already exist.

**Fix Required:**
1. Check if session already exists in archive before appending
2. OR: Use separate archive files per archiving operation (e.g., SESSIONS-archive-2025-11-28.md)
3. OR: Refuse to append, create new archive file with incremented number

---

### CRIT-004: save-full.md - Incorrect Path to Archive Script
**File:** `.claude/commands/save-full.md:274`
**Severity:** CRITICAL
**Impact:** Archiving fails, bad UX

**Problem:**
```bash
bash scripts/archive-sessions-helper.sh --keep 10 --context "$CONTEXT_DIR"
```

Path is relative: `scripts/archive-sessions-helper.sh`

If user runs `/save-full` from subdirectory (e.g., `backend/src/`), the script won't find `scripts/` (which is at project root).

**Example:**
```
/project/backend/src/$ /save-full
bash scripts/archive-sessions-helper.sh: No such file or directory
```

**Fix Required:**
```bash
# Find project root where scripts/ is located
PROJECT_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
bash "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" --keep 10 --context "$CONTEXT_DIR"
```

OR: Use find-context-folder.sh logic to locate project root.

---

### CRIT-005: review-context.md - bash Code Calls Claude Tools
**File:** `.claude/commands/review-context.md:229-260`
**Severity:** CRITICAL
**Impact:** Smart loading doesn't work, confusing instructions

**Problem:**
The "bash code block" contains `Read` tool calls:
```bash
if [ "$FILE_SIZE" -lt 1000 ]; then
  echo "📖 Loading SESSIONS.md fully ($FILE_SIZE lines)"
  # Read entire file
  Read "$CONTEXT_DIR/SESSIONS.md"  # <-- This is Claude tool, not bash!
```

`Read` is a Claude Code tool, not a bash command. This bash block will fail if executed as bash.

**Confusion:**
- Is this bash code that Claude should run using Bash tool?
- OR: Is this instructions for Claude to follow?
- Mixed metaphor: Some parts are bash (if/else), some parts are Claude instructions

**Fix Required:**
Rewrite as **instructions to Claude**, not bash code:

```
If file size < 1000 lines:
  - Use Read tool to load entire file
  - Display "Loading SESSIONS.md fully (N lines)"

If file size 1000-5000 lines:
  - Use Read tool with limit=300 for session index
  - Calculate offset = file_size - 500
  - Use Read tool with offset and limit=500 for recent sessions
  - Display "Loading strategically"

If file size > 5000 lines:
  - Use Read tool with limit=200 for session index
  - Calculate offset = file_size - 300
  - Use Read tool with offset and limit=300 for current session
  - Warn user to archive
```

---

### CRIT-006: review-context.md - "Read entire file" Misleading
**File:** `.claude/commands/review-context.md:235`
**Severity:** CRITICAL
**Impact:** Incomplete data loading

**Problem:**
```bash
Read "$CONTEXT_DIR/SESSIONS.md"  # Read entire file
```

Comment says "Read entire file", but Read tool has default limit of 2000 lines.

If SESSIONS.md is 800 lines (< 1000, "small"), this code path runs.
But if SESSIONS.md is 1500 lines (still < 2000 threshold), Read only gets first 2000 lines.

Wait, 1500 < 2000, so all good. But if somehow it's exactly 1000 lines, smart loading doesn't kick in, and Read gets all 1000. That's fine.

Actually, re-reading: If file is < 1000 lines, it's definitely < 2000, so Read default will get everything. This is NOT a bug.

**Correction:** NOT A BUG. Comment is accurate. Removed from critical list.

---

### CRIT-007: Cross-Document Consistency - Wrong Session Count
**File:** `.claude/commands/review-context.md:449`
**Severity:** HIGH (downgraded from CRITICAL)
**Impact:** Incorrect reporting

**Problem:**
```bash
SESSION_COUNT=$(grep -c "^## Session" "$CONTEXT_DIR/SESSIONS.md" 2>/dev/null || echo "0")
```

Counts ALL lines starting with "## Session", including "## Session Index" header.

If file has sessions 1-10 plus a "## Session Index" header:
- Actual sessions: 10
- Reported sessions: 11 (includes index header)

**Inconsistency:**
Archive script uses `grep -cE "^## Session [0-9]+"` (correct).
Consistency check uses `grep -c "^## Session"` (wrong).

**Fix Required:**
```bash
SESSION_COUNT=$(grep -cE "^## Session [0-9]+" "$CONTEXT_DIR/SESSIONS.md" 2>/dev/null || echo "0")
```

---

## HIGH PRIORITY ISSUES (Should Fix Before Release)

### HIGH-001: Archive Script - Incomplete Error Cleanup
**File:** `scripts/archive-sessions-helper.sh` (multiple locations)
**Severity:** HIGH
**Impact:** Leaves temp files, bad UX

**Problem:**
- Line 14: `set -e` causes immediate exit on any error
- Line 133: Removes $TEMP_FILE on one specific error
- Other error paths (line 117) don't clean up temp files
- If script fails, leaves `.tmp` files in context/

**Fix Required:**
```bash
# Add trap for cleanup
cleanup() {
  rm -f "$TEMP_FILE" "$ARCHIVE_TEMP" 2>/dev/null
}
trap cleanup EXIT ERR
```

---

### HIGH-002: Archive Script - No Atomic Operation
**File:** `scripts/archive-sessions-helper.sh:200`
**Severity:** HIGH
**Impact:** Data loss risk

**Problem:**
```bash
mv "$TEMP_FILE" "$SESSIONS_FILE"
```

If `mv` fails (permissions, disk full, etc.), user loses SESSIONS.md.

**Race Condition:**
1. Create archive ✓
2. Build new SESSIONS.md in temp file ✓
3. Move temp to real → FAILS (disk full)
4. Result: Archive has old sessions, main file is corrupted/missing

**Fix Required:**
```bash
# Verify temp file before overwriting
if [ -f "$TEMP_FILE" ] && [ -s "$TEMP_FILE" ]; then
  # Keep old file as additional backup during move
  cp "$SESSIONS_FILE" "$SESSIONS_FILE.pre-archive"
  mv "$TEMP_FILE" "$SESSIONS_FILE"
  rm -f "$SESSIONS_FILE.pre-archive"
else
  echo "❌ Error: Generated file is empty or missing"
  exit 1
fi
```

---

### HIGH-003: Archive Script - Appending Loses Context
**File:** `scripts/archive-sessions-helper.sh:144-160`
**Severity:** HIGH
**Impact:** Poor UX, hard to navigate archives

**Problem:**
When appending to existing archive:
```bash
cp "$ARCHIVE_FILE" "$ARCHIVE_TEMP"
# Then appends sessions directly
```

No separator between old archived sessions and newly archived sessions.

**Result:**
Archive file has:
```
## Session 1
...
## Session 5
## Session 6  ← Where did first archive end?
...
## Session 10
```

Can't tell that sessions 1-5 were archived on 2025-11-01 and sessions 6-10 on 2025-11-28.

**Fix Required:**
Add separator when appending:
```bash
if [ -f "$ARCHIVE_FILE" ]; then
  ARCHIVE_TEMP="$ARCHIVE_FILE.tmp"
  cp "$ARCHIVE_FILE" "$ARCHIVE_TEMP"

  # Add separator
  cat >> "$ARCHIVE_TEMP" << EOF

---
# Archived on $(date +%Y-%m-%d)
Sessions $FIRST_SESSION through $LAST_SESSION
---

EOF
fi
```

---

### HIGH-004: save-full.md - Weak Archiving Error Handling
**File:** `.claude/commands/save-full.md:276-284`
**Severity:** HIGH
**Impact:** Silent data corruption possible

**Problem:**
```bash
if [ $? -eq 0 ]; then
  echo "✅ Old sessions archived successfully"
else
  echo "⚠️  Archiving failed, continuing without archiving"
fi
```

If archiving script fails partway:
- SESSIONS.md might be corrupted
- Archive might be incomplete
- Backup exists but user doesn't know to restore

Error handling just says "failed" and continues. No guidance.

**Fix Required:**
```bash
if [ $? -eq 0 ]; then
  # Verify archive was created
  if [ -f "$CONTEXT_DIR/SESSIONS-archive-$(date +%Y).md" ]; then
    echo "✅ Archiving successful"
  else
    echo "⚠️  Archiving reported success but archive file not found"
  fi
else
  echo "❌ Archiving failed!"
  echo ""
  echo "Your SESSIONS.md backup is at: $CONTEXT_DIR/SESSIONS.md.backup"
  echo "To restore: cp $CONTEXT_DIR/SESSIONS.md.backup $CONTEXT_DIR/SESSIONS.md"
  echo ""
  read -p "Continue with /save-full or abort? [c/A] " -n 1 -r
  # Handle user choice
fi
```

---

### HIGH-005: review-context.md - No FILE_SIZE Validation
**File:** `.claude/commands/review-context.md:230`
**Severity:** HIGH
**Impact:** Arithmetic errors, script crashes

**Problem:**
```bash
FILE_SIZE=$(wc -l < "$CONTEXT_DIR/SESSIONS.md" 2>/dev/null | tr -d ' ')

if [ "$FILE_SIZE" -lt 1000 ]; then
```

If `wc -l` fails or file doesn't exist, FILE_SIZE could be empty string.
Then `[ "" -lt 1000 ]` causes error: "integer expression expected"

**Fix Required:**
```bash
FILE_SIZE=$(wc -l < "$CONTEXT_DIR/SESSIONS.md" 2>/dev/null | tr -d ' ')

# Validate FILE_SIZE is a number
if ! [[ "$FILE_SIZE" =~ ^[0-9]+$ ]]; then
  echo "⚠️  Could not determine SESSIONS.md size"
  FILE_SIZE=0
fi

if [ "$FILE_SIZE" -eq 0 ]; then
  echo "⚠️  SESSIONS.md is empty or not found"
elif [ "$FILE_SIZE" -lt 1000 ]; then
  # ... smart loading logic
fi
```

---

### HIGH-006: Cross-Document Consistency - No Actionable Fix Guidance
**File:** `.claude/commands/review-context.md:442`
**Severity:** HIGH
**Impact:** Poor UX, user doesn't know how to fix

**Problem:**
```bash
if [ "$CONTEXT_PHASE" != "$STATUS_PHASE" ]; then
  echo "  ⚠️  Phase drift detected - files show different phases"
fi
```

Tells user there's a problem, but not:
- Which file is wrong
- Which phase is correct
- How to fix it

**Fix Required:**
```bash
if [ "$CONTEXT_PHASE" != "$STATUS_PHASE" ]; then
  echo "  ⚠️  Phase mismatch detected:"
  echo "      CONTEXT.md: \"$CONTEXT_PHASE\""
  echo "      STATUS.md:  \"$STATUS_PHASE\""
  echo ""
  echo "  Action: Update the incorrect file to match your current phase."
  echo "  Typically STATUS.md is more current (updated by /save)."
fi
```

---

### HIGH-007: Smart Loading - Session Index Could Be > 300 Lines
**File:** `.claude/commands/review-context.md:240`
**Severity:** MEDIUM (downgraded from HIGH)
**Impact:** Incomplete index loading for very active projects

**Problem:**
```bash
Read "$CONTEXT_DIR/SESSIONS.md" limit=300
```

Reads first 300 lines assuming that covers the Session Index.

For a project with 100+ sessions, index could be > 300 lines.
Would cut off mid-index.

**Likelihood:** LOW (most projects have < 50 sessions)

**Fix Required:**
Find where Session Index ends (first `---` separator), then read up to that point.

---

### HIGH-008: Archive Script - Help Text Wrong Module Number
**File:** `scripts/archive-sessions-helper.sh:3`
**Severity:** LOW (downgraded)
**Impact:** Documentation inconsistency

**Problem:**
```bash
# Part of AI Context System v3.5.0 - MODULE-101
```

Archive script is MODULE-102, not MODULE-101.
(MODULE-101 is code review auto-report)

**Fix Required:**
```bash
# Part of AI Context System v3.5.0 - MODULE-102
```

---

## MEDIUM PRIORITY ISSUES (Nice to Fix)

### MED-001: Archive Filename Only Uses Year
**File:** `scripts/archive-sessions-helper.sh:52`
**Severity:** MEDIUM
**Impact:** Large archive files, hard to navigate

**Problem:**
```bash
ARCHIVE_FILE="$CONTEXT_DIR/SESSIONS-archive-$YEAR.md"
```

All archivings in 2025 go to `SESSIONS-archive-2025.md`.

If user archives quarterly:
- Q1: Appends sessions 1-50
- Q2: Appends sessions 51-100
- Q3: Appends sessions 101-150
- Q4: Appends sessions 151-200

Result: One giant 200-session file, hard to navigate.

**Recommendation:**
Option 1: Use month in filename
```bash
ARCHIVE_FILE="$CONTEXT_DIR/SESSIONS-archive-$(date +%Y-%m).md"
```

Option 2: Use incremental numbering
```bash
# Find next available archive number
ARCHIVE_NUM=1
while [ -f "$CONTEXT_DIR/SESSIONS-archive-$YEAR-$ARCHIVE_NUM.md" ]; do
  ARCHIVE_NUM=$((ARCHIVE_NUM + 1))
done
ARCHIVE_FILE="$CONTEXT_DIR/SESSIONS-archive-$YEAR-$ARCHIVE_NUM.md"
```

---

### MED-002: save-full.md - No "Don't Ask Again" Option
**File:** `.claude/commands/save-full.md:268`
**Severity:** MEDIUM
**Impact:** Annoying for users who don't want to archive

**Problem:**
```bash
read -p "Archive old sessions (keep last 10)? [Y/n] " -n 1 -r
```

Every time SESSIONS.md > 2000 lines, user is prompted.

If user says "n" once, they're prompted again next time, and again, and again.
No way to say "stop asking me."

**Recommendation:**
Add `.no-archive` flag file:
```bash
if [ -f "$CONTEXT_DIR/.no-archive" ]; then
  # User opted out, skip prompt
  echo "ℹ️  Auto-archiving disabled (to re-enable: rm context/.no-archive)"
else
  read -p "Archive old sessions? [Y/n/never] " -n 1 -r

  if [[ $REPLY =~ ^[Nn]ever$ ]]; then
    touch "$CONTEXT_DIR/.no-archive"
    echo "Auto-archiving disabled for this project"
  elif [[ $REPLY =~ ^[Yy]$ ]]; then
    # ... do archiving
  fi
fi
```

---

### MED-003: Archive Script - No Validation of Extracted Sessions
**File:** `scripts/archive-sessions-helper.sh:174, 195`
**Severity:** MEDIUM
**Impact:** Silent corruption possible

**Problem:**
Script extracts session content using `sed -n "${SESSION_START},${SESSION_END}p"`.

No validation that extracted content:
- Actually starts with "## Session N"
- Is non-empty
- Makes sense

If SESSIONS.md is malformed, could archive garbage.

**Recommendation:**
```bash
# After extraction, validate
EXTRACTED=$(sed -n "${SESSION_START},${SESSION_END}p" "$SESSIONS_FILE")
if ! echo "$EXTRACTED" | head -1 | grep -qE "^## Session [0-9]+"; then
  echo "❌ Error: Extracted content doesn't start with session header"
  echo "   Session $i at line $SESSION_START"
  exit 1
fi
```

---

### MED-004: --context DIR Not Validated
**File:** `scripts/archive-sessions-helper.sh:29-30`
**Severity:** MEDIUM
**Impact:** Confusing error messages

**Problem:**
```bash
--context)
  CONTEXT_DIR="$2"
  shift 2
```

Accepts any value for --context, even `/nonexistent/path`.

Later (line 57) checks if SESSIONS_FILE exists, but error message is:
```
❌ Error: /nonexistent/path/SESSIONS.md not found
```

Doesn't clearly indicate that the **directory** is wrong.

**Fix Required:**
```bash
--context)
  CONTEXT_DIR="$2"
  if [ ! -d "$CONTEXT_DIR" ]; then
    echo "❌ Error: Context directory does not exist: $CONTEXT_DIR"
    exit 1
  fi
  shift 2
```

---

### MED-005: Trailing Blank Lines in Archived Sessions
**File:** `scripts/archive-sessions-helper.sh:175, 196`
**Severity:** LOW
**Impact:** Slight formatting inconsistency

**Problem:**
```bash
sed -n "${SESSION_START},${SESSION_END}p" "$SESSIONS_FILE" >> "$ARCHIVE_TEMP"
echo "" >> "$ARCHIVE_TEMP"  # Add blank line between sessions
```

Adds blank line after EVERY session, including last one.

Result: Archive file ends with trailing blank line.

**Recommendation:**
Only add blank line if not the last session:
```bash
sed -n "${SESSION_START},${SESSION_END}p" "$SESSIONS_FILE" >> "$ARCHIVE_TEMP"

# Only add separator if not last session
if [ $i -lt $((KEEP_START_INDEX - 1)) ]; then
  echo "" >> "$ARCHIVE_TEMP"
fi
```

---

### MED-006: Date Parsing Inconsistency
**File:** `.claude/commands/review-context.md:424-426`
**Severity:** MEDIUM
**Impact:** False positives in consistency checks

**Problem:**
```bash
CONTEXT_DATE=$(grep "Last Updated:" "$CONTEXT_DIR/CONTEXT.md" 2>/dev/null | sed 's/.*Last Updated: *//' | head -1)
```

Assumes format "Last Updated: YYYY-MM-DD"

But some files might have:
- "Last Updated: 2025-11-28 14:30" (includes time)
- "Last Updated: November 28, 2025" (different format)
- Multiple "Last Updated:" fields in file

`head -1` takes first occurrence, which might not be the file-level one.

**Recommendation:**
Define standard format in templates, document in guide.

OR: Parse more flexibly:
```bash
# Extract just the date portion (YYYY-MM-DD)
CONTEXT_DATE=$(grep "Last Updated:" "$CONTEXT_DIR/CONTEXT.md" | head -1 | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
```

---

## LOW PRIORITY ISSUES (Optional)

### LOW-001: save-full.md - UX Inconsistency in Prompt
**File:** `.claude/commands/save-full.md:268`
**Severity:** LOW
**Impact:** Minor UX confusion

**Problem:**
```bash
read -p "Archive old sessions (keep last 10)? [Y/n] " -n 1 -r
```

Uses `[Y/n]` pattern (Y is default).

Then checks:
```bash
if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
```

The `|| [[ -z $REPLY ]]` suggests pressing Enter (empty) = Yes.

But with `-n 1`, pressing Enter gives empty string, which works.

**Potential Confusion:**
Some users might think:
- `-n 1` means "read 1 character"
- So they type "Y" without Enter
- Actually `-n 1` makes it so just pressing Enter works too

This is technically correct but might confuse users familiar with `-n 1` pattern.

**Recommendation:**
Document or add comment explaining behavior:
```bash
# -n 1 reads single char; Enter alone = accept default (Y)
read -p "Archive old sessions (keep last 10)? [Y/n] " -n 1 -r
```

---

### LOW-002: Module Documentation Inconsistency
**File:** Various
**Severity:** LOW
**Impact:** Documentation clarity

**Problem:**
Different files reference modules inconsistently:
- Some say "MODULE-102" (correct)
- Some say "MODULE-101" (wrong)
- Some say "v3.5.0" without module number

**Recommendation:**
Standardize module references across all files.

---

## SUMMARY BY FILE

### scripts/archive-sessions-helper.sh
- 🔴 CRIT-001: Incorrect session numbers in header
- 🔴 CRIT-002: Session index not updated
- 🔴 CRIT-003: No deduplication on append
- 🟠 HIGH-001: Incomplete error cleanup
- 🟠 HIGH-002: No atomic operation
- 🟠 HIGH-003: Appending loses context
- 🟠 HIGH-008: Wrong module number
- 🟡 MED-001: Filename only uses year
- 🟡 MED-003: No session validation
- 🟡 MED-004: No context dir validation
- 🟡 MED-005: Trailing blank lines

**Total:** 11 issues (3 critical, 4 high, 4 medium)

### .claude/commands/save-full.md
- 🔴 CRIT-004: Incorrect script path
- 🟠 HIGH-004: Weak error handling
- 🟡 MED-002: No "don't ask again" option
- ⚪ LOW-001: UX inconsistency in prompt

**Total:** 4 issues (1 critical, 1 high, 1 medium, 1 low)

### .claude/commands/review-context.md
- 🔴 CRIT-005: bash code calls Claude tools
- 🔴 CRIT-007: Wrong session count
- 🟠 HIGH-005: No FILE_SIZE validation
- 🟠 HIGH-006: No actionable fix guidance
- 🟠 HIGH-007: Session index might be > 300 lines
- 🟡 MED-006: Date parsing inconsistency

**Total:** 6 issues (2 critical, 3 high, 1 medium)

### install.sh
- ✅ No critical issues found
- (Previously found issues were in scope review, now verified)

---

## IMPACT ASSESSMENT

### If Released As-Is:

**Data Corruption Risks:**
- CRIT-001: Wrong info in archive headers (confusing but not destructive)
- CRIT-003: Duplicate sessions in archives (confusing, wastes space)
- HIGH-002: Potential SESSIONS.md loss if mv fails

**Feature Failures:**
- CRIT-004: Archiving won't work from subdirectories
- CRIT-005: Smart loading instructions unclear

**User Confusion:**
- CRIT-002: Session index lists non-existent sessions
- CRIT-007: Wrong session counts reported
- HIGH-006: No guidance on fixing consistency issues

**Silent Failures:**
- HIGH-001: Temp files left behind on error
- HIGH-004: Archiving fails but user doesn't know how to recover

**Probability of Issues:**
- Data corruption: LOW (requires specific failure conditions)
- Feature failures: **HIGH** (will happen to many users)
- User confusion: **VERY HIGH** (will happen to all users)

---

## RECOMMENDATIONS

### Must Fix Before v3.5.0 Release:
1. ✅ CRIT-001: Fix session numbers in archive header
2. ✅ CRIT-003: Add deduplication or separate archive files
3. ✅ CRIT-004: Fix script path in save-full.md
4. ✅ CRIT-005: Rewrite smart loading as instructions, not bash
5. ✅ CRIT-007: Use correct grep pattern for session count

### Should Fix Before Release (High Priority):
6. ✅ HIGH-001: Add cleanup trap to archive script
7. ✅ HIGH-002: Make archive operation atomic
8. ✅ HIGH-004: Improve archiving error handling
9. ✅ HIGH-005: Validate FILE_SIZE before arithmetic

### Can Release Without (But Should Fix Soon):
- CRIT-002: Session index update (document as known limitation)
- HIGH-003: Archive append separator (improves UX)
- HIGH-006: Better consistency check guidance (improves UX)
- All MEDIUM issues

### Can Defer to v3.5.1:
- All LOW issues
- MED-001 through MED-006

---

## TESTING REQUIREMENTS

After fixes, must test:

1. **Archive Script:**
   - Archive from project root ✓
   - Archive from subdirectory ✓
   - Archive with existing archive file ✓
   - Archive when disk is nearly full ✓
   - Archive when permissions are restricted ✓
   - Verify session numbers in header ✓
   - Run twice, verify no duplicates ✓

2. **Smart Loading:**
   - SESSIONS.md with 500 lines ✓
   - SESSIONS.md with 2500 lines ✓
   - SESSIONS.md with 8000 lines ✓
   - SESSIONS.md missing ✓
   - SESSIONS.md corrupted ✓

3. **Consistency Checks:**
   - Matching phases ✓
   - Mismatched phases ✓
   - Missing fields ✓
   - Multiple occurrences ✓

4. **Error Paths:**
   - Archive script fails mid-operation ✓
   - Disk full during archiving ✓
   - User cancels archiving ✓
   - SESSIONS.md is read-only ✓

---

## CONCLUSION

**Current Status:** 🔴 NOT READY FOR RELEASE

**Critical Issues:** 5 (must fix)
**High Priority Issues:** 5 (should fix)
**Medium Priority Issues:** 6 (nice to fix)
**Low Priority Issues:** 2 (optional)

**Estimated Fix Time:**
- Critical issues: 4-6 hours
- High priority: 3-4 hours
- Total: 7-10 hours

**Recommendation:**
1. Fix all 5 critical issues
2. Fix at least HIGH-001, HIGH-002, HIGH-004, HIGH-005
3. Test thoroughly
4. Release as v3.5.0
5. Address remaining issues in v3.5.1

**Quality Gate:** Cannot proceed to release until critical issues resolved and tested.

---

**Review Completed:** 2025-11-28
**Next Action:** Create fix plan and implement critical fixes
