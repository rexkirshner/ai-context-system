#!/bin/bash
# Generate Audit Report
# Phase 5.2 of v5.1.0 implementation
#
# Generates both markdown and JSON audit reports from synthesized findings.
# Supports atomic writes and automatic filename generation.
#
# Usage:
#   ./scripts/generate-audit-report.sh < synthesized-findings.json
#   ./scripts/generate-audit-report.sh -i findings.json -o docs/audits
#   cat findings.json | ./scripts/generate-audit-report.sh
#
# Options:
#   -i, --input FILE      Input JSON file (default: stdin)
#   -o, --output DIR      Output directory (default: docs/audits)
#   -h, --help            Show this help message
#
# Output:
#   Creates audit-YYYY-MM-DD.{md,json} (or audit-YYYY-MM-DD-NNN.{md,json} for subsequent runs)
#   Prints paths to generated files

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source common functions
source "$PROJECT_ROOT/scripts/common-functions.sh"

# Default values
INPUT_FILE=""
OUTPUT_DIR="docs/audits"

# Print help
print_help() {
  cat << 'EOF'
Generate Audit Report - Creates markdown and JSON reports from synthesized findings

Usage:
  ./scripts/generate-audit-report.sh < synthesized-findings.json
  ./scripts/generate-audit-report.sh -i findings.json -o docs/audits
  cat findings.json | ./scripts/generate-audit-report.sh

Options:
  -i, --input FILE      Input JSON file (default: stdin)
  -o, --output DIR      Output directory (default: docs/audits)
  -h, --help            Show this help message

Input Format:
  The input JSON should contain synthesized findings with metadata, summary,
  and findings array. See .claude/schemas/audit-report.json for schema.

Output:
  Creates audit-YYYY-MM-DD.{md,json} files in the output directory.
  For multiple runs on the same day, creates audit-YYYY-MM-DD-002.{md,json}, etc.

Examples:
  # Generate from stdin
  echo '{"metadata":{},"summary":{},"findings":[]}' | ./scripts/generate-audit-report.sh

  # Generate from file
  ./scripts/generate-audit-report.sh -i audit-results.json

  # Specify output directory
  ./scripts/generate-audit-report.sh -i results.json -o reports/
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -i|--input)
      INPUT_FILE="$2"
      shift 2
      ;;
    -o|--output)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Use -h or --help for usage information" >&2
      exit 1
      ;;
  esac
done

# Read input
if [ -n "$INPUT_FILE" ]; then
  if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found: $INPUT_FILE" >&2
    exit 1
  fi
  report=$(cat "$INPUT_FILE")
else
  # Read from stdin
  if [ -t 0 ]; then
    echo "Error: No input provided. Use -i FILE or pipe JSON to stdin." >&2
    echo "Use -h or --help for usage information" >&2
    exit 1
  fi
  report=$(cat)
fi

# Validate input is valid JSON
if ! echo "$report" | jq . > /dev/null 2>&1; then
  echo "Error: Input is not valid JSON" >&2
  exit 1
fi

# Validate required fields
if ! echo "$report" | jq -e '.metadata' > /dev/null 2>&1; then
  echo "Error: Input missing required 'metadata' field" >&2
  exit 1
fi

if ! echo "$report" | jq -e '.summary' > /dev/null 2>&1; then
  echo "Error: Input missing required 'summary' field" >&2
  exit 1
fi

if ! echo "$report" | jq -e '.findings' > /dev/null 2>&1; then
  echo "Error: Input missing required 'findings' field" >&2
  exit 1
fi

# Generate reports
result=$(generate_audit_report "$report" "$OUTPUT_DIR")

# Extract paths
md_file=$(echo "$result" | jq -r '.markdown')
json_file=$(echo "$result" | jq -r '.json')

# Print results
echo "Audit reports generated:"
echo "  Markdown: $md_file"
echo "  JSON:     $json_file"
