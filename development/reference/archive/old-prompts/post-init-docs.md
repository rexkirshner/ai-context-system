# Post-Init Documentation Scaffold

**Purpose:** Run this prompt immediately after `/init` to create comprehensive meta-documentation for effective cross-session collaboration.

**When to use:** Right after initializing a new project with Claude Code.

---

## Prompt

Please create a comprehensive documentation suite for this project that will help you (and future Claude instances) maintain context across sessions. Based on the current project structure and package.json, create the following files:

### 1. CLAUDE.md - Developer Guide
Create a developer-focused guide that includes:

**Project Overview:**
- Brief description of what this project does
- Key technologies and frameworks
- Links to important external resources

**Commands:**
- List all npm scripts with descriptions
- Key development commands
- Build/deployment commands
- Testing commands

**Architecture:**
- High-level architecture overview
- Key directories and their purposes
- Important patterns and conventions
- File structure explanation

**Development Status:**
- Current phase/milestone
- What's complete vs. in progress
- Known limitations

**Important Notes:**
- Any special considerations
- Environment variables needed
- Dependencies or external services

**Critical Path:**
- Current status summary
- Recent accomplishments
- Next steps

### 2. PRD.md - Product Requirements Document
Create a product-focused document that includes:

**Executive Summary:**
- What problem does this solve?
- Who is it for?
- What's the vision?

**Current Status:**
- Version number
- Phase/milestone
- Launch readiness

**Tech Stack:**
- Framework and version
- Key dependencies
- Why these choices?

**Implementation Plan:**
- Phases/milestones
- Timeline (if applicable)
- Success criteria

**Progress Log:**
- Session-by-session updates
- What was accomplished when

**Future Roadmap:**
- Post-launch features
- Nice-to-haves
- Deferred items

### 3. DECISIONS.md - Technical Decisions
Document why specific technical choices were made:

**Framework & Core Stack:**
- Why this framework?
- Why these dependencies?
- Trade-offs considered

**Architecture Patterns:**
- Why this architecture?
- Alternatives considered
- When to reconsider

**Key Technical Decisions:**
- For each major decision:
  - What was decided
  - Why it was decided
  - Trade-offs
  - When to reconsider

**Decision Review Process:**
- How to evaluate if decisions need revisiting

### 4. KNOWN_ISSUES.md - Issues & Limitations
Track current state honestly:

**Blocking Issues:**
- Critical bugs preventing deployment/use

**Non-Critical Issues:**
- Warnings that don't block
- Minor annoyances
- Technical debt

**Limitations by Design:**
- What doesn't work (and why that's OK)
- Trade-offs made intentionally

**Future Improvements:**
- Technical debt to address
- Performance optimizations
- Missing features

**Edge Cases:**
- Scenarios to monitor
- Potential future issues

### 5. tasks/next-steps.md - Action Hub
Create a living document for "what's next":

**Ready to Do Now:**
- Immediate next actions
- What's unblocked

**Pending/Blocked:**
- What's waiting on something
- Dependencies

**Future Work:**
- Nice-to-haves
- Post-launch items

**Maintenance Tasks:**
- Regular upkeep needed
- How to handle common updates

**Success Metrics:**
- What to track
- How to measure success

---

## Instructions

1. **Analyze the current project:**
   - Read package.json to understand the stack
   - Scan the directory structure
   - Identify the project type (web app, CLI, library, etc.)

2. **Create all 5 files** with appropriate content for THIS specific project

3. **Use templates but customize:**
   - Don't just copy generic content
   - Fill in actual technologies, frameworks, and decisions from this project
   - If information isn't clear, use placeholders like `[TODO: Describe...]`

4. **Keep it concise:**
   - Each file should be scannable in 5 minutes
   - Use bullet points and headings
   - Link between documents where appropriate

5. **Think forward:**
   - What would a future Claude instance need to know?
   - What decisions need context?
   - What's the current state vs. future plans?

---

## Success Criteria

After running this prompt, you should have:

- ✅ All 5 documentation files created
- ✅ Each file has real content (not just templates)
- ✅ A new Claude instance could read these and be productive
- ✅ The "why" behind decisions is documented
- ✅ Current status is clear
- ✅ Next steps are actionable

---

## Example Output Structure

```
project-root/
├── CLAUDE.md              # Developer guide
├── PRD.md                 # Product requirements
├── DECISIONS.md           # Technical decisions
├── KNOWN_ISSUES.md        # Current limitations
└── tasks/
    └── next-steps.md      # Action hub
```

---

## Notes

- These docs should evolve with the project
- Update them regularly (use `/update-docs` command)
- They're living documents, not write-once artifacts
- Better to have incomplete docs than no docs
- You can always refine later

---

## Related Commands

After creating these docs, you can use:
- `/update-docs` - Sync docs with current code state
- `/review-docs` - Audit documentation completeness
