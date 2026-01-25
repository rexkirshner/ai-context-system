# Contributing

Thanks for your interest in improving the AI Context System.

## Philosophy

Before proposing changes, understand v6's core principles:

1. **Advisory, not mechanical** — Guidelines agents follow, not enforcement machinery
2. **Pure prompts, no scripts** — Claude handles logic, not shell scripts
3. **Keep it simple** — If it can't be used in 30 seconds, it doesn't ship

## What We Accept

- Bug fixes in command prompts
- Documentation improvements
- Clarity enhancements that don't add complexity

## What We Don't Accept

- New commands (we have 8, that's enough)
- Shell scripts or automation
- Features that add complexity without proportional value
- "Nice to have" additions

## How to Contribute

1. Open an issue describing the problem first
2. Wait for discussion before submitting a PR
3. Keep changes minimal and focused
4. Update CHANGELOG.md for user-facing changes

## Testing Changes

1. Copy modified commands to a test project
2. Run `/init-context` on a fresh project
3. Run `/save` and verify output
4. Test `/update-context-system` from an older version

## Commit Messages

Follow conventional commits:
- `fix(command): description` for bug fixes
- `docs: description` for documentation
- `chore: description` for maintenance

## Questions?

Open an issue for discussion.
