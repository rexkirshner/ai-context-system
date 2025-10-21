# Terminology Guardrails for v3.0.0 Rebrand

**Purpose:** Prevent over-zealous find/replace during implementation. Clear guidance on what changes vs what stays.

**AI Context System:** The new universal name for the system (formerly Claude Context System)

---

## ✅ MUST Change: System Name References

### Pattern: "Claude Context System"
**Replace with:** "AI Context System"

**Where:**
- README.md (title, descriptions, taglines)
- All command headers (.claude/commands/*.md)
- install.sh (echo messages, success messages)
- CHANGELOG.md (current version entries only)
- .claude/docs/*.md (all references)
- scripts/*.sh (echo messages)
- templates/*.md (system name references)

**Examples:**

✅ **CHANGE:**
```markdown
# Claude Context System
```
```markdown
# AI Context System
```

✅ **CHANGE:**
```bash
echo "Claude Context System v3.0.0 is now installed"
```
```bash
echo "AI Context System v3.0.0 is now installed"
```

✅ **CHANGE:**
```markdown
The Claude Context System provides perfect session continuity...
```
```markdown
The AI Context System provides perfect session continuity...
```

---

## ✅ MUST Change: Feedback File References

### Pattern: "claude-context-feedback.md"
**Replace with:** "context-feedback.md"

**Where:**
- .claude/commands/init-context.md
- .claude/commands/update-context-system.md
- .claude/commands/validate-context.md
- .claude/commands/organize-docs.md
- .claude/commands/code-review.md
- .claude/commands/save.md (if has feedback reminder)
- .claude/commands/save-full.md (if has feedback reminder)
- README.md
- CHANGELOG.md
- templates/context-feedback.template.md (internal references)

**Examples:**

✅ **CHANGE:**
```bash
cp templates/claude-context-feedback.template.md context/claude-context-feedback.md
```
```bash
cp templates/context-feedback.template.md context/context-feedback.md
```

✅ **CHANGE:**
```markdown
Add feedback to `context/claude-context-feedback.md`
```
```markdown
Add feedback to `context/context-feedback.md`
```

---

## ✅ MUST Change: Template Filename

### File: templates/claude-context-feedback.template.md
**Rename to:** templates/context-feedback.template.md

**Action:**
```bash
git mv templates/claude-context-feedback.template.md templates/context-feedback.template.md
```

---

## ✅ MUST Change: Repository References

### Pattern: "github.com/rexkirshner/claude-context-system"
**Replace with:** "github.com/rexkirshner/ai-context-system"

**Where:**
- README.md (installation instructions)
- install.sh (download URLs)
- CHANGELOG.md (current entries)
- All commands referencing GitHub
- Migration guides

**Note:** GitHub will auto-redirect old URLs, but update references for clarity.

---

## ❌ MUST NOT Change: Claude-Specific Files

### Files That Stay "Claude"

**1. claude.md**
- **Filename:** `claude.md` (stays as-is)
- **Reason:** This is Claude's entry point to the context system
- **Analogous to:** cursor.md (Cursor's entry point), aider.md (Aider's entry point)
- **Location:** context/claude.md (created by /init-context)
- **Template:** templates/claude.md.template (stays as-is)

**2. Multi-AI Header Templates**
- `templates/claude.md.template` ← Claude's header
- `templates/cursor.md.template` ← Cursor's header
- `templates/aider.md.template` ← Aider's header
- `templates/codex.md.template` ← Codex's header
- All stay tool-specific by design

**Why?**
Each AI tool gets its own entry point with tool-specific instructions. This is the multi-AI support architecture (v2.1+).

---

## ❌ MUST NOT Change: Historical References

### Pattern: Historical changelog entries
**Action:** KEEP AS-IS for historical accuracy

**Examples:**

❌ **DO NOT CHANGE:**
```markdown
## v2.3.2 - 2025-10-15

### Fixed
- Claude Context System bug in init-context
```

**Reason:** Historical accuracy. Old versions were called "Claude Context System".

❌ **DO NOT CHANGE:**
```markdown
Originally designed as Claude Context System, now AI Context System...
```

**Reason:** Acknowledges history and evolution.

---

## ❌ MUST NOT Change: Code Examples Mentioning Claude

### Pattern: Examples showing Claude usage
**Action:** KEEP unless it's a system name reference

**Examples:**

❌ **DO NOT CHANGE:**
```markdown
When using Claude Code:
1. Read context/claude.md
2. Follow the instructions
```

**Reason:** This is about using Claude the AI tool, not the system name.

✅ **BUT DO CHANGE:**
```markdown
The Claude Context System helps you use Claude Code effectively.
```
```markdown
The AI Context System helps you use Claude Code effectively.
```

---

## ⚠️ CONDITIONAL: Attribution and Branding

### Pattern: "Originally designed for Claude Code"
**Action:** KEEP or ADD as context

**Preferred phrasing:**
```markdown
Originally designed for Claude Code, supports all AI coding assistants.
```

**Where to add:**
- README.md tagline
- Release announcements
- Migration messaging
- Footer of key docs

**Why?**
- Acknowledges origin and quality association
- Shows evolution not abandonment
- Helps Claude users feel included

---

## ⚠️ CONDITIONAL: Marketing Copy

### Pattern: References to Claude in feature descriptions
**Action:** EVALUATE CASE-BY-CASE

**Examples:**

✅ **CHANGE (system name):**
```markdown
Claude Context System was designed to solve...
```
```markdown
AI Context System was designed to solve...
```

⚠️ **KEEP (tool reference):**
```markdown
Optimized for Claude Code workflows
```

⚠️ **KEEP (historical):**
```markdown
Built by Claude Code users, for Claude Code users
```

✅ **UPDATE (make inclusive):**
```markdown
Perfect for Claude Code projects
```
```markdown
Perfect for AI-powered development (optimized for Claude Code)
```

---

## Search & Replace Safety Checklist

### Before Running Any Find/Replace:

1. ✅ **Check context** - Is this a system name or tool reference?
2. ✅ **Check location** - Is this historical or current?
3. ✅ **Check file** - Is this a Claude-specific file (claude.md)?
4. ✅ **Check scope** - Are we in CHANGELOG historical entries?
5. ✅ **Check examples** - Is this showing Claude usage?

### Red Flags (DON'T CHANGE):

- 🚫 Filename is `claude.md` or `**/claude.md.template`
- 🚫 In CHANGELOG section for v2.x or earlier
- 🚫 Example code showing "Read context/claude.md"
- 🚫 "Optimized for Claude Code" (marketing)
- 🚫 Historical attribution

### Green Lights (DO CHANGE):

- ✅ System name in documentation
- ✅ Feedback filename references
- ✅ Repository URLs
- ✅ Current version documentation
- ✅ Command descriptions

---

## Safe Search Patterns

### System Name (Safe to Replace)

```bash
# Safe patterns
"Claude Context System"
"claude-context-system"  # repo name
"CLAUDE CONTEXT SYSTEM"  # all caps

# Context-dependent (check before replacing)
"claude context"  # might be "claude context system" or "claude.md context"
```

### Feedback File (Safe to Replace)

```bash
# Safe patterns
"claude-context-feedback.md"
"claude-context-feedback"
"templates/claude-context-feedback.template.md"
```

### Files (NEVER Replace)

```bash
# NEVER replace these
"claude.md"
"templates/claude.md.template"
"context/claude.md"
```

---

## Quick Reference Table

| Pattern | Change? | Replace With | Notes |
|---------|---------|--------------|-------|
| "Claude Context System" | ✅ YES | "AI Context System" | System name |
| claude-context-feedback.md | ✅ YES | context-feedback.md | Feedback file |
| claude.md | ❌ NO | - | Claude's entry point |
| claude-context-system (repo) | ✅ YES | ai-context-system | GitHub repo |
| "Originally designed for Claude" | ⚠️ KEEP | - | Attribution |
| CHANGELOG v2.x entries | ❌ NO | - | Historical accuracy |
| "Optimized for Claude Code" | ⚠️ KEEP | - | Marketing/feature |
| templates/claude.md.template | ❌ NO | - | Tool-specific template |

---

## Implementation Workflow

### Phase 2: Implementation

**Step 1: Automated (Safe Patterns)**
```bash
# Run rename script (to be created)
./scripts/v3-rename.sh
```

**Step 2: Manual Review**
- Check all changed files
- Verify no claude.md references changed
- Verify CHANGELOG historical entries intact
- Verify examples still make sense

**Step 3: Verification**
```bash
# Should find ZERO results (except in this guardrail doc)
grep -r "Claude Context System" . \
  --exclude-dir=.git \
  --exclude-dir=planning \
  --exclude="CHANGELOG.md"  # Allow in historical sections

# Should find ZERO results
grep -r "claude-context-feedback.md" . \
  --exclude-dir=.git \
  --exclude-dir=planning

# Should find SOME results (this is correct)
grep -r "claude.md" .
# Expected: templates/, init-context.md examples, etc.
```

---

## Post-Implementation Checklist

After all changes:

- [ ] README.md title is "AI Context System"
- [ ] No "Claude Context System" in current docs (except CHANGELOG historical)
- [ ] No "claude-context-feedback.md" references (except in migration logic)
- [ ] claude.md and templates/claude.md.template still exist
- [ ] Repository renamed to ai-context-system
- [ ] All tests reference new names
- [ ] Migration guide references both old and new names
- [ ] "Originally designed for Claude Code, supports all AI assistants" appears in key docs

---

## Common Mistakes to Avoid

### ❌ Mistake 1: Renaming claude.md
```bash
# WRONG
git mv templates/claude.md.template templates/ai.md.template
```

**Why wrong:** claude.md is Claude's entry point (tool-specific), not a system file.

### ❌ Mistake 2: Changing CHANGELOG history
```markdown
# WRONG
## v2.3.2 - 2025-10-15
Fixed AI Context System bug...
```

**Why wrong:** v2.3.2 was "Claude Context System" - historical accuracy matters.

### ❌ Mistake 3: Over-zealous example updates
```markdown
# WRONG
When using the AI tool:
1. Read context/ai.md  # NO! It's context/claude.md for Claude users
```

**Why wrong:** Examples showing Claude usage should reference claude.md.

### ❌ Mistake 4: Breaking multi-AI support
```bash
# WRONG - removing tool-specific headers
rm templates/claude.md.template
rm templates/cursor.md.template
```

**Why wrong:** Each AI tool needs its own entry point.

---

## Edge Cases

### Case 1: "claude-context" in variable names
```bash
# Code variable
CLAUDE_CONTEXT_DIR="context/"

# Decision: KEEP (internal variable, not user-facing)
```

### Case 2: Git commit messages
```bash
# Old commit from v2.x
"Fix Claude Context System bug"

# Decision: KEEP (historical, in git history)
```

### Case 3: Screenshots with old name
```markdown
![Claude Context System](screenshot.png)
```

**Decision:** UPDATE screenshot OR add caption "(shown: v2.x, now AI Context System)"

---

**Version:** 1.0
**Created:** 2025-10-21
**Purpose:** Guide v3.0.0 implementation team through safe renaming
