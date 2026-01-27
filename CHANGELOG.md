# Changelog

All notable changes to the AI Context System will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [6.0.4] - 2026-01-27

### Fixed

- **`/init-context` now handles existing CLAUDE.md** - When CLAUDE.md already exists but lacks the Session Loop block, the command now displays the snippet and instructs users to add it. Previously, existing CLAUDE.md files were silently preserved without the core ACS mechanism, leaving future sessions unaware of context/STATUS.md and `/save`.
- **Installation docs clarify session restart requirement** - Added note that Claude Code must be restarted after copying command files for new commands to be available. Previously, users encountered "Unknown skill" errors when running `/init-context` immediately after installation.
- **`/update-context-system` no longer creates backup files** - Removed redundant backup step since git is required for updates. Rollback now uses `git checkout` instead of backup files.

## [6.0.3] - 2026-01-26

### Changed

- **`/review-cost` rebalanced for serverless stacks** - Moved Serverless & Edge Platforms section to top with Vercel-specific cost drivers (rendering strategy, image optimization, build minutes, bandwidth). Renamed Database section to Database & ORM with Prisma-specific items (N+1 queries, connection pooling). Traditional Infrastructure section moved lower with "skip for serverless" guidance.

### Fixed

- **`/save` session history clarification** - Added note explaining STATUS.md is replaced each session (not appended). Session history preserved in git commits; persistent context goes in DECISIONS.md.
- **`/save` mixed DECISIONS.md formats** - Clarified that new entries should always use v6.0 format even if file contains older v5.x entries.
- **`/update-context-system` verification wording** - Changed "8 files" to "8 command files (*.md)" to avoid confusion.
- **`/update-context-system` rollback placeholders** - Fixed inconsistent `[version]` vs `[current-version]` placeholders in rollback section.
- **All review commands formatting consistency** - All 5 review commands (`/review-cost`, `/review-performance`, `/review-security`, `/review-accessibility`, `/review-seo`) now use consistent bold formatting with brief explanations for each checklist item.

## [6.0.2] - 2026-01-25

### Fixed

- **Pre-v6 migration failures** - v5.x users running `/update-context-system` encountered broken upgrades due to script dependencies being deleted mid-execution
- **`/save` corrupting v5.x STATUS.md** - Now detects v5.x format and provides migration instructions instead of corrupting files

### Added

- **`migrate-to-v6.sh`** - One-time bootstrap script for pre-v6 → v6.0 migration
  - Checks for git availability before proceeding
  - Detects and refuses v6.0+ projects (directs to `/update-context-system`)
  - Detects and refuses fresh projects (directs to `/init-context`)
  - Creates timestamped backup before migration
  - Deletes all v5.x artifacts (scripts/, agents/, templates/, etc.)
  - Downloads v6.0 commands from GitHub with clear error handling
  - Deletes itself after successful completion
- **Format guard in `/save`** - Detects v5.x STATUS.md format and stops with clear migration instructions
- **Pre-v6 detection in `/update-context-system`** - Refuses pre-v6 systems with migration script instructions

### Changed

- **Two upgrade paths** - Clear separation:
  - Pre-v6 → v6.0: Run `migrate-to-v6.sh` script
  - v6.x → v6.y: Run `/update-context-system` command
- **`/update-context-system` simplified** - Now only handles v6.x → v6.y upgrades (migration logic moved to script)
- **MIGRATIONS.md rewritten** - Documents two upgrade paths with troubleshooting

### Removed

- **`install.sh`** - Superseded by two-path upgrade strategy (fresh installs use git clone + cp, pre-v6 migrations use migrate-to-v6.sh)

## [6.0.1] - 2026-01-25

### Fixed

- **Working Set scope limitation for review commands** - Added "Scope Expansion" sections to all review commands with critical paths to include when Working Set lacks review-relevant files
- **`/save` decision recording now autonomous** - AI evaluates session and records decisions without prompting user, reducing friction

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
