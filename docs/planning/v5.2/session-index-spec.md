# Session Index Specification

**Version:** v5.2.0
**Purpose:** Define Session Index format and rotation rules for SESSIONS.md scalability

---

## Problem Statement

SESSIONS.md grows unbounded as projects progress. At 50+ sessions (~500 tokens each), the file exceeds practical token limits for AI context loading.

## Solution

1. **Session Index** - Compact table at top for quick navigation
2. **Archival** - Move old session content to `.sessions-archive/` directory
3. **Token Budget** - Keep SESSIONS.md under 20,000 tokens

---

## Index Table Format

```markdown
| # | Date | Phase | Focus | Key Decisions |
|---|------|-------|-------|---------------|
| 50 | 2026-01-23 | Production | Member Onboarding | Password rules |
| 49 | 2026-01-22 | Production | Email Integration | Resend chosen |
```

**Columns:**
- **#**: Session number (integer, most recent first in display)
- **Date**: YYYY-MM-DD format
- **Phase**: Project phase (Setup, Development, Production, etc.)
- **Focus**: 2-4 word summary of session focus
- **Key Decisions**: Most important decision/outcome (optional, ≤50 chars)

**Token Cost:** ~20 tokens per row

---

## Rotation Rules

### Threshold

Archive when session count > 30 full sessions in SESSIONS.md.

### Archive Batch

Move oldest 10 sessions at a time to minimize churn.

### What Gets Archived

- Full session content (everything between `## Session N` headers)
- Index rows are NEVER archived (remain for navigation)

### Archive Location

`context/.sessions-archive/` directory with timestamped files:
- `sessions-archive-YYYY-MM-DD-HHMMSS.md`

This matches the existing v5.1.0 archival pattern from `archive-sessions-helper.sh`.

### Archive Format

```markdown
# Archived Sessions

Sessions archived from SESSIONS.md to manage file size.
Archived: YYYY-MM-DD HH:MM:SS

Search all archives: `grep -rA50 "## Session N" context/.sessions-archive/`

---

## Session 1 | 2025-10-09 | Initial Setup

[Full content preserved exactly as originally written]

---

## Session 2 | 2025-10-10 | Feature Work

[Full content preserved exactly as originally written]
```

---

## Token Budget

Target: Keep SESSIONS.md under 20,000 tokens

| Component | Token Estimate |
|-----------|----------------|
| Header + formatting | ~200 tokens |
| Session Index (100 rows) | ~2,000 tokens |
| 25 full sessions | ~12,500 tokens |
| Tips and templates | ~500 tokens |
| **Total** | ~15,200 tokens |

Leaves ~5,000 tokens buffer for variation.

---

## Implementation

### /save-full Updates

After creating session entry:

1. **Update Index Table**
   - Extract: session number, date, phase, focus (from TL;DR)
   - Insert row after table header

2. **Check Archive Threshold**
   ```bash
   SESSION_COUNT=$(grep -c "^## Session [0-9]" context/SESSIONS.md)
   if [ "$SESSION_COUNT" -gt 30 ]; then
     # Trigger archive
   fi
   ```

3. **Archive If Needed**
   - Identify oldest 10 sessions
   - Extract full content
   - Create new timestamped file in `.sessions-archive/`
   - Remove from SESSIONS.md (keep index rows)

### /review-context Updates

When loading sessions:

1. Always read Session Index (small, fits in context)
2. Read last 5-10 full sessions for detailed context
3. Note if sessions are archived (guide user to archive file)

---

## Migration Path

For existing projects without Session Index:

1. Run `scripts/migrate-sessions-index.sh`
2. Script extracts session metadata and generates index
3. Manual review recommended before committing

---

## Test Cases

### Index Generation

```bash
# Input: ## Session 5 | 2026-01-23 | Feature Work
# Expected row: | 5 | 2026-01-23 | - | Feature Work | - |
```

### Archive Trigger

```bash
# 31 sessions → archive oldest 10
# Result: 21 full sessions + 31 index rows
```

### Token Verification

```bash
# Count tokens (approximate: words * 1.3)
wc -w context/SESSIONS.md | awk '{print $1 * 1.3}'
# Should be < 20000
```
