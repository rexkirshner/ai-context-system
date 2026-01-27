# /save-session

Record what happened this context window. Output: `docs/sessions/SESSION-[N].md`

Run before `/compact` or when context is long.

## Do

1. Reflect on the entire conversation
2. Find next session number from `docs/sessions/`
3. Create directory if needed
4. Write `docs/sessions/SESSION-[N].md`
5. Confirm to user

## Output Format

```markdown
# Session N

**Date:** YYYY-MM-DD

## Summary
[2-3 sentences: what was this session about]

## Accomplished
- [What got done]

## Files Changed
| File | Change |
|------|--------|
| `path` | [what changed] |

## Commits
- `sha` - message

## Decisions
**[Topic]:** [choice] — [why]

## Unfinished
- [ ] [What's left to do]

## Next Session
[Context for whoever picks this up]
```

**Guidance:** Thorough but concise. Focus on what's useful to review later. Enough context to pick up where this left off.
