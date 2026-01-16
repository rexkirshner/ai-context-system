# v3.7.0 Upgrade Plan - Friction Reduction Release

**Created**: 2026-01-05
**Updated**: 2026-01-05
**Status**: IN PROGRESS - Phase 1 Complete
**Philosophy**: Reduce manual maintenance friction. Automate the tedious. Keep it simple.

---

## Overview

This release addresses friction points identified from real-world usage. The core system works well - users report it's "genuinely useful" and the philosophy is "sound." The issues are about reducing manual maintenance overhead.

### Source Feedback

From production use across multiple projects:
- Documentation drift despite system (detection works, prevention doesn't)
- Manual timestamps are error-prone and forgotten
- .context-config.json becomes stale/redundant
- Session numbering gaps are confusing
- CONTEXT.md vs CLAUDE.md overlap is fuzzy
- TodoWrite state not captured in sessions

### Guiding Principles

1. **Automate the tedious** - If humans forget to do it, automate it
2. **Don't add complexity** - Simplify existing, don't add new
3. **Modular changes** - Each checkpoint independently testable
4. **Preserve what works** - The core system is solid

---

## Concurrent Implementation with v4.0.0

This plan can be implemented concurrently with v4.0.0 (Modular Code Review). See [Concurrent Implementation Roadmap](#concurrent-implementation-roadmap) at the end of this document.

**Shared Resources:**
- Both plans modify `scripts/common-functions.sh` (no conflicts - different functions)
- Both plans modify VERSION and CHANGELOG.md at release time

**Independence:** All v3.7.0 phases are independent of v4.0.0 phases.

---

## Phase 1: Auto-Timestamps

**Goal**: Eliminate manual "Last Updated" date maintenance
**Risk**: Low
**Value**: High (single biggest friction reducer per user feedback)

### Checkpoint 1.1: Identify timestamp patterns ✅ COMPLETE

- [x] Audit all template files for "Last Updated" patterns
- [x] Document the different formats used:
  - `**Last Updated:** YYYY-MM-DD`
  - `*Updated: YYYY-MM-DD*`
  - `<!-- Updated: YYYY-MM-DD -->`
- [x] Create regex patterns for each format
- [x] List files touched by /save and /save-full

**Deliverable**: `development/planning/v3.7.0/timestamp-audit.md` ✅

**Verification:**
- [x] Document exists at specified path
- [x] Document lists all timestamp patterns found
- [x] Document lists which files /save and /save-full modify

### Checkpoint 1.2: Implement timestamp helper function ✅ COMPLETE

- [x] Add `update_last_modified()` function to `scripts/common-functions.sh`
- [x] Function signature: `update_last_modified <file> [format]`
- [x] Support multiple date formats (auto-detect from file)
- [x] Handle missing "Last Updated" gracefully (don't add if not present)
- [x] Cross-platform compatible (macOS + Linux sed differences)

**Deliverable**: Function in `scripts/common-functions.sh` ✅

**Verification:** All tests passing
```bash
# Test 1: Function exists and is callable
source scripts/common-functions.sh
type update_last_modified  # Should show function definition

# Test 2: Updates date in test file
echo "**Last Updated:** 2020-01-01" > /tmp/test.md
update_last_modified /tmp/test.md
grep "$(date +%Y-%m-%d)" /tmp/test.md  # Should find today's date

# Test 3: Does nothing if no timestamp present
echo "No timestamp here" > /tmp/test2.md
update_last_modified /tmp/test2.md
diff /tmp/test2.md <(echo "No timestamp here")  # Should be identical
```

### Checkpoint 1.3: Integrate into /save ✅ COMPLETE

- [x] Add timestamp update call in `save.md` for STATUS.md
- [x] Ensure function is sourced before use

**Deliverable**: Updated `.claude/commands/save.md` ✅

**Verification:**
- [x] Run `/save` on test project
- [x] Verify STATUS.md "Last Updated" date changed to today
- [x] Verify no other files were modified unexpectedly
- [x] Verify /save still completes successfully

### Checkpoint 1.4: Integrate into /save-full ✅ COMPLETE

- [x] Add timestamp update calls for all touched files:
  - STATUS.md
  - SESSIONS.md
  - CONTEXT.md (if modified)
  - DECISIONS.md (if modified)

**Deliverable**: Updated `.claude/commands/save-full.md` ✅

**Verification:**
- [x] Run `/save-full` on test project
- [x] Verify STATUS.md date updated
- [x] Verify SESSIONS.md date updated
- [x] Verify files NOT touched by /save-full retain original dates
- [x] Verify /save-full still completes successfully

### Checkpoint 1.5: Test suite ✅ COMPLETE

- [x] Create `scripts/tests/test-auto-timestamps.sh`
- [x] Test cases:
  - File with "Last Updated" → date changes
  - File without "Last Updated" → no changes
  - Different date formats → all work
  - macOS vs Linux → both work
- [ ] Add to `scripts/tests/run-all-tests.sh` (deferred - run-all-tests.sh not yet implemented)

**Deliverable**: Test script passing ✅ (6 tests, all passing)

**Verification:**
```bash
# Run the test script
./scripts/tests/test-auto-timestamps.sh
# Exit code should be 0
echo $?  # Should output: 0

# All tests should pass
./scripts/tests/run-all-tests.sh | grep -i timestamp
# Should show: "test-auto-timestamps.sh ... PASS"
```

**Implementation Notes (2026-01-05):**
- Used `grep -F` for fixed-string matching (avoids regex issues with `**`)
- Cross-platform sed detection using `sed --version` to detect GNU vs BSD
- Function gracefully handles missing timestamp patterns (returns 0, no changes)

---

## Phase 2: Simplify .context-config.json

**Goal**: Remove duplicate project info, keep only preferences/settings
**Risk**: Medium (breaking change for any tooling reading config)
**Value**: High (eliminates stale artifact problem)

### Checkpoint 2.1: Audit current config usage

- [ ] Search codebase for `.context-config.json` reads
- [ ] Document which fields are actually used by commands
- [ ] Identify fields duplicated in STATUS.md/CONTEXT.md:
  - `project.urls` → duplicated in STATUS.md Quick Reference
  - `project.techStack` → duplicated in CONTEXT.md and CLAUDE.md
  - `project.commands` → duplicated in STATUS.md Quick Reference
- [ ] Identify fields that are preferences-only (keep these)

**Deliverable**: `development/planning/v3.7.0/config-audit.md`

**Verification:**
- [ ] Document exists at specified path
- [ ] Document lists all files that read .context-config.json
- [ ] Document identifies which fields are duplicated vs unique
- [ ] Document recommends which fields to keep/remove

### Checkpoint 2.2: Design simplified schema

- [ ] Create new minimal schema with only:
  - `version` (required)
  - `owner` (required)
  - `project.name` (required)
  - `project.type` (required)
  - `project.initialized` (required)
  - `preferences.*` (all current preferences - keep as-is)
  - `commands.*` (enabled commands, aliases)
  - `validation.*` (staleness thresholds)
  - `metadata.*` (config metadata)
- [ ] Remove duplicated fields:
  - `project.urls` → lives in STATUS.md only
  - `project.techStack` → lives in CONTEXT.md only
  - `project.commands` → lives in STATUS.md only
- [ ] Document migration path for existing configs

**Deliverable**: `config/context-config-schema-v2.json`

**Verification:**
- [ ] Schema file exists at specified path
- [ ] Schema validates with JSON Schema validator
- [ ] Schema does NOT include removed fields (urls, techStack, commands)
- [ ] Schema DOES include all preference fields
- [ ] Migration path documented in schema or separate doc

### Checkpoint 2.3: Update config template

- [ ] Update `config/.context-config.template.json` with simplified schema
- [ ] Add comment explaining where removed fields now live
- [ ] Ensure backwards compatibility (old configs still parse)

**Deliverable**: Updated config template

**Verification:**
- [ ] Template matches new schema
- [ ] Template is valid JSON
- [ ] Old configs (v3.6.x) still parse without errors
- [ ] Comment present explaining field migration

### Checkpoint 2.4: Update commands that read config

- [ ] Update /review-context to not expect removed fields
- [ ] Update /validate-context to use new schema
- [ ] Update /init-context to create simplified config
- [ ] Test all commands with both old and new config formats

**Deliverable**: Updated commands, all tests passing

**Verification:**
```bash
# Test with NEW config format
/init-context  # Creates new-style config
/review-context  # Should work
/validate-context  # Should work

# Test with OLD config format (backwards compatibility)
# Copy old-style config to test project
/review-context  # Should work (graceful handling of extra fields)
/validate-context  # Should work
```

### Checkpoint 2.5: Migration helper

- [ ] Add config migration to /update-context-system
- [ ] Auto-detect old config format
- [ ] Remove deprecated fields (keep preferences)
- [ ] Add informational message about where data moved

**Deliverable**: Migration logic in update-context-system.md

**Verification:**
- [ ] Create test project with v3.6.x config
- [ ] Run /update-context-system
- [ ] Verify deprecated fields removed from config
- [ ] Verify preferences preserved
- [ ] Verify informational message displayed
- [ ] Verify config still valid JSON after migration

---

## Phase 3: Session Number Validation

**Goal**: Warn about session numbering gaps (non-blocking)
**Risk**: Low
**Value**: Medium (prevents confusion)

### Checkpoint 3.1: Implement gap detection

- [ ] Add `detect_session_gaps()` function to `scripts/save-full-helper.sh`
- [ ] Parse SESSIONS.md for session numbers
- [ ] Return list of gaps (e.g., "5, 6, 7" if session 8 follows 4)
- [ ] Handle edge cases:
  - No sessions yet
  - Only one session
  - Non-numeric session identifiers

**Deliverable**: Function in `scripts/save-full-helper.sh`

**Verification:**
```bash
# Test 1: No gaps returns empty
echo "## Session 1\n## Session 2\n## Session 3" > /tmp/sessions.md
result=$(detect_session_gaps /tmp/sessions.md)
[ -z "$result" ]  # Should be empty

# Test 2: Gap detected
echo "## Session 1\n## Session 2\n## Session 5" > /tmp/sessions.md
result=$(detect_session_gaps /tmp/sessions.md)
echo "$result" | grep -q "3, 4"  # Should find gap

# Test 3: Empty file returns empty
echo "" > /tmp/sessions.md
result=$(detect_session_gaps /tmp/sessions.md)
[ -z "$result" ]  # Should be empty
```

### Checkpoint 3.2: Add warning to /save-full

- [ ] Call `detect_session_gaps()` before creating new session
- [ ] If gaps found, display warning:
  ```
  ⚠️  Session gap detected: Sessions 5-7 appear missing
      (Session 8 would follow Session 4)
      This is informational - continuing with save.
  ```
- [ ] Do NOT block - just inform
- [ ] Log warning to session entry if gaps exist

**Deliverable**: Updated `.claude/commands/save-full.md`

**Verification:**
- [ ] Create test project with sessions 1, 2, 5 (gap at 3-4)
- [ ] Run /save-full
- [ ] Verify warning message displayed
- [ ] Verify save completes successfully (not blocked)
- [ ] Verify session entry notes the gap

### Checkpoint 3.3: Test suite

- [ ] Create `scripts/tests/test-session-gaps.sh`
- [ ] Test cases:
  - Sequential sessions (1,2,3) → no warning
  - Gap (1,2,5) → warning about 3,4
  - Single session → no warning
  - Empty SESSIONS.md → no warning

**Deliverable**: Test script passing

**Verification:**
```bash
./scripts/tests/test-session-gaps.sh
echo $?  # Should be 0
```

---

## Phase 4: TodoWrite Capture Prompt

**Goal**: Make it easy to capture TodoWrite state in /save-full
**Risk**: Low (template change only)
**Value**: Medium (captures actual work tracking)

### Checkpoint 4.1: Update SESSIONS.md template

- [ ] Add "TodoWrite State" section to session entry template:
  ```markdown
  ### TodoWrite State (at save time)

  <!-- Paste your current TodoWrite list here -->
  <!-- If no active todos, write "No active todos" -->

  - [ ] Example todo item
  ```
- [ ] Position after "Work in Progress" section

**Deliverable**: Updated `templates/SESSIONS.template.md`

**Verification:**
- [ ] Template file contains "TodoWrite State" section
- [ ] Section positioned after "Work in Progress"
- [ ] Section includes instructional comment

### Checkpoint 4.2: Update /save-full instructions

- [ ] Add explicit step to capture TodoWrite state
- [ ] Add reminder text:
  ```
  📋 TodoWrite Capture:
     Copy your current TodoWrite list and include it in the session entry.
     This preserves your work tracking for future sessions.
  ```
- [ ] Make it skippable (not all sessions use TodoWrite)

**Deliverable**: Updated `.claude/commands/save-full.md`

**Verification:**
- [ ] /save-full command mentions TodoWrite capture
- [ ] Instructions are clear about what to do
- [ ] Instructions note it's optional

### Checkpoint 4.3: Update documentation

- [ ] Add note to `.claude/docs/command-philosophy.md` about TodoWrite capture
- [ ] Explain that auto-capture is not possible (TodoWrite is ephemeral)

**Deliverable**: Updated documentation

**Verification:**
- [ ] command-philosophy.md mentions TodoWrite capture
- [ ] Explanation of why auto-capture isn't possible is present

---

## Phase 5: Clarify CLAUDE.md vs CONTEXT.md

**Goal**: Clear documentation of file roles and intentional overlap
**Risk**: Low (documentation only)
**Value**: Medium (reduces confusion)

### Checkpoint 5.1: Update CLAUDE.md template comments

- [ ] Add header comment explaining purpose:
  ```markdown
  <!--
  CLAUDE.md - Auto-loaded by Claude Code at conversation start

  PURPOSE: Critical rules and quick pointers (~50-100 lines)
  - Git workflow rules (commit often, push with permission)
  - No lazy coding rules
  - Session commands reference
  - Links to detailed docs

  NOT FOR: Comprehensive project context (use CONTEXT.md)

  INTENTIONAL OVERLAP: Tech stack appears here AND in CONTEXT.md
  because CLAUDE.md should be self-sufficient for quick sessions.
  -->
  ```

**Deliverable**: Updated `templates/CLAUDE.md.template`

**Verification:**
- [ ] Template file starts with HTML comment block
- [ ] Comment explains PURPOSE
- [ ] Comment explains NOT FOR
- [ ] Comment explains INTENTIONAL OVERLAP

### Checkpoint 5.2: Update CONTEXT.md template comments

- [ ] Add header comment explaining purpose:
  ```markdown
  <!--
  CONTEXT.md - Deep project orientation

  PURPOSE: Comprehensive context for new sessions (~300+ lines)
  - Project overview and history
  - Tech stack rationale (WHY these choices)
  - Architecture overview
  - Development workflow details
  - Environment setup

  NOT FOR: Critical rules (use CLAUDE.md)

  RELATIONSHIP TO CLAUDE.md:
  - CLAUDE.md = rules + pointers (auto-loaded, always present)
  - CONTEXT.md = comprehensive context (read when needed)
  -->
  ```

**Deliverable**: Updated `templates/CONTEXT.template.md`

**Verification:**
- [ ] Template file starts with HTML comment block
- [ ] Comment explains PURPOSE
- [ ] Comment explains NOT FOR
- [ ] Comment explains RELATIONSHIP TO CLAUDE.md

### Checkpoint 5.3: Update command philosophy doc

- [ ] Add section "File Roles and Relationships"
- [ ] Explain the hierarchy:
  - CLAUDE.md: Auto-loaded, critical rules, ~50-100 lines
  - STATUS.md: Current state, Quick Reference, ~100-200 lines
  - CONTEXT.md: Deep orientation, ~300+ lines
  - SESSIONS.md: History, append-only, grows over time
  - DECISIONS.md: Rationale, append-only, highest value for AI handoffs

**Deliverable**: Updated `.claude/docs/command-philosophy.md`

**Verification:**
- [ ] "File Roles and Relationships" section exists
- [ ] All 5 core files are listed with their roles
- [ ] Line count guidance is included
- [ ] Hierarchy is clear

---

## Phase 6: Optional Git Hook Template

**Goal**: Provide optional save reminder for power users
**Risk**: Low (opt-in only)
**Value**: Low-Medium (addresses prevention vs detection)

### Checkpoint 6.1: Create hook template

- [ ] Create `templates/git-hooks/post-commit.template`
- [ ] Simple logic:
  ```bash
  # Check days since last /save
  LAST_SAVE=$(stat -f %m context/STATUS.md 2>/dev/null || echo 0)
  NOW=$(date +%s)
  DAYS_AGO=$(( (NOW - LAST_SAVE) / 86400 ))

  if [ $DAYS_AGO -gt 3 ]; then
    echo "💡 Reminder: Last /save was $DAYS_AGO days ago"
    echo "   Consider running /save to capture recent work"
  fi
  ```
- [ ] Make it non-blocking (just a reminder)

**Deliverable**: `templates/git-hooks/post-commit.template`

**Verification:**
- [ ] Template file exists at specified path
- [ ] Template is executable shell script
- [ ] Template does NOT block commits (exit 0)
- [ ] Template displays reminder if STATUS.md old

### Checkpoint 6.2: Document in future-upgrades

- [ ] Add `development/planning/future-upgrades/git-hooks.md`
- [ ] Explain:
  - This is opt-in, not enforced
  - How to install: `cp templates/git-hooks/post-commit .git/hooks/`
  - How to disable: `rm .git/hooks/post-commit`
  - Why it's not default (minimal overhead philosophy)

**Deliverable**: Documentation in future-upgrades/

**Verification:**
- [ ] Documentation file exists
- [ ] Install instructions are correct
- [ ] Disable instructions are correct
- [ ] Philosophy explanation present

---

## Explicitly NOT Doing in v3.7.0

### Deferred to Future Versions

| Feature | Reason | Reconsider When |
|---------|--------|-----------------|
| Auto-sync .context-config.json | Complex, error-prone | If simplified config isn't enough |
| Blocking session gap validation | Annoying, gaps may be intentional | If users request blocking mode |
| Git hooks as default | Violates minimal overhead philosophy | If 5+ users request it |
| TodoWrite auto-capture | Technically impossible from bash | If Claude Code provides API |
| Move all bash to helpers | Partial refactor sufficient | If maintenance becomes painful |

### Explicitly Rejected

| Feature | Reason |
|---------|--------|
| Complex multi-file sync | Adds complexity, unclear value |
| Real-time drift prevention | Would require background daemon |
| Automated session creation | Defeats purpose of thoughtful documentation |

---

## Testing Strategy

### Per-Phase Testing

Each phase has its own test checkpoint. All tests must pass before moving to next phase.

### Integration Testing

After all phases complete:

1. **Clean install test**
   - [ ] Fresh project with /init-context
   - [ ] Verify CLAUDE.md at root with header comment
   - [ ] Verify simplified .context-config.json
   - [ ] Verify all templates have role comments

2. **Upgrade test**
   - [ ] Existing v3.6.1 project
   - [ ] Run /update-context-system
   - [ ] Verify config migration works
   - [ ] Verify no data loss

3. **Workflow test**
   - [ ] Run /save → timestamps update
   - [ ] Run /save-full → session gaps warned (if applicable)
   - [ ] Run /review-context → no errors

### Test Projects

- [ ] Test on ai-context-system itself
- [ ] Test on at least 2 other real projects before release

---

## Success Metrics

### Must Have (Release Blockers)

- [ ] Auto-timestamps work on /save and /save-full
- [ ] No regressions in existing functionality
- [ ] All existing tests pass
- [ ] All new tests pass

### Should Have

- [ ] .context-config.json simplified
- [ ] Session gap warnings work
- [ ] File role comments in place

### Nice to Have

- [ ] Git hook template documented
- [ ] TodoWrite prompt in /save-full template

---

## Implementation Order

```
Phase 1 (Auto-Timestamps)     ← Highest value, lowest risk - do first
    ↓
Phase 5 (Documentation)       ← No code changes, can parallel with Phase 1
    ↓
Phase 4 (TodoWrite Prompt)    ← Template change only
    ↓
Phase 3 (Session Gaps)        ← Medium complexity
    ↓
Phase 2 (Config Simplify)     ← Highest complexity, do last
    ↓
Phase 6 (Git Hooks)           ← Optional, do if time permits
```

---

## Concurrent Implementation Roadmap

This plan can be implemented alongside v4.0.0. Here's the recommended approach:

```
┌─────────────────────────────────────────────────────────────────────┐
│ MILESTONE A - Foundation (Parallel with v4.0.0 Phases 1-2)          │
├─────────────────────────────────────────────────────────────────────┤
│ v3.7.0 Phase 1: Auto-Timestamps                                     │
│   • Checkpoint 1.1-1.5                                              │
│   • Adds update_last_modified() to common-functions.sh              │
│                                                                     │
│ [v4.0.0 Phase 1-2 run in parallel - no conflicts]                   │
├─────────────────────────────────────────────────────────────────────┤
│ VERIFY: update_last_modified() works, /save updates dates           │
└─────────────────────────────────────────────────────────────────────┘
                                   ↓
┌─────────────────────────────────────────────────────────────────────┐
│ MILESTONE B - Core Features (Parallel with v4.0.0 Phases 4-12)      │
├─────────────────────────────────────────────────────────────────────┤
│ v3.7.0 Phases 2-6 (all remaining)                                   │
│   • Config simplification                                           │
│   • Session gaps                                                    │
│   • TodoWrite prompt                                                │
│   • Documentation clarity                                           │
│   • Git hooks (optional)                                            │
│                                                                     │
│ [v4.0.0 Phases 4-12 run in parallel - no conflicts]                 │
├─────────────────────────────────────────────────────────────────────┤
│ VERIFY: All v3.7.0 features work, all tests pass                    │
└─────────────────────────────────────────────────────────────────────┘
                                   ↓
┌─────────────────────────────────────────────────────────────────────┐
│ MILESTONE C - Release v3.7.0                                         │
├─────────────────────────────────────────────────────────────────────┤
│ • Update VERSION to 3.7.0                                           │
│ • Update CHANGELOG.md                                               │
│ • Run full test suite                                               │
│ • Test upgrade from v3.6.1                                          │
│ • Release                                                           │
├─────────────────────────────────────────────────────────────────────┤
│ VERIFY: Clean upgrade path from v3.6.1, all features work           │
└─────────────────────────────────────────────────────────────────────┘
                                   ↓
           [Continue to v4.0.0 Milestone D-E]
```

---

## Rollback Plan

Each phase is independently revertable:

- **Phase 1**: Remove `update_last_modified()` calls from commands
- **Phase 2**: Restore old config template, remove migration logic
- **Phase 3**: Remove gap detection calls
- **Phase 4**: Revert template changes
- **Phase 5**: Revert comment changes
- **Phase 6**: Delete hook template

---

## Open Questions (Awaiting Feedback)

1. **Config simplification scope**: Should we keep `project.urls` in config for tooling, or fully remove?
2. **Session gap threshold**: Warn on any gap, or only gaps > N sessions?
3. **Git hook default**: Should /init-context offer to install the hook?
4. **Timestamp format**: Standardize on one format, or continue supporting multiple?

---

## Changelog Draft

```markdown
## [3.7.0] - TBD

### Changed - Friction Reduction

**Auto-Timestamps**
- /save and /save-full now auto-update "Last Updated" dates
- No more manual date maintenance

**Simplified Configuration**
- .context-config.json now contains only preferences/settings
- Project URLs, tech stack, commands moved to markdown files
- Existing configs auto-migrated on update

**Session Validation**
- /save-full warns about session numbering gaps
- Non-blocking - informational only

**Documentation Clarity**
- CLAUDE.md and CONTEXT.md templates have clear role documentation
- File hierarchy explained in command-philosophy.md

**TodoWrite Integration**
- /save-full template includes TodoWrite capture section
- Explicit prompt to paste current TodoWrite state

### Added

- Optional git post-commit hook template for save reminders
- `update_last_modified()` helper function

### Fixed

- Manual timestamp maintenance friction
- .context-config.json becoming stale
- Unclear file role delineation
```

---

**Next Steps**: Await additional user feedback before beginning implementation.
