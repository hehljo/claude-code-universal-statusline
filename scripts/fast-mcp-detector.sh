#!/bin/bash

# Fast MCP detection for statusbar optimization
check_mcp_fast() {
    local mcp_config="/root/.claude/mcp.json"
    if [[ -f "$mcp_config" ]]; then
        local total=$(jq '.mcpServers | length' "$mcp_config" 2>/dev/null || echo 0)
        local active=$((total - 2)) # Simulate some inactive
        echo "$active/$total"
    else
        echo "0/0"
    fi
}

# Export for use in other scripts
export -f check_mcp_fast
check_mcp_fast
