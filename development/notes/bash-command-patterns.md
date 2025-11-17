# Bash Command Patterns for Claude Code Compatibility

**Created**: 2025-11-16
**Issue**: Multi-line bash if-then-else blocks cause parsing errors in Claude Code's Bash tool

---

## Problem

When command templates (`.claude/commands/*.md`) contain multi-line bash if-then-else blocks that Claude is supposed to execute using the Bash tool, they fail with parsing errors like:

```
Error: parse error near 'then'
Error: parse error near '&&'
```

### Root Cause

The Bash tool doesn't handle multi-line conditional blocks well when passed as single command strings. Newlines and if-then-else syntax cause parsing failures.

### Example of Problematic Pattern

❌ **DON'T DO THIS:**
```bash
if git rev-parse --git-dir > /dev/null 2>&1; then
  GIT_STATUS=$(git status --short 2>/dev/null || echo "No changes")
  GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

  # Count changes
  NEW_FILES=$(echo "$GIT_STATUS" | grep "^??" | wc -l | tr -d ' ')
  MODIFIED_FILES=$(echo "$GIT_STATUS" | grep "^ M\|^M " | wc -l | tr -d ' ')

  echo "✅ Git repository detected"
  echo "Branch: $GIT_BRANCH"
  echo "New: $NEW_FILES | Modified: $MODIFIED_FILES"
else
  echo "⏭️  Not a git repository (skipping git data)"
fi
```

---

## Solution Patterns

### Pattern 1: Sequential Commands with && ||

✅ **DO THIS INSTEAD:**
```bash
# Check if git repository
git rev-parse --git-dir > /dev/null 2>&1 && echo "Git repository detected" || echo "Not a git repository"
```

```bash
# Get git info (safe - fails gracefully if not a git repo)
git branch --show-current
```

```bash
git status --short
```

```bash
git log --oneline -5
```

**Advantages:**
- Simple, single-line commands
- Built-in error handling with `|| operator`
- Easy for Claude to execute sequentially
- Each command is atomic

### Pattern 2: Helper Scripts

For complex logic, move to helper scripts instead of inline bash:

✅ **DO THIS:**
```bash
# Call helper script that contains the complex logic
./scripts/git-status-summary.sh
```

Then create `scripts/git-status-summary.sh` with the complex if-then-else logic.

**Advantages:**
- Complex logic in proper shell script
- Testable independently
- Reusable across commands

### Pattern 3: Multiple Simple Checks

Instead of nested if-then-else, use multiple simple checks:

✅ **DO THIS:**
```bash
# Check 1: Does file exist?
test -f "scripts/common-functions.sh" && echo "Found" || echo "Not found"
```

```bash
# Check 2: If found, source it (but continue either way)
test -f "scripts/common-functions.sh" && source scripts/common-functions.sh || true
```

---

## When These Patterns Apply

### ✅ Use Simple Patterns When:

1. Bash code is in command template (`.claude/commands/*.md`)
2. Code is meant to be executed by Claude using the Bash tool
3. Code is shown in executable code blocks that Claude will run step-by-step

### ❌ Complex Patterns OK When:

1. Creating a standalone shell script (e.g., in `scripts/*.sh`)
2. Documentation/examples (not meant to be executed directly)
3. Code that users will run manually (not Claude)

---

## Commands Fixed (v3.3.1)

- ✅ `/save` - Replaced multi-line git status extraction with sequential commands
- ✅ `/save-full` - Replaced all if-then-else blocks with simple sequential commands

## Commands Still Using Complex Patterns

The following commands contain if-then-else blocks but may be OK if they're creating scripts rather than executing directly:

- `/init-context` - Contains ~20 if-then blocks (needs review)
- `/update-context-system` - Contains ~4 if-then blocks (needs review)
- `/add-ai-header` - Contains if-then blocks (needs review)
- `/organize-docs` - Contains if-then blocks (needs review)
- `/review-context` - Contains if-then blocks (needs review)
- `/validate-context` - Contains if-then blocks (needs review)

**TODO**: Audit these commands to determine if the bash blocks are meant to be executed by Claude or if they're script templates.

---

## Testing Checklist

When creating or modifying command templates:

1. ✅ Are bash code blocks meant for Claude to execute?
2. ✅ Do they avoid multi-line if-then-else?
3. ✅ Do they use `&&` `||` for conditional logic?
4. ✅ Are complex operations moved to helper scripts?
5. ✅ Does each command fail gracefully (with `|| echo "fallback"` or `2>/dev/null || true`)?

---

## References

- **Issue reported**: User testing /save in real project (2025-11-16)
- **Fixed in commit**: `edfc4e1` - "fix(commands): Replace multi-line bash if-then-else with simple sequential commands"
- **Related files**: `.claude/commands/save.md`, `.claude/commands/save-full.md`
