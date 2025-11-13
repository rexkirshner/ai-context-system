# Code Style Guide

This document defines coding standards and principles for this project.

<!-- TEMPLATE SECTION: KEEP ALL - Core principles are standard and should be preserved -->
## Core Principles

### 1. Simplicity Above All
- Make the smallest possible change to fix issues
- Every change should impact minimal code
- Choose simple solutions over complex ones
- If it can be done with less code, do it with less code

**Bad Example:**
```typescript
// Complex solution
function processUser(user: User) {
  const processor = new UserProcessor(user);
  const validator = new UserValidator();
  const transformer = new UserTransformer();

  if (validator.validate(user)) {
    return transformer.transform(processor.process(user));
  }
}
```

**Good Example:**
```typescript
// Simple solution
function processUser(user: User) {
  if (!user.email) return null;
  return { ...user, processed: true };
}
```

### 2. No Lazy Coding
- **NEVER** use temporary fixes or band-aids
- **ALWAYS** find and fix root causes
- **NO** shortcuts or workarounds
- Think like a senior developer

**Questions to ask:**
- Am I fixing the symptom or the cause?
- Will this need to be fixed again later?
- Is there a better way to solve this?

### 3. Root Cause Analysis
- Trace through ENTIRE code flow when debugging
- No assumptions, no shortcuts
- Understand why something broke, not just how to make it work
- Document root causes in commits

**Debugging Workflow:**
1. Reproduce the issue
2. Trace the COMPLETE code flow
3. Identify the root cause
4. Fix the cause, not the symptom
5. Verify the fix
6. Add test to prevent regression

### 4. Minimal Code Impact
- Changes should only affect necessary code
- Avoid broad refactors when targeted fix works
- Don't introduce bugs through overly complex changes
- Surgical precision over broad changes

**Review Questions:**
- Can this be done with fewer file changes?
- Am I touching files that don't need to change?
- Is this change as focused as possible?
<!-- END TEMPLATE SECTION -->

## Code Organization

<!-- TEMPLATE SECTION: CUSTOMIZE - Replace with your project-specific file structure -->
### File Structure
[FILL: Add your project-specific file organization rules]
<!-- END TEMPLATE SECTION -->


### Naming Conventions

**Files:**
- Components: `PascalCase.tsx`
- Utilities: `kebab-case.ts`
- Hooks: `use-hook-name.ts`
- Types: `types.ts` or inline with usage

**Variables & Functions:**
```typescript
// Variables: camelCase, descriptive
const userEmail = "email@example.com";
const isAuthenticated = true;

// Functions: camelCase, verb-based
function getUserById(id: string) { }
function validateEmail(email: string) { }

// Constants: UPPER_SNAKE_CASE
const MAX_RETRY_COUNT = 3;
const API_BASE_URL = "https://api.example.com";

// Types/Interfaces: PascalCase
interface User { }
type ApiResponse = { };
```

### Code Structure

**Function Size:**
- Keep functions under 50 lines
- If longer, break into smaller functions
- Each function should do ONE thing

**Nesting Depth:**
- Maximum 3 levels of nesting
- Use early returns to reduce nesting
- Extract complex conditions to variables

**Good Example:**
```typescript
function processOrder(order: Order) {
  if (!order.isValid) return null;
  if (!order.isPaid) return null;

  return fulfillOrder(order);
}
```

**Bad Example:**
```typescript
function processOrder(order: Order) {
  if (order.isValid) {
    if (order.isPaid) {
      if (order.items.length > 0) {
        // Deep nesting
      }
    }
  }
}
```

## TypeScript Standards

### Type Safety
- **NO** `any` types (use `unknown` if needed)
- **NO** type assertions unless absolutely necessary
- **YES** to strict mode
- **YES** to explicit return types on functions

```typescript
// Bad
function getUser(id: any): any {
  return users.find((u: any) => u.id === id);
}

// Good
function getUser(id: string): User | undefined {
  return users.find((u: User) => u.id === id);
}
```

### Interfaces vs Types
- Use `interface` for object shapes
- Use `type` for unions, intersections, utilities
- Be consistent within a file

## Error Handling

### Always Handle Errors
```typescript
// Bad
async function fetchUser(id: string) {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}

// Good
async function fetchUser(id: string) {
  try {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) {
      throw new Error(`Failed to fetch user: ${response.statusText}`);
    }
    return await response.json();
  } catch (error) {
    console.error('Error fetching user:', error);
    throw error; // or handle appropriately
  }
}
```

### Error Types
- Use custom error classes for different error types
- Include context in error messages
- Log errors appropriately

## Comments & Documentation

### When to Comment
- **Complex logic:** Explain WHY, not WHAT
- **Workarounds:** Explain why workaround is needed
- **TODOs:** Include ticket/issue number if applicable
- **Gotchas:** Warn about non-obvious behavior

```typescript
// Bad: Comments what the code does (obvious)
// Increment the counter
counter++;

// Good: Comments why the code does it (context)
// Increment counter here to avoid race condition with async fetch
counter++;
```

### JSDoc for Public APIs
```typescript
/**
 * Validates user email address
 * @param email - Email address to validate
 * @returns true if valid, false otherwise
 * @throws ValidationError if email is malformed
 */
function validateEmail(email: string): boolean {
  // implementation
}
```

## Testing Standards

### Test Coverage
- **Critical paths:** 100% coverage required
- **Business logic:** 100% coverage required
- **Utilities:** 100% coverage required
- **UI components:** Test key interactions

### Test Structure
```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', () => {
      // Arrange
      const userData = { email: 'test@example.com' };

      // Act
      const result = createUser(userData);

      // Assert
      expect(result).toBeDefined();
      expect(result.email).toBe(userData.email);
    });

    it('should throw error with invalid email', () => {
      // Test error case
    });
  });
});
```

## Git Workflow

### Commits
- Write clear, descriptive commit messages
- Reference issue numbers when applicable
- Make atomic commits (one logical change per commit)

**Commit Message Format:**
```
[Type]: Brief description

Detailed explanation of what changed and why.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Types:** feat, fix, refactor, docs, test, chore

### Pull Requests
- One feature/fix per PR
- Include description of changes
- Link related issues
- **NEVER push without explicit approval**

## Performance

### Optimization Rules
1. **Measure first:** Don't optimize without profiling
2. **Optimize hot paths:** Focus on frequently-run code
3. **Simple > Fast:** Prefer simple code unless perf critical
4. **User-perceived performance:** Prioritize what users notice

### Common Optimizations
- Memoize expensive computations
- Debounce/throttle user input handlers
- Virtualize long lists
- Code split large bundles
- Optimize images

## Security

### Input Validation
- **ALWAYS** validate user input
- **NEVER** trust client-side validation alone
- Sanitize data before rendering
- Use parameterized queries for database

### Secrets Management
- **NEVER** commit secrets to git
- Use environment variables
- Use `.env.local` for local secrets (gitignored)
- Document required env vars in `.env.example`

## Code Review Checklist

Before submitting code:
- [ ] Follows simplicity principle
- [ ] Root cause fixed, not symptom
- [ ] Minimal code impact
- [ ] No temporary fixes
- [ ] Types are strict (no `any`)
- [ ] Errors are handled
- [ ] Tests are written
- [ ] Code is documented
- [ ] Commits are clear
- [ ] Performance considered
- [ ] Security reviewed
- [ ] Tested in dev environment

## Language-Specific Guidelines

<!-- TEMPLATE SECTION: CUSTOMIZE - Add your language/framework-specific guidelines -->
### [FILL: Language: e.g., TypeScript/React]

[FILL: Add language-specific conventions here]
<!-- END TEMPLATE SECTION -->


**React-specific:**
- Prefer function components over class components
- Use hooks appropriately
- Keep components focused (single responsibility)
- Memoize expensive renders with `React.memo`

**[Other framework-specific rules]**

## Anti-Patterns to Avoid

### General Anti-Patterns
- ❌ God objects/functions (doing too much)
- ❌ Premature optimization
- ❌ Copy-paste programming
- ❌ Magic numbers/strings
- ❌ Deeply nested code
- ❌ Overly clever code

<!-- TEMPLATE SECTION: CUSTOMIZE - Add anti-patterns specific to your project -->
### Project-Specific Anti-Patterns
[FILL: Add patterns specific to this project to avoid]
<!-- END TEMPLATE SECTION -->

## Refactoring Guidelines

### When to Refactor
- When adding new feature to messy code
- When fixing bug in confusing code
- When code is hard to understand
- NOT when on a deadline

### How to Refactor
1. Ensure tests exist (or add them)
2. Make small, incremental changes
3. Run tests after each change
4. Commit frequently
5. Don't mix refactoring with new features

## Code Quality Tools

<!-- TEMPLATE SECTION: CUSTOMIZE - Configure your project's code quality tools -->
### Linting
- [FILL: Tool: e.g., ESLint with specific config]
- Run before commits
- Fix all errors, minimize warnings

### Formatting
- [FILL: Tool: e.g., Prettier]
- Auto-format on save
- Consistent config across team

### Type Checking
- [FILL: Tool: e.g., TypeScript strict mode]
- No errors allowed
- CI/CD enforces type safety
<!-- END TEMPLATE SECTION -->

## Review Process

### Self-Review
Before requesting review:
1. Read your own code changes
2. Check against this style guide
3. Run all tests
4. Test in dev environment
5. Check for console errors/warnings

### Code Review Focus
Reviewers should check for:
- Adherence to core principles
- Root cause vs symptom fixes
- Code simplicity
- Test coverage
- Security concerns

## Exceptions

### When Rules Can Be Broken
- Emergency production fixes (document why)
- Performance-critical code (with benchmarks)
- Third-party library constraints (document)

**Always document exceptions with:**
```typescript
// EXCEPTION: [Rule being broken]
// REASON: [Why it's necessary]
// TODO: [How to fix properly later]
```

## Questions to Ask

When writing code:
- Is this the simplest solution?
- Am I fixing root cause or symptom?
- Does this follow our principles?
- Would future me understand this?
- Is this necessary?

When reviewing code:
- Is this simple and clear?
- Are root causes addressed?
- Is code impact minimal?
- Are there any lazy shortcuts?
- Would I be proud of this code?
