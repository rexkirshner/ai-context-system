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

## File Scope

This agent reads from `databaseFiles` file list in scanner output.
Focuses on ORM schemas, migrations, queries, and data access layers.

## Purpose

Identify database issues with **verification**. Every finding must include evidence of the issue AND confirmation that no proper optimization exists. Supports common ORMs: Prisma, Drizzle, TypeORM, Mongoose, Sequelize.

## Input

- Codebase context from `.claude/cache/codebase-context.json`
- Focus on `databaseFiles` list
- Check ORM-specific patterns based on detected dependencies

## Output

Array of `AuditFinding` objects with `category: "database"` and `id` prefix `DB-`.

## Database Patterns

### Critical Severity

| Issue | Vuln Pattern | Mitigation Pattern |
|-------|--------------|-------------------|
| SQL injection | `$queryRaw\|$executeRaw` with `${` interpolation | `Prisma.sql\|parameterized\|prepared` |
| Raw query injection | `query\(.*\+\|execute\(.*\$\{` | `parameterized\|placeholder\|?` |

### High Severity

| Issue | Vuln Pattern | Mitigation Pattern |
|-------|--------------|-------------------|
| N+1 queries | `for.*await.*find(One\|Unique)\|forEach.*await` | `include:\|populate\|with:\|findMany` |
| Unbounded fetch | `findMany()\|find({})` without limit | `take:\|limit\|LIMIT\|first:\|skip:.*take:` |
| Missing transaction | Multiple writes without wrapper | `$transaction\|transaction\|BEGIN` |
| No connection pooling | Direct connection strings | `pooling\|pool:\|connectionLimit` |

### Medium Severity

| Issue | Vuln Pattern | Mitigation Pattern |
|-------|--------------|-------------------|
| SELECT * usage | `SELECT \*\|findMany()` without select | `select:\|SELECT.*specific.*columns` |
| Missing index hints | Large table full scans | `@index\|createIndex\|INDEX` |
| No retry logic | Database calls without retry | `retry\|backoff\|attempts` |

### Low Severity

| Issue | Vuln Pattern | Mitigation Pattern |
|-------|--------------|-------------------|
| No soft delete | `delete()\|destroy()` on user data | `deletedAt\|softDelete\|paranoid` |
| Raw SQL in code | Inline SQL strings | ORM query builders |
| Missing timestamps | Models without audit fields | `createdAt\|updatedAt\|timestamps` |

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

## Guardrails

- **DO** adjust patterns for detected ORM
- **DO** prioritize security issues (SQL injection) over performance
- **DO** check for batching in loops
- **DO NOT** flag ORM-generated queries
- **DO NOT** flag intentional unbounded queries (marked with comments)
- **DO NOT** flag admin/migration scripts differently from production code
