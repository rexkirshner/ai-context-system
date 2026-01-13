# /save-full

Comprehensive session documentation (10-15 minutes).

## Usage

```
/save-full
```

## Description

Creates a complete session entry in SESSIONS.md with mental model, accomplishments, and handoff notes. Use for session breaks or handoffs to another AI.

## What It Creates

Session entry with BEGIN/END markers containing:
- **Mental Model**: Current understanding of the codebase
- **What Was Done**: Summary of accomplishments
- **Key Decisions**: Decisions made during session
- **Next Steps**: What to work on next
- **Blockers**: Any issues preventing progress

## Session Entry Format

```markdown
<!-- BEGIN SESSION: 2026-01-13T10:00:00Z -->
## Session 2026-01-13

### Mental Model
[Understanding of the codebase and current task]

### What Was Done
- Implemented user authentication
- Added session management
- Created login/logout endpoints

### Key Decisions
- D023: Using JWT for authentication

### Next Steps
- Add password reset flow
- Implement rate limiting

### Blockers
None
<!-- END SESSION: 2026-01-13T12:00:00Z -->
```

## Verification

- Entry has BEGIN/END markers
- All required sections present
- Timestamps in ISO format
- Decision references valid

## Example

```bash
> /save-full

Documenting session...

Mental Model: Building user authentication system with JWT tokens...
What Was Done: 3 items documented
Key Decisions: 1 decision referenced (D023)
Next Steps: 2 items queued

Session entry added to SESSIONS.md.
```

## See Also

- [/save](save.md) - Quick status update
- [/export](export.md) - Create handoff package
