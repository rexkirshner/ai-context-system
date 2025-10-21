# v3 Codex Suggestions

## Documentation & Messaging
- Update planning docs to introduce the new name up front (e.g. headers in `comprehensive-rename-evaluation.md`, `strategic-analysis.md`, `rename-analysis.md`) so reviewers aren’t toggling between legacy and target branding.
- Create a "terminology guardrail" list clarifying what stays Claude-specific (`claude.md`, command examples) versus what must switch to AI Context System to prevent over-zealous find/replace passes.
- Compile a search matrix covering case variants and hyphenated forms (`"Claude Context System"`, `"claude context system"`, `"claude-context-system"`, repo slugs) to ensure nothing slips through.
- Normalize version references in published docs (current README shows 2.3.2, later section says 2.2.0) while prepping the v3 launch copy; it helps avoid mixed-version messaging during the rebrand.

## Migration & Testing
- Expand the testing matrix to include custom-content edge cases for the feedback file migration (large files, unusual frontmatter, non-ASCII characters) to validate the archive logic before v3 ships.
- Document a manual verification checklist for `/update-context-system` covering both success (new `context-feedback.md` populated) and rollback (restoring archived content) so contributors can follow consistent QA steps.
- Add a regression test note for new installs ensuring `/init-context` seeds `context-feedback.md` and never creates the legacy filename, preventing drift as templates evolve.

## Tooling & Process
- Script the rename workflow (bash or Python) to batch-update docs and commands; checking this into `scripts/` lets future contributors rerun the transformation and audit diffs.
- Plan a one-time CI job or local lint script that fails builds if `Claude Context System` appears outside approved historical sections (e.g. old changelog entries), giving ongoing enforcement.
- Capture the Git remotes update procedure after the repo rename (old origin removal, new origin add, fetch/verify) in the roadmap so contributors remember to realign their local clones.

## Communication & Launch
- In the user communication plan, explicitly acknowledge "AI Context System (formerly Claude Context System)" through the first release cycle to help searchers land in the right place.
- Prepare an FAQ entry explaining why `claude.md` remains (Claude-specific entry point) to defuse confusion once the broader branding switches to AI Context System.
- Consider adding social proof or testimonials to the launch announcement that emphasize multi-AI success stories—helps signal the rebrand is additive, not a pivot away from Claude.
