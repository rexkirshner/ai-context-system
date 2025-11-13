# Reference Folder

This folder contains reference materials and historical artifacts for the AI Context System.

## Current Files

### preference-catalog.yaml

Comprehensive catalog of all available workflow preferences and options. This is **reference documentation only** - not enforced by commands.

**Actual preferences are defined in:**
- `templates/CLAUDE.template.md` - Communication style, workflow rules
- `templates/CODE_STYLE.template.md` - Core development principles
- `config/.context-config.template.json` - Configuration options

Use this catalog to understand what preferences are available, then implement them in the appropriate template files.

## Archive

Historical and abandoned approaches preserved for reference:

### archive/
- **legacy-code-review-with-fixes.md** - Old code review approach that made changes during review (we learned this breaks things)

### archive/old-prompts/
- **post-init-docs.md** - Original initialization prompts (superseded by /init-context command)
- **review-docs-prompt.md** - Original review prompts (superseded by /review-context command)
- **update-docs-prompt.md** - Original update prompts (superseded by /save-context command)

## Deleted Files (consolidated elsewhere)

These files were deleted because their content was consolidated into templates and config:

- **communication-guide.md** → Merged into `templates/CLAUDE.template.md` and `config/preferences.yaml`
- **workflow-rules.md** → Merged into `templates/CODE_STYLE.template.md` and `config/preferences.yaml`
- **claude-example.md** → Redundant with `templates/CLAUDE.template.md`
- **helpful prompts.txt** → Obsolete notes

## Active Configuration

For current, active configuration files, see:
- `config/` - Active configuration files and schemas
- `templates/` - Documentation templates used by commands
