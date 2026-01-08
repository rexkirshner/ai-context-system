# AI Context System Troubleshooting Guide

**Purpose:** Quick solutions to common issues
**See also:** [CHANGELOG.md](../../CHANGELOG.md) for version history

---

## Quick Diagnostics

Run `/validate-context` first. It identifies most issues automatically.

```bash
/validate-context
```

---

## Common Issues

### 1. CLAUDE.md Not Auto-Loading

**Symptom:** Claude doesn't seem to know your project context at conversation start.

**Cause:** CLAUDE.md is in the wrong location.

**Solution:**
```bash
# Check current location
ls -la CLAUDE.md context/claude.md 2>/dev/null

# If in context/ folder, move it:
mv context/claude.md ./CLAUDE.md
```

**Correct locations for auto-loading:**
- `./CLAUDE.md` (project root) - Recommended
- `./.claude/CLAUDE.md` (alternative)

**Wrong location:**
- `context/claude.md` - NOT auto-loaded

---

### 2. "Context directory not found"

**Symptom:** Commands fail with "context directory not found" error.

**Cause:** Running commands from wrong directory or context not initialized.

**Solutions:**

1. **Navigate to project root:**
   ```bash
   cd /path/to/your/project
   ```

2. **Initialize context if missing:**
   ```bash
   /init-context
   ```

3. **Check if context exists:**
   ```bash
   ls -la context/
   ```

---

### 3. "jq: command not found"

**Symptom:** Commands fail when validating JSON files.

**Cause:** `jq` JSON processor not installed.

**Solution:**
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# Fedora/RHEL
sudo dnf install jq

# Windows (with chocolatey)
choco install jq
```

**Workaround:** Commands will continue with reduced functionality if jq is missing.

---

### 4. Download Failures During Update

**Symptom:** `/update-context-system` fails with network errors.

**Causes:**
- No internet connection
- GitHub is down or rate-limited
- Firewall blocking connections

**Solutions:**

1. **Check connectivity:**
   ```bash
   curl -I https://github.com
   ```

2. **Retry with verbose output:**
   ```bash
   curl -v https://raw.githubusercontent.com/rexkirshner/ai-context-system/main/VERSION
   ```

3. **Check GitHub status:** https://www.githubstatus.com/

4. **Try again later:** GitHub rate limits may have been hit.

---

### 5. Invalid JSON in Config Files

**Symptom:** `/validate-context` reports invalid JSON.

**Cause:** Syntax error in `.context-config.json` or session files.

**Solutions:**

1. **Validate JSON syntax:**
   ```bash
   # Using jq
   jq . context/.context-config.json

   # Using python
   python3 -c "import json; json.load(open('context/.context-config.json'))"
   ```

2. **Common JSON errors:**
   - Trailing commas: `{"key": "value",}` - Remove trailing comma
   - Missing quotes: `{key: "value"}` - Add quotes around key
   - Single quotes: `{'key': 'value'}` - Use double quotes

3. **Reset to template:**
   ```bash
   cp templates/.context-config.template.json context/.context-config.json
   ```

---

### 6. Session Numbers Out of Sync

**Symptom:** Duplicate session numbers or gaps in session history.

**Cause:** Manual editing of SESSIONS.md or interrupted saves.

**Solution:**
```bash
# Check current session count
grep "^## Session " context/SESSIONS.md | head -10

# Re-number if needed (manual review recommended)
# The system will auto-detect next number on next save
```

---

### 7. "Permission denied" Errors

**Symptom:** Cannot read or write context files.

**Cause:** Incorrect file permissions.

**Solutions:**

1. **Fix permissions:**
   ```bash
   chmod 644 context/*.md context/*.json
   chmod 755 context/
   chmod 755 scripts/*.sh
   ```

2. **Check ownership:**
   ```bash
   ls -la context/
   # Should be owned by your user
   ```

---

### 8. Commands Not Found

**Symptom:** `/save`, `/validate-context`, etc. don't work.

**Cause:** Commands not in `.claude/commands/` or incorrect format.

**Solutions:**

1. **Check commands exist:**
   ```bash
   ls .claude/commands/
   ```

2. **Re-run installer:**
   ```bash
   curl -sSL https://aicontextsystem.com/install | bash
   ```

3. **Update system:**
   ```bash
   /update-context-system
   ```

---

### 9. Git Operations Failing

**Symptom:** Context system commands fail on git operations.

**Cause:** Not in a git repository or git not configured.

**Solutions:**

1. **Initialize git:**
   ```bash
   git init
   ```

2. **Check git status:**
   ```bash
   git status
   ```

3. **Configure git (if needed):**
   ```bash
   git config user.name "Your Name"
   git config user.email "your@email.com"
   ```

---

### 10. Backup/Rollback Issues

**Symptom:** Can't restore from backup after failed update.

**Solution:**

1. **Find backup:**
   ```bash
   ls -la .context-backup-*
   ```

2. **Rollback manually:**
   ```bash
   # Replace YYYYMMDD-HHMMSS with actual backup timestamp
   cp -r .context-backup-YYYYMMDD-HHMMSS/context .
   cp -r .context-backup-YYYYMMDD-HHMMSS/.claude .
   ```

3. **Verify restoration:**
   ```bash
   /validate-context
   ```

---

## Version-Specific Issues

### Upgrading from v3.5.x to v3.6.x

**Breaking change:** CLAUDE.md location moved from `context/claude.md` to project root.

See: [MIGRATION_v3.5_to_v3.6.md](./MIGRATION_v3.5_to_v3.6.md)

**Quick fix:**
```bash
# Move existing file
mv context/claude.md ./CLAUDE.md

# Or create fresh from template
cp templates/CLAUDE.md.template ./CLAUDE.md
```

---

### Upgrading from v2.x to v3.x

**Major changes:**
- Quick Reference consolidated into STATUS.md
- New session format with Mental Models
- Configuration schema changes

**Solution:** Run `/update-context-system` which handles migrations automatically.

---

## Debug Mode

For detailed troubleshooting, enable verbose output:

```bash
# Set verbosity before running commands
export VERBOSITY=debug

# Then run the command
/validate-context

# Reset to normal
unset VERBOSITY
```

---

## Getting Help

### Self-Help Resources

1. **Validate system:** `/validate-context`
2. **Check templates:** `ls templates/`
3. **Read documentation:** `.claude/docs/`
4. **Review changelog:** `CHANGELOG.md`

### Reporting Issues

If the above doesn't help:

1. **Gather diagnostics:**
   ```bash
   # System info
   cat VERSION
   uname -a

   # Context state
   /validate-context

   # Error details
   # Copy the exact error message
   ```

2. **Report issue:** https://github.com/rexkirshner/ai-context-system/issues

3. **Include:**
   - System version (from VERSION file)
   - Operating system
   - Error message (exact text)
   - Steps to reproduce
   - Output of `/validate-context`

---

## Prevention Tips

### Regular Maintenance

1. **Weekly:** Run `/validate-context`
2. **Before major changes:** Create backup with `/update-context-system`
3. **After updates:** Verify with `/review-context`

### Best Practices

1. **Don't edit JSON files manually** - Use commands or templates
2. **Keep VERSION file intact** - It's the source of truth
3. **Commit context changes** - Protect your work
4. **Use `/save` regularly** - Prevent data loss

---

**Version:** 3.6.0
**Last Updated:** 2024-12-16
