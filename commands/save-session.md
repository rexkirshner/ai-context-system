# /save-session

Record what happened this context window. Output: `docs/sessions/SESSION-NNN.md`

Run before `/compact` or when context is long.

## Do

1. Reflect on the full conversation (what was attempted, succeeded, failed)
2. Determine next session number:
   - List existing `docs/sessions/SESSION-*.md` (create dir if missing)
   - Extract highest N; next = N+1
   - If none exist, start at 1
   - If computed filename exists (collision), increment until free
   - Use zero-padded 3-digit format: `SESSION-001.md`
3. Collect verified repo state:
   - `git branch --show-current`
   - `git status` (clean/dirty)
   - `git diff --name-status` (files changed)
   - `git log --oneline -n 5` (recent commits)
   - If git unavailable or can't verify, write "Unknown" (don't guess)
4. Write `docs/sessions/SESSION-NNN.md` using format below
5. Reply to user with:
   - File path created
   - Session number
   - Note if git info couldn't be verified

## Hard Rules

- **Verify from git.** Commits and Files Changed must come from actual git commands. If unverifiable, write "Unknown" — never guess.
- **No secrets.** Never include tokens, keys, private URLs, credentials, or PII. Reference generically ("API key", "prod DB") without values.
- **Stay concise.** Follow the caps below. Scannable > thorough.

## Output Format

```markdown
# Session NNN

**Date:** YYYY-MM-DD

## Summary
[2-3 sentences: what this session was about and the outcome]

## Accomplished
- [bullet]
```
Max 5-7 bullets. Concrete outcomes only.

```markdown
## Repo State
- **Branch:** <name or Unknown>
- **Working tree:** <clean/dirty/Unknown>
- **Notes:** <optional: failing tests, build status if known>

## Files Changed
| File | Status |
|------|--------|
| `path` | added/modified/deleted — what changed |
```
From `git diff --name-status` or `git status`. If unverifiable: "Unable to verify — no git or uncommitted state unknown."

```markdown
## Commits
- `sha` — message
```
From `git log`. If none this session or unverifiable: "None this session" or "Unable to verify."

```markdown
## Decisions
- **[Topic]:** [decision] — [why]
```
Max 5 items. Include tradeoff if relevant.

```markdown
## Key Discussions
- [Notable insight, user preference, or important exchange]
```
Max 5 items. Skip if nothing notable.

```markdown
## Unfinished
- [ ] [Actionable task]
```
Max 5-10 items. Phrased as tasks someone can pick up.

```markdown
## Next Session
[What to do next, in order. Include specific commands/paths to pick up quickly. 5-10 lines max.]
```

## Guidance

- Be factual and skimmable
- Prefer specifics (file paths, function names) over vague descriptions
- If a section would be empty, omit it (except Summary, which is required)
