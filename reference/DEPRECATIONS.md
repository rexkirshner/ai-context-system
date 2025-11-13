# Deprecated Features - Removal Tracking

**Purpose:** Prevent zombie code by explicitly tracking what's deprecated and when it will be removed.

---

## Active Deprecations

**None** - All deprecated features have been removed.

---

## Removal Timeline

**No pending removals** - Check before each major release.

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

## Not Deprecated (Corrections)

### Staleness Thresholds Configuration (Investigated v3.3.0)
- **Status:** ❌ **NOT DEPRECATED** - Entry was incorrect
- **Investigation Date:** 2025-11-13 (v3.3.0 pre-release)
- **Finding:** This configuration is actively used and valuable
- **Evidence:**
  - Used by `.claude/commands/validate-context.md` (lines 239-253)
  - Provides per-file staleness thresholds (STATUS, SESSIONS, CONTEXT, CODE_MAP)
  - Allows color-coded staleness warnings (🟢 green, 🟡 yellow, 🔴 red)
  - Users CAN and DO customize these values (not "hardcoded")
- **Reason for Confusion:** DEPRECATIONS.md had outdated entry from v2.2.0
- **Action Taken:** Removed incorrect deprecation entry, kept feature as-is
- **Future Consideration:** Could add schema validation (not in schema currently)

---

## Removed Features (Historical)

### `/save-context` Command (Removed in v3.2.1)
- **Deprecated:** v2.1.0 (2025-10-20)
- **Removed:** v3.2.1 (2025-10-22)
- **Replacement:** `/save` (quick, 2-3 min) or `/save-full` (comprehensive, 10-15 min)
- **Reason:** Naming confusion - users didn't know difference between `/save` and `/save-context`
- **Files Removed:**
  - `.claude/commands/save-context.md` - Deprecated command
  - `.claude/docs/save-context-guide.md` - Documentation guide
  - `scripts/save-context-helper.sh` → Renamed to `save-full-helper.sh`
- **Migration:** Automatic - users naturally migrate to `/save` or `/save-full`

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

**Last Updated:** 2025-11-13 (v3.3.0 - Corrected staleness thresholds entry)
**Next Review:** v3.4.0 (periodic review)