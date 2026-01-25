# Changelog

All notable changes to the AI Context System will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [6.0.1] - 2026-01-25

### Fixed

- **Working Set scope limitation for review commands** - Added "Scope Expansion" sections to all review commands with critical paths to include when Working Set lacks review-relevant files

### Added

- Scope expansion guidance for `/review-security` (auth, API, middleware, config files)
- Scope expansion guidance for `/review-accessibility` (components, pages, styles)
- Scope expansion guidance for `/review-cost` (infrastructure, database, API routes)
- Scope expansion guidance for `/review-performance` (API, lib, components, database)
- Scope expansion guidance for `/review-seo` (pages, meta components, sitemap, robots.txt)
- Automated tool suggestions for all review commands

## [6.0.0] - 2026-01-24

**MAJOR RELEASE** - Radical Simplification

v6.0 is a complete redesign. v5.x had 22 commands, 14 agents, and 150KB of shell scripts. v6.0 has **3 files** and **8 commands** (3 core + 5 optional reviews). The value is in the subtraction.

### Philosophy

- **Advisory, not mechanical** - Guidelines agents should follow, not enforcement machinery
- **Pure prompts, no scripts** - Claude handles logic, not shell scripts
- **Working Set as boundary** - Simple list of 3-7 items you're touching

### Changed (BREAKING)

- **3 context files** instead of 8:
  - `CLAUDE.md` - Entry point with Session Loop (absorbs CONTEXT.md)
  - `context/STATUS.md` - Current state (simplified format)
  - `context/DECISIONS.md` - Decision log (unchanged format)

- **8 commands** instead of 22:
  - `/init-context` - Creates context files (safe, never overwrites)
  - `/save` - End of session (replaces both `/save` and `/save-full`)
  - `/update-context-system` - Updates from repo with migrations
  - `/review-security` - Security audit
  - `/review-performance` - Performance check
  - `/review-accessibility` - Accessibility review
  - `/review-seo` - SEO review
  - `/review-cost` - Cost optimization review

- **Simple installation** - `git clone` + `cp`, no install script

### Removed

- All shell scripts (150KB → 0)
- All agents (14 files) - reviews are now simple prompts
- SESSIONS.md - Git history is enough
- CONTEXT.md - Merged into CLAUDE.md
- `/save-full` - Just use `/save`
- `/review-context`, `/validate-context`, `/export-context`
- `/migrate-context`, `/organize-docs`, `/update-templates`
- All JSON schemas, hooks, skills
- Config files (`.context-config.json`, `acs-settings.json`)
- Complex validation and staleness detection machinery

### Added

- `MIGRATIONS.md` - Version migration instructions
- `.claude/VERSION` - Tracks installed version
- Non-git repo support - HeadCommit can be "N/A"
- Error handling guidance in `/update-context-system`

### Migration

See [MIGRATIONS.md](./MIGRATIONS.md) for step-by-step upgrade from any pre-v6 version.

Quick summary:
1. Backup existing files
2. Delete legacy artifacts
3. Copy new commands
4. Create CLAUDE.md if missing (synthesize from CONTEXT.md)
5. Add Session Loop to existing CLAUDE.md
6. Transform STATUS.md (new format)

---

**Note:** For v5.x and earlier changelog entries, see [CHANGELOG-archive.md](./CHANGELOG-archive.md).
