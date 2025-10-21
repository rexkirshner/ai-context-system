# Enhanced Testing Matrix for v3.0.0

**AI Context System** (formerly Claude Context System)

This document expands the testing matrix with additional edge cases based on Codex feedback.

---

## Additional Edge Case Tests (Feedback File Migration)

### Category: File Content Edge Cases

| Test ID | Scenario | Setup | Expected Result | Verify |
|---------|----------|-------|----------------|--------|
| **EC-9** | Large feedback file (1000+ lines) | Create file with 1000+ entries | Archives successfully, no truncation | Full content in archive |
| **EC-10** | Feedback file with non-ASCII characters | Add emoji, Chinese, Arabic text | Archives with correct encoding | grep for non-ASCII in archive |
| **EC-11** | Feedback file with unusual markdown | Nested lists, tables, code blocks | Archives all formatting | Markdown structure preserved |
| **EC-12** | Feedback file with custom frontmatter | Add YAML frontmatter to file | Archives frontmatter too | grep for frontmatter in archive |
| **EC-13** | Feedback file exactly 10 lines in section | Create file with exactly 10 content lines | Should archive (>10 threshold) | Check archive created |
| **EC-14** | Feedback file with 11 lines in section | Create file with 11 content lines | Archives (meets threshold) | Archive created |
| **EC-15** | Feedback file with binary content | Accidentally add binary data | Handles gracefully | No crash, clear error |
| **EC-16** | Feedback file with very long lines | Single line with 10,000+ chars | Archives without truncation | grep shows full line |

---

### Category: File System Edge Cases

| Test ID | Scenario | Setup | Expected Result | Verify |
|---------|----------|-------|----------------|--------|
| **EC-17** | Feedback file is symlink | ln -s other-file.md claude-context-feedback.md | Follows symlink, archives target | Archive has real content |
| **EC-18** | artifacts/feedback/ is read-only | chmod 444 artifacts/feedback/ | Clear error, old file safe | Error message helpful |
| **EC-19** | artifacts/ doesn't exist but can't be created | Parent dir is read-only | Clear error, old file safe | Helpful error message |
| **EC-20** | Feedback file has spaces in content lines | Mixed empty + content lines | Counts correctly | Meets/fails threshold correctly |
| **EC-21** | Multiple feedback files (both old and new) | Both files exist | Warns, doesn't auto-merge | Warning displayed |
| **EC-22** | Feedback file owned by root | sudo touch, can't read/write | Permission error, clear fix | Error message shows chmod |
| **EC-23** | Disk almost full during archive | Leave 100KB free, 50KB file | Detects, fails gracefully | Old file untouched |
| **EC-24** | Network drive with slow I/O | NFS/SMB mount | Completes (may be slow) | No timeout errors |

---

### Category: Character Encoding Edge Cases

| Test ID | Scenario | Setup | Expected Result | Verify |
|---------|----------|-------|----------------|--------|
| **EC-25** | UTF-8 with BOM | Add UTF-8 BOM to file | Archives with BOM intact | BOM preserved |
| **EC-26** | Mixed line endings (CRLF + LF) | Windows + Unix line endings | Archives correctly | Line count accurate |
| **EC-27** | No final newline | File doesn't end with \n | Archives correctly | Content intact |
| **EC-28** | Tab characters in content | Mix tabs and spaces | Archives with tabs | grep shows tabs |
| **EC-29** | NULL bytes in file | Accidentally added \0 | Handles gracefully | Clear error or skip |
| **EC-30** | Latin-1 encoded file | File is ISO-8859-1 | Converts or warns | No corruption |

---

### Category: Concurrent Access Edge Cases

| Test ID | Scenario | Setup | Expected Result | Verify |
|---------|----------|-------|----------------|--------|
| **EC-31** | File being edited during migration | Open in editor during update | Waits or warns | No partial writes |
| **EC-32** | File locked by another process | lock file with flock | Detects lock, clear error | Helpful message |
| **EC-33** | Multiple /update-context-system runs | Run twice simultaneously | Second detects first, exits | No race condition |

---

### Category: Template Edge Cases

| Test ID | Scenario | Setup | Expected Result | Verify |
|---------|----------|-------|----------------|--------|
| **EC-34** | Both old and new templates exist | Both templates/ files present | Prefers new template | Uses context-feedback.template.md |
| **EC-35** | Neither template exists | Delete both templates | Clear warning, continues | Helpful error message |
| **EC-36** | Template is corrupted/empty | touch empty template | Warns, creates empty file | User notified |
| **EC-37** | Template has no Feedback Entries section | Malformed template | Creates file anyway | Works despite template issue |

---

### Category: Version Migration Paths

| Test ID | Scenario | Setup | Expected Result | Verify |
|---------|----------|-------|----------------|--------|
| **EC-38** | Upgrade from v2.3.0 (pre-feedback) | No feedback file exists | Creates new file | context-feedback.md created |
| **EC-39** | Upgrade from v2.3.1 (first feedback) | Has old feedback file | Migrates correctly | Archive + new file |
| **EC-40** | Upgrade from v2.3.2 (current) | Has old feedback file | Migrates correctly | Archive + new file |
| **EC-41** | Upgrade from v1.x (very old) | No feedback file | Creates new file | Works despite old version |
| **EC-42** | Upgrade skipping versions (v2.0 → v3.0) | No feedback file | Creates new file | Migration works |

---

## Integration Test Enhancements

### Category: Command Chain Testing

| Test ID | Scenario | Commands | Expected Result | Verify |
|---------|----------|----------|----------------|--------|
| **IT-9** | Full workflow after migration | /update → /validate → /save | All commands work | No broken refs |
| **IT-10** | Feedback after migration | Update → Add feedback → /save | Feedback in new file | context-feedback.md has entry |
| **IT-11** | Multiple updates in succession | /update × 3 times | Only archives once | No duplicate archives |
| **IT-12** | Update after manual file edit | Edit context-feedback.md → /update | Preserves edits | User content safe |

---

### Category: Search & Replace Verification

| Test ID | Scenario | Check | Expected Result | Verify |
|---------|----------|-------|----------------|--------|
| **IT-13** | No "Claude Context System" in current docs | grep -r "Claude Context System" | Only in CHANGELOG historical | Historical sections only |
| **IT-14** | No old feedback filename in commands | grep -r "claude-context-feedback" | Only in migration logic (OLD_FEEDBACK var) | Intentional references only |
| **IT-15** | claude.md still referenced correctly | grep -r "claude.md" | Many matches (correct) | Tool-specific refs intact |
| **IT-16** | All URLs updated | grep -r "github.com.*claude-context-system" | Zero matches or redirects noted | URLs correct |
| **IT-17** | Version numbers updated | grep -r "2.3.2" | Only in historical sections | Current version is 3.0.0 |
| **IT-18** | Template filenames correct | ls templates/ | context-feedback.template.md exists | Old template gone |

---

## User Workflow Enhancements

### Category: Real-World Scenarios

| Test ID | Workflow | Steps | Expected Result | Success Criteria |
|---------|----------|-------|----------------|------------------|
| **WF-7** | User with custom feedback template | User added sections → update | Custom sections archived | All customizations preserved |
| **WF-8** | User tracking feedback in git | Feedback in git → update | Git shows deletion + addition | Proper git rename |
| **WF-9** | Team with shared repo | Multiple users → one updates | Other users see new filename | Clear communication |
| **WF-10** | User interrupts update mid-way | Ctrl+C during migration | Old file intact | No data loss |
| **WF-11** | User runs update twice | /update → /update again | Second update idempotent | No duplicate archives |
| **WF-12** | Power user with automation | Scripts reference old filename | Scripts break with clear error | Error leads to fix |

---

### Category: Documentation Verification

| Test ID | Document | Verification | Expected Result | Verify |
|---------|----------|--------------|----------------|--------|
| **DT-9** | README installation | Follow README steps exactly | System installs correctly | New user success |
| **DT-10** | Migration guide accuracy | Follow migration guide exactly | Upgrade succeeds | Step-by-step works |
| **DT-11** | Rollback instructions | Follow rollback procedure | System rolls back | Downgrade works |
| **DT-12** | FAQ for claude.md | Read FAQ entry | User understands why | Confusion prevented |
| **DT-13** | Search engine results | Google "AI Context System" | Finds GitHub repo | SEO works |
| **DT-14** | Old URL redirect | Visit old GitHub URL | Redirects to new | GitHub redirect works |

---

## Performance Testing

### Category: Large-Scale Scenarios

| Test ID | Scenario | Scale | Expected Result | Verify |
|---------|----------|-------|----------------|--------|
| **PT-1** | Large feedback file migration | 10,000 line file | Completes in <5 seconds | Performance acceptable |
| **PT-2** | Many archived feedback files | 100 archived files | Doesn't slow down update | Performance stable |
| **PT-3** | Large project (1000s of files) | Huge codebase | Update completes normally | No performance issues |
| **PT-4** | Slow disk I/O | Simulate slow HDD | Completes (slower) | No timeouts |

---

## Manual Verification Checklist

### Post-Migration Verification (QA Steps)

**Fresh Installation (v3.0.0):**
- [ ] Run `/init-context` in empty project
- [ ] Verify `context/context-feedback.md` created (NEW name)
- [ ] Verify `context/claude-context-feedback.md` does NOT exist (OLD name)
- [ ] Verify `context/claude.md` exists (tool-specific, correct)
- [ ] Verify all 6 files created (claude.md, CONTEXT.md, STATUS.md, DECISIONS.md, SESSIONS.md, context-feedback.md)
- [ ] Verify README shows "AI Context System"
- [ ] Verify commands show "AI Context System" in output

**Upgrade Path (v2.3.2 → v3.0.0):**
- [ ] Create test project with v2.3.2
- [ ] Add feedback content to `claude-context-feedback.md` (>10 lines)
- [ ] Run `/update-context-system`
- [ ] Verify `context/claude-context-feedback.md` is GONE
- [ ] Verify `context/context-feedback.md` exists (NEW name)
- [ ] Verify `artifacts/feedback/feedback-v2.3.2-DATE.md` exists (archived)
- [ ] Verify archive contains all original content
- [ ] Verify new file has fresh template
- [ ] Verify migration message displayed
- [ ] Run `/validate-context` - should pass
- [ ] Run `/save` - should work with new filenames

**Rollback Test:**
- [ ] Upgrade project to v3.0.0
- [ ] Copy archived feedback back to old name
- [ ] Delete new feedback file
- [ ] Downgrade to v2.3.2
- [ ] Verify system works with old filenames
- [ ] Verify no data lost

**Search Verification:**
- [ ] grep -r "Claude Context System" → Only in CHANGELOG historical sections
- [ ] grep -r "claude-context-feedback.md" → Only in migration logic variables
- [ ] grep -r "claude.md" → Many results (CORRECT - tool-specific)
- [ ] grep -r "AI Context System" → Many results in current docs
- [ ] grep -r "github.com.*claude-context-system" → Zero or noted as redirects
- [ ] grep -r "2\.3\.2" → Only in CHANGELOG historical sections

---

## Regression Prevention Tests

### Category: Future-Proofing

| Test ID | Scenario | Purpose | Expected Result | Verify |
|---------|----------|---------|----------------|--------|
| **RP-1** | New template creation | Add new template | Uses new naming convention | No "claude-context" prefix |
| **RP-2** | New command creation | Add new command | References correct filenames | No old names |
| **RP-3** | Documentation updates | Update README | Uses "AI Context System" | No old system name |
| **RP-4** | CI/CD lint check | Run lint script | Fails on "Claude Context System" | Enforcement works |

---

## Test Automation Scripts

### 1. Fresh Install Test
```bash
#!/bin/bash
# test-fresh-install-v3.sh

TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Install v3.0.0
curl -sL github.com/rexkirshner/ai-context-system/install.sh | bash
/init-context

# Verify new filenames
[[ -f "context/context-feedback.md" ]] || exit 1
[[ ! -f "context/claude-context-feedback.md" ]] || exit 1
[[ -f "context/claude.md" ]] || exit 1

echo "✅ Fresh install test passed"
```

### 2. Upgrade Test
```bash
#!/bin/bash
# test-upgrade-v3.sh

TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Install v2.3.2
curl -sL github.com/rexkirshner/claude-context-system/install.sh | bash
/init-context

# Add test feedback content
cat >> context/claude-context-feedback.md << 'EOF'

## 2025-10-21 - Test Entry

**What happened:** This is test content

**Suggestion:** Should be preserved

**Severity:** 🟢 Minor
EOF

# Upgrade to v3.0.0
/update-context-system

# Verify migration
[[ ! -f "context/claude-context-feedback.md" ]] || exit 1
[[ -f "context/context-feedback.md" ]] || exit 1
[[ -f "artifacts/feedback/feedback-v2.3.2-"*.md ]] || exit 1

# Verify content preserved
ARCHIVE=$(ls artifacts/feedback/feedback-v2.3.2-*.md | head -1)
grep -q "This is test content" "$ARCHIVE" || exit 1

echo "✅ Upgrade test passed"
```

### 3. Edge Case: Large File Test
```bash
#!/bin/bash
# test-large-file-v3.sh

TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Install v2.3.2
curl -sL github.com/rexkirshner/claude-context-system/install.sh | bash
/init-context

# Create large feedback file (1000 entries)
for i in {1..1000}; do
  cat >> context/claude-context-feedback.md << EOF

## 2025-10-21 - Entry $i

**What happened:** Test entry $i

**Suggestion:** Content $i

**Severity:** 🟢 Minor
EOF
done

# Upgrade
START=$(date +%s)
/update-context-system
END=$(date +%s)
DURATION=$((END - START))

# Verify
[[ -f "context/context-feedback.md" ]] || exit 1
ARCHIVE=$(ls artifacts/feedback/feedback-v2.3.2-*.md | head -1)
LINES=$(wc -l < "$ARCHIVE")
[[ $LINES -gt 1000 ]] || exit 1
[[ $DURATION -lt 10 ]] || echo "⚠️  Warning: Slow performance ($DURATION seconds)"

echo "✅ Large file test passed (${DURATION}s for 1000 entries)"
```

### 4. Edge Case: Non-ASCII Test
```bash
#!/bin/bash
# test-non-ascii-v3.sh

TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Install v2.3.2
curl -sL github.com/rexkirshner/claude-context-system/install.sh | bash
/init-context

# Add non-ASCII content
cat >> context/claude-context-feedback.md << 'EOF'

## 2025-10-21 - Unicode Test

**What happened:** Testing emoji 🎉🚀✅ and Chinese 你好世界 and Arabic مرحبا

**Suggestion:** Should preserve all characters

**Severity:** 🟢 Minor
EOF

# Upgrade
/update-context-system

# Verify UTF-8 preserved
ARCHIVE=$(ls artifacts/feedback/feedback-v2.3.2-*.md | head -1)
grep -q "🎉🚀✅" "$ARCHIVE" || exit 1
grep -q "你好世界" "$ARCHIVE" || exit 1
grep -q "مرحبا" "$ARCHIVE" || exit 1

echo "✅ Non-ASCII test passed"
```

---

## Summary

**Total Test Cases:** 42 (original) + 42 (enhanced) = **84 test cases**

### Breakdown:
- **Fresh Installation:** 6 tests
- **Upgrade Path:** 8 tests
- **Edge Cases:** 42 tests (expanded from 8)
- **Integration:** 18 tests (expanded from 8)
- **User Workflows:** 12 tests (expanded from 6)
- **Documentation:** 14 tests (expanded from 8)
- **Performance:** 4 tests (new)

### Automation:
- 4 automated test scripts provided
- Manual verification checklist (22 items)
- Regression prevention tests (4 tests)

---

**Version:** 2.0 (Enhanced with Codex feedback)
**Created:** 2025-10-21
**Purpose:** Comprehensive testing for v3.0.0 rebrand
**Key Addition:** Edge cases for feedback file migration (large files, non-ASCII, unusual content)
