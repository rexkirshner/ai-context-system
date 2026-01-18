#!/bin/bash

# Find context folder by checking current directory and up to 2 parent directories
# Returns the relative path to context folder or exits with error
#
# v5.1.2: Respects git boundaries - won't traverse past a .git/ directory
#         This prevents nested repo context confusion where a child repo
#         accidentally uses a parent repo's context files
#
# Usage:
#   source "$(dirname "${BASH_SOURCE[0]}")/../scripts/find-context-folder.sh" || exit 1
#   CONTEXT_DIR=$(find_context_folder) || exit 1
#
# Version: See VERSION file at repository root

find_context_folder() {
  local current_dir="$PWD"
  local git_boundary_hit=false
  local git_boundary_at=""

  # Check current directory
  if [ -d "context" ] && [ -f "context/.context-config.json" ]; then
    echo "context"
    return 0
  fi

  # v5.1.2: Check for git boundary at current directory
  if [ -d ".git" ]; then
    git_boundary_hit=true
    git_boundary_at="$PWD"
  fi

  # Check parent directory (only if no git boundary hit yet)
  if [ "$git_boundary_hit" = false ]; then
    # First check if parent has .git (would be a boundary)
    if [ -d "../.git" ]; then
      git_boundary_hit=true
      git_boundary_at="$(cd .. && pwd)"
    fi

    if [ -d "../context" ] && [ -f "../context/.context-config.json" ]; then
      echo "../context"
      return 0
    fi
  fi

  # Check grandparent directory (only if no git boundary hit yet)
  if [ "$git_boundary_hit" = false ]; then
    # First check if grandparent has .git (would be a boundary)
    if [ -d "../../.git" ]; then
      git_boundary_hit=true
      git_boundary_at="$(cd ../.. && pwd)"
    fi

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
  if [ "$git_boundary_hit" = true ]; then
    echo "" >&2
    echo "⚠️  Git boundary detected at: $git_boundary_at" >&2
    echo "   Search stopped to prevent nested repo context confusion." >&2
    echo "   Parent directories beyond this point were NOT searched." >&2
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
  if [ "$git_boundary_hit" = true ]; then
    echo "If this is a nested project inside another:" >&2
    echo "  - Install AI Context System in THIS repo: /init-context" >&2
    echo "  - Or cd to the parent project to use its context" >&2
  else
    echo "If context folder exists elsewhere:" >&2
    echo "  - Commands work from project root" >&2
    echo "  - Commands work from subdirectories (up to 2 levels deep)" >&2
    echo "  - Example: backend/, frontend/, src/, etc." >&2
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
