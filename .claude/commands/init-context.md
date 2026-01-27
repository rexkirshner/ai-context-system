---
name: init-context
description: Initialize or migrate context files for a project
---

# /init-context

Initialize context files for a new project, or complete migration from pre-v6 versions.

## Step 1: Detect Migration State

Check for pre-v6 context files:
- `context/SESSIONS.md` exists?
- `context/CONTEXT.md` exists?
- `context/STATUS.md` exists and contains `## Quick Reference` or `## Current Phase`?

**If any of these are true → this is a post-migration state. Go to "Migration Mode" below.**

**If none are true → this is a fresh install or already v6. Go to "Normal Mode" below.**

---

## Migration Mode

This project has old context files from pre-v6. Extract valuable information and create v6.0 files.

### 1. Read Old Files

Read any that exist:
- `context/SESSIONS.md` — session history, recent work
- `context/CONTEXT.md` — project context, description
- `context/STATUS.md` — current objective, work in progress
- `context/DECISIONS.md` — past decisions

Extract:
- Current objective/goal
- Recent work and context
- Any decisions worth preserving
- Working files mentioned

### 2. Create/Update STATUS.md (v6.0 format)

Write `context/STATUS.md` with this exact format:

```markdown
# Status

SchemaVersion: 1
LastUpdated: [today's date YYYY-MM-DD]
HeadCommit: [run: git rev-parse --short HEAD, or "N/A"]
Objective: [extracted from old files]

## Working Set

- [3-7 files/directories extracted from old context]

## Next Actions

- [extracted from old files, or "TBD"]

## Blocked On

- (None)
```

### 3. Create/Update DECISIONS.md (v6.0 format)

If `context/DECISIONS.md` exists with old format entries, preserve them. Write with this format:

```markdown
# Decisions

Append-only log.

---

## YYYY-MM-DD: [Area] Decision Title
Why: [reason]
Tradeoff: [what we gave up]
RevisitWhen: [trigger to revisit]
```

Old format entries (Context/Decision/Rationale) can remain — just ensure new entries use v6.0 format.

### 4. Update CLAUDE.md

Check if CLAUDE.md has the Session Loop block (look for "Session Loop" or "Read `context/STATUS.md`").

If missing, add this block at the very top of CLAUDE.md:

```markdown
> **Session Loop**
> 1. Start → Read `context/STATUS.md`
> 2. End → Run `/save`

```

### 5. Delete Old Files

```bash
rm -f context/SESSIONS.md context/CONTEXT.md
```

### 6. Report

```
Migration complete:
  ✓ STATUS.md updated to v6.0 format
  ✓ DECISIONS.md updated to v6.0 format
  ✓ CLAUDE.md has Session Loop
  ✓ Old files removed (SESSIONS.md, CONTEXT.md)

Run /save to verify everything works.
```

---

## Normal Mode

For fresh installs or projects already on v6.0.

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

**Detecting project info:**
1. Check `package.json` for `name` field → use as project name
2. Check `README.md` for title (first `#` heading) → use as project name
3. If neither exists, use the directory name or ask the user

Fill in bracketed sections by reading:
- `package.json` scripts for run/test/build commands
- `Makefile`, `build.gradle`, `Cargo.toml`, etc. for build commands
- `README.md` for project description

**If CLAUDE.md already exists**, check if it contains the Session Loop block. If not found:

> **Important:** Your existing CLAUDE.md doesn't include the Session Loop. Add this block to the top:
>
> ```markdown
> > **Session Loop**
> > 1. Start → Read `context/STATUS.md`
> > 2. End → Run `/save`
> ```

### 2. context/STATUS.md

If context/STATUS.md doesn't exist:
1. Create the context directory: `mkdir -p context/`
2. Create the file:

```markdown
# Status

SchemaVersion: 1
LastUpdated: [today's date YYYY-MM-DD]
HeadCommit: [run: git rev-parse --short HEAD, or "N/A" if not a git repo]
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

### 4. Report

For each file:
- "Already exists: [filename]" if it existed
- "Created: [filename]" if it was created

If CLAUDE.md is created, ask user to review and customize it.
