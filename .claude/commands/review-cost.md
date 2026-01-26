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
- `**/package.json` (for dependency costs)
- `**/api/**` routes (for API call patterns)

Consider running: Cloud provider cost dashboards, database query analyzers, or bundle size analyzers.

## What to Check

Skip sections that don't apply to your deployment model.

### Serverless & Edge Platforms (Vercel, Netlify, Cloudflare)
- **Rendering strategy**: SSR on every request vs ISR/SSG (static is free, SSR costs per invocation)
- **Edge vs Serverless runtime**: Edge is cheaper but has limitations
- **Function duration**: Long-running functions cost more—optimize or move to background jobs
- **Function memory**: Over-allocated memory increases cost per invocation
- **Cold starts**: Patterns that prevent warm instances (too many routes, large bundles)
- **Image optimization**: Excessive transformations (Vercel charges per optimization)
- **Build minutes**: Slow builds consume CI/CD budget
- **Bandwidth**: Large responses, missing compression, unoptimized assets

### Database & ORM (Prisma, Drizzle, etc.)
- **N+1 queries**: The #1 cost multiplier—use `include`/`select` or dataloaders
- **Connection pooling**: Missing pooling exhausts connections (use PgBouncer or Prisma Accelerate)
- **Query efficiency**: Fetching unused fields, missing pagination, full table scans
- **Transaction overuse**: Wrapping reads in transactions unnecessarily
- **Over-provisioned tiers**: Database tier larger than needed
- **Read replicas**: Not using replicas for read-heavy workloads

### API Usage
- Unnecessary calls to paid APIs
- Missing caching for API responses
- Batch operations not utilized
- Rate limit handling (retries adding cost)
- Cheaper API tier opportunities

### Caching
- Missing cache layers causing repeated expensive operations
- Cache invalidation inefficiencies
- In-memory vs external cache decisions
- TTL optimization

### Code Patterns
- **N+1 queries**: Loops that make database/API calls (cost multiplier)
- Polling vs webhooks
- Synchronous vs async for expensive operations
- Retry storms
- Missing circuit breakers

### Traditional Infrastructure (VMs, Containers, Kubernetes)
Skip this section for serverless deployments.
- Over-provisioned instances or services
- Unused resources still incurring costs
- Reserved vs on-demand opportunities
- Region selection inefficiencies
- Auto-scaling configuration

### Storage
- Large files that could be compressed
- Unused assets consuming storage
- Missing CDN for static assets
- Storage tier optimization (hot vs cold)
- Duplicate data

### Third-Party Services
- Unused paid features
- Tier optimization opportunities
- Alternative cheaper services
- License optimization

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
