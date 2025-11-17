# Known Issues

Existing content here.


## [CRITICAL] SQL injection vulnerability in search API
**Found:** 2025-11-17 (Code Review - Session 20)
**Location:** `api/search.ts:123`
**Impact:** User input directly concatenated into SQL query - allows arbitrary SQL execution
**Severity:** CRITICAL (Security)
**Review:** See [Code Review Report](../artifacts/code-reviews/session-20-review.md#C1)
**Status:** 🔴 Open


## [CRITICAL] Missing rate limiting on authentication endpoints
**Found:** 2025-11-17 (Code Review - Session 20)
**Location:** `api/auth/register.ts:45`
**Impact:** Endpoints vulnerable to brute force attacks
**Severity:** CRITICAL (Security)
**Review:** See [Code Review Report](../artifacts/code-reviews/session-20-review.md#C2)
**Status:** 🔴 Open


## [CRITICAL] Hardcoded secrets in configuration
**Found:** 2025-11-17 (Code Review - Session 20)
**Location:** `config.ts:89`
**Impact:** Database credentials and API keys committed to repository
**Severity:** CRITICAL (Security)
**Review:** See [Code Review Report](../artifacts/code-reviews/session-20-review.md#C3)
**Status:** 🔴 Open

