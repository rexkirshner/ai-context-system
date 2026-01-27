# /update-context

Update CLAUDE.md (and AGENTS.md) with permanent learnings from this session.

Run this before `/compact` or when context is getting long. It captures what was learned about the project so future sessions benefit.

**Supports both Claude Code and OpenAI Codex.**

## What to Extract

**Permanent learnings** — things true about the PROJECT:

| Type | Examples |
|------|----------|
| Commands | `npm run dev`, `pytest -x`, how to build/test/deploy |
| Constraints | "Don't modify X", "Always use Y pattern", "Keep Z under N lines" |
| Patterns | Conventions used in this codebase, architectural decisions |
| Quirks | Non-obvious things, "config is in weird place because...", gotchas |
| Preferences | User's stated preferences for how they like to work |

**Ignore ephemeral stuff** — things true about the MOMENT:

- What we're currently working on
- Temporary state ("tests are failing right now")
- This session's specific task
- Blockers that will be resolved

**The heuristic:** If it affects how future sessions should work, it's permanent. If it's about right now, it's ephemeral.

## File Structure

Use this structure for the context file:

```markdown
# [Project Name]

[One-line description]

## Commands

- Run: `[command]`
- Test: `[command]`
- Build: `[command]`

## Constraints

- [Constraint 1]
- [Constraint 2]

## Notes

- [Quirk or pattern worth knowing]
```

## Instructions

1. **Read** both CLAUDE.md and AGENTS.md (if they exist)

2. **Reflect** on this session:
   - What commands were used or discovered?
   - What constraints emerged? (things to do or avoid)
   - What patterns or conventions were followed?
   - What non-obvious things were learned about the codebase?
   - What preferences did the user express?

3. **Filter** — only keep permanent learnings, discard ephemeral stuff

4. **Update** the context files:
   - Add new learnings to appropriate sections
   - Update anything that's now outdated or wrong
   - Remove anything no longer relevant
   - Keep it concise — instructions, not documentation

5. **Mirror** CLAUDE.md ↔ AGENTS.md:
   - Both files should have identical content
   - If only one exists, create the other as a copy
   - If both exist but differ, merge them (combine unique content from each)

6. **Report** what changed:
   ```
   Updated context files:
   + Added: npm run test:watch command
   + Added: Constraint about not modifying legacy auth
   ~ Updated: Build command (was wrong)

   CLAUDE.md: [N] lines
   AGENTS.md: [N] lines (mirrored)
   ```

## Keep It Tight

Context files should be concise. Aim for:
- Under 50 lines for small projects
- Under 100 lines for complex projects

If it's growing too long, consolidate or remove less important items. This is an instruction file, not documentation.

## If Nothing to Update

```
No new permanent learnings to add. Context files unchanged.
```
