# v4.0.0 Planning - Modular Code Review System

**Status**: COMPLETE - All 15 phases implemented (2026-01-05)

## Quick Links

- [UPGRADE_PLAN.md](./UPGRADE_PLAN.md) - Detailed implementation plan with 15 phases

## Decisions Made

- **Version**: 4.0.0 (major release)
- **Checklists**: Fully integrate into commands, then delete `.claude/checklists/`
- **Legacy support**: None - clean break

## Summary

Transform `/code-review` from monolithic command to modular audit system.

### New Commands

| Command | Description | Platform Flags | Status |
|---------|-------------|----------------|--------|
| `/code-review` | Master orchestrator (interactive selection) | - | **COMPLETE** |
| `/code-review-security` | OWASP-style security audit | - | **COMPLETE** |
| `/code-review-performance` | Core Web Vitals, bundle, runtime | - | **COMPLETE** |
| `/code-review-accessibility` | WCAG compliance | - | **COMPLETE** |
| `/code-review-seo` | Technical SEO | - | **COMPLETE** |
| `/code-review-database` | Query optimization, N+1, indexes | `--prisma`, `--drizzle` | **COMPLETE** |
| `/code-review-infrastructure` | Serverless costs, caching | `--vercel`, `--aws` | **COMPLETE** |
| `/code-review-typescript` | Type safety, strictness | - | **COMPLETE** |
| `/code-review-testing` | Coverage and quality | - | **COMPLETE** |
| `/build-check` | Pre-push build gate | - | **COMPLETE** |

### Breaking Changes

- `/code-review` becomes interactive orchestrator (not monolithic)
- Reports move to `docs/audits/` (was `artifacts/code-reviews/`)
- `.claude/checklists/` deleted (integrated into commands)
- No context system integration (standalone reports only)
- No legacy flag

## Implementation Progress

### Milestone A - COMPLETE (2026-01-05)

**Phase 1: Directory Structure & Migration** - All checkpoints complete
- [x] Checkpoint 1.1: Created `docs/audits/` directory structure
- [x] Checkpoint 1.2: Created `audits-index.template.md`
- [x] Checkpoint 1.3: Added migration logic to update-context-system.md
- [x] Checkpoint 1.4: Added .gitkeep files for empty directories

**Phase 2: Shared Infrastructure** - All checkpoints complete
- [x] Checkpoint 2.1: Implemented `get_next_audit_number()` function
- [x] Checkpoint 2.2: Documented audit report header template
- [x] Checkpoint 2.3: Implemented `update_audit_index()` function
- [x] Checkpoint 2.4: Implemented platform detection helpers

Commit: `a675344` - "Implement Milestone A: Foundation for v3.7.0 and v4.0.0"

### Milestone B - COMPLETE (2026-01-05)

**Phase 4: Security Audit** - COMPLETE
- [x] Created `.claude/commands/code-review-security.md`
- [x] OWASP Top 10 (2021) framework coverage
- [x] Attack surface inventory
- [x] Dependency vulnerability scanning

**Phase 5: Performance Audit** - COMPLETE
- [x] Created `.claude/commands/code-review-performance.md`
- [x] Core Web Vitals (LCP, INP, CLS) coverage
- [x] Bundle analysis patterns
- [x] Caching strategy review

**Phase 6: Database Audit** - COMPLETE
- [x] Created `.claude/commands/code-review-database.md`
- [x] Added platform flag support: `--prisma`, `--drizzle`, `--typeorm`, `--raw`
- [x] Integrated with `detect_database_platform()` auto-detection
- [x] Fixed glob pattern issue in `get_next_audit_number()` for empty directories

**Phase 7: Infrastructure Audit** - COMPLETE
- [x] Created `.claude/commands/code-review-infrastructure.md`
- [x] Added platform flags: `--vercel`, `--aws`, `--cloudflare`, `--netlify`, `--railway`, `--fly`
- [x] Cost Surface Inventory
- [x] Rendering strategy analysis

**Phase 8: SEO Audit** - COMPLETE
- [x] Created `.claude/commands/code-review-seo.md`
- [x] Technical SEO with metadata analysis
- [x] Structured data validation
- [x] Core Web Vitals integration

**Phase 9: Accessibility Audit** - COMPLETE
- [x] Created `.claude/commands/code-review-accessibility.md`
- [x] WCAG 2.1 AA framework (POUR principles)
- [x] Keyboard navigation patterns
- [x] Color contrast analysis

**Phase 10: TypeScript Audit** - COMPLETE
- [x] Created `.claude/commands/code-review-typescript.md`
- [x] tsconfig.json analysis
- [x] Explicit any tracking
- [x] Type coverage metrics

**Phase 11: Testing Audit** - COMPLETE
- [x] Created `.claude/commands/code-review-testing.md`
- [x] Coverage analysis
- [x] Test pyramid distribution
- [x] Mock strategy review

**Phase 12: Build Check** - COMPLETE
- [x] Created `.claude/commands/build-check.md`
- [x] Pre-push quality gate
- [x] Framework auto-detection

**Files Created (Milestone B):**
- `.claude/commands/code-review-security.md`
- `.claude/commands/code-review-performance.md`
- `.claude/commands/code-review-database.md`
- `.claude/commands/code-review-infrastructure.md`
- `.claude/commands/code-review-seo.md`
- `.claude/commands/code-review-accessibility.md`
- `.claude/commands/code-review-typescript.md`
- `.claude/commands/code-review-testing.md`
- `.claude/commands/build-check.md`

**Files Modified:**
- `scripts/common-functions.sh` - Fixed `get_next_audit_number()` glob pattern

**Bug Fixes (Post-Milestone B Review):**
- Fixed `update_audit_index()` sed issue on macOS - replaced with awk for cross-platform reliability
- Added `scripts/tests/output/` to `.gitignore` to prevent test artifact commits

Commits:
- `d4501b2` - Phase 6: Database
- `1a5013e` - Phase 7: Infrastructure
- `b83080d` - Phase 8: SEO
- `5d87fb3` - Phase 4: Security
- `65e8cb7` - Phase 5: Performance
- `55ded02` - Phase 9: Accessibility
- `ac8679c` - Phase 10: TypeScript
- `eeb678c` - Phase 11: Testing
- `d6e0be5` - Phase 12: Build Check
- `d76f764` - Fix update_audit_index sed issue
- `ef420d7` - Add test output to .gitignore

### Implementation Decisions

1. **Audit Naming**: `{type}-audit-NN.md` format with zero-padded numbers
2. **Platform Detection**: Auto-detect from project files, override with flags
3. **INDEX.md**: Uses HTML comment marker for insertion point
4. **Cross-platform**: All sed commands work on both macOS and Linux

### Files Modified

- `scripts/common-functions.sh` - Added audit and platform detection functions
- `.claude/commands/update-context-system.md` - Added v4.0.0 migration logic

### Files Created

- `docs/audits/` - New audit directory structure
- `templates/audits-index.template.md` - INDEX.md template

### Helper Functions Added

```bash
# Audit system (v4.0.0)
get_next_audit_number()    # Returns next audit number (01, 02, etc.)
update_audit_index()       # Updates INDEX.md with new entry

# Platform detection (v4.0.0)
detect_database_platform() # Returns: prisma|drizzle|typeorm|raw|unknown
detect_hosting_platform()  # Returns: vercel|aws|cloudflare|netlify|unknown
detect_framework()         # Returns: nextjs|remix|astro|vite|express|unknown
```

### Milestone C - COMPLETE (2026-01-05)

**Phase 3: Master Orchestrator** - COMPLETE
- [x] Transformed `/code-review` into modular orchestrator
- [x] Interactive menu for audit type selection
- [x] Command-line arguments (--security, --performance, etc.)
- [x] Preset combinations (--prelaunch, --backend, --frontend, --all)
- [x] Combined summary report generation
- [x] Weighted grading calculation
- [x] Migration guide from v3.x

**Phase 13: Refactor Existing Command** - COMPLETE
- [x] Replaced monolithic code review with orchestrator
- [x] Old behavior documented in migration section
- [x] Version updated to 4.0.0

Commit: `edb8609` - "Phase 3: Transform /code-review into master orchestrator"

### Milestone D - COMPLETE (2026-01-05)

**Phase 14: Documentation** - COMPLETE
- [x] Updated CHANGELOG with complete v4.0.0 section
- [x] Documented breaking changes
- [x] Added Removed section for deprecated features
- [x] Migration guide included in /code-review command

**Phase 15: Cleanup** - COMPLETE
- [x] Deleted `.claude/checklists/` directory
- [x] Removed: accessibility.md, performance.md, security.md, seo-review.md
- [x] All checklist content integrated into modular commands

Commit: `9525703` - "Phase 14-15: Complete v4.0.0 documentation and cleanup"

## Implementation Order (Complete)

```
Phase 1 (Directory & Migration)   ← COMPLETE
    ↓
Phase 2 (Shared Infrastructure)   ← COMPLETE
    ↓
Phase 4-12 (All Audit Commands)   ← COMPLETE
    ↓
Phase 3 (Master Command)          ← COMPLETE
    ↓
Phase 13 (Refactor)               ← COMPLETE
    ↓
Phase 14-15 (Docs & Cleanup)      ← COMPLETE
```

## Key Changes

- **Location**: `docs/audits/` (was `artifacts/code-reviews/`)
- **Naming**: `{type}-audit-NN.md` (incrementing per type)
- **Reports**: Standalone (no context system integration)
- **Migration**: Auto-migrate existing files to `docs/audits/archive/pre-v4.0.0-migration/`

## Implementation Status - ALL COMPLETE

- [x] Phase 1: Directory Structure & Migration **COMPLETE**
- [x] Phase 2: Shared Infrastructure **COMPLETE**
- [x] Phase 3: Master Command **COMPLETE**
- [x] Phase 4: Security Audit **COMPLETE**
- [x] Phase 5: Performance Audit **COMPLETE**
- [x] Phase 6: Database Audit **COMPLETE**
- [x] Phase 7: Infrastructure Audit **COMPLETE**
- [x] Phase 8: SEO Audit **COMPLETE**
- [x] Phase 9: Accessibility Audit **COMPLETE**
- [x] Phase 10: TypeScript Audit **COMPLETE**
- [x] Phase 11: Testing Audit **COMPLETE**
- [x] Phase 12: Build Check **COMPLETE**
- [x] Phase 13: Refactor Existing Command **COMPLETE**
- [x] Phase 14: Documentation & Migration **COMPLETE**
- [x] Phase 15: Cleanup **COMPLETE**

**All 15 phases complete. Ready for v4.0.0 release.**
