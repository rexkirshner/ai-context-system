# /export Skill

Export context documentation to handoff package.

## Purpose

Create comprehensive export for AI-to-AI transfers, developer onboarding, or archival. Packages all context files with summary and next steps.

## Output

Two files in `artifacts/exports/`:

```
artifacts/exports/
├── handoff-YYYY-MM-DD-HHMMSS.json  # Machine-readable
└── handoff-YYYY-MM-DD-HHMMSS.md    # Human-readable
```

### JSON Structure

```json
{
  "metadata": {
    "exportedAt": "2026-01-13T10:30:00Z",
    "acsVersion": "5.0.0",
    "projectName": "my-app"
  },
  "summary": {
    "projectState": "MVP complete, working on auth",
    "criticalDecisions": ["D001: JWT with RS256", "D005: Prisma ORM"],
    "activeBlockers": []
  },
  "contextFiles": {
    "context": "[full CONTEXT.md content]",
    "status": "[full STATUS.md content]",
    "decisions": "[full DECISIONS.md content]",
    "recentSessions": ["[last 3 session entries]"]
  },
  "nextSteps": ["Add rate limiting", "Implement logout"]
}
```

### Markdown Structure

```markdown
# Handoff Package

**Exported:** [timestamp] | **Project:** [name] | **ACS:** [version]

## Summary
[Project state from STATUS.md]

### Critical Decisions
- D001: [summary]
- D005: [summary]

### Active Blockers
[List or "None"]

---

## Context Files

### CONTEXT.md
[Full content]

### STATUS.md
[Full content]

### Recent Sessions
[Last 3 session entries]

---

## Next Steps
1. [Priority item]
2. [Second item]
```

## Execution

### 1. Create Export Directory

```
mkdir -p artifacts/exports
```

### 2. Gather Data

| Field | Source |
|-------|--------|
| Metadata | VERSION file, config, current timestamp |
| Project state | STATUS.md Current Phase section |
| Critical decisions | Last 5 decision IDs from DECISIONS.md |
| Blockers | STATUS.md Blockers section |
| Context files | Read full content of each |
| Recent sessions | Last 3 session entries from SESSIONS.md |
| Next steps | Combined from STATUS.md and last session |

### 3. Build JSON

Use proper JSON escaping for file contents. Validate with `jq .` before writing.

### 4. Build Markdown

Human-readable format with clear section headers.

### 5. Write Files

Generate timestamp-based filenames to avoid conflicts.

### 6. Verify

| Check | Requirement |
|-------|-------------|
| JSON valid | `jq .` succeeds |
| Required fields | metadata, summary, contextFiles, nextSteps present |
| Files created | Both .json and .md exist |

## Output Summary

```
✓ Handoff Package Exported

Files:
  artifacts/exports/handoff-2026-01-13-103000.json
  artifacts/exports/handoff-2026-01-13-103000.md

Contents:
  - Full context files
  - Last 3 sessions
  - [N] decisions highlighted
  - [N] next steps
```

## Guardrails

- **DO NOT** include sensitive data (.env contents, secrets)
- **DO** validate JSON before writing
- **DO** include both formats (JSON + Markdown)
- **DO** use timestamp in filename to avoid overwrites
