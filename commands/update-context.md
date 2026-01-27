# /update-context

Update CLAUDE.md and AGENTS.md with **permanent, repo-specific learnings** from this session.

Run before `/compact` or when context is long.

## Goal

Make future sessions faster by capturing only what will still matter later.

## Extract (permanent)

Only include items true about the PROJECT that will remain useful:
- **Commands** — actually used/verified (run, test, build, deploy)
- **Constraints** — "don't touch X", "must use Y"
- **Patterns** — architecture, naming, folder structure conventions
- **Quirks** — non-obvious gotchas
- **Preferences** — workflow choices that affect *this repo* (formatting, tools, review style)

## Ignore (ephemeral)

Do NOT include things true only about right now:
- Current task, temporary blockers, WIP state, TODOs, timestamps, debugging notes

**Heuristic:** Affects future sessions → keep. About this moment → drop.

## Hard Rules

- **No guessing.** Only record commands/conventions verified from repo files or session evidence. If unsure, omit. Evidence: README, package scripts, Makefile, CI config, tool output, successful command runs.
- **No secrets.** Never write API keys, tokens, private URLs, or credentials into context files.
- **No placeholders.** If a section would be empty, omit the section entirely.
- **Idempotent.** Running twice with no new learnings = zero changes.
- **Minimal diff.** Don't reorder sections or reformat unless needed to add/merge/remove a bullet.
- **Deduplicate.** Merge near-duplicates; keep the most specific version.
- **Tight bullets.** Short, imperative. ≤120 chars when possible. No paragraphs.
- **No filler.** If it's not repo-specific, don't add it.
- **Repo-scoped preferences only.** Skip personal preferences unless they change how the codebase should be handled.
- **Size limit enforcement.** If over limit (<50 small, <100 complex): merge bullets, remove low-signal items first (Preferences → Quirks → Patterns), always keep Constraints and verified Commands.

## Do

1. Read CLAUDE.md and AGENTS.md (if missing, create both — use repo folder name as Project Name, or "Project" if unknown)
2. Extract candidate learnings; filter out ephemeral items
3. Update content:
   - Add new learnings to appropriate section
   - Edit outdated bullets (minimal edits)
   - Remove stale/incorrect bullets
   - Normalize phrasing + dedupe
4. Mirror: produce ONE canonical markdown text, write byte-for-byte to both files
5. Verify: re-read both files and confirm identical; if not, fix
6. Report changes (structured):
   ```
   + Added: [section] → [bullet]
   - Removed: [section] → [bullet]
   ~ Edited: [before] → [after]

   CLAUDE.md: N lines
   AGENTS.md: N lines (identical)
   ```

## File Structure

```markdown
# [Project Name]

[One-line description]

## Commands
- Run: `...`
- Test: `...`
- Build: `...`
- Deploy: `...`
```
Use exactly these labels: `Run:`, `Test:`, `Build:`, `Deploy:` (each at most once, only if verified). Omit any that don't apply.

```markdown
## Constraints
- ...

## Patterns
- ...

## Quirks
- ...

## Preferences
- ...
```
Omit any section that would be empty.

If nothing new: "No new learnings. Context files unchanged."
