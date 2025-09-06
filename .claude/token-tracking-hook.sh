#!/bin/bash
#
# Claude Code Token Tracking Hook
# Automatically tracks token usage after each API call
#

# Configuration
SYNC_TRACKER="/root/.claude/sync-usage-tracker.sh"
HOOK_LOG="/root/.claude/hook-tracking.log"

# Log function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [TOKEN-HOOK] $1" >> "$HOOK_LOG"
}

# Extract tokens from Claude API response
extract_tokens() {
    local response_data="$1"
    
    # Try different ways to extract token information
    local input_tokens=0
    local output_tokens=0
    
    # Method 1: Direct usage object
    if echo "$response_data" | jq -e '.usage' > /dev/null 2>&1; then
        input_tokens=$(echo "$response_data" | jq -r '.usage.input_tokens // 0')
        output_tokens=$(echo "$response_data" | jq -r '.usage.output_tokens // 0')
    fi
    
    # Method 2: From message metadata
    if [[ "$input_tokens" == "0" ]] && echo "$response_data" | jq -e '.message' > /dev/null 2>&1; then
        input_tokens=$(echo "$response_data" | jq -r '.message.usage.input_tokens // 0')
        output_tokens=$(echo "$response_data" | jq -r '.message.usage.output_tokens // 0')
    fi
    
    # Method 3: From response headers or metadata
    if [[ "$input_tokens" == "0" ]]; then
        # Check for token information in various locations
        input_tokens=$(echo "$response_data" | jq -r '.meta.input_tokens // .metadata.input_tokens // .tokens.input // 0')
        output_tokens=$(echo "$response_data" | jq -r '.meta.output_tokens // .metadata.output_tokens // .tokens.output // 0')
    fi
    
    # Log and update if tokens found
    if [[ "$input_tokens" -gt 0 ]] || [[ "$output_tokens" -gt 0 ]]; then
        log_message "Extracted tokens: input=$input_tokens, output=$output_tokens"
        
        # Update token tracking
        if [[ -x "$SYNC_TRACKER" ]]; then
            "$SYNC_TRACKER" add "$input_tokens" "$output_tokens"
        fi
    else
        log_message "No token usage found in response"
    fi
}

# Main hook execution
main() {
    local hook_type="${1:-unknown}"
    log_message "Hook triggered: $hook_type"
    
    case "$hook_type" in
        "pre-request")
            # Before API request
            log_message "Pre-request hook - preparing token tracking"
            ;;
        "post-request")
            # After API request - this is where we extract tokens
            local response_file="$2"
            if [[ -f "$response_file" ]]; then
                log_message "Processing response file: $response_file"
                local response_data=$(cat "$response_file")
                extract_tokens "$response_data"
            elif [[ -n "$2" ]]; then
                # Response data passed as parameter
                log_message "Processing response data from parameter"
                extract_tokens "$2"
            else
                # Read from stdin
                log_message "Processing response data from stdin"
                local response_data=$(cat)
                extract_tokens "$response_data"
            fi
            ;;
        "session-end")
            log_message "Session ended - token tracking complete"
            ;;
        *)
            log_message "Unknown hook type: $hook_type"
            ;;
    esac
}

# Execute main function with all parameters
main "$@"