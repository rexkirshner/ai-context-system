# /save-full Skill

Comprehensive session documentation for breaks and handoffs.

## Purpose

Create a detailed session entry in SESSIONS.md documenting all work accomplished, decisions made, and next steps. This enables perfect session continuity for future AI or human handoffs.

## Output

Session entry appended to `context/SESSIONS.md` with BEGIN/END markers:

```markdown
<!-- BEGIN SESSION 15 -->
## Session 15 | 2026-01-13 | Authentication

### TL;DR
Implemented JWT validation middleware and integrated it with Express routes. Added comprehensive tests for token expiration and refresh flows.

### Accomplishments
- Added JWT validation middleware in src/middleware/auth.ts
- Integrated token refresh logic
- Created test suite for authentication flows

### Decisions
- **D015**: Use RS256 algorithm for JWT signing

### Files Changed
- src/middleware/auth.ts
- src/routes/auth.ts
- tests/auth.test.ts

### Mental Models
The auth flow follows OAuth2 pattern: client requests token, server validates, middleware checks each request.

### Next Steps
- Add rate limiting to auth endpoints
- Implement logout (token blacklist)

### Git Operations
- Commits: 3
- Pushed: true
- Branch: feature/auth
<!-- END SESSION 15 -->
```

## Output Schema

Entry must validate against `SessionEntry` schema:

```json
{
  "number": 15,
  "date": "2026-01-13",
  "focus": "Authentication",
  "tldr": "Implemented JWT validation middleware...",
  "accomplishments": ["Added JWT validation middleware..."],
  "decisions": [{"id": "D015", "summary": "Use RS256 for JWT"}],
  "filesChanged": ["src/middleware/auth.ts"],
  "mentalModels": "The auth flow follows OAuth2 pattern...",
  "nextSteps": ["Add rate limiting to auth endpoints"],
  "gitOperations": {"commits": 3, "pushed": true, "branch": "feature/auth"}
}
```

## Execution Steps

### Step 1: Gather Session Information

Collect information from the session:

#### 1.1 Get Session Number

```bash
# Get last session number from SESSIONS.md
LAST_SESSION=$(grep -oE '## Session [0-9]+' context/SESSIONS.md | tail -1 | grep -oE '[0-9]+')
SESSION_NUM=$((LAST_SESSION + 1))

# If no sessions found, start at 1
[ -z "$LAST_SESSION" ] && SESSION_NUM=1
```

#### 1.2 Get Git Information

```bash
# Get current branch
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

# Count commits since last session
# (Use session date or fallback to reasonable window)
LAST_SESSION_DATE=$(grep -oE '## Session [0-9]+ \| [0-9]{4}-[0-9]{2}-[0-9]{2}' context/SESSIONS.md | tail -1 | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')

if [ -n "$LAST_SESSION_DATE" ]; then
  COMMIT_COUNT=$(git log --oneline --since="$LAST_SESSION_DATE" 2>/dev/null | wc -l | xargs)
else
  COMMIT_COUNT=$(git log --oneline -20 2>/dev/null | wc -l | xargs)
fi

# Check if pushed
UNPUSHED=$(git log --oneline @{u}..HEAD 2>/dev/null | wc -l | xargs)
if [ "$UNPUSHED" -eq 0 ]; then
  PUSHED=true
else
  PUSHED=false
fi

# Get files changed in this session
FILES_CHANGED=$(git diff --name-only HEAD~${COMMIT_COUNT:-5} 2>/dev/null | head -20)
```

#### 1.3 Determine Session Focus

Based on conversation context:
- Primary topic discussed
- Main files worked on
- Feature/bug being addressed

**AI should determine focus from:**
1. User's initial request this session
2. Most-worked-on area of code
3. Primary accomplishment

### Step 2: Generate TL;DR

**Requirements:**
- 50-300 characters
- 2-3 sentences
- Captures the essential "what was accomplished"
- Written in past tense

**AI should write TL;DR summarizing:**
1. Main accomplishment
2. Any significant decisions
3. Current state

### Step 3: List Accomplishments

Review the session and list:
- Features implemented
- Bugs fixed
- Refactoring done
- Tests added
- Documentation updated

**Format:** Bullet points, past tense, specific file references.

### Step 4: Document Decisions

For any decisions made during session:
- Assign sequential ID (D001, D002, ...)
- Write brief summary
- Add full entry to DECISIONS.md if significant

**Check existing IDs:**
```bash
LAST_DECISION=$(grep -oE 'D[0-9]{3}' context/DECISIONS.md | sort -u | tail -1)
NEXT_DECISION_NUM=$(( ${LAST_DECISION#D} + 1 ))
NEXT_DECISION_ID=$(printf "D%03d" $NEXT_DECISION_NUM)
```

### Step 5: Capture Mental Models

Document key insights:
- How does this system/feature work?
- What patterns were discovered?
- Any "aha moments" worth preserving?

This helps future sessions understand the *thinking* behind the code.

### Step 6: Define Next Steps

List actionable next steps:
- What should be done next session?
- Any blockers to address?
- Features to implement?

**Format:** Start with imperative verb, be specific.

### Step 7: Update STATUS.md Quick Reference

Regenerate the Quick Reference block:

```bash
# Calculate new health score (simplified)
# In practice, run /review logic

# Update Quick Reference
cat > /tmp/qr-update.md << EOF
<!-- BEGIN AUTO:QUICK_REFERENCE -->
**Project:** $(jq -r '.project.name' context/.context-config.json) | **Phase:** $(grep -oE 'Phase:? [A-Za-z]+' context/STATUS.md | head -1 | cut -d: -f2 | xargs) | **Health:** --/100
**Focus:** [session focus]
**Resume:** [first next step]
<!-- END AUTO:QUICK_REFERENCE -->
EOF

# Replace existing Quick Reference (use sed or Edit tool)
```

### Step 8: Write Session Entry

Append to SESSIONS.md using atomic write pattern:

```bash
# Get today's date
TODAY=$(date +%Y-%m-%d)

# Write entry to temp file first
cat > context/.sessions.tmp << EOF
<!-- BEGIN SESSION $SESSION_NUM -->
## Session $SESSION_NUM | $TODAY | [Focus]

### TL;DR
[TL;DR text - 50-300 chars]

### Accomplishments
[Bullet list]

### Decisions
[Decision references if any]

### Files Changed
[File list]

### Mental Models
[Insights]

### Next Steps
[Action items]

### Git Operations
- Commits: $COMMIT_COUNT
- Pushed: $PUSHED
- Branch: $BRANCH
<!-- END SESSION $SESSION_NUM -->
EOF

# Atomic append
cat context/.sessions.tmp >> context/SESSIONS.md
rm context/.sessions.tmp
```

### Step 9: Verify Entry

```bash
# Check entry was written
if grep -q "<!-- BEGIN SESSION $SESSION_NUM -->" context/SESSIONS.md; then
  echo "✓ Session $SESSION_NUM saved"
else
  echo "✗ Failed to save session"
  exit 1
fi

# Validate TL;DR length
TLDR_LENGTH=$(sed -n "/BEGIN SESSION $SESSION_NUM/,/END SESSION $SESSION_NUM/p" context/SESSIONS.md | grep -A5 '### TL;DR' | tail -n +2 | head -1 | wc -c | xargs)

if [ "$TLDR_LENGTH" -lt 50 ] || [ "$TLDR_LENGTH" -gt 300 ]; then
  echo "⚠ TL;DR length ($TLDR_LENGTH chars) should be 50-300"
fi
```

### Step 10: Output Summary

```
✓ Session $SESSION_NUM Saved

Focus: [session focus]
TL;DR: [tldr preview]

Accomplishments: [count] items
Decisions: [count] documented
Files Changed: [count] files
Next Steps: [count] items

Git: $COMMIT_COUNT commits on $BRANCH (pushed: $PUSHED)

Context health: Run /review to check score
```

## Verification Criteria

| Check | Requirement |
|-------|-------------|
| Schema valid | Entry validates against SessionEntry schema |
| Markers present | Has `<!-- BEGIN SESSION N -->` and `<!-- END SESSION N -->` |
| TL;DR length | 50-300 characters |
| Focus length | Max 100 characters |
| Session number | Sequential (previous + 1) |

## Error Handling

- If SESSIONS.md doesn't exist, create it with header
- If session number conflict, warn and use correct number
- If write fails, show what was attempted
- Never leave partial entry (use atomic write)

## Time Estimate

10-15 minutes for comprehensive documentation.

## When to Use

- Before taking a break
- Before AI handoff
- After completing a significant feature
- At end of day
- ~3-5 times per 20 work sessions

## Notes

- This skill replaces v4.x `/save-full` command
- Mandatory TL;DR ensures session continuity
- BEGIN/END markers protect against partial writes
- Mental Models section is key for AI understanding
- Git operations are auto-detected where possible
