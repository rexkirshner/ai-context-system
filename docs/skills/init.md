# /init

Initialize AI Context System for a project.

## Usage

```
/init
```

## Description

Creates the context documentation structure for a new project or validates existing context. Auto-detects project type, technology stack, and key files.

## Output

Creates `context/` directory with:
- `CONTEXT.md` - Project orientation
- `STATUS.md` - Current state with Quick Reference
- `DECISIONS.md` - Decision log
- `SESSIONS.md` - Session history
- `.context-config.json` - Configuration

## Verification

- All required files created
- Placeholders < 3 per file
- Quick Reference block present in STATUS.md
- Valid JSON in config file

## Example

```bash
$ claude
> /init

Detecting project type...
Found: Next.js 14 with TypeScript

Creating context structure:
  ✓ context/CONTEXT.md
  ✓ context/STATUS.md
  ✓ context/DECISIONS.md
  ✓ context/SESSIONS.md
  ✓ context/.context-config.json

Context initialized. Run /review for health check.
```

## See Also

- [/review](review.md) - Check context health
- [/save-full](save-full.md) - Save session state
