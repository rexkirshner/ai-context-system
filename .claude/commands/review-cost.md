---
name: review-cost
description: Cost optimization review of the codebase
---

# /review-cost

Perform a cost optimization review of the codebase.

## Scope

Review the files in the Working Set (from `context/STATUS.md`), or if specified, a particular file/directory.

### Scope Expansion

If the Working Set lacks infrastructure files, expand to include:
- `**/vercel.json`, `**/netlify.toml`, `**/serverless.*`
- `**/prisma/**`, `**/drizzle/**`, `**/*database*`
- `**/next.config.*`, `**/vite.config.*`
- `package.json` (for dependency costs)
- `**/api/**` routes (for API call patterns)

Consider running: Cloud provider cost dashboards, database query analyzers, or bundle size analyzers.

## What to Check

### Cloud Resources
- Over-provisioned instances or services
- Unused resources still incurring costs
- Reserved vs on-demand opportunities
- Region selection inefficiencies
- Auto-scaling configuration

### Database
- Inefficient queries causing high read/write costs
- Over-provisioned database tiers
- Missing connection pooling
- Unnecessary indexes consuming storage
- Read replicas vs primary usage

### API Usage
- Unnecessary calls to paid APIs
- Missing caching for API responses
- Batch operations not utilized
- Rate limit handling (retries adding cost)
- Cheaper API tier opportunities

### Storage
- Large files that could be compressed
- Unused assets consuming storage
- Missing CDN for static assets
- Storage tier optimization (hot vs cold)
- Duplicate data

### Serverless / Functions
- Over-allocated memory
- Long-running functions that should be services
- Cold start patterns adding latency costs
- Unnecessary invocations
- Timeout configurations

### Caching
- Missing cache layers causing repeated expensive operations
- Cache invalidation inefficiencies
- In-memory vs external cache decisions
- TTL optimization

### Third-Party Services
- Unused paid features
- Tier optimization opportunities
- Alternative cheaper services
- License optimization

### Code Patterns
- N+1 queries (cost multiplier)
- Polling vs webhooks
- Synchronous vs async for expensive operations
- Retry storms
- Missing circuit breakers

## Output Format

```markdown
## Cost Optimization Review

### High Impact Opportunities
- [Issue]: [Description, location, and estimated savings potential]

### Medium Impact Opportunities
- [Issue]: [Description and location]

### Low-Hanging Fruit
- [Quick wins that are easy to implement]

### Already Optimized
- [Good patterns found]

### Checked Areas
- [List of what was reviewed]

### Recommended Next Steps
- [Prioritized actions]
```

## Behavior

1. Read STATUS.md to understand current context (if it doesn't exist, suggest running `/init-context` first or ask user to specify scope)
2. Review files in Working Set (or specified scope)
3. Check against cost optimization criteria above
4. Produce report in specified format
5. Do NOT make changes - report only

## Done

Provide the cost optimization review report.
