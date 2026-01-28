# Grade Calculation Specification

Defines how code review audit grades are calculated from findings.

## Formula

```
Base Score = 100

Deductions (with caps to prevent single category dominating):
  Critical: -25 each (capped at -50 total)
  High:     -10 each (capped at -30 total)
  Medium:   -3 each  (capped at -20 total)
  Low:      -1 each  (capped at -10 total)
  Info:     0 (no deduction)

Final Score = max(0, Base - Deductions)
```

## Grade Thresholds

| Grade | Score Range | Interpretation |
|-------|-------------|----------------|
| A | 90-100 | Excellent - minor issues only |
| B | 80-89 | Good - some improvements needed |
| C | 70-79 | Acceptable - significant work needed |
| D | 60-69 | Poor - major issues to address |
| F | 0-59 | Failing - critical problems |

## Implementation

```javascript
function calculateGrade(findings) {
  let score = 100;

  const counts = {
    critical: findings.filter(f => f.severity === 'critical').length,
    high: findings.filter(f => f.severity === 'high').length,
    medium: findings.filter(f => f.severity === 'medium').length,
    low: findings.filter(f => f.severity === 'low').length
  };

  // Apply deductions with caps
  score -= Math.min(counts.critical * 25, 50);
  score -= Math.min(counts.high * 10, 30);
  score -= Math.min(counts.medium * 3, 20);
  score -= Math.min(counts.low * 1, 10);

  // Ensure non-negative
  score = Math.max(0, score);

  // Determine letter grade
  const grade =
    score >= 90 ? 'A' :
    score >= 80 ? 'B' :
    score >= 70 ? 'C' :
    score >= 60 ? 'D' : 'F';

  return { score, grade };
}
```

## Test Cases

| Findings | Expected Score | Grade | Reasoning |
|----------|----------------|-------|-----------|
| 0 of any | 100 | A | Clean codebase |
| 1 critical | 75 | C | 100 - 25 = 75 |
| 2 critical | 50 | F | 100 - 50 (capped) = 50 |
| 3 high | 70 | C | 100 - 30 = 70 |
| 5 high | 70 | C | 100 - 30 (capped) = 70 |
| 10 medium | 80 | B | 100 - 20 (capped) = 80 |
| 10 low | 90 | A | 100 - 10 (capped) = 90 |
| 1H + 5M + 10L | 65 | D | 100 - 10 - 15 - 10 = 65 |

## Deduplication Rules

Findings are deduplicated BEFORE grade calculation to prevent double-counting.

### When to Merge Findings

Findings are duplicates if ANY of these match:

1. **Same location** - Same file AND lines within 5 of each other
2. **Same file + title** - Same file AND same title (case-insensitive)

### Merge Strategy

When merging:
1. Keep finding with **higher severity** as primary
2. If same severity, keep **alphabetically first** specialist
3. Note merged finding IDs in report
4. Combine unique recommendations

### Example

```json
// SEC-001 at src/api.ts:15 - "Missing auth check"
// INFRA-003 at src/api.ts:17 - "Unprotected endpoint"
// → Merged: SEC-001 (higher severity or first alphabetically)
// → Note: "Merged with INFRA-003"
```

## Bash Implementation for Testing

```bash
calculate_grade() {
  local critical=$1 high=$2 medium=$3 low=$4
  local score=100

  local crit_ded=$((critical * 25))
  [ $crit_ded -gt 50 ] && crit_ded=50

  local high_ded=$((high * 10))
  [ $high_ded -gt 30 ] && high_ded=30

  local med_ded=$((medium * 3))
  [ $med_ded -gt 20 ] && med_ded=20

  local low_ded=$((low * 1))
  [ $low_ded -gt 10 ] && low_ded=10

  score=$((score - crit_ded - high_ded - med_ded - low_ded))
  [ $score -lt 0 ] && score=0

  echo $score
}

# Test cases
[ $(calculate_grade 0 0 0 0) -eq 100 ] && echo "PASS: No findings = 100" || echo "FAIL"
[ $(calculate_grade 1 0 0 0) -eq 75 ] && echo "PASS: 1 critical = 75" || echo "FAIL"
[ $(calculate_grade 2 0 0 0) -eq 50 ] && echo "PASS: 2 critical = 50" || echo "FAIL"
[ $(calculate_grade 0 3 0 0) -eq 70 ] && echo "PASS: 3 high = 70" || echo "FAIL"
[ $(calculate_grade 0 5 0 0) -eq 70 ] && echo "PASS: 5 high = 70 (capped)" || echo "FAIL"
[ $(calculate_grade 0 0 10 0) -eq 80 ] && echo "PASS: 10 medium = 80 (capped at 20)" || echo "FAIL"
[ $(calculate_grade 0 0 0 10) -eq 90 ] && echo "PASS: 10 low = 90 (capped)" || echo "FAIL"
[ $(calculate_grade 0 1 5 10) -eq 65 ] && echo "PASS: 1H+5M+10L = 65" || echo "FAIL"
```
