---
name: init-context
description: Creates CLAUDE.md, context/STATUS.md, and context/DECISIONS.md if they don't exist
---

# /init-context

Initialize context files for a project. Safe to run - never overwrites existing files.

## What to Create

### 1. CLAUDE.md (in project root)

If CLAUDE.md doesn't exist, create it:

```markdown
> **Session Loop**
> 1. Start → Read `context/STATUS.md`
> 2. End → Run `/save`

# [Project Name]

[One paragraph: what this is, what it does.]

## Commands

Run: `[command]`
Test: `[command]`
Build: `[command]`

## Constraints

- Don't refactor unrelated code
- Keep PRs under 300 lines
- If you need to touch files outside Working Set, pause, propose, update Working Set, then proceed

## Context

- Status: `context/STATUS.md`
- Decisions: `context/DECISIONS.md`

## Notes

- [Project-specific conventions]
```

Ask the user for project name and fill in the bracketed sections based on:
- Package.json (if exists)
- Build files (Makefile, build.gradle, etc.)
- Existing README.md

### 2. context/STATUS.md

If context/STATUS.md doesn't exist, create the context directory and file:

```markdown
# Status

SchemaVersion: 1
LastUpdated: [today's date YYYY-MM-DD]
HeadCommit: [run: git rev-parse --short HEAD]
Objective: [ask user or leave as "TBD"]

## Working Set

- [3-7 files/directories to start with, or "TBD"]

## Next Actions

- [Initial next steps, or "TBD"]

## Blocked On

- (None)
```

### 3. context/DECISIONS.md

If context/DECISIONS.md doesn't exist, create it:

```markdown
# Decisions

Append-only log.

---
```

## Behavior

1. Check which files exist
2. Only create missing files
3. For existing files, report "Already exists: [filename]"
4. For created files, report "Created: [filename]"
5. If CLAUDE.md is created, ask user to review and customize it

## Done

Report what was created vs already existed.
