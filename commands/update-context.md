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

- **No guessing.** Only record commands/conventions verified from repo files or session evidence. If unsure, omit.
- **Idempotent.** Running twice with no new learnings = zero changes.
- **Deduplicate.** Merge near-duplicates; keep the most specific version.
- **Tight bullets.** Short, imperative. ≤120 chars. No paragraphs.
- **No filler.** If it's not repo-specific, don't add it.
- **Repo-scoped preferences only.** Skip personal preferences unless they change how the codebase should be handled.

## Do

1. Read CLAUDE.md and AGENTS.md (create both if missing)
2. Extract candidate learnings; filter out ephemeral items
3. Update content:
   - Add new learnings to appropriate section
   - Edit outdated bullets (minimal edits)
   - Remove stale/incorrect bullets
   - Normalize phrasing + dedupe
4. Mirror: produce ONE canonical markdown text, write byte-for-byte to both files
5. Report changes (structured):
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

## Constraints
- ...

## Patterns
- ...

## Quirks
- ...

## Preferences
- ...
```

**Size limit:** <50 lines small repos, <100 lines complex.

If nothing new: "No new learnings. Context files unchanged."
