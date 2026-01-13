# /save Skill

Quick session save - updates STATUS.md only.

## Purpose

Minimal-overhead state capture. Updates Quick Reference block and current tasks. Use for most session endings.

**Use /save-full instead when:** Before breaks, before handoffs, after completing significant features, when decisions need documenting.

## Output

Only `context/STATUS.md` is modified:
1. Quick Reference block refreshed
2. Current tasks/blockers/next steps updated if changed

## Execution

### 1. Read Current State

From STATUS.md, extract:
- Current phase
- Current focus (from `## Current Focus` or recent work)
- First item from `## Next Steps`

### 2. Generate Resume Point

Resume point MUST:
- Start with action verb: Add, Build, Complete, Configure, Continue, Create, Debug, Fix, Implement, Refactor, Review, Test, Update, etc.
- Include location: "in [file/directory]"

**Good:** `Continue implementing auth middleware in src/middleware/auth.ts`
**Bad:** `Work on auth` (no verb pattern, no location)

### 3. Update Quick Reference Block

Replace content between markers:

```markdown
<!-- BEGIN AUTO:QUICK_REFERENCE -->
**Project:** [name] | **Phase:** [phase] | **Health:** --/100
**Focus:** [current focus - max 60 chars]
**Resume:** [resume point with verb + location]
<!-- END AUTO:QUICK_REFERENCE -->
```

### 4. Update Status Sections

Review and update only if changed:
- **Active Tasks** - Mark completed, add new
- **Blockers** - Update or clear resolved
- **Next Steps** - Ensure actionable first item

**DO NOT** add placeholder content or rewrite unchanged sections.

### 5. Verify

| Check | Requirement |
|-------|-------------|
| Only STATUS.md modified | No other context files changed |
| Quick Reference present | Has BEGIN/END AUTO markers |
| Resume point valid | Starts with verb, contains location preposition |

## Output Summary

```
✓ Status saved

Quick Reference:
  Project: [name]
  Focus: [focus]
  Resume: [resume point]

Next session: Run /review for health score
```

## Guardrails

- **DO NOT** modify SESSIONS.md, DECISIONS.md, or CONTEXT.md
- **DO NOT** add filler content to unchanged sections
- **DO** preserve existing content structure
- **DO** keep resume point specific and actionable
