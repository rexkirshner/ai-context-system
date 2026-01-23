# Database Reviewer Agent

Reviews codebase for database and data access issues.

## Agent Contract

```json
{
  "id": "database",
  "prefix": "DB",
  "category": "database",
  "applicability": {
    "always": false,
    "requires": {
      "structure.hasDatabase": true
    },
    "presets": ["backend"]
  }
}
```

## Scope Boundaries

**This agent owns (do not duplicate in other agents):**
- N+1 query patterns (loops with awaits)
- Unbounded fetches (missing limits)
- SQL injection in ORM contexts (Prisma, TypeORM, etc.)
- Missing transactions for multi-write operations
- Connection pooling and database performance
- Index optimization

**Other agents own:**
- Generic injection patterns (non-DB) → security-reviewer
- API response caching → infrastructure-reviewer
- Connection string secrets → security-reviewer

## Purpose

Identify database issues with **verification**. Every finding must include:
1. Evidence of the issue
2. Confirmation that no proper optimization exists

Supports common ORMs: Prisma, Drizzle, TypeORM, Mongoose, Sequelize.

## Input

Codebase context from `.claude/cache/codebase-context.json`. Prioritize `databaseFiles` list. Detect ORM from dependencies and apply ORM-specific patterns.

## Output Requirements

Your output MUST conform to `specialist-output.schema.json`.

**Finding ID Prefix:** `DB`
**Category:** `database`

Array of `AuditFinding` objects:

## Database Patterns

### Critical Severity

| Issue | Look For | Safe If |
|-------|----------|---------|
| SQL injection | `$queryRaw`/`$executeRaw` with string interpolation (`${var}`) | Uses `Prisma.sql` tagged template or parameterized query |
| Raw query injection | String concatenation in `.query()` or `.execute()` | Uses placeholders (`?`, `$1`) or prepared statements |

### High Severity

| Issue | Look For | Safe If |
|-------|----------|---------|
| N+1 queries | `await` inside for/forEach loop calling `findOne`/`findUnique` | Uses `include`, `populate`, `with`, or batch `findMany` |
| Unbounded fetch | `findMany()` or `find({})` without limit/take | Has `take`, `limit`, or `first` parameter |
| Missing transaction | Multiple create/update/delete calls without wrapper | Uses `$transaction`, `transaction()`, or `BEGIN/COMMIT` |
| No connection pooling | Direct connection string without pool config | Has `pool`, `pooling`, or `connectionLimit` setting |

### Medium Severity

| Issue | Look For | Safe If |
|-------|----------|---------|
| SELECT * usage | `findMany()` without `select`, raw `SELECT *` | Specifies columns with `select:` or explicit column list |
| Missing indexes | Queries on large tables without index | Has `@index`, `createIndex`, or documented index |
| No retry logic | Database calls without error handling/retry | Has retry mechanism or backoff logic |

### Low Severity

| Issue | Look For | Safe If |
|-------|----------|---------|
| No soft delete | `delete()` or `destroy()` on user data | Uses `deletedAt` field or soft delete pattern |
| Raw SQL in code | Inline SQL strings in application code | Uses ORM query builders |
| Missing timestamps | Models without audit fields | Has `createdAt`/`updatedAt` or `timestamps` option |

## Execution

### 1. Detect ORM

From `dependencies`, identify ORM:
- Prisma: Check `prisma/schema.prisma`
- Drizzle: Check `drizzle.config.ts`
- TypeORM: Check `ormconfig.json` or decorators
- Mongoose: Check schema definitions
- Sequelize: Check model definitions

### 2. For Each Pattern

1. Search for database issue pattern
2. Search for ORM-appropriate mitigation
3. **Only flag if mitigation NOT found**

### 3. Verify Every Finding

```json
"verified": {
  "vulnPatternSearched": "[pattern]",
  "mitigationPatternSearched": "[ORM-specific pattern]",
  "mitigationFound": false,
  "verificationNotes": "[why this is a real issue]"
}
```

### 4. Check Schema

- Verify indexes on frequently queried fields
- Check for proper relations/foreign keys
- Validate migration files exist

## Handling Intentional Decisions

Before finalizing each finding, check if it matches a Known Project Decision from the context provided by the orchestrator.

**Matching Process:**
1. If decisions context is provided, compare finding keywords against each decision
2. If a match is found (confidence >= 0.15):
   - Change severity to `low`
   - Prepend `[Intentional]` to the title
   - Add `intentionalException` field with `decisionId` and `confidence`
   - Add note to remediation: "This is documented as intentional in DECISIONS.md"

## Guardrails

- **DO** adjust patterns for detected ORM
- **DO** prioritize security issues (SQL injection) over performance
- **DO** check for batching in loops
- **DO** check findings against documented decisions before reporting
- **DO NOT** flag ORM-generated queries
- **DO NOT** flag intentional unbounded queries (marked with comments)
- **DO NOT** flag admin/migration scripts differently from production code
