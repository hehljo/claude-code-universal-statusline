#!/bin/bash
#
# Advanced Token Tracker für Claude Code
# Analysiert Claude API Responses für exakte Token-Verbrauchsdaten
#

SYNC_TRACKER="/root/.claude/sync-usage-tracker.sh"
LOG_FILE="/root/.claude/advanced-tracking.log"
RESPONSE_CACHE="/tmp/claude-responses"

# Log function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ADVANCED-TRACKER] $1" >> "$LOG_FILE"
}

# Response Cache Directory erstellen
setup_cache() {
    mkdir -p "$RESPONSE_CACHE"
}

# API Response analysieren und echte Token extrahieren
analyze_api_response() {
    local response_file="$1"
    
    if [[ ! -f "$response_file" ]]; then
        log_message "Response file not found: $response_file"
        return 1
    fi
    
    log_message "Analyzing API response: $response_file"
    
    # Verschiedene Token-Extraktionsmethoden versuchen
    local input_tokens=0
    local output_tokens=0
    local found_tokens=false
    
    # Method 1: Standard Claude API Response Format
    if jq -e '.usage' "$response_file" >/dev/null 2>&1; then
        input_tokens=$(jq -r '.usage.input_tokens // 0' "$response_file")
        output_tokens=$(jq -r '.usage.output_tokens // 0' "$response_file")
        if [[ "$input_tokens" -gt 0 ]] || [[ "$output_tokens" -gt 0 ]]; then
            found_tokens=true
            log_message "Method 1: Found tokens in .usage - input: $input_tokens, output: $output_tokens"
        fi
    fi
    
    # Method 2: OpenAI-Format Compatibility  
    if [[ "$found_tokens" == false ]] && jq -e '.choices[0].message' "$response_file" >/dev/null 2>&1; then
        # Für OpenAI-kompatible APIs
        input_tokens=$(jq -r '.usage.prompt_tokens // 0' "$response_file")
        output_tokens=$(jq -r '.usage.completion_tokens // 0' "$response_file")
        if [[ "$input_tokens" -gt 0 ]] || [[ "$output_tokens" -gt 0 ]]; then
            found_tokens=true
            log_message "Method 2: Found tokens in OpenAI format - input: $input_tokens, output: $output_tokens"
        fi
    fi
    
    # Method 3: Anthropic API Headers
    if [[ "$found_tokens" == false ]]; then
        # Prüfe auf Anthropic-spezifische Token-Headers
        local anthropic_input=$(jq -r '.meta.anthropic_input_tokens // .anthropic.input_tokens // 0' "$response_file")
        local anthropic_output=$(jq -r '.meta.anthropic_output_tokens // .anthropic.output_tokens // 0' "$response_file")
        if [[ "$anthropic_input" -gt 0 ]] || [[ "$anthropic_output" -gt 0 ]]; then
            input_tokens="$anthropic_input"
            output_tokens="$anthropic_output"
            found_tokens=true
            log_message "Method 3: Found tokens in Anthropic headers - input: $input_tokens, output: $output_tokens"
        fi
    fi
    
    # Method 4: Text-basierte Token-Schätzung als Fallback
    if [[ "$found_tokens" == false ]]; then
        log_message "Method 4: No exact tokens found, falling back to estimation"
        
        # Input aus verschiedenen Quellen schätzen
        local input_text=""
        local output_text=""
        
        # Input Text finden
        input_text=$(jq -r '.prompt // .input // .message.content // ""' "$response_file" 2>/dev/null)
        
        # Output Text finden
        output_text=$(jq -r '.content // .text // .message // .choices[0].message.content // ""' "$response_file" 2>/dev/null)
        
        # Token schätzen (1 Token ≈ 0.75 Wörter)
        if [[ -n "$input_text" ]]; then
            local input_words=$(echo "$input_text" | wc -w)
            input_tokens=$((input_words * 4 / 3))
        fi
        
        if [[ -n "$output_text" ]]; then
            local output_words=$(echo "$output_text" | wc -w)
            output_tokens=$((output_words * 4 / 3))
        fi
        
        log_message "Estimated tokens from text - input: $input_tokens, output: $output_tokens"
        found_tokens=true
    fi
    
    # Token-Tracking updaten falls Tokens gefunden
    if [[ "$found_tokens" == true ]] && ([[ "$input_tokens" -gt 0 ]] || [[ "$output_tokens" -gt 0 ]]); then
        log_message "Updating token tracking with: input=$input_tokens, output=$output_tokens"
        
        if [[ -x "$SYNC_TRACKER" ]]; then
            "$SYNC_TRACKER" add "$input_tokens" "$output_tokens"
            log_message "Token tracking updated successfully"
            return 0
        else
            log_message "Sync tracker not executable: $SYNC_TRACKER"
            return 1
        fi
    else
        log_message "No valid tokens found for tracking"
        return 1
    fi
}

# Monitor Claude API Responses
monitor_responses() {
    local monitor_dir="${1:-$RESPONSE_CACHE}"
    
    log_message "Starting response monitoring in: $monitor_dir"
    
    # inotify für Datei-Monitoring verwenden
    if command -v inotifywait >/dev/null 2>&1; then
        inotifywait -m -e create -e modify --format '%w%f' "$monitor_dir" | while read file; do
            if [[ "$file" =~ \.json$ ]]; then
                log_message "New API response detected: $file"
                sleep 0.5  # Kurz warten bis Datei vollständig geschrieben
                analyze_api_response "$file"
            fi
        done
    else
        log_message "inotifywait not available, using polling method"
        
        # Polling als Fallback
        while true; do
            for file in "$monitor_dir"/*.json; do
                if [[ -f "$file" ]] && [[ "$file" -nt "$RESPONSE_CACHE/.last_check" ]]; then
                    analyze_api_response "$file"
                fi
            done
            touch "$RESPONSE_CACHE/.last_check"
            sleep 2
        done
    fi
}

# Hauptfunktion
main() {
    setup_cache
    
    case "${1:-monitor}" in
        "monitor")
            log_message "Advanced Token Tracker started"
            monitor_responses "$2"
            ;;
        "analyze")
            if [[ -n "$2" ]]; then
                analyze_api_response "$2"
            else
                echo "Usage: $0 analyze <response_file>"
            fi
            ;;
        "test")
            # Test-Modus für Entwicklung
            log_message "Test mode activated"
            echo "Testing token extraction with sample data..."
            ;;
        *)
            echo "Usage: $0 [monitor|analyze|test] [file/directory]"
            ;;
    esac
}

# Script ausführen
main "$@"