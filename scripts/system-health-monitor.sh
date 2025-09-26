#!/bin/bash

# UNIVERSAL MODE System Health Monitor
health_check() {
    local status=0
    local issues=()

    # Check Task Master
    if ! which task-master >/dev/null 2>&1; then
        issues+=("Task Master not available")
        status=1
    fi

    # Check MCP configuration
    if [[ ! -f "/root/.claude/mcp.json" ]]; then
        issues+=("MCP configuration missing")
        status=1
    fi

    # Check UNIVERSAL MODE template
    if [[ ! -f "/root/.claude/CLAUDE_TEMPLATE_GLOBAL.md" ]]; then
        issues+=("UNIVERSAL MODE template missing")
        status=1
    fi

    # Check statusbar
    if [[ ! -x "/root/.claude/universal-statusline.sh" ]]; then
        issues+=("Enhanced statusbar not installed")
        status=1
    fi

    # Report results
    if [[ $status -eq 0 ]]; then
        echo "✅ System health: OPTIMAL"
        echo "🌍 UNIVERSAL MODE: Fully operational"
        echo "📊 Intelligence systems: Active"
        echo "🔧 MCPs available: $(cat /root/.claude/mcp.json 2>/dev/null | jq '.mcpServers | length' 2>/dev/null || echo 'Unknown')"
    else
        echo "⚠️ System health: DEGRADED"
        echo "Issues found:"
        for issue in "${issues[@]}"; do
            echo "  ❌ $issue"
        done
    fi

    return $status
}

# Auto-repair function
auto_repair() {
    echo "🔧 Attempting auto-repair..."

    # Fix Task Master config if missing
    if [[ ! -f "$(pwd)/.taskmaster/config.json" ]]; then
        mkdir -p "$(pwd)/.taskmaster/tasks"
        echo '{"project_name":"Auto-detected","tasks":[],"next_id":1}' > "$(pwd)/.taskmaster/tasks/tasks.json"
        echo '{"project_root":"'$(pwd)'","created":"'$(date -Iseconds)'"}' > "$(pwd)/.taskmaster/config.json"
        echo "✅ Task Master configuration repaired"
    fi

    # Re-run health check
    health_check
}

# Command line interface
case "${1:-check}" in
    "check") health_check ;;
    "repair") auto_repair ;;
    "status") health_check ;;
    *) echo "Usage: $0 {check|repair|status}" ;;
esac
