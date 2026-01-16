# v3.7.0 Planning - Friction Reduction Release

**Status**: IN PROGRESS - Milestone A complete

## Quick Links

- [UPGRADE_PLAN.md](./UPGRADE_PLAN.md) - Detailed implementation plan with modular checkpoints
- [timestamp-audit.md](./timestamp-audit.md) - Timestamp patterns analysis

## Summary

v3.7.0 addresses friction points from real-world usage:

| Phase | Feature | Value | Risk | Status |
|-------|---------|-------|------|--------|
| 1 | Auto-timestamps | High | Low | **COMPLETE** |
| 2 | Simplify .context-config.json | High | Medium | Pending |
| 3 | Session gap warnings | Medium | Low | Pending |
| 4 | TodoWrite capture prompt | Medium | Low | Pending |
| 5 | Clarify file roles | Medium | Low | Pending |
| 6 | Optional git hook | Low | Low | Pending |

## Implementation Progress

### Milestone A - COMPLETE (2026-01-05)

**Phase 1: Auto-Timestamps** - All checkpoints complete

Completed:
- [x] Checkpoint 1.1: Identified timestamp patterns in all templates
- [x] Checkpoint 1.2: Implemented `update_last_modified()` in common-functions.sh
- [x] Checkpoint 1.3: Integrated timestamps into /save
- [x] Checkpoint 1.4: Integrated timestamps into /save-full
- [x] Checkpoint 1.5: Created test-auto-timestamps.sh (6 tests, all passing)

Commit: `a675344` - "Implement Milestone A: Foundation for v3.7.0 and v4.0.0"

### Implementation Decisions

1. **Timestamp Pattern**: Using `**Last Updated:** YYYY-MM-DD` format
2. **Cross-platform**: BSD sed (macOS) and GNU sed (Linux) both supported
3. **Non-destructive**: If no timestamp pattern exists, function does nothing (doesn't add one)
4. **Multiple timestamps**: If file has multiple `**Last Updated:**` patterns, all are updated

### Files Modified

- `scripts/common-functions.sh` - Added `update_last_modified()` function
- `.claude/commands/save.md` - Added Step 5 for auto-timestamp
- `.claude/commands/save-full.md` - Added auto-timestamp in Step 4

### Files Created

- `scripts/tests/test-auto-timestamps.sh` - Test suite for timestamp function
- `development/planning/v3.7.0/timestamp-audit.md` - Pattern analysis

## Next Steps (Milestone B)

Phases 2-6 can be implemented. Priority order:

1. Phase 5: Documentation clarity (low risk)
2. Phase 4: TodoWrite prompt (template change only)
3. Phase 3: Session gaps (medium complexity)
4. Phase 2: Config simplify (highest complexity)
5. Phase 6: Git hooks (optional)

## Feedback Source

Based on detailed production feedback documenting:
- What works well (CLAUDE.md auto-load, DECISIONS.md value, drift detection)
- What could be improved (manual timestamps, stale config, session gaps)
- High-impact quick wins prioritized

## Implementation Status

- [x] Phase 1: Auto-Timestamps **COMPLETE**
- [ ] Phase 2: Simplify Config
- [ ] Phase 3: Session Gaps
- [ ] Phase 4: TodoWrite Prompt
- [ ] Phase 5: Documentation
- [ ] Phase 6: Git Hooks (optional)
