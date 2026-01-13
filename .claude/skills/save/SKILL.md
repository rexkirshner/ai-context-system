# /save Skill

Quick session save - updates current state only.

## Purpose

Minimal overhead status update at end of work sessions. Updates STATUS.md with current tasks and refreshes the Quick Reference block. Does NOT create a full session entry in SESSIONS.md (use /save-full for that).

## Time Estimate

2-3 minutes.

## When to Use

- End of most work sessions
- Quick state capture before switching tasks
- When you don't need full session documentation

Use `/save-full` instead when:
- Before taking a break
- Before AI handoff
- After completing a significant feature
- When decisions need documenting

## Output

Only `context/STATUS.md` is modified:
1. Quick Reference block updated with current state
2. Current tasks/blockers/next steps refreshed

## Execution Steps

### Step 1: Verify Context Exists

```bash
if [ ! -f "context/STATUS.md" ]; then
  echo "Error: context/STATUS.md not found"
  echo "Run /init to initialize context"
  exit 1
fi
```

### Step 2: Gather Current State

Collect information for Quick Reference:

```bash
# Get project name from config
PROJECT_NAME=$(jq -r '.project.name // "Unknown"' context/.context-config.json 2>/dev/null)

# Get current phase from STATUS.md
CURRENT_PHASE=$(grep -oE 'Phase:? [A-Za-z0-9]+' context/STATUS.md | head -1 | cut -d: -f2 | xargs || echo "Development")

# Get current focus from STATUS.md or active work
CURRENT_FOCUS=$(grep -A1 '## Current Focus\|## Focus' context/STATUS.md | tail -1 | head -c 50 || echo "Active development")
```

### Step 3: Determine Resume Point

Extract or generate resume point:

```bash
# Get first next step from STATUS.md
RESUME_POINT=$(grep -A5 '## Next Steps\|### Next' context/STATUS.md | grep -E '^\s*-' | head -1 | sed 's/^[- ]*//')

# Validate format (must start with verb)
VALID_VERBS="Add|Build|Complete|Configure|Continue|Create|Debug|Delete|Deploy|Document|Enhance|Extend|Extract|Finish|Fix|Implement|Improve|Integrate|Investigate|Migrate|Move|Optimize|Refactor|Remove|Rename|Replace|Research|Resolve|Review|Rewrite|Set up|Simplify|Test|Update|Upgrade|Validate|Verify|Wire up|Write"

if ! echo "$RESUME_POINT" | grep -qE "^($VALID_VERBS)"; then
  RESUME_POINT="Continue current work in context/STATUS.md"
fi

# Ensure location reference
if ! echo "$RESUME_POINT" | grep -qE ' (in|at|for|to) '; then
  RESUME_POINT="$RESUME_POINT in context/STATUS.md"
fi
```

### Step 4: Update Quick Reference Block

Replace the AUTO block in STATUS.md:

```markdown
<!-- BEGIN AUTO:QUICK_REFERENCE -->
**Project:** [project-name] | **Phase:** [phase] | **Health:** --/100
**Focus:** [current-focus]
**Resume:** [resume-point]
<!-- END AUTO:QUICK_REFERENCE -->
```

**Implementation:**
1. Read STATUS.md
2. Find `<!-- BEGIN AUTO:QUICK_REFERENCE -->` and `<!-- END AUTO:QUICK_REFERENCE -->` markers
3. Replace content between markers with updated Quick Reference
4. Write back to STATUS.md

### Step 5: Update Current State Sections

Review and update these sections in STATUS.md if needed:

- **Current Phase** - Update if phase changed
- **Active Tasks** - Mark completed items, add new ones
- **Blockers** - Update or clear resolved blockers
- **Next Steps** - Ensure at least one actionable item

**Note:** Only update sections that have actually changed. Don't add placeholder content.

### Step 6: Verify Output

```bash
# Ensure only STATUS.md was modified
CHANGED_FILES=$(git diff --name-only 2>/dev/null || echo "")

if [ -n "$CHANGED_FILES" ]; then
  if echo "$CHANGED_FILES" | grep -qv "^context/STATUS.md$"; then
    echo "Warning: Files other than STATUS.md were modified"
    echo "$CHANGED_FILES"
  fi
fi

# Verify Quick Reference block exists
if grep -q "BEGIN AUTO:QUICK_REFERENCE" context/STATUS.md; then
  echo "✓ Quick Reference updated"
else
  echo "✗ Quick Reference block missing"
fi
```

### Step 7: Output Summary

```
✓ Status saved

Quick Reference:
  Project: [name]
  Phase: [phase]
  Focus: [focus]
  Resume: [resume-point]

Modified: context/STATUS.md only

Next session: Run /review for health score
```

## Verification Criteria

| Check | Requirement |
|-------|-------------|
| Files modified | Only `context/STATUS.md` |
| Quick Reference | Has BEGIN/END AUTO markers |
| Resume point | Starts with allowed verb, has location |

## Difference from /save-full

| Aspect | /save | /save-full |
|--------|-------|------------|
| Time | 2-3 min | 10-15 min |
| Modifies | STATUS.md only | STATUS.md + SESSIONS.md |
| Creates session entry | No | Yes |
| Documents decisions | No | Yes |
| Mental models | No | Yes |
| Use frequency | ~17/20 sessions | ~3/20 sessions |

## Error Handling

- If STATUS.md doesn't exist, error with instruction to run /init
- If Quick Reference markers missing, add them
- If config missing, use sensible defaults
- Never fail silently - always show what was updated

## Notes

- This skill replaces v4.x `/save` command
- Minimal overhead design - most sessions end with this
- Quick Reference is the only derived content updated
- User should run /save-full periodically for full documentation
