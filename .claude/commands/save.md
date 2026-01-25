---
name: save
description: End of session - updates STATUS.md and optionally DECISIONS.md
---

# /save

Update context at end of session.

## Prerequisites

Verify these files exist:
- `context/STATUS.md`
- `context/DECISIONS.md`

If missing, suggest running `/init-context` first.

## What to Update

### context/STATUS.md

Update all fields while preserving the exact format:

```markdown
# Status

SchemaVersion: 1
LastUpdated: [today's date YYYY-MM-DD]
HeadCommit: [run: git rev-parse --short HEAD, or keep existing value if not a git repo]
Objective: [current goal - update if changed during session]

## Working Set

- [3-7 files/directories being touched]
- [Add any new paths worked on this session]
- [Remove paths no longer relevant]

## Next Actions

- [Concrete next steps based on session progress]
- [What should the next session pick up?]

## Blocked On

- [Any blockers, or "(None)" if clear]
```

**Field guidance:**
- **LastUpdated**: Always today's date
- **HeadCommit**: Current git SHA (run `git rev-parse --short HEAD`); if not a git repo, keep existing value
- **Objective**: Update if focus shifted during session
- **Working Set**: 3-7 items, reflect what was actually touched
- **Next Actions**: Actionable items for next session
- **Blocked On**: External dependencies, questions, or "(None)"

### context/DECISIONS.md (if applicable)

Ask: "Any decisions worth recording from this session?"

If yes, append a new entry:

```markdown
---

## YYYY-MM-DD: [Area] Decision Title
Why: [reason for the decision]
Tradeoff: [what we gave up or risk we accepted]
RevisitWhen: [trigger condition to reconsider]
```

Replace `YYYY-MM-DD` with today's actual date (e.g., 2026-01-24).

**Area prefixes** (for grep-ability—choose the most relevant area):
- [DB], [API], [UI], [Auth], [Infra], [Deps], [Arch], [Test], [Perf], etc.
- Use the area most affected by the decision, or [Arch] for cross-cutting choices

**Only record decisions that:**
- Affect future development choices
- Have meaningful tradeoffs
- Someone might ask "why did we do it this way?"

## Behavior

1. Read current STATUS.md
2. Update all fields based on session work
3. Write updated STATUS.md (preserve exact format)
4. Ask about decisions
5. If decision to record, append to DECISIONS.md
6. Report what was updated

## Done

Report:
- "Updated STATUS.md" with summary of changes
- "Added decision: [title]" if applicable, or "No new decisions"
