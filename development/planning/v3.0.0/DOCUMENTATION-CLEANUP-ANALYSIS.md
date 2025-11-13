# Documentation Cleanup Analysis

**Date:** 2025-10-22
**Purpose:** Identify obsolete documentation for removal
**Goal:** Reduce bloat in downloads/installs while preserving valuable content

---

## Current State

**Total .md files:** 97 files
**Key directories:**
- `.claude/` - Active system files (commands, docs, checklists)
- `artifacts/` - Historical planning, reviews, research
- `planning/v3.0.0/` - v3.0 planning documents (27 files!)
- `reference/` - Archive of deprecated features
- `docs/` - User-facing documentation
- `templates/` - File templates

---

## Analysis by Directory

### 1. `planning/v3.0.0/` (27 FILES - LARGEST BLOAT)

**Status:** Most are v3.0.0 planning artifacts from the rebrand/release process

#### DEFINITELY OBSOLETE (Recommend DELETE):

**Planning artifacts (completed work):**
- `phase-1-completion-report.md` - Planning phase done, no longer needed
- `phase-3-testing-report.md` - Testing complete
- `phase-5-final-review-report.md` - Final review complete
- `comprehensive-review-report.md` - Duplicate/superseded
- `COMPREHENSIVE_REVIEW_REPORT.md` - Duplicate of above
- `v3-0-0-comprehensive-roadmap.md` - Roadmap completed

**Intermediate analysis (superseded):**
- `rename-analysis.md` - Rename completed
- `comprehensive-rename-evaluation.md` - Rename complete
- `scenario-b-decision-guide.md` - Decision made
- `strategic-analysis.md` - Analysis complete, executed
- `search-matrix.md` - Search analysis done
- `enhanced-testing-matrix.md` - Testing complete
- `terminology-guardrails.md` - Applied, no longer standalone reference

**Codex reviews (historical, not actionable):**
- `v3-codex-suggestions.md` - Evaluated, decisions made
- `v3-codex-feedback.md` - Evaluated, decisions made
- `CODEX_SUGGESTIONS_STATUS.md` - Status tracked, work done
- `roadmap-addendum-codex.md` - Incorporated into work

**Release planning (release complete):**
- `RELEASE_ANNOUNCEMENT.md` - Release published, announcement sent

**Total to delete:** 17 files

#### VALUABLE (Recommend KEEP):

**User feedback analysis (learning from real-world usage):**
- ✅ `real-world-feedback-analysis.md` - Portfolio-tracker lessons (valuable)
- ✅ `project-zebra-feedback-analysis.md` - Multi-dev project lessons (valuable)
- ✅ `ORGANIZE-DOCS-FEEDBACK-RESPONSE.md` - /organize-docs improvements
- ✅ `SAVE-FULL-FEEDBACK-RESPONSE.md` - /save-full improvements (v3.1.0)
- ✅ `organize-docs-validation.md` - Validation results

**Critical fixes documentation:**
- ✅ `CRITICAL-UPGRADE-FAILURE-FIX.md` - Documents v3.0.0-3.0.2 upgrade failures (important history)

**Decision artifacts (why we made choices):**
- ✅ `CODEX_FEEDBACK_EVALUATION.md` - Evaluation reasoning (shows thought process)
- ✅ `CODEX-IMPROVEMENTS-SUMMARY.md` - What we implemented from feedback
- ✅ `faq-claude-md-retention.md` - FAQ explaining claude.md retention (useful)

**Meta documentation:**
- ✅ `README.md` - Index of planning directory

**Total to keep:** 10 files

---

### 2. `artifacts/planning/` (11 FILES - HISTORICAL RELEASES)

**Status:** Planning docs from v2.2.0 and v2.3.0 releases

#### ALL OBSOLETE (Recommend ARCHIVE or DELETE):

**v2.2.0 planning (superseded by v3.0+):**
- `v2.2.0-boundary-feature-summary.md` - Feature shipped in v2.2.0
- `v2.2.0-codex-feedback-response.md` - Addressed in v2.2.0
- `v2.2.0-deferrals.md` - Decisions made
- `v2.2.0-final-summary.md` - Release complete
- `v2.2.0-implementation-plan-final-v2.md` - Implemented
- `v2.2.0-implementation-plan-final.md` - Duplicate
- `v2.2.0-implementation-plan-revised.md` - Superseded by final
- `v2.2.0-implementation-plan.md` - Superseded by revised/final
- `v2.2.0-plan-codex-feedback.md` - Addressed
- `v2.2.0-plan-comparison.md` - Planning complete
- `v2.2.0-revised-scope.md` - Scope executed

**v2.2.1 planning:**
- `2024-10-v2.2.1-organization-plan.md` - Feature shipped

**v2.3.0 planning:**
- `v2.3.0-implementation-plan.md` - Implemented
- `v2.3.0-removal-plan.md` - Removals done

**Total to delete:** 14 files (ALL of them)

**Rationale:** These are all completed planning docs from old releases. The features shipped, decisions made, work done. No ongoing reference value.

---

### 3. `artifacts/reviews/` (1 FILE)

- `2024-10-code-review-v2.2.2.md` - Code review from Oct 2024

**Recommendation:** DELETE - Historical code review, issues addressed or superseded by later work

---

### 4. `artifacts/research/` (1 FILE)

- `2024-10-codex-analysis-v2.1.0.md` - Codex analysis from v2.1.0

**Recommendation:** DELETE - Analysis from old version, superseded by v3 work

---

### 5. `reference/archive/` (6 FILES)

**Status:** Archive of deprecated/abandoned features

#### Current contents:
- `abandoned-features/README.md` - Index of abandoned features
- `legacy-code-review-with-fixes.md` - Old code review approach
- `old-prompts/post-init-docs.md` - Old prompt
- `old-prompts/review-docs-prompt.md` - Old prompt
- `old-prompts/update-docs-prompt.md` - Old prompt
- `old-prompts/validate-context-OLD.md` - Old validation

**Recommendation:** KEEP ALL (6 files)
**Rationale:** These are intentionally archived. They're already in `reference/archive/` which signals "historical reference." Small file count, useful for understanding evolution.

---

### 6. `reference/` ROOT (2 FILES)

- `DEPRECATIONS.md` - List of deprecated features
- `README.md` - Index of reference directory

**Recommendation:** KEEP BOTH
**Rationale:** Active reference documentation. Users need to know what's deprecated.

---

### 7. `docs/` (5 FILES in subdirectories)

**docs/architecture/:**
- `PRD.md` - Product requirements document
- `STRUCTURE.md` - System structure documentation

**docs/migration/:**
- `MIGRATION_GUIDE.md` - Generic migration guide
- `v2.0-to-v2.1.md` - v2.0→v2.1 migration
- `v2.1-to-v2.2.md` - v2.1→v2.2 migration

**docs/setup/:**
- `SETUP_GUIDE.md` - Setup documentation

**Recommendation:** UNCERTAIN - Need your input

**Questions:**
1. Are `docs/architecture/` files still accurate and useful?
2. Do we need old migration guides (v2.0→v2.1, v2.1→v2.2) now that we have `MIGRATION_GUIDE_v2_to_v3.md` at root?
3. Is `docs/setup/SETUP_GUIDE.md` redundant with README.md or still valuable?

---

### 8. `templates/legacy/` (4 FILES)

- `next-steps.template.md` - Old template
- `QUICK_REF.template.md` - Old Quick Reference (now in STATUS.md)
- `README.md` - Index of legacy templates
- `todo.template.md` - Old todo template

**Recommendation:** KEEP ALL (4 files)
**Rationale:** Small, already marked as legacy, useful for understanding v1.x→v2.x migration

---

### 9. `.claude/` (ACTIVE SYSTEM FILES)

**commands/:** 13 active commands ✅ KEEP ALL
**docs/:** 7 active documentation files ✅ KEEP ALL
**checklists/:** 4 active checklists ✅ KEEP ALL

**Recommendation:** KEEP ALL (24 files) - These are the core active system

---

### 10. `scripts/` (1 FILE)

- `LEGACY-SCRIPTS.md` - Documentation of legacy scripts

**Recommendation:** KEEP
**Rationale:** Useful reference, small

---

### 11. ROOT LEVEL (3 KEY FILES)

- `README.md` ✅ KEEP - Project readme
- `CHANGELOG.md` ✅ KEEP - Version history
- `MIGRATION_GUIDE_v2_to_v3.md` ✅ KEEP - Active migration guide
- `ORGANIZATION.md` ✅ KEEP - Organization guidelines

---

## Summary by Action

### DELETE (47 files total)

**planning/v3.0.0/ (17 files):**
1. phase-1-completion-report.md
2. phase-3-testing-report.md
3. phase-5-final-review-report.md
4. comprehensive-review-report.md
5. COMPREHENSIVE_REVIEW_REPORT.md
6. v3-0-0-comprehensive-roadmap.md
7. rename-analysis.md
8. comprehensive-rename-evaluation.md
9. scenario-b-decision-guide.md
10. strategic-analysis.md
11. search-matrix.md
12. enhanced-testing-matrix.md
13. terminology-guardrails.md
14. v3-codex-suggestions.md
15. v3-codex-feedback.md
16. roadmap-addendum-codex.md
17. RELEASE_ANNOUNCEMENT.md

**artifacts/planning/ (14 files - ALL):**
1. v2.2.0-boundary-feature-summary.md
2. v2.2.0-codex-feedback-response.md
3. v2.2.0-deferrals.md
4. v2.2.0-final-summary.md
5. v2.2.0-implementation-plan-final-v2.md
6. v2.2.0-implementation-plan-final.md
7. v2.2.0-implementation-plan-revised.md
8. v2.2.0-implementation-plan.md
9. v2.2.0-plan-codex-feedback.md
10. v2.2.0-plan-comparison.md
11. v2.2.0-revised-scope.md
12. 2024-10-v2.2.1-organization-plan.md
13. v2.3.0-implementation-plan.md
14. v2.3.0-removal-plan.md

**artifacts/reviews/ (1 file):**
1. 2024-10-code-review-v2.2.2.md

**artifacts/research/ (1 file):**
1. 2024-10-codex-analysis-v2.1.0.md

**Also delete empty directories after cleanup:**
- artifacts/planning/ (will be empty)
- artifacts/reviews/ (will be empty)
- artifacts/research/ (will be empty)
- artifacts/ (will be empty)

---

### KEEP (50 files) - Active/Valuable

**planning/v3.0.0/ (10 files):**
- Real-world feedback analysis files (5)
- Critical fixes documentation (1)
- Codex evaluation reasoning (3)
- README.md (1)

**.claude/ (24 files):**
- All commands, docs, checklists

**reference/ (8 files):**
- All archive and deprecation docs

**templates/ (15 files including legacy/)**
- All templates

**Root (4 files):**
- README.md, CHANGELOG.md, MIGRATION_GUIDE_v2_to_v3.md, ORGANIZATION.md

**scripts/ (1 file):**
- LEGACY-SCRIPTS.md

---

### UNCERTAIN - NEED YOUR INPUT (5 files in docs/)

**docs/architecture/:**
- PRD.md - Still accurate? Still useful?
- STRUCTURE.md - Still accurate? Still useful?

**docs/migration/:**
- MIGRATION_GUIDE.md - Redundant with root MIGRATION_GUIDE_v2_to_v3.md?
- v2.0-to-v2.1.md - Needed anymore?
- v2.1-to-v2.2.md - Needed anymore?

**docs/setup/:**
- SETUP_GUIDE.md - Redundant with README.md?

---

## Impact Analysis

### File Count Reduction

**Before cleanup:**
- Total .md files: 97

**After cleanup (if all approved):**
- Delete: 47 files
- Keep: 50 files
- Reduction: 48%

### Size Reduction

Estimated disk space savings: ~500-800 KB of markdown files

### Download Impact

**Before:**
- Planning artifacts: 33 files (mostly obsolete)
- Artifacts total: 16 files (ALL obsolete)

**After:**
- Planning artifacts: 10 files (all valuable)
- Artifacts: 0 files (directory removed)

**Users downloading the system:** 48% fewer files, more focused content

---

## Recommended Action Plan

### Phase 1: Safe Deletions (No Input Needed)
Delete all files in:
- `artifacts/planning/` (14 files) - ALL completed v2.x planning
- `artifacts/reviews/` (1 file) - Historical review
- `artifacts/research/` (1 file) - Old analysis
- `planning/v3.0.0/` obsolete planning (17 files) - Completed work

**Subtotal: 33 files** - Safe to delete, no ongoing value

### Phase 2: User Decision Required (5 files in docs/)
Ask user about:
1. docs/architecture/* (2 files)
2. docs/migration/* (3 files)
3. docs/setup/* (1 file overlap with 2)

### Phase 3: Cleanup Empty Directories
After deletions:
- Remove `artifacts/` entirely (all subdirs empty)
- Update any references to deleted files

---

## Questions for User

1. **docs/architecture/** - Are PRD.md and STRUCTURE.md still accurate and useful?
2. **docs/migration/** - Do we need old v2.x→v2.x migration guides, or is the root `MIGRATION_GUIDE_v2_to_v3.md` sufficient?
3. **docs/setup/** - Is SETUP_GUIDE.md redundant with README.md?

---

## Preservation Reasoning

**Why we're keeping planning/v3.0.0/ feedback files:**
- Real-world feedback analysis shows learning from actual usage
- Critical upgrade failure documentation is important historical record
- Codex evaluation shows our reasoning process (meta-learning)
- These inform future improvements

**Why we're deleting artifacts/:**
- ALL files are completed planning from shipped releases
- No ongoing reference value
- Decisions made, features shipped, work done
- Anyone needing this can check git history

**Why we're keeping reference/archive/:**
- Small file count (8 files)
- Intentionally archived (already marked as historical)
- Useful for understanding system evolution
- Good practice to document deprecations
