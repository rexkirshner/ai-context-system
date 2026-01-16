# Future Upgrades

This folder contains potential features and improvements that were considered but deferred to future releases.

## Purpose

- Document features that were planned but not implemented
- Provide context for future development decisions
- Avoid repeating analysis work
- Track what users have requested vs what's been delivered

## Status Legend

- 📋 **Planned** - Design complete, ready to implement
- 🤔 **Proposed** - Idea documented, needs design/validation
- ⏸️ **Deferred** - Was planned for a release but postponed
- ❌ **Rejected** - Considered and decided against

## Future Upgrade Documents

### Deferred from v3.3.0

- **sync-commits.md** - ⏸️ Multi-developer commit synchronization command
  - Originally planned for v3.3.0 Day 3
  - Deferred to v3.3.1 or v3.4.0
  - Experimental feature, limited user feedback (2 projects)

### Proposed for v3.4.0+

- **priority-2-template-markers.md** - 🤔 Additional template markers
  - AI header files (aider, cursor, codex, generic)
  - STATUS.template.md structural markers
  - DECISIONS.template.md structural markers
  - Lower priority than v3.3.0 Priority 1

- **session-archiving.md** - 🤔 Archive old sessions
  - Move completed sessions to archive files
  - Keep SESSIONS.md manageable
  - Current append-only works fine

- **note-command.md** - 🤔 Quick note-taking command
  - Lightweight alternative to /save
  - Only if /save can't be optimized
  - User feedback needed

- **interactive-init.md** - 🤔 Guided initialization
  - Walk users through template customization
  - Only if template markers aren't sufficient
  - Test Priority 1 markers first

- **developer-profiles.md** - 🤔 Team member attribution
  - Track who worked on what
  - Wait for more multi-developer teams
  - Only 1 team provided feedback so far

## Adding New Future Upgrades

When deferring a feature:

1. Create a markdown file in this directory
2. Use the template below
3. Document the decision rationale
4. Link to any related planning documents

### Template

```markdown
# [Feature Name]

**Status**: [Planned/Proposed/Deferred/Rejected]
**Originally Planned For**: [Version]
**Deferred To**: [Version or "TBD"]
**Priority**: [High/Medium/Low]

## Problem Statement

[What problem does this solve?]

## Proposed Solution

[Brief description of the solution]

## Why Deferred

[Reasoning for postponing this feature]

## User Feedback

[What users have said about this need]

## Design Notes

[Link to any design documents or planning]

## Implementation Complexity

[Estimated effort: Hours/Days/Weeks]

## Dependencies

[What else needs to be in place first]

## Decision Criteria

[What would make us implement this in the future?]
```

## Review Process

Future upgrades should be reviewed periodically:

- After each release
- When user feedback mentions the feature
- When related features are being implemented
- Quarterly planning reviews

---

*This folder helps us say "no, but later" instead of just "no" to good ideas.*
