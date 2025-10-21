# Deprecated Features - Removal Tracking

**Purpose:** Prevent zombie code by explicitly tracking what's deprecated and when it will be removed.

---

## Active Deprecations (v2.2.0)

### `/save-context` Command
- **Deprecated:** v2.2.0 (2025-10-20)
- **Replacement:** `/save` (quick) or `/save-full` (comprehensive)
- **Planned Removal:** v2.3.0 (approximately 3 months after v2.2.0 release)
- **Status:** Functional but warns users
- **Reason:** Naming confusion - users don't know difference between save/save-context
- **Files Affected:**
  - `.claude/commands/save-context.md` (14K)
  - `scripts/save-context-helper.sh` (8.2K)
  - `.claude/docs/save-context-guide.md` (23K)
  - 200+ documentation references
- **Migration Path:** Users should use `/save` for quick updates or `/save-full` for comprehensive saves

### Complex Staleness Configuration
- **Deprecated:** v2.2.0
- **Replacement:** Simple enabled/disabled flag with hardcoded thresholds
- **Planned Removal:** v2.3.0
- **Status:** Still parsed but ignored
- **Reason:** Nobody customizes these values (0 projects in 20+ sessions feedback)
- **Files Affected:**
  - `config/.context-config.template.json` (lines 180-260)
  - Schema validation

---

## Removal Timeline

### v2.3.0 (Target: Q1 2026)

**Phase 1: Pre-removal warnings (v2.2.5 - 1 month before)**
- Add loud deprecation warnings to `/save-context`
- Update all documentation to use `/save` or `/save-full`
- Email announcement to known users

**Phase 2: Removal (v2.3.0)**
- Delete `.claude/commands/save-context.md`
- Delete `scripts/save-context-helper.sh`
- Delete `.claude/docs/save-context-guide.md`
- Update 200+ documentation references
- Remove staleness config parsing

**Phase 3: Cleanup (v2.3.1)**
- Remove deprecation warnings (no longer needed)
- Update migration guides

---

## How to Use This File

**When deprecating something:**
1. Add entry above with deprecation date
2. Set planned removal version
3. Document replacement path
4. Track files affected

**Before each release:**
1. Check if any deprecations are due for removal
2. Update warnings if approaching removal date
3. Communicate to users

**When removing:**
1. Mark as removed in this file
2. Move entry to "Removed Features" section
3. Update CHANGELOG.md

---

## Removed Features (Historical)

### QUICK_REF.md (Removed in v2.1.0)
- **Deprecated:** v2.0.0
- **Removed:** v2.1.0
- **Replacement:** Merged into STATUS.md as Quick Reference section
- **Migration:** Automatic during v2.1 upgrade

### `/quick-save-context` Command (Removed in v1.8.0)
- **Deprecated:** v1.7.0
- **Removed:** v1.8.0
- **Replacement:** Merged into smart `/save-context` (now `/save`)
- **Reason:** Redundant with improved save command

---

## Deprecation Policy

**Deprecation Period:** Minimum 1 major version or 3 months, whichever is longer

**Warning Levels:**
1. **Soft Deprecation** - Mentioned in CHANGELOG, no warnings
2. **Active Deprecation** - Warning in command output
3. **Loud Deprecation** - Prominent warning, requires confirmation
4. **Removal** - Deleted with clear migration path

**Communication:**
- CHANGELOG.md entry
- Migration guide update
- In-command warnings
- This file updated

---

**Last Updated:** 2025-10-20
**Next Review:** v2.2.5 (before v2.3.0 removals)