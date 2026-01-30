# /update-context

Audit the project and update CLAUDE.md and AGENTS.md to accurately reflect its current state.

## Goal

Ensure context files describe the project **as it exists now** — not as it was documented months ago or during a single session.

**Discovery is the primary job.** Finding undocumented commands, patterns, and structure matters more than syncing files.

## Scope

**Only modify CLAUDE.md and AGENTS.md.** Do not edit any other files as part of this command.

## When to Run

- After major refactors or restructuring
- When onboarding to a project you haven't touched in a while
- Periodically to catch documentation drift
- Before handing off to another developer or agent

## Audit Process

**Always scan fresh.** Don't rely on session context or what you "already know" - actually read the files.

1. **Scan the codebase**
   - package.json / Makefile / pyproject.toml (commands, scripts, dependencies)
   - Lock files (package-lock.json, pnpm-lock.yaml, yarn.lock) to identify package manager
   - Directory structure and contents (don't just note existence - check what's inside)
   - Config files (.eslintrc, tsconfig, CI configs)
   - README for stated conventions

2. **Read existing CLAUDE.md and AGENTS.md**
   - If missing, create both using the default structure below
   - If both exist but differ, merge only verified items (drop anything you can't verify from the codebase)

3. **Identify drift**
   - Compare package.json scripts to documented commands - flag any undocumented scripts
   - Commands that changed or no longer exist
   - New directories or patterns not documented
   - Constraints that are no longer true
   - Missing information that would help future sessions

4. **Update content**
   - Preserve existing section order and bullet order
   - Append new bullets at the end of the relevant section
   - Remove stale/incorrect information
   - When deduping, keep the earliest occurrence

5. **Write both files**
   - Generate the final content once
   - Write to both CLAUDE.md and AGENTS.md from the same buffer
   - Confirm they are identical before finishing

## What to Include

Only **permanent, repo-specific facts**:
- **Commands** — verified from package.json, Makefile, or safe execution. Prefer verification from config files; only execute read-only commands when needed.
- **Constraints** — "don't touch X", "must use Y", architectural boundaries
- **Patterns** — folder structure, naming conventions, data flow
- **Quirks** — non-obvious gotchas discovered through use
- **Preferences** — workflow choices that affect this repo

## What to Exclude

- Session-specific state, TODOs, WIP notes
- Timestamps or "last updated" markers
- Secrets, API keys, tokens, credentials
- Stack traces or error logs (summarize the takeaway instead)
- Personal preferences not tied to the repo
- Anything you're guessing rather than verifying

## Hard Rules

- **No guessing.** Only record what's verified from files or execution. If unsure, omit.
- **No risky execution.** Don't run commands that can mutate state (migrate, seed, deploy, reset) to verify them. Treat any command that writes to disk, DB, or network as risky unless clearly documented as dry-run. Prefer inspecting config files. If executing, use `--help`, `--version`, `--dry-run`, or equivalent.
- **No secrets.** Never write credentials into context files.
- **Scope boundary.** Only modify CLAUDE.md and AGENTS.md. Do not edit other files.
- **Idempotent.** Running twice with no project changes = zero file changes.
- **Preserve order.** Don't reorder sections or bullets. Append new items at the end of each section.
- **Preserve header.** Keep project name + description unless clearly wrong.
- **Flexible structure.** Match the project's existing organization if it's already comprehensive. Don't force a rigid template onto rich documentation.
- **Size targets.** Aim for <50 lines (small repos) or <100 lines (complex repos). If over: merge bullets, keep the most-used commands, remove low-signal items.

## Monorepo Guidance

If the project is a monorepo:
- Document root-level workspace commands (install, build, test from root)
- Only include package-specific commands if they're common across packages
- Clearly note the working directory for commands (e.g., "Run from apps/web/")
- Don't explode into per-package minutiae

## Default Structure

Use this structure only when **creating from scratch**. Don't force it onto existing comprehensive documentation.

```markdown
# [Project Name]

[One-line description]

## Commands

- Run: `<command>`
- Test: `<command>`
- Build: `<command>`

## Structure

- `src/` — [purpose]
- `tests/` — [purpose]

## Constraints

- [constraint]

## Quirks

- [gotcha]
```

Omit any section that would be empty.

## Report Format

```
Audited: package.json, src/, tests/, .github/

+ Added: [section] → [bullet]
- Removed: [section] → [bullet]
~ Edited: [before] → [after]

CLAUDE.md: N lines
AGENTS.md: N lines (identical)
```

If nothing changed: "Audit complete. Context files already accurate (no drift found in scripts, structure, or config)."
