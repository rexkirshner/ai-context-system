# AI Context System: File Purposes Guide

This guide explains the purpose of each file in the AI Context System and helps you understand which files are required vs optional for your project.

## File Categories

### Core Files (Always Create)

These files are essential for the AI Context System to function. They should be created when you initialize the system.

| File | Purpose | When to Update |
|------|---------|----------------|
| `CLAUDE.md` | AI entry point - the first file Claude reads | When project structure changes significantly |
| `context/CONTEXT.md` | Project orientation - gives Claude context about the project | Each session, or when major changes occur |
| `context/STATUS.md` | Current state dashboard - active tasks, blockers, recent changes | Every session |
| `context/SESSIONS.md` | Session history - log of what was accomplished | After each session |

### Standard Files (Create When Needed)

These files add significant value but may not be needed for every project.

| File | Purpose | When to Create |
|------|---------|----------------|
| `context/DECISIONS.md` | Architectural decision log | When making significant technical choices |

### Optional Files (Create On Demand)

These files are helpful for complex projects but can be skipped for simpler ones.

| File | Purpose | When to Create |
|------|---------|----------------|
| `context/ARCHITECTURE.md` | Deep technical documentation | Complex projects with multiple components |
| `context/CODE_STYLE.md` | Style guidelines beyond linter config | When team has specific conventions |
| `context/KNOWN_ISSUES.md` | Blockers and gotchas | When tracking persistent issues |
| `context/PRD.md` | Product requirements | When building to a specification |

## CONTEXT.md vs README.md

A common question is: "What's the difference between CONTEXT.md and README.md?"

| Aspect | README.md | CONTEXT.md |
|--------|-----------|------------|
| **Audience** | Humans (GitHub visitors) | AI agents (Claude) |
| **Purpose** | Project introduction, setup instructions | Session orientation for AI takeover |
| **Content Focus** | How to install, run, contribute | What's happening now, what's in progress |
| **Update Frequency** | Rarely (major changes only) | Every session |
| **Location** | Repository root | `context/` folder |
| **Tone** | Marketing/onboarding | Technical/operational |

### Example Content Differences

**README.md** might say:
> "MyApp is a task management application built with React and Node.js. To get started, run `npm install` followed by `npm start`."

**CONTEXT.md** might say:
> "This session is implementing the user notifications feature. The backend is complete but the frontend React components need work. See STATUS.md for current blockers."

### Do I Need Both?

- **Public/open-source projects**: Yes, keep both. README.md for humans, CONTEXT.md for AI.
- **Private/personal projects**: CONTEXT.md is more important. README.md is optional.
- **Team projects**: Both are valuable. CONTEXT.md helps any AI agent pick up where another left off.

## File Size Guidelines

### SESSIONS.md
- **Target size**: 10-30 most recent sessions
- **When too large**: Archive old sessions with `/archive-sessions`
- **Archive location**: `context/.sessions-archive/`

### DECISIONS.md
- **Target size**: Active decisions only
- **When too large**: Archive old decisions with `/archive-decisions`
- **Archive location**: `context/.decisions-archive/`

### ARCHITECTURE.md
- **Target size**: ~300-500 lines for the overview
- **When too large**: Split into `docs/architecture/` subdirectory

See [ARCHITECTURE Size Guidance](#architecture-size-guidance) below.

## ARCHITECTURE Size Guidance

If your ARCHITECTURE.md exceeds 500 lines, consider splitting it:

```
context/ARCHITECTURE.md (overview, ~300 lines)
├── System diagram
├── Key patterns summary
├── Component overview (brief)
└── Links to deep dives

docs/architecture/ (detailed documentation)
├── authentication.md
├── database-design.md
├── api-contracts.md
├── deployment.md
└── ...
```

### What to Keep in ARCHITECTURE.md

- High-level system diagram
- Key architectural patterns (brief descriptions)
- Component list with one-sentence descriptions
- Cross-references to detailed docs

### What to Move to docs/architecture/

- Detailed design documents
- API specifications
- Database schema explanations
- Deployment procedures
- Security considerations

## Quick Reference

### Minimum Setup (Simple Projects)
```
CLAUDE.md
context/
├── CONTEXT.md
├── STATUS.md
└── SESSIONS.md
```

### Standard Setup (Most Projects)
```
CLAUDE.md
context/
├── CONTEXT.md
├── STATUS.md
├── SESSIONS.md
└── DECISIONS.md
```

### Full Setup (Complex Projects)
```
CLAUDE.md
context/
├── CONTEXT.md
├── STATUS.md
├── SESSIONS.md
├── DECISIONS.md
├── ARCHITECTURE.md
├── CODE_STYLE.md
├── KNOWN_ISSUES.md
└── PRD.md
```

## See Also

- [Usage Examples](./usage-examples.md) - Real-world examples
- [Command Philosophy](./command-philosophy.md) - How commands work
- [Troubleshooting](./TROUBLESHOOTING.md) - Common issues
