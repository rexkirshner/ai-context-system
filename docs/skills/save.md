# /save

Quick status update (2-3 minutes).

## Usage

```
/save
```

## Description

Lightweight save that only updates STATUS.md with current state. Use for quick checkpoints between work sessions. For comprehensive session documentation, use `/save-full` instead.

## What It Updates

- Current Focus section in STATUS.md
- Quick Reference block (if stale)
- Last Updated timestamp

## What It Does NOT Do

- Create session entry in SESSIONS.md (use /save-full)
- Update DECISIONS.md
- Generate handoff documentation

## Example

```bash
> /save

Updating STATUS.md...

Current Focus: Implementing user authentication
Quick Reference: ✓ Updated

Status saved. Use /save-full for complete session documentation.
```

## When to Use

- Quick checkpoint before stepping away
- After completing a small task
- To refresh Quick Reference block

## See Also

- [/save-full](save-full.md) - Complete session documentation
- [/review](review.md) - Check context health
