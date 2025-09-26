#!/bin/bash

# 🤖 Automatic MCP Activation System for UNIVERSAL MODE
# Intelligently activates and manages MCP servers based on project context

# Script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# MCP configuration paths
MCP_CONFIG_PATH="$HOME/.config/claude-desktop/claude_desktop_config.json"
MCP_BACKUP_PATH="$HOME/.config/claude-desktop/claude_desktop_config.backup.json"
MCP_STATES_PATH="$HOME/.claude/mcp-states.json"

# Available MCP servers with their configurations
declare -A MCP_SERVERS=(
    ["filesystem"]='{"command": "npx", "args": ["-y", "@modelcontextprotocol/server-filesystem", "/root"]}'
    ["git"]='{"command": "npx", "args": ["-y", "@modelcontextprotocol/server-git", "--repository", "."]}'
    ["github"]='{"command": "npx", "args": ["-y", "@modelcontextprotocol/server-github"], "env": {"GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"}}'
    ["postgres"]='{"command": "npx", "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://localhost/claude"]}'
    ["brave-search"]='{"command": "npx", "args": ["-y", "@modelcontextprotocol/server-brave-search"], "env": {"BRAVE_API_KEY": "${BRAVE_API_KEY}"}}'
    ["puppeteer"]='{"command": "npx", "args": ["-y", "@modelcontextprotocol/server-puppeteer"]}'
    ["memory"]='{"command": "npx", "args": ["-y", "@modelcontextprotocol/server-memory"]}'
    ["everything"]='{"command": "npx", "args": ["-y", "@modelcontextprotocol/server-everything"]}'
    ["sequential-thinking"]='{"command": "npx", "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]}'
)

# Task Master MCP (local installation)
if [[ -f "$SCRIPT_DIR/../mcp-servers/task-master/package.json" ]]; then
    MCP_SERVERS["task-master"]='{"command": "node", "args": ["'$SCRIPT_DIR'/../mcp-servers/task-master/index.js"]}'
fi

# Initialize MCP system
init_mcp_system() {
    echo "🤖 Initializing MCP Auto-Activation System..."

    # Create necessary directories
    mkdir -p "$(dirname "$MCP_CONFIG_PATH")"
    mkdir -p "$HOME/.claude"

    # Backup existing configuration
    if [[ -f "$MCP_CONFIG_PATH" ]]; then
        cp "$MCP_CONFIG_PATH" "$MCP_BACKUP_PATH"
        echo "✅ Backed up existing MCP configuration"
    fi

    # Initialize states file
    if [[ ! -f "$MCP_STATES_PATH" ]]; then
        cat > "$MCP_STATES_PATH" << 'EOF'
{
  "active_servers": [],
  "project_associations": {},
  "auto_activation": true,
  "last_update": null
}
EOF
        echo "✅ Initialized MCP states tracking"
    fi

    echo "✅ MCP system initialized"
}

# Get current MCP configuration
get_current_config() {
    if [[ -f "$MCP_CONFIG_PATH" ]]; then
        cat "$MCP_CONFIG_PATH"
    else
        echo '{"mcpServers": {}}'
    fi
}

# Update MCP configuration with new servers
update_mcp_config() {
    local servers_to_activate=("$@")
    local current_config=$(get_current_config)

    # Create new configuration
    local new_config=$(echo "$current_config" | jq '.mcpServers = {}')

    # Add each server to configuration
    for server in "${servers_to_activate[@]}"; do
        if [[ -n "${MCP_SERVERS[$server]}" ]]; then
            local server_config="${MCP_SERVERS[$server]}"
            new_config=$(echo "$new_config" | jq --arg name "$server" --argjson config "$server_config" '.mcpServers[$name] = $config')
            echo "✅ Added $server to MCP configuration"
        else
            echo "⚠️  Unknown MCP server: $server"
        fi
    done

    # Write new configuration
    echo "$new_config" > "$MCP_CONFIG_PATH"

    # Update states
    local updated_states=$(cat "$MCP_STATES_PATH" | jq --argjson servers "$(printf '%s\n' "${servers_to_activate[@]}" | jq -R . | jq -s .)" '
        .active_servers = $servers |
        .last_update = now
    ')
    echo "$updated_states" > "$MCP_STATES_PATH"

    echo "✅ MCP configuration updated with ${#servers_to_activate[@]} servers"
}

# Check if MCP server is available
check_mcp_availability() {
    local server="$1"
    local config="${MCP_SERVERS[$server]}"

    if [[ -z "$config" ]]; then
        return 1
    fi

    # For NPX-based servers, check if NPX is available
    if echo "$config" | jq -e '.command == "npx"' >/dev/null; then
        command -v npx >/dev/null 2>&1 || return 1

        # Check if specific package is available (quick check)
        local package=$(echo "$config" | jq -r '.args[1]')
        # Note: Full availability check would require actual package installation
        # For now, we assume NPX packages are available if NPX is installed
        return 0
    fi

    # For other commands, check if command exists
    local cmd=$(echo "$config" | jq -r '.command')
    command -v "$cmd" >/dev/null 2>&1
}

# Get available MCP servers
get_available_mcps() {
    local available=()

    for server in "${!MCP_SERVERS[@]}"; do
        if check_mcp_availability "$server"; then
            available+=("$server")
        fi
    done

    printf '%s\n' "${available[@]}"
}

# Activate MCPs based on project intelligence
auto_activate_mcps() {
    local project_dir="${1:-$(pwd)}"
    local force_update="${2:-false}"

    echo "🧠 Analyzing project for optimal MCP activation..."

    # Get project intelligence
    local intelligence=$("$SCRIPT_DIR/intelligent-project-detector.sh" analyze "$project_dir")

    if [[ $? -ne 0 ]]; then
        echo "❌ Failed to analyze project"
        return 1
    fi

    # Extract recommended MCPs
    local essential_mcps=($(echo "$intelligence" | jq -r '.mcps.essential[]' 2>/dev/null))
    local recommended_mcps=($(echo "$intelligence" | jq -r '.mcps.recommended[]' 2>/dev/null))
    local optional_mcps=($(echo "$intelligence" | jq -r '.mcps.optional[]' 2>/dev/null))

    # Combine MCPs by priority
    local mcps_to_activate=()
    mcps_to_activate+=("${essential_mcps[@]}")
    mcps_to_activate+=("${recommended_mcps[@]}")

    # Add optional MCPs if they're available and user hasn't disabled them
    local auto_optional=$(cat "$MCP_STATES_PATH" | jq -r '.auto_optional // true')
    if [[ "$auto_optional" == "true" ]]; then
        mcps_to_activate+=("${optional_mcps[@]}")
    fi

    # Remove duplicates and filter by availability
    local available_mcps=($(get_available_mcps))
    local final_mcps=()

    for mcp in "${mcps_to_activate[@]}"; do
        if [[ " ${available_mcps[*]} " =~ " ${mcp} " ]] && [[ ! " ${final_mcps[*]} " =~ " ${mcp} " ]]; then
            final_mcps+=("$mcp")
        fi
    done

    # Check if we need to update configuration
    local current_mcps=($(cat "$MCP_STATES_PATH" | jq -r '.active_servers[]' 2>/dev/null))
    local needs_update=false

    if [[ "$force_update" == "true" ]] || [[ ${#current_mcps[@]} -ne ${#final_mcps[@]} ]]; then
        needs_update=true
    else
        # Check if arrays are different
        for mcp in "${final_mcps[@]}"; do
            if [[ ! " ${current_mcps[*]} " =~ " ${mcp} " ]]; then
                needs_update=true
                break
            fi
        done
    fi

    if [[ "$needs_update" == "true" ]]; then
        echo "🔄 Updating MCP configuration..."
        update_mcp_config "${final_mcps[@]}"

        # Store project association
        local project_hash=$(echo "$project_dir" | md5sum | cut -d' ' -f1)
        local updated_states=$(cat "$MCP_STATES_PATH" | jq --arg hash "$project_hash" --arg path "$project_dir" --argjson mcps "$(printf '%s\n' "${final_mcps[@]}" | jq -R . | jq -s .)" '
            .project_associations[$hash] = {
                "path": $path,
                "mcps": $mcps,
                "last_activated": now
            }
        ')
        echo "$updated_states" > "$MCP_STATES_PATH"
    else
        echo "✅ MCP configuration is already optimal"
    fi

    # Display activation summary
    echo ""
    echo "📊 MCP Activation Summary:"
    echo "Project Type: $(echo "$intelligence" | jq -r '.project.primary_type')"
    echo "Confidence: $(echo "$intelligence" | jq -r '.project.confidence')%"
    echo ""
    echo "Essential MCPs: ${essential_mcps[*]:-none}"
    echo "Recommended MCPs: ${recommended_mcps[*]:-none}"
    echo "Optional MCPs: ${optional_mcps[*]:-none}"
    echo ""
    echo "Activated MCPs (${#final_mcps[@]}): ${final_mcps[*]}"

    # Check for missing MCPs
    local missing_mcps=()
    for mcp in "${essential_mcps[@]}" "${recommended_mcps[@]}"; do
        if [[ ! " ${available_mcps[*]} " =~ " ${mcp} " ]]; then
            missing_mcps+=("$mcp")
        fi
    done

    if [[ ${#missing_mcps[@]} -gt 0 ]]; then
        echo ""
        echo "⚠️  Missing recommended MCPs: ${missing_mcps[*]}"
        echo "Run 'npm install -g' for the missing packages to enable full functionality"
    fi

    return 0
}

# List current MCP status
list_mcp_status() {
    echo "🤖 MCP Auto-Activation Status"
    echo "=============================="

    if [[ ! -f "$MCP_STATES_PATH" ]]; then
        echo "❌ MCP system not initialized. Run 'init' first."
        return 1
    fi

    local states=$(cat "$MCP_STATES_PATH")
    local active_mcps=($(echo "$states" | jq -r '.active_servers[]' 2>/dev/null))
    local auto_activation=$(echo "$states" | jq -r '.auto_activation')
    local last_update=$(echo "$states" | jq -r '.last_update')

    echo "Auto-activation: $auto_activation"
    echo "Last update: $last_update"
    echo ""
    echo "Active MCPs (${#active_mcps[@]}):"

    if [[ ${#active_mcps[@]} -eq 0 ]]; then
        echo "  (none)"
    else
        for mcp in "${active_mcps[@]}"; do
            local status="✅"
            if ! check_mcp_availability "$mcp"; then
                status="❌"
            fi
            echo "  $status $mcp"
        done
    fi

    echo ""
    echo "Available MCPs:"
    local available_mcps=($(get_available_mcps))
    for mcp in "${!MCP_SERVERS[@]}"; do
        local status="❌"
        if [[ " ${available_mcps[*]} " =~ " ${mcp} " ]]; then
            status="✅"
        fi
        local active_marker=""
        if [[ " ${active_mcps[*]} " =~ " ${mcp} " ]]; then
            active_marker=" (active)"
        fi
        echo "  $status $mcp$active_marker"
    done
}

# Install missing MCP packages
install_missing_mcps() {
    echo "📦 Installing missing MCP packages..."

    local missing_packages=()

    # Check each MCP server
    for server in "${!MCP_SERVERS[@]}"; do
        local config="${MCP_SERVERS[$server]}"

        # For NPX-based servers, try to install the package
        if echo "$config" | jq -e '.command == "npx"' >/dev/null; then
            local package=$(echo "$config" | jq -r '.args[1]')

            if [[ "$package" != "null" && "$package" =~ ^@modelcontextprotocol/ ]]; then
                echo "Installing $package..."
                if npm install -g "$package" 2>/dev/null; then
                    echo "✅ Installed $package"
                else
                    echo "⚠️  Failed to install $package (may require different installation method)"
                fi
            fi
        fi
    done

    echo "✅ Installation check complete"
}

# Restore MCP configuration from backup
restore_mcp_config() {
    if [[ -f "$MCP_BACKUP_PATH" ]]; then
        cp "$MCP_BACKUP_PATH" "$MCP_CONFIG_PATH"
        echo "✅ Restored MCP configuration from backup"
    else
        echo "❌ No backup configuration found"
        return 1
    fi
}

# Main execution
main() {
    local action="$1"
    shift

    case "$action" in
        "init")
            init_mcp_system
            ;;
        "activate"|"auto")
            auto_activate_mcps "$@"
            ;;
        "status"|"list")
            list_mcp_status
            ;;
        "install")
            install_missing_mcps
            ;;
        "restore")
            restore_mcp_config
            ;;
        "config")
            # Show current configuration
            echo "Current MCP configuration:"
            get_current_config | jq .
            ;;
        "available")
            echo "Available MCP servers:"
            get_available_mcps
            ;;
        *)
            echo "MCP Auto-Activation System"
            echo "=========================="
            echo ""
            echo "Usage: $0 <command> [options]"
            echo ""
            echo "Commands:"
            echo "  init              - Initialize MCP auto-activation system"
            echo "  activate [dir]    - Auto-activate optimal MCPs for project"
            echo "  status            - Show current MCP activation status"
            echo "  install           - Install missing MCP packages"
            echo "  restore           - Restore MCP configuration from backup"
            echo "  config            - Show current MCP configuration"
            echo "  available         - List available MCP servers"
            echo ""
            echo "Examples:"
            echo "  $0 init                    # Initialize system"
            echo "  $0 activate                # Activate for current directory"
            echo "  $0 activate /path/to/proj  # Activate for specific project"
            echo "  $0 status                  # Check activation status"
            exit 1
            ;;
    esac
}

# Execute if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi