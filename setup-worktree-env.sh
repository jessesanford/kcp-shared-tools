#!/bin/bash

# Worktree Environment Setup Script
# Run this from any worktree to access shared worktree management tools

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up worktree environment...${NC}"

# Check if we're in a worktree
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}Warning: Not in a git repository${NC}"
fi

# Source the aliases
if [ -f "/workspaces/kcp-shared-tools/.worktree-aliases" ]; then
    source /workspaces/kcp-shared-tools/.worktree-aliases
    echo -e "${GREEN}✓ Worktree aliases loaded${NC}"
else
    echo -e "${YELLOW}Warning: Alias file not found${NC}"
fi

# Make management script executable
if [ -f "/workspaces/kcp-shared-tools/manage-worktrees.sh" ]; then
    chmod +x /workspaces/kcp-shared-tools/manage-worktrees.sh
    echo -e "${GREEN}✓ Management script ready${NC}"
else
    echo -e "${YELLOW}Warning: Management script not found${NC}"
fi

# Display available commands
echo -e "${BLUE}Available commands:${NC}"
echo "  wt-list      - List all worktrees"
echo "  wt-status    - Show status of all worktrees"
echo "  wt-switch    - Switch to a worktree directory"
echo "  wt-create    - Create a new worktree"
echo "  wt-remove    - Remove a worktree"
echo "  wt-sync      - Sync all worktrees with remote"

# Add to shell profile hint
echo -e "${YELLOW}Tip: Add this to your ~/.bashrc for automatic setup:${NC}"
echo "source /workspaces/kcp-shared-tools/setup-worktree-env.sh"

echo -e "${GREEN}✓ Worktree environment ready!${NC}"
