# /save-full Skill

Comprehensive session documentation for breaks and handoffs.

## Purpose

Create detailed session entry in SESSIONS.md. Enables perfect continuity for future AI or human sessions. Use before breaks, handoffs, or after significant work.

## Output

Session entry appended to `context/SESSIONS.md`:

```markdown
<!-- BEGIN SESSION [N] -->
## Session [N] | [YYYY-MM-DD] | [Focus Area]

### TL;DR
[50-300 chars summarizing what was accomplished]

### Accomplishments
- [Specific accomplishment with file reference]
- [Another accomplishment]

### Decisions
- **D[NNN]**: [Decision summary] (see DECISIONS.md)

### Files Changed
- [file paths modified this session]

### Mental Models
[Key insight about how the system works that future sessions should know]

### Next Steps
- [Actionable item starting with verb]
- [Another actionable item]

### Git
Commits: [N] | Branch: [name] | Pushed: [yes/no]
<!-- END SESSION [N] -->
```

## Execution

### 1. Determine Session Number

Read SESSIONS.md, find last `## Session N`, increment by 1.

### 2. Gather Information

| Field | Source |
|-------|--------|
| Focus | Primary topic/feature worked on this session |
| TL;DR | Summarize main accomplishments in 2-3 sentences |
| Accomplishments | Review session work, list with file references |
| Decisions | Any choices made with rationale (add to DECISIONS.md if significant) |
| Files Changed | `git diff --name-only` or track from session work |
| Mental Models | Key insights about architecture/patterns discovered |
| Next Steps | What should happen next session |
| Git info | Branch name, commit count, push status |

### 3. Write TL;DR

Requirements:
- 50-300 characters
- Past tense
- Captures essence of session

**Good:** `Implemented JWT validation middleware and integrated with Express routes. Added tests for token expiration and refresh flows.`

**Bad:** `Worked on auth stuff.` (too vague, no specifics)

### 4. Document Decisions

For significant decisions:
1. Assign ID: `D001`, `D002`, etc. (check existing IDs in DECISIONS.md)
2. Add full entry to DECISIONS.md with context, rationale, alternatives
3. Reference in session entry

### 5. Capture Mental Models

Document insights that help future sessions understand:
- How does this subsystem work?
- What patterns are used and why?
- Any non-obvious relationships?

### 6. Update Quick Reference

Also update STATUS.md Quick Reference block (same as /save).

### 7. Append Session Entry

Write entry with BEGIN/END markers. **Atomic write** - never leave partial entry.

### 8. Verify

| Check | Requirement |
|-------|-------------|
| Session number | Sequential (previous + 1) |
| TL;DR length | 50-300 characters |
| Markers | Has BEGIN/END SESSION markers |
| Accomplishments | At least one specific item |
| Next Steps | At least one actionable item |

## Output Summary

```
✓ Session [N] Saved

Focus: [area]
TL;DR: [preview...]

Accomplishments: [count]
Decisions: [count]
Next Steps: [count]

Git: [N] commits on [branch]
```

## Guardrails

- **DO NOT** leave session entry incomplete (use markers)
- **DO NOT** write vague TL;DR without specifics
- **DO** include file paths in accomplishments
- **DO** write Mental Models section - it's critical for AI continuity
- **DO** update STATUS.md Quick Reference too
