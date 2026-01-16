# /validate

Validate context documentation structure and integrity.

## Usage

```
/validate
```

## Description

Performs deep validation of context documentation:
- Checks all required files exist
- Validates cross-references (decision IDs, session markers)
- Detects broken links and orphaned references
- Verifies JSON config syntax

## Validation Checks

| Check | What It Validates |
|-------|-------------------|
| Files | Required context files exist |
| Structure | Correct sections in each file |
| References | D### decision IDs exist |
| Markers | BEGIN/END session pairs match |
| Config | Valid JSON syntax |
| Links | Internal links resolve |

## Output

```
Validating context documentation...

Files:
  ✓ CONTEXT.md exists
  ✓ STATUS.md exists
  ✓ DECISIONS.md exists
  ✓ SESSIONS.md exists

References:
  ✓ D001 found in DECISIONS.md
  ✓ D002 found in DECISIONS.md
  ✗ D999 referenced but not found

Markers:
  ✓ 5 sessions with matched BEGIN/END

Errors: 1
  - Broken reference: D999 in STATUS.md:15

Run /review for health score.
```

## Error Types

| Error | Meaning | Fix |
|-------|---------|-----|
| Missing file | Required file doesn't exist | Run /init |
| Broken reference | D### not in DECISIONS.md | Add decision or fix reference |
| Unclosed session | BEGIN without END | Add END marker |
| Invalid JSON | Config file syntax error | Fix JSON syntax |

## Example

```bash
> /validate

✓ All files present
✓ All references valid
✓ All session markers matched
✓ Config valid

Context documentation is valid.
```

## See Also

- [/review](review.md) - Get health score
- [/init](init.md) - Initialize context
