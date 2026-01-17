# Known Issues & Limitations

> **[OPTIONAL FILE]** - Create this when tracking persistent issues, technical debt, or known limitations.

This document tracks current bugs, limitations, technical debt, and future improvements. Honesty is key - hidden issues compound.

## Current Status

**Last Updated:** [YYYY-MM-DD]
**Total Issues:** [N]
- Blocking: [N]
- High Priority: [N]
- Medium Priority: [N]
- Low Priority: [N]

---

## Blocking Issues

Issues that prevent deployment, cause data loss, or break critical functionality.

### [B1: Issue Title]
**Discovered:** [YYYY-MM-DD] Session [N]
**Severity:** Blocking
**Impact:** [What this breaks]

**Description:**
[Detailed description of the issue]

**Reproduction Steps:**
1. [Step 1]
2. [Step 2]
3. [Issue occurs]

**Root Cause:**
[Why this happens - if known]

**Workaround:**
[Temporary solution - if any]

**Fix Required:**
[What needs to be done]

**Related:**
- Code: `path/to/affected-file.ts:123`
- Session: See SESSIONS.md Session [N]
- Decision: See DECISIONS.md [Related decision]

---

## High Priority Issues

Issues that significantly impact user experience or developer productivity but don't block deployment.

### [H1: Issue Title]
**Discovered:** [YYYY-MM-DD] Session [N]
**Severity:** High
**Impact:** [What this affects]

[Same detailed structure as blocking issues]

---

## Medium Priority Issues

Issues that cause minor problems or annoyances but have workarounds.

### [M1: Issue Title]
**Discovered:** [YYYY-MM-DD] Session [N]
**Severity:** Medium
**Impact:** [What this affects]

**Description:**
[Brief description]

**Workaround:**
[How to work around this]

**Fix Complexity:** [Low/Medium/High]

---

## Low Priority Issues

Minor issues, edge cases, or cosmetic problems.

### [L1: Issue Title]
**Discovered:** [YYYY-MM-DD] Session [N]
**Severity:** Low
**Impact:** [Minimal impact description]

**Description:**
[Brief description]

**Fix:** [When/if to address]

---

## Limitations by Design

Intentional limitations due to scope, resources, or architectural decisions.

### [LD1: Limitation Title]
**Type:** By Design
**Decision:** [Reference to DECISIONS.md if applicable]

**What's Limited:**
[What doesn't work]

**Why:**
[Reason for limitation]

**Workaround:**
[How users can work around this]

**Future Consideration:**
[If/when this might be addressed]

---

## Technical Debt

Code or architecture that works but needs improvement. Accumulates "interest" over time.

### [TD1: Debt Item Title]
**Added:** [YYYY-MM-DD]
**Category:** [Architecture/Code Quality/Testing/Performance/etc.]
**Interest Rate:** [Low/Medium/High - how much this costs us]

**What:**
[Description of the debt]

**Why It Exists:**
[How this debt was incurred]

**Cost:**
[What this costs us - time, bugs, complexity]

**Repayment Plan:**
[How/when to address this]

**Examples:**
- `path/to/problematic-code.ts:123`

---

## Browser/Platform Specific Issues

Issues that only occur in specific environments.

### [ENV1: Environment-Specific Issue]
**Discovered:** [YYYY-MM-DD]
**Affected:** [Browser/OS/Device]

**Issue:**
[What doesn't work]

**Affected Versions:**
[Specific versions impacted]

**Workaround:**
[How to handle]

**Fix Status:**
[Planned/Investigating/Deferred]

---

## Performance Issues

Known performance bottlenecks or concerns.

### [P1: Performance Issue]
**Discovered:** [YYYY-MM-DD]
**Type:** [Load Time/Runtime/Memory/etc.]
**Impact:** [Slow page, lag, etc.]

**Measurement:**
- Current: [Metric]
- Target: [Metric]

**Root Cause:**
[Why it's slow]

**Optimization Plan:**
[How to improve]

---

## Security Considerations

Security limitations or areas needing attention (NOT active vulnerabilities - those are Blocking).

### [SEC1: Security Consideration]
**Identified:** [YYYY-MM-DD]
**Type:** [Auth/Data/Input/etc.]

**Concern:**
[What could be improved]

**Risk Level:** [Low/Medium]

**Mitigation:**
[Current safeguards]

**Improvement:**
[How to strengthen]

---

## Integration Issues

Problems with third-party services or APIs.

### [INT1: Integration Issue]
**Service:** [Service name]
**Discovered:** [YYYY-MM-DD]

**Issue:**
[What doesn't work properly]

**Impact:**
[Effect on functionality]

**Status:**
[Our side/Their side/Both]

**Workaround:**
[Temporary solution]

---

## Testing Gaps

Areas with insufficient test coverage or missing test types.

### [TEST1: Testing Gap]
**Area:** [What's not tested]
**Risk:** [What could break]

**Current Coverage:**
[Current state]

**Needed:**
[What tests are needed]

**Priority:** [Low/Medium/High]

---

## Documentation Gaps

Missing or incomplete documentation.

### [DOC1: Documentation Gap]
**Area:** [What's undocumented]
**Impact:** [Who this affects]

**Needed:**
[What docs are needed]

**Priority:** [Low/Medium/High]

---

## Future Improvements

Enhancements that would be nice to have but aren't fixing problems.

### [IMP1: Improvement Title]
**Type:** [Feature/Performance/UX/DX/etc.]
**Value:** [High/Medium/Low]
**Effort:** [High/Medium/Low]

**Description:**
[What this would add]

**Benefit:**
[Why this would be valuable]

**Complexity:**
[How hard to implement]

**Dependencies:**
[What needs to happen first]

---

## Edge Cases

Scenarios that rarely occur but could cause issues.

### [EDGE1: Edge Case]
**Scenario:** [When this occurs]
**Frequency:** [How often]
**Impact:** [What happens]

**Current Behavior:**
[What happens now]

**Desired Behavior:**
[What should happen]

**Fix Priority:** [Low/Medium/High]

---

## Recently Fixed Issues

Moved here when resolved for historical reference (prune periodically).

### [FIXED1: Issue Title]
**Was:** [Severity level]
**Fixed:** [YYYY-MM-DD] Session [N]
**How:** [Brief fix description]
**Commit:** [Git commit hash or reference]

---

## Issue Management

### Adding New Issues
1. Determine severity (Blocking → Low)
2. Add to appropriate section
3. Include all relevant fields
4. Link to sessions, code, decisions
5. Update status counts at top

### Resolving Issues
1. Verify fix in multiple scenarios
2. Add tests to prevent regression
3. Move to "Recently Fixed" section
4. Update status counts
5. Document in SESSIONS.md

### Prioritization
**Severity levels:**
- **Blocking:** Fix immediately, blocks deployment
- **High:** Fix soon, significantly impacts users/devs
- **Medium:** Fix when possible, has workarounds
- **Low:** Fix if time allows, minimal impact

**Priority factors:**
- User impact (how many affected, how severely)
- Workaround availability (none = higher priority)
- Data loss risk (potential = highest priority)
- Development friction (slows team = higher)

### Review Schedule
- **Weekly:** Review blocking/high issues
- **Monthly:** Review all issues, update priorities
- **Quarterly:** Prune fixed issues, reassess debt

---

## Metrics

**Issue Velocity:**
- Added this week: [N]
- Fixed this week: [N]
- Net change: [+/-N]

**Age Distribution:**
- < 1 week: [N]
- 1-4 weeks: [N]
- 1-3 months: [N]
- > 3 months: [N]

**Technical Debt:**
- Total items: [N]
- High interest: [N]
- Repayment planned: [N]

---

## Quick Reference

**Top Priority Issues:**
1. [Issue ID]: [Brief description]
2. [Issue ID]: [Brief description]
3. [Issue ID]: [Brief description]

**Quick Wins** (Low effort, high value):
1. [Issue ID]: [Brief description]
2. [Issue ID]: [Brief description]

**Watching** (Might get worse):
1. [Issue ID]: [Brief description]
2. [Issue ID]: [Brief description]

---

## Notes

- This document should be brutally honest
- Hidden issues compound and get worse
- Document the "why" behind weird code
- Temporary hacks should be marked as technical debt
- If something feels wrong, document it
- Future you will thank present you
