# /validate Skill

Validate context documentation structure and integrity.

## Purpose

Check context files for structural issues, broken references, and format compliance. Read-only operation that reports problems without fixing them.

## Output

```
╔════════════════════════════════════════════╗
║       Context Validation Report            ║
╚════════════════════════════════════════════╝

Structure Checks:
  ✓ CONTEXT.md exists and has required sections
  ✓ STATUS.md exists with Quick Reference block
  ✓ DECISIONS.md exists
  ✓ SESSIONS.md exists with valid entries
  ✓ .context-config.json is valid JSON

Cross-Reference Checks:
  ✓ All D### references exist in DECISIONS.md
  ✗ D999 referenced but not found

Quick Reference Sync:
  ✓ Project name matches config
  ⚠ Resume point missing location reference

Format Compliance:
  ✓ All sessions have BEGIN/END markers
  ✓ Session numbers are sequential

Summary: [N]/[M] passed, [X] failed, [Y] warnings
```

## Validation Checks

### Structure (Required Files)

| File | Check |
|------|-------|
| context/CONTEXT.md | Exists |
| context/STATUS.md | Exists, has Quick Reference block |
| context/DECISIONS.md | Exists |
| context/SESSIONS.md | Exists |
| context/.context-config.json | Exists, valid JSON, has version, project.name |

### Cross-References

- Find all `D###` patterns in STATUS.md and SESSIONS.md
- Verify each exists in DECISIONS.md as heading or bold entry
- Flag broken references as errors
- Flag orphaned decisions (in DECISIONS.md but never referenced) as warnings

### Quick Reference Sync

| Field | Validation |
|-------|------------|
| Project name | Matches config project.name |
| Resume point | Starts with action verb |
| Resume point | Contains location (in/at/for/to + path) |

### Format Compliance

| Check | Pass Criteria |
|-------|---------------|
| Session markers | Equal count of `BEGIN SESSION` and `END SESSION` |
| No incomplete sessions | Last marker is `END SESSION` |
| Sequential numbers | No gaps in session numbering |
| TL;DR present | Each session has `### TL;DR` section |

### Placeholders

- Count `[FILL:...]` patterns in CONTEXT.md
- Warn if any unfilled placeholders exist

## Execution

### 1. Run All Checks

Run every validation check, collecting errors and warnings. Don't stop at first failure.

### 2. Categorize Results

- **Error (✗):** Must fix - broken functionality
- **Warning (⚠):** Should fix - degraded quality
- **Pass (✓):** OK

### 3. Output Summary

Show pass/fail/warning counts and list all issues.

## Verification

| Check | Requirement |
|-------|-------------|
| All checks run | Complete even if errors found |
| Broken refs detected | D999 injection causes failure |
| Markers validated | Missing END marker causes failure |

## Guardrails

- **DO NOT** modify any files (read-only)
- **DO NOT** stop at first error - run all checks
- **DO** list all issues found, not just first
- **DO** distinguish errors (must fix) from warnings (should fix)
