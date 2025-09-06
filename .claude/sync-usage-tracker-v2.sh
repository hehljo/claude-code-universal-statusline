#!/bin/bash
#
# Sync Usage Tracker v2.0 for Claude Code - Multi-Server Support
# Synchronizes real token usage between servers via shared NAS
#

# Configuration
SHARED_DIR="/mnt/fileshare/claude-sync"
LOCAL_DIR="/root/.claude"
USAGE_FILE="usage-tracking.json"

# Server identification
SERVER_ID=$(hostname || echo "unknown")
if [[ "$SERVER_ID" =~ lxc ]]; then
    SERVER_ID="LXC115"
else
    SERVER_ID="MAIN"
fi

# Get usage file path (shared preferred, local fallback)
get_usage_file() {
    if [[ -d "$SHARED_DIR" ]]; then
        echo "$SHARED_DIR/$USAGE_FILE"
    else
        echo "$LOCAL_DIR/$USAGE_FILE"
    fi
}

# Add real token consumption (input + output separated)
add_real_tokens() {
    local input_tokens="${1:-0}"
    local output_tokens="${2:-0}"
    local total_tokens=$((input_tokens + output_tokens))
    local usage_file=$(get_usage_file)
    local current_time=$(date +%s)
    
    # Log the usage
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$SERVER_ID] Real tokens: input=$input_tokens, output=$output_tokens, total=$total_tokens" >> "$LOCAL_DIR/token-usage.log"
    
    # Check if file exists and has v2.0 structure
    if [[ ! -f "$usage_file" ]] || ! jq -e '.version' "$usage_file" >/dev/null 2>&1; then
        echo "Creating new v2.0 usage tracking file..."
        initialize_usage_file "$usage_file"
    fi
    
    # Lock for atomic update
    local lock_file="${usage_file}.lock"
    exec 200>"$lock_file"
    flock 200 || return 1
    
    # Update with real token data
    jq --arg server "$SERVER_ID" \
       --argjson input "$input_tokens" \
       --argjson output "$output_tokens" \
       --argjson total "$total_tokens" \
       --argjson time "$current_time" '
       .token_usage.current_window.total_tokens += $total |
       .token_usage.current_window.input_tokens += $input |
       .token_usage.current_window.output_tokens += $output |
       .token_usage.current_window.total_requests += 1 |
       .token_usage.current_window.last_request = $time |
       if .token_usage.current_window.first_request == null then
           .token_usage.current_window.first_request = $time
       else . end |
       .server_tracking.last_active_server = $server |
       .server_tracking.servers[$server].last_active = $time |
       .server_tracking.servers[$server].session_requests += 1 |
       .server_tracking.servers[$server].session_tokens.total += $total |
       .server_tracking.servers[$server].session_tokens.input += $input |
       .server_tracking.servers[$server].session_tokens.output += $output |
       .last_updated = $time
       ' "$usage_file" > "${usage_file}.tmp" && mv "${usage_file}.tmp" "$usage_file"
    
    # Release lock
    exec 200>&-
    
    echo "✅ Added $total_tokens tokens ($input_tokens input + $output_tokens output)"
}

# Initialize new v2.0 usage file
initialize_usage_file() {
    local file="$1"
    local current_time=$(date +%s)
    local current_hour=$(date +%H)
    local current_date=$(date +%Y-%m-%d)
    local session_start=$(date -d "$current_date $current_hour:00:00" +%s)
    local next_reset=$((session_start + 18000))
    
    cat > "$file" << EOF
{
  "version": "2.0",
  "last_updated": $current_time,
  "session_management": {
    "current_session": {
      "session_start": $session_start,
      "next_reset": $next_reset,
      "duration_seconds": 18000
    }
  },
  "plan_configuration": {
    "current_plan": "pro",
    "limits": {
      "pro": {"total_tokens": 100000, "window_hours": 5},
      "max": {"total_tokens": 500000, "window_hours": 5}
    }
  },
  "token_usage": {
    "current_window": {
      "total_tokens": 0,
      "input_tokens": 0,
      "output_tokens": 0,
      "total_requests": 0,
      "first_request": null,
      "last_request": null
    }
  },
  "server_tracking": {
    "last_active_server": "$SERVER_ID",
    "servers": {
      "$SERVER_ID": {
        "last_active": $current_time,
        "session_requests": 0,
        "session_tokens": {"total": 0, "input": 0, "output": 0}
      }
    }
  }
}
EOF
}

# Get current status display
get_status() {
    local usage_file=$(get_usage_file)
    local current_time=$(date +%s)
    
    if [[ ! -f "$usage_file" ]]; then
        echo "🟢 100k (5h0m)"
        return
    fi
    
    # Read current usage
    local tokens_used=$(jq -r '.token_usage.current_window.total_tokens // 0' "$usage_file")
    local plan=$(jq -r '.plan_configuration.current_plan // "pro"' "$usage_file")
    local next_reset=$(jq -r '.session_management.current_session.next_reset // 0' "$usage_file")
    
    # Check if reset needed
    if [[ $current_time -gt $next_reset ]]; then
        tokens_used=0
        # Reset the window
        jq --argjson time "$current_time" \
           --argjson start "$(date -d "$(date +%Y-%m-%d) $(date +%H):00:00" +%s)" \
           --argjson reset "$(($(date -d "$(date +%Y-%m-%d) $(date +%H):00:00" +%s) + 18000))" \
           '.session_management.current_session.session_start = $start |
            .session_management.current_session.next_reset = $reset |
            .token_usage.current_window = {
                "total_tokens": 0,
                "input_tokens": 0, 
                "output_tokens": 0,
                "total_requests": 0,
                "first_request": null,
                "last_request": null
            } |
            .last_updated = $time' "$usage_file" > "${usage_file}.tmp" && mv "${usage_file}.tmp" "$usage_file"
    fi
    
    # Calculate remaining tokens and time
    local limit=100000
    if [[ "$plan" == "max" ]]; then
        limit=500000
    fi
    
    local remaining=$((limit - tokens_used))
    local percentage=$((tokens_used * 100 / limit))
    
    # Status icon
    local icon="🟢"
    if [[ $percentage -gt 80 ]]; then
        icon="🔴"
    elif [[ $percentage -gt 60 ]]; then
        icon="🟡"
    fi
    
    # Time until reset
    local time_to_reset=$((next_reset - current_time))
    local hours_to_reset=$((time_to_reset / 3600))
    local mins_to_reset=$(((time_to_reset % 3600) / 60))
    
    # Format output
    if [[ $remaining -gt 0 ]]; then
        if [[ $hours_to_reset -gt 0 ]]; then
            echo "$icon $((remaining / 1000))k (${hours_to_reset}h${mins_to_reset}m)"
        else
            echo "$icon $((remaining / 1000))k (${mins_to_reset}m)"
        fi
    else
        echo "$icon 0k (${hours_to_reset}h${mins_to_reset}m)"
    fi
}

# Show detailed status
show_detailed_status() {
    local usage_file=$(get_usage_file)
    
    if [[ ! -f "$usage_file" ]]; then
        echo "No usage data found"
        return
    fi
    
    echo "=== Claude Usage Tracking Status ==="
    echo "File: $usage_file"
    echo "Version: $(jq -r '.version // "1.0"' "$usage_file")"
    echo "Plan: $(jq -r '.plan_configuration.current_plan // "unknown"' "$usage_file")"
    echo ""
    echo "Current Window:"
    echo "  Total Tokens: $(jq -r '.token_usage.current_window.total_tokens // 0' "$usage_file")"
    echo "  Input Tokens: $(jq -r '.token_usage.current_window.input_tokens // 0' "$usage_file")"  
    echo "  Output Tokens: $(jq -r '.token_usage.current_window.output_tokens // 0' "$usage_file")"
    echo "  Total Requests: $(jq -r '.token_usage.current_window.total_requests // 0' "$usage_file")"
    echo ""
    echo "Active Servers: $(jq -r '.server_tracking.servers | keys | join(", ")' "$usage_file")"
    echo "Last Active: $(jq -r '.server_tracking.last_active_server // "unknown"' "$usage_file")"
}

# Main execution
main() {
    case "${1:-status}" in
        "add")
            local input_tokens="${2:-0}"
            local output_tokens="${3:-0}"
            add_real_tokens "$input_tokens" "$output_tokens"
            get_status
            ;;
        "status")
            get_status
            ;;
        "detailed")
            show_detailed_status
            ;;
        "init")
            initialize_usage_file "$(get_usage_file)"
            echo "✅ Initialized v2.0 usage tracking"
            ;;
        *)
            echo "Usage: $0 [add <input_tokens> <output_tokens>|status|detailed|init]"
            echo ""
            echo "Commands:"
            echo "  add INPUT OUTPUT  - Add real token consumption"
            echo "  status           - Show current status"
            echo "  detailed         - Show detailed statistics"
            echo "  init             - Initialize new tracking file"
            ;;
    esac
}

# Execute main
main "$@"