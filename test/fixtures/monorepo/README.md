# Monorepo Fixture

This is a test fixture for AI Context System v5.0.

## Stack

- Turborepo (build system)
- TypeScript
- Next.js (web app)
- Express (API)

## Structure

```
apps/
  web/     - Next.js frontend
  api/     - Express backend
packages/
  ui/      - Shared UI components
  utils/   - Shared utilities
  config/  - Shared configuration
```

## Development

```bash
npm install
npm run dev
```

## Testing

```bash
npm test
```

## Building

```bash
npm run build
```
