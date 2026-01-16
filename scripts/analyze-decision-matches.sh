#!/bin/bash
# Analyze decision match accuracy logs
# Phase 4.3 of v5.1.0 implementation
#
# Usage:
#   ./scripts/analyze-decision-matches.sh [log_file]
#
# Default log file: .claude/cache/decision-matches.log
#
# Output:
#   Summary statistics about decision matching accuracy

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default log file location
LOG_FILE="${1:-.claude/cache/decision-matches.log}"

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
  echo "Decision match log not found: $LOG_FILE"
  echo ""
  echo "The log file is created when code review runs with decision matching enabled."
  echo "Run a code review on a project with context/DECISIONS.md to generate logs."
  exit 1
fi

# Count total entries
total=$(wc -l < "$LOG_FILE" | tr -d ' ')

if [ "$total" -eq 0 ]; then
  echo "Decision match log is empty."
  exit 0
fi

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Decision Match Accuracy Analysis                          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Basic counts
matched=$(grep -c '"result":"matched"' "$LOG_FILE" || echo "0")
not_matched=$(grep -c '"result":"not_matched"' "$LOG_FILE" || echo "0")

# Calculate percentage
if [ "$total" -gt 0 ]; then
  match_percent=$((matched * 100 / total))
else
  match_percent=0
fi

echo "Total match attempts: $total"
echo "Matches above threshold: $matched ($match_percent%)"
echo "Below threshold: $not_matched"
echo ""

# Average confidence of matches
if [ "$matched" -gt 0 ]; then
  avg_confidence=$(jq -s '[.[] | select(.result == "matched") | .confidence] | add / length' "$LOG_FILE" 2>/dev/null || echo "N/A")
  echo "Average confidence of matches: $avg_confidence"
fi

# Most frequently matched decisions
echo ""
echo "Decisions most frequently matched:"
jq -r 'select(.result == "matched") | .decisionId' "$LOG_FILE" 2>/dev/null \
  | sort | uniq -c | sort -rn | head -5 \
  | while read count decision; do
      echo "  $decision: $count"
    done

# Matches by agent
echo ""
echo "Matches by agent:"
jq -r 'select(.result == "matched") | .agentId' "$LOG_FILE" 2>/dev/null \
  | sort | uniq -c | sort -rn \
  | while read count agent; do
      echo "  $agent: $count"
    done

# Recent activity
echo ""
echo "Recent entries (last 5):"
tail -5 "$LOG_FILE" | jq -r '"  \(.timestamp) | \(.agentId) | \(.findingId) -> \(.result)"' 2>/dev/null || tail -5 "$LOG_FILE"

echo ""
echo "Log file: $LOG_FILE"
echo "Log size: $(du -h "$LOG_FILE" | cut -f1)"

# Recommendations
echo ""
echo "────────────────────────────────────────────────────────────"
echo "Recommendations:"

if [ "$match_percent" -lt 5 ]; then
  echo "  ⚠ Low match rate ($match_percent%). Consider:"
  echo "    - Adding more decisions to DECISIONS.md"
  echo "    - Lowering the match threshold (currently 0.15)"
elif [ "$match_percent" -gt 30 ]; then
  echo "  ⚠ High match rate ($match_percent%). Consider:"
  echo "    - Reviewing if matches are accurate (false positives?)"
  echo "    - Raising the match threshold if too aggressive"
else
  echo "  ✓ Match rate ($match_percent%) is in healthy range (5-30%)"
fi
