# Critical Upgrade Failure - Fix Plan

**Date:** 2025-10-22
**Severity:** CRITICAL - Production breaking
**Status:** In Progress

---

## Problem Summary

The v3.0.0 upgrade **completely destroys user systems** due to repository name mismatch:

- **Code references:** `ai-context-system` (new name)
- **Actual repository:** `claude-context-system` (not renamed yet)
- **Result:** All file downloads return 404 → Every system file replaced with "404: Not Found"

**Impact:** 100% upgrade failure rate, complete system destruction

---

## Root Causes

1. **Repository not renamed on GitHub** - Still `claude-context-system`
2. **No file validation** - Installer accepts 404 error pages as valid files
3. **No rollback on failure** - System left in destroyed state
4. **No HTTP status checking** - curl -sL accepts any response
5. **No VERSION file in repository** - Returns 404
6. **Interactive prompts** - Blocks AI/automated execution

---

## Immediate Fix Strategy

### Option A: Revert to Old Repository Name (FASTEST - RECOMMENDED)
**Time:** 30 minutes
**Risk:** Low

1. Change all references back to `claude-context-system`
2. Keep the rebrand story (it's still "AI Context System")
3. Repository rename can happen later with proper planning

**Files to fix:**
- install.sh (lines 22-24)
- All documentation URLs

### Option B: Complete the Rename (COMPLEX)
**Time:** 2-4 hours
**Risk:** High - affects all existing users

1. Rename GitHub repository
2. Test all URLs
3. Verify redirects work
4. Update all clones

**Not recommended right now** - too risky without testing

---

## Critical Fixes Required (MUST DO)

### 1. Fix Repository URLs
```bash
# install.sh - Change back to working repository
REPO_URL="https://github.com/rexkirshner/claude-context-system"
RAW_URL="https://raw.githubusercontent.com/rexkirshner/claude-context-system/main"
```

### 2. Create VERSION File
```bash
# In repository root
echo "3.0.0" > VERSION
git add VERSION
git commit -m "Add VERSION file for installer"
```

### 3. Add File Validation
```bash
validate_download() {
  local file="$1"

  # Check exists
  if [ ! -f "$file" ]; then
    return 1
  fi

  # Check size (404 errors are ~14 bytes)
  local size=$(wc -c < "$file" | tr -d ' ')
  if [ "$size" -lt 50 ]; then
    echo "❌ File too small: $file ($size bytes)"
    cat "$file"
    return 1
  fi

  # Check for 404 content
  if grep -q "404" "$file" || grep -q "Not Found" "$file"; then
    echo "❌ File contains 404 error: $file"
    return 1
  fi

  return 0
}
```

### 4. Add HTTP Status Checking
```bash
download_file() {
  local url="$1"
  local output="$2"

  # Download with HTTP status
  HTTP_CODE=$(curl -sL -w "%{http_code}" -o "$output" "$url")

  if [ "$HTTP_CODE" != "200" ]; then
    echo "❌ HTTP $HTTP_CODE: $url"
    rm -f "$output"
    return 1
  fi

  # Validate content
  if ! validate_download "$output"; then
    rm -f "$output"
    return 1
  fi

  return 0
}
```

### 5. Add Non-Interactive Mode
```bash
# Parse flags
NON_INTERACTIVE=false
if [[ "$1" == "--yes" ]] || [[ "$1" == "-y" ]]; then
  NON_INTERACTIVE=true
fi

# Use flag in prompt
if [ "$NON_INTERACTIVE" = true ]; then
  REPLY="y"
else
  read -p "Overwrite existing installation? [y/N] " -n 1 -r
  echo
fi
```

### 6. Add Rollback on Error
```bash
set -e  # Exit on error

trap 'rollback_on_error' ERR

rollback_on_error() {
  echo ""
  echo "❌ Installation failed"

  if [ -d "$BACKUP_DIR" ]; then
    echo "🔄 Restoring from backup..."
    cp -r "$BACKUP_DIR/.claude" . 2>/dev/null || true
    cp -r "$BACKUP_DIR/scripts" . 2>/dev/null || true
    echo "✅ System restored"
  fi

  exit 1
}
```

---

## Testing Required

### Pre-Release Testing
```bash
# 1. Create test project
mkdir /tmp/upgrade-test
cd /tmp/upgrade-test

# 2. Install v2.1.0 (from old system)
# ... initialize context

# 3. Run upgrade with --yes flag
/update-context-system

# 4. Verify NO 404s
for file in .claude/commands/*.md; do
  if grep -q "404" "$file"; then
    echo "FAIL: $file is 404"
    exit 1
  fi
done

# 5. Check file sizes
for file in .claude/commands/*.md; do
  size=$(wc -c < "$file")
  if [ "$size" -lt 100 ]; then
    echo "FAIL: $file too small ($size bytes)"
    exit 1
  fi
done

# 6. Try running commands
/save
/review-context
/validate-context

echo "✅ All tests passed"
```

---

## Implementation Order

1. ✅ **Fix repository URLs** (install.sh + all docs)
2. ✅ **Create VERSION file** (in repo root)
3. ✅ **Add file validation** (install.sh)
4. ✅ **Add HTTP status checking** (install.sh)
5. ✅ **Add non-interactive mode** (install.sh + update-context-system.md)
6. ✅ **Add rollback on error** (install.sh)
7. ✅ **Test end-to-end** (fresh install + upgrade)
8. ✅ **Update documentation** (fix command syntax)

---

## Timeline

- **Critical fixes:** 1-2 hours
- **Testing:** 30 minutes
- **Documentation:** 30 minutes
- **Total:** 2-3 hours

---

## Release Strategy

### DO NOT release v3.0.0 until:
- [ ] All 6 critical fixes implemented
- [ ] End-to-end upgrade tested successfully
- [ ] Fresh install tested successfully
- [ ] File validation confirmed working
- [ ] Rollback mechanism tested

### When ready:
1. Create v3.0.1 with all fixes
2. Test upgrade from v2.1.0 → v3.0.1
3. Update release notes with "Critical upgrade fix"
4. Notify any v3.0.0 early adopters

---

## Lessons Learned

1. **Never rebrand repository in code before GitHub**
2. **Always validate downloaded file contents**
3. **Test upgrade path before release**
4. **HTTP 200 doesn't mean valid content**
5. **Interactive prompts break automation**
6. **Command substitution syntax has compatibility issues**

---

**Status:** Implementing fixes now
