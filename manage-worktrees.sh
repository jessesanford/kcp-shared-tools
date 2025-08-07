#!/bin/bash

# Git Worktree Management Script for KCP Development
# This script helps manage multiple worktrees for parallel development

set -e

WORKTREE_BASE="/workspaces/kcp-worktrees"
REPO_ROOT="/workspaces/kcp"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to create a worktree
create_worktree() {
    local branch_name=$1
    local worktree_name=${2:-$(basename "$branch_name")}
    local worktree_path="$WORKTREE_BASE/$worktree_name"
    
    if [ -d "$worktree_path" ]; then
        print_color $YELLOW "Worktree already exists: $worktree_path"
        return 1
    fi
    
    print_color $BLUE "Creating worktree for branch: $branch_name"
    cd "$REPO_ROOT"
    
    if git show-ref --verify --quiet "refs/heads/$branch_name" || git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; then
        git worktree add "$worktree_path" "$branch_name"
        print_color $GREEN "✓ Created worktree: $worktree_path"
    else
        print_color $RED "✗ Branch not found: $branch_name"
        return 1
    fi
}

# Function to remove a worktree
remove_worktree() {
    local worktree_name=$1
    local worktree_path="$WORKTREE_BASE/$worktree_name"
    
    if [ ! -d "$worktree_path" ]; then
        print_color $RED "Worktree not found: $worktree_path"
        return 1
    fi
    
    print_color $YELLOW "Removing worktree: $worktree_path"
    cd "$REPO_ROOT"
    git worktree remove "$worktree_path"
    print_color $GREEN "✓ Removed worktree: $worktree_path"
}

# Function to list all worktrees
list_worktrees() {
    print_color $BLUE "Current Git Worktrees:"
    cd "$REPO_ROOT"
    git worktree list
}

# Function to create worktrees for key TMC branches
setup_tmc_worktrees() {
    print_color $BLUE "Setting up worktrees for key TMC development branches..."
    
    # Core development branches
    local branches=(
        "main"
        "feature/tmc2-impl2/01a-cluster-basic"
        "feature/tmc2-impl2/01b-cluster-enhanced"
        "feature/tmc2-impl2/01c-placement-basic"
        "feature/tmc2-impl2/01d-placement-advanced"
        "feature/tmc2-impl2/02a-core-apis"
        "feature/tmc2-impl2/02b-advanced-apis"
        "feature/tmc2-impl2/03a-controller-base"
        "feature/tmc2-impl2/03b-controller-binary-manager"
        "feature/tmc2-impl2/04a-api-types"
        "feature/tmc2-impl2/04c-placement-controller"
    )
    
    for branch in "${branches[@]}"; do
        local short_name=$(echo "$branch" | sed 's|feature/tmc2-impl2/||' | sed 's|feature/||')
        create_worktree "$branch" "$short_name" || true
    done
    
    print_color $GREEN "✓ TMC worktree setup complete!"
}

# Function to sync all worktrees with remote
sync_all_worktrees() {
    print_color $BLUE "Syncing all worktrees with remote..."
    
    cd "$REPO_ROOT"
    git fetch --all
    
    git worktree list --porcelain | grep "^worktree " | while read -r line; do
        local worktree_path=$(echo "$line" | cut -d' ' -f2)
        local branch_line=$(git worktree list --porcelain | grep -A2 "^worktree $worktree_path" | grep "^branch ")
        
        if [ -n "$branch_line" ]; then
            local branch=$(echo "$branch_line" | cut -d' ' -f2- | sed 's|refs/heads/||')
            print_color $YELLOW "Syncing worktree: $worktree_path (branch: $branch)"
            
            cd "$worktree_path"
            if git status --porcelain | grep -q .; then
                print_color $YELLOW "  Warning: Worktree has uncommitted changes, skipping pull"
            else
                git pull origin "$branch" 2>/dev/null || print_color $YELLOW "  Warning: Could not pull $branch"
            fi
        fi
    done
    
    print_color $GREEN "✓ Sync complete!"
}

# Function to show worktree status
status_all_worktrees() {
    print_color $BLUE "Worktree Status Summary:"
    
    git worktree list --porcelain | grep "^worktree " | while read -r line; do
        local worktree_path=$(echo "$line" | cut -d' ' -f2)
        local branch_line=$(git worktree list --porcelain | grep -A2 "^worktree $worktree_path" | grep "^branch ")
        
        if [ -n "$branch_line" ]; then
            local branch=$(echo "$branch_line" | cut -d' ' -f2- | sed 's|refs/heads/||')
            local short_path=$(basename "$worktree_path")
            
            cd "$worktree_path"
            local status=$(git status --porcelain | wc -l)
            local ahead_behind=$(git rev-list --left-right --count origin/"$branch"...HEAD 2>/dev/null || echo "0 0")
            
            if [ "$status" -gt 0 ]; then
                print_color $YELLOW "📁 $short_path ($branch) - $status uncommitted changes"
            else
                print_color $GREEN "📁 $short_path ($branch) - clean"
            fi
            
            if [ "$ahead_behind" != "0 0" ]; then
                local behind=$(echo "$ahead_behind" | cut -d' ' -f1)
                local ahead=$(echo "$ahead_behind" | cut -d' ' -f2)
                if [ "$behind" -gt 0 ] || [ "$ahead" -gt 0 ]; then
                    print_color $BLUE "   ↓$behind ↑$ahead commits"
                fi
            fi
        fi
    done
}

# Function to open a worktree in a new terminal/editor
open_worktree() {
    local worktree_name=$1
    local worktree_path="$WORKTREE_BASE/$worktree_name"
    
    if [ ! -d "$worktree_path" ]; then
        print_color $RED "Worktree not found: $worktree_path"
        echo "Available worktrees:"
        ls -1 "$WORKTREE_BASE" 2>/dev/null || echo "No worktrees found"
        return 1
    fi
    
    print_color $GREEN "Opening worktree: $worktree_path"
    cd "$worktree_path"
    
    # If running in VS Code, open in new window
    if command -v code >/dev/null 2>&1; then
        code "$worktree_path"
    else
        # Just cd to the directory
        exec bash
    fi
}

# Help function
show_help() {
    echo "Git Worktree Management for KCP Development"
    echo ""
    echo "Usage: $0 <command> [arguments]"
    echo ""
    echo "Commands:"
    echo "  create <branch> [name]    Create a new worktree for the specified branch"
    echo "  remove <name>             Remove a worktree by name"
    echo "  list                      List all current worktrees"
    echo "  setup-tmc                 Create worktrees for all key TMC branches"
    echo "  sync                      Sync all worktrees with remote"
    echo "  status                    Show status of all worktrees"
    echo "  open <name>               Open a worktree in VS Code/new terminal"
    echo "  help                      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 create feature/tmc2-impl2/01a-cluster-basic cluster-basic"
    echo "  $0 remove cluster-basic"
    echo "  $0 setup-tmc"
    echo "  $0 open main"
}

# Main script logic
case "${1:-help}" in
    "create")
        if [ -z "$2" ]; then
            print_color $RED "Error: Branch name required"
            show_help
            exit 1
        fi
        create_worktree "$2" "$3"
        ;;
    "remove")
        if [ -z "$2" ]; then
            print_color $RED "Error: Worktree name required"
            show_help
            exit 1
        fi
        remove_worktree "$2"
        ;;
    "list")
        list_worktrees
        ;;
    "setup-tmc")
        setup_tmc_worktrees
        ;;
    "sync")
        sync_all_worktrees
        ;;
    "status")
        status_all_worktrees
        ;;
    "open")
        if [ -z "$2" ]; then
            print_color $RED "Error: Worktree name required"
            show_help
            exit 1
        fi
        open_worktree "$2"
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_color $RED "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
