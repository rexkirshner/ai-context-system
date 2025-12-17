# Migration Guide: v3.5.x to v3.6.0

**Version:** 3.6.0
**Purpose:** Step-by-step migration for the CLAUDE.md location change

---

## What Changed

### Breaking Change: CLAUDE.md Location

| Aspect | v3.5.x (Before) | v3.6.0 (After) |
|--------|-----------------|----------------|
| Location | `context/claude.md` | `./CLAUDE.md` (project root) |
| Case | lowercase | UPPERCASE |
| Auto-loaded | No | Yes |
| Purpose | Same | Same (but now actually works) |

### Why This Matters

Claude Code automatically loads files named `CLAUDE.md` from:
- `./CLAUDE.md` (project root)
- `./.claude/CLAUDE.md` (alternative)

Files in `context/` are **never** auto-loaded. The v3.5.x placement meant users had to manually read the file at the start of each conversation, defeating the purpose of having critical context readily available.

---

## Quick Migration (30 seconds)

If you just want to get it working:

```bash
# Move existing file to project root
mv context/claude.md ./CLAUDE.md

# Verify it worked
ls -la CLAUDE.md
```

Done. Claude Code will now auto-load your CLAUDE.md.

---

## Full Migration (5 minutes)

For the complete upgrade with the enhanced template:

### Step 1: Backup Your Customizations

```bash
# Save your current file
cp context/claude.md context/claude.md.backup
```

### Step 2: Move to New Location

```bash
mv context/claude.md ./CLAUDE.md
```

### Step 3: Update Your System

```bash
/update-context-system
```

This downloads the latest templates and commands.

### Step 4: Consider Template Upgrade

The v3.6.0 template has significant improvements:

**New sections in v3.6.0 template:**
- Project Identity (project name, tech stack, phase)
- Critical Rules (git push protocol, no lazy coding, simplicity)
- Working Style (communication, complex vs simple tasks)
- Debugging Protocol (trace code flow, no assumptions)
- Before Committing Checklist (dev environment verification)
- Session Management (commands reference)
- Context Files Table (links to all docs)
- Project-Specific Notes (constraints, gotchas)

**Options:**

A. **Keep your existing content** (no action needed)
   - Your customizations are preserved
   - Works fine, just located correctly now

B. **Merge with new template** (recommended)
   ```bash
   # View new template
   cat templates/CLAUDE.md.template

   # Edit CLAUDE.md and add sections you want
   ```

C. **Start fresh with new template**
   ```bash
   # Backup first
   cp CLAUDE.md CLAUDE.md.custom

   # Copy new template
   cp templates/CLAUDE.md.template ./CLAUDE.md

   # Fill in project-specific sections
   ```

### Step 5: Verify Migration

```bash
/validate-context
```

Should show:
- `CLAUDE.md` at root
- No warning about old location

---

## Migration Scenarios

### Scenario A: You have `context/claude.md`

This is the most common case.

```bash
mv context/claude.md ./CLAUDE.md
```

### Scenario B: You already have `./CLAUDE.md`

No action needed. You're already set up correctly.

### Scenario C: You have both files

This shouldn't happen, but if it does:

```bash
# Review both files
diff context/claude.md ./CLAUDE.md

# Decide which to keep (usually root version)
# Then remove the old one
rm context/claude.md
```

### Scenario D: You have neither file

```bash
# Create from template
cp templates/CLAUDE.md.template ./CLAUDE.md

# Fill in project-specific sections
```

### Scenario E: Your file is heavily customized

```bash
# 1. Move it first
mv context/claude.md ./CLAUDE.md

# 2. Review the new template for ideas
cat templates/CLAUDE.md.template

# 3. Add any new sections you want to your existing file
```

---

## What If Something Goes Wrong

### Rollback to v3.5.x behavior

```bash
# Move file back (not recommended, but possible)
mv ./CLAUDE.md context/claude.md
```

Note: This restores old behavior where CLAUDE.md is not auto-loaded.

### Restore from backup

```bash
# If you created a backup
cp context/claude.md.backup ./CLAUDE.md
```

### Start completely fresh

```bash
# Remove and reinitialize
rm -f CLAUDE.md context/claude.md
/init-context
```

---

## Verification Checklist

After migration, verify:

- [ ] `CLAUDE.md` exists at project root (`ls -la CLAUDE.md`)
- [ ] No file at old location (`! ls context/claude.md 2>/dev/null`)
- [ ] `/validate-context` passes
- [ ] Start new Claude conversation and verify context is loaded

---

## Automated Migration

The `/update-context-system` command includes migration assistance:

1. Detects old location automatically
2. Offers interactive migration options:
   - **MOVE**: Preserves your customizations
   - **CREATE**: Uses new template
   - **SKIP**: Handle manually

```bash
/update-context-system

# When prompted about CLAUDE.md migration, choose option 1 (MOVE)
```

---

## FAQ

### Q: Will Claude forget my project context?

No. Moving the file preserves all content. Claude will actually load it better now (automatically instead of manually).

### Q: What about other AI tools (Cursor, Aider)?

They continue to use `context/cursor.md`, `context/aider.md`, etc. Only CLAUDE.md moved because only Claude Code has auto-loading behavior.

### Q: Do I need to update my .gitignore?

No. The file name didn't change, just the location.

### Q: What if I skip migration?

Your existing `context/claude.md` will continue to work, but you'll need to manually read it at the start of each conversation. The auto-loading benefit is only available when the file is at project root.

---

## Related Documentation

- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Common issues and solutions
- [CHANGELOG.md](../../CHANGELOG.md) - Full v3.6.0 release notes
- [update-guide.md](./update-guide.md) - General update process

---

**Version:** 3.6.0
**Last Updated:** 2024-12-16
