# AI Context System

**Version 3.4.0** • [What's New](#-v340-released---code-review-actionability)

> **Externalize AI context. Enable human-AI collaboration. Perfect session continuity.**
>
> Built for all AI coding assistants. Optimized for Claude Code.

---

## 🎯 Core Purpose

The AI Context System externalizes AI reasoning into visible, structured documentation that serves four critical purposes:

### 1. **Session Continuity**
Never lose context between AI sessions. Pick up exactly where you left off—days, weeks, or months later—without re-explaining anything.

### 2. **Externalized AI Context**
Make AI thoughts, decisions, and mental models visible to humans. Turn invisible AI reasoning into tangible documentation that programmers can read, review, and reference.

### 3. **Human-AI Collaboration**
Enable programmers to work alongside AI agents with full visibility into the AI's thinking process, constraints, and decision rationale.

### 4. **AI-to-AI Collaboration**
Facilitate peer review, project handoffs, and collaborative development between different AI agents—with complete context preservation.

---

## 🎉 v3.4.0 Released - Code Review Actionability

**Major enhancement to `/code-review` based on real-world user feedback**

**New Features:**
- ✨ **Smart issue grouping** - 25 identical errors → 1 grouped task
- ✨ **Auto-TodoWrite generation** - 40+ findings → 7-10 actionable tasks (30 min → 30 sec)
- ✨ **KNOWN_ISSUES.md integration** - Critical issues persist across sessions
- ✨ **STATUS.md auto-update** - Review summary visible in project status
- ✨ **Review history tracking** - All reviews tracked in artifacts/code-reviews/INDEX.md
- ✨ **Automatic comparison** - Auto-detects and compares with previous reviews

**Impact:**
- Transforms reviews from "excellent analysis" to "immediately actionable"
- 30-60 minutes of manual work → automated in seconds
- Full context system integration
- Quality trends visible over time

**Full details:** [CHANGELOG.md](./CHANGELOG.md) • **Upgrade:** `/update-context-system`

---

## The Problem

AI reasoning is invisible. Context is lost between sessions. Decisions lack rationale. Humans can't review AI's thinking. New AI agents must reverse-engineer everything. Collaboration breaks down.

## The Solution

Externalize AI context into structured, visible documentation:

- **`/init-context`** or **`/migrate-context`** - One-time setup
- **`/save`** (2-3 min) - Quick updates during work
- **`/save-full`** (10-15 min) - Comprehensive saves before breaks/handoffs
- **`/review-context`** - Verify continuity at session start

Everything AI thinks gets documented. No hidden context. Perfect session continuity. Full visibility for humans and AI agents.

---

## 🤖 Multi-AI Support

### Built for All AI Coding Assistants

**Universal concepts work everywhere:**
- File structure (`context/`, `SESSIONS.md`, `STATUS.md`, etc.)
- Documentation philosophy (externalize reasoning)
- Mental model capture
- Decision rationale
- Session continuity

**Supported AI tools:**
- Claude Code
- Cursor
- Aider
- GitHub Codex
- Any AI assistant with file system access

### Optimized for Claude Code

**Claude-specific features:**
- **Slash commands** - `/save`, `/save-full`, `/init-context`, etc. (14 commands)
- **TodoWrite integration** - Automatic capture of task state
- **Interactive workflows** - Approval checkpoints, validation prompts
- **Command system** - Structured `.claude/commands/` architecture

**Other AI tools:**
- Can use the file structure and templates manually
- Can reference `cursor.md`, `aider.md`, etc. (tool-specific headers)
- Full access to externalized context
- Manual workflow (no slash commands)

**Why Claude-optimized?**
This system was built using Claude Code through extensive dogfooding. The slash command system provides the best UX, but the core value—externalized context—works with any AI tool.

---

## Quick Start

### Option 1: One-Command Install (Recommended)

```bash
# Install from GitHub (downloads to current directory)
curl -sL https://raw.githubusercontent.com/rexkirshner/ai-context-system/main/install.sh | bash

# Initialize context
/init-context

# Daily workflow
/save          # Quick update (2-3 min) - most sessions
/save-full     # Comprehensive (10-15 min) - before breaks/handoffs
```

### Option 2: Manual Install

```bash
# 1. Clone the repo
git clone https://github.com/rexkirshner/ai-context-system.git

# 2. Copy toolkit to your project
cp -r ai-context-system/.claude /path/to/your/project/
cp -r ai-context-system/scripts /path/to/your/project/
cp -r ai-context-system/templates /path/to/your/project/

# 3. In Claude Code, initialize
/init-context

# 4. Clean up (optional)
rm -rf ai-context-system
```

**Try it now!** See [SETUP_GUIDE.md](./SETUP_GUIDE.md) for complete instructions.

---

## What Gets Created

**Core documentation** (`/init-context`):
```
your-project/
├── .claude/                        # Claude Code commands (optional for other AIs)
│   ├── commands/                   # 14 slash commands
│   ├── docs/                       # Comprehensive guides
│   └── checklists/                 # Review criteria
├── scripts/
│   ├── save-full-helper.sh         # Session template generator
│   ├── update-quick-reference.sh   # Auto-generates Quick Reference
│   └── validate-context.sh         # Documentation health check
├── context/                        # ← EXTERNALIZED AI CONTEXT (visible to humans)
│   ├── .context-config.json        # Project configuration
│   ├── claude.md                   # Claude Code entry point (7-line header)
│   ├── cursor.md                   # Cursor entry point (optional)
│   ├── aider.md                    # Aider entry point (optional)
│   ├── CONTEXT.md                  # Orientation (who/what/how/why)
│   ├── STATUS.md                   # Current state + auto-generated Quick Reference
│   ├── DECISIONS.md                # Decision log (WHY choices were made)
│   └── SESSIONS.md                 # History (AI mental models + reasoning)
└── artifacts/                      # Generated outputs
    ├── code-reviews/               # AI peer reviews
    ├── exports/                    # Context exports for handoffs
    └── [other analysis outputs]
```

**Everything in `context/` is externalized AI reasoning**—visible to programmers, reviewable by humans, shareable across AI agents.

**Additional files created on-demand:**
- `CODE_MAP.md` → Project complexity increases (>20 files)
- `PRD.md` → Product vision becomes complex
- `ARCHITECTURE.md` → System design needs comprehensive documentation

---

## Key Features

### 1. Session Continuity
- **Zero context loss** - Resume exactly where you left off
- **Work-in-progress preservation** - Precise state capture with mental models
- **Structured history** - SESSIONS.md tracks every session's evolution
- **Quick Reference** - Auto-generated dashboard in STATUS.md

### 2. Externalized AI Context
- **Visible reasoning** - AI decisions externalized to DECISIONS.md
- **Mental models captured** - AI's current understanding documented
- **Constraints visible** - Project limitations and tradeoffs documented
- **Thought process preserved** - How AI approached problems, not just solutions

### 3. Human-AI Collaboration
- **Full visibility** - Programmers can read AI's reasoning
- **Reviewable decisions** - Humans can verify AI understood constraints
- **Course-correction enabled** - See when AI misunderstood, adjust quickly
- **Shared mental models** - Human and AI aligned on project understanding

### 4. AI-to-AI Collaboration
- **Peer review** - `/code-review` with full context understanding
- **Seamless handoffs** - `/export-context` packages everything for new AI
- **Cross-tool compatibility** - Works across Claude, Cursor, Aider, etc.
- **Preserved rationale** - New AI understands WHY, not just WHAT

### Additional Capabilities
- **Single source of truth** - No duplication, everything in one place
- **Smart save commands** - `/save` (quick) vs `/save-full` (comprehensive)
- **Auto-generated Quick Reference** - Extracted from config + current state
- **Git operation audit trail** - Auto-logged commits/pushes in SESSIONS.md
- **Validation tools** - Check documentation health and staleness

---

## Core Commands

**Note:** These commands are universal and work with any AI coding assistant. They're organized in `.claude/commands/` following Claude Code's slash command paradigm, but the workflows themselves are generalizable. Future versions will provide native support for other AI tools (Cursor, Aider, etc.). For now, other AI assistants can reference these command files directly to follow the same workflows.

### Setup Commands (Run Once)

#### `/init-context`
Creates 5 core files: claude.md, CONTEXT.md, STATUS.md (with auto-generated Quick Reference), DECISIONS.md, SESSIONS.md. Optional files suggested when complexity demands. **Start simple, grow naturally.**

#### `/migrate-context`
Migrates existing documentation to AI Context System structure. Preserves ALL existing content while organizing into context/ folder. Consolidates to single source of truth.

### Maintenance Commands (Run Frequently)

#### `/save`
**Quick save - run often (2-3 min)**

Updates STATUS.md with auto-generated Quick Reference. Captures current tasks, blockers, next steps. Your safety net for session continuity.

#### `/save-full`
**Comprehensive save - run before breaks (10-15 min)**

Everything /save does + SESSIONS.md entry with mental models and decision rationale. Auto-logs git operations. **Essential for AI-to-AI handoffs.**

#### `/review-context`
**Run at session start**

Verifies documentation is current and accurate. Shows Quick Reference. Checks for version updates. Confirms you can resume exactly where you left off.

### Collaboration Commands

#### `/code-review`
**AI peer review with full context**

Comprehensive code audit leveraging DECISIONS.md, SESSIONS.md, and STATUS.md for context-aware review. Identifies issues with understanding of constraints and rationale.

#### `/export-context`
**Package for AI-to-AI handoffs**

Combines all context documentation into single markdown file. Perfect for project handoffs to new AI agents, team members, or cross-tool transitions.

#### `/validate-context`
**Check documentation health**

Validates all context files follow expected structure. Reports staleness (🟢🟡🔴), missing sections, and health score. Ensures context is ready for collaboration.

### Update Commands

#### `/update-context-system`
Updates slash commands and scripts from GitHub. Ensures you have latest features and fixes.

#### `/update-templates`
Compare your context files with latest templates. Interactive updates with visual diffs and automatic backups.

---

## Documentation Files

### CONTEXT.md - Orientation
**Who, what, how, why.** Includes tech stack, architecture, communication preferences, anti-patterns. References other files instead of duplicating.

**Purpose:** Project overview for any AI agent or human taking over.

### STATUS.md - Current State
**Single source of truth for "what's happening now."** Includes auto-generated Quick Reference (project overview, URLs, tech stack), current phase, active tasks, blockers, next session start point.

**Purpose:** Fast orientation for session continuity and handoffs.

### DECISIONS.md - Decision Log (Critical for AI Collaboration)
**WHY choices were made.** Includes technical decisions with rationale, alternatives considered, constraints and tradeoffs, when to reconsider.

**Purpose:** Enable AI agents to understand reasoning, not just code. **Critical for peer review and takeovers.**

### SESSIONS.md - History
**What happened when.** Includes mandatory TL;DR, structured entries, what changed, decisions, files, **AI mental models**, problem-solving approaches, auto-logged git operations.

**Purpose:** AI agents learn from problem-solving patterns, understand evolution, review decision history. **Externalized AI reasoning visible to humans.**

---

## Typical Workflows

### New Project
```
1. Install AI Context System
2. /init-context
3. Start coding
4. /save (frequently)
5. /save-full (at session end)
```

### AI-to-AI Handoff
```
1. /save-full (capture current mental model)
2. /validate-context (ensure completeness)
3. /export-context (package everything)
4. Share export with new AI agent
5. New AI reads context/ folder for full understanding
```

### Human Review of AI Work
```
1. Open context/DECISIONS.md (see WHY AI made choices)
2. Check SESSIONS.md (see AI's reasoning process)
3. Review STATUS.md (understand current state)
4. Verify AI understood project constraints
```

### Daily Work (Session Continuity)
```
1. Open project
2. /review-context (see Quick Reference + verify continuity)
3. Start coding
4. /save (frequently - 2-3 min quick updates)
5. /save-full (at end of session - 10-15 min comprehensive)
```

### AI Peer Review
```
1. /save-full (ensure context is current)
2. /code-review (AI reviews with full context)
3. Review artifacts/code-reviews/ output
4. Address issues in new session
```

---

## Success Metrics

This system is successful when:

**Session Continuity:**
> "I can end any session abruptly, start days later, run /review-context, and continue exactly where I left off."

**Externalized Context:**
> "I can read DECISIONS.md and SESSIONS.md and understand exactly what the AI was thinking and why."

**Human-AI Collaboration:**
> "I can verify the AI understood my constraints by reading its documented reasoning."

**AI-to-AI Collaboration:**
> "A new AI agent can read context/ and understand the entire project history, decisions, and current mental model."

---

## Configuration

Each project gets a `.context-config.json` with:
- Workflow preferences
- Documentation settings
- Command configuration
- Communication style
- Project type (single-repo, meta-project, etc.)

Customize per project or use defaults. Full schema: `config/context-config-schema.json`

---

## Requirements

**For Claude Code users (full features):**
- Claude Code CLI
- File system access

**For other AI tools (manual workflow):**
- Any AI coding assistant with file system access
- Manual use of templates and file structure
- Reference appropriate tool header (cursor.md, aider.md, etc.)

**Universal:**
- Any project (language/framework agnostic)
- Git recommended (but not required - works with timestamp-based detection)

---

## Best Practices

1. **Externalize everything** - AI thoughts, decisions, mental models → visible documentation
2. **Save often** - Run `/save` frequently (2-3 min quick updates)
3. **Full saves at boundaries** - Run `/save-full` before breaks, handoffs (10-15 min)
4. **Review at start** - Always `/review-context` when opening project
5. **Validate before handoffs** - Run `/validate-context` before AI-to-AI transitions
6. **Read the externalized context** - DECISIONS.md and SESSIONS.md show AI reasoning
7. **Trust the system** - It captures more AI context than you think

---

## Troubleshooting

**Commands not working?**
- ⚠️ **CRITICAL:** Check for multiple `.claude` directories
- Claude Code may be loading commands from a parent folder
- **Solution:** Only keep `.claude` in the actual project root
- Exception: Meta-projects intentionally have multiple `.claude` dirs

**Context feels stale?**
- Run `/save` immediately
- Check STATUS.md Quick Reference for overview
- Check SESSIONS.md for last update

**Can't resume work?**
- Run `/review-context` to see Quick Reference
- Check STATUS.md → Work In Progress section
- Check SESSIONS.md last entry for mental model

See [SETUP_GUIDE.md](./SETUP_GUIDE.md) for detailed troubleshooting.

---

## Version

**Current Version:** 3.2.2
**Status:** Production Ready
**Last Updated:** 2025-10-23

**What's New in v3.2.2:**
- Fixed critical installer bug blocking all upgrades (save-context.md 404)
- Fixed version detection showing blank
- Fixed misleading error messages in non-interactive mode
- Installer now works reliably with --yes flag

**See:** [CHANGELOG.md](./CHANGELOG.md) for complete version history

---

## Contributing

This system externalizes AI reasoning—making it visible, reviewable, and shareable. You're welcome to:
- Fork and adapt for your workflow
- Suggest improvements via issues
- Share your adaptations
- Contribute templates for other AI tools

---

## License

Use freely for personal or commercial projects.

---

## Try It Now!

**One-command install:**
```bash
curl -sL https://raw.githubusercontent.com/rexkirshner/ai-context-system/main/install.sh | bash
```

Then:
```bash
/init-context    # Create your context structure
/save           # Experience session continuity
```

**See also:**
- [SETUP_GUIDE.md](./SETUP_GUIDE.md) - Complete installation and usage
- [CHANGELOG.md](./CHANGELOG.md) - Version history
- [MIGRATION_GUIDE_v2_to_v3.md](./MIGRATION_GUIDE_v2_to_v3.md) - Migration from v2.x

---

**Remember:** When in doubt, `/save`!

**Your AI's thoughts are valuable. Externalize them.**
