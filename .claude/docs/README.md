# Command Documentation

This folder contains detailed documentation for slash commands. The commands themselves (in `.claude/commands/`) are kept lean with just execution steps, while comprehensive explanations live here.

## Structure

**Commands** (`.claude/commands/*.md`)
- Brief description
- Execution steps (bash code blocks)
- Links to detailed docs

**Documentation** (`.claude/docs/*.md`)
- When to use
- Philosophy and principles
- Detailed examples
- Error handling strategies
- Success criteria

## Documentation Files

### command-philosophy.md
Core principles that guide all commands:
- Simplicity first
- User approval for destructive actions
- Session continuity
- No broken promises

### review-context-guide.md
Deep dive into `/review-context`:
- Confidence scoring explained
- Verification strategies
- Gap analysis
- Loading context into memory

### code-review-guide.md
Complete code review methodology:
- Review categories
- Grading rubric
- Issue categorization
- "No changes" rule explained

### usage-examples.md
Real-world usage patterns:
- Daily workflow
- New project setup
- Team handoff
- Quality checks

### TROUBLESHOOTING.md
Quick solutions to common issues:
- CLAUDE.md not auto-loading
- Context directory not found
- Download failures
- JSON validation errors
- Permission issues

### MIGRATION_v3.5_to_v3.6.md
Step-by-step migration guide for v3.6.0:
- CLAUDE.md location change
- File migration options
- Verification steps

### VERSION_MANAGEMENT.md
Version control and configuration:
- VERSION file (single source of truth)
- Config file versioning
- Upgrade path handling

## Modular Audit Commands (v4.0.0)

Specialized audit commands with integrated checklists:
- `/code-review-security` - OWASP Top 10 security audit
- `/code-review-accessibility` - WCAG 2.1 AA compliance
- `/code-review-performance` - Core Web Vitals audit
- `/code-review-seo` - Technical SEO audit
- `/code-review-database` - Database efficiency audit
- `/code-review-infrastructure` - Serverless cost optimization
- `/code-review-typescript` - Type safety audit
- `/code-review-testing` - Coverage and quality audit

## Benefits

**For Commands:**
- Scannable (200-300 lines max)
- Fast to load
- Easy to execute
- Clear action steps

**For Documentation:**
- Detailed explanations
- Examples and philosophy
- Reusable across commands
- Easy to update independently

## Reading Order

1. Start with `command-philosophy.md` for core principles
2. Read specific guide when learning a command
3. Reference checklists during reviews
4. Consult usage examples for workflows
