# /save-session

Record what happened in this context window. Output: `docs/sessions/SESSION-NNN.md`

Run before `/compact` or when context is long.

## Do

1. Reflect on the full conversation (what was attempted, succeeded, failed)
2. Determine next session number:
   - List existing `docs/sessions/SESSION-*.md` (create dir if missing)
   - Extract highest N; next = N+1
   - If none exist, start at 1
   - If computed filename exists (collision), increment until free
   - Use zero-padded 3-digit format: `SESSION-001.md`
3. Collect verified repo state:
   - `git rev-parse --short HEAD` (current commit)
   - `git branch --show-current` (current branch)
   - `git status` (clean/dirty)
   - `git diff --name-status HEAD` (files changed vs last commit; fallback: `git status --porcelain`)
   - `git log --oneline -n 5` (recent commits)
   - If git unavailable: use structured fallback (see below)
4. Draft session file content using format below
5. **Secrets scan (mandatory):** Before finalizing, scan draft for secrets. Redact any matches with `[REDACTED]`. If unsure, redact.

   **Patterns to catch:**
   - API key prefixes: `sk-`, `ghp_`, `github_pat_`, `xoxb-`, `xoxp-`, `xoxa-`, `xapp-`, `AKIA`, `AIza`
   - Private keys: `-----BEGIN`, `BEGIN OPENSSH PRIVATE KEY`, `ssh-rsa`
   - JWT-like: `xxxxx.yyyyy.zzzzz`
   - Auth headers: `Authorization: Bearer`, `Authorization: Basic`
   - URLs with credentials: `://user:pass@`, `://...@`
   - Connection strings: `postgres://`, `mongodb://`, `mysql://`, `redis://`
   - High-entropy tokens: any contiguous string ≥20 chars containing `[A-Za-z0-9_-]` that appears after `=` or `:`, inside quotes, or near words like key/token/secret/password/bearer/cookie

6. Write `docs/sessions/SESSION-NNN.md`
7. Reply to user with:
   - File path created
   - Session number
   - Note if git info couldn't be verified

## Hard Rules

- **Verify from git.** Commits and Files Changed must come from actual git commands. If unverifiable, write "Unknown" — never guess.
- **No secrets (enforced).**
  - Never write secrets into session files: tokens, API keys, passwords, private keys, cookies, connection strings, auth URLs, or PII.
  - Never paste raw output of `printenv`, `.env` files, secret managers, CI logs, cloud console dumps, or full config files. Summarize instead: "Configured env var for X (value redacted)."
  - If you need to reference a secret, describe generically and use `[REDACTED]` for any value.
  - Commit messages: if they contain suspected secrets, keep the SHA but redact the message.
- **Stay concise.** Follow the caps below. Scannable > thorough.

## Output Format

```markdown
# Session NNN

**Date:** YYYY-MM-DD
```
Use today's local date.

```markdown
## Summary
[2-3 sentences: what this session was about and the outcome]

## Accomplished
- [bullet]
```
Max 5-7 bullets. Concrete outcomes only.

```markdown
## Repo State
- **HEAD:** <short sha or Unknown>
- **Branch:** <name or Unknown>
- **Working tree:** <clean/dirty/Unknown>
- **Notes:** <optional: failing tests, build status if known>
```
If not a git repo:
```markdown
## Repo State
- **HEAD:** Not a git repo
- **Branch:** Not a git repo
- **Working tree:** Unknown
```

```markdown
## Files Changed
| File | Status |
|------|--------|
| `path` | A/M/D/R/untracked |
```
From `git diff --name-status HEAD` (preferred) or `git status --porcelain`. Status = A (added), M (modified), D (deleted), R (renamed), or "untracked". Add short note only if directly observed (e.g., from diff), otherwise omit. If not a git repo: "Unable to verify (no git)."

```markdown
## Commits
- `sha` — message
```
From `git log`. Max 5-7 commits; if more, summarize as "N commits this session, key ones:" and list the most significant. If message contains suspected secret, keep SHA but write `[REDACTED]`. If none this session: "None this session." If not a git repo: "Unable to verify (no git)."

```markdown
## Decisions
- **[Topic]:** [decision] — [why]
```
Max 5 items. Include tradeoff if relevant.

```markdown
## Key Discussions
- [Notable insight, user preference, or important exchange]
```
Max 5 items. Skip if nothing notable.

```markdown
## Pointers
- `path/to/relevant/file`
```
3-7 file paths or docs most relevant to resume work. Not just what changed — what's important context. **Never include secret-bearing files:** `.env*`, `secrets.*`, `*.pem`, `id_rsa*`, `credentials.*`, keyfiles.

```markdown
## Blocked On
- [What external input/response/access is needed]
```
Waiting for external input (user decision, API access, review, etc.). Distinct from Unfinished. Omit if nothing blocked.

```markdown
## Unfinished
- [ ] [Actionable task]
```
Max 5-10 items. Phrased as tasks someone can pick up. These are not blocked, just not done yet.

```markdown
## Next Session
[What to do next, in order. Include specific commands/paths to pick up quickly. 5-10 lines max.]
```

## Guidance

- Be factual and skimmable
- Prefer specifics (file paths, function names) over vague descriptions
- If a section would be empty, omit it (except Summary, which is required)
