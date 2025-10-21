# Claude Context System - File Structure

**Version 2.2.0** - Complete file organization

## Root Files

### Core Documentation
- **README.md** - Overview of the Claude Context System
- **PRD.md** - Product requirements document
- **SETUP_GUIDE.md** - Installation and usage guide
- **MIGRATION_GUIDE.md** - v1.x → v2.0 migration steps
- **CHANGELOG.md** - Version history and changes

## .claude/commands/

Slash command definitions for project workflows.

**Setup Commands (run once):**
- **init-context.md** - Initialize v2.1 structure for new projects (creates 4 core files + 1 AI header)
- **migrate-context.md** - Migrate existing v1.x projects to v2.0

**Maintenance Commands (run frequently):**
- **save.md** - Quick save (2-3 min): Updates STATUS.md (with Quick Reference)
- **save-full.md** - Comprehensive save (10-15 min): Everything save does + detailed SESSIONS.md
- **review-context.md** - Verify documentation accuracy and load context at session start

**Quality & Sharing Commands:**
- **code-review.md** - Comprehensive code quality audit (no changes made)
- **validate-context.md** - Validate documentation structure and health
- **export-context.md** - Export all context docs to single file

**Update Commands:**
- **update-context-system.md** - Update commands and templates from GitHub

**Legacy Commands (v1.x):**
- **save-context.md** - Legacy (replaced by save.md + save-full.md in v2.0)

## .claude/docs/

Comprehensive guides explaining command philosophy and methodology.

**Core Guides:**
- **README.md** - Documentation folder structure and reading order
- **command-philosophy.md** - Core principles (Prime Directive, anti-patterns)
- **code-review-guide.md** - Review methodology, grading rubric, examples
- **save-context-guide.md** - WIP preservation, file-by-file update strategies
- **review-context-guide.md** - Trust but verify, confidence scoring, verification
- **update-guide.md** - System updates, version management, troubleshooting
- **usage-examples.md** - Real-world workflows and scenarios

## .claude/checklists/

Domain-specific review criteria for `/code-review`.

- **accessibility.md** - WCAG compliance, keyboard nav, screen readers
- **security.md** - OWASP Top 10, SQL injection, XSS protection
- **seo-review.md** - Meta tags, Core Web Vitals, structured data
- **performance.md** - Bundle optimization, caching strategies

## templates/

Documentation templates used by `/init-context` and `/add-ai-header`.

**v2.1 Core Templates:**
- **CONTEXT.template.md** - Project orientation (platform-neutral, ~300 lines)
- **STATUS.template.md** - Current state with auto-generated Quick Reference
- **DECISIONS.template.md** - Decision log with guidelines for AI agents
- **SESSIONS.template.md** - Structured session history format

**v2.1 AI Header Templates (Multi-AI Support):**
- **claude.md.template** - Claude/Claude Code entry point
- **cursor.md.template** - Cursor IDE entry point
- **aider.md.template** - Aider CLI entry point
- **codex.md.template** - GitHub Copilot entry point
- **generic-ai-header.template.md** - Template for any other AI tool

**Optional Templates:**
- **PRD.template.md** - Product requirements document
- **ARCHITECTURE.template.md** - Technical architecture documentation
- **CODE_STYLE.template.md** - Coding standards and principles
- **KNOWN_ISSUES.template.md** - Issue tracking template

**Legacy Templates (v1.x - for migration reference):**
- **CLAUDE.template.md** - Replaced by CONTEXT.template.md
- **next-steps.template.md** - Replaced by STATUS.md
- **todo.template.md** - Merged into STATUS.md

## config/

Configuration files for the context system.

- **.context-config.template.json** - v2.0 configuration template
  - Includes: version, counters (nextDecisionId, sessionCount), metrics tracking
- **context-config-schema.json** - JSON Schema for validation

## scripts/

Automation scripts used by commands.

- **validate-context.sh** - Used by `/validate-context`
- **export-sessions-json.sh** - Used by `/export-context`
- **save-context-helper.sh** - Used by `/save` and `/save-full`
- **migrate-to-1-9-0.sh** - Legacy migration (v1.7/v1.8 → v1.9)

## reference/

Reference materials (not enforced by commands).

- **preference-catalog.yaml** - Catalog of workflow preferences

## Typical Project Structure (After /init-context)

```
your-project/
├── .claude/
│   ├── commands/           # Slash commands
│   ├── docs/               # Comprehensive guides
│   └── checklists/         # Review criteria
├── context/
│   ├── claude.md           # AI header: Claude/Claude Code entry point ✨ v2.1
│   ├── CONTEXT.md          # Platform-neutral project orientation ✨ v2.1
│   ├── STATUS.md           # Current state with Quick Reference ✨ v2.1
│   ├── DECISIONS.md        # Decision log ✨ v2.0
│   ├── SESSIONS.md         # Structured history ✨ v2.0
│   ├── cursor.md           # (optional AI header for Cursor) ✨ v2.1
│   ├── aider.md            # (optional AI header for Aider) ✨ v2.1
│   ├── codex.md            # (optional AI header for Copilot) ✨ v2.1
│   ├── CODE_MAP.md         # (optional code location guide) ✨ v2.1
│   ├── PRD.md              # (optional product requirements)
│   ├── ARCHITECTURE.md     # (optional technical architecture)
│   └── .context-config.json
├── artifacts/
│   ├── code-reviews/
│   ├── lighthouse/
│   ├── performance/
│   └── security/
└── [your project files]
```

## AI Header Files (Multi-AI Support Pattern) ✨ v2.1

**Purpose:** Tool-specific entry points that redirect to platform-neutral docs

**Pattern:**
- Each AI tool gets a lightweight 7-line header file
- All header files point to the same platform-neutral documentation
- No duplication of content
- Easy to add support for new AI tools

**Standard header files:**
- **claude.md** - For Claude/Claude Code (always created by /init-context)
- **cursor.md** - For Cursor IDE (optional, created with /add-ai-header cursor)
- **aider.md** - For Aider CLI (optional, created with /add-ai-header aider)
- **codex.md** - For GitHub Copilot (optional, created with /add-ai-header codex)
- **[tool].md** - For any other AI tool (use /add-ai-header [tool])

**All point to:** CONTEXT.md (platform-neutral documentation)

**Format:** 7 lines total
```markdown
# [Tool Name] Context

**📍 Start here:** [CONTEXT.md](./CONTEXT.md)

This project uses the Claude Context System v2.1. All documentation is in platform-neutral markdown files.

**Quick start:** [STATUS.md](./STATUS.md) → Active Tasks → Begin working
```

**Why this pattern:**
- Platform neutrality: Core docs work with any AI tool
- Easy extension: One 7-line file per new tool
- No duplication: All tools share same documentation
- Future-proof: Ready for new AI tools as they emerge

## v2.1 File Purpose Summary

| File | Purpose | Update Frequency |
|------|---------|------------------|
| **claude.md** | AI header: Entry point for Claude | Created once |
| **CONTEXT.md** | Platform-neutral project orientation | Rarely (architecture changes) |
| **STATUS.md** | Current state with Quick Reference (auto-generated) | Every `/save` |
| **DECISIONS.md** | WHY choices were made | When decisions made |
| **SESSIONS.md** | Structured history (Changed/Decisions/Files) | Every `/save` (brief), `/save-full` (detailed) |
| cursor.md | AI header: Entry point for Cursor | Created if needed (optional) |
| aider.md | AI header: Entry point for Aider | Created if needed (optional) |
| codex.md | AI header: Entry point for Copilot | Created if needed (optional) |
| CODE_MAP.md | Code location guide | When features added (optional) |
| PRD.md | Product vision | As needed (optional) |
| ARCHITECTURE.md | System design | As needed (optional) |

## Key Differences from v2.0

**v2.1 Changes (2025-10):**

**Eliminated:**
- QUICK_REF.md → Merged into STATUS.md as auto-generated Quick Reference section

**Added:**
- AI header files (claude.md, cursor.md, aider.md, codex.md) - Multi-AI support pattern
- /add-ai-header command - Easy addition of new AI tool support
- CODE_MAP.md template - Optional code location guide
- Configurable staleness thresholds in .context-config.json
- Git push protection settings in config
- Auto-generated Quick Reference section in STATUS.md

**Enhanced:**
- CONTEXT.md - Trimmed to ~300 lines, added "Getting Started Path"
- STATUS.md - Now includes auto-generated Quick Reference at top
- .context-config.json - Added project URLs, commands, tech stack, validation thresholds

**File count:** v2.0 had 6 files → v2.1 has 4 core files + 1 AI header (consolidation via QUICK_REF merge)

**Philosophy:**
- Platform neutrality: Core docs work with any AI tool
- Consolidation: Merge duplicate content, don't expand unnecessarily
- Auto-generation: Prevent manual drift with system-managed sections
- Configurability: Per-project flexibility without code changes

## Key Differences from v1.x

**Eliminated:**
- `tasks/next-steps.md` → Merged into STATUS.md
- `tasks/todo.md` → Merged into STATUS.md
- `CLAUDE.md` → Renamed to CONTEXT.md (v2.0), then claude.md header added (v2.1)

**Added:**
- STATUS.md - Single source of truth for current state
- QUICK_REF.md - Auto-generated dashboard (v2.0, merged into STATUS in v2.1)
- DECISIONS.md - Always created (was optional before)
- AI header files - Multi-AI support (v2.1)

**Improved:**
- SESSIONS.md - Structured format instead of prose

**Philosophy:**
- No status duplication - update once in STATUS.md
- Single file per purpose
- Auto-generation where possible
- Platform-neutral core with tool-specific entry points
