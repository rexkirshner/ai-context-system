#!/bin/bash
# Common functions used across AI Context System commands
# Version: 3.0.0
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

  # Default
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
check_for_updates() {
  local check_file=".claude/.last-update-check"
  local check_interval=86400  # 24 hours

  # Skip if verbosity is quiet
  [ "$VERBOSITY" = "quiet" ] && return 0

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

  # Get latest version from GitHub (timeout quickly, don't block)
  local repo_url=$(get_repo_url)
  local repo_path="${repo_url#https://github.com/}"

  local latest=$(curl -s --connect-timeout 3 --max-time 5 \
    "https://api.github.com/repos/$repo_path/releases/latest" 2>/dev/null \
    | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')

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
# Initialization
# =============================================================================

# Run auto-update check in background (non-blocking)
# Only if not already running and not in quiet mode
if [ "$VERBOSITY" != "quiet" ] && [ -z "$UPDATE_CHECK_RUNNING" ]; then
  export UPDATE_CHECK_RUNNING=1
  check_for_updates &
fi

# Log that common functions were loaded (debug only)
log_debug "Loaded common-functions.sh v2.3.0"
