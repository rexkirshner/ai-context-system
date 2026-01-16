# DECISIONS.md

---

## D001 - Handle "Quotes" and Special Characters

**Date:** 2025-01-15
**Status:** Accepted

### Decision

Use JSON for config with special chars like: "quotes", backslashes \, tabs	, and newlines.

Code example:
```javascript
const msg = "Hello \"World\"";
const path = "C:\\Users\\test";
```

### Rationale

Need to ensure parser handles:
- Double quotes: "example"
- Backslashes: C:\path\to\file
- Unicode: emoji 🎉 and accents café
- Tabs and	whitespace
- Angle brackets: <script>alert("xss")</script>

---
