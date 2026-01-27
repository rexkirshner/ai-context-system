# /save-session

Save a record of what happened during this context window.

Run this before `/compact` or when context is getting long. Creates a session log for later review.

## Output Location

`docs/sessions/SESSION-[NUMBER].md`

## What to Capture

Reflect on the entire conversation and record:

### Summary
- 2-3 sentence overview of what this session was about

### What Was Accomplished
- Tasks completed
- Features implemented
- Bugs fixed
- Problems solved

### Files Changed
- List of files created, modified, or deleted
- Brief note on what changed in each

### Commits Made
- List commits created during this session (if any)
- Include commit messages

### Decisions Made
- Any significant decisions with brief rationale
- Technical choices, architecture decisions, approach changes

### Key Discussions
- Notable exchanges or insights worth remembering
- Questions asked and answers given
- User preferences expressed

### Unfinished Work
- What was started but not completed
- What was planned but not started
- Blockers encountered

### Notes for Next Session
- Context that would help someone picking this up
- Where to look, what to watch out for

## Output Format

```markdown
# Session [NUMBER]

**Date:** YYYY-MM-DD
**Duration:** [rough estimate if known]

## Summary

[2-3 sentences]

## Accomplished

- [Task/feature/fix]
- [Task/feature/fix]

## Files Changed

| File | Change |
|------|--------|
| `path/to/file.ts` | [what changed] |

## Commits

- `abc1234` - [commit message]
- `def5678` - [commit message]

## Decisions

### [Decision Title]
**Choice:** [what was decided]
**Why:** [brief rationale]

## Key Discussions

- [Notable point or insight]

## Unfinished

- [ ] [Task not completed]
- [ ] [Task not started]

## Next Session

[Context for whoever picks this up]
```

## Instructions

1. **Determine** the next session number (check `docs/sessions/` for existing sessions)
2. **Create** `docs/sessions/` directory if it doesn't exist
3. **Reflect** on the entire conversation
4. **Write** the session record to `docs/sessions/SESSION-[NUMBER].md`
5. **Confirm** to user: "Session saved to docs/sessions/SESSION-[NUMBER].md"

## Tips

- Be thorough but concise
- Focus on what would be useful for the user to review later
- Include enough context that someone could pick up where this left off
- Don't just list files - explain what was done to them
