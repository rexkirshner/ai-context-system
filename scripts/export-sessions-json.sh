#!/bin/bash
# export-sessions-json.sh - Export SESSIONS.md to JSON format
#
# Version: 5.0.2
# Rewritten for robustness and cross-platform compatibility
#
# Features:
# - Multiple session header formats (pipe and dash)
# - Markdown code block detection (skips ``` content)
# - Partial date support (YYYY-MM accepted)
# - Template/example section exclusion
# - Proper JSON escaping for special characters
# - Titles with colons preserved (uses internal ||| delimiter)
# - Multi-paragraph TL;DR support
# - Atomic file operations (write temp → validate → move)
# - Debug mode with --debug flag
# - Graceful fallback when validators unavailable

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Source common functions if available
if [ -f "$SCRIPT_DIR/common-functions.sh" ]; then
  source "$SCRIPT_DIR/common-functions.sh"
fi

# Fallback colors
GREEN="${GREEN:-\033[0;32m}"
BLUE="${BLUE:-\033[0;34m}"
YELLOW="${YELLOW:-\033[1;33m}"
RED="${RED:-\033[0;31m}"
NC="${NC:-\033[0m}"

# Debug mode (set via --debug flag or DEBUG env var)
DEBUG="${DEBUG:-false}"

# =============================================================================
# Utility Functions
# =============================================================================

debug_log() {
  if [ "$DEBUG" = "true" ]; then
    echo "[DEBUG] $*" >&2
  fi
}

# Escape string for JSON
# Handles: backslashes, quotes, newlines, tabs, carriage returns
json_escape() {
  local str="$1"
  # Escape backslashes first (must be first!)
  str="${str//\\/\\\\}"
  # Escape double quotes
  str="${str//\"/\\\"}"
  # Escape newlines
  str="${str//$'\n'/\\n}"
  # Escape tabs
  str="${str//$'\t'/\\t}"
  # Escape carriage returns
  str="${str//$'\r'/\\r}"
  printf '%s' "$str"
}

# =============================================================================
# Session Counting Function
# =============================================================================

# Count actual sessions (not template sections)
# Excludes: Session Index, Session Template, Example, [N] placeholders
count_actual_sessions() {
  local file="$1"

  if [ ! -f "$file" ]; then
    echo "0"
    return 0
  fi

  # Get content before any template/example sections
  # Match only "## Session N" where N is a digit (not [N])
  # Exclude lines containing "Template", "Index", "[N]"
  sed -n '1,/^## \(Example\|Session Template\)/p' "$file" 2>/dev/null | \
    grep -E "^## Session [0-9]+" | \
    grep -v -i "Template" | \
    grep -v "Index" | \
    grep -v "\[N\]" | \
    wc -l | \
    tr -d ' '
}

# =============================================================================
# Session Parser (Code Block Aware)
# =============================================================================

# Internal delimiter for parsing (NOT colon - titles may contain colons!)
# Using ||| because it's extremely unlikely in natural text
DELIM="|||"

# Parse SESSIONS.md while respecting code blocks
# Output format: EVENT|||field1|||field2|||...
parse_sessions_file() {
  local file="$1"
  local in_code_block=false
  local in_session=false

  debug_log "Parsing file: $file"

  # Read file line by line, stopping before template sections
  local line_num=0
  local stop_parsing=false

  while IFS= read -r line || [ -n "$line" ]; do
    line_num=$((line_num + 1))

    # Stop at template/example sections
    if [[ "$line" =~ ^##\ (Example|Session\ Template) ]]; then
      debug_log "  Line $line_num: Stopping at template section"
      stop_parsing=true
    fi

    [ "$stop_parsing" = "true" ] && continue

    # Track code block state (toggle on ``` lines)
    if [[ "$line" =~ ^\`\`\` ]]; then
      if [ "$in_code_block" = "true" ]; then
        in_code_block=false
        debug_log "  Line $line_num: Exited code block"
      else
        in_code_block=true
        debug_log "  Line $line_num: Entered code block"
      fi
      continue
    fi

    # Skip content inside code blocks
    if [ "$in_code_block" = "true" ]; then
      continue
    fi

    # Check for session header: ## Session N ...
    if [[ "$line" =~ ^##\ Session\ ([0-9]+) ]]; then
      # Close previous session if open
      if [ "$in_session" = "true" ]; then
        echo "SESSION_END"
      fi

      local session_num="${BASH_REMATCH[1]}"
      local date=""
      local title=""

      # Try pipe format with title: ## Session N | DATE | TITLE
      if [[ "$line" =~ \|\ ([0-9]{4}-[0-9]{2}(-[0-9]{2})?)\ \|\ (.+)$ ]]; then
        date="${BASH_REMATCH[1]}"
        title="${BASH_REMATCH[3]}"
        debug_log "  Line $line_num: Session $session_num (pipe+title) date=$date title=$title"
      # Try pipe format without title: ## Session N | DATE
      elif [[ "$line" =~ \|\ ([0-9]{4}-[0-9]{2}(-[0-9]{2})?)$ ]]; then
        date="${BASH_REMATCH[1]}"
        debug_log "  Line $line_num: Session $session_num (pipe) date=$date"
      # Try dash format: ## Session N - DATE
      elif [[ "$line" =~ -\ ([0-9]{4}-[0-9]{2}(-[0-9]{2})?) ]]; then
        date="${BASH_REMATCH[1]}"
        debug_log "  Line $line_num: Session $session_num (dash) date=$date"
      else
        debug_log "  Line $line_num: Session $session_num (no date found)"
      fi

      echo "SESSION_START${DELIM}${session_num}${DELIM}${date}${DELIM}${title}"
      in_session=true
      continue
    fi

    # Regular content line (only if in a session)
    if [ "$in_session" = "true" ]; then
      echo "SESSION_CONTENT${DELIM}${line}"
    fi

  done < "$file"

  # Close final session
  if [ "$in_session" = "true" ]; then
    echo "SESSION_END"
  fi
}

# =============================================================================
# JSON Generation
# =============================================================================

# Generate JSON object for a session
generate_session_json() {
  local num="$1"
  local date="$2"
  local title="$3"
  local tldr="$4"
  local status="$5"

  cat << EOF
{
  "sessionNumber": $num,
  "date": "$(json_escape "$date")",
  "title": "$(json_escape "$title")",
  "tldr": "$(json_escape "$tldr")",
  "status": "$(json_escape "$status")"
}
EOF
}

# =============================================================================
# Main Export Function
# =============================================================================

export_sessions_to_json() {
  local context_dir="${1:-context}"
  local sessions_file="$context_dir/SESSIONS.md"
  local output_file="$context_dir/.sessions-data.json"

  debug_log "Context dir: $context_dir"
  debug_log "Sessions file: $sessions_file"
  debug_log "Output file: $output_file"

  # Verify sessions file exists
  if [ ! -f "$sessions_file" ]; then
    echo -e "${RED}Error: $sessions_file not found${NC}" >&2
    echo "   Run /init-context first to initialize the context system" >&2
    return 1
  fi

  # Count sessions
  local total_sessions
  total_sessions=$(count_actual_sessions "$sessions_file")
  debug_log "Total sessions: $total_sessions"

  echo -e "${BLUE}📊 Exporting SESSIONS.md to JSON...${NC}"
  echo "   Sessions found: $total_sessions"
  echo ""

  # Get metadata
  local version project_name exported_at
  version=$(grep -m 1 '"version":' "$context_dir/.context-config.json" 2>/dev/null | cut -d'"' -f4 || echo "5.0.2")
  project_name=$(grep -m 1 '"name":' "$context_dir/.context-config.json" 2>/dev/null | cut -d'"' -f4 || echo "Unknown Project")
  exported_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # ATOMIC OPERATION: Write to temp file first
  local temp_file
  temp_file=$(mktemp "${output_file}.XXXXXX")
  debug_log "Temp file: $temp_file"

  # Generate JSON
  {
    echo "{"
    echo '  "metadata": {'
    echo "    \"version\": \"$version\","
    echo "    \"exportedAt\": \"$exported_at\","
    echo "    \"projectName\": \"$(json_escape "$project_name")\","
    echo "    \"totalSessions\": $total_sessions"
    echo '  },'
    echo '  "sessions": ['

    local first=true
    local current_num=""
    local current_date=""
    local current_title=""
    local current_tldr=""
    local current_status="Complete"
    local in_tldr=false

    while IFS= read -r event; do
      case "$event" in
        SESSION_START${DELIM}*)
          # Parse: SESSION_START|||num|||date|||title
          local rest="${event#SESSION_START${DELIM}}"
          current_num="${rest%%${DELIM}*}"
          rest="${rest#*${DELIM}}"
          current_date="${rest%%${DELIM}*}"
          current_title="${rest#*${DELIM}}"

          current_tldr=""
          current_status="Complete"
          in_tldr=false

          debug_log "Processing session $current_num"
          ;;

        SESSION_CONTENT${DELIM}*)
          local content="${event#SESSION_CONTENT${DELIM}}"

          # Detect TL;DR section start
          if [[ "$content" =~ ^###\ TL\;DR ]] || [[ "$content" =~ ^\*\*TL\;DR ]]; then
            in_tldr=true
            debug_log "  Entered TL;DR section"
            continue
          fi

          # Detect end of TL;DR (next ### header)
          if [ "$in_tldr" = "true" ] && [[ "$content" =~ ^### ]]; then
            in_tldr=false
            debug_log "  Exited TL;DR section"
          fi

          # Capture TL;DR content (multiple paragraphs until next ###)
          if [ "$in_tldr" = "true" ]; then
            if [ -n "$content" ]; then
              if [ -n "$current_tldr" ]; then
                current_tldr="$current_tldr $content"
              else
                current_tldr="$content"
              fi
            fi
          fi

          # Detect status
          if [[ "$content" =~ Status:.*In\ Progress ]] || [[ "$content" =~ ⏳ ]]; then
            current_status="In Progress"
          fi
          ;;

        SESSION_END)
          # Output session JSON
          if [ "$first" = "true" ]; then
            first=false
          else
            echo ","
          fi

          debug_log "  Writing session $current_num to JSON"
          generate_session_json "$current_num" "$current_date" "$current_title" "$current_tldr" "$current_status" | sed 's/^/    /'
          ;;
      esac
    done < <(parse_sessions_file "$sessions_file")

    echo ""
    echo "  ]"
    echo "}"
  } > "$temp_file"

  # Validate output before replacing original
  echo -e "${BLUE}🔍 Validating JSON...${NC}"

  local validation_passed=false
  local validator_used=""

  # Try jq first (most common)
  if command -v jq > /dev/null 2>&1; then
    if jq empty "$temp_file" 2>/dev/null; then
      validation_passed=true
      validator_used="jq"

      # Pretty-print with jq
      local pretty_temp
      pretty_temp=$(mktemp)
      if jq '.' "$temp_file" > "$pretty_temp" 2>/dev/null; then
        mv "$pretty_temp" "$temp_file"
        debug_log "Formatted with jq"
      else
        rm -f "$pretty_temp"
      fi
    fi
  fi

  # Try python3 as fallback
  if [ "$validation_passed" = "false" ] && command -v python3 > /dev/null 2>&1; then
    if python3 -c "import json; json.load(open('$temp_file'))" 2>/dev/null; then
      validation_passed=true
      validator_used="python3"
    fi
  fi

  # Try json_validate from common-functions if available
  if [ "$validation_passed" = "false" ] && type json_validate > /dev/null 2>&1; then
    if json_validate "$temp_file" 2>/dev/null; then
      validation_passed=true
      validator_used="json_validate"
    fi
  fi

  # No validator available
  if [ "$validation_passed" = "false" ] && \
     ! command -v jq > /dev/null 2>&1 && \
     ! command -v python3 > /dev/null 2>&1 && \
     ! type json_validate > /dev/null 2>&1; then
    echo -e "${YELLOW}   ⚠️  No JSON validator available (jq, python3)${NC}"
    echo "   Output not validated, proceeding anyway"
    validation_passed=true  # Proceed with caution
    validator_used="none"
  fi

  if [ "$validation_passed" = "true" ]; then
    # ATOMIC: Move temp file to final location
    mv "$temp_file" "$output_file"

    echo -e "   ${GREEN}✅ Valid JSON${NC}"
    [ -n "$validator_used" ] && [ "$validator_used" != "none" ] && echo "   Validated with: $validator_used"
    echo ""

    # Summary
    local file_size
    file_size=$(du -h "$output_file" | cut -f1)

    echo -e "${GREEN}✅ Export complete!${NC}"
    echo ""
    echo "   Output: $output_file"
    echo "   Size: $file_size"
    echo "   Sessions: $total_sessions"
    echo ""

    return 0
  else
    echo -e "${RED}❌ Invalid JSON generated${NC}" >&2
    echo "   Temp file preserved for debugging: $temp_file" >&2
    # Don't delete temp file - useful for debugging
    return 1
  fi
}

# =============================================================================
# Argument Parsing and Main
# =============================================================================

main() {
  local context_dir=""

  # Parse arguments
  while [ $# -gt 0 ]; do
    case "$1" in
      --debug)
        DEBUG="true"
        shift
        ;;
      --help|-h)
        echo "Usage: export-sessions-json.sh [OPTIONS] [CONTEXT_DIR]"
        echo ""
        echo "Export SESSIONS.md to JSON format."
        echo ""
        echo "Options:"
        echo "  --debug    Enable debug output"
        echo "  --help     Show this help message"
        echo ""
        echo "Arguments:"
        echo "  CONTEXT_DIR  Path to context directory (default: context/)"
        exit 0
        ;;
      -*)
        echo "Unknown option: $1" >&2
        echo "Use --help for usage information" >&2
        exit 1
        ;;
      *)
        # Positional argument = context directory
        context_dir="$1"
        shift
        ;;
    esac
  done

  # Default context directory
  if [ -z "$context_dir" ]; then
    context_dir="${BASE_DIR}/context"
  fi

  debug_log "Starting export-sessions-json.sh"
  debug_log "DEBUG=$DEBUG"
  debug_log "context_dir=$context_dir"

  export_sessions_to_json "$context_dir"
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
