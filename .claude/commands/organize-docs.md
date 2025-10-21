---
name: organize-docs
description: "Organize project documentation into proper structure"
---

# /organize-docs Command

**Interactive documentation cleanup** - Helps file documents in appropriate locations.

**Philosophy:** "A place for everything, everything in its place"

---

## Execution Steps

### Step 1: Scan for Disorganized Files

**Scan project for files that need organization:**

```bash
echo "🔍 Scanning for files to organize..."
echo ""

# Find loose .md files in root (exclude allowed ones)
echo "Checking project root..."
LOOSE_ROOT=$(find . -maxdepth 1 -name "*.md" \
  ! -name "README.md" \
  ! -name "SECURITY.md" \
  ! -name "CONTRIBUTING.md" \
  ! -name "LICENSE.md" \
  ! -name "CHANGELOG.md" \
  ! -name "ORGANIZATION.md" \
  2>/dev/null)

# Find .md files in source directories
echo "Checking source directories..."
LOOSE_SRC=$(find src backend frontend lib -name "*.md" 2>/dev/null || true)

# Count results
ROOT_COUNT=$(echo "$LOOSE_ROOT" | grep -c "\.md$" || echo "0")
SRC_COUNT=$(echo "$LOOSE_SRC" | grep -c "\.md$" || echo "0")
TOTAL=$((ROOT_COUNT + SRC_COUNT))

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SCAN RESULTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Loose files in root: $ROOT_COUNT"
echo "Docs in source dirs: $SRC_COUNT"
echo "Total to organize: $TOTAL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$TOTAL" -eq 0 ]; then
  echo "✅ Project is well-organized! No loose files found."
  echo ""
  echo "Current structure follows best practices:"
  echo "  📄 Root - Only essential files"
  echo "  📁 context/ - Active context system"
  echo "  📁 docs/ - Organized documentation"
  echo "  📁 artifacts/ - Historical work"
  exit 0
fi

# List all files that need attention
if [ "$ROOT_COUNT" -gt 0 ]; then
  echo "Files in root:"
  echo "$LOOSE_ROOT"
  echo ""
fi

if [ "$SRC_COUNT" -gt 0 ]; then
  echo "Files in source directories:"
  echo "$LOOSE_SRC"
  echo ""
fi
```

**If files found, proceed to Step 2. If no files found, exit with success message.**

---

### Step 2: Analyze Each File

**For each file found, analyze its content and purpose:**

**Analysis criteria:**
1. **Read the file** - Use Read tool to examine contents
2. **Determine type** - Based on content keywords and structure:
   - **Milestone** - Keywords: milestone, completed, done, finished, shipped
   - **Planning** - Keywords: proposal, plan, roadmap, spec, requirements, PRD
   - **Review** - Keywords: review, audit, analysis, feedback, retrospective
   - **Research** - Keywords: research, comparison, evaluation, investigation
   - **Setup** - Keywords: setup, installation, configuration, getting started
   - **Architecture** - Keywords: architecture, design, structure, system, patterns
   - **API** - Keywords: api, endpoint, route, REST, GraphQL
   - **General Notes** - Doesn't fit other categories
3. **Assess status** - Is this active documentation or historical artifact?
4. **Check for dates** - Does filename or content suggest when it was created?

**Create a summary table:**

```markdown
| File | Type | Status | Suggested Location | Reason |
|------|------|--------|---------------------|--------|
| NOTES.md | planning | historical | artifacts/planning/ | Old planning notes from Oct 2024 |
| API_DESIGN.md | architecture | permanent | docs/architecture/ | Current API design reference |
| ... | ... | ... | ... | ... |
```

**Present this table to the user before proceeding.**

---

### Step 3: Create Folder Structure

**If `artifacts/` or `docs/` folders don't exist, create them:**

```bash
echo "Setting up organized folder structure..."
echo ""

# Create artifacts/ for historical work
if [ ! -d "artifacts" ]; then
  echo "Creating artifacts/ directories..."
  mkdir -p artifacts/milestones
  mkdir -p artifacts/planning
  mkdir -p artifacts/reviews
  mkdir -p artifacts/research
  mkdir -p artifacts/notes
  echo "  ✅ artifacts/ created"
fi

# Create docs/ for permanent documentation
if [ ! -d "docs" ]; then
  echo "Creating docs/ directories..."
  mkdir -p docs/setup
  mkdir -p docs/development
  mkdir -p docs/architecture
  mkdir -p docs/api
  echo "  ✅ docs/ created"
fi

echo ""
echo "📁 Folder structure ready"
echo ""
```

---

### Step 4: File Organization Plan

**Present organization plan to user:**

```markdown
## Organization Plan

I've analyzed all loose files and created this organization plan:

### Files to Move

**To artifacts/planning/:**
- NOTES.md → artifacts/planning/2024-10-old-notes.md
- PROPOSAL.md → artifacts/planning/2024-09-initial-proposal.md

**To docs/architecture/:**
- API_DESIGN.md → docs/architecture/api-design.md

**To artifacts/milestones/:**
- MILESTONE_1.md → artifacts/milestones/2024-11-milestone-1.md

### Naming Conventions Applied

Historical files (artifacts/) use date prefix: `YYYY-MM-DD-description.md`
Permanent files (docs/) use descriptive names: `topic-description.md`

### Actions

Say "proceed" to execute these moves
Say "modify" to adjust the plan
Say "cancel" to abort organization
```

**Wait for user approval before proceeding.**

---

### Step 5: Execute Organization

**Once user approves, execute the moves:**

```bash
# Example move operations (customize based on analysis)

echo "Organizing files..."
echo ""

# Move files to proper locations
# Use 'git mv' if in git repo, otherwise 'mv'
if git rev-parse --git-dir > /dev/null 2>&1; then
  MV_CMD="git mv"
  echo "Using git mv (changes will be staged)"
else
  MV_CMD="mv"
  echo "Using mv (not a git repository)"
fi

# Execute each move
# $MV_CMD "NOTES.md" "artifacts/planning/2024-10-old-notes.md"
# $MV_CMD "API_DESIGN.md" "docs/architecture/api-design.md"
# ... (based on approved plan)

echo ""
echo "✅ Files moved to organized locations"
```

**IMPORTANT:** Only execute moves that were explicitly approved by the user.

---

### Step 6: Summary and Validation

**Provide summary of organization:**

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ORGANIZATION COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Summary:"
echo "  📁 Files organized: $ORGANIZED_COUNT"
echo "  📁 Folders created: $FOLDERS_CREATED"
echo "  📄 Root directory: Clean"
echo ""
echo "Current structure:"
echo "  📁 artifacts/ - Historical work (dated)"
echo "  📁 docs/ - Permanent documentation (organized)"
echo "  📁 context/ - Active context system"
echo "  📄 Root - Only essential files"
echo ""
echo "✅ Project structure is now clean and organized!"
echo ""
```

**Suggest validation:**

```bash
echo "Next steps:"
echo "  1. Run /validate-context to check organization score"
echo "  2. Review ORGANIZATION.md for guidelines"
echo "  3. Commit organized structure to git"
echo ""
```

---

## Guidelines

### Categorization Rules

**artifacts/** (Historical - Dated files):
- `artifacts/milestones/` - Completed milestones, feature completions
- `artifacts/planning/` - Old proposals, specs, roadmaps
- `artifacts/reviews/` - Code reviews, audits, retrospectives
- `artifacts/research/` - Research, comparisons, evaluations
- `artifacts/notes/` - Meeting notes, brainstorms, general notes

**docs/** (Permanent - Topic-organized):
- `docs/setup/` - Installation, configuration guides
- `docs/development/` - Development workflows, testing
- `docs/architecture/` - System design, patterns, decisions
- `docs/api/` - API documentation, endpoints

### Naming Conventions

**Historical files (artifacts/):**
- Format: `YYYY-MM-DD-description.md`
- Example: `2024-10-15-auth-milestone-complete.md`
- Always include date prefix

**Permanent files (docs/):**
- Format: `descriptive-topic-name.md`
- Example: `database-architecture.md`
- No dates (living documentation)

### Decision Guidelines

**When to use artifacts/ vs docs/:**

Use **artifacts/** when:
- Work is completed (milestone, project phase)
- Proposal was superseded by new approach
- Document is historical reference
- Rarely or never updated

Use **docs/** when:
- Documentation is long-term reference
- Will be updated as system evolves
- Describes current state
- Organized by topic, not time

---

## When to Run /organize-docs

**Monthly Maintenance:**
- Regular cleanup prevents accumulation
- Takes 5-10 minutes
- Keeps organization score high

**Before Major Releases:**
- Ensure professional appearance
- Clean structure for handoffs
- Archive completed work

**When Validation Flags Issues:**
- Organization score < 90
- Loose files > 5 in root
- Documentation sprawl detected

**When Project Feels Cluttered:**
- Hard to find documentation
- Unclear what's current vs old
- New files accumulating in wrong places

---

## Expected Outcome

**Before:**
```
project-root/
├── README.md
├── NOTES.md
├── OLD_PLAN.md
├── IDEAS.md
├── MILESTONE_1.md
├── API_THOUGHTS.md
└── backend/
    └── BACKEND_NOTES.md
```

**After:**
```
project-root/
├── README.md
├── LICENSE.md
├── context/
│   ├── CONTEXT.md
│   └── STATUS.md
├── docs/
│   ├── architecture/
│   │   └── api-design.md
│   └── setup/
│       └── configuration.md
└── artifacts/
    ├── planning/
    │   ├── 2024-09-initial-ideas.md
    │   └── 2024-10-old-plan.md
    └── milestones/
        └── 2024-11-milestone-1.md
```

**Result:** Clean, organized, professional structure.

---

**Version:** 2.2.1
**Added:** Organization features for structural neatness
