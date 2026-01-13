# /review Skill

Review context health and provide actionable resume point.

## Purpose

Calculate documentation health score and provide clear starting point for new sessions. Run at session start or anytime to check context state.

## Output

```
╔════════════════════════════════════════════╗
║         Context Health Report              ║
╚════════════════════════════════════════════╝

Score: [N]/100 [🟢|🟡|🔴]

Breakdown:
  Status Freshness:     [X]/20
  Sessions Freshness:   [X]/20
  Decisions Coverage:   [X]/15
  Context Completeness: [X]/15
  Quick Reference Sync: [X]/15
  Cross References:     [X]/15

[Warnings if any]

Next Action: [most impactful improvement]
Resume Point: [actionable task with file location]
```

## Health Score Calculation

### Components (100 points total)

| Component | Max | Scoring |
|-----------|-----|---------|
| Status Freshness | 20 | 20 - (days_since_update × 2), min 0 |
| Sessions Freshness | 20 | 20 - (days_since_session × 2), min 0 |
| Decisions Coverage | 15 | 15 if recent session refs decision, 10 if any exist, 0 otherwise |
| Context Completeness | 15 | 15 - (placeholders × 3) - (missing_fields × 5), min 0 |
| Quick Reference Sync | 15 | 3 pts each: project name, phase, focus, resume format, health present |
| Cross References | 15 | 15 - (broken_decision_refs × 5), min 0 |

### Thresholds

| Score | Status | Indicator |
|-------|--------|-----------|
| 80-100 | Healthy | 🟢 |
| 50-79 | Needs attention | 🟡 |
| 0-49 | Critical | 🔴 |

## Execution

### 1. Verify Context Exists

If no `context/` directory, suggest running `/init`.

### 2. Calculate Each Score Component

**Status Freshness:** Check file modification time of STATUS.md

**Sessions Freshness:** Parse last session date from `## Session N | YYYY-MM-DD` pattern

**Decisions Coverage:**
- 15: Last session references a D### decision
- 10: DECISIONS.md has entries
- 0: No decisions documented

**Context Completeness:**
- Count `[FILL:...]` placeholders in CONTEXT.md
- Check required fields: project.name, project.type in config, Primary Language in CONTEXT.md

**Quick Reference Sync:** Check STATUS.md Quick Reference block:
- Project name matches config
- Phase matches current phase section
- Focus is populated
- Resume starts with verb, has location
- Health score is present

**Cross References:** Find all `D###` references in STATUS.md and SESSIONS.md, verify each exists in DECISIONS.md

### 3. Generate Warnings

Add warnings for:
- STATUS.md older than 7 days
- No session entries in last 7 days
- No decisions documented
- Unfilled placeholders
- Quick Reference out of sync
- Broken decision references

### 4. Determine Next Action

Recommend fixing the lowest-scoring component:
- Low Status Freshness → "Update STATUS.md with current work"
- Low Sessions Freshness → "Run /save-full to document recent work"
- Low Decisions Coverage → "Document a recent decision in DECISIONS.md"
- Low Context Completeness → "Fill in missing fields in CONTEXT.md"

### 5. Extract Resume Point

Priority order:
1. First item from STATUS.md `## Next Steps`
2. First item from last session's `### Next Steps`
3. Generated: "Continue work on current tasks in context/STATUS.md"

Resume point MUST start with action verb and include file/location reference.

## Verification

| Check | Requirement |
|-------|-------------|
| Score range | 0-100 inclusive |
| Resume format | Starts with verb, contains location |
| All components | Each breakdown item calculated |

## Guardrails

- **DO NOT** modify any files (read-only operation)
- **DO NOT** generate resume point without location reference
- **DO** show all warnings, not just first one
- **DO** provide actionable next step based on lowest score
