# /update-context

Update CLAUDE.md and AGENTS.md with permanent learnings from this session.

Run before `/compact` or when context is long.

## Extract (permanent)

Things true about the PROJECT:
- **Commands** — how to run, test, build, deploy
- **Constraints** — "don't modify X", "always use Y"
- **Patterns** — conventions, architecture decisions
- **Quirks** — non-obvious gotchas
- **Preferences** — how the user likes to work

## Ignore (ephemeral)

Things true about the MOMENT:
- Current task, temporary state, session-specific blockers

**Heuristic:** Affects future sessions → permanent. About right now → ephemeral.

## Do

1. Read CLAUDE.md and AGENTS.md (if they exist)
2. Reflect: what was learned about this project?
3. Update both files:
   - Add new learnings
   - Update outdated info
   - Remove stale items
4. Mirror: keep CLAUDE.md and AGENTS.md identical
   - If only one exists, create the other
   - If both exist but differ, merge them
5. Report what changed

## File Structure

```markdown
# [Project Name]

[One-line description]

## Commands
- Run: `...`
- Test: `...`
- Build: `...`

## Constraints
- [Constraint]

## Notes
- [Quirk or pattern]
```

**Keep it tight:** Under 50 lines for small projects, under 100 for complex. Instructions, not documentation.

If nothing new: "No new learnings. Context files unchanged."
