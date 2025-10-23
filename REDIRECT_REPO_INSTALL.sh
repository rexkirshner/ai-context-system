#!/bin/bash

# install.sh (redirect version)
# This repository has been renamed to: ai-context-system
#
# This script automatically redirects to the new installer

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Clear screen for better visibility
clear

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}⚠️  Repository Moved${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}This repository has been renamed to reflect universal AI support${NC}"
echo ""
echo -e "  ${RED}Old${NC}: github.com/rexkirshner/${RED}claude-context-system${NC}"
echo -e "  ${GREEN}New${NC}: github.com/rexkirshner/${GREEN}ai-context-system${NC}"
echo ""
echo -e "${BLUE}Why?${NC} The system now supports Claude Code, Cursor, Aider, Codex, and more."
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}Redirecting to new installer...${NC}"
echo ""

# Wait a moment for user to read
sleep 2

# Redirect to new installer
echo -e "${BLUE}Downloading from: ${GREEN}ai-context-system${NC}"
echo ""

# Execute new installer
curl -sL https://raw.githubusercontent.com/rexkirshner/ai-context-system/main/install.sh | bash

# Check exit code
EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
  echo -e "${GREEN}✅ Installation complete${NC}"
  echo ""
  echo -e "${YELLOW}📌 Please update your bookmarks:${NC}"
  echo -e "   ${GREEN}https://github.com/rexkirshner/ai-context-system${NC}"
  echo ""
else
  echo -e "${RED}❌ Installation failed${NC}"
  echo ""
  echo -e "${YELLOW}Please try installing directly from the new repository:${NC}"
  echo -e "   ${GREEN}https://github.com/rexkirshner/ai-context-system${NC}"
  echo ""
fi

exit $EXIT_CODE
