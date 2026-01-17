#!/bin/bash
# Common functions used across AI Context System commands
# Version: See VERSION file at repository root
#
# This file extracts duplicate code from multiple commands into shared utilities.
# Source this file at the beginning of any command that needs these functions.
#
# Usage:
#   source scripts/common-functions.sh

# Exit codes (standardized across all commands)
export EXIT_SUCCESS=0
export EXIT_ERROR=1
export EXIT_MISUSE=2
export EXIT_NOT_FOUND=3
export EXIT_NETWORK=4
export EXIT_PERMISSION=5
export EXIT_VALIDATION=6

# Cache configuration
export CACHE_DIR=".claude/.cache"
export CACHE_TTL=60  # seconds

# Color codes for output
export RED='\033[0;31m'
export YELLOW='\033[1;33m'
export GREEN='\033[0;32m'
export BLUE='\033[0;34m'
export NC='\033[0m' # No Color

# =============================================================================
# TTY-Aware Color Output (v5.0.2)
# =============================================================================

# Color output only if stdout is a terminal
#
# When output is piped or redirected, ANSI escape codes cause garbled text.
# This function detects the output mode and strips codes when appropriate.
#
# Handles ALL ANSI escape sequences:
# - Colors: \e[31m (red), \e[0m (reset), etc.
# - Cursor: \e[2J (clear), \e[H (home), etc.
# - Extended: \e[38;5;XXXm (256 colors), \e[38;2;R;G;Bm (24-bit)
# - Private sequences: \e[?25h (show cursor), etc.
#
# Usage:
#   color_echo "${RED}Error${NC}"
#   color_echo "${GREEN}Success${NC}"
#
# Args:
#   $1 - String to output (may contain ANSI escape codes)
#
# Example:
#   color_echo "${RED}❌ Build failed${NC}"
#   result=$(color_echo "${GREEN}✅ Passed${NC}" | cat)  # Codes stripped
#
color_echo() {
  local message="$1"

  if [ -t 1 ]; then
    # stdout is a terminal - use colors
    echo -e "$message"
  else
    # stdout is piped/redirected - strip ALL ANSI escape sequences
    # Pattern matches:
    #   \x1b or \033 - escape character
    #   \[           - CSI (Control Sequence Introducer)
    #   [0-9;?]*     - parameters (including ? for private sequences)
    #   [A-Za-z]     - final byte (command)
    #
    # Try perl first (more reliable across platforms), fall back to sed
    if command -v perl > /dev/null 2>&1; then
      echo -e "$message" | perl -pe 's/\e\[[0-9;?]*[A-Za-z]//g'
    else
      # sed may not handle \x1b on all platforms, but covers most cases
      echo -e "$message" | sed 's/\x1b\[[0-9;?]*[A-Za-z]//g'
    fi
  fi
}

# =============================================================================
# Repository Root Detection
# =============================================================================

# Get the repository root directory
# Works from any subdirectory within a git repository
# Falls back to current directory if not in a git repo
#
# Usage:
#   REPO_ROOT=$(get_repo_root)
#   ls "$REPO_ROOT/.claude/commands/"
#
# Returns:
#   Absolute path to repository root, or pwd if not in git repo
get_repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

# =============================================================================
# Context Directory Management
# =============================================================================

# Find context directory by searching up to 2 parent directories
# Used in: save.md, save-full.md, review-context.md, validate-context.md,
#          organize-docs.md, export-context.md, session-summary.md, update-templates.md
find_context_dir() {
  for dir in "context" "../context" "../../context"; do
    if [ -d "$dir" ]; then
      echo "$dir"
      return 0
    fi
  done
  return 1
}

# =============================================================================
# DECISIONS.md Parsing (v5.1.0)
# =============================================================================

# Parse DECISIONS.md and output JSON array of decisions
#
# Extracts decision blocks from a DECISIONS.md file. Each decision is expected
# to have a header in the format: ## D### - Title
#
# The function handles:
# - Empty files (returns [])
# - Non-existent files (returns [])
# - Malformed headers (skips them)
# - Special characters in content (properly escapes for JSON)
#
# Usage:
#   decisions=$(parse_decisions "context/DECISIONS.md")
#   echo "$decisions" | jq '.[0].id'
#
# Args:
#   $1 - Path to DECISIONS.md file
#
# Returns:
#   JSON array of decision objects:
#   [{"id":"D001","title":"Decision Title","content":"Full content..."}]
#
# Example:
#   parse_decisions "context/DECISIONS.md" | jq 'length'
#   # Returns: 5 (number of decisions)
#
parse_decisions() {
  local decisions_file="$1"

  # Return empty array if file doesn't exist or is empty
  if [ ! -f "$decisions_file" ] || [ ! -s "$decisions_file" ]; then
    echo "[]"
    return 0
  fi

  # Use awk to parse the file - handles multi-line content properly
  # Pattern: ## D### - Title (where ### is numbers)
  awk '
    BEGIN {
      first = 1
      printf "["
    }

    # Function to escape and output a decision as JSON
    # This eliminates code duplication (was repeated 3 times)
    function output_decision(dec_id, dec_title, dec_content) {
      # Escape content for JSON
      gsub(/\\/, "\\\\", dec_content)  # Backslashes first
      gsub(/"/, "\\\"", dec_content)   # Double quotes
      gsub(/\t/, "\\t", dec_content)   # Tabs
      gsub(/\r/, "", dec_content)      # Carriage returns

      # Remove leading/trailing whitespace from content
      gsub(/^[[:space:]]+/, "", dec_content)
      gsub(/[[:space:]]+$/, "", dec_content)

      # Replace actual newlines with \n for JSON
      gsub(/\n/, "\\n", dec_content)

      if (!first) printf ","
      first = 0
      printf "{\"id\":\"%s\",\"title\":\"%s\",\"content\":\"%s\"}", dec_id, dec_title, dec_content
    }

    # Match decision headers: ## D001 - Title
    /^## D[0-9]+ - / {
      # If we had a previous decision, output it
      if (id != "") {
        output_decision(id, title, content)
      }

      # Extract ID (D followed by digits)
      match($0, /D[0-9]+/)
      id = substr($0, RSTART, RLENGTH)

      # Extract title (everything after "D### - ")
      title = $0
      sub(/^## D[0-9]+ - /, "", title)

      # Escape title for JSON
      gsub(/\\/, "\\\\", title)
      gsub(/"/, "\\\"", title)
      gsub(/\t/, "\\t", title)

      content = ""
      next
    }

    # Skip other ## headers (like "## Decision Index", "## Guidelines")
    /^## / {
      # If we had a decision in progress, output it first
      if (id != "") {
        output_decision(id, title, content)
        id = ""
        content = ""
      }
      next
    }

    # Accumulate content for current decision
    id != "" {
      if (content != "") content = content "\n"
      content = content $0
    }

    END {
      # Output any remaining decision
      if (id != "") {
        output_decision(id, title, content)
      }
      printf "]"
    }
  ' "$decisions_file"
}

# =============================================================================
# Decision Matching Algorithm (v5.1.0)
# =============================================================================

# Common English stopwords to filter out during keyword extraction
# These words don't contribute meaningful signal for matching
STOPWORDS="a an the is are was were be been being have has had do does did will would could should may might must shall can this that these those it its he she they them their what which who whom where when why how and or but if then else for of to in on at by with from as into through during before after above below between under again further once here there all each few more most other some such no nor not only own same so than too very just"

# Calculate Jaccard similarity between two keyword sets
#
# Jaccard similarity = |A ∩ B| / |A ∪ B|
# Returns a value between 0.00 (no overlap) and 1.00 (identical)
#
# Processing:
# - Converts to lowercase
# - Removes punctuation
# - Splits on whitespace
# - Removes stopwords
#
# Usage:
#   similarity=$(jaccard_similarity "no test framework" "test coverage missing")
#   echo "$similarity"  # e.g., "0.33"
#
# Args:
#   $1 - First text string
#   $2 - Second text string
#
# Returns:
#   Similarity score as decimal string (e.g., "0.50")
#
jaccard_similarity() {
  local text_a="$1"
  local text_b="$2"

  # Use awk for fully portable implementation (no bash 4+ associative arrays)
  # Replace newlines with spaces first to handle multi-line content
  # Use a unique delimiter that won't appear in normal text
  local delimiter="__JACCARD_SPLIT__"

  # Preprocess: convert newlines to spaces
  local clean_a clean_b
  clean_a=$(printf '%s' "$text_a" | tr '\n\r' '  ')
  clean_b=$(printf '%s' "$text_b" | tr '\n\r' '  ')

  # Pass both texts separated by the delimiter
  printf '%s%s%s' "$clean_a" "$delimiter" "$clean_b" | awk -v stopwords="$STOPWORDS" -v delim="$delimiter" '
    BEGIN {
      # Build stopword lookup
      n = split(stopwords, arr)
      for (i = 1; i <= n; i++) {
        stop[tolower(arr[i])] = 1
      }
    }
    {
      # Split input on delimiter
      idx = index($0, delim)
      if (idx > 0) {
        text_a = substr($0, 1, idx - 1)
        text_b = substr($0, idx + length(delim))
      } else {
        text_a = $0
        text_b = ""
      }

      # Process text_a: lowercase, remove punctuation, split
      gsub(/[^a-zA-Z0-9 ]/, " ", text_a)
      text_a = tolower(text_a)
      n_a = split(text_a, words_a)

      # Build set A (unique words, excluding stopwords)
      for (i = 1; i <= n_a; i++) {
        w = words_a[i]
        if (w != "" && !(w in stop)) {
          set_a[w] = 1
        }
      }

      # Process text_b: lowercase, remove punctuation, split
      gsub(/[^a-zA-Z0-9 ]/, " ", text_b)
      text_b = tolower(text_b)
      n_b = split(text_b, words_b)

      # Build set B (unique words, excluding stopwords)
      for (i = 1; i <= n_b; i++) {
        w = words_b[i]
        if (w != "" && !(w in stop)) {
          set_b[w] = 1
        }
      }

      # Calculate intersection and union
      intersection = 0
      for (w in set_a) {
        union_set[w] = 1
        if (w in set_b) {
          intersection++
        }
      }
      for (w in set_b) {
        union_set[w] = 1
      }

      # Count union
      union_size = 0
      for (w in union_set) {
        union_size++
      }

      # Calculate and print Jaccard similarity
      if (union_size == 0) {
        printf "0.00"
      } else {
        printf "%.2f", intersection / union_size
      }
    }
  '
}

# Match a finding against all decisions in a DECISIONS.md file
#
# Parses the decisions file, extracts keywords from each decision,
# and finds the best match for the given finding text.
#
# The default threshold of 0.15 is calibrated for matching short findings
# against verbose decision content. Jaccard similarity is diluted when
# one set (decision) is much larger than the other (finding). Testing shows:
# - Related findings score ~0.20-0.30
# - Unrelated findings score ~0.00-0.05
#
# Usage:
#   result=$(match_finding_to_decisions "No test coverage" "context/DECISIONS.md")
#   echo "$result" | jq '.matched'
#
# Args:
#   $1 - Finding text to match
#   $2 - Path to DECISIONS.md file
#   $3 - Similarity threshold (optional, default 0.15)
#
# Returns:
#   JSON object:
#   - On match: {"matched":true,"decision_id":"D001","confidence":0.65}
#   - No match: {"matched":false}
#
match_finding_to_decisions() {
  local finding="$1"
  local decisions_file="$2"
  local threshold="${3:-0.15}"

  # Handle empty finding
  if [ -z "$finding" ]; then
    echo '{"matched":false}'
    return 0
  fi

  # Handle non-existent file
  if [ ! -f "$decisions_file" ]; then
    echo '{"matched":false}'
    return 0
  fi

  # Use a temp file to store decisions JSON (avoids bash interpreting escape sequences)
  local temp_file
  temp_file=$(mktemp)

  # Ensure cleanup on exit (handles errors, interrupts, etc.)
  trap "rm -f '$temp_file'" EXIT

  # Parse decisions once and store in temp file
  parse_decisions "$decisions_file" > "$temp_file"

  # Check if we have any valid decisions
  local count
  count=$(jq 'length' "$temp_file")
  if [ "$count" -eq 0 ]; then
    rm -f "$temp_file"
    trap - EXIT
    echo '{"matched":false}'
    return 0
  fi

  # Find best match
  local best_id=""
  local best_score="0.00"

  # Extract all decisions in a single jq call (MUCH faster than 3 calls per decision)
  # Format: id<TAB>title<TAB>content (truncated)
  # Using NULL as record separator to handle content with newlines
  while IFS=$'\t' read -r id title content; do
    # Combine title and content for matching (content already truncated by jq)
    local decision_text
    decision_text="$title $content"

    # Calculate similarity
    local score
    score=$(jaccard_similarity "$finding" "$decision_text")

    # Check if this is the best match (inline comparison for speed)
    if awk -v new="$score" -v old="$best_score" 'BEGIN { exit (new > old) ? 0 : 1 }'; then
      best_id="$id"
      best_score="$score"
    fi
  done < <(jq -r '.[] | [.id, .title, (.content | .[0:500] | gsub("\n"; " "))] | @tsv' "$temp_file")

  # Clean up
  rm -f "$temp_file"
  trap - EXIT

  # Check if best match exceeds threshold
  if awk -v score="$best_score" -v thresh="$threshold" 'BEGIN { exit (score >= thresh) ? 0 : 1 }' && [ -n "$best_id" ]; then
    echo "{\"matched\":true,\"decision_id\":\"$best_id\",\"confidence\":$best_score}"
  else
    echo '{"matched":false}'
  fi
}

# =============================================================================
# Network Operations with Retry and Validation
# =============================================================================

# Robust download with retry, timeout, and validation
# Fixes Issue #2 (network error handling) and Issue #8 (download validation)
#
# Args:
#   $1 - URL to download
#   $2 - Output file path
#   $3 - Max attempts (optional, default 3)
#   $4 - Timeout in seconds (optional, default 10)
#
# Returns:
#   0 on success, 1 on failure
download_with_retry() {
  local url=$1
  local output=$2
  local attempts=${3:-3}
  local timeout=${4:-10}
  local max_time=30

  for i in $(seq 1 $attempts); do
    if curl --connect-timeout $timeout --max-time $max_time -sL "$url" -o "$output" 2>/dev/null; then
      # Validate downloaded file
      if [ -f "$output" ]; then
        # Check it's not an HTML error page
        if head -1 "$output" 2>/dev/null | grep -qi "<!DOCTYPE\|<html"; then
          log_error "Downloaded file appears to be HTML (likely an error page)"
          rm -f "$output"
        else
          # Check file size is reasonable (> 0 bytes, < 10MB)
          local size=$(wc -c < "$output" 2>/dev/null || echo "0")
          if [ "$size" -lt 1 ]; then
            log_error "Downloaded file is empty"
            rm -f "$output"
          elif [ "$size" -gt 10485760 ]; then
            log_warn "Downloaded file is large ($size bytes)"
            return 0
          else
            return 0
          fi
        fi
      fi
    fi

    if [ $i -lt $attempts ]; then
      log_warn "Download attempt $i/$attempts failed, retrying in $((i * 2))s..."
      sleep $((i * 2))
    fi
  done

  show_error $EXIT_NETWORK "Failed to download after $attempts attempts" \
    "Check your internet connection" \
    "Verify the URL is correct: $url" \
    "Try again later if GitHub is experiencing issues"
  return 1
}

# =============================================================================
# Input Validation and Sanitization
# =============================================================================

# Validate user input against pattern and length constraints
# Fixes Issue #4 (command injection vulnerability)
#
# Args:
#   $1 - Input to validate
#   $2 - Regex pattern (optional, default alphanumeric + dash/underscore)
#   $3 - Max length (optional, default 50)
#
# Returns:
#   0 if valid, 1 if invalid
validate_input() {
  local input=$1
  local pattern=${2:-'^[a-zA-Z0-9_-]+$'}
  local max_length=${3:-50}

  # Check length
  if [ ${#input} -gt $max_length ]; then
    show_error $EXIT_VALIDATION "Input too long (max $max_length characters)" \
      "Provided input has ${#input} characters" \
      "Shorten the input and try again"
    return 1
  fi

  # Check pattern
  if [[ ! "$input" =~ $pattern ]]; then
    show_error $EXIT_VALIDATION "Invalid input format" \
      "Input must match pattern: $pattern" \
      "Typically: letters, numbers, dashes, and underscores only"
    return 1
  fi

  return 0
}

# Sanitize filename to prevent path traversal
sanitize_filename() {
  local filename=$1
  # Remove path components, special chars except dash/underscore/dot
  echo "$filename" | sed 's/[^a-zA-Z0-9._-]/_/g' | sed 's/^\.*//' | cut -c1-255
}

# =============================================================================
# File System Operations (Performance Optimized)
# =============================================================================

# Efficiently find markdown files with depth limit and exclusions
# Fixes Issue #1 (performance bottlenecks)
#
# Args:
#   $1 - Max depth (optional, default 3)
#   $2 - Starting directory (optional, default current)
#
# Returns:
#   List of .md files
find_md_files() {
  local max_depth=${1:-3}
  local start_dir=${2:-.}

  find "$start_dir" -maxdepth $max_depth -name "*.md" \
    -not -path "*/node_modules/*" \
    -not -path "*/.git/*" \
    -not -path "*/dist/*" \
    -not -path "*/build/*" \
    -not -path "*/.next/*" \
    -not -path "*/out/*" \
    -not -path "*/target/*" \
    -not -path "*/vendor/*" \
    2>/dev/null
}

# Efficiently find directories with exclusions
find_directories() {
  local max_depth=${1:-3}
  local start_dir=${2:-.}

  find "$start_dir" -maxdepth $max_depth -type d \
    -not -path "*/node_modules/*" \
    -not -path "*/.git/*" \
    -not -path "*/dist/*" \
    -not -path "*/build/*" \
    -not -path "*/.next/*" \
    -not -path "*/out/*" \
    2>/dev/null
}

# =============================================================================
# Cache Operations
# =============================================================================

# Get cached value if fresh enough
# Improvement #4 (caching for performance)
#
# Args:
#   $1 - Cache key
#
# Returns:
#   Cached value if exists and fresh, empty otherwise
get_cached() {
  local key=$1
  local file="$CACHE_DIR/$key"

  if [ -f "$file" ]; then
    # Calculate age (portable across macOS and Linux)
    local file_time
    if stat -f %m "$file" >/dev/null 2>&1; then
      # macOS
      file_time=$(stat -f %m "$file")
    else
      # Linux
      file_time=$(stat -c %Y "$file")
    fi

    local current_time=$(date +%s)
    local age=$((current_time - file_time))

    if [ $age -lt $CACHE_TTL ]; then
      cat "$file"
      return 0
    fi
  fi
  return 1
}

# Set cached value
set_cached() {
  local key=$1
  local value=$2
  mkdir -p "$CACHE_DIR"
  echo "$value" > "$CACHE_DIR/$key"
}

# Clear all cached values
clear_cache() {
  if [ -d "$CACHE_DIR" ]; then
    rm -rf "$CACHE_DIR"
    log_success "Cache cleared"
  fi
}

# =============================================================================
# Platform-Portable Helpers (v5.0.1)
# =============================================================================
# These helpers provide consistent behavior across macOS (BSD) and Linux (GNU).
# Use these instead of platform-specific commands to ensure portability.

# In-place sed that works on both macOS (BSD) and Linux (GNU)
#
# The `sed -i` command requires different syntax on different platforms:
#   - Linux (GNU sed):  sed -i 's/a/b/' file
#   - macOS (BSD sed):  sed -i '' 's/a/b/' file
#
# This helper detects the platform and uses the correct syntax automatically.
#
# Usage:
#   inplace_sed 's/old/new/' file.txt
#   inplace_sed 's/old/new/g' file.txt
#
# Args:
#   $1 - sed expression (e.g., 's/foo/bar/g')
#   $2 - file to modify
#
# Returns:
#   0 on success, 1 on failure
#
# Example:
#   inplace_sed 's/TODO/DONE/' tasks.md
#   inplace_sed 's|/old/path|/new/path|g' config.txt
#
inplace_sed() {
  local expression="$1"
  local file="$2"

  # Validate arguments
  if [ -z "$expression" ]; then
    log_error "inplace_sed: requires expression argument"
    return 1
  fi

  if [ -z "$file" ]; then
    log_error "inplace_sed: requires file argument"
    return 1
  fi

  if [ ! -f "$file" ]; then
    log_error "inplace_sed: file not found: $file"
    return 1
  fi

  # Detect sed variant and use appropriate syntax
  if sed --version 2>&1 | grep -q GNU; then
    # GNU sed (Linux)
    sed -i "$expression" "$file"
  else
    # BSD sed (macOS)
    sed -i '' "$expression" "$file"
  fi
}

# Compute SHA-256 hash of a file (portable across macOS/Linux)
#
# Hash commands differ by platform:
#   - Linux: sha256sum file
#   - macOS: shasum -a 256 file
#   - Fallback: openssl dgst -sha256 file
#
# This helper tries available commands in order of preference.
#
# Usage:
#   hash=$(hash_file /path/to/file)
#
# Args:
#   $1 - file to hash
#
# Returns:
#   Prints SHA-256 hash (64 hex characters) to stdout
#   Returns 1 if file not found or no hash command available
#
# Example:
#   old_hash=$(hash_file config.json)
#   # ... modify file ...
#   new_hash=$(hash_file config.json)
#   [ "$old_hash" != "$new_hash" ] && echo "File changed"
#
hash_file() {
  local file="$1"

  # Validate argument
  if [ -z "$file" ]; then
    log_error "hash_file: requires file argument"
    return 1
  fi

  if [ ! -f "$file" ]; then
    log_error "hash_file: file not found: $file"
    return 1
  fi

  # Try hash commands in order of preference
  if command -v sha256sum &>/dev/null; then
    # Linux (GNU coreutils)
    sha256sum "$file" | cut -d' ' -f1
  elif command -v shasum &>/dev/null; then
    # macOS / BSD
    shasum -a 256 "$file" | cut -d' ' -f1
  elif command -v openssl &>/dev/null; then
    # Fallback: openssl (available on most systems)
    openssl dgst -sha256 "$file" | sed 's/.*= //'
  else
    log_error "hash_file: no hash command available (need sha256sum, shasum, or openssl)"
    return 1
  fi
}

# Compare two files by hash (returns 0 if identical, 1 if different)
#
# More reliable than comparing file contents directly, especially for
# binary files or files with different line endings.
#
# Usage:
#   if files_identical file1.txt file2.txt; then
#     echo "Same content"
#   fi
#
# Args:
#   $1 - first file
#   $2 - second file
#
# Returns:
#   0 if files have identical content
#   1 if files differ or either doesn't exist
#
# Example:
#   if files_identical "context/feedback.md" "templates/feedback.template.md"; then
#     echo "Feedback file unmodified from template"
#   fi
#
files_identical() {
  local file1="$1"
  local file2="$2"

  # Both files must exist
  if [ ! -f "$file1" ] || [ ! -f "$file2" ]; then
    return 1
  fi

  local hash1 hash2
  hash1=$(hash_file "$file1") || return 1
  hash2=$(hash_file "$file2") || return 1

  [ "$hash1" = "$hash2" ]
}

# Validate JSON file syntax (portable across systems)
#
# JSON validation tools differ by availability:
#   - jq (fastest, most reliable)
#   - python3 (common on macOS/Linux)
#   - python (fallback for older systems)
#
# This helper tries available validators in order of preference.
#
# Usage:
#   if json_validate config.json; then
#     echo "Valid JSON"
#   fi
#
# Args:
#   $1 - JSON file to validate
#
# Returns:
#   0 if valid JSON
#   1 if invalid JSON or file not found
#
# Note: If no validator available, returns 0 with a warning.
#       This allows scripts to continue on minimal systems.
#
# Example:
#   if json_validate ".claude/schemas/agent-contract.json"; then
#     echo "Schema file is valid JSON"
#   else
#     echo "Schema file has JSON syntax errors"
#   fi
#
json_validate() {
  local file="$1"

  # Validate argument
  if [ -z "$file" ]; then
    log_error "json_validate: requires file argument"
    return 1
  fi

  if [ ! -f "$file" ]; then
    log_error "json_validate: file not found: $file"
    return 1
  fi

  # Try validators in order of preference
  if command -v jq &>/dev/null; then
    # jq is the gold standard for JSON validation
    jq empty "$file" 2>/dev/null
    return $?
  elif command -v python3 &>/dev/null; then
    # python3 json module
    python3 -c "import json; json.load(open('$file'))" 2>/dev/null
    return $?
  elif command -v python &>/dev/null; then
    # python 2.x fallback (rare but possible)
    python -c "import json; json.load(open('$file'))" 2>/dev/null
    return $?
  else
    # No validator available - warn and assume valid
    # This allows scripts to run on minimal systems
    log_warn "json_validate: no JSON validator available (install jq for best results)"
    return 0
  fi
}

# Count files matching a pattern in a directory (deterministic)
#
# File counting with `ls | wc -l` is fragile:
#   - Varies by platform (may include . and ..)
#   - Affected by aliases and shell options
#   - Counts directories too
#
# This helper uses `find` for deterministic, portable counting.
#
# Usage:
#   count=$(count_files /path/to/dir "*.md")
#   count=$(count_files /path/to/dir "*.json")
#
# Args:
#   $1 - directory to search
#   $2 - filename pattern (glob, optional - defaults to *)
#
# Returns:
#   Prints count to stdout (integer >= 0)
#   Returns 0 even if directory doesn't exist (count will be 0)
#
# Example:
#   agent_count=$(count_files .claude/agents "*.md")
#   if [ "$agent_count" -lt 12 ]; then
#     echo "Missing agent files (found $agent_count, expected 12)"
#   fi
#
count_files() {
  local dir="$1"
  local pattern="${2:-*}"

  # Validate directory argument
  if [ -z "$dir" ]; then
    log_error "count_files: requires directory argument"
    echo "0"
    return 1
  fi

  # If directory doesn't exist, count is 0 (not an error)
  if [ ! -d "$dir" ]; then
    echo "0"
    return 0
  fi

  # Use find for deterministic, portable counting
  # -maxdepth 1: don't recurse into subdirectories
  # -type f: only count files (not directories)
  # -name: match the pattern
  # wc -l: count lines
  # tr -d ' ': remove whitespace (macOS wc adds leading spaces)
  find "$dir" -maxdepth 1 -type f -name "$pattern" 2>/dev/null | wc -l | tr -d ' '
}

# Count decisions in DECISIONS.md
# Handles both ## D001 and ### D001 formats (v5.0.2)
#
# Args:
#   $1 - Path to DECISIONS.md (optional, defaults to context/DECISIONS.md)
#
# Returns:
#   Prints count to stdout (integer >= 0)
#
# Example:
#   count=$(count_decisions "context/DECISIONS.md")
#   echo "Found $count decisions"
#
count_decisions() {
  local file="${1:-context/DECISIONS.md}"

  # If file doesn't exist, count is 0
  if [ ! -f "$file" ]; then
    echo "0"
    return 0
  fi

  # Match both ## D001 and ### D001 formats
  # Pattern: ^##+ D[0-9] (one or more # followed by space, D, then digit)
  # Use grep -E for extended regex
  grep -E "^##+ D[0-9]" "$file" 2>/dev/null | wc -l | tr -d ' '
}

# =============================================================================
# File Safety Operations
# =============================================================================

# Confirm deletion of potentially sensitive files
# Protects gitignored files from accidental deletion
#
# Args:
#   $1 - File path to check before deletion
#
# Returns:
#   0 - Safe to delete (not gitignored or user confirmed)
#   1 - Do not delete (user declined)
#
# Usage:
#   if confirm_deletion "context/file.md"; then
#     rm -f "context/file.md"
#   else
#     echo "Deletion cancelled"
#   fi
confirm_deletion() {
  local file="$1"

  # Defensive: If no file specified, don't block
  if [ -z "$file" ]; then
    return 0
  fi

  # If file doesn't exist, nothing to protect
  if [ ! -e "$file" ]; then
    return 0
  fi

  # Check if we're in a git repository
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    # Not in git repo, no gitignore to check
    return 0
  fi

  # Check if file is gitignored (potential sensitive data)
  if git check-ignore -q "$file" 2>/dev/null; then
    # File is gitignored - require explicit confirmation
    echo ""
    echo "⚠️  WARNING: Potentially sensitive file detected"
    echo "   File: $file"
    echo "   Status: Gitignored (may contain credentials, API keys, etc.)"
    echo ""
    echo "   This file is in .gitignore and may contain sensitive data."
    echo "   Deletion is NOT recommended unless you're certain."
    echo ""
    echo -n "   To delete, type exactly: yes delete $(basename "$file")"
    echo ""
    echo -n "   > "

    read -r confirmation

    if [ "$confirmation" = "yes delete $(basename "$file")" ]; then
      echo ""
      echo "✓ Deletion confirmed"
      return 0
    else
      echo ""
      echo "✗ Deletion cancelled (input did not match)"
      return 1
    fi
  fi

  # File not gitignored, safe to delete
  return 0
}

# =============================================================================
# Logging and Output
# =============================================================================

# Verbosity level (can be overridden by commands)
VERBOSITY=${VERBOSITY:-normal}

# Log info message (respects verbosity)
log_info() {
  [ "$VERBOSITY" != "quiet" ] && echo "$1"
}

# Log verbose message
log_verbose() {
  if [ "$VERBOSITY" = "verbose" ] || [ "$VERBOSITY" = "debug" ]; then
    echo "$1"
  fi
}

# Log debug message
log_debug() {
  if [ "$VERBOSITY" = "debug" ]; then
    echo "DEBUG: $1" >&2
  fi
}

# Log success message
log_success() {
  [ "$VERBOSITY" != "quiet" ] && echo "✅ $1"
}

# Log warning message
log_warn() {
  echo "⚠️  $1" >&2
}

# Log error message
log_error() {
  echo "❌ $1" >&2
}

# Show progress indicator
# Fixes Issue #10 (no progress indicators)
#
# Args:
#   $1 - Message
#   $2 - Current step (optional)
#   $3 - Total steps (optional)
show_progress() {
  local message=$1
  local step=$2
  local total=$3

  if [ "$VERBOSITY" = "quiet" ]; then
    return
  fi

  if [ -n "$step" ] && [ -n "$total" ]; then
    echo "⏳ [$step/$total] $message..."
  else
    echo "⏳ $message..."
  fi
}

# Show detailed error with suggestions
# Fixes Issue #9 (incomplete error messages)
#
# Args:
#   $1 - Error code
#   $2 - Error message
#   $@ - Suggestions (remaining args)
show_error() {
  local error_code=$1
  local message=$2
  shift 2
  local suggestions=("$@")

  echo "" >&2
  echo "❌ Error ($error_code): $message" >&2
  echo "" >&2

  if [ ${#suggestions[@]} -gt 0 ]; then
    echo "This usually means:" >&2
    for suggestion in "${suggestions[@]}"; do
      echo "  • $suggestion" >&2
    done
    echo "" >&2
  fi
}

# =============================================================================
# Configuration and Repository Management
# =============================================================================

# Get repository URL from config or use default
# Fixes Issue #7 (hardcoded GitHub URLs)
get_repo_url() {
  local config_file="context/.context-config.json"

  if [ -f "$config_file" ]; then
    local custom_repo=$(grep -o '"repositoryUrl"[[:space:]]*:[[:space:]]*"[^"]*"' "$config_file" 2>/dev/null | cut -d'"' -f4)
    if [ -n "$custom_repo" ]; then
      echo "$custom_repo"
      return
    fi
  fi

  # Default repository URL
  echo "https://github.com/rexkirshner/ai-context-system"
}

# Get raw content URL from repository URL
get_raw_url() {
  local repo=$(get_repo_url)
  echo "${repo/github.com/raw.githubusercontent.com}/main"
}

# Get system version from VERSION file or config
get_system_version() {
  # Try VERSION file first (single source of truth in v2.3.0+)
  if [ -f "VERSION" ]; then
    cat VERSION
    return
  fi

  # Fallback to config file (for older versions)
  if [ -f "context/.context-config.json" ]; then
    grep -m 1 '"version":' context/.context-config.json 2>/dev/null | cut -d'"' -f4
    return
  fi

  echo "unknown"
}

# =============================================================================
# Auto-Update Checking
# =============================================================================

# Check for available updates (non-blocking)
# Improvement #5 (auto-update notifications)
# v4.2.1: Added ACS_UPDATING check to suppress notice during update
check_for_updates() {
  local check_file=".claude/.last-update-check"
  local check_interval=86400  # 24 hours

  # Skip if verbosity is quiet
  [ "$VERBOSITY" = "quiet" ] && return 0

  # Skip if we're already running /update-context-system (v4.2.1)
  # Prevents confusing "Run /update-context-system" message during update
  [ "$ACS_UPDATING" = "true" ] && return 0

  # Check once per day
  if [ -f "$check_file" ]; then
    local file_time
    if stat -f %m "$check_file" >/dev/null 2>&1; then
      file_time=$(stat -f %m "$check_file")
    else
      file_time=$(stat -c %Y "$check_file")
    fi

    local current_time=$(date +%s)
    local age=$((current_time - file_time))

    if [ $age -lt $check_interval ]; then
      return 0
    fi
  fi

  # Get latest version from GitHub VERSION file (timeout quickly, don't block)
  # Changed from /releases/latest API to VERSION file for accurate version tracking
  local latest=$(curl -s --connect-timeout 3 --max-time 5 \
    "https://raw.githubusercontent.com/rexkirshner/ai-context-system/main/VERSION" 2>/dev/null \
    | tr -d '[:space:]')

  local current=$(get_system_version)

  if [ -n "$latest" ] && [ "$latest" != "$current" ] && [ "$latest" != "unknown" ]; then
    echo "" >&2
    echo "💡 Update available: v$current → v$latest" >&2
    echo "   Run /update-context-system to upgrade" >&2
    echo "" >&2
  fi

  # Update check timestamp
  mkdir -p "$(dirname "$check_file")"
  touch "$check_file"
}

# =============================================================================
# Backup and Rollback
# =============================================================================

# Create timestamped backup of context and .claude
# Fixes Issue #6 (no migration rollback)
#
# Returns:
#   Backup directory path
create_backup() {
  local backup_dir=".context-backup-$(date +%Y%m%d-%H%M%S)"

  show_progress "Creating backup" 1 1
  mkdir -p "$backup_dir"

  if [ -d "context" ]; then
    cp -r context/ "$backup_dir/" 2>/dev/null || true
  fi

  if [ -d ".claude" ]; then
    cp -r .claude/ "$backup_dir/" 2>/dev/null || true
  fi

  log_success "Backup created: $backup_dir"
  log_info "To rollback: cp -r $backup_dir/context . && cp -r $backup_dir/.claude ."
  echo ""

  echo "$backup_dir"
}

# Rollback from backup directory
rollback_from_backup() {
  local backup_dir=$1

  if [ ! -d "$backup_dir" ]; then
    show_error $EXIT_NOT_FOUND "Backup directory not found: $backup_dir"
    return 1
  fi

  show_progress "Rolling back from backup" 1 1

  if [ -d "$backup_dir/context" ]; then
    rm -rf context
    cp -r "$backup_dir/context" .
  fi

  if [ -d "$backup_dir/.claude" ]; then
    rm -rf .claude
    cp -r "$backup_dir/.claude" .
  fi

  log_success "Rolled back to: $backup_dir"
  return 0
}

# =============================================================================
# Preflight Checks
# =============================================================================

# Run preflight checks before command execution
# Validates environment is ready for AI Context System operations
#
# Args:
#   $1 - Check level: "minimal" | "standard" | "full" (default: standard)
#
# Returns:
#   0 if all checks pass, 1 if any fail
#
# Usage:
#   preflight_check "minimal"   # Just check context dir exists
#   preflight_check "standard"  # Context dir + required files
#   preflight_check "full"      # All checks including dependencies
preflight_check() {
  local level="${1:-standard}"
  local failed=0

  log_debug "Running preflight check (level: $level)"

  # Minimal: Check we're in a project with context
  if ! find_context_dir >/dev/null 2>&1; then
    show_error $EXIT_NOT_FOUND "Context directory not found" \
      "Run from project root directory" \
      "Initialize context with /init-context if this is a new project" \
      "Check that context/ folder exists"
    return 1
  fi

  if [ "$level" = "minimal" ]; then
    return 0
  fi

  # Standard: Check required files exist
  local context_dir=$(find_context_dir)
  local required_files=(
    "$context_dir/CONTEXT.md"
    "$context_dir/STATUS.md"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      log_warn "Missing required file: $file"
      failed=$((failed + 1))
    fi
  done

  if [ $failed -gt 0 ]; then
    show_error $EXIT_VALIDATION "Context system incomplete ($failed missing files)" \
      "Run /init-context to create missing files" \
      "Or run /validate-context for detailed analysis"
    return 1
  fi

  if [ "$level" = "standard" ]; then
    return 0
  fi

  # Full: Check dependencies
  if ! check_dependencies "curl" "git"; then
    return 1
  fi

  # Full: Check CLAUDE.md at root
  if [ ! -f "CLAUDE.md" ] && [ ! -f ".claude/CLAUDE.md" ]; then
    log_warn "CLAUDE.md not found at project root"
    log_info "  Run /init-context or move context/claude.md to ./CLAUDE.md"
  fi

  return 0
}

# =============================================================================
# Dependency Checks
# =============================================================================

# Check if required dependencies are available
# Provides helpful installation instructions if missing
#
# Args:
#   $@ - List of commands to check (e.g., "curl" "git" "jq")
#
# Returns:
#   0 if all dependencies present, 1 if any missing
#
# Usage:
#   check_dependencies "curl" "git"
#   check_dependencies "jq"  # Optional, warns but doesn't fail
check_dependencies() {
  local missing=()
  local optional=("jq")  # These warn but don't fail

  for cmd in "$@"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing+=("$cmd")
    fi
  done

  if [ ${#missing[@]} -eq 0 ]; then
    return 0
  fi

  # Check if all missing are optional
  local critical=0
  for cmd in "${missing[@]}"; do
    local is_optional=0
    for opt in "${optional[@]}"; do
      if [ "$cmd" = "$opt" ]; then
        is_optional=1
        break
      fi
    done

    if [ $is_optional -eq 1 ]; then
      log_warn "Optional dependency missing: $cmd"
      show_install_hint "$cmd"
    else
      log_error "Required dependency missing: $cmd"
      show_install_hint "$cmd"
      critical=$((critical + 1))
    fi
  done

  if [ $critical -gt 0 ]; then
    return 1
  fi

  return 0
}

# Show installation hints for common dependencies
show_install_hint() {
  local cmd="$1"

  case "$cmd" in
    jq)
      echo "  Install jq for JSON validation:" >&2
      echo "    macOS:  brew install jq" >&2
      echo "    Ubuntu: sudo apt-get install jq" >&2
      echo "    Fedora: sudo dnf install jq" >&2
      ;;
    curl)
      echo "  Install curl for network operations:" >&2
      echo "    macOS:  brew install curl" >&2
      echo "    Ubuntu: sudo apt-get install curl" >&2
      ;;
    git)
      echo "  Install git for version control:" >&2
      echo "    macOS:  brew install git" >&2
      echo "    Ubuntu: sudo apt-get install git" >&2
      ;;
    *)
      echo "  Install $cmd using your package manager" >&2
      ;;
  esac
  echo "" >&2
}

# =============================================================================
# Validation Helpers
# =============================================================================

# Validate that required files exist
validate_context_files() {
  local missing=0

  local required_files=(
    "context/CONTEXT.md"
    "context/STATUS.md"
    "context/SESSIONS.md"
    "context/DECISIONS.md"
    "context/.context-config.json"
  )

  for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
      log_error "Missing required file: $file"
      missing=$((missing + 1))
    fi
  done

  if [ $missing -gt 0 ]; then
    show_error $EXIT_VALIDATION "Context system incomplete ($missing missing files)" \
      "Run /init-context to create missing files" \
      "Or run /validate-context for detailed analysis"
    return 1
  fi

  return 0
}

# Check if JSON file is valid
validate_json() {
  local file=$1

  if [ ! -f "$file" ]; then
    return 1
  fi

  # Try to parse with python if available
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "import json; json.load(open('$file'))" 2>/dev/null
    return $?
  elif command -v python >/dev/null 2>&1; then
    python -c "import json; json.load(open('$file'))" 2>/dev/null
    return $?
  fi

  # Fallback: basic syntax check
  grep -q "^{" "$file" && grep -q "}$" "$file"
  return $?
}

# =============================================================================
# Git Helpers
# =============================================================================

# Check if working directory is clean
git_is_clean() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    return 1  # Not a git repo
  fi

  git diff --quiet && git diff --cached --quiet
  return $?
}

# Get current git branch name
git_current_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown"
}

# =============================================================================
# Session Management Functions
# =============================================================================

# Get the next session number (MAX + 1, not COUNT + 1)
#
# IMPORTANT: This finds the MAXIMUM existing session number, not the count.
# This correctly handles gaps from archiving sessions.
#
# Example: If sessions 1-30 were archived and sessions 40, 41, 44 remain,
# this returns 45 (max+1), NOT 4 (count+1).
#
# Supports both session header formats:
#   - Pipe format: "## Session N | DATE | TITLE"
#   - Dash format: "## Session N - DATE"
#
# Usage:
#   next=$(get_next_session_number)
#   next=$(get_next_session_number "context")
#
# Args:
#   $1 - context directory (optional, default: "context")
#
# Returns:
#   Prints next session number to stdout (MAX existing + 1)
#
get_next_session_number() {
  local context_dir="${1:-context}"
  local sessions_file="$context_dir/SESSIONS.md"

  # No file = start at 1
  if [ ! -f "$sessions_file" ]; then
    echo "1"
    return 0
  fi

  # Find the MAXIMUM session number (not COUNT)
  # 1. Stop before "## Example" sections (template content)
  # 2. Match "## Session N" where N is a number
  # 3. Exclude template references
  # 4. Extract just the number
  # 5. Sort numerically and take the largest
  local max_session
  max_session=$(
    sed -n '1,/^## Example/p' "$sessions_file" 2>/dev/null | \
    grep -E "^## Session [0-9]+" | \
    grep -v -i "Template" | \
    sed -E 's/^## Session ([0-9]+).*/\1/' | \
    sort -n | \
    tail -1
  )

  # Default to 0 if no sessions found or invalid result
  if [ -z "$max_session" ] || ! [[ "$max_session" =~ ^[0-9]+$ ]]; then
    max_session=0
  fi

  echo $((max_session + 1))
}

# Get the highest existing session number
#
# Returns the maximum session number, not a count. After archiving sessions
# 1-30, if sessions 40, 41, 44 remain, returns 44 (not 3).
#
# Usage:
#   max=$(get_max_session_number)
#   max=$(get_max_session_number "context")
#
# Returns:
#   The highest session number that exists (0 if none)
#
get_max_session_number() {
  local context_dir="${1:-context}"
  local next=$(get_next_session_number "$context_dir")
  echo $((next - 1))
}

# DEPRECATED: Use get_max_session_number() instead
#
# This function name is misleading - it returns the max session number,
# not a count of sessions. Kept for backward compatibility.
# Will be removed in v6.0.0.
#
get_current_session_count() {
  local context_dir="${1:-context}"
  log_warn "get_current_session_count() is deprecated, use get_max_session_number()"
  get_max_session_number "$context_dir"
}

# =============================================================================
# Auto-Timestamp Functions (v3.7.0)
# =============================================================================

# Update "Last Updated" date in a markdown file
# Supports the pattern: **Last Updated:** [anything]
# Cross-platform compatible (macOS + Linux)
#
# Args:
#   $1 - File path to update
#
# Returns:
#   0 on success (even if no timestamp found - that's OK)
#   1 if file doesn't exist
#
# Usage:
#   update_last_modified "context/STATUS.md"
update_last_modified() {
  local file="$1"
  local today=$(date +%Y-%m-%d)

  # Check if file exists
  if [ ! -f "$file" ]; then
    log_debug "update_last_modified: File not found: $file"
    return 1
  fi

  # Check if file has "Last Updated" pattern
  if grep -q '\*\*Last Updated:\*\*' "$file"; then
    # Only replace the date portion (YYYY-MM-DD), preserve any suffix like "(Session N)"
    # Uses inplace_sed helper for cross-platform compatibility
    inplace_sed "s/\\(\\*\\*Last Updated:\\*\\* \\)[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}/\\1$today/" "$file"
    log_debug "update_last_modified: Updated timestamp in $file to $today"
    return 0
  fi

  # No timestamp pattern found - that's OK, don't add one
  log_debug "update_last_modified: No timestamp pattern found in $file (skipping)"
  return 0
}

# =============================================================================
# Audit System Functions (v4.0.0)
# =============================================================================

# Get the next audit number for a given audit type
# Scans existing audit files and returns the next number (01, 02, etc.)
#
# Args:
#   $1 - Audit type (e.g., "security", "performance", "database")
#   $2 - Directory to scan (optional, default: "docs/audits")
#
# Returns:
#   Two-digit number string (e.g., "01", "02", "15")
#
# Usage:
#   num=$(get_next_audit_number "security")
#   # Creates: security-audit-01.md, security-audit-02.md, etc.
get_next_audit_number() {
  local audit_type="$1"
  local directory="${2:-docs/audits}"
  local max=0

  # Ensure directory exists
  if [ ! -d "$directory" ]; then
    printf "%02d" 1
    return 0
  fi

  # Find highest existing number for this audit type
  # Use find to avoid glob expansion issues when no files match
  while IFS= read -r file; do
    if [ -n "$file" ] && [ -f "$file" ]; then
      # Extract number from filename (e.g., security-audit-03.md -> 03 -> 3)
      local num=$(echo "$file" | grep -oE '[0-9]+\.md$' | grep -oE '[0-9]+')
      if [ -n "$num" ]; then
        # Remove leading zeros for comparison
        num=$((10#$num))
        [ "$num" -gt "$max" ] && max="$num"
      fi
    fi
  done < <(find "$directory" -maxdepth 1 -name "${audit_type}-audit-*.md" -type f 2>/dev/null)

  # Return next number with zero-padding
  printf "%02d" $((max + 1))
}

# Update the audit INDEX.md with a new entry
# Adds a row to the "Recent Audits" table
#
# Args:
#   $1 - Directory containing INDEX.md (e.g., "docs/audits")
#   $2 - Audit type (e.g., "Security", "Performance")
#   $3 - Audit filename (e.g., "security-audit-01.md")
#   $4 - Grade (e.g., "B+", "A-")
#   $5 - Key findings summary (e.g., "2 high, 5 medium issues")
#
# Returns:
#   0 on success, 1 on failure
#
# Usage:
#   update_audit_index "docs/audits" "Security" "security-audit-01.md" "B+" "2 high, 5 medium"
update_audit_index() {
  local directory="$1"
  local audit_type="$2"
  local filename="$3"
  local grade="$4"
  local findings="$5"
  local index_file="$directory/INDEX.md"
  local today=$(date +%Y-%m-%d)

  # Create INDEX.md from template if it doesn't exist
  if [ ! -f "$index_file" ]; then
    if [ -f "templates/audits-index.template.md" ]; then
      mkdir -p "$directory"
      cp "templates/audits-index.template.md" "$index_file"
      log_info "Created INDEX.md from template"
    else
      log_error "INDEX.md not found and template not available"
      return 1
    fi
  fi

  # Create the new row
  local new_row="| $today | $audit_type | [$filename](./$filename) | $grade | $findings |"

  # Insert new row before the comment marker using awk (more portable than sed for this)
  local marker="<!-- New audit entries will be added above this line -->"
  if grep -q "$marker" "$index_file"; then
    # Use awk for reliable cross-platform insertion
    awk -v row="$new_row" -v marker="$marker" '
      $0 ~ marker { print row }
      { print }
    ' "$index_file" > "$index_file.tmp" && mv "$index_file.tmp" "$index_file"
    log_success "Added audit entry to INDEX.md"
    return 0
  else
    log_warn "Could not find insertion point in INDEX.md"
    return 1
  fi
}

# =============================================================================
# Platform Detection Functions (v4.0.0)
# =============================================================================

# Detect the database platform/ORM in use
# Checks for common database tools in the project
#
# Returns:
#   String: "prisma" | "drizzle" | "typeorm" | "sequelize" | "knex" | "raw" | "unknown"
#
# Usage:
#   platform=$(detect_database_platform)
detect_database_platform() {
  # Check for Prisma
  if [ -f "prisma/schema.prisma" ]; then
    echo "prisma"
    return 0
  fi

  # Check package.json for various ORMs
  if [ -f "package.json" ]; then
    if grep -q '"drizzle-orm"' package.json 2>/dev/null; then
      echo "drizzle"
      return 0
    fi
    if grep -q '"typeorm"' package.json 2>/dev/null; then
      echo "typeorm"
      return 0
    fi
    if grep -q '"sequelize"' package.json 2>/dev/null; then
      echo "sequelize"
      return 0
    fi
    if grep -q '"knex"' package.json 2>/dev/null; then
      echo "knex"
      return 0
    fi
    # Check for raw database drivers
    if grep -qE '"pg"|"mysql2"|"sqlite3"|"better-sqlite3"' package.json 2>/dev/null; then
      echo "raw"
      return 0
    fi
  fi

  echo "unknown"
}

# Detect the hosting/deployment platform
# Checks for platform-specific configuration files and dependencies
#
# Returns:
#   String: "vercel" | "aws" | "cloudflare" | "netlify" | "railway" | "fly" | "unknown"
#
# Usage:
#   platform=$(detect_hosting_platform)
detect_hosting_platform() {
  # Check for Vercel
  if [ -f "vercel.json" ] || [ -d ".vercel" ]; then
    echo "vercel"
    return 0
  fi
  if [ -f "package.json" ] && grep -q '"@vercel/' package.json 2>/dev/null; then
    echo "vercel"
    return 0
  fi

  # Check for AWS
  if [ -f "serverless.yml" ] || [ -f "serverless.yaml" ] || [ -f "sam.yaml" ] || [ -f "template.yaml" ]; then
    echo "aws"
    return 0
  fi
  if [ -d ".aws" ] || [ -f "cdk.json" ]; then
    echo "aws"
    return 0
  fi

  # Check for Cloudflare
  if [ -f "wrangler.toml" ] || [ -f "wrangler.json" ]; then
    echo "cloudflare"
    return 0
  fi

  # Check for Netlify
  if [ -f "netlify.toml" ] || [ -d ".netlify" ]; then
    echo "netlify"
    return 0
  fi

  # Check for Railway
  if [ -f "railway.json" ] || [ -f "railway.toml" ]; then
    echo "railway"
    return 0
  fi

  # Check for Fly.io
  if [ -f "fly.toml" ]; then
    echo "fly"
    return 0
  fi

  echo "unknown"
}

# Detect the web framework in use
# Checks for common JavaScript/TypeScript frameworks
#
# Returns:
#   String: "nextjs" | "remix" | "astro" | "nuxt" | "sveltekit" | "vite" | "express" | "unknown"
#
# Usage:
#   framework=$(detect_framework)
detect_framework() {
  if [ ! -f "package.json" ]; then
    echo "unknown"
    return 0
  fi

  # Check for Next.js
  if grep -q '"next"' package.json 2>/dev/null; then
    echo "nextjs"
    return 0
  fi

  # Check for Remix
  if grep -q '"@remix-run/' package.json 2>/dev/null; then
    echo "remix"
    return 0
  fi

  # Check for Astro
  if grep -q '"astro"' package.json 2>/dev/null; then
    echo "astro"
    return 0
  fi

  # Check for Nuxt
  if grep -q '"nuxt"' package.json 2>/dev/null; then
    echo "nuxt"
    return 0
  fi

  # Check for SvelteKit
  if grep -q '"@sveltejs/kit"' package.json 2>/dev/null; then
    echo "sveltekit"
    return 0
  fi

  # Check for Vite (standalone, not as part of another framework)
  if grep -q '"vite"' package.json 2>/dev/null && \
     ! grep -qE '"astro"|"nuxt"|"@sveltejs/kit"' package.json 2>/dev/null; then
    echo "vite"
    return 0
  fi

  # Check for Express
  if grep -q '"express"' package.json 2>/dev/null; then
    echo "express"
    return 0
  fi

  echo "unknown"
}

# =============================================================================
# Initialization
# =============================================================================

# =============================================================================
# Documentation Currency Functions (v3.4.0)
# =============================================================================

# Calculate days since a given date
# Usage: days_since_date "2025-11-10"
# Returns: Number of days since the date (or -1 if invalid date)
days_since_date() {
  local date_string="$1"

  # Handle empty input
  if [ -z "$date_string" ]; then
    echo "-1"
    return 1
  fi

  # Convert date string to epoch seconds (platform-independent approach)
  local date_epoch
  if date -j -f "%Y-%m-%d" "$date_string" "+%s" >/dev/null 2>&1; then
    # BSD/macOS date command
    date_epoch=$(date -j -f "%Y-%m-%d" "$date_string" "+%s" 2>/dev/null)
  elif date -d "$date_string" "+%s" >/dev/null 2>&1; then
    # GNU date command (Linux)
    date_epoch=$(date -d "$date_string" "+%s" 2>/dev/null)
  else
    # Date parsing failed
    echo "-1"
    return 1
  fi

  # Get current time in epoch seconds
  local now_epoch=$(date "+%s")

  # Calculate difference in days
  local diff_seconds=$((now_epoch - date_epoch))
  local days=$((diff_seconds / 86400))

  echo "$days"
  return 0
}

# Calculate days since a file was last modified
# Usage: days_since_file_modified "/path/to/file.md"
# Returns: Number of days since last modification (or -1 if file doesn't exist)
days_since_file_modified() {
  local file_path="$1"

  # Check if file exists
  if [ ! -f "$file_path" ]; then
    echo "-1"
    return 1
  fi

  # Get file modification time in epoch seconds (platform-independent)
  local file_epoch
  if stat -f%m "$file_path" >/dev/null 2>&1; then
    # BSD/macOS stat command
    file_epoch=$(stat -f%m "$file_path" 2>/dev/null)
  elif stat -c%Y "$file_path" >/dev/null 2>&1; then
    # GNU stat command (Linux)
    file_epoch=$(stat -c%Y "$file_path" 2>/dev/null)
  else
    # stat failed
    echo "-1"
    return 1
  fi

  # Get current time in epoch seconds
  local now_epoch=$(date "+%s")

  # Calculate difference in days
  local diff_seconds=$((now_epoch - file_epoch))
  local days=$((diff_seconds / 86400))

  echo "$days"
  return 0
}

# =============================================================================
# Documentation Health Check (v4.1.0)
# =============================================================================

# Check health of project documentation
# Compares CLAUDE.md against CONTEXT.md for staleness and drift
#
# Usage:
#   check_documentation_health [context_dir]
#
# Returns (via global variables):
#   DOC_HEALTH_STATUS    - "healthy" | "stale" | "drift" | "incomplete"
#   DOC_HEALTH_DETAILS   - Array of issue descriptions
#   DOC_HEALTH_WARNINGS  - Count of warnings found
#
# Exit codes:
#   0 - Check completed (regardless of health status)
#   1 - Could not run check (missing files, etc.)
check_documentation_health() {
  local context_dir="${1:-context}"
  local repo_root
  repo_root=$(get_repo_root)

  # Initialize return variables
  DOC_HEALTH_STATUS="healthy"
  DOC_HEALTH_DETAILS=()
  DOC_HEALTH_WARNINGS=0

  local claude_md="$repo_root/CLAUDE.md"
  local context_md="$repo_root/$context_dir/CONTEXT.md"

  # Check 1: Files exist
  if [ ! -f "$claude_md" ]; then
    DOC_HEALTH_STATUS="incomplete"
    DOC_HEALTH_DETAILS+=("CLAUDE.md not found at project root")
    DOC_HEALTH_WARNINGS=$((DOC_HEALTH_WARNINGS + 1))
  fi

  if [ ! -f "$context_md" ]; then
    DOC_HEALTH_STATUS="incomplete"
    DOC_HEALTH_DETAILS+=("CONTEXT.md not found in $context_dir/")
    DOC_HEALTH_WARNINGS=$((DOC_HEALTH_WARNINGS + 1))
    return 0  # Can't do further checks
  fi

  # Check 2: Template placeholders in CONTEXT.md
  local placeholders
  placeholders=$(grep -c '\[FILL:' "$context_md" 2>/dev/null | tr -d '\n' || echo "0")
  placeholders=${placeholders:-0}
  if [ "$placeholders" -gt 0 ]; then
    DOC_HEALTH_DETAILS+=("CONTEXT.md has $placeholders unfilled [FILL:...] placeholders")
    DOC_HEALTH_WARNINGS=$((DOC_HEALTH_WARNINGS + 1))
    [ "$DOC_HEALTH_STATUS" = "healthy" ] && DOC_HEALTH_STATUS="incomplete"
  fi

  # Check 3: Staleness comparison (if both files exist)
  if [ -f "$claude_md" ] && [ -f "$context_md" ]; then
    local claude_age context_age
    claude_age=$(days_since_file_modified "$claude_md")
    context_age=$(days_since_file_modified "$context_md")

    if [ "$claude_age" -ge 0 ] && [ "$context_age" -ge 0 ]; then
      local age_diff=$((claude_age - context_age))

      if [ "$age_diff" -gt 30 ]; then
        DOC_HEALTH_DETAILS+=("CLAUDE.md is ${claude_age} days old (CONTEXT.md: ${context_age} days) - significantly stale")
        DOC_HEALTH_WARNINGS=$((DOC_HEALTH_WARNINGS + 1))
        DOC_HEALTH_STATUS="stale"
      elif [ "$age_diff" -gt 14 ]; then
        DOC_HEALTH_DETAILS+=("CLAUDE.md is ${claude_age} days old (CONTEXT.md: ${context_age} days) - consider updating")
        DOC_HEALTH_WARNINGS=$((DOC_HEALTH_WARNINGS + 1))
        [ "$DOC_HEALTH_STATUS" = "healthy" ] && DOC_HEALTH_STATUS="stale"
      fi
    fi
  fi

  # Check 4: Tech stack drift (if both files exist)
  if [ -f "$claude_md" ] && [ -f "$context_md" ]; then
    # Extract tech keywords from CONTEXT.md
    local context_tech
    context_tech=$(grep -oE '\b(React|Next\.js|Vue|Svelte|Angular|Node|Express|Prisma|Drizzle|TypeORM|PostgreSQL|MySQL|MongoDB|Redis|Docker|Kubernetes|Vercel|AWS|Cloudflare|Supabase|Firebase)\b' "$context_md" 2>/dev/null | sort -u | tr '\n' ' ')

    # Check if each tech is mentioned in CLAUDE.md
    local missing_tech=()
    for tech in $context_tech; do
      if ! grep -qi "$tech" "$claude_md" 2>/dev/null; then
        missing_tech+=("$tech")
      fi
    done

    # Only flag if 2+ technologies missing (reduce false positives)
    if [ ${#missing_tech[@]} -ge 2 ]; then
      DOC_HEALTH_DETAILS+=("Tech drift: CONTEXT.md mentions ${missing_tech[*]} - not in CLAUDE.md")
      DOC_HEALTH_WARNINGS=$((DOC_HEALTH_WARNINGS + 1))
      [ "$DOC_HEALTH_STATUS" = "healthy" ] && DOC_HEALTH_STATUS="drift"
    fi
  fi

  return 0
}

# Format documentation health check results for display
# Usage: format_documentation_health
format_documentation_health() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Documentation Health Check"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  if [ "$DOC_HEALTH_WARNINGS" -eq 0 ]; then
    local claude_md_path="$(get_repo_root)/CLAUDE.md"
    if [ -f "$claude_md_path" ]; then
      local claude_age
      claude_age=$(days_since_file_modified "$claude_md_path")
      echo "  CLAUDE.md current (${claude_age} days old)"
    else
      echo "  CLAUDE.md not found"
    fi
    echo "  CONTEXT.md fully configured"
  else
    for detail in "${DOC_HEALTH_DETAILS[@]}"; do
      echo "  - $detail"
    done
    echo ""
    echo "Recommendations:"

    case "$DOC_HEALTH_STATUS" in
      "incomplete")
        echo "  - Run /init-context to create missing files"
        echo "  - Fill in [FILL:...] placeholders with project details"
        ;;
      "stale")
        echo "  - Review CLAUDE.md and update with current project info"
        echo "  - Compare with CONTEXT.md for accuracy"
        ;;
      "drift")
        echo "  - Update CLAUDE.md tech stack section"
        echo "  - Ensure CLAUDE.md reflects current architecture"
        ;;
    esac
  fi
  echo ""
}

# =============================================================================
# Context Completeness Detection (v4.1.1)
# =============================================================================

# Count unfilled [FILL:...] placeholders in a file
# Usage: count=$(count_unfilled_placeholders "context/CONTEXT.md")
# Returns: Number of unfilled placeholders (0 if file doesn't exist)
count_unfilled_placeholders() {
  local file="$1"

  if [ ! -f "$file" ]; then
    echo "0"
    return 0
  fi

  local count
  count=$(grep -c '\[FILL:' "$file" 2>/dev/null | tr -d '\n' || echo "0")
  count=${count:-0}
  echo "$count"
}

# =============================================================================
# Project Auto-Detection (v4.1.1)
# =============================================================================

# Detect project name from various sources
# Priority: package.json > Cargo.toml > pyproject.toml > directory name
# Usage: name=$(detect_project_name)
detect_project_name() {
  local name=""

  # Try package.json
  if [ -f "package.json" ]; then
    name=$(grep -m1 '"name"' package.json 2>/dev/null | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
  fi

  # Try Cargo.toml
  if [ -z "$name" ] && [ -f "Cargo.toml" ]; then
    name=$(grep -m1 '^name' Cargo.toml 2>/dev/null | sed 's/name[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/')
  fi

  # Try pyproject.toml
  if [ -z "$name" ] && [ -f "pyproject.toml" ]; then
    name=$(grep -m1 'name' pyproject.toml 2>/dev/null | sed 's/name[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/')
  fi

  # Fallback to directory name
  if [ -z "$name" ]; then
    name=$(basename "$(pwd)")
  fi

  echo "$name"
}

# Detect project description
# Priority: package.json > README first line
# Usage: desc=$(detect_project_description)
detect_project_description() {
  local desc=""

  # Try package.json
  if [ -f "package.json" ]; then
    desc=$(grep -m1 '"description"' package.json 2>/dev/null | sed 's/.*"description"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
  fi

  # Try README first meaningful line
  if [ -z "$desc" ]; then
    for readme in README.md README.rst README.txt README; do
      if [ -f "$readme" ]; then
        # Get first non-empty, non-header line
        desc=$(grep -v '^#\|^$\|^==\|^--' "$readme" 2>/dev/null | head -1 | cut -c1-200)
        [ -n "$desc" ] && break
      fi
    done
  fi

  echo "$desc"
}

# Detect repository URL from git remote
# Usage: url=$(detect_repo_url)
detect_repo_url() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo ""
    return 0
  fi

  local url
  url=$(git remote get-url origin 2>/dev/null || echo "")

  # Convert SSH URL to HTTPS for display
  if [[ "$url" == git@* ]]; then
    url=$(echo "$url" | sed 's/git@\([^:]*\):/https:\/\/\1\//' | sed 's/\.git$//')
  fi

  echo "$url"
}

# Detect tech stack from project files
# Returns: Comma-separated list of detected technologies
# Usage: stack=$(detect_tech_stack)
detect_tech_stack() {
  local stack=()

  # Check for JavaScript/TypeScript ecosystem
  if [ -f "package.json" ]; then
    # Check for specific frameworks
    if grep -q '"next"' package.json 2>/dev/null; then
      stack+=("Next.js")
    elif grep -q '"@remix-run' package.json 2>/dev/null; then
      stack+=("Remix")
    elif grep -q '"astro"' package.json 2>/dev/null; then
      stack+=("Astro")
    elif grep -q '"nuxt"' package.json 2>/dev/null; then
      stack+=("Nuxt")
    elif grep -q '"@sveltejs/kit"' package.json 2>/dev/null; then
      stack+=("SvelteKit")
    elif grep -q '"react"' package.json 2>/dev/null; then
      stack+=("React")
    elif grep -q '"vue"' package.json 2>/dev/null; then
      stack+=("Vue")
    elif grep -q '"express"' package.json 2>/dev/null; then
      stack+=("Express")
    fi

    # Check for TypeScript
    if grep -q '"typescript"' package.json 2>/dev/null || [ -f "tsconfig.json" ]; then
      stack+=("TypeScript")
    else
      stack+=("JavaScript")
    fi

    # Check for database/ORM
    if grep -q '"prisma"' package.json 2>/dev/null || [ -d "prisma" ]; then
      stack+=("Prisma")
    elif grep -q '"drizzle-orm"' package.json 2>/dev/null; then
      stack+=("Drizzle")
    fi

    # Check for database
    if grep -q '"pg"\|"postgres"' package.json 2>/dev/null; then
      stack+=("PostgreSQL")
    elif grep -q '"mysql' package.json 2>/dev/null; then
      stack+=("MySQL")
    elif grep -q '"mongodb"' package.json 2>/dev/null; then
      stack+=("MongoDB")
    fi
  fi

  # Check for Python
  if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
    stack+=("Python")
    if grep -q 'django' requirements.txt pyproject.toml 2>/dev/null; then
      stack+=("Django")
    elif grep -q 'flask' requirements.txt pyproject.toml 2>/dev/null; then
      stack+=("Flask")
    elif grep -q 'fastapi' requirements.txt pyproject.toml 2>/dev/null; then
      stack+=("FastAPI")
    fi
  fi

  # Check for Rust
  if [ -f "Cargo.toml" ]; then
    stack+=("Rust")
  fi

  # Check for Go
  if [ -f "go.mod" ]; then
    stack+=("Go")
  fi

  # Check for hosting platforms
  if [ -f "vercel.json" ] || [ -d ".vercel" ]; then
    stack+=("Vercel")
  elif [ -f "netlify.toml" ]; then
    stack+=("Netlify")
  elif [ -f "fly.toml" ]; then
    stack+=("Fly.io")
  elif [ -f "railway.json" ]; then
    stack+=("Railway")
  fi

  # Return comma-separated list
  local IFS=','
  echo "${stack[*]}"
}

# Detect project type
# Returns: web-app | api | cli | library | unknown
# Usage: type=$(detect_project_type)
detect_project_type() {
  # Check for web app indicators
  if [ -f "package.json" ]; then
    if grep -qE '"next"|"remix"|"astro"|"nuxt"|"svelte"' package.json 2>/dev/null; then
      echo "web-app"
      return 0
    fi

    # Check for CLI
    if grep -q '"bin"' package.json 2>/dev/null; then
      echo "cli"
      return 0
    fi

    # Check for library (no bin, has main/module)
    if grep -qE '"main"|"module"|"exports"' package.json 2>/dev/null && \
       ! grep -q '"bin"' package.json 2>/dev/null; then
      echo "library"
      return 0
    fi

    # Express/Fastify = API
    if grep -qE '"express"|"fastify"|"hapi"|"koa"' package.json 2>/dev/null; then
      echo "api"
      return 0
    fi
  fi

  # Python web frameworks
  if grep -qE 'django|flask|fastapi' requirements.txt pyproject.toml 2>/dev/null; then
    echo "web-app"
    return 0
  fi

  # CLI indicators
  if [ -f "setup.py" ] && grep -q 'entry_points\|console_scripts' setup.py 2>/dev/null; then
    echo "cli"
    return 0
  fi

  echo "unknown"
}

# =============================================================================
# Finding Deduplication Utilities (v5.1.0)
# =============================================================================

# Deduplicate findings by location (file:line)
#
# Merges findings that occur at the same file and line number. When multiple
# findings are at the same location, they are merged with:
# - ID: First finding's ID with "-MERGED" suffix
# - Severity: Highest severity among merged findings
# - detectedBy: Array of detector prefixes (extracted from IDs)
# - mergedFrom: Array of original finding IDs
#
# Usage:
#   cat findings.json | dedupe_by_location
#   dedupe_by_location < findings.json
#
# Input: JSON array of findings (stdin)
# Output: JSON array of deduplicated findings
#
# Example:
#   cat raw.json | dedupe_by_location | jq 'length'
#
dedupe_by_location() {
  jq '
    # Create a grouping key that handles missing location gracefully
    # Findings without location get unique keys (their ID) so they are not merged
    def location_key:
      if .location.file and .location.line then
        .location.file + ":" + (.location.line | tostring)
      else
        # Use finding ID as key for findings without location - prevents incorrect merging
        "NO_LOCATION:" + .id
      end;

    # Group findings by location key
    group_by(location_key)
    | map(
      if length == 1 then
        # Single finding - return as-is
        .[0]
      else
        # Multiple findings at same location - merge them
        .[0] + {
          "id": (.[0].id + "-MERGED"),
          "severity": (
            [.[] | .severity // "low" | ascii_downcase] | map(
              if . == "critical" then 4
              elif . == "high" then 3
              elif . == "medium" then 2
              elif . == "info" then 0
              else 1 end
            ) | max |
            if . == 4 then "critical"
            elif . == 3 then "high"
            elif . == 2 then "medium"
            elif . == 0 then "info"
            else "low" end
          ),
          "detectedBy": ([.[] | .id | split("-")[0]] | unique),
          "mergedFrom": ([.[] | .id])
        }
      end
    )
  '
}

# Group similar findings by pattern
#
# Groups findings that have similar titles (ignoring the specific file/location
# portion). When 3+ similar findings exist, creates a GROUP-* entry that
# summarizes them.
#
# The grouping key is: category + normalized title (with " in <file>" removed)
#
# Usage:
#   cat findings.json | group_similar_findings
#   cat findings.json | group_similar_findings 5   # threshold of 5
#
# Args:
#   $1 - Minimum group size threshold (optional, default 3)
#
# Input: JSON array of findings (stdin)
# Output: JSON array with GROUP entries added
#
# Example:
#   cat raw.json | group_similar_findings 3 | jq '[.[] | select(.type == "group")]'
#
group_similar_findings() {
  local min_group_size="${1:-3}"

  jq --argjson min "$min_group_size" '
    # Create grouping key: category + normalized title (with null safety)
    def grouping_key:
      ((.category // "uncategorized") + ":" + ((.title // "") | gsub(" in .*$"; "")));

    # Group by the key
    group_by(grouping_key)
    | to_entries
    | map(
      .key as $group_index |
      .value |
      if length >= $min then
        # Add a GROUP entry for patterns with enough matches
        # Use group index for unique ID to avoid collisions
        (.[0].category // "uncategorized") as $cat |
        ($cat | ascii_upcase) as $cat_upper |
        . + [{
          "id": "GROUP-\($cat_upper)-\($group_index)",
          "type": "group",
          "category": $cat,
          "pattern": ((.[0].title // "") | gsub(" in .*$"; "")),
          "count": length,
          "files": ([.[] | .location.file // null] | map(select(. != null)) | unique),
          "memberIds": ([.[] | .id])
        }]
      else
        # Return findings as-is
        .
      end
    )
    # Flatten nested arrays back into single array
    | flatten
  '
}

# =============================================================================
# Monorepo Detection Utilities (v5.1.0)
# =============================================================================

# Detect monorepo type and return configuration
#
# Checks for monorepo indicator files in priority order:
# 1. turbo.json (Turborepo)
# 2. nx.json (Nx)
# 3. lerna.json (Lerna)
# 4. pnpm-workspace.yaml (pnpm)
# 5. package.json with workspaces + yarn.lock (Yarn)
# 6. package.json with workspaces (npm)
# 7. Otherwise: single project
#
# Usage:
#   result=$(detect_monorepo)           # Current directory
#   result=$(detect_monorepo "./apps")  # Specific directory
#
# Args:
#   $1 - Directory to check (optional, default: current directory)
#
# Returns:
#   JSON object with type, buildCmd, and workspaceCmd:
#   {"type":"turborepo","buildCmd":"turbo build","workspaceCmd":"turbo build --filter="}
#
# Example:
#   detect_monorepo /path/to/repo | jq -r '.type'
#   # Returns: "turborepo", "nx", "lerna", "pnpm", "yarn", "npm", or "single"
#
detect_monorepo() {
  local dir="${1:-.}"

  # Turborepo (highest priority)
  if [ -f "$dir/turbo.json" ]; then
    echo '{"type":"turborepo","buildCmd":"turbo build","workspaceCmd":"turbo build --filter="}'
    return 0
  fi

  # Nx
  if [ -f "$dir/nx.json" ]; then
    echo '{"type":"nx","buildCmd":"nx run-many --target=build","workspaceCmd":"nx run --project="}'
    return 0
  fi

  # Lerna
  if [ -f "$dir/lerna.json" ]; then
    echo '{"type":"lerna","buildCmd":"lerna run build","workspaceCmd":"lerna run build --scope="}'
    return 0
  fi

  # pnpm workspaces
  if [ -f "$dir/pnpm-workspace.yaml" ]; then
    echo '{"type":"pnpm","buildCmd":"pnpm -r build","workspaceCmd":"pnpm --filter="}'
    return 0
  fi

  # Yarn or npm workspaces (check package.json for workspaces field)
  if [ -f "$dir/package.json" ]; then
    # Check if workspaces field exists
    if jq -e '.workspaces' "$dir/package.json" >/dev/null 2>&1; then
      # Distinguish between yarn and npm based on lockfile
      if [ -f "$dir/yarn.lock" ]; then
        echo '{"type":"yarn","buildCmd":"yarn workspaces run build","workspaceCmd":"yarn workspace "}'
        return 0
      else
        echo '{"type":"npm","buildCmd":"npm run build --workspaces","workspaceCmd":"npm run build -w "}'
        return 0
      fi
    fi
  fi

  # Single project (no monorepo indicators)
  echo '{"type":"single","buildCmd":"npm run build","workspaceCmd":null}'
}

# List all workspaces in a monorepo
#
# Enumerates workspaces based on the detected monorepo type.
# For tools that use package.json workspaces, it expands glob patterns
# and finds all directories containing package.json files.
#
# Usage:
#   workspaces=$(list_workspaces)
#   workspaces=$(list_workspaces "./monorepo")
#
# Args:
#   $1 - Directory to check (optional, default: current directory)
#
# Returns:
#   JSON array of workspace objects:
#   [{"name":"web","path":"apps/web"},{"name":"api","path":"apps/api"}]
#
# Example:
#   list_workspaces | jq '.[].name'
#
list_workspaces() {
  local dir="${1:-.}"
  local mono_type
  mono_type=$(detect_monorepo "$dir" | jq -r '.type')

  case "$mono_type" in
    turborepo|nx|lerna|pnpm|yarn|npm)
      # Find all package.json files excluding node_modules and root package.json
      # Extract workspace info from each
      find "$dir" -name "package.json" -not -path "*/node_modules/*" -not -path "$dir/package.json" 2>/dev/null \
        | while read -r pkg; do
            local ws_dir name rel_path
            ws_dir=$(dirname "$pkg")
            name=$(jq -r '.name // "unnamed"' "$pkg" 2>/dev/null)
            # Make path relative to dir
            rel_path=${ws_dir#"$dir/"}
            echo "{\"name\":\"$name\",\"path\":\"$rel_path\"}"
          done | jq -s '.' 2>/dev/null || echo "[]"
      ;;
    *)
      # Single project - no workspaces
      echo "[]"
      ;;
  esac
}

# =============================================================================
# PHASE 4: DECISION-AWARE CODE REVIEW
# =============================================================================

# Extract keywords from decision text
#
# Extracts meaningful keywords from decision title and content,
# filtering out stopwords and normalizing to lowercase.
# Used for displaying relevant keywords to agents.
#
# Usage:
#   keywords=$(get_decision_keywords "No test framework - manual testing only")
#
# Args:
#   $1 - Text to extract keywords from (title + content)
#
# Returns:
#   Space-separated list of lowercase keywords (max 8)
#
# Example:
#   get_decision_keywords "Use vanilla JavaScript" → "vanilla javascript"
#
get_decision_keywords() {
  local text="$1"

  # Skip if empty
  [ -z "$text" ] && return 0

  # Extract keywords using awk
  # 1. Lowercase
  # 2. Remove punctuation
  # 3. Split on whitespace
  # 4. Filter stopwords
  # 5. Take unique, limit to 8
  echo "$text" | awk '
    BEGIN {
      # Common stopwords to filter
      split("the a an is are was were be been being have has had do does did will would could should may might must shall can this that these those it its they them their there here where when what which who whom whose how why and or but if then else for of to from by with at in on as", stop)
      for (i in stop) stopwords[stop[i]] = 1
    }
    {
      # Lowercase and clean
      text = tolower($0)
      gsub(/[^a-z0-9 ]/, " ", text)

      # Split and filter
      n = split(text, words)
      count = 0
      for (i = 1; i <= n && count < 8; i++) {
        w = words[i]
        if (length(w) > 2 && !(w in stopwords) && !(w in seen)) {
          seen[w] = 1
          result = result (result ? " " : "") w
          count++
        }
      }
    }
    END { print result }
  '
}

# Format decisions as markdown table for agent input
#
# Takes a DECISIONS.md file and formats its decisions as a markdown
# table suitable for inclusion in agent prompts. Each decision is
# represented with its ID, title, and extracted keywords.
#
# Usage:
#   table=$(format_decisions_for_agents "context/DECISIONS.md")
#
# Args:
#   $1 - Path to DECISIONS.md file
#
# Returns:
#   Markdown-formatted section with decisions table, or empty string if file missing
#
# Example output:
#   ## Known Project Decisions
#
#   The following decisions are documented in DECISIONS.md...
#
#   | ID | Decision | Keywords |
#   |----|----------|----------|
#   | D001 | No test framework | test, testing, manual |
#
format_decisions_for_agents() {
  local decisions_file="$1"

  # Return empty if file doesn't exist
  [ -f "$decisions_file" ] || return 0

  # Parse decisions
  local decisions
  decisions=$(parse_decisions "$decisions_file")

  # Check if we have any decisions
  local count
  count=$(echo "$decisions" | jq 'length' 2>/dev/null || echo "0")

  # Build the output
  local output=""

  # Section header
  output="## Known Project Decisions

The following decisions are documented in DECISIONS.md. If a finding matches
one of these decisions, downgrade its severity to LOW and mark as intentional.

"

  # If no decisions, indicate that
  if [ "$count" = "0" ] || [ "$count" = "null" ]; then
    output="${output}*No decisions documented.*"
    echo "$output"
    return 0
  fi

  # Table header
  output="${output}| ID | Decision | Keywords |
|----|----------|----------|
"

  # Add each decision as a row
  local temp_file
  temp_file=$(mktemp)
  trap "rm -f '$temp_file'" RETURN

  echo "$decisions" > "$temp_file"

  # Process each decision
  while IFS= read -r line; do
    local id title content keywords
    id=$(echo "$line" | jq -r '.id // ""')
    title=$(echo "$line" | jq -r '.title // ""')
    content=$(echo "$line" | jq -r '.content // ""')

    # Skip if no ID
    [ -z "$id" ] && continue

    # Extract keywords from title and content
    keywords=$(get_decision_keywords "$title $content")

    # Escape pipe characters in title for markdown table
    title=$(echo "$title" | sed 's/|/\\|/g')

    # Add row
    output="${output}| $id | $title | $keywords |
"
  done < <(jq -c '.[]' "$temp_file" 2>/dev/null)

  echo "$output"
}

# Load complete decisions context block for agent injection
#
# Combines format_decisions_for_agents with markdown separators
# to create a complete context block ready for agent prompts.
#
# Usage:
#   context=$(load_decisions_context "context/DECISIONS.md")
#
# Args:
#   $1 - Path to DECISIONS.md file
#
# Returns:
#   Complete markdown context block with separators, or empty string if no file
#
# Example:
#   context=$(load_decisions_context "context/DECISIONS.md")
#   # Pass $context to agent prompts
#
load_decisions_context() {
  local decisions_file="$1"

  # Return empty if file doesn't exist
  [ -f "$decisions_file" ] || return 0

  # Get formatted decisions
  local formatted
  formatted=$(format_decisions_for_agents "$decisions_file")

  # Return empty if formatting failed
  [ -z "$formatted" ] && return 0

  # Wrap in markdown separators
  echo "---
$formatted
---"
}

# Annotate a finding with decision match information
#
# Checks if a finding matches any documented decision, and if so:
# - Downgrades severity to "low"
# - Adds intentionalException with decisionId and confidence
# - Prepends "[Intentional] " to title
# - Adds note to remediation referencing DECISIONS.md
#
# Usage:
#   annotated=$(annotate_finding_with_decision "$finding_json" "DECISIONS.md")
#
# Args:
#   $1 - Finding JSON object (single finding)
#   $2 - Path to DECISIONS.md file
#   $3 - Threshold (optional, default: 0.15)
#
# Returns:
#   Annotated finding JSON (unchanged if no match or file missing)
#
# Example:
#   finding='{"id":"TEST-001","severity":"high",...}'
#   result=$(annotate_finding_with_decision "$finding" "context/DECISIONS.md")
#
annotate_finding_with_decision() {
  local finding="$1"
  local decisions_file="$2"
  local threshold="${3:-0.15}"

  # Return unchanged if file doesn't exist
  if [ ! -f "$decisions_file" ]; then
    echo "$finding"
    return 0
  fi

  # Extract text from finding to match against
  local title description
  title=$(echo "$finding" | jq -r '.title // ""')
  description=$(echo "$finding" | jq -r '.description // ""')
  local finding_text="$title $description"

  # Get match result
  local match_result
  match_result=$(match_finding_to_decisions "$finding_text" "$decisions_file" "$threshold")

  # Check if matched
  local matched
  matched=$(echo "$match_result" | jq -r '.matched // false')

  if [ "$matched" = "true" ]; then
    # Extract match details
    local decision_id confidence
    decision_id=$(echo "$match_result" | jq -r '.decision_id')
    confidence=$(echo "$match_result" | jq -r '.confidence')

    # Annotate the finding using jq to properly handle string escaping
    # - Add [Intentional] prefix only if not already present
    # - Append note to remediation with proper newline handling
    echo "$finding" | jq \
      --arg did "$decision_id" \
      --argjson conf "$confidence" \
      '
        .severity = "low" |
        .title = (if (.title | startswith("[Intentional]")) then .title else "[Intentional] " + .title end) |
        .remediation = (
          if (.remediation // "") != "" then
            .remediation + "\n\nNote: This is documented as intentional in DECISIONS.md (" + $did + ")"
          else
            "Note: This is documented as intentional in DECISIONS.md (" + $did + ")"
          end
        ) |
        .intentionalException = {
          "decisionId": $did,
          "confidence": $conf
        }
      '
  else
    # No match - return unchanged
    echo "$finding"
  fi
}

# Log a decision match attempt for accuracy tracking
#
# Logs match attempts (both matches and non-matches) to enable
# threshold tuning and match accuracy analysis over time.
#
# Usage:
#   log_decision_match "SEC-001" "Finding title" "D001" "0.65" "true" "security" "0.15"
#
# Args:
#   $1 - Finding ID
#   $2 - Finding title
#   $3 - Matched decision ID (empty if no match)
#   $4 - Confidence score
#   $5 - Match result ("true" or "false")
#   $6 - Agent ID
#   $7 - Threshold used (optional, default: 0.15)
#
# Environment:
#   DECISION_MATCH_LOG_DIR - Override log directory (default: .claude/cache)
#
# Log format: JSONL (one JSON object per line)
#
log_decision_match() {
  local finding_id="$1"
  local finding_title="$2"
  local decision_id="$3"
  local confidence="$4"
  local matched="$5"
  local agent_id="$6"
  local threshold="${7:-0.15}"

  # Determine log directory
  local log_dir="${DECISION_MATCH_LOG_DIR:-.claude/cache}"
  local log_file="$log_dir/decision-matches.log"

  # Create directory if needed
  mkdir -p "$log_dir" 2>/dev/null

  # Determine result string
  local result
  if [ "$matched" = "true" ]; then
    result="matched"
  else
    result="not_matched"
  fi

  # Build JSON entry
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Escape special characters in strings for valid JSON
  # Using jq for reliable JSON string escaping (handles all edge cases)
  # jq -Rs reads raw input and converts to JSON string; we strip the outer quotes
  finding_title=$(printf '%s' "$finding_title" | jq -Rs '.' | sed 's/^"//;s/"$//')

  # Create JSON entry
  local json_entry
  if [ -n "$decision_id" ]; then
    json_entry=$(printf '{"timestamp":"%s","findingId":"%s","findingTitle":"%s","decisionId":"%s","confidence":%s,"threshold":%s,"result":"%s","agentId":"%s"}' \
      "$timestamp" "$finding_id" "$finding_title" "$decision_id" "$confidence" "$threshold" "$result" "$agent_id")
  else
    json_entry=$(printf '{"timestamp":"%s","findingId":"%s","findingTitle":"%s","decisionId":null,"confidence":%s,"threshold":%s,"result":"%s","agentId":"%s"}' \
      "$timestamp" "$finding_id" "$finding_title" "$confidence" "$threshold" "$result" "$agent_id")
  fi

  # Append to log file
  echo "$json_entry" >> "$log_file"

  # Check for large file (>10MB) and emit hint
  if [ -f "$log_file" ]; then
    local size
    size=$(wc -c < "$log_file" | tr -d ' ')
    if [ "$size" -gt 10485760 ]; then
      echo "[INFO] Decision match log is large (>10MB). Consider rotation." >&2
    fi
  fi
}

# =============================================================================
# PHASE 5: SYNTHESIS AND REPORTING
# =============================================================================

# Synthesize findings with deduplication and grouping
#
# Applies two-layer deduplication to raw findings:
# 1. Location-based: merge findings at identical file:line
# 2. Pattern-based: group similar findings (>=3 threshold)
#
# Usage:
#   echo "$findings_json" | synthesize_findings
#
# Input: JSON array of AuditFinding objects from stdin
#
# Returns:
#   JSON object with:
#   - findings: deduplicated array
#   - groups: pattern-based groups
#   - stats: deduplication statistics
#
# Example:
#   cat raw-findings.json | synthesize_findings | jq '.stats'
#
synthesize_findings() {
  local input
  input=$(cat)

  # Handle empty or null input
  if [ -z "$input" ] || [ "$input" = "[]" ] || [ "$input" = "null" ]; then
    echo '{"findings":[],"groups":[],"stats":{"rawFindings":0,"afterLocationDedup":0,"afterPatternGrouping":0,"reductionPercent":0}}'
    return 0
  fi

  # Count raw findings
  local raw_count
  raw_count=$(echo "$input" | jq 'length' 2>/dev/null || echo "0")

  # Layer 1: Location-based deduplication
  local after_location_dedup
  after_location_dedup=$(echo "$input" | dedupe_by_location)

  # Count after location dedup
  local location_dedup_count
  location_dedup_count=$(echo "$after_location_dedup" | jq 'length' 2>/dev/null || echo "$raw_count")

  # Layer 2: Pattern-based grouping
  # group_similar_findings returns a flat array with GROUP-* entries mixed in
  local with_groups
  with_groups=$(echo "$after_location_dedup" | group_similar_findings)

  # Extract findings and groups from the flat array
  # Groups have type == "group", findings don't have a type field
  local findings groups
  findings=$(echo "$with_groups" | jq '[.[] | select(.type != "group")]' 2>/dev/null || echo "[]")
  groups=$(echo "$with_groups" | jq '[.[] | select(.type == "group")]' 2>/dev/null || echo "[]")

  # Calculate reduction percent
  local reduction_percent
  if [ "$raw_count" -gt 0 ]; then
    reduction_percent=$((100 - (location_dedup_count * 100 / raw_count)))
  else
    reduction_percent=0
  fi

  # Build final result
  jq -n \
    --argjson findings "$findings" \
    --argjson groups "$groups" \
    --argjson raw "$raw_count" \
    --argjson after_loc "$location_dedup_count" \
    --argjson reduction "$reduction_percent" \
    '{
      "findings": $findings,
      "groups": $groups,
      "stats": {
        "rawFindings": $raw,
        "afterLocationDedup": $after_loc,
        "afterPatternGrouping": ($findings | length),
        "reductionPercent": $reduction
      }
    }'
}

# =============================================================================
# PHASE 5.2: REPORT GENERATION
# =============================================================================

# Get the next available audit filename
#
# Determines the next audit filename based on date and existing files.
# First audit of the day: audit-YYYY-MM-DD
# Subsequent audits: audit-YYYY-MM-DD-002, audit-YYYY-MM-DD-003, etc.
#
# Usage:
#   filename=$(get_next_audit_filename "/path/to/docs/audits")
#
# Args:
#   $1 - Output directory (default: docs/audits)
#
# Returns:
#   Filename without extension (e.g., "audit-2026-01-16" or "audit-2026-01-16-002")
#
get_next_audit_filename() {
  local output_dir="${1:-docs/audits}"
  local today
  today=$(date +%Y-%m-%d)
  local date_prefix="audit-${today}"

  # Count existing audits for today
  local existing_count
  existing_count=$(find "$output_dir" -maxdepth 1 -name "${date_prefix}*.md" 2>/dev/null | wc -l | tr -d ' ')

  if [ "$existing_count" -eq 0 ]; then
    # First audit of the day
    echo "$date_prefix"
  else
    # Subsequent audit - add numbered suffix
    local next_num=$((existing_count + 1))
    printf "%s-%03d" "$date_prefix" "$next_num"
  fi
}

# Clean up stale .tmp files from interrupted writes
#
# Removes any .tmp files left over from failed report generation.
# Should be called at the start of report generation.
#
# Usage:
#   cleanup_audit_tmp_files "/path/to/docs/audits"
#
# Args:
#   $1 - Output directory (default: docs/audits)
#
cleanup_audit_tmp_files() {
  local output_dir="${1:-docs/audits}"

  # Find and remove .tmp files
  find "$output_dir" -maxdepth 1 -name "*.tmp" -type f -delete 2>/dev/null
}

# Generate markdown audit report
#
# Creates a human-readable markdown report from synthesized findings.
# Uses atomic write (temp file → rename) for safety.
#
# Usage:
#   md_file=$(generate_audit_markdown "$report_json" "/path/to/docs/audits")
#   md_file=$(generate_audit_markdown "$report_json" "/path/to/docs/audits" "audit-2026-01-16")
#
# Args:
#   $1 - JSON report data (synthesized findings with metadata)
#   $2 - Output directory (default: docs/audits)
#   $3 - Optional: pre-determined filename (without extension)
#
# Returns:
#   Path to generated markdown file
#
generate_audit_markdown() {
  local report="$1"
  local output_dir="${2:-docs/audits}"
  local filename="${3:-}"  # Optional: pre-determined filename

  # Ensure output directory exists
  mkdir -p "$output_dir"

  # Note: cleanup_audit_tmp_files is called by generate_audit_report() when
  # this function is called from there. When called directly, temp files
  # will be cleaned up next time generate_audit_report runs.

  # Get filename if not provided
  if [ -z "$filename" ]; then
    filename=$(get_next_audit_filename "$output_dir")
  fi
  local md_file="$output_dir/${filename}.md"
  local tmp_file="${md_file}.tmp"

  # Extract all basic values in a single jq call for efficiency
  local extracted
  extracted=$(echo "$report" | jq -r '
    [
      (.metadata.projectName // "Unknown"),
      (.metadata.timestamp // "Unknown"),
      (.summary.grade // "N/A"),
      (.metadata.filesScanned // 0 | tostring),
      (.metadata.agentsRun // [] | join(", ")),
      (.summary.criticalCount // 0 | tostring),
      (.summary.highCount // 0 | tostring),
      (.summary.mediumCount // 0 | tostring),
      (.summary.lowCount // 0 | tostring),
      (.stats.rawFindings // 0 | tostring),
      (.stats.afterLocationDedup // 0 | tostring),
      (.stats.afterPatternGrouping // 0 | tostring),
      (.stats.reductionPercent // 0 | tostring),
      (.metadata.schemaVersion // "1.0.0")
    ] | join("\n")
  ')

  # Parse extracted values (one jq call instead of 12+)
  local project_name timestamp grade files_scanned agents_run
  local critical_count high_count medium_count low_count total_findings
  local raw_findings after_location_dedup after_pattern_grouping reduction_percent
  local schema_version

  project_name=$(echo "$extracted" | sed -n '1p')
  timestamp=$(echo "$extracted" | sed -n '2p')
  grade=$(echo "$extracted" | sed -n '3p')
  files_scanned=$(echo "$extracted" | sed -n '4p')
  agents_run=$(echo "$extracted" | sed -n '5p')
  critical_count=$(echo "$extracted" | sed -n '6p')
  high_count=$(echo "$extracted" | sed -n '7p')
  medium_count=$(echo "$extracted" | sed -n '8p')
  low_count=$(echo "$extracted" | sed -n '9p')
  raw_findings=$(echo "$extracted" | sed -n '10p')
  after_location_dedup=$(echo "$extracted" | sed -n '11p')
  after_pattern_grouping=$(echo "$extracted" | sed -n '12p')
  reduction_percent=$(echo "$extracted" | sed -n '13p')
  schema_version=$(echo "$extracted" | sed -n '14p')

  total_findings=$((critical_count + high_count + medium_count + low_count))

  # Build positives section
  local positives_section
  positives_section=$(echo "$report" | jq -r '
    if (.positives // []) | length > 0 then
      (.positives | map("- " + .) | join("\n"))
    else
      "_No specific positives identified._"
    end
  ')

  # Build findings section - sorted by severity (critical > high > medium > low)
  local findings_section
  findings_section=$(echo "$report" | jq -r '
    # Sort by severity priority
    def severity_priority:
      if . == "critical" then 0
      elif . == "high" then 1
      elif . == "medium" then 2
      elif . == "low" then 3
      else 4
      end;

    # Format location safely (handles null/missing location)
    def format_location:
      if .location and .location.file then
        "- **Location:** `" + .location.file +
        (if .location.line then ":" + (.location.line | tostring) else "" end) + "`\n"
      else
        ""
      end;

    if (.findings // []) | length > 0 then
      (.findings | sort_by(.severity | severity_priority) | map(
        "### " + .id + " (" + (.severity | ascii_upcase) + ")\n\n" +
        "**" + .title + "**\n\n" +
        (if .description then .description + "\n\n" else "" end) +
        format_location +
        "- **Category:** " + .category + "\n" +
        (if .remediation then "- **Remediation:** " + .remediation + "\n" else "" end)
      ) | join("\n---\n\n"))
    else
      "_No findings to report._"
    end
  ')

  # Write to temp file
  cat > "$tmp_file" << EOF
# Code Audit Report

**Project:** ${project_name}
**Date:** ${timestamp}
**Grade:** ${grade}

---

## Executive Summary

| Metric | Value |
|--------|-------|
| Files Scanned | ${files_scanned} |
| Agents Run | ${agents_run} |
| Total Findings | ${total_findings} |
| Deduplication | ${reduction_percent}% reduction |

### Severity Breakdown

| Severity | Count |
|----------|-------|
| Critical | ${critical_count} |
| High | ${high_count} |
| Medium | ${medium_count} |
| Low | ${low_count} |

---

## Positives

${positives_section}

---

## Findings

${findings_section}

---

## Deduplication Statistics

| Stage | Count |
|-------|-------|
| Raw findings | ${raw_findings} |
| After location dedup | ${after_location_dedup} |
| After pattern grouping | ${after_pattern_grouping} |
| **Reduction** | **${reduction_percent}%** |

---

## Metadata

- **Schema Version:** ${schema_version}
- **Generated:** ${timestamp}
EOF

  # Atomic rename
  mv "$tmp_file" "$md_file"

  # Return path
  echo "$md_file"
}

# Generate JSON audit report
#
# Creates a machine-readable JSON report from synthesized findings.
# Uses atomic write (temp file → rename) for safety.
#
# Usage:
#   json_file=$(generate_audit_json "$report_json" "/path/to/docs/audits")
#
# Args:
#   $1 - JSON report data (synthesized findings with metadata)
#   $2 - Output directory (default: docs/audits)
#
# Returns:
#   Path to generated JSON file
#
generate_audit_json() {
  local report="$1"
  local output_dir="${2:-docs/audits}"
  local filename="${3:-}"  # Optional: pre-determined filename

  # Ensure output directory exists
  mkdir -p "$output_dir"

  # Get filename if not provided
  if [ -z "$filename" ]; then
    filename=$(get_next_audit_filename "$output_dir")
  fi
  local json_file="$output_dir/${filename}.json"
  local tmp_file="${json_file}.tmp"

  # Write formatted JSON to temp file
  echo "$report" | jq '.' > "$tmp_file"

  # Atomic rename
  mv "$tmp_file" "$json_file"

  # Return path
  echo "$json_file"
}

# Generate complete audit report (both MD and JSON)
#
# Main entry point for report generation. Creates both markdown
# and JSON reports with atomic writes.
#
# Usage:
#   result=$(generate_audit_report "$report_json" "/path/to/docs/audits")
#
# Args:
#   $1 - JSON report data (synthesized findings with metadata)
#   $2 - Output directory (default: docs/audits)
#
# Returns:
#   JSON object with paths to generated files
#
generate_audit_report() {
  local report="$1"
  local output_dir="${2:-docs/audits}"

  # Ensure output directory exists
  mkdir -p "$output_dir"

  # Clean up any stale temp files first
  cleanup_audit_tmp_files "$output_dir"

  # Get filename once and use for both reports
  local filename
  filename=$(get_next_audit_filename "$output_dir")

  # Generate both reports with the same filename
  local md_file json_file
  md_file=$(generate_audit_markdown "$report" "$output_dir" "$filename")
  json_file=$(generate_audit_json "$report" "$output_dir" "$filename")

  # Return result
  jq -n \
    --arg md "$md_file" \
    --arg json "$json_file" \
    '{"markdown": $md, "json": $json}'
}

# =============================================================================
# PHASE 5.3: DRY-RUN MODE
# =============================================================================

# Format dry-run output for code review preview
#
# Shows what would happen during a code review without actually running it:
# - Codebase analysis summary
# - Agent selection with reasons
# - Project decisions (if available)
# - Estimated review scope
#
# Usage:
#   output=$(format_dry_run_output "$codebase_context" "$decisions_context" "$project_dir")
#
# Args:
#   $1 - Codebase context JSON (from codebase scanner)
#   $2 - Decisions context string (from load_decisions_context, may be empty)
#   $3 - Project directory (for path context, default: current dir)
#
# Returns:
#   Formatted text output suitable for display
#
format_dry_run_output() {
  local context="$1"
  local decisions_context="$2"
  local project_dir="${3:-.}"

  # Extract codebase info
  local project_type has_ui has_tests has_database
  project_type=$(echo "$context" | jq -r '.structure.projectType // "unknown"')
  has_ui=$(echo "$context" | jq -r '.structure.hasUI // false')
  has_tests=$(echo "$context" | jq -r '.structure.hasTests // false')
  has_database=$(echo "$context" | jq -r '.structure.hasDatabase // false')

  # Extract file info
  local total_files total_lines has_typescript
  total_files=$(echo "$context" | jq -r '.files.totalFiles // 0')
  total_lines=$(echo "$context" | jq -r '.size.totalLines // 0')
  has_typescript=$(echo "$context" | jq -r '.files.hasTypeScript // false')

  # Extract frameworks
  local frameworks
  frameworks=$(echo "$context" | jq -r '.structure.frameworks // [] | join(", ")')
  if [ -z "$frameworks" ]; then
    frameworks="None detected"
  fi

  # Build file type breakdown
  local file_breakdown
  file_breakdown=$(echo "$context" | jq -r '
    if .files.byExtension then
      .files.byExtension | to_entries | sort_by(-.value) | .[0:5] |
      map("    " + .key + ": " + (.value | tostring)) | join("\n")
    else
      "    (No file breakdown available)"
    end
  ')

  # Determine agent selection
  local agents_output=""
  local selected_count=0
  local total_agents=9

  # Security - always selected
  agents_output+="  ✓ security-reviewer (always)\n"
  selected_count=$((selected_count + 1))

  # Performance - always selected
  agents_output+="  ✓ performance-reviewer (always)\n"
  selected_count=$((selected_count + 1))

  # Accessibility - requires UI
  if [ "$has_ui" = "true" ]; then
    agents_output+="  ✓ accessibility-reviewer (hasUI: true)\n"
    selected_count=$((selected_count + 1))
  else
    agents_output+="  ✗ accessibility-reviewer (hasUI: false)\n"
  fi

  # SEO - requires UI
  if [ "$has_ui" = "true" ]; then
    agents_output+="  ✓ seo-reviewer (hasUI: true)\n"
    selected_count=$((selected_count + 1))
  else
    agents_output+="  ✗ seo-reviewer (hasUI: false)\n"
  fi

  # Database - requires database
  if [ "$has_database" = "true" ]; then
    agents_output+="  ✓ database-reviewer (hasDatabase: true)\n"
    selected_count=$((selected_count + 1))
  else
    agents_output+="  ✗ database-reviewer (hasDatabase: false)\n"
  fi

  # Testing - always selected
  agents_output+="  ✓ testing-reviewer (always)\n"
  selected_count=$((selected_count + 1))

  # Type Safety - requires TypeScript or always
  if [ "$has_typescript" = "true" ]; then
    agents_output+="  ✓ type-safety-reviewer (hasTypeScript: true)\n"
    selected_count=$((selected_count + 1))
  else
    agents_output+="  ✗ type-safety-reviewer (hasTypeScript: false)\n"
  fi

  # Infrastructure - always selected
  agents_output+="  ✓ infrastructure-reviewer (always)\n"
  selected_count=$((selected_count + 1))

  # Cost - always selected
  agents_output+="  ✓ cost-optimizer (always)\n"
  selected_count=$((selected_count + 1))

  # Build decisions section
  local decisions_section=""
  if [ -n "$decisions_context" ]; then
    # Extract decision count and IDs from the context
    local decision_count
    decision_count=$(echo "$decisions_context" | grep -c "^| D[0-9]" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
    # Ensure it's a number
    decision_count="${decision_count:-0}"
    if [ "$decision_count" -gt 0 ] 2>/dev/null; then
      decisions_section="
Project Decisions ($decision_count found):
$(echo "$decisions_context" | grep "^| D[0-9]" | sed 's/^| /  /' | cut -d'|' -f1-2 | sed 's/|/:/g')
"
    fi
  fi

  # Build output
  cat << EOF
╔════════════════════════════════════════════════════════════════╗
║                    Code Review Dry Run                          ║
╚════════════════════════════════════════════════════════════════╝

Codebase Analysis:
  Project Type: $project_type
  Total Files: $total_files
  Total Lines: $total_lines
  Frameworks: $frameworks
  Has UI: $has_ui
  Has Tests: $has_tests
  Has Database: $has_database
  Has TypeScript: $has_typescript

File Types:
$file_breakdown
$decisions_section
Selected Agents ($selected_count/$total_agents):
$(echo -e "$agents_output")
Estimated Scope:
  ~$total_lines lines across $total_files files

To run the full review:
  /code-review --all
EOF
}

# =============================================================================
# PHASE 1.2: SESSION INDEX AUTO-GENERATION
# =============================================================================

# Generate session index from SESSIONS.md
#
# Parses all session headers and regenerates the Session Index table.
# Handles both pipe-delimited (## Session N | DATE | PHASE) and legacy
# (## Session N - DATE) formats.
#
# Usage:
#   generate_session_index "$CONTEXT_DIR/SESSIONS.md"
#
# Args:
#   $1 - Path to SESSIONS.md file
#
# Returns:
#   0 on success, 1 on error
#   Modifies SESSIONS.md in place with updated index
#
generate_session_index() {
  local sessions_file="$1"

  if [ ! -f "$sessions_file" ]; then
    echo "Error: SESSIONS.md not found: $sessions_file" >&2
    return 1
  fi

  local temp_file="${sessions_file}.tmp"

  # Extract all session headers with their info
  # Format: ## Session N | DATE | PHASE or ## Session N - DATE
  local sessions_data=()

  while IFS= read -r header_line; do
    local session_num=""
    local session_date=""
    local phase=""
    local focus=""
    local session_status=""

    # Parse pipe-delimited format: ## Session N | DATE | PHASE
    if echo "$header_line" | grep -qE "^## Session [0-9]+ \|"; then
      session_num=$(echo "$header_line" | grep -oE "Session [0-9]+" | grep -oE "[0-9]+")
      session_date=$(echo "$header_line" | cut -d'|' -f2 | tr -d ' ')
      phase=$(echo "$header_line" | cut -d'|' -f3- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    # Parse legacy format: ## Session N - DATE
    elif echo "$header_line" | grep -qE "^## Session [0-9]+ -"; then
      session_num=$(echo "$header_line" | grep -oE "Session [0-9]+" | grep -oE "[0-9]+")
      session_date=$(echo "$header_line" | sed -E 's/^## Session [0-9]+ - //' | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" | head -1)
      phase="(legacy)"
    else
      continue
    fi

    # Find the status line for this session (next few lines after header)
    local line_num
    line_num=$(grep -n "^## Session $session_num " "$sessions_file" | head -1 | cut -d: -f1)

    if [ -n "$line_num" ]; then
      # Look for **Status:** or **Focus:** in next 5 lines
      local context_lines
      context_lines=$(sed -n "$((line_num+1)),$((line_num+5))p" "$sessions_file")

      # Extract focus
      focus=$(echo "$context_lines" | grep -oE '\*\*Focus:\*\* [^|]+' | head -1 | sed 's/\*\*Focus:\*\* //')
      focus=$(echo "$focus" | sed 's/[[:space:]]*$//' | cut -c1-30)  # Truncate to 30 chars

      # Extract status
      if echo "$context_lines" | grep -q "✅"; then
        session_status="✅"
      elif echo "$context_lines" | grep -q "⏳"; then
        session_status="⏳"
      else
        session_status="?"
      fi
    fi

    if [ -n "$session_num" ] && [ -n "$session_date" ]; then
      sessions_data+=("$session_num|$session_date|$phase|$focus|$session_status")
    fi
  done < <(grep -E "^## Session [0-9]+" "$sessions_file")

  # Build the new index table
  local index_content="| # | Date | Phase | Focus | Status |
|---|------|-------|-------|--------|"

  for entry in "${sessions_data[@]}"; do
    IFS='|' read -r num dt ph fo st <<< "$entry"
    # Escape any special characters and truncate
    fo=$(echo "$fo" | cut -c1-30)
    index_content+=$'\n'"| $num | $dt | $ph | $fo | $st |"
  done

  # Check if Session Index section exists
  if grep -q "## Session Index" "$sessions_file"; then
    # Replace existing index section
    # Find the start and end of the index section
    local index_start index_end
    index_start=$(grep -n "## Session Index" "$sessions_file" | head -1 | cut -d: -f1)

    # Find the next --- after the index (end of index section)
    index_end=$(sed -n "$((index_start+1)),\$p" "$sessions_file" | grep -n "^---$" | head -1 | cut -d: -f1)

    if [ -n "$index_start" ] && [ -n "$index_end" ]; then
      index_end=$((index_start + index_end))

      # Build new file: header + new index + rest
      {
        head -n "$index_start" "$sessions_file"
        echo ""
        echo "$index_content"
        echo ""
        tail -n "+$index_end" "$sessions_file"
      } > "$temp_file"

      mv "$temp_file" "$sessions_file"
    else
      echo "Warning: Could not find index section boundaries" >&2
      return 1
    fi
  else
    # Insert index section after the first ---
    local first_separator
    first_separator=$(grep -n "^---$" "$sessions_file" | head -1 | cut -d: -f1)

    if [ -n "$first_separator" ]; then
      {
        head -n "$first_separator" "$sessions_file"
        echo ""
        echo "## Session Index"
        echo ""
        echo "$index_content"
        echo ""
        tail -n "+$((first_separator+1))" "$sessions_file"
      } > "$temp_file"

      mv "$temp_file" "$sessions_file"
    else
      echo "Warning: Could not find separator to insert index" >&2
      return 1
    fi
  fi

  return 0
}

# =============================================================================

# Run auto-update check in background (non-blocking)
# Only if not already running and not in quiet mode
if [ "$VERBOSITY" != "quiet" ] && [ -z "$UPDATE_CHECK_RUNNING" ]; then
  export UPDATE_CHECK_RUNNING=1
  check_for_updates &
fi

# Log that common functions were loaded (debug only)
log_debug "Loaded common-functions.sh (version: $(cat VERSION 2>/dev/null || echo 'unknown'))"
