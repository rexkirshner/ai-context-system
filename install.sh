#!/bin/bash
# Compatibility shim for pre-v6 update commands
#
# Old /update-context-system commands (v4.x, v5.x) try to download this file.
# This script redirects them to the correct migration path.
#
# If you're seeing this, your project needs migration to v6.x.

set -e

echo ""
echo "=============================================="
echo "  AI Context System - Migration Required"
echo "=============================================="
echo ""
echo "The /update-context-system command you ran is from a pre-v6 version."
echo "This project needs migration to v6.x before it can be updated."
echo ""
echo "Run these commands to migrate:"
echo ""
echo "  curl -O https://raw.githubusercontent.com/rexkirshner/ai-context-system/main/migrate-to-v6.sh"
echo "  chmod +x migrate-to-v6.sh"
echo "  ./migrate-to-v6.sh"
echo ""
echo "After migration, use /update-context-system for future v6.x updates."
echo ""
echo "Documentation: https://acs-docs.pages.dev/about/migration"
echo "=============================================="
echo ""

exit 1
