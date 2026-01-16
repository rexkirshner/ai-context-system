# /export

Export context for handoff to another AI or archival.

## Usage

```
/export
```

## Description

Creates a complete handoff package containing all context documentation in a portable format. Useful for:
- Handoff to another AI assistant
- Archiving project state
- Sharing context with team members

## Output

Creates timestamped files in `artifacts/exports/`:
- `handoff-YYYY-MM-DD-HHMMSS.json` - Machine-readable
- `handoff-YYYY-MM-DD-HHMMSS.md` - Human-readable

## Handoff Package Schema

```json
{
  "exportedAt": "2026-01-13T10:00:00Z",
  "acsVersion": "5.0.0",
  "project": {
    "name": "my-project",
    "type": "nextjs"
  },
  "context": {
    "orientation": "...",
    "currentStatus": "...",
    "keyDecisions": [...],
    "recentSessions": [...]
  },
  "resumePoint": "Continue implementing auth flow",
  "nextSteps": [...]
}
```

## Example

```bash
> /export

Creating handoff package...

Export complete:
  artifacts/exports/handoff-2026-01-13-100000.json
  artifacts/exports/handoff-2026-01-13-100000.md

Package includes:
  - Project orientation
  - Current status
  - 5 key decisions
  - 3 recent sessions
  - Resume point
```

## Use Cases

1. **AI Handoff**: When switching between AI assistants
2. **Break**: Before stepping away for extended period
3. **Archive**: Snapshot of project state
4. **Share**: Send context to collaborator

## See Also

- [/save-full](save-full.md) - Save session
- [/review](review.md) - Check context health
