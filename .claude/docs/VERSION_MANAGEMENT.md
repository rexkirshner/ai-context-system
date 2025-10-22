# Version Management - CRITICAL

## ⚠️ ALWAYS Update Version Numbers

**CRITICAL RULE:** Every change to the AI Context System MUST increment the version number, no matter how small.

### Why This Matters

Users rely on `/update-context-system` to detect changes. If we don't increment the version:
- The command reports "Already up to date" even though changes exist
- Users don't know updates are available
- Updates may happen silently without user knowledge
- Confusing, misleading experience

### Version Numbering (Semantic Versioning)

Format: `MAJOR.MINOR.PATCH` (e.g., `1.2.3`)

**When to increment:**

- **MAJOR (1.0.0 → 2.0.0)**: Breaking changes
  - Command behavior changes that require user action
  - Config format changes requiring migration
  - Removed or renamed commands
  - Changed required file structure

- **MINOR (1.0.0 → 1.1.0)**: New features, non-breaking
  - New commands added
  - New sections in templates
  - Enhanced existing commands
  - New optional features

- **PATCH (1.0.0 → 1.0.1)**: Bug fixes, documentation
  - Bug fixes in commands
  - Documentation improvements
  - Template typo fixes
  - Small clarifications

### Where to Update Version

**ALWAYS update ALL of these locations:**

1. **`config/.context-config.template.json`**
   ```json
   {
     "version": "1.1.0",  // <-- HERE
     "metadata": {
       "configVersion": "1.1.0"  // <-- AND HERE
     }
   }
   ```

2. **`CHANGELOG.md`**
   ```markdown
   ## [Unreleased]

   ## [1.1.0] - 2025-10-04  // <-- ADD NEW VERSION SECTION

   ### Added
   - List of changes...
   ```

3. **`README.md`** (if displayed there)
   ```markdown
   **Current Version:** 1.1.0  // <-- UPDATE IF PRESENT
   ```

### Workflow for ANY Change

```bash
# 1. Make your changes
# ...

# 2. Update version number in config/.context-config.template.json
# Change "version": "1.0.0" to "1.1.0" (or appropriate increment)

# 3. Update CHANGELOG.md
# Move [Unreleased] items to new version section

# 4. Commit with version in message
git commit -m "Version 1.1.0: [description of changes]"

# 5. Tag the release
git tag -a v1.1.0 -m "Version 1.1.0"
git push origin v1.1.0
```

### Version Update Checklist

Before committing ANY change:

- [ ] Updated `version` in `config/.context-config.template.json`
- [ ] Updated `configVersion` in metadata section
- [ ] Updated `CHANGELOG.md` with new version section
- [ ] Commit message includes version number
- [ ] Tagged release with `git tag -a v1.x.x`

### Examples

**Adding a new command:**
```
1.0.0 → 1.1.0 (MINOR - new feature)
```

**Fixing typo in template:**
```
1.0.0 → 1.0.1 (PATCH - documentation fix)
```

**Renaming a command:**
```
1.0.0 → 2.0.0 (MAJOR - breaking change)
```

**Adding new template section (optional):**
```
1.0.0 → 1.1.0 (MINOR - enhancement)
```

### What Happens If You Forget

If version isn't updated:
- `/update-context-system` sees 1.0.0 locally, 1.0.0 on GitHub
- Reports "Already up to date"
- BUT still downloads and updates commands
- **Confusing and misleading to users**

### Testing Updates

After incrementing version:

```bash
# Test in example project
cd ../examples/test-update
/update-context-system

# Should see:
# 📦 Update available: v1.0.0 → v1.1.0
# ✅ Updated commands
```

### Quick Reference

**ANY change = version bump**
- New command? MINOR
- Fix bug? PATCH
- Breaking change? MAJOR
- Documentation improvement? PATCH
- New template section? MINOR
- Template typo? PATCH

**When in doubt:** Increment PATCH at minimum.

### History Tracking

Keep CHANGELOG.md complete:
- Every version gets a section
- List all changes under Added/Changed/Fixed/Removed
- Include date of release
- Link to GitHub releases if applicable

### Git Tags

Always tag releases:
```bash
git tag -a v1.1.0 -m "Version 1.1.0: Added quick-save-context, export-context, validate-context"
git push origin v1.1.0
```

Tags make it easy to:
- See version history
- Download specific versions
- Reference in documentation

---

## Critical: .claude Directory Location

**IMPORTANT:** There should only be ONE `.claude` directory per project.

### The Problem

If a project is nested inside another folder that has a `.claude` directory:
```
parent-folder/
├── .claude/            ← PROBLEM: Parent has .claude
│   └── commands/
└── my-project/
    ├── .claude/        ← Project also has .claude
    │   └── commands/
    └── context/
```

**What happens:**
- Claude Code may load commands from the parent folder instead of the project
- Commands get out of sync
- Updates don't work correctly
- Very confusing experience

### The Solution

**Only keep `.claude` in the actual project root:**
```
parent-folder/          ← No .claude here (unless this IS a project)
└── my-project/
    ├── .claude/        ← Only here
    │   └── commands/
    └── context/
```

**Fix existing conflicts:**
```bash
# If parent folder is NOT a project itself:
rm -rf parent-folder/.claude

# If parent folder IS a project:
# Move nested project out of it
```

### Verification

Both `/init-context` and `/migrate-context` now check for this issue and warn you.

---

## Remember

**If you changed ANYTHING, increment the version.**

No exceptions. Users depend on accurate versioning.
