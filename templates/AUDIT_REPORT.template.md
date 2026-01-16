# Code Audit Report

**Project:** {{PROJECT_NAME}}
**Date:** {{TIMESTAMP}}
**Grade:** {{GRADE}}

---

## Executive Summary

| Metric | Value |
|--------|-------|
| Files Scanned | {{FILES_SCANNED}} |
| Agents Run | {{AGENTS_RUN}} |
| Total Findings | {{TOTAL_FINDINGS}} |
| Deduplication | {{REDUCTION_PERCENT}}% reduction |

### Severity Breakdown

| Severity | Count |
|----------|-------|
| Critical | {{CRITICAL_COUNT}} |
| High | {{HIGH_COUNT}} |
| Medium | {{MEDIUM_COUNT}} |
| Low | {{LOW_COUNT}} |

---

## Positives

{{POSITIVES}}

---

## Findings

{{FINDINGS}}

---

## Deduplication Statistics

| Stage | Count |
|-------|-------|
| Raw findings | {{RAW_FINDINGS}} |
| After location dedup | {{AFTER_LOCATION_DEDUP}} |
| After pattern grouping | {{AFTER_PATTERN_GROUPING}} |
| **Reduction** | **{{REDUCTION_PERCENT}}%** |

---

## Metadata

- **Schema Version:** {{SCHEMA_VERSION}}
- **ACS Version:** {{ACS_VERSION}}
- **Generated:** {{TIMESTAMP}}
