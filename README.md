# AI Context System

**Version 3.0.0**

> Perfect session continuity for AI coding assistants
>
> **Start simple, grow naturally. Platform-neutral core with tool-specific entry points.**
>
> _Originally designed for Claude Code, now supports all AI assistants (Claude, Cursor, Aider, Codex, and more)_

---

## 🎉 v3.0.0 Released - Rebrand to AI Context System

**BREAKING CHANGE:** System renamed to reflect universal AI support

**What Changed:**
- **System Name**: Claude Context System → **AI Context System**
- **Feedback File**: `claude-context-feedback.md` → `context-feedback.md`
- **Repository**: Renamed to `ai-context-system` (old URLs auto-redirect)

**What Stayed the Same:**
- ✅ `claude.md`, `cursor.md`, `aider.md`, `codex.md` (tool-specific entry points - correct by design)
- ✅ All your content: `CONTEXT.md`, `STATUS.md`, `DECISIONS.md`, `SESSIONS.md`
- ✅ Zero data loss - all content preserved and archived

**Migration (5 minutes):**
```bash
/update-context-system  # Automatic migration, zero data loss
```

**Learn more:** [MIGRATION_GUIDE_v2_to_v3.md](./MIGRATION_GUIDE_v2_to_v3.md) • [CHANGELOG.md](./CHANGELOG.md)

---

## 🆕 What's New in v2.1

**Philosophy:** Consolidate, don't expand. Start with minimal overhead, add complexity only when needed.

**Key Improvements:**
- **File consolidation** - QUICK_REF merged into STATUS.md → 5 files (4 core + 1 AI header)
- **Multi-AI support** - Platform-neutral docs with tool-specific headers (claude.md, cursor.md, etc.)
- **Mandatory TL;DR** - Enforced 2-3 sentence summaries in sessions
- **Automated staleness** - Visual indicators (🟢🟡🔴) with configurable thresholds
- **Git push protection** - 5-layer structural prevention system
- **CODE_MAP optional** - 4-question criteria gates creation

**New Structure:**
- **claude.md** - AI header (7-line redirect to platform-neutral docs)
- **CONTEXT.md** - Platform-neutral orientation (~300 lines, 50% reduction)
- **STATUS.md** - Single source of truth **with auto-generated Quick Reference at top**
- **DECISIONS.md** - Decision log (WHY choices were made)
- **SESSIONS.md** - Structured history with mandatory TL;DR + auto-logged git ops

**For new projects:** Run `/init-context` - creates minimal structure, suggests optional files when needed

**For v2.0 projects:** See [MIGRATION_GUIDE_v2.0_to_v2.1.md](./MIGRATION_GUIDE_v2.0_to_v2.1.md) - 10-15 minute migration

**Learn more:** [What's New in v2.1](#whats-new-in-v21) • [CHANGELOG.md](./CHANGELOG.md)

---

## What is This?

The AI Context System is a complete toolkit for maintaining perfect context across AI coding sessions AND enabling AI agents to review, improve, and take over your work.

**Dual Purpose:**
1. **Session Continuity** - Never lose your place, never repeat explanations, never lose work again
2. **AI Agent Review & Takeover** - Rich documentation that enables AI agents to understand your thinking, review your work, and seamlessly take over development

## The Problem

**For Session Continuity:**
- Context is lost between sessions
- You repeat the same explanations every time
- Work in progress disappears when sessions end
- Technical decisions get forgotten or contradicted
- Session handoffs feel like starting over

**For AI Agent Review & Takeover:**
- AI agents can't understand WHY you made certain decisions
- Code reviews lack context about constraints and tradeoffs
- New AI agents starting on your project have to reverse-engineer your thinking
- Architecture reviews miss the rationale behind design choices
- Handoffs to other developers/AIs lose critical mental models

## The Solution

**Two-tier workflow** - Minimal overhead for continuous work, comprehensive documentation when needed:

**Philosophy:**
- **Within sessions:** TodoWrite for active productivity (zero overhead)
- **Quick saves (daily):** `/save` updates current state (2-3 minutes)
- **Comprehensive saves (occasional):** `/save-full` before breaks/handoffs (10-15 minutes)
- **Single source of truth:** No duplication, but comprehensive depth

**Setup (run once):**
- **`/init-context`** - Create core files (CONTEXT.md, STATUS.md, DECISIONS.md)
- **`/migrate-context`** - Migrate existing project with documentation

**Daily Workflow:**
- **`/save`** - Quick save (2-3 min): Updates STATUS.md (with auto-generated Quick Reference section)
- **`/save-full`** - Comprehensive (10-15 min): Everything /save does + SESSIONS.md entry + mental models
- **Frequency:** Use `/save` most sessions, `/save-full` 3-5× per 20 sessions
- **`/review-context`** - Verify continuity and completeness

**Quality & Sharing:**
- **`/code-review`** - AI agent conducts quality audit
- **`/validate-context`** - Check documentation completeness
- **`/export-context`** - Generate AI-optimized export for review/takeover

**Updates:**
- **`/update-context-system`** - Update to latest version from GitHub

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/rexkirshner/ai-context-system.git

# 2. Copy toolkit to your project
cp -r ai-context-system/.claude /path/to/your/project/
cp -r ai-context-system/scripts /path/to/your/project/

# 3. In Claude Code, initialize
/init-context

# 4. Clean up (after init completes)
rm -rf ai-context-system

# 5. Daily workflow
/save          # Quick update (2-3 min) - most sessions
/save-full     # Comprehensive (10-15 min) - before breaks/handoffs
```

See [SETUP_GUIDE.md](./SETUP_GUIDE.md) for complete instructions.

## What Gets Created

**Core documentation** (`/init-context`):
```
your-project/
├── .claude/                        # Toolkit (you copy this)
│   ├── commands/                   # Slash commands
│   ├── docs/                       # Comprehensive guides
│   └── checklists/                 # Review criteria
├── scripts/
│   └── validate-context.sh         # Validation script
├── context/                        # Core documentation files
│   ├── .context-config.json        # Project configuration
│   ├── claude.md                   # AI header (7-line redirect)
│   ├── CONTEXT.md                  # Orientation (who/what/how/why)
│   ├── STATUS.md                   # Current state (includes Quick Reference section)
│   ├── DECISIONS.md                # Decision log (WHY choices were made)
│   └── SESSIONS.md                 # History (structured, comprehensive)
└── artifacts/                      # Generated outputs
    ├── code-reviews/               # AI agent code reviews
    ├── lighthouse/                 # Performance reports
    ├── performance/                # Perf analysis
    ├── security/                   # Security audits
    ├── bundle-analysis/            # Bundle reports
    └── coverage/                   # Test coverage
```

**Additional files created on-demand**:
- `CODE_MAP.md` → Project has >20 files, multiple directories
- `PRD.md` → Product vision gets complex
- `ARCHITECTURE.md` → System design needs comprehensive documentation

**Key Principle:** Structured but comprehensive. AI agents need depth to understand your thinking, constraints, and rationale - not just what you did, but WHY.

## Key Features

### Dual Purpose: Developer Productivity + AI Agent Review (New in v1.8.0!)
- **Within sessions** - TodoWrite for active productivity (minimal overhead)
- **At save points** - Rich documentation for AI review and takeover
- **Mental models captured** - AI agents understand your thinking, not just code
- **Decision rationale preserved** - DECISIONS.md explains WHY, not just WHAT
- **Comprehensive but structured** - Depth without verbosity

### AI Agent Review & Takeover
- **`/code-review`** - AI agent reviews your code with full context
- **`/export-context`** - Generates AI-optimized export for agent takeover
- **DECISIONS.md** - AI understands constraints and tradeoffs
- **SESSIONS.md** - AI learns from your problem-solving approach
- **Mental model capture** - AI knows your current thinking and next steps

### Single Source of Truth
- **Each piece of information lives in ONE place**
- No duplication between CONTEXT.md, STATUS.md, SESSIONS.md
- STATUS.md is canonical for current state
- DECISIONS.md is canonical for WHY
- CONTEXT.md references other files instead of duplicating

### Structured, Comprehensive Documentation
- **SESSIONS.md is structured AND comprehensive**
- Easy to scan: What changed, decisions, files, mental models, next steps
- Enough depth for AI agents to understand context and thinking
- Auto-generated Quick Reference section in STATUS.md

### Smart Save Commands
- **`/save` (2-3 min)** - Quick updates: STATUS.md with auto-generated Quick Reference
- **`/save-full` (10-15 min)** - Comprehensive: Everything /save does + SESSIONS.md entry with mandatory TL;DR
- **Captures TodoWrite state automatically**
- **Auto-logs git operations** (commits, pushes) to SESSIONS.md
- **Extracts mental models and decision rationale**
- Suggests optional files when complexity demands

### Zero Context Loss
- Session logs preserve exact state + thinking
- Work-in-progress with mental models
- Can resume from anywhere
- AI agents can take over seamlessly

## Core Commands

### Setup Commands (Run Once)

#### `/init-context`
**For ALL projects**

Creates 5 files (4 core + 1 AI header): claude.md, CONTEXT.md, STATUS.md, DECISIONS.md, SESSIONS.md. STATUS.md includes auto-generated Quick Reference section at top. Optional files (CODE_MAP, PRD) suggested when complexity demands. **Start simple, grow naturally.**

#### `/migrate-context`
**For EXISTING projects with docs**

Migrates existing documentation to AI Context System structure. Preserves ALL existing content while organizing into context/ and artifacts/ folders. Consolidates to single source of truth.

### Maintenance Commands (Run Frequently)

#### `/save`
**Quick save - run often (2-3 min)**

**Updates current state. Fast and lightweight.**

- Updates STATUS.md (including auto-generated Quick Reference section)
- Captures current tasks, blockers, next steps
- Your safety net for maintaining context

#### `/save-full`
**Comprehensive save - run before breaks (10-15 min)**

**Everything /save does + full session documentation.**

- Updates STATUS.md with auto-generated Quick Reference
- Adds structured entry to SESSIONS.md with mandatory TL;DR
- Captures mental models and decision rationale
- Auto-logs git operations for audit trail
- Suggests optional files when complexity demands

#### `/review-context`
**Run at session start**

Verifies documentation is current and accurate. Shows Quick Reference section from STATUS.md. Checks for version updates. Reports any gaps or issues. Confirms you can resume exactly where you left off.

### Quality & Sharing Commands

#### `/code-review`
**Run when quality matters**

Comprehensive code audit with NO changes during review. Identifies issues and suggests improvements in a separate session. Takes its time to be thorough.

#### `/validate-context`
**Run to check documentation health**

Validates all context files follow expected structure. Checks staleness with visual indicators (🟢🟡🔴). Flags missing sections, unfilled placeholders, and configuration issues. Reports health score and actionable recommendations.

#### `/export-context`
**Run to share or backup**

Combines all context documentation into single markdown file with table of contents. Perfect for team handoffs, backups, or offline reference.

### Update Commands

#### `/update-context-system`
**Run periodically to get latest improvements**

Updates slash commands and configuration from GitHub. Ensures you have the latest commands and features. Interactive mode with version detection.

#### `/update-templates`
**Compare and update context files with latest templates**

Shows visual diffs between your context files and latest templates. Interactive file-by-file updates with automatic backups. Robust path resolution (works with any installation method). Perfect for adopting template improvements after system updates.

## Choosing Your Setup Command

### Use `/init-context` when:
- ✅ Starting a brand new project
- ✅ Project has basic setup (package.json) but no docs yet
- ✅ No existing CLAUDE.md or context documentation
- ✅ You want Claude to create everything from scratch

### Use `/migrate-context` when:
- ✅ Project already has documentation (CLAUDE.md, PRD.md, etc.)
- ✅ Docs are scattered in root directory or old structure
- ✅ You have artifacts (lighthouse reports, code reviews) to organize
- ✅ Want to preserve ALL existing content while adopting the system

**Examples:**
- `npx create-next-app` → Use `/init-context`
- Mature project with CLAUDE.md in root → Use `/migrate-context`
- Fresh clone with no docs → Use `/init-context`
- Project with tasks/ folder and multiple docs → Use `/migrate-context`

## Documentation Files

### CONTEXT.md - Orientation (Rarely Changes)
**Who, what, how, why.** Includes:
- Tech stack and architecture
- Communication preferences
- Anti-patterns to avoid
- Commands and setup
- References other files (no duplication)

**For AI agents:** Project overview, constraints, preferences

### STATUS.md - Current State (Frequently Updated)
**Single source of truth for "what's happening now."** Includes:
- **Auto-generated Quick Reference section at top** (project overview, tech stack, URLs)
- Current phase/focus
- Active tasks (checkboxes)
- Blockers and recent decisions
- Next session start point
- Updated by every `/save` and `/save-full`

**For AI agents:** Current work state, immediate priorities, blockers, fast orientation

### DECISIONS.md - Decision Log (Critical for AI Review)
**WHY choices were made.** Includes:
- Technical decisions and rationale
- Alternatives considered
- Constraints and tradeoffs
- When to reconsider
- Append-only decision history

**For AI agents:** Understand WHY, not just WHAT. Critical for reviews and takeover.

### SESSIONS.md - History (Structured, Comprehensive)
**What happened when.** Includes:
- **Mandatory TL;DR** (2-3 sentence summary) for quick scanning
- Structured entries (scannable but comprehensive)
- What changed, decisions, files, mental models
- **Auto-logged git operations** (commits, pushes for audit trail)
- Problem-solving approaches
- Enough depth for AI understanding
- Append-only

**For AI agents:** Learn from problem-solving patterns, understand evolution, see thinking process, review decision history

### Optional Files (Created On-Demand)

**CODE_MAP.md** - File structure and navigation (when >20 files, multiple directories)

**PRD.md** - Product vision and roadmap (when scope is complex)

**ARCHITECTURE.md** - System design details (when architecture is complex)

## Workflow Integration

This system is built around solid workflow principles:

### Core Methodology
1. Plan first, execute second
2. Track all progress
3. Make simplest possible changes
4. Never use temporary fixes
5. Find and fix root causes
6. Trace entire code flows
7. Test before committing
8. Never push without approval

### Communication Style
- High-level summaries only
- Direct, concise responses
- Clear approval checkpoints
- No verbose explanations

These are embedded in CODE_STYLE.md and enforced automatically.

## File Organization

```
claude-context-system/
├── README.md                   # This file
├── PRD.md                      # System requirements
├── SETUP_GUIDE.md              # How to install and use
├── STRUCTURE.md                # Complete file organization guide
├── .claude/
│   ├── commands/               # Custom slash commands (12 total)
│   │   ├── init-context.md
│   │   ├── migrate-context.md
│   │   ├── save.md
│   │   ├── save-full.md
│   │   ├── save-context.md
│   │   ├── review-context.md
│   │   ├── code-review.md
│   │   ├── validate-context.md
│   │   ├── export-context.md
│   │   ├── update-context-system.md
│   │   ├── update-templates.md
│   │   ├── add-ai-header.md
│   │   └── session-summary.md
│   ├── docs/                   # Comprehensive command guides
│   │   ├── README.md
│   │   ├── command-philosophy.md
│   │   ├── code-review-guide.md
│   │   ├── save-context-guide.md
│   │   ├── review-context-guide.md
│   │   ├── update-guide.md
│   │   └── usage-examples.md
│   └── checklists/             # Specialized review criteria
│       ├── accessibility.md
│       ├── security.md
│       ├── seo-review.md
│       └── performance.md
├── templates/                  # Doc templates
│   ├── claude.md.template
│   ├── cursor.md.template
│   ├── aider.md.template
│   ├── codex.md.template
│   ├── generic-ai-header.template.md
│   ├── CONTEXT.template.md
│   ├── STATUS.template.md
│   ├── DECISIONS.template.md
│   ├── SESSIONS.template.md
│   ├── CODE_MAP.template.md
│   ├── PRD.template.md
│   └── ARCHITECTURE.template.md
└── config/
    ├── .context-config.template.json
    └── context-config-schema.json
```

## Typical Workflows

### New Project
```
1. Init project
2. /init-context
3. Start coding
4. /save (frequently)
5. /save-full (at session end)
```

### Existing Project Migration
```
1. Copy .claude/ and scripts/ to project
2. /migrate-context
3. Review migration report
4. /save-full
5. Continue working
```

### Daily Work
```
1. Open project
2. /review-context
3. Start coding
4. /save (frequently - 2-3 min quick updates)
5. /save-full (at end of session - 10-15 min comprehensive)
```

### Quality Check
```
1. /save-full
2. /validate-context (check docs health + staleness)
3. /code-review (thorough audit)
4. Review reports
5. Fix in new session
```

### Team Handoff
```
1. /save-full
2. /validate-context
3. /export-context
4. Share export file with team
```

## Success Metrics

This system is successful when:
> "I can end any session abruptly, start a new session days later, run /review-context, and continue exactly where I left off without any re-explanation or context loss."

## Configuration

Each project gets a `.context-config.json` with:
- Workflow preferences
- Documentation settings
- Command configuration
- Communication style

Customize per project or use global defaults.

## Requirements

- Claude Code
- Any project (language/framework agnostic)
- File system access for context/ folder

## Best Practices

1. **Save often** - Run `/save` frequently during active work (2-3 min quick updates)
2. **Full saves at boundaries** - Run `/save-full` at session end, before breaks (10-15 min comprehensive)
3. **Review at start** - Always `/review-context` when opening project
4. **Init immediately** - Run `/init-context` on all new projects
5. **Don't edit manually** - Let commands manage documentation
6. **Trust the system** - It captures more than you think

## Troubleshooting

**Commands not working or loading wrong versions?**
- ⚠️ **CRITICAL:** Check for multiple `.claude` directories
- Claude Code may be loading commands from a parent folder
- Run: `find .. -maxdepth 2 -name ".claude"`
- **Solution:** Only keep `.claude` in the actual project root
- Remove `.claude` from parent folders that aren't projects

**Context feels stale?**
- Run `/save` immediately
- Check STATUS.md for current state
- Check SESSIONS.md for last update

**Can't resume work?**
- Check STATUS.md for next steps
- Review SESSIONS.md last entry for WIP
- Check git status

**Commands missing after update?**
- Check if there's a parent `.claude` directory
- The update may have updated the wrong folder
- Verify: `ls .claude/commands` shows all 12 commands

See [SETUP_GUIDE.md](./SETUP_GUIDE.md) for detailed troubleshooting.

## Version

**Current Version:** 3.0.0
**Status:** Production Ready
**Last Updated:** 2025-10-22

See [What's New in v3.0.0](#-v300-released---rebrand-to-ai-context-system) at the top of this file.

### Previous Versions

#### What's New in v2.0.0

**Core Improvements: Promise → Delivery** - Real-world feedback from v1.9.0 revealed critical gaps between what we promised and what we delivered.

**Migration Status:** v2.0.0 includes new templates and file structure. Automated migration with dry-run/backup/rollback planned for v2.1. For now, follow [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md) for manual migration steps.

**The Issues Fixed (v2.0):**
- **Promised files now created**: STATUS.md, QUICK_REF.md, CONTEXT.md, DECISIONS.md, SESSIONS.md all generated by `/init-context`
- **Status duplication eliminated**: STATUS.md is now the single source of truth - other files reference it instead of duplicating
- **SESSIONS.md made scannable**: Structured format (Changed/Decisions/Files/Next) instead of prose - find info in seconds instead of scrolling 800 lines
- **Decision log added**: DECISIONS.md captures WHY with proper structure - critical for AI agent review
- **Commands handle missing files**: Graceful degradation instead of failures when optional docs don't exist
- **Two-tier workflow**: `/save` (2-3 min quick updates) vs `/save-full` (10-15 min comprehensive saves)

**Key Changes (v2.0):**
- **v2.0 file structure**: CONTEXT.md (orientation), STATUS.md (current), DECISIONS.md (why), SESSIONS.md (history), QUICK_REF.md (auto-gen)
- **Manual migration**: Follow [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md) to migrate from v1.x to v2.0
- **Template-based setup**: `/init-context` creates 5 core files from updated templates

**Planned for v2.1:**
- **Automated migration**: Dry-run mode, automatic backups, rollback mechanism
- **Decision ID auto-increment**: Auto-assigned IDs stored in .context-config.json
- **Metrics tracking**: `/save` duration logging for continuous improvement
- **Auto-calculation in QUICK_REF**: Progress % computed from STATUS.md checkboxes

**Philosophy:**
```
v1.9.0: Minimal overhead daily, rich docs occasionally
v2.0.0: Same philosophy, but actually DELIVERS on it
```

**Bottom line:** Same great two-tier workflow, but now the files we promise actually get created, status stays consistent, and nothing gets lost in migration.

### What's New in v1.8.0 (Previously)

**Dual Purpose: Developer Productivity + AI Agent Review** - Real-world feedback revealed a critical insight: this system isn't just for session continuity, it's for AI agents to review, improve, and take over your work.

**The Realization:**
- **During work:** TodoWrite >> Context docs for productivity
- **At save points:** Rich documentation for AI review and takeover
- **The value:** AI agents can understand WHY, review with full context, take over seamlessly

**Key Changes:**
- **Restored DECISIONS.md** - Critical for AI agents to understand rationale
- **Enhanced SESSIONS.md** - Structured BUT comprehensive (mental models + thinking)
- **3 core files** - CONTEXT.md (orientation), STATUS.md (current), DECISIONS.md (why)
- **Single source of truth** - No duplication, but comprehensive depth
- **Auto-generated dashboard** - QUICK_REF.md for fast orientation
- **Smart `/save-context`** - Captures TodoWrite + mental models for AI review
- **AI-optimized exports** - `/export-context` generates takeover-ready documentation

**Philosophy:**
```
v1.7.0: Start minimal → Grow naturally
v1.8.0: Minimal overhead during work → Rich documentation for AI review/takeover
```

**The sweet spot:** Low friction for you, rich context for AI agents.

## Contributing

This is a workflow system you can adapt to your needs. You're welcome to:
- Fork and adapt for your preferences
- Suggest improvements
- Share your adaptations

## License

Use freely for personal or commercial projects.

## Questions?

See:
- [SETUP_GUIDE.md](./SETUP_GUIDE.md) - Complete setup and usage
- [PRD.md](./PRD.md) - Full product requirements
- context/CLAUDE.md in any project - Project-specific guide

---

**Remember:** When in doubt, `/save`!
