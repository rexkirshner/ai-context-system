---
name: code-review
description: Run comprehensive code review using the agent-based system
---

# /code-review Command

Run comprehensive code review using the agent-based system. This command delegates to the `code-reviewer` orchestrator agent which dynamically discovers and runs specialist reviewers.

## Usage

```bash
/code-review [options]
```

## Options

| Flag | Effect |
|------|--------|
| `--all` | Run all discovered specialists |
| `--prelaunch` | Pre-deployment check (security, testing, performance, accessibility, seo) |
| `--frontend` | UI-focused review (security, performance, accessibility, seo) |
| `--backend` | API-focused review (security, testing, database, infrastructure) |
| `--quick` | Security only (fast sanity check) |
| `--security` | Just security specialist |
| `--performance` | Just performance specialist |
| `--accessibility` | Just accessibility specialist |
| `--seo` | Just SEO specialist |
| `--database` | Just database specialist |
| `--infrastructure` | Just infrastructure specialist |
| `--typescript` | Just TypeScript specialist |
| `--testing` | Just testing specialist |
| `--incremental` | Only review files changed since last audit |

Multiple specific flags can be combined: `/code-review --security --database`

## Execution

This command invokes the `code-reviewer` agent, which will:

1. **Run codebase-scanner** - Analyze project structure and build shared context
2. **Discover specialist agents** - Find all `*-reviewer.md` files in `.claude/agents/`
3. **Validate contracts** - Each agent declares its applicability via JSON contract
4. **Select specialists** - Based on flags, presets, or auto-detection from scanner output
5. **Run specialists in parallel** - Each uses scanner's specialized file lists
6. **Synthesize findings** - Deduplicate, calculate grade, identify positives
7. **Generate report** - Output to `docs/audits/audit-NN.{json,md}`

## Agent-Based Architecture

The review system uses **self-declaring agents**. Each specialist declares when it should run:

```json
{
  "id": "performance",
  "prefix": "PERF",
  "category": "performance",
  "applicability": {
    "always": false,
    "requires": { "structure.hasUI": true },
    "presets": ["prelaunch", "frontend"]
  }
}
```

**Adding a new specialist = creating one file.** No central registry to update.

## Available Specialists (8)

| Specialist | ID | Focus | Auto-runs when |
|------------|----|----|----------------|
| security-reviewer | security | Vulnerabilities, auth, injection | Always |
| test-coverage-reviewer | testing | Untested code paths | Always |
| performance-reviewer | performance | Core Web Vitals, blocking ops | hasUI = true |
| accessibility-reviewer | accessibility | WCAG compliance | hasUI = true |
| seo-reviewer | seo | Meta tags, Open Graph | hasUI = true, webapp/monorepo |
| type-safety-reviewer | typescript | TypeScript strictness | primaryLanguage = typescript |
| database-reviewer | database | N+1, SQL injection | hasDatabase = true |
| infrastructure-reviewer | infrastructure | CI secrets, health checks | hasCI = true |

## Output

Reports are saved to `docs/audits/`:
- `audit-NN.md` - Human-readable report
- `audit-NN.json` - Machine-readable (AuditReport schema)

The number NN increments automatically (01, 02, ...).

## Examples

```bash
# Interactive - auto-selects based on project type
/code-review

# Pre-deployment comprehensive check
/code-review --prelaunch

# Backend-focused review
/code-review --backend

# Just security (fastest)
/code-review --quick

# Specific combination
/code-review --security --database --testing

# All specialists
/code-review --all
```

## CRITICAL RULES

1. **NEVER make code changes during review** - Analysis only
2. **All findings require verification** - No pattern-matching without proof
3. **Report what you find** - Don't skip or minimize issues

---
