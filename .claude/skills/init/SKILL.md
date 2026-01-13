# /init Skill

Initialize AI Context System for a new project.

## Purpose

Create minimal context files for session continuity and AI handoffs. Auto-detect as much as possible; minimize user input.

## Output Structure

```
context/
├── CONTEXT.md           # Project orientation (stable)
├── STATUS.md            # Current state + Quick Reference (dynamic)
├── DECISIONS.md         # Decision log (append-only)
├── SESSIONS.md          # Session history (append-only)
└── .context-config.json # Configuration
CLAUDE.md                # Entry point (project root)
```

## Execution

### 1. Check If Already Initialized

If `context/.context-config.json` exists, stop and suggest running `/review` instead.

### 2. Auto-Detect Project Info

Gather without prompting the user:

| Field | Detection Method |
|-------|-----------------|
| Project name | `package.json` name → `pyproject.toml` name → `Cargo.toml` name → directory name |
| Type | `src/app/` or `pages/` = app, `bin/` = cli, `lib/` only = library, `api/` = api |
| Language | Most common extension in `src/`: `.ts/.tsx` = TypeScript, `.py` = Python, etc. |
| Framework | Check dependencies: next, react, express, fastapi, etc. |
| Dev command | `package.json` scripts.dev → Makefile dev → `npm run dev` |
| Test command | `package.json` scripts.test → `pytest` → `go test` |

### 3. Create Files

**context/.context-config.json:**
```json
{
  "version": "5.0.0",
  "profile": "standard",
  "project": { "name": "[detected]", "type": "[detected]" }
}
```

**context/CONTEXT.md:**
```markdown
# [Project Name]

## Overview
[First paragraph from README.md OR package.json description OR "A [type] project"]

## Tech Stack
- **Language:** [detected]
- **Framework:** [detected or "None"]

## Getting Started
\`\`\`bash
[detected dev command]
\`\`\`

## Key Files
- [List 3-5 important files based on project type]
```

**context/STATUS.md:**
```markdown
<!-- BEGIN AUTO:QUICK_REFERENCE -->
**Project:** [name] | **Phase:** Setup | **Health:** --/100
**Focus:** Initial configuration
**Resume:** Review CONTEXT.md for accuracy in context/CONTEXT.md
<!-- END AUTO:QUICK_REFERENCE -->

## Current Phase
Initial setup.

## Active Tasks
- [ ] Review CONTEXT.md for accuracy
- [ ] Make first commit with context files

## Next Steps
- Begin development work
- Run /save-full after completing significant work
```

**context/DECISIONS.md:**
```markdown
# Decisions Log

Track decisions with rationale for AI continuity.

| ID | Date | Decision | Rationale |
|----|------|----------|-----------|

*Use /save-full to document decisions made during sessions.*
```

**context/SESSIONS.md:**
```markdown
# Session History

<!-- BEGIN SESSION 1 -->
## Session 1 | [today] | Initialization

### TL;DR
Initialized AI Context System v5.0. Created context files with auto-detected project configuration.

### Next Steps
- Review CONTEXT.md for accuracy
- Begin development
<!-- END SESSION 1 -->
```

**CLAUDE.md** (only if doesn't exist):
```markdown
# Claude Code Instructions

This project uses AI Context System v5.0.

**Start:** Read `context/STATUS.md`
**End:** Run `/save-full` to document work

## Commands
- `/review` - Health check and resume point
- `/save-full` - Document session completely
- `/save` - Quick status update
```

### 4. Verify

| Check | Pass Criteria |
|-------|---------------|
| Config valid | `jq .` succeeds on `.context-config.json` |
| Project name | Non-empty in config |
| Placeholders | Fewer than 3 `[FILL:...]` in CONTEXT.md |

## Output Summary

```
✓ AI Context System v5.0 Initialized

Created: context/CONTEXT.md, STATUS.md, DECISIONS.md, SESSIONS.md
         context/.context-config.json, CLAUDE.md

Next: Review context/CONTEXT.md, then begin work
```

## Guardrails

- **DO NOT** prompt user for information that can be auto-detected
- **DO NOT** create placeholder-heavy files; use detected values or sensible defaults
- **DO** fall back gracefully if detection fails (use directory name, generic descriptions)
- **DO** complete initialization in one pass without stopping for input
