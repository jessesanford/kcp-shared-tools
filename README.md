# KCP Worktree Management Tools

This directory contains shared tools for managing git worktrees across all KCP development environments.

## Location
These tools are stored outside any git repository at `/workspaces/kcp-shared-tools/` to ensure they're accessible from all worktrees.

## Quick Start

From any worktree:
```bash
# Setup environment (loads aliases and tools)
source /workspaces/kcp-shared-tools/setup-worktree-env.sh

# Add to your shell profile for automatic setup
echo 'source /workspaces/kcp-shared-tools/setup-worktree-env.sh' >> ~/.bashrc
```

## Available Tools

1. **manage-worktrees.sh** - Main worktree management script
2. **.worktree-aliases** - Shell aliases for quick commands  
3. **WORKTREES-GUIDE.md** - Comprehensive usage documentation
4. **setup-worktree-env.sh** - Environment setup script

## Available Commands (after setup)

- `wt-list` - List all worktrees
- `wt-status` - Show status of all worktrees
- `wt-switch <name>` - Switch to a worktree
- `wt-create <branch> <name>` - Create new worktree
- `wt-remove <name>` - Remove a worktree
- `wt-sync` - Sync all worktrees with remote

## Integration with KCP Development

These tools are designed to work with the KCP TMC implementation workflow described in `/home/vscode/.claude/CLAUDE.md`.

For detailed usage instructions, read `WORKTREES-GUIDE.md` in this directory.
# kcp-shared-tools
