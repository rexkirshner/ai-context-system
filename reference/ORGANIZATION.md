# Project Organization Guidelines

**Philosophy:** "A place for everything, everything in its place"

**Version:** 3.0.0
**Purpose:** Maintain professional structure and reduce cognitive load through disciplined organization

---

## Core Principle: Active vs. Historical Files

The AI Context System enforces a clear distinction:

- **Active** - Currently needed, frequently updated → Keep accessible
- **Historical** - Completed work, old plans → Archive with dates
- **Permanent** - Long-term reference → Organize by topic

**Result:** Clean project structure that's easy to navigate and professional in appearance.

---

## The Standard Folder Structure

```
project-root/
├── README.md                   # Project overview (required)
├── SECURITY.md                 # Security policy (if applicable)
├── CONTRIBUTING.md             # Contribution guide (if applicable)
├── LICENSE.md                  # License (required)
├── CHANGELOG.md                # Version history (recommended)
│
├── context/                    # AI Context System (active)
│   ├── claude.md               # AI header (7-line redirect)
│   ├── CONTEXT.md              # Project orientation
│   ├── STATUS.md               # Current state
│   ├── SESSIONS.md             # Session history
│   ├── DECISIONS.md            # Decision log
│   └── .context-config.json    # Configuration
│
├── docs/                       # Permanent Documentation
│   ├── setup/
│   │   ├── installation.md
│   │   └── configuration.md
│   ├── development/
│   │   ├── local-environment.md
│   │   └── testing-guide.md
│   ├── architecture/
│   │   ├── system-overview.md
│   │   └── data-flow.md
│   └── api/
│       ├── endpoints.md
│       └── authentication.md
│
├── artifacts/                  # Historical Work Archive
│   ├── milestones/
│   │   ├── 2025-10-01-milestone-1-auth.md
│   │   └── 2025-11-15-milestone-2-api.md
│   ├── planning/
│   │   ├── 2025-09-initial-proposal.md
│   │   └── 2025-10-feature-roadmap.md
│   ├── reviews/
│   │   ├── 2025-10-15-security-audit.md
│   │   └── 2025-11-01-code-review.md
│   └── research/
│       ├── database-comparison.md
│       └── framework-evaluation.md
│
└── [source code directories]
    ├── src/
    ├── tests/
    └── ...
```

---

## Folder Rules

### Root Directory (Minimal)

**Only these files belong in root:**
- `README.md` - Project overview
- `SECURITY.md` - Security policy
- `CONTRIBUTING.md` - Contribution guidelines
- `LICENSE.md` - License
- `CHANGELOG.md` - Version history
- `ORGANIZATION.md` - This file

**Everything else goes in organized folders.**

**Why:** Clean root = professional appearance, easy to understand project at a glance.

---

### context/ - Active Context System

**Contents:**
- Platform-neutral documentation (CONTEXT.md, STATUS.md, etc.)
- AI headers (claude.md, cursor.md, etc.)
- Configuration (.context-config.json)

**Rules:**
- ✅ Only AI Context System files
- ❌ No project documentation here (use docs/)
- ❌ No historical files (use artifacts/)
- ❌ No random notes (file them properly)

**Why:** Keep context system isolated and focused on its purpose.

---

### docs/ - Permanent Documentation

**Purpose:** Long-term reference documentation organized by topic

**Organization:**
```
docs/
├── setup/          # Getting started, installation
├── development/    # Development workflows, testing
├── architecture/   # System design, diagrams
├── api/           # API documentation
├── deployment/    # Deployment guides
└── maintenance/   # Operational guides
```

**Rules:**
- ✅ Organize by topic, not by date
- ✅ Keep files updated (living documentation)
- ✅ Use clear, descriptive names
- ❌ No dated files (those go in artifacts/)
- ❌ No temporary notes

**When to use:** Documentation that will be referenced long-term.

---

### artifacts/ - Historical Work Archive

**Purpose:** Preserve completed work, old plans, and dated artifacts

**Organization:**
```
artifacts/
├── milestones/    # Completed milestones (dated)
├── planning/      # Old proposals, specs (dated)
├── reviews/       # Code reviews, audits (dated)
├── research/      # Comparisons, evaluations
└── notes/         # Meeting notes, brainstorms (dated)
```

**Naming Convention:** `YYYY-MM-DD-description.md`
- ✅ `2025-10-20-auth-milestone-complete.md`
- ✅ `2025-09-15-database-proposal.md`
- ❌ `milestone1.md`
- ❌ `old-plan.md`

**Rules:**
- ✅ Always include date
- ✅ Use descriptive names
- ✅ Never delete (history matters)
- ✅ Rarely update (historical record)
- ❌ No active planning here (use docs/ or context/)

**When to use:** Work is completed, proposal is superseded, or document is historical reference.

---

## Anti-Patterns to Avoid

### ❌ Documentation Sprawl

**Bad:**
```
root/
├── README.md
├── NOTES.md
├── IDEAS.md
├── RANDOM_THOUGHTS.md
├── TEMP.md
├── TODO.md
├── IMPLEMENTATION_PLAN.md
├── OLD_PLAN.md
├── FINAL_PLAN_REALLY.md
└── ...15 more random files
```

**Good:**
```
root/
├── README.md
├── LICENSE.md
├── docs/
│   └── planning/
│       └── implementation-strategy.md
└── artifacts/
    └── planning/
        ├── 2025-09-initial-proposal.md
        └── 2025-10-revised-approach.md
```

---

### ❌ Source Directory Documentation

**Bad:**
```
src/
├── backend/
│   ├── BACKEND_NOTES.md       # Wrong place!
│   ├── API_DESIGN.md          # Wrong place!
│   └── TODO.md                # Wrong place!
```

**Good:**
```
src/
├── backend/
│   └── [code only]
└── docs/
    ├── architecture/
    │   └── backend-design.md
    └── api/
        └── endpoints.md
```

**Why:** Source directories are for code. Documentation belongs in docs/.

---

### ❌ Unclear Historical Files

**Bad:**
```
root/
├── OLD_PLAN.md                # When? What milestone?
├── OLD_OLD_PLAN.md            # Very confusing!
├── FINAL_PLAN.md              # Is this current?
└── FINAL_PLAN_REAL.md         # Or is THIS current?
```

**Good:**
```
artifacts/planning/
├── 2025-09-01-initial-approach.md
├── 2025-09-15-revised-strategy.md
└── 2025-10-01-final-architecture.md

docs/architecture/
└── current-design.md          # This is the current one
```

---

## Naming Conventions

### Use ISO Dates for Historical Files

**Format:** `YYYY-MM-DD-description.md`

**Examples:**
- ✅ `2025-10-20-api-security-audit.md`
- ✅ `2025-11-01-milestone-2-complete.md`
- ❌ `oct-20-audit.md`
- ❌ `security-audit-10-20.md`

**Why:** ISO format sorts correctly, unambiguous, international standard.

---

### Use Descriptive Names

**Good:**
- ✅ `database-comparison-postgres-vs-mysql.md`
- ✅ `authentication-implementation-strategy.md`
- ✅ `user-feedback-analysis.md`

**Bad:**
- ❌ `db.md`
- ❌ `notes.md`
- ❌ `stuff.md`
- ❌ `temp.md`

**Why:** Clear names = easy to find, no guessing.

---

## Maintenance Schedule

### Daily (30 seconds)
- [ ] Keep root directory clean
- [ ] File completed work immediately
- [ ] No loose files accumulating

### Weekly (5 minutes)
- [ ] Review any loose files
- [ ] Move old plans to artifacts/planning/
- [ ] Archive completed milestones

### Monthly (15 minutes)
- [ ] Run `/organize-docs` command
- [ ] Review artifacts/ structure
- [ ] Clean up docs/ (remove outdated)
- [ ] Update ORGANIZATION status in STATUS.md

### Before Releases
- [ ] Full organization pass
- [ ] Ensure professional appearance
- [ ] Update README if structure changed
- [ ] Verify no sensitive files exposed

---

## AI Context System Integration

### Validation

**Run `/validate-context` to check organization:**
```bash
/validate-context

# Output includes:
Organization score: 85/100
⚠️ 3 loose files in project root
💡 Suggestion: Run /organize-docs
```

**Organization scoring:**
- 100: Perfect (≤ 5 files in root, all in right places)
- 90-99: Excellent (minor cleanup needed)
- 75-89: Good (some reorganization recommended)
- 60-74: Fair (needs attention)
- <60: Poor (run /organize-docs)

---

### Cleanup Command

**Run `/organize-docs` for interactive cleanup:**
```bash
/organize-docs

# Interactive wizard:
# 1. Scans for misplaced files
# 2. Suggests categorization
# 3. Guides filing process
# 4. Creates folder structure
```

**Use when:**
- Organization score < 90
- Monthly maintenance
- Before releases
- After major features
- Project feels cluttered

---

### Automatic Prompts

**`/save-full` includes organization reminder:**
```
🧹━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ORGANIZATION REMINDER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Detected 5 loose documentation files.

Good practice: File documentation in organized folders

Run: /organize-docs for guided cleanup
Skip: Say 'skip organization' to continue
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Frequency:** When loose files > 2 and running /save-full

---

## Quick Reference Commands

```bash
# Check organization status
/validate-context

# Interactive cleanup
/organize-docs

# Manual audit (quick check)
find . -maxdepth 1 -name "*.md" ! -name "README.md" ! -name "LICENSE.md"

# Count loose files
find . -maxdepth 1 -name "*.md" | wc -l
# Should be ≤ 5

# Check source directory docs (shouldn't exist)
find src -name "*.md"
```

---

## Philosophy: Why Organization Matters

### Reduces Cognitive Load
- Know exactly where to find things
- No "where did I put that file?" moments
- Clear mental model of project structure

### Professional Appearance
- Clean repositories look maintained
- Easy for new contributors
- Inspires confidence in quality

### Enables Handoffs
- New developers understand quickly
- AI agents navigate easily
- Historical context preserved

### Prevents Technical Debt
- Clutter accumulates slowly
- Regular organization prevents sprawl
- Easier to maintain long-term

### The AI Context System Thrives on Order
- Context files work best when project is organized
- AI agents understand structure better
- Session continuity improved

---

## Summary

**The Rules:**
1. Root: Only essential files (≤ 5)
2. context/: Active context system only
3. docs/: Organized permanent documentation
4. artifacts/: Dated historical work
5. Source: Code only, no docs

**The Habits:**
- File immediately, don't accumulate
- Use ISO dates for historical files
- Run /organize-docs monthly
- Keep organization score > 90

**The Result:**
- Professional appearance
- Easy navigation
- Clear history
- Reduced cognitive load
- Better collaboration

**Remember:** A well-organized project is easier to develop, maintain, and hand off.

---

**Version:** 2.2.1
**Last Updated:** 2025-10-20
**Status:** Active guideline for all projects using AI Context System