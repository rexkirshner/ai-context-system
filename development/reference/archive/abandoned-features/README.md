# Abandoned Features

Features that were designed and partially implemented but ultimately removed from the system.

## JSON Artifacts (Removed in v1.4.0)

**Original Idea:** Generate machine-readable `state.json` and `session-N.json` files alongside markdown documentation for "fast agent loading."

**Files:**
- `state-schema.json` - Schema for current project state
- `session-schema.json` - Schema for individual session logs

**Why Implemented:**
- Speculative optimization for faster context loading
- Structured data for potential integrations
- Cross-session memory in JSON format

**Why Removed:**
- `/review-context` never implemented JSON reading (always used markdown)
- `/quick-save-context` never updated JSON files
- No measurable performance benefit
- Added ~200 lines of complexity to `/save-context`
- Schemas were never validated
- Markdown worked fine for all use cases

**Lesson Learned:**
Don't implement speculative optimizations. Markdown as source of truth was sufficient. JSON artifacts added complexity without delivering value.

**Timeline:**
- Introduced: v1.2.0 (2025-10-04)
- Removed: v1.4.0 (2025-10-04)
- Duration: Same day (rapid development iteration)

**Impact of Removal:**
- Saved 193 lines in save-context.md
- Removed 2 unused schema files
- Simplified mental model (markdown is authoritative)
- No loss of functionality
