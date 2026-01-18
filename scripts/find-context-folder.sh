#!/bin/bash

# Find context folder by checking current directory and up to 2 parent directories
# Returns the relative path to context folder or exits with error
#
# v5.1.2: Respects git boundaries - won't traverse into parent if current dir
#         is a separate git repository (prevents nested repo context confusion)
#
# Usage:
#   source "$(dirname "${BASH_SOURCE[0]}")/../scripts/find-context-folder.sh" || exit 1
#   CONTEXT_DIR=$(find_context_folder) || exit 1
#
# Version: See VERSION file at repository root

find_context_folder() {
  local current_dir="$PWD"

  # Check current directory
  if [ -d "context" ] && [ -f "context/.context-config.json" ]; then
    echo "context"
    return 0
  fi

  # v5.1.2: Check if current directory is a git repo root
  # If so, don't traverse upward (prevents nested repo confusion)
  local is_git_root=false
  if [ -d ".git" ]; then
    is_git_root=true
  fi

  # Check parent directory (only if we're not at a git root without local context)
  if [ "$is_git_root" = false ]; then
    if [ -d "../context" ] && [ -f "../context/.context-config.json" ]; then
      echo "../context"
      return 0
    fi

    # Check grandparent directory
    if [ -d "../../context" ] && [ -f "../../context/.context-config.json" ]; then
      echo "../../context"
      return 0
    fi
  fi

  # Not found - provide helpful error
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
  echo "❌ Context folder not found" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
  echo "" >&2
  echo "Searched:" >&2
  echo "  - $PWD/context/" >&2
  if [ "$is_git_root" = true ]; then
    echo "" >&2
    echo "Note: This directory contains .git/ - treating as separate project." >&2
    echo "      Parent directories were NOT searched to prevent context confusion." >&2
  else
    echo "  - $PWD/../context/" >&2
    echo "  - $PWD/../../context/" >&2
  fi
  echo "" >&2
  echo "Current directory: $PWD" >&2
  echo "" >&2
  echo "To initialize context system:" >&2
  echo "  1. Navigate to your project root" >&2
  echo "  2. Run: /init-context" >&2
  echo "" >&2
  if [ "$is_git_root" = false ]; then
    echo "If context folder exists elsewhere:" >&2
    echo "  - Commands work from project root" >&2
    echo "  - Commands work from subdirectories (up to 2 levels deep)" >&2
    echo "  - Example: backend/, frontend/, src/, etc." >&2
  else
    echo "If this is a nested project inside another:" >&2
    echo "  - Install AI Context System in THIS directory: /init-context" >&2
    echo "  - Or cd to the parent project to use its context" >&2
  fi
  echo "" >&2
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
  return 1
}

# If sourced, define the function
# If executed directly, run the function
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  find_context_folder
fi
