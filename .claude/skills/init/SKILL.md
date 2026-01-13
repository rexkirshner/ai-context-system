# /init Skill

Initialize AI Context System for a new or existing project.

## Purpose

Create the minimal context file structure needed for session continuity and AI handoffs.

## Output

```
context/
├── CONTEXT.md           # Orientation (rarely changes)
├── STATUS.md            # Current state + Quick Reference
├── DECISIONS.md         # Decision log with rationale
├── SESSIONS.md          # Session history
└── .context-config.json # Configuration
```

Plus CLAUDE.md at project root (auto-loaded by Claude Code).

## Execution Steps

### Step 1: Check Prerequisites

```bash
# Verify we're in a valid project directory
if [ ! -d ".git" ] && [ ! -f "package.json" ] && [ ! -f "pyproject.toml" ] && [ ! -f "Cargo.toml" ] && [ ! -f "go.mod" ]; then
  echo "Warning: No recognized project markers found"
  echo "Continuing anyway..."
fi

# Check if already initialized
if [ -f "context/.context-config.json" ]; then
  echo "AI Context System already initialized."
  echo "Use /review to check context health."
  exit 0
fi
```

### Step 2: Auto-Detect Project Information

Gather project information automatically:

**Detect project name:**
1. Check package.json `name` field
2. Check pyproject.toml `name` field
3. Check Cargo.toml `name` field
4. Fall back to directory name

**Detect project type:**
- Has `src/app/` or `pages/` → app
- Has `bin/` or `cli` in name → cli
- Has `lib/` and no app → library
- Has `api/` or `routes/` → api
- Has `apps/` and `packages/` → monorepo

**Detect primary language:**
- Count file extensions in `src/` or root
- Most common: TypeScript (.ts/.tsx), JavaScript (.js/.jsx), Python (.py), Rust (.rs), Go (.go)

**Detect dev/test commands:**
- Read package.json scripts for `dev`, `start`, `test`
- Read pyproject.toml for pytest or unittest
- Read Makefile for standard targets

### Step 3: Create Directory Structure

```bash
mkdir -p context
```

### Step 4: Create Configuration

Create `context/.context-config.json`:

```json
{
  "version": "5.0.0",
  "profile": "standard",
  "project": {
    "name": "[detected-name]",
    "type": "[detected-type]"
  }
}
```

### Step 5: Create Context Files

**CONTEXT.md** - Use detected info to fill in:

```markdown
# [Project Name]

## Overview
[Auto-detect from README.md first paragraph or package.json description]

## Tech Stack
- **Primary Language:** [detected]
- **Framework:** [detected from dependencies]
- **Database:** [detected if present]

## Getting Started

### Development
\`\`\`bash
[detected dev command]
\`\`\`

### Testing
\`\`\`bash
[detected test command]
\`\`\`

## Architecture
[Brief description of main directories]

## Key Files
[List 3-5 most important files]
```

**STATUS.md** - Initialize with Quick Reference:

```markdown
<!-- BEGIN AUTO:QUICK_REFERENCE -->
**Project:** [name] | **Phase:** Setup | **Health:** --/100
**Focus:** Initial setup
**Resume:** Complete context initialization
<!-- END AUTO:QUICK_REFERENCE -->

## Current Phase
Initial setup and configuration.

## Active Tasks
- [ ] Review and customize CONTEXT.md
- [ ] Make first commit with context files

## Blockers
None.

## Next Steps
- Start development work
- Use /save-full at end of significant work sessions
```

**DECISIONS.md** - Start empty:

```markdown
# Decisions Log

Track important decisions with rationale for AI continuity.

## Format

Each decision should include:
- **ID:** Sequential (D001, D002, ...)
- **Date:** When decided
- **Summary:** One-line description
- **Context:** Why this decision was needed
- **Decision:** What was decided
- **Rationale:** Why this option was chosen
- **Alternatives:** What else was considered

---

## Active Decisions

*No decisions recorded yet. Use /save-full to document decisions made during sessions.*
```

**SESSIONS.md** - Start with initialization entry:

```markdown
# Session History

Append-only log of work sessions for continuity.

---

<!-- BEGIN SESSION 1 -->
## Session 1 | [today's date] | Initialization

### TL;DR
Initialized AI Context System v5.0 for [project-name]. Created context/ directory with CONTEXT.md, STATUS.md, DECISIONS.md, and SESSIONS.md.

### Accomplishments
- Initialized AI Context System
- Auto-detected project configuration
- Created context files from detected info

### Next Steps
- Review CONTEXT.md for accuracy
- Begin development work
<!-- END SESSION 1 -->
```

**CLAUDE.md** (project root) - Create if not exists:

```markdown
# Claude Code Instructions

## Context System
This project uses AI Context System v5.0 for session continuity.

**Start of session:** Read `context/STATUS.md` for current state
**End of session:** Run `/save-full` to document work

## Project Quick Reference
See `context/STATUS.md` for current tasks and next steps.

## Key Commands
- `/review` - Check context health and get resume point
- `/save-full` - Document session with full details
- `/save` - Quick status update
```

### Step 6: Verify Output

Run verification checks:

```bash
# Count placeholders (should be < 3)
PLACEHOLDERS=$(grep -cE '\[FILL:[^\]]+\]' context/CONTEXT.md 2>/dev/null || echo "0")
echo "Placeholders: $PLACEHOLDERS"

# Check required fields
REQUIRED_OK=true

# Project name in config
if ! jq -e '.project.name' context/.context-config.json >/dev/null 2>&1; then
  echo "Missing: project name"
  REQUIRED_OK=false
fi

# Project type in config
if ! jq -e '.project.type' context/.context-config.json >/dev/null 2>&1; then
  echo "Missing: project type"
  REQUIRED_OK=false
fi

# Primary language in CONTEXT.md
if ! grep -q "Primary Language:" context/CONTEXT.md 2>/dev/null; then
  echo "Missing: primary language"
  REQUIRED_OK=false
fi

# Verification result
if [ "$PLACEHOLDERS" -lt 3 ] && [ "$REQUIRED_OK" = "true" ]; then
  echo "✓ Initialization complete"
else
  echo "⚠ Some fields need attention"
fi
```

### Step 7: Output Summary

```
✓ AI Context System v5.0 Initialized

Created:
  context/CONTEXT.md      - Project orientation
  context/STATUS.md       - Current state
  context/DECISIONS.md    - Decision log
  context/SESSIONS.md     - Session history
  context/.context-config.json
  CLAUDE.md              - Entry point (if new)

Next steps:
1. Review context/CONTEXT.md for accuracy
2. Start your development work
3. Run /save-full at end of session
```

## Verification Criteria

Per V5_PLANNING.md:

| Check | Requirement |
|-------|-------------|
| Placeholders | `grep -cE '\[FILL:[^\]]+\]' context/CONTEXT.md` returns < 3 |
| Required fields | project.name, project.type, primary language all present |
| Config valid | `jq . context/.context-config.json` succeeds |

## Error Handling

- If detection fails, use `[FILL: description]` placeholder
- Never leave files partially written
- If config parse fails, show raw JSON for debugging
- On any error, show what was created and what needs manual attention

## Notes

- This skill replaces v4.x `/init-context` command
- Much simpler: no interactive prompts, auto-detect everything possible
- Focus on getting to "working" state quickly
- User can refine later with /save-full
