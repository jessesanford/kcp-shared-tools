# Git Worktrees Setup for KCP Parallel Development

This document explains how to use git worktrees for efficient parallel development on the kcp project.

## Overview

Git worktrees allow you to have multiple working directories for the same repository, each checked out to different branches. This is perfect for the kcp project's complex TMC (Transparent Multi-Cluster) development workflow with many feature branches.

## Current Setup

### Main Repository
- **Location**: `/workspaces/kcp` 
- **Current Branch**: `feature/tmc-planning`
- **Purpose**: Main development and planning workspace

### Worktree Directory Structure
```
/workspaces/kcp-worktrees/
├── main/                              # Main/stable branch
├── 01a-cluster-basic/                # TMC cluster registration basics
├── 01b-cluster-enhanced/             # Enhanced cluster features
├── 01c-placement-basic/              # Basic workload placement
├── 01d-placement-advanced/           # Advanced placement strategies
├── 02a-core-apis/                    # Core TMC APIs
├── 02b-advanced-apis/                # Advanced API features
├── 03a-controller-base/              # Controller foundation
├── 03b-controller-binary-manager/    # Controller binary management
├── 04a-api-types/                    # API type definitions
└── 04c-placement-controller/         # Placement controller implementation
```

## Worktree Management Script

Use the provided script at `/workspaces/kcp/scripts/manage-worktrees.sh` for easy worktree management:

### Basic Commands

```bash
# List all worktrees
./scripts/manage-worktrees.sh list

# Create a new worktree
./scripts/manage-worktrees.sh create feature/branch-name optional-short-name

# Remove a worktree
./scripts/manage-worktrees.sh remove worktree-name

# Set up all key TMC worktrees
./scripts/manage-worktrees.sh setup-tmc

# Check status of all worktrees
./scripts/manage-worktrees.sh status

# Sync all worktrees with remote
./scripts/manage-worktrees.sh sync

# Open a worktree in VS Code
./scripts/manage-worktrees.sh open worktree-name
```

## Parallel Development Workflow

### 1. Feature Development
```bash
# Work on cluster registration in one terminal
cd /workspaces/kcp-worktrees/01a-cluster-basic
# Make changes, commit, test...

# Simultaneously work on placement in another terminal
cd /workspaces/kcp-worktrees/01c-placement-basic
# Make changes, commit, test...
```

### 2. Integration Testing
```bash
# Test main branch stability
cd /workspaces/kcp-worktrees/main
make test

# Test specific feature branch
cd /workspaces/kcp-worktrees/02a-core-apis
make test-integration
```

### 3. Code Review Preparation
```bash
# Check status across all worktrees
./scripts/manage-worktrees.sh status

# Sync with remote before creating PRs
./scripts/manage-worktrees.sh sync
```

## Benefits for KCP Development

### 1. **Parallel Feature Development**
- Work on multiple TMC phases simultaneously
- No need to constantly switch branches
- Independent build/test environments

### 2. **Reduced Context Switching**
- Keep different features in separate terminals/IDE windows
- Maintain mental context for each feature area
- No lost work due to branch switching

### 3. **Safe Experimentation**
- Try different approaches in parallel
- Compare implementations side-by-side
- Easy rollback without affecting other work

### 4. **Efficient Code Review**
- Keep PR branches isolated
- Easy comparison between versions
- Faster iteration on feedback

## IDE/Editor Integration

### VS Code
Each worktree can be opened as a separate VS Code workspace:
```bash
# Open specific worktree in VS Code
code /workspaces/kcp-worktrees/02a-core-apis

# Or use the script
./scripts/manage-worktrees.sh open 02a-core-apis
```

### Terminal Management
Use terminal multiplexers like tmux or screen, or simply open multiple terminal windows:
```bash
# Terminal 1: Main development
cd /workspaces/kcp

# Terminal 2: Cluster work
cd /workspaces/kcp-worktrees/01a-cluster-basic

# Terminal 3: Placement work
cd /workspaces/kcp-worktrees/01c-placement-basic
```

## Best Practices

### 1. **Naming Conventions**
- Use short, descriptive names for worktrees
- Follow the pattern: `<phase>-<component>-<feature>`
- Examples: `01a-cluster-basic`, `02b-advanced-apis`

### 2. **Regular Syncing**
```bash
# Sync all worktrees daily
./scripts/manage-worktrees.sh sync

# Check for conflicts or issues
./scripts/manage-worktrees.sh status
```

### 3. **Clean Working Directories**
- Commit changes regularly in each worktree
- Don't leave uncommitted changes when switching focus
- Use `git stash` for temporary work

### 4. **Resource Management**
- Don't run multiple builds simultaneously (can be resource-intensive)
- Close unused worktrees to save memory
- Use the `remove` command for completed features

## Advanced Usage

### Creating Feature-Specific Worktrees
```bash
# Create worktree for new feature
./scripts/manage-worktrees.sh create feature/tmc2-impl2/05-new-feature new-feature

# Work in the new worktree
cd /workspaces/kcp-worktrees/new-feature
```

### Comparing Implementations
```bash
# Compare files between branches
diff /workspaces/kcp-worktrees/01a-cluster-basic/pkg/apis/tmc/v1alpha1/types.go \
     /workspaces/kcp-worktrees/02a-core-apis/pkg/apis/tmc/v1alpha1/types.go
```

### Building Multiple Versions
```bash
# Build different versions in parallel (use different terminals)
cd /workspaces/kcp-worktrees/main && make build
cd /workspaces/kcp-worktrees/02a-core-apis && make build
```

## Troubleshooting

### Common Issues

1. **"Branch is already used by worktree"**
   - Use `git worktree list` to see existing worktrees
   - Remove unused worktree with `./scripts/manage-worktrees.sh remove`

2. **Disk space concerns**
   - Each worktree is a full working directory
   - Remove completed feature worktrees
   - Use symbolic links for large shared assets if needed

3. **Build conflicts**
   - Ensure different worktrees don't interfere with each other
   - Use separate output directories if needed
   - Don't run resource-intensive operations simultaneously

### Cleanup
```bash
# Remove all worktrees (except main repo)
git worktree list --porcelain | grep "^worktree " | grep -v "/workspaces/kcp$" | \
    cut -d' ' -f2 | xargs -I {} git worktree remove {}

# Or use the script for individual removal
./scripts/manage-worktrees.sh remove worktree-name
```

## Summary

Git worktrees provide an excellent solution for kcp's complex multi-branch development workflow. They enable:

- **Parallel development** across multiple TMC features
- **Reduced friction** when switching between different work streams  
- **Improved productivity** by maintaining context for each feature area
- **Safer experimentation** with isolated working directories

Use the provided management script to easily create, manage, and navigate between your different development environments.
