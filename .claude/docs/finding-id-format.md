# Finding ID Format

Standard format for identifying findings across all code review specialists.

## Format

`{PREFIX}-{NUMBER}`

Where:
- `PREFIX` is a 2-5 letter code unique to each specialist
- `NUMBER` is a 3-digit sequential number (e.g., 001, 002)

Examples: `SEC-001`, `PERF-003`, `A11Y-012`

## Prefixes by Specialist

| Specialist Agent | Prefix | Example IDs |
|------------------|--------|-------------|
| security-reviewer | SEC | SEC-001, SEC-002 |
| performance-reviewer | PERF | PERF-001, PERF-002 |
| accessibility-reviewer | A11Y | A11Y-001, A11Y-002 |
| seo-reviewer | SEO | SEO-001, SEO-002 |
| database-reviewer | DB | DB-001, DB-002 |
| infrastructure-reviewer | INFRA | INFRA-001, INFRA-002 |
| type-safety-reviewer | TS | TS-001, TS-002 |
| test-coverage-reviewer | TEST | TEST-001, TEST-002 |
| library-adoption-reviewer | LIB | LIB-001, LIB-002 |

## Positive Finding IDs

Format: `{PREFIX}-POS{NUMBER}`

Examples: `SEC-POS1`, `PERF-POS2`

Positive findings highlight good practices observed in the codebase.

## Severity (Separate Field)

Severity is NOT embedded in the ID. Instead, it's a separate field in the finding:

```json
{
  "id": "SEC-001",
  "severity": "high",
  ...
}
```

Valid severity values:
- `critical` - Security vulnerability, data loss risk, production blockers
- `high` - Significant issue affecting users or system reliability
- `medium` - Should fix but not urgent
- `low` - Minor improvement
- `info` - Observation only, no action required

## Why This Format

1. **Unique IDs** - Prefix ensures no collisions between specialists
2. **Traceable** - Easy to identify which specialist found the issue
3. **Stable** - IDs don't change if severity is reclassified
4. **Mergeable** - Synthesis agent can deduplicate by location, not ID

## Usage in Reports

When referencing findings:
- In markdown: Use the full ID (e.g., "See SEC-001 for details")
- In JSON: Use the ID as a key for deduplication tracking
- In merged findings: Note both IDs (e.g., "SEC-001 merged with INFRA-003")

## Schema Reference

- Finding schema: `.claude/schemas/audit-finding.json`
- Specialist output schema: `.claude/schemas/specialist-output.schema.json`
- Final report schema: `.claude/schemas/audit-report.json`
