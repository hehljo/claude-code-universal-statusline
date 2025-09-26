#!/bin/bash

# Task Master MCP Server Global Installer
# Integrates Task Master AI into Claude Code via MCP

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNIVERSAL_MODE_DIR="$(dirname "$SCRIPT_DIR")"
MCP_SERVER_DIR="$UNIVERSAL_MODE_DIR/mcp-servers/task-master"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if task-master is installed
check_task_master() {
    if ! command -v task-master &> /dev/null; then
        print_error "Task Master AI is not installed globally"
        print_status "Installing task-master-ai..."
        npm install -g task-master-ai
        print_success "Task Master AI installed successfully"
    else
        print_success "Task Master AI is already installed"
    fi
}

# Install MCP Server globally
install_mcp_server() {
    print_status "Installing Task Master MCP Server globally..."
    
    # Create global npm link
    cd "$MCP_SERVER_DIR"
    npm link
    
    print_success "Task Master MCP Server installed globally"
}

# Add to Claude Code MCP configuration
configure_claude_code() {
    local claude_config_dir="$HOME/.claude"
    local mcp_config="$claude_config_dir/mcp.json"
    
    # Create .claude directory if it doesn't exist
    mkdir -p "$claude_config_dir"
    
    # Backup existing config
    if [[ -f "$mcp_config" ]]; then
        cp "$mcp_config" "$mcp_config.backup.$(date +%Y%m%d_%H%M%S)"
        print_status "Backed up existing MCP configuration"
    fi
    
    # Create or update MCP configuration
    if [[ -f "$mcp_config" ]]; then
        # Update existing config
        print_status "Updating existing MCP configuration..."
        
        # Use jq to add task-master server
        jq '.mcpServers["task-master"] = {
            "command": "task-master-mcp",
            "args": [],
            "env": {}
        }' "$mcp_config" > "$mcp_config.tmp" && mv "$mcp_config.tmp" "$mcp_config"
    else
        # Create new config
        print_status "Creating new MCP configuration..."
        
        cat > "$mcp_config" << 'EOF'
{
  "mcpServers": {
    "task-master": {
      "command": "task-master-mcp",
      "args": [],
      "env": {}
    }
  }
}
EOF
    fi
    
    print_success "Claude Code MCP configuration updated"
}

# Update Universal Mode statusline to include Task Master
update_statusline() {
    local statusline_script="$UNIVERSAL_MODE_DIR/scripts/universal-statusline.sh"
    
    if [[ -f "$statusline_script" ]]; then
        print_status "Updating Universal Mode statusline..."
        
        # Add Task Master detection to statusline
        if ! grep -q "task-master" "$statusline_script"; then
            # Add task count detection
            sed -i '/# MCP Server Detection/a\
\
# Task Master Integration\
TASK_COUNT=""\
if command -v task-master &> /dev/null && [[ -d ".taskmaster" ]]; then\
    PENDING_TASKS=$(task-master list --status=pending 2>/dev/null | grep -c "^[0-9]" || echo "0")\
    if [[ "$PENDING_TASKS" -gt 0 ]]; then\
        TASK_COUNT="📋${PENDING_TASKS}"\
    fi\
fi' "$statusline_script"
            
            # Update statusline output to include tasks
            sed -i 's/echo "$STATUS_ICON $MODE_STATUS | $MCP_STATUS | $PROJECT_TYPE | $CODE_QUALITY"/echo "$STATUS_ICON $MODE_STATUS | $MCP_STATUS | $PROJECT_TYPE | $CODE_QUALITY $TASK_COUNT"/' "$statusline_script"
            
            print_success "Universal Mode statusline updated with Task Master integration"
        else
            print_warning "Task Master integration already exists in statusline"
        fi
    else
        print_warning "Universal Mode statusline script not found"
    fi
}

# Test the installation
test_installation() {
    print_status "Testing Task Master MCP Server installation..."
    
    # Test MCP server
    if command -v task-master-mcp &> /dev/null; then
        print_success "Task Master MCP Server command is available"
    else
        print_error "Task Master MCP Server command not found"
        return 1
    fi
    
    # Test Claude Code configuration
    if [[ -f "$HOME/.claude/mcp.json" ]]; then
        if jq -e '.mcpServers["task-master"]' "$HOME/.claude/mcp.json" &> /dev/null; then
            print_success "Task Master MCP Server configured in Claude Code"
        else
            print_error "Task Master MCP Server not found in Claude Code configuration"
            return 1
        fi
    else
        print_error "Claude Code MCP configuration not found"
        return 1
    fi
    
    print_success "Task Master MCP integration test completed successfully"
}

# Show usage information
show_usage() {
    echo "Task Master MCP Server Global Installer"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --install     Install Task Master MCP Server globally"
    echo "  --uninstall   Remove Task Master MCP Server"
    echo "  --test        Test the installation"
    echo "  --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --install    # Install Task Master MCP integration"
    echo "  $0 --test       # Test the installation"
}

# Uninstall function
uninstall() {
    print_status "Uninstalling Task Master MCP Server..."
    
    # Remove npm link
    npm unlink -g task-master-mcp 2>/dev/null || true
    
    # Remove from Claude Code config
    local mcp_config="$HOME/.claude/mcp.json"
    if [[ -f "$mcp_config" ]]; then
        jq 'del(.mcpServers["task-master"])' "$mcp_config" > "$mcp_config.tmp" && mv "$mcp_config.tmp" "$mcp_config"
        print_success "Removed Task Master from Claude Code configuration"
    fi
    
    print_success "Task Master MCP Server uninstalled"
}

# Main execution
main() {
    case "${1:-}" in
        --install)
            print_status "Starting Task Master MCP Server global installation..."
            check_task_master
            install_mcp_server
            configure_claude_code
            update_statusline
            test_installation
            print_success "Task Master MCP Server installation completed!"
            echo ""
            echo "🎯 Next steps:"
            echo "1. Restart Claude Code to load the new MCP server"
            echo "2. Use task-master commands directly in Claude Code:"
            echo "   - task_master_list"
            echo "   - task_master_next"
            echo "   - task_master_add_task"
            echo "3. Initialize Task Master in your project: task-master init"
            ;;
        --uninstall)
            uninstall
            ;;
        --test)
            test_installation
            ;;
        --help|*)
            show_usage
            ;;
    esac
}

main "$@"