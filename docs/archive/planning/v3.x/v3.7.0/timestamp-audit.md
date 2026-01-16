# Timestamp Patterns Audit

**Created:** 2026-01-05
**Status:** COMPLETE

## Timestamp Patterns Found

All templates use a consistent pattern with minor variations:

| Pattern | Files | Notes |
|---------|-------|-------|
| `**Last Updated:** [Auto-updated]` | CODE_MAP.template.md, CONTEXT.template.md | Placeholder text |
| `**Last Updated:** [YYYY-MM-DD]` | PRD.template.md, KNOWN_ISSUES.template.md, next-steps.template.md | Date placeholder |
| `**Last Updated:** [Auto-updated by /save]` | STATUS.template.md | Explicit /save reference |
| `**Last Updated:** [Timestamp]` | legacy/QUICK_REF.template.md | Generic placeholder |

## Regex Pattern for Detection

The following regex matches all patterns:
```regex
\*\*Last Updated:\*\* .+
```

For replacement, we need to preserve the markdown bold formatting:
```regex
(\*\*Last Updated:\*\*) .+
```

Replace with: `$1 YYYY-MM-DD`

## Files Touched by Commands

### /save Command
- `context/STATUS.md` - Updates "Work In Progress" section including "Last Updated" field

### /save-full Command
- `context/STATUS.md` - Full update including Quick Reference
- `context/SESSIONS.md` - New session entry appended (no timestamp field)
- `context/DECISIONS.md` - If decisions made (has no Last Updated)
- `context/CONTEXT.md` - Currency check only (has Last Updated but not auto-updated)

## Implementation Recommendation

### Function: `update_last_modified()`

```bash
update_last_modified() {
  local file="$1"
  local today=$(date +%Y-%m-%d)

  # Check if file exists
  [ ! -f "$file" ] && return 1

  # Check if file has "Last Updated" pattern
  if grep -q '\*\*Last Updated:\*\*' "$file"; then
    # Platform-independent sed (macOS requires different syntax)
    if sed --version 2>&1 | grep -q GNU; then
      # GNU sed (Linux)
      sed -i "s/\*\*Last Updated:\*\* .*/\*\*Last Updated:\*\* $today/" "$file"
    else
      # BSD sed (macOS)
      sed -i '' "s/\*\*Last Updated:\*\* .*/\*\*Last Updated:\*\* $today/" "$file"
    fi
    return 0
  fi

  # No timestamp pattern found - that's OK, don't add one
  return 0
}
```

### Integration Points

1. **In /save (save.md)**
   - After updating STATUS.md content
   - Call: `update_last_modified "$CONTEXT_DIR/STATUS.md"`

2. **In /save-full (save-full.md)**
   - After updating STATUS.md: `update_last_modified "$CONTEXT_DIR/STATUS.md"`
   - After updating CONTEXT.md (if modified): `update_last_modified "$CONTEXT_DIR/CONTEXT.md"`
   - SESSIONS.md doesn't have Last Updated (session entries have their own dates)
   - DECISIONS.md doesn't have Last Updated (decisions have their own dates)

## Files Summary

| File | Has Last Updated | Auto-Update in /save | Auto-Update in /save-full |
|------|------------------|---------------------|---------------------------|
| STATUS.md | Yes | Yes | Yes |
| CONTEXT.md | Yes | No | If modified |
| SESSIONS.md | No (per-entry) | No | No |
| DECISIONS.md | No (per-entry) | No | No |
| CLAUDE.md | No | No | No |
