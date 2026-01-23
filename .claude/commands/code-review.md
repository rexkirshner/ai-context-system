---
name: code-review
description: Run comprehensive code review using the agent-based system
---

# /code-review Command

Run comprehensive code review using the agent-based system. This command delegates to the `code-reviewer` orchestrator agent which dynamically discovers and runs specialist reviewers.

> **Execution Model:** Each bash block runs in an isolated shell.
> Variables do not persist between blocks. See `.claude/docs/shell-execution-model.md`.

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
| `--libraries` | Just library adoption reviewer (identifies homegrown code to replace with battle-tested libraries) |
| `--incremental` | Only review files changed since last audit |

Multiple specific flags can be combined: `/code-review --security --database`

## How to Execute (v5.1.5)

This command uses the Task tool to spawn the code-reviewer orchestrator agent.

**Direct invocation pattern:**
```
Task(
    subagent_type="general-purpose",
    prompt="You are the code-reviewer orchestrator. Read and follow
            .claude/agents/code-reviewer.md to run a comprehensive code review.
            Flags: [--prelaunch|--all|--security|etc]",
    description="Run code review"
)
```

**What happens when executed:**
1. Orchestrator reads `.claude/agents/code-reviewer.md`
2. Spawns `codebase-scanner` agent to build shared context
3. Discovers all `*-reviewer.md` files in `.claude/agents/`
4. Selects specialists based on flags and project type
5. Spawns selected specialists in parallel (using Task tool)
6. Runs `synthesis-agent` to deduplicate and grade findings
7. Generates report to `docs/audits/audit-NN.{md,json}`

**Alternative - manual orchestration:**
If you prefer to run agents manually:
1. Read `.claude/agents/codebase-scanner.md`, run its scan
2. Read each specialist agent file, run those applicable to your project
3. Read `.claude/agents/synthesis-agent.md`, combine and deduplicate results

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

## Available Specialists (9)

| Specialist | File | Prefix | Auto-runs when |
|------------|------|--------|----------------|
| security-reviewer | security-reviewer.md | SEC- | Always |
| test-coverage-reviewer | test-coverage-reviewer.md | TEST- | Always |
| library-adoption-reviewer | library-adoption-reviewer.md | LIB- | --all or --libraries only |
| performance-reviewer | performance-reviewer.md | PERF- | hasUI = true |
| accessibility-reviewer | accessibility-reviewer.md | A11Y- | hasUI = true |
| seo-reviewer | seo-reviewer.md | SEO- | hasUI = true |
| type-safety-reviewer | type-safety-reviewer.md | TS- | primaryLanguage = typescript |
| database-reviewer | database-reviewer.md | DB- | hasDatabase = true |
| infrastructure-reviewer | infrastructure-reviewer.md | INFRA- | hasCI = true |

### Verification Checklist (v5.1.5)

**When running `--all`, verify all 9 specialists launched:**

- [ ] security-reviewer launched
- [ ] test-coverage-reviewer launched
- [ ] library-adoption-reviewer launched
- [ ] performance-reviewer launched
- [ ] accessibility-reviewer launched
- [ ] seo-reviewer launched
- [ ] type-safety-reviewer launched
- [ ] database-reviewer launched
- [ ] infrastructure-reviewer launched

**Discovery command:**
```bash
ls .claude/agents/*-reviewer.md | wc -l
# Should output: 9

# List all specialists:
ls .claude/agents/*-reviewer.md | sed 's|.*/||' | sort
```

**If count differs:** Check for missing or renamed agent files. All specialists must be present for `--all` to work correctly

## Specialist Selection Logic

### How Specialists Are Selected

When running `/code-review` without explicit specialist flags:

1. **Codebase Scanner** runs first, producing `codebase-context.json` with detected features
2. **Each specialist checks** its `applicability` contract against scanner output
3. **Applicable specialists** are launched in parallel

### Selection Rules by Specialist

| Specialist | Selection Rule | Scanner Field |
|------------|----------------|---------------|
| security-reviewer | Always runs | `always: true` |
| test-coverage-reviewer | Always runs | `always: true` |
| performance-reviewer | Has UI/frontend | `structure.hasUI: true` |
| accessibility-reviewer | Has UI/frontend | `structure.hasUI: true` |
| seo-reviewer | Has UI + webapp/monorepo | `structure.hasUI: true` |
| type-safety-reviewer | TypeScript project | `structure.primaryLanguage: "typescript"` |
| database-reviewer | Has database/ORM | `structure.hasDatabase: true` |
| infrastructure-reviewer | Has CI configuration | `structure.hasCI: true` |
| library-adoption-reviewer | Manual only | Requires `--all` or `--libraries` flag |

### Manual Override

Explicit flags always run the specified specialist, regardless of scanner detection:

```bash
# Force infrastructure review even without CI detected
/code-review --infrastructure

# Force database review even without ORM detected
/code-review --database

# Run library adoption (never auto-selected)
/code-review --libraries
```

### Selection Examples

**SvelteKit app with Prisma + GitHub Actions:**
```
Scanner detects: hasUI=true, hasDatabase=true, hasCI=true, primaryLanguage=typescript

Auto-selected (7):
  ✓ security-reviewer (always)
  ✓ test-coverage-reviewer (always)
  ✓ performance-reviewer (hasUI)
  ✓ accessibility-reviewer (hasUI)
  ✓ seo-reviewer (hasUI)
  ✓ type-safety-reviewer (typescript)
  ✓ database-reviewer (hasDatabase)
  ✓ infrastructure-reviewer (hasCI)

Not selected:
  ✗ library-adoption-reviewer (requires --all or --libraries)
```

**Express.js API (no UI):**
```
Scanner detects: hasUI=false, hasDatabase=true, hasCI=false, primaryLanguage=javascript

Auto-selected (3):
  ✓ security-reviewer (always)
  ✓ test-coverage-reviewer (always)
  ✓ database-reviewer (hasDatabase)

Not selected:
  ✗ performance-reviewer (no UI)
  ✗ accessibility-reviewer (no UI)
  ✗ seo-reviewer (no UI)
  ✗ type-safety-reviewer (not typescript)
  ✗ infrastructure-reviewer (no CI)
  ✗ library-adoption-reviewer (requires flag)
```

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

# Library adoption recommendations
/code-review --libraries

# All specialists (includes library adoption reviewer)
/code-review --all
```

## Debug Mode (--verbose) (v5.1.5)

For debugging or understanding the review process:

```bash
/code-review --prelaunch --verbose
```

**Verbose output includes:**
- Scanner output summary (detected features: hasUI, hasDatabase, etc.)
- Specialist selection reasoning (why each was included or excluded)
- Individual finding counts per specialist
- Deduplication statistics (before/after synthesis)

**Example verbose output:**
```
🔍 Scanner Results:
   hasUI: true, hasDatabase: true, hasTypeScript: true, hasCI: false

📋 Specialist Selection:
   ✓ security-reviewer: always=true
   ✓ test-coverage-reviewer: always=true
   ✓ performance-reviewer: hasUI=true (detected)
   ✓ accessibility-reviewer: hasUI=true (detected)
   ✓ database-reviewer: hasDatabase=true (Prisma detected)
   ✗ infrastructure-reviewer: hasCI=false (SKIPPED)

🔄 Running 7 specialists...
   security-reviewer: 5 findings
   test-coverage-reviewer: 3 findings
   performance-reviewer: 2 findings
   ...

📊 Synthesis:
   Raw findings: 23
   After deduplication: 18 (22% reduction)
   Grade: B (79/100)
```

This is useful for:
- Understanding why certain specialists were skipped
- Debugging agent discovery issues
- Verifying scanner detection accuracy
- Identifying deduplication effectiveness

## CRITICAL RULES

1. **NEVER make code changes during review** - Analysis only
2. **All findings require verification** - No pattern-matching without proof
3. **Report what you find** - Don't skip or minimize issues

---
