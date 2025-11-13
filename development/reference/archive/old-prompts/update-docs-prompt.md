---
description: Update all meta-documentation to reflect current code state
---

Please review the codebase and update all meta-documentation to accurately reflect the current state of the project.

**When to use this command:**
- After completing a major feature or phase
- Before ending a work session
- When docs feel stale or out of sync
- After making significant technical decisions

## Steps to Follow

### 1. Analyze Current State

**Scan the following to understand what's changed:**
- Recent git commits (last 5-10 commits)
- package.json for dependencies added/removed
- File structure changes (new directories, major files)
- Code in key files to understand architecture
- Build output or error logs if relevant

**Ask yourself:**
- What's been built since docs were last updated?
- What decisions were made?
- What's the current status vs. what docs say?
- Are there new known issues or limitations?

### 2. Update Each Documentation File

**CLAUDE.md:**
- [ ] Update "Development Status" section
- [ ] Add new commands if any npm scripts were added
- [ ] Update "Critical Path" with latest accomplishments
- [ ] Add new architectural patterns if introduced
- [ ] Update file structure if major changes

**PRD.md:**
- [ ] Update version number and status
- [ ] Mark completed phases/milestones as ✅
- [ ] Add new session to Progress Log
- [ ] Update timeline if relevant
- [ ] Move completed items from future to done

**DECISIONS.md:**
- [ ] Document any new technical decisions made
- [ ] Add reasoning for framework/library choices
- [ ] Update "When to reconsider" sections if context changed
- [ ] Add alternatives that were considered and rejected

**KNOWN_ISSUES.md:**
- [ ] Remove fixed issues
- [ ] Add newly discovered issues
- [ ] Update severity (blocking → non-critical if fixed)
- [ ] Add new limitations if design changed
- [ ] Update technical debt section

**tasks/next-steps.md:**
- [ ] Mark completed actions as done
- [ ] Add new immediate next steps
- [ ] Update blockers/unblocked items
- [ ] Refresh success metrics if tracked
- [ ] Update maintenance tasks if new patterns introduced

### 3. Ensure Consistency

**Cross-check between docs:**
- Does CLAUDE.md "Current Status" match PRD.md status?
- Are DECISIONS.md choices reflected in CLAUDE.md architecture?
- Are KNOWN_ISSUES.md blockers mentioned in next-steps.md?
- Is the story coherent across all docs?

### 4. Add Session Summary

**To PRD.md Progress Log, add:**
```markdown
### YYYY-MM-DD - Session [N]
**[Phase Name] [Status]:**
- ✅ [Accomplishment 1]
- ✅ [Accomplishment 2]
- ✅ [Key decision made]
- 🎯 **[Phase Status]**
```

**To CLAUDE.md Critical Path, update:**
```markdown
**Current Status:** [Updated status]

**Completed in Session [N]:**
- ✅ [List key accomplishments]
- ✅ [Updated files/features]

**Key Files Modified/Created:**
- `path/to/file.ts` - [What changed]
```

### 5. Quality Check

**Before finishing, verify:**
- [ ] All checkboxes above are completed
- [ ] Dates are current
- [ ] Version numbers are incremented if appropriate
- [ ] No contradictions between docs
- [ ] A new Claude instance could read and understand
- [ ] "Next steps" are actionable and clear

---

## Output Format

After updating docs, provide a brief summary:

```markdown
## Documentation Update Summary

**Updated Files:**
- CLAUDE.md - Added [X], updated [Y]
- PRD.md - Session [N] logged, marked Phase [X] complete
- DECISIONS.md - Documented decision about [X]
- KNOWN_ISSUES.md - Fixed [X], added [Y]
- tasks/next-steps.md - Updated immediate actions

**Key Changes:**
- [Major change 1]
- [Major change 2]

**Current Status:** [One sentence project status]
```

---

## Important Reminders

**Be thorough but efficient:**
- Don't rewrite everything - update what changed
- Use git history to catch what you might miss
- Focus on material changes, not cosmetic edits

**Think about the reader:**
- Future Claude instances need context
- Future you in 3 months needs to remember why
- New contributors need to get oriented

**Keep it honest:**
- Don't hide issues or technical debt
- Document the "why" behind weird decisions
- Admit when something is hacky or temporary

**Maintain narrative:**
- Docs should tell a coherent story
- Show progression over time
- Connect decisions to outcomes

---

## Example Changes

**Good update:**
```markdown
### 2025-10-02 - Session 6
**Phase 8 - Deployment Ready:**
- ✅ Configured Cloudflare Pages static export
- ✅ Fixed critical image optimization bug (404s on desktop variants)
- ✅ Added OG images for social sharing
- 🎯 **Phase 8 Complete - Deployment Ready!**
```

**Bad update:**
```markdown
### 2025-10-02
- Updated stuff
- Fixed some bugs
```

---

## When to Skip Updates

**You can skip this command when:**
- Only typo fixes or minor cosmetic changes
- Less than 1 hour of work since last update
- No new decisions or learnings
- Just exploring/experimenting (not committing)

**But always update when:**
- Completing a phase/milestone
- Making a significant technical decision
- Discovering a critical issue
- Before ending a long session
- Before deployment
```
