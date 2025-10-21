# Search Matrix for v3.0.0 Rebrand

**Purpose:** Comprehensive list of all search patterns to check during implementation. Covers all case variants, hyphenations, and edge cases.

**AI Context System:** The new universal name (formerly Claude Context System)

---

## Category 1: System Name Variants

### Exact Matches (MUST CHANGE)

| Pattern | Case | Locations | Replace With |
|---------|------|-----------|--------------|
| `Claude Context System` | Title Case | Docs, headers | `AI Context System` |
| `CLAUDE CONTEXT SYSTEM` | All Caps | Maybe headers | `AI CONTEXT SYSTEM` |
| `claude context system` | Lower Case | Unlikely but check | `ai context system` |
| `Claude context system` | Sentence | Docs | `AI context system` |

### Command to Search:
```bash
# Case-insensitive search for system name
grep -ri "claude context system" . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=planning \
  --color=always
```

---

## Category 2: Repository/URL Variants

### Exact Matches (MUST CHANGE)

| Pattern | Format | Locations | Replace With |
|---------|--------|-----------|--------------|
| `claude-context-system` | Kebab case | URLs, repo names | `ai-context-system` |
| `github.com/rexkirshner/claude-context-system` | Full URL | install.sh, docs | `github.com/rexkirshner/ai-context-system` |
| `/claude-context-system/` | Path segment | URLs | `/ai-context-system/` |
| `claude_context_system` | Snake case | Unlikely variables | `ai_context_system` |

### Command to Search:
```bash
# Find repo references
grep -r "claude-context-system" . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=planning \
  --color=always

# Find GitHub URLs
grep -r "github.com.*claude-context-system" . \
  --exclude-dir=.git \
  --color=always
```

---

## Category 3: Feedback File Variants

### Exact Matches (MUST CHANGE)

| Pattern | Context | Locations | Replace With |
|---------|---------|-----------|--------------|
| `claude-context-feedback.md` | Full filename | Commands, docs | `context-feedback.md` |
| `context/claude-context-feedback.md` | Full path | Commands | `context/context-feedback.md` |
| `claude-context-feedback` | No extension | Code references | `context-feedback` |
| `templates/claude-context-feedback.template.md` | Template path | Commands, install.sh | `templates/context-feedback.template.md` |

### Command to Search:
```bash
# Find all feedback file references
grep -r "claude-context-feedback" . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=planning \
  --color=always
```

---

## Category 4: Files to Rename (NOT Search/Replace)

### Physical Files (MUST RENAME)

| Current Path | New Path | Action |
|--------------|----------|--------|
| `templates/claude-context-feedback.template.md` | `templates/context-feedback.template.md` | `git mv` |

### Files to NOT Rename (MUST KEEP)

| Path | Reason | DO NOT CHANGE |
|------|--------|---------------|
| `templates/claude.md.template` | Claude's entry point template | ✅ KEEP |
| `context/claude.md` | Claude's entry point (user projects) | ✅ KEEP |
| `templates/cursor.md.template` | Cursor's entry point template | ✅ KEEP |
| `templates/aider.md.template` | Aider's entry point template | ✅ KEEP |
| `templates/codex.md.template` | Codex's entry point template | ✅ KEEP |

### Command to Verify:
```bash
# Should exist (Claude-specific files)
ls -la templates/claude.md.template
ls -la templates/cursor.md.template
ls -la templates/aider.md.template
ls -la templates/codex.md.template

# Should exist after rename
ls -la templates/context-feedback.template.md

# Should NOT exist after rename
ls -la templates/claude-context-feedback.template.md  # Should error
```

---

## Category 5: Abbreviations & Shortcuts

### Exact Matches (CHECK CONTEXT)

| Pattern | Context | Action |
|---------|---------|--------|
| `CCS` | Abbreviation | Check if "Claude Context System" or "Code Continuity System" |
| `ACS` | New abbreviation | Use for "AI Context System" |

### Command to Search:
```bash
# Find abbreviations (rare, but check)
grep -r "\bCCS\b" . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=planning
```

---

## Category 6: Documentation Prose (MUST CHANGE)

### Partial Matches in Sentences

| Pattern | Example | Replace With |
|---------|---------|--------------|
| `The Claude Context System` | "The Claude Context System provides..." | `The AI Context System` |
| `Claude Context System's` | "...using Claude Context System's features" | `AI Context System's` |
| `of Claude Context System` | "Overview of Claude Context System" | `of AI Context System` |
| `for Claude Context System` | "Guide for Claude Context System" | `for AI Context System` |

### Command to Search:
```bash
# Find in markdown files
find . -name "*.md" \
  -not -path "./.git/*" \
  -not -path "./node_modules/*" \
  -not -path "./planning/*" \
  -exec grep -l "Claude Context System" {} \;
```

---

## Category 7: Code Comments (MUST CHANGE)

### In Shell Scripts

| Pattern | Context | Replace With |
|---------|---------|--------------|
| `# Claude Context System installer` | Comment | `# AI Context System installer` |
| `# Update Claude Context System` | Comment | `# Update AI Context System` |
| `## Claude Context System v3.0.0` | Header comment | `## AI Context System v3.0.0` |

### Command to Search:
```bash
# Find in shell scripts
find . -name "*.sh" \
  -not -path "./.git/*" \
  -exec grep -n "Claude Context System" {} + \
  --color=always
```

---

## Category 8: Echo/Print Messages (MUST CHANGE)

### In Scripts and Commands

| Pattern | Context | Replace With |
|---------|---------|--------------|
| `echo "Claude Context System"` | Install message | `echo "AI Context System"` |
| `log_info "Claude Context System"` | Log message | `log_info "AI Context System"` |
| `printf "Claude Context System"` | Printf statement | `printf "AI Context System"` |

### Command to Search:
```bash
# Find echo statements
grep -r "echo.*Claude Context System" . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=planning \
  --color=always
```

---

## Category 9: CHANGELOG & Historical (DO NOT CHANGE)

### Patterns to PRESERVE

| Section | Pattern | Action |
|---------|---------|--------|
| `## v2.*` | Any v2.x section | ✅ KEEP AS-IS |
| `## v1.*` | Any v1.x section | ✅ KEEP AS-IS |
| Historical attribution | "Originally Claude Context System" | ✅ KEEP AS-IS |

### Command to Verify (should have NO matches outside CHANGELOG):
```bash
# Find "Claude Context System" but exclude CHANGELOG historical sections
# Manual review needed - check each match is in v3.0.0+ section only
grep -n "Claude Context System" CHANGELOG.md
```

---

## Category 10: Configuration & Metadata (MUST CHANGE)

### JSON/Config Files

| File | Field | Replace |
|------|-------|---------|
| `package.json` | `"name"` | `"ai-context-system"` (if exists) |
| `package.json` | `"description"` | Update text |
| `.context-config.json` | Any description fields | Update text |

### Command to Search:
```bash
# Find in JSON files
find . -name "*.json" \
  -not -path "./.git/*" \
  -not -path "./node_modules/*" \
  -exec grep -l "Claude Context System" {} \;
```

---

## Category 11: Special Cases (CONDITIONAL)

### Attribution & Origin Statements

| Pattern | Action | Notes |
|---------|--------|-------|
| `Originally designed as Claude Context System` | ✅ KEEP | Historical accuracy |
| `Formerly Claude Context System` | ✅ KEEP/ADD | Helps discoverability |
| `Built for Claude Code` | ✅ KEEP | Tool reference, not system |
| `Optimized for Claude Code` | ✅ KEEP | Marketing/feature statement |

### Command to Search:
```bash
# Find "Originally" or "Formerly" statements
grep -ri "originally.*claude" . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=planning

grep -ri "formerly.*claude" . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=planning
```

---

## Category 12: claude.md References (DO NOT CHANGE)

### Patterns to PRESERVE

| Pattern | Context | Action |
|---------|---------|--------|
| `claude.md` | Filename reference | ✅ KEEP |
| `context/claude.md` | Path reference | ✅ KEEP |
| `templates/claude.md.template` | Template path | ✅ KEEP |
| `Read claude.md` | Instruction | ✅ KEEP |
| `/init-context creates claude.md` | Documentation | ✅ KEEP |

### Command to Verify (should find many - this is correct):
```bash
# These are CORRECT - claude.md should be referenced
grep -r "claude\.md" . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=planning \
  --color=always
```

---

## Category 13: Version Numbers (MUST UPDATE)

### Patterns to Update

| Pattern | Context | Replace With |
|---------|---------|--------------|
| `version: "2.3.2"` | Current version | `version: "3.0.0"` |
| `Version 2.3.2` | Documentation | `Version 3.0.0` |
| `v2.3.2` | Headers | `v3.0.0` |

### Command to Search:
```bash
# Find current version references
grep -r "2\.3\.2" . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=planning \
  --color=always
```

---

## Comprehensive Search Script

### Master Search Command

```bash
#!/bin/bash
# v3-comprehensive-search.sh
# Searches for all patterns that need review

echo "=== CATEGORY 1: System Name ==="
grep -ri "claude context system" . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=planning \
  --color=always

echo ""
echo "=== CATEGORY 2: Repository URLs ==="
grep -r "claude-context-system" . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=planning \
  --color=always

echo ""
echo "=== CATEGORY 3: Feedback File ==="
grep -r "claude-context-feedback" . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=planning \
  --color=always

echo ""
echo "=== CATEGORY 4: Version Numbers ==="
grep -r "2\.3\.2" . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=planning \
  --color=always

echo ""
echo "=== CATEGORY 5: claude.md (VERIFY PRESENT) ==="
grep -r "claude\.md" . \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=planning \
  --color=always | head -20

echo ""
echo "=== Search Complete ==="
echo "Review each match and verify against terminology-guardrails.md"
```

---

## Post-Implementation Verification

### After all changes, these should return ZERO results:

```bash
# 1. No "Claude Context System" in current docs (except CHANGELOG historical)
grep -ri "claude context system" README.md

# 2. No "Claude Context System" in commands
grep -r "Claude Context System" .claude/commands/

# 3. No old feedback filename in commands
grep -r "claude-context-feedback.md" .claude/commands/ | grep -v "OLD_FEEDBACK"

# 4. No old repo URL in install.sh
grep "github.com.*claude-context-system" install.sh
```

### These should return MANY results (correct):

```bash
# 1. claude.md should be referenced (correct)
grep -r "claude\.md" .

# 2. AI Context System should appear frequently
grep -r "AI Context System" . | wc -l

# 3. New feedback filename should appear
grep -r "context-feedback.md" .
```

---

## Edge Case Searches

### 1. Mixed Case Variants
```bash
# Case variations
grep -r "Claude context system" .
grep -r "claude Context System" .
grep -r "CLAUDE CONTEXT SYSTEM" .
```

### 2. Hyphenated Variants
```bash
# With hyphens
grep -r "claude-context-system" .
grep -r "Claude-Context-System" .
```

### 3. Underscored Variants
```bash
# With underscores (rare but possible in code)
grep -r "claude_context_system" .
grep -r "CLAUDE_CONTEXT_SYSTEM" .
```

### 4. Abbreviated Variants
```bash
# Abbreviations
grep -r "\bCCS\b" .
```

---

## File Type Specific Searches

### Markdown Files Only
```bash
find . -name "*.md" \
  -not -path "./.git/*" \
  -not -path "./node_modules/*" \
  -not -path "./planning/*" \
  -exec grep -l "Claude Context System" {} \;
```

### Shell Scripts Only
```bash
find . -name "*.sh" \
  -not -path "./.git/*" \
  -exec grep -l "Claude Context System" {} \;
```

### JSON Files Only
```bash
find . -name "*.json" \
  -not -path "./.git/*" \
  -not -path "./node_modules/*" \
  -exec grep -l "Claude Context System" {} \;
```

### Template Files Only
```bash
find . -name "*.template.*" \
  -not -path "./.git/*" \
  -exec grep -l "Claude Context System" {} \;
```

---

## Priority Matrix

### Critical (Must Find/Replace)

| Priority | Pattern | Estimated Occurrences |
|----------|---------|----------------------|
| 🔴 P0 | "Claude Context System" | ~146 |
| 🔴 P0 | "claude-context-feedback.md" | ~20 |
| 🔴 P0 | Repository URL | ~10 |
| 🔴 P0 | Version "2.3.2" → "3.0.0" | ~15 |

### Important (Must Verify)

| Priority | Pattern | Action |
|----------|---------|--------|
| 🟡 P1 | claude.md references | KEEP |
| 🟡 P1 | CHANGELOG historical | KEEP |
| 🟡 P1 | Template filenames | RENAME (feedback only) |

### Nice to Have (Optional)

| Priority | Pattern | Action |
|----------|---------|--------|
| 🟢 P2 | Abbreviations (CCS) | Update if found |
| 🟢 P2 | Code comments | Update for clarity |

---

## Implementation Checklist

Before starting Phase 2:

- [ ] Run comprehensive search script
- [ ] Document all matches found
- [ ] Categorize each match (change vs keep)
- [ ] Create automated rename script
- [ ] Test rename script on copy
- [ ] Review all changes manually
- [ ] Run verification searches
- [ ] Commit changes

---

**Version:** 1.0
**Created:** 2025-10-21
**Purpose:** Comprehensive search patterns for v3.0.0 rebrand
**Usage:** Run searches before and after implementation to verify completeness
