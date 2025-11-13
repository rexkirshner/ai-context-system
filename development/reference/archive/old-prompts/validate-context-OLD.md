---
name: validate-context
description: Validate context documentation structure and completeness
---

# /validate-context Command

Verify that all context documentation follows the expected structure, flag missing required sections, and check for incomplete placeholders. Perfect for ensuring documentation quality before sharing or deployment.

## When to Use This Command

- After /init-context to verify proper setup
- After /migrate-context to ensure migration completed
- Before /export-context to check completeness
- Periodically to maintain documentation quality
- Before project handoff or team sharing
- When documentation feels incomplete

## What This Command Does

1. Checks for all required context files
2. Validates file structure (required sections present)
3. Flags unfilled placeholders (`[TODO: ...]`, `[Your Name]`, etc.)
4. Validates .context-config.json format
5. Checks task files for completeness
6. Reports documentation health score
7. Provides actionable recommendations

## Execution Steps

### Step 1: Check Required Files Exist

```bash
# Required files
REQUIRED_FILES=(
  "context/CLAUDE.md"
  "context/PRD.md"
  "context/ARCHITECTURE.md"
  "context/CODE_STYLE.md"
  "context/DECISIONS.md"
  "context/KNOWN_ISSUES.md"
  "context/SESSIONS.md"
  "context/tasks/next-steps.md"
  "context/tasks/todo.md"
  "context/.context-config.json"
)

MISSING=()
for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    MISSING+=("$file")
  fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "❌ Missing required files:"
  printf '  - %s\n' "${MISSING[@]}"
fi
```

### Step 2: Validate CLAUDE.md Structure

**Required sections:**
- Project Overview
- Working with You (or Communication Style/Workflow Preferences)
- Core Development Methodology
- Commands
- Architecture
- Config reference (link to .context-config.json)

**Validation:**
```bash
# Check each required section
CLAUDE_SECTIONS=(
  "Project Overview"
  "Working with You"
  "Core Development Methodology"
  "Commands"
  "Architecture"
)

MISSING_SECTIONS=()
for section in "${CLAUDE_SECTIONS[@]}"; do
  if ! grep -q "## $section" context/CLAUDE.md 2>/dev/null; then
    MISSING_SECTIONS+=("$section")
  fi
done

# Check for config reference
if ! grep -q ".context-config.json" context/CLAUDE.md 2>/dev/null; then
  echo "⚠️  CLAUDE.md missing reference to .context-config.json"
fi

# Check for correct task paths (context/tasks/ not just tasks/)
if grep -q "tasks/next-steps.md" context/CLAUDE.md 2>/dev/null && \
   ! grep -q "context/tasks/next-steps.md" context/CLAUDE.md 2>/dev/null; then
  echo "⚠️  CLAUDE.md has incorrect task paths (missing 'context/' prefix)"
fi
```

### Step 3: Validate PRD.md Structure

**Required sections:**
- Executive Summary
- Current Status
- Technical Stack
- Implementation Plan
- Progress Log

**Validation:**
```bash
PRD_SECTIONS=(
  "Executive Summary"
  "Current Status"
  "Technical Stack"
  "Implementation Plan"
  "Progress Log"
)

for section in "${PRD_SECTIONS[@]}"; do
  if ! grep -q "## $section" context/PRD.md 2>/dev/null; then
    echo "⚠️  PRD.md missing: $section"
  fi
done

# Check if Progress Log has at least one entry
if ! grep -q "^### 20" context/PRD.md 2>/dev/null; then
  echo "⚠️  PRD.md Progress Log is empty (no dated entries)"
fi
```

### Step 4: Validate ARCHITECTURE.md Structure

**Required sections:**
- High-Level Overview
- System Components (or Key Directories)
- Technology Choices

**Validation:**
```bash
ARCH_SECTIONS=(
  "High-Level Overview"
  "Technology Choices"
)

for section in "${ARCH_SECTIONS[@]}"; do
  if ! grep -q "## $section" context/ARCHITECTURE.md 2>/dev/null; then
    echo "⚠️  ARCHITECTURE.md missing: $section"
  fi
done

# Check if it has meaningful content (more than just headers)
LINE_COUNT=$(wc -l < context/ARCHITECTURE.md)
if [ "$LINE_COUNT" -lt 20 ]; then
  echo "⚠️  ARCHITECTURE.md seems sparse ($LINE_COUNT lines)"
fi
```

### Step 5: Validate CODE_STYLE.md Structure

**Required sections:**
- Core Principles (or Core Development Principles)
- Language Conventions (can be project-specific)
- Git Workflow

**Validation:**
```bash
STYLE_SECTIONS=(
  "Core"
  "Git Workflow"
)

for section in "${STYLE_SECTIONS[@]}"; do
  if ! grep -q "$section" context/CODE_STYLE.md 2>/dev/null; then
    echo "⚠️  CODE_STYLE.md missing: $section section"
  fi
done

# Check for critical workflow rules
CRITICAL_RULES=(
  "NEVER push without explicit approval"
  "simplicity"
  "root cause"
)

for rule in "${CRITICAL_RULES[@]}"; do
  if ! grep -qi "$rule" context/CODE_STYLE.md 2>/dev/null; then
    echo "⚠️  CODE_STYLE.md missing critical rule: $rule"
  fi
done
```

### Step 6: Validate SESSIONS.md Structure

**Required:**
- At least one session entry
- Session entries follow format: `## Session [N] - YYYY-MM-DD`

**Validation:**
```bash
# Check if SESSIONS.md has at least one session
SESSION_COUNT=$(grep -c "^## Session" context/SESSIONS.md 2>/dev/null || echo "0")

if [ "$SESSION_COUNT" -eq 0 ]; then
  echo "❌ SESSIONS.md has no session entries"
elif [ "$SESSION_COUNT" -lt 3 ]; then
  echo "ℹ️  SESSIONS.md has only $SESSION_COUNT session(s) - consider using /save-context more frequently"
fi

# Check if sessions have proper date format
if ! grep -q "^## Session [0-9]* - [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}" context/SESSIONS.md 2>/dev/null; then
  echo "⚠️  SESSIONS.md entries missing proper date format (YYYY-MM-DD)"
fi
```

### Step 7: Check for Unfilled Placeholders

**Common placeholder patterns:**
- `[TODO: ...]`
- `[Your Name]`
- `[Project Name]`
- `[Add ...]`
- `[Fill in ...]`
- `[PLACEHOLDER]`

**Scan all context files:**
```bash
PLACEHOLDER_PATTERNS=(
  "\[TODO:"
  "\[Your Name\]"
  "\[Project Name\]"
  "\[Add "
  "\[Fill in"
  "\[PLACEHOLDER\]"
)

for pattern in "${PLACEHOLDER_PATTERNS[@]}"; do
  MATCHES=$(grep -r "$pattern" context/*.md context/tasks/*.md 2>/dev/null | wc -l)
  if [ "$MATCHES" -gt 0 ]; then
    echo "⚠️  Found $MATCHES unfilled placeholder(s): $pattern"
    # Show first few examples
    grep -rn "$pattern" context/*.md context/tasks/*.md 2>/dev/null | head -3
  fi
done
```

### Step 8: Validate .context-config.json

**Check JSON validity and required fields:**

```bash
# Check if valid JSON
if ! python3 -c "import json; json.load(open('context/.context-config.json'))" 2>/dev/null; then
  echo "❌ .context-config.json is not valid JSON"
  exit 1
fi

# Check for required fields
REQUIRED_FIELDS=(
  "version"
  "owner"
  "preferences"
)

for field in "${REQUIRED_FIELDS[@]}"; do
  if ! grep -q "\"$field\"" context/.context-config.json 2>/dev/null; then
    echo "❌ .context-config.json missing required field: $field"
  fi
done

# Check if owner is still placeholder
if grep -q "\"owner\": \"\[Your Name\]\"" context/.context-config.json 2>/dev/null; then
  echo "⚠️  .context-config.json owner field still has placeholder value"
fi
```

### Step 9: Validate Task Files

**Check next-steps.md:**
```bash
# Should have at least some action items
if [ ! -s context/tasks/next-steps.md ]; then
  echo "⚠️  next-steps.md is empty"
elif ! grep -q "- \[ \]" context/tasks/next-steps.md 2>/dev/null; then
  echo "ℹ️  next-steps.md has no pending actions (all completed or missing checkboxes)"
fi
```

**Check todo.md:**
```bash
# todo.md can be empty between sessions, just verify it exists
if [ ! -f context/tasks/todo.md ]; then
  echo "❌ tasks/todo.md is missing"
fi
```

### Step 10: Calculate Health Score

**Scoring system:**
- Required files present: 40 points (4 points each × 10 files)
- Required sections present: 30 points
- No placeholders: 15 points
- Valid config JSON: 10 points
- Session history: 5 points (1+ sessions)

**Calculate score:**
```bash
TOTAL_SCORE=0
MAX_SCORE=100

# Files (4 points each, 10 files = 40 max)
FILES_PRESENT=$((10 - ${#MISSING[@]}))
FILE_SCORE=$((FILES_PRESENT * 4))
TOTAL_SCORE=$((TOTAL_SCORE + FILE_SCORE))

# Sections (calculate based on missing sections)
# Estimate ~10 critical sections across all files
SECTIONS_SCORE=$((30 - ${#MISSING_SECTIONS[@]} * 3))
SECTIONS_SCORE=$((SECTIONS_SCORE < 0 ? 0 : SECTIONS_SCORE))
TOTAL_SCORE=$((TOTAL_SCORE + SECTIONS_SCORE))

# Placeholders (estimate from grep results)
if [ "$TOTAL_PLACEHOLDERS" -eq 0 ]; then
  PLACEHOLDER_SCORE=15
elif [ "$TOTAL_PLACEHOLDERS" -lt 5 ]; then
  PLACEHOLDER_SCORE=10
else
  PLACEHOLDER_SCORE=5
fi
TOTAL_SCORE=$((TOTAL_SCORE + PLACEHOLDER_SCORE))

# Config JSON validity
if [ "$CONFIG_VALID" = true ]; then
  TOTAL_SCORE=$((TOTAL_SCORE + 10))
fi

# Session history
if [ "$SESSION_COUNT" -ge 1 ]; then
  TOTAL_SCORE=$((TOTAL_SCORE + 5))
fi

PERCENTAGE=$((TOTAL_SCORE * 100 / MAX_SCORE))
```

### Step 11: Generate Validation Report

**Comprehensive report with actionable recommendations:**

```markdown
# Context Validation Report

**Overall Health Score:** XX/100 (XX%)

## Status: [Excellent / Good / Needs Attention / Critical Issues]

---

## File Completeness

✅ **9/10 required files present**
❌ **Missing:**
- context/DECISIONS.md

## Structure Validation

### CLAUDE.md
✅ All required sections present
⚠️  Missing config reference
✅ Task paths correct

### PRD.md
✅ All required sections present
⚠️  Progress Log has no entries

### ARCHITECTURE.md
✅ All required sections present
⚠️  Seems sparse (18 lines)

### CODE_STYLE.md
✅ All required sections present
✅ All critical rules present

### SESSIONS.md
✅ Has session entries (12 sessions)
✅ Proper date format

## Placeholder Analysis

⚠️  **5 unfilled placeholders found:**

1. `[TODO: Add deployment instructions]` in CLAUDE.md:45
2. `[Your Name]` in .context-config.json:3
3. `[Add database schema]` in ARCHITECTURE.md:67

## Configuration

✅ .context-config.json is valid JSON
⚠️  Owner field still has placeholder value
✅ All required fields present

## Task Files

✅ next-steps.md has 8 pending actions
✅ todo.md exists

---

## Recommendations

### High Priority
1. **Fill in owner name** in .context-config.json
2. **Create DECISIONS.md** - Run /save-context to auto-generate
3. **Add session entry to PRD.md** Progress Log

### Medium Priority
4. **Expand ARCHITECTURE.md** - Add more detail about system design
5. **Fill placeholders** - Address 5 TODO markers in documentation
6. **Add config reference to CLAUDE.md** - Link to .context-config.json

### Low Priority
7. Consider adding more detail to sparse sections
8. Review session frequency (12 sessions is good!)

---

## Quick Fixes

Run these commands to address some issues automatically:

```bash
# Create missing DECISIONS.md from template
cp templates/DECISIONS.template.md context/DECISIONS.md

# Update owner in config (replace [Your Name] with actual name)
sed -i '' 's/\[Your Name\]/John Doe/' context/.context-config.json
```

Then run /save-context to update documentation.

---

## Health Assessment

**Excellent (90-100%)**: Documentation is comprehensive and well-maintained
**Good (75-89%)**: Minor issues, documentation is usable
**Needs Attention (60-74%)**: Several missing pieces, address soon
**Critical Issues (<60%)**: Significant gaps, run /init-context or /migrate-context

Your score: **82/100 (82%) - Good**

Your context system is in good shape with minor improvements needed. Address the high-priority items and you'll be at excellent status.

---

**Next Steps:**
1. Address high-priority recommendations
2. Run /save-context to update documentation
3. Run /validate-context again to verify fixes
```

## Validation Categories

### Critical Issues (Block Usage)
- Missing 3+ required files
- Invalid .context-config.json
- CLAUDE.md completely empty
- No session history at all

### Warnings (Should Fix Soon)
- Missing 1-2 required files
- Missing required sections
- 5+ unfilled placeholders
- Sparse documentation (<20 lines in major files)

### Info (Nice to Have)
- Few placeholders (1-4)
- Older session history (no recent sessions)
- Task files empty
- Config owner still placeholder

## Usage Examples

### After Initial Setup
```
/init-context
/validate-context

> Health Score: 75/100 (Good)
> Found 8 placeholders to fill
> Recommendation: Update project-specific information
```

### After Migration
```
/migrate-context
/validate-context

> Health Score: 88/100 (Good)
> All required sections present
> 3 minor placeholders to fill
```

### Before Export
```
/save-context
/validate-context
/export-context

> Health Score: 95/100 (Excellent)
> Ready to export!
```

### Regular Health Check
```
/validate-context

> Health Score: 92/100 (Excellent)
> Documentation is well-maintained
> Consider adding recent decisions to DECISIONS.md
```

## Important Notes

### What Gets Validated

**Structure:**
- Required files exist
- Required sections present
- Proper heading hierarchy
- Date formats correct

**Content:**
- Placeholders filled
- Minimum content length
- Critical rules present
- Config valid JSON

**Completeness:**
- Session history exists
- Task files populated
- Config references correct
- Cross-file consistency

### What Doesn't Get Validated

- Content accuracy (can't verify technical correctness)
- Writing quality
- Code examples
- Specific project details
- Personal preferences in config

### False Positives

**May warn about:**
- Intentional placeholders (template sections for future use)
- Short but complete documentation
- Empty task lists (if all work done)
- Missing optional sections

**If you get warnings for intentional choices:**
- Document why in relevant file
- Health score may be lower, that's OK
- Validation helps catch unintentional gaps

## Automation

### Pre-Export Validation
```bash
# Validate before exporting
/validate-context
if health_score >= 85:
  /export-context
else:
  echo "Fix validation issues first"
```

### CI/CD Integration
```bash
# In CI pipeline
claude-code /validate-context
exit_code=$?

if [ $exit_code -ne 0 ]; then
  echo "Context validation failed"
  exit 1
fi
```

### Periodic Checks
```bash
# Weekly validation reminder
/validate-context
# Review score and address top 3 recommendations
```

## Success Criteria

Validation succeeds when:
- All required files exist
- All critical sections present
- No critical placeholders (`[TODO: CRITICAL]`)
- Valid config JSON
- Health score reported
- Actionable recommendations provided

**Perfect validation:**
- Health score 90+
- All files present
- All sections complete
- No placeholders
- Recent session activity
- Clear, detailed report
