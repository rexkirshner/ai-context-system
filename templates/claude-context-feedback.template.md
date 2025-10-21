# Claude Context System - Feedback Log

**Version**: [Your CCS version]
**Project**: [Your project name]

---

## Purpose

This file helps improve the Claude Context System for everyone. Your feedback matters!

**Please document:**
- 🐛 **Bugs** - Errors, unexpected behavior, crashes
- 💡 **Improvements** - Ideas to make CCS better
- ❓ **Questions** - Confusion, unclear documentation
- ✨ **Feature Requests** - New capabilities you'd like
- 👍 **Praise** - What's working well (we need this too!)

---

## Guidelines

**Be specific:**
- Which command? (`/init-context`, `/save-full`, etc.)
- What were you doing?
- What happened vs. what you expected?

**Include context:**
- Operating system (macOS, Linux, Windows)
- Claude Code version
- Project type (web app, CLI, library)

**Suggest solutions:**
- How could this be better?
- What would the ideal behavior be?

**Mark severity:**
- 🔴 **Critical** - Blocking work, data loss, security issue
- 🟡 **Moderate** - Inconvenient, workaround exists
- 🟢 **Minor** - Nice to have, polish

---

## Template

Copy this template for each feedback entry:

```markdown
## YYYY-MM-DD - [Command/Feature] - [Category]

**What happened**: [Clear description of the issue or observation]

**Expected behavior**: [What you thought would happen]

**Actual behavior**: [What actually happened]

**Steps to reproduce** (for bugs):
1. Step one
2. Step two
3. Step three

**Suggestion**: [Your idea for how to improve this]

**Severity**: [🔴 Critical / 🟡 Moderate / 🟢 Minor]

**Environment**:
- OS: [macOS 14.x / Ubuntu 22.04 / Windows 11]
- Claude Code: [version]
- CCS: [version from context/.context-config.json]
```

---

## Feedback Entries

<!-- Add your feedback below this line -->

---

## Examples (Delete after reading)

### Example 1: Bug Report

## 2024-10-21 - /validate-context - Bug 🐛

**What happened**: Running `/validate-context` crashed when SESSIONS.md had emoji in session titles

**Expected behavior**: Validation should handle emoji in markdown files

**Actual behavior**: Got error "invalid byte sequence" and validation stopped

**Steps to reproduce**:
1. Add emoji to session title: `## Session 5 | 2024-10-20 | 🚀 Launch`
2. Run `/validate-context`
3. Error appears

**Suggestion**: Add UTF-8 encoding handling to validation script

**Severity**: 🟡 Moderate (workaround: remove emoji from titles)

**Environment**:
- OS: macOS 14.5
- Claude Code: 1.2.0
- CCS: 2.3.0

---

### Example 2: Feature Request

## 2024-10-21 - /save - Feature Request ✨

**What happened**: Would love auto-save reminder after 30 minutes of work

**Expected behavior**: After 30 min without `/save`, gentle reminder appears

**Suggestion**: Add optional reminder in .context-config.json:
```json
"notifications": {
  "saveReminder": {
    "enabled": true,
    "intervalMinutes": 30
  }
}
```

**Severity**: 🟢 Minor (nice quality of life improvement)

**Environment**:
- OS: Ubuntu 22.04
- Claude Code: 1.1.5
- CCS: 2.3.0

---

### Example 3: Praise

## 2024-10-21 - /organize-docs - Praise 👍

**What happened**: The `/organize-docs` command is AMAZING! Cleaned up 20+ loose files in 2 minutes.

**Why it's great**:
- Interactive and smart (analyzed files before moving)
- Suggested good locations
- Dated historical files automatically
- Kept my project professional

**Suggestion**: None - this is perfect! Maybe add to README as a selling point?

**Severity**: 🟢 (just appreciation!)

---

**Thank you for helping make the Claude Context System better!** 🙏

*Your feedback will be reviewed when you run `/update-context-system` or manually share it with the maintainers.*
