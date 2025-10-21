# PRD: Claude Context System

## Executive Summary

**Product Name:** Claude Context System
**Version:** 1.9.0
**Owner:** Rex Kirshner
**Status:** Active Development
**Last Updated:** 2025-10-06

### What Changed in v1.9.0

**Real-world AI agent feedback** identified the core problem:
> "How often do you actually lose context vs. how often do you update docs?"

**The Frequency Mismatch:**
- Update docs: 20× (every session)
- Recover context: 3-4× (occasional breaks)
- Overhead/benefit ratio: 5:1 (unfavorable)
- Result: Negative ROI (pay 100-200 min, save 12-20 min)

**v1.9.0 Response: Two-Tier Workflow**
- **Most sessions:** `/save` quick update (2-3 min)
  - Updates STATUS.md + Quick Reference section (in STATUS.md)
  - Minimal overhead, continuous work
- **Occasional:** `/save-full` comprehensive (10-15 min)
  - Creates SESSIONS.md entry
  - Documents mental models and rationale
  - Use 3-5× per 20 sessions (before breaks/handoffs)
- **Result:** 50-60% reduction in overhead (100-200 min → 70-95 min)

**Philosophy:** Align cost with value - minimal overhead for common case, comprehensive documentation only when needed.

### What Changed in v1.8.0

**Real-world feedback** revealed we were solving the wrong problem:
- ✅ Session continuity worked (recovery from context loss)
- ❌ Within-session overhead too high
- ❌ TodoWrite > Context docs during active work
- ❌ Duplication: same info in 3 places (CLAUDE.md, next-steps.md, SESSIONS.md)
- ❌ SESSIONS.md too verbose (190+ lines, exhausting to write/read)

**v1.8.0 Response: Dual Purpose Philosophy**
- **Within sessions:** TodoWrite for productivity
- **At save points:** Rich documentation for AI agents
- **3 core files:** CONTEXT.md + STATUS.md + DECISIONS.md
- **Single source of truth:** No duplication
- **Structured SESSIONS.md:** 40-60 lines with mental models
- **Smart `/save-context`:** Captures TodoWrite, updates what changed

### Problem Statement

**For Session Continuity:**
When working with Claude Code across multiple sessions, critical context is lost including:
- Current work state and progress
- Technical decisions and rationale
- User-specific preferences and workflows
- Project architecture understanding
- Known issues and limitations
- Work history and session logs

This leads to:
- Repeated explanations of project state
- Lost work when sessions end unexpectedly
- Inconsistent approaches between sessions
- Time wasted re-establishing context
- Risk of contradicting previous decisions

**For AI Agent Review & Takeover:**
When AI agents need to review or take over development:
- Code lacks context about WHY decisions were made
- Constraints and tradeoffs aren't documented
- Mental models and problem-solving approaches are invisible
- Alternative approaches considered are lost
- Handoffs require reverse-engineering the developer's thinking
- Reviews lack depth without understanding rationale

This leads to:
- Superficial code reviews missing critical context
- AI agents suggesting already-rejected alternatives
- Loss of institutional knowledge during handoffs
- Inability for AI to continue work seamlessly
- Poor architectural review without understanding constraints

### Solution

A dual-purpose documentation system that:

**For Session Continuity:**
- Preserves complete project state between sessions
- Maintains structured documentation automatically
- Enables seamless session recovery
- Enforces consistent workflows and preferences
- Tracks all work history and decisions

**For AI Agent Review & Takeover:**
- Captures mental models and problem-solving approaches
- Documents decision rationale with alternatives considered
- Preserves constraints and tradeoffs
- Provides comprehensive context for code review
- Enables AI agents to understand WHY, not just WHAT
- Facilitates seamless handoff to other AI agents or developers

**Key Insight:**
The system minimizes overhead during active development (TodoWrite for productivity) while capturing rich documentation at save points for AI agent consumption.

---

## User Personas

### Primary User: Rex (Power Developer)
- Works on multiple complex projects simultaneously
- Has specific workflow preferences (no lazy coding, simplicity first)
- Needs perfect session continuity
- Values efficiency and hates repetition
- Requires high trust in AI maintaining context
- **Wants AI agents to review and improve his work**
- **Needs AI agents that can take over development when needed**

### Secondary User: AI Agent (Reviewer/Takeover Agent)
- Needs to understand WHY decisions were made, not just WHAT code exists
- Must learn from developer's problem-solving approaches
- Requires context about constraints and tradeoffs
- Needs to avoid suggesting already-rejected alternatives
- Should provide meaningful code reviews with full context
- Must be able to seamlessly continue development
- Consumes DECISIONS.md, SESSIONS.md, and mental models

### Tertiary Users: Other Claude Code Users
- May adapt system for their own preferences
- Need customizable workflows
- Want session continuity but with different styles
- May use for AI agent review and collaboration

---

## Core Requirements

### Functional Requirements

#### 1. Command System

The system provides **nine slash commands** available in every project:

**Setup Commands (run once):**

**`/init-context`** (v1.8.0+)
- Creates **3 core files:** CONTEXT.md + STATUS.md + DECISIONS.md
- Auto-generates Quick Reference section (in STATUS.md) dashboard
- Analyzes existing project
- Creates configuration file
- Suggests optional files (PRD, ARCHITECTURE) when complexity demands
- DECISIONS.md critical for AI agent understanding

**`/migrate-context`**
- Migrates existing projects with documentation
- Consolidates to single source of truth
- Eliminates duplication
- Organizes into context/ and artifacts/ folders
- Preserves all existing content

**Maintenance Commands (run frequently):**

**`/save-context`** (Dual Purpose - v1.8.0+)
- **Captures TodoWrite state automatically**
- **Extracts mental models and decision rationale for AI agents**
- Updates STATUS.md (always)
- Appends structured, comprehensive entry to SESSIONS.md (40-60 lines)
- Updates DECISIONS.md when significant decisions made
- Auto-generates Quick Reference section (in STATUS.md) dashboard
- Suggests optional files when complexity demands
- Use `--full` flag for comprehensive AI review preparation
- **Low overhead for developer, rich context for AI agents**

**`/review-context`**
- Verifies documentation accuracy
- Checks for inconsistencies
- Confirms session continuity
- Reports gaps or issues
- Run at session start

**Quality & Sharing Commands:**

**`/code-review`**
- Comprehensive code quality audit
- NO changes during review
- Generates detailed report
- Suggests improvements separately
- Run when quality matters

**`/validate-context`**
- Validates documentation structure
- Flags missing sections and placeholders
- Reports health score
- Run to check documentation health

**`/export-context`**
- Combines all context docs into single file
- Generates table of contents
- Perfect for team handoffs or backups

**Update Commands:**

**`/update-context-system`**
- Updates slash commands from GitHub
- Optionally updates context file templates
- Interactive or automatic mode
- Run periodically for latest improvements

#### 2. Documentation System

**Core Files (in context/ folder):**

| File | Purpose | Updated | Philosophy | For AI Agents |
|------|---------|---------|------------|---------------|
| CONTEXT.md | Orientation (who/what/how/why) | Rarely | Rarely changes | Project overview, constraints |
| STATUS.md | Current state (tasks/blockers/next) | Every session | Single source of truth | Current work state |
| DECISIONS.md | Decision log (WHY choices made) | When decisions made | Append-only | Critical - understand rationale |
| SESSIONS.md | History (structured, comprehensive) | Every session | Append-only | Mental models, problem-solving |
| Quick Reference section (in STATUS.md) | Dashboard (auto-generated) | Auto | Generated from STATUS.md | Fast orientation |

**Optional Files (created on-demand):**

| File | Purpose | When to Create | For AI Agents |
|------|---------|----------------|---------------|
| PRD.md | Product vision & roadmap | When scope gets complex | Product context |
| ARCHITECTURE.md | System design details | When architecture gets complex | Design decisions |

**Key Principles:**
- Single source of truth - each piece of information lives in ONE place
- Structured but comprehensive - AI agents need depth to understand WHY
- Mental models captured - AI learns from your thinking process

#### 3. Configuration System

**.context-config.json** stores:
- User preferences (workflow, communication style)
- Documentation settings (location, frequency)
- Command configuration (enabled commands, aliases)
- Template preferences

#### 4. Workflow Enforcement

System enforces Rex's core principles:
- Never push to GitHub without explicit approval
- Always find root causes, no temporary fixes
- Make simplest possible changes
- Test before committing
- Provide high-level summaries only
- Trace entire code flow when debugging

### Non-Functional Requirements

#### Performance
- Commands execute in <5 seconds
- Documentation updates are incremental
- No noticeable IDE slowdown

#### Reliability
- Never lose context data
- Handle interrupted sessions gracefully
- Recover from partial updates

#### Usability
- Zero learning curve for basic use
- Clear command outputs
- Intuitive folder structure
- Self-documenting system

#### Compatibility
- Works with any project type
- Language/framework agnostic
- Git-friendly (can be tracked or ignored)
- Works across all Claude Code sessions

---

## Technical Specifications

### File Structure

```
project-root/
├── context/                      # All context docs
│   ├── .context-config.json     # Configuration
│   ├── CLAUDE.md                # Developer guide
│   ├── PRD.md                   # Product specs
│   ├── ARCHITECTURE.md          # Technical design
│   ├── DECISIONS.md             # Decision log
│   ├── CODE_STYLE.md            # Coding standards
│   ├── KNOWN_ISSUES.md          # Issue tracking
│   ├── SESSIONS.md              # Session history
│   ├── tasks/
│   │   ├── next-steps.md        # Action items
│   │   └── todo.md              # Current tasks
│   └── reviews/
│       └── [session]-review.md  # Review results
```

### Command Behavior

**Init Sequence:**
1. Check if context/ exists
2. Create folder structure
3. Generate all template files
4. Analyze project (package.json, file structure)
5. Fill in known information
6. Create configuration file
7. Report completion status

**Save Sequence:**
1. Verify context/ exists (create if not)
2. Analyze current state vs documented state
3. Update each documentation file
4. Add session log entry
5. Capture work-in-progress
6. Report what was updated

**Review Sequence:**
1. Load all documentation
2. Check internal consistency
3. Verify against current code
4. Assess completeness
5. Report confidence level for continuity

**Code Review Sequence:**
1. Analyze code without making changes
2. Check against CODE_STYLE.md
3. Identify issues and improvements
4. Generate detailed report
5. Save report to reviews/ folder

---

## Success Metrics

### Quantitative Metrics
- **Session Continuity Rate:** >95% successful context reload
- **Context Capture Time:** <30 seconds per save
- **Documentation Coverage:** 100% of required files maintained
- **Command Success Rate:** >99% successful execution

### Qualitative Metrics
- User never needs to re-explain project state
- New sessions feel like continuations, not restarts
- Confidence in context preservation
- Zero lost work due to session ends

### Success Criteria
- [ ] All 4 commands work reliably
- [ ] Documentation stays synchronized with code
- [ ] Session handoff is seamless
- [ ] User preferences are consistently applied
- [ ] No manual context management needed

---

## Implementation Phases

### Phase 1: Core Infrastructure ⏳
- Create command definitions
- Build template system
- Implement /init-context
- Basic documentation generation

### Phase 2: Context Preservation
- Implement /save-context
- Session tracking
- Change detection
- State capture

### Phase 3: Validation & Review
- Implement /review-context
- Consistency checking
- Gap detection
- Confidence scoring

### Phase 4: Code Review System
- Implement /code-review
- Report generation
- Standards checking
- Improvement tracking

### Phase 5: Polish & Optimization
- Performance tuning
- Error handling
- Edge cases
- User feedback incorporation

---

## User Workflows

### New Project Start

```
1. Create/open project
2. Run /init-context
3. Review generated docs
4. Begin work
5. Run /save-context periodically
```

### Daily Development

```
1. Open project
2. Run /review-context
3. Continue from last state
4. Run /save-context during work
5. Run /save-context before ending
```

### Quality Check

```
1. Complete feature
2. Run /save-context
3. Run /code-review
4. Review report
5. Address issues in new session
```

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Context file corruption | High | Backup previous version before updates |
| Inconsistent updates | Medium | Validation checks in /review-context |
| Command failures | Medium | Graceful degradation, clear error messages |
| Documentation drift | Low | Frequent /save-context reminders |

---

## Future Enhancements

### V1.1
- Auto-save on timer
- Git hooks for context updates
- Context diff visualization

### V2.0
- Multi-user context sharing
- Context branching for experiments
- AI-powered context insights

### V3.0
- Cross-project context linking
- Context templates by project type
- Automated context pruning

---

## Success Statement

The Claude Context System is successful when:

> **"I can end any session abruptly, start a new session days later, run /review-context, and continue exactly where I left off without any re-explanation or context loss."**

---

## Appendix: Design Philosophy

### Core Principles

1. **Context is Sacred** - Never lose user context, ever
2. **Simplicity First** - Simple implementations over complex ones
3. **Progressive Enhancement** (v1.7.0+) - Start minimal, grow when needed
4. **No Surprises** - System behavior should be predictable
5. **Self-Documenting** - System explains itself
6. **Fail Safe** - Errors should never destroy context

### v1.8.0 Philosophy Shift

**What We Learned:**
Real-world usage revealed a critical insight we were missing:

**The Dual Purpose:**
1. **Session continuity** - Recover from context loss (what we built for)
2. **AI agent review/takeover** - Enable AI to understand, review, and take over work (what we missed!)

**User Feedback Analysis:**
- Session continuity worked ✅ (could recover from context loss)
- Within-session overhead too high ❌ (TodoWrite >> Context docs during active work)
- But the feedback was evaluating ONLY for continuity, missing the bigger picture
- **The system wasn't just for YOU - it's for AI AGENTS reviewing and taking over your work**

**The Key Insight:**
> "This system isn't just about session continuity. It's about creating rich documentation that enables AI agents to understand WHY you made decisions, review your work with full context, and seamlessly take over development."

**The Real Value:**
- AI code reviews need to understand constraints and tradeoffs
- AI agents taking over need mental models and rationale
- Future development needs decision history
- Comprehensive documentation enables introspection and improvement

**New Approach - Dual Purpose:**
- **Within sessions:** TodoWrite is the productivity tool (minimal overhead)
- **At save points:** Rich documentation for AI review/takeover (comprehensive depth)
- **3 core files:** CONTEXT.md (orientation) + STATUS.md (current state) + DECISIONS.md (WHY)
- **Structured BUT comprehensive:** SESSIONS.md has depth (40-60 lines with mental models)
- **Single source of truth:** No duplication, but comprehensive depth where needed
- **Smart `/save-context`:** Captures TodoWrite + mental models + decision rationale
- **Auto-dashboard:** Quick Reference section (in STATUS.md) for fast orientation

**The Shift:**
```
OLD (v1.7.0): "Start minimal → Grow naturally when complexity demands"
NEW (v1.8.0): "Minimal overhead during work → Rich context for AI review/takeover"
```

**The Sweet Spot:**
- Low friction for developer (TodoWrite during work)
- Rich context for AI agents (comprehensive saves)
- Enables AI to understand WHY, not just WHAT
- AI agents can review, improve, and take over seamlessly

**Validated By:**
Understanding that user feedback was evaluating ONLY for session continuity, missing the primary value: **enabling AI agents to understand your thinking and take over development with full context.**

### User Preferences Integration

The system is built around Rex's specific workflow needs:
- Root cause analysis over quick fixes
- Surgical code changes over broad refactors
- High-level communication over verbose explanations
- Explicit approval for risky operations
- Complete code flow tracing for debugging

These preferences are embedded into CODE_STYLE.md and enforced throughout the system.
