# Rename Difficulty Analysis

**AI Context System** (formerly Claude Context System)

**Decision Made:** Rebrand to AI Context System for v3.0.0

---

## What's Currently Claude-Specific

### Hard-coded in user projects:
1. **context/claude.md** - AI header file (created by /init-context)
2. **context/claude-context-feedback.md** - Feedback file (created in v2.3.1+)

### System files (can change easily):
1. **templates/claude.md.template**
2. **templates/claude-context-feedback.template.md**  
3. Documentation references (146 occurrences)
4. Command descriptions
5. README/marketing

### Repository:
1. **GitHub repo name**: claude-context-system
2. **Install URLs**: Reference repo name (but GitHub redirects old URLs)

## Already Universal (v2.1+)

### Core files (no Claude branding):
- CONTEXT.md
- STATUS.md
- DECISIONS.md
- SESSIONS.md
- .context-config.json

### Multi-AI support exists:
- cursor.md.template
- aider.md.template
- codex.md.template
- generic-ai-header.template.md

### Most commands are generic:
- /init-context
- /save, /save-full
- /validate-context
- /organize-docs
- etc.

## Rename Scenarios

### Scenario A: Documentation-Only Rebrand
**Keep file names, change system name**

Difficulty: ★☆☆☆☆ (LOW - 2-3 hours)

Changes needed:
- README.md system name
- All command descriptions
- install.sh messages
- Marketing/positioning

Impact on existing projects:
- NONE (no file changes)
- Just documentation updates
- Version: 2.4 (minor, non-breaking)

Files staying same:
- context/claude.md (one AI header among many)
- context/claude-context-feedback.md
- templates/claude.md.template

User experience:
- Transparent upgrade
- No migration needed
- Files work exactly as before

### Scenario B: Partial Rename (Generic Feedback)
**Rename feedback file, keep AI headers**

Difficulty: ★★☆☆☆ (MEDIUM - 4-5 hours)

Changes needed:
- claude-context-feedback.md → context-feedback.md
- Update init-context.md
- Update update-context-system.md (archive logic)
- Migration script for existing projects
- All Scenario A changes

Impact on existing projects:
- Feedback file needs rename
- Old feedback archived with old name
- Commands updated to look for new name
- Version: 3.0 (minor breaking change)

Migration complexity:
- /update-context-system detects old file
- Renames to new name
- Updates references
- Medium risk

### Scenario C: Full Rename (All Files)
**Rename everything Claude-specific**

Difficulty: ★★★★☆ (HIGH - 8-10 hours + ongoing support)

Changes needed:
- claude.md → ai.md or {tool}.md for all tools?
- claude-context-feedback.md → context-feedback.md
- Update ALL commands
- Update ALL templates
- Migration script for existing projects
- Backward compatibility testing
- All Scenario A+B changes

Impact on existing projects:
- Multiple files need rename
- All AI headers affected (claude.md, cursor.md, etc.)
- Complex migration path
- High confusion risk
- Version: 3.0 (major breaking change)

Migration complexity:
- Detect all old files
- Rename based on tool (claude.md → still claude.md? or ai.md?)
- Update config references
- Update custom user modifications
- HIGH risk - users may have customized these files

Problem: What do we rename claude.md to?
- ai.md? (but then what about cursor.md, aider.md?)
- Keep tool-specific names? (then why rename?)
- Generic entry point? (conflicts with multi-AI support)

### Scenario D: Backward-Compatible Transition
**Support both names for 1-2 versions**

Difficulty: ★★★★★ (VERY HIGH - 12-15 hours + complexity debt)

Changes needed:
- All Scenario C changes
- PLUS: Support both file names in all commands
- Deprecation warnings
- Detection logic (which name is user using?)
- Gradual migration path
- Eventually still need breaking change

Impact on existing projects:
- Can upgrade without immediate migration
- Warnings guide them to migrate
- More time to adapt

Complexity:
- Code handles both old/new names
- Confusing for new users
- Technical debt for 1-2 versions
- Still ends in breaking change eventually
