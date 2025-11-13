# FAQ: Why does claude.md still exist?

**AI Context System** (formerly Claude Context System)

This FAQ addresses the most common question after the v3.0.0 rebrand.

---

## The Question

**Q:** If this is now "AI Context System", why is there still a `claude.md` file?

**Q:** Shouldn't we rename claude.md to ai.md or something more generic?

**Q:** This seems inconsistent - the system is called "AI Context System" but has claude.md?

---

## The Answer

**A:** Great question! `claude.md` is Claude's **entry point** to the universal context system, just like `cursor.md` is Cursor's entry point and `aider.md` is Aider's entry point.

### Understanding the Multi-AI Architecture

The AI Context System supports multiple AI coding assistants. Each AI tool needs its own configuration file with tool-specific instructions.

**File Structure:**
```
context/
├── claude.md          ← Claude's entry point (Claude-specific instructions)
├── cursor.md          ← Cursor's entry point (Cursor-specific instructions)
├── aider.md           ← Aider's entry point (Aider-specific instructions)
├── codex.md           ← Codex's entry point (Codex-specific instructions)
├── CONTEXT.md         ← Universal context (shared by all AI tools)
├── STATUS.md          ← Universal status (shared by all AI tools)
├── DECISIONS.md       ← Universal decisions (shared by all AI tools)
├── SESSIONS.md        ← Universal sessions (shared by all AI tools)
└── context-feedback.md ← System feedback (not AI-specific)
```

### Why Tool-Specific Entry Points?

Each AI coding assistant has:
- **Different syntax** for reading files
- **Different capabilities** (some can run bash, some can't)
- **Different workflows** (some support MCP, some don't)
- **Different instructions** for best results

**Example:** Claude vs Cursor
```markdown
# claude.md
Read this first when opening this project. Read all files listed below.

# cursor.md
@CONTEXT.md @STATUS.md @DECISIONS.md @SESSIONS.md
```

Different AIs need different instructions!

---

## The Naming Is Correct

### claude.md is not "the main file for Claude Context System"

**WRONG understanding:**
- "claude.md is the main file because the system is called Claude Context System"
- "If we rename to AI Context System, claude.md should become ai.md"

**CORRECT understanding:**
- "claude.md is Claude tool's entry point to the universal context system"
- "cursor.md is Cursor tool's entry point to the same universal context system"
- "The system being called 'AI Context System' is independent from which AI tool you use"

### System Name vs File Name

| Concept | Name | Purpose |
|---------|------|---------|
| **System** | AI Context System | What the toolkit is called |
| **claude.md** | Claude's entry point | How Claude accesses the universal context |
| **cursor.md** | Cursor's entry point | How Cursor accesses the universal context |
| **CONTEXT.md** | Universal context | Shared by all AI tools |

---

## Analogies

### Package.json Doesn't Make It npm-Only

Having a `package.json` doesn't mean your project is npm-only:
- You can also use yarn, pnpm, bun
- `package.json` is how npm integrates
- `yarn.lock` is how yarn integrates
- Both can coexist

Same with AI Context System:
- `claude.md` is how Claude integrates
- `cursor.md` is how Cursor integrates
- `aider.md` is how Aider integrates
- All can coexist

### Docker Analogy

Having a `Dockerfile` doesn't mean your project is Docker-only:
- You can also use Podman, containerd
- `Dockerfile` is the standard integration format
- Multiple container runtimes use the same Dockerfile

Same with AI Context System:
- `claude.md`, `cursor.md`, `aider.md` are integration files
- Multiple AIs use the same universal context (CONTEXT.md, STATUS.md, etc.)
- System works with all of them

---

## What Actually Changed in v3.0.0

### What Changed:

| Item | v2.x | v3.0.0 |
|------|------|--------|
| System name | Claude Context System | AI Context System |
| Feedback file | claude-context-feedback.md | context-feedback.md |
| Repository | claude-context-system | ai-context-system |
| Documentation | "Claude Context System" | "AI Context System" |

### What Stayed the Same:

| Item | Still | Why |
|------|-------|-----|
| claude.md | ✅ Unchanged | Claude's entry point (tool-specific) |
| cursor.md | ✅ Unchanged | Cursor's entry point (tool-specific) |
| aider.md | ✅ Unchanged | Aider's entry point (tool-specific) |
| CONTEXT.md | ✅ Unchanged | Universal context (not AI-specific) |
| STATUS.md | ✅ Unchanged | Universal status (not AI-specific) |
| DECISIONS.md | ✅ Unchanged | Universal decisions (not AI-specific) |
| SESSIONS.md | ✅ Unchanged | Universal sessions (not AI-specific) |

---

## Why This Design Makes Sense

### Separation of Concerns

**Tool-Specific (claude.md, cursor.md):**
- How to read the context
- Tool-specific instructions
- Optimal workflows for that AI
- Integration details

**Universal (CONTEXT.md, STATUS.md, etc.):**
- What the project is about
- Current status and tasks
- Architectural decisions
- Session history

This separation allows:
1. **Each AI to work optimally** with tool-specific instructions
2. **Context to stay universal** and tool-agnostic
3. **Teams to use multiple AI tools** without conflicts
4. **System to remain future-proof** for new AI tools

---

## Real-World Usage

### Solo Developer Using Claude

```
context/
├── claude.md          ← You use this
├── CONTEXT.md         ← Universal context
├── STATUS.md          ← Universal status
└── ...
```

Claude reads claude.md, which tells it to read the universal files.

### Team Using Claude + Cursor

```
context/
├── claude.md          ← Claude users use this
├── cursor.md          ← Cursor users use this
├── CONTEXT.md         ← Everyone shares this
├── STATUS.md          ← Everyone shares this
└── ...
```

Both tools access the same universal context through their own entry points.

### Multi-Tool Power User

```
context/
├── claude.md          ← For Claude Code
├── cursor.md          ← For Cursor
├── aider.md           ← For Aider CLI
├── codex.md           ← For GitHub Copilot
├── CONTEXT.md         ← One source of truth
└── ...
```

All tools access the same context, each through its optimal entry point.

---

## Common Misconceptions

### ❌ Misconception 1: "claude.md means it's Claude-only"

**Reality:** claude.md is ONE of many entry points. cursor.md, aider.md, codex.md all exist too.

Having multiple integration files = supporting multiple tools!

### ❌ Misconception 2: "Renaming to AI Context System means removing 'claude'"

**Reality:** Renaming the SYSTEM (toolkit name) is separate from keeping INTEGRATION FILES (tool entry points).

System = AI Context System
Integration files = claude.md, cursor.md, aider.md, etc.

### ❌ Misconception 3: "Should rename claude.md to ai.md"

**Reality:** This would break multi-AI support!

If claude.md becomes ai.md:
- What about cursor.md? Does it also become ai.md? (can't have duplicates)
- Do all entry points become generic? (defeats the purpose)
- How do we have tool-specific instructions? (we can't)

The current design is correct: tool-specific entry points + universal context.

---

## The Bottom Line

**claude.md staying is PROOF that the system is multi-AI compatible, not proof that it's Claude-only.**

Just like:
- Having multiple Dockerfiles for different architectures doesn't make you architecture-locked
- Having multiple package managers supported doesn't make you npm-only
- Having multiple CI configs doesn't make you GitHub Actions-only

**Having claude.md, cursor.md, aider.md, codex.md means the system supports all of them.**

The rebrand to "AI Context System" reflects this universal support in the system name, while keeping the tool-specific integration files that make it work.

---

## For More Information

**Architecture introduced:** v2.1.0 (Multi-AI Support)

**Related files:**
- `templates/claude.md.template` - Claude entry point template
- `templates/cursor.md.template` - Cursor entry point template
- `templates/aider.md.template` - Aider entry point template
- `templates/codex.md.template` - Codex entry point template
- `templates/generic-ai-header.template.md` - Generic entry point for other AIs

**Philosophy:**
- Tool-specific entry points (claude.md, cursor.md)
- Universal context (CONTEXT.md, STATUS.md, DECISIONS.md, SESSIONS.md)
- Platform-neutral core with tool-specific adapters

---

**Version:** 1.0
**Created:** 2025-10-21
**Purpose:** Address #1 question after v3.0.0 rebrand
**Target Audience:** Users confused by claude.md retention
