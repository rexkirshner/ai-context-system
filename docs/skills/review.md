# /review

Check context documentation health and get resume point.

## Usage

```
/review
```

## Description

Analyzes context documentation quality and provides:
- Health score (0-100)
- Breakdown by category
- Warnings for issues
- Resume point for session continuity

## Output

```json
{
  "score": 85,
  "breakdown": {
    "statusFreshness": 18,
    "sessionsFreshness": 20,
    "decisionsCoverage": 12,
    "contextCompleteness": 15,
    "quickReferenceSync": 10,
    "crossReferences": 10
  },
  "warnings": ["Quick Reference may be stale"],
  "nextAction": "Update Quick Reference block",
  "resumePoint": "Continue implementing auth flow"
}
```

## Health Score Categories

| Category | Max Points | Measures |
|----------|------------|----------|
| Status Freshness | 20 | How recently STATUS.md was updated |
| Sessions Freshness | 20 | How recently session was logged |
| Decisions Coverage | 15 | Important decisions documented |
| Context Completeness | 15 | Required sections present |
| Quick Reference Sync | 15 | QR matches actual state |
| Cross References | 15 | Links are valid |

## Example

```bash
> /review

Context Health: 85/100

Breakdown:
  Status Freshness:      18/20
  Sessions Freshness:    20/20
  Decisions Coverage:    12/15
  Context Completeness:  15/15
  Quick Reference Sync:  10/15
  Cross References:      10/15

Warnings:
  - Quick Reference may be stale (last updated 3 days ago)

Resume Point:
  Continue implementing auth flow (see SESSIONS.md)

Next Action:
  Update Quick Reference block
```

## See Also

- [/save](save.md) - Quick status update
- [/save-full](save-full.md) - Full session save
