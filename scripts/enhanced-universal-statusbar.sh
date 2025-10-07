#!/bin/bash

# 🌍 Enhanced UNIVERSAL MODE Statusbar with Intelligence Integration
# Real-time display of active intelligence systems, MCPs, and project optimization

# Script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# JSON Input von stdin lesen
input=$(cat)

# Basis-Informationen extrahieren
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name')
session_id=$(echo "$input" | jq -r '.session_id')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')

# Intelligence cache files
INTELLIGENCE_CACHE="$HOME/.claude/intelligence-cache"
MCP_STATES_PATH="$HOME/.claude/mcp-states.json"
PATTERN_STATES_PATH="$HOME/.claude/pattern-states.json"

mkdir -p "$INTELLIGENCE_CACHE"

# Get or update project intelligence
get_project_intelligence() {
    local project_dir="$1"
    local cache_file="$INTELLIGENCE_CACHE/$(echo "$project_dir" | md5sum | cut -d' ' -f1).json"

    # Check if cache is valid (5 minutes for Claude Code v2.0.1 performance)
    if [[ -f "$cache_file" ]] && [[ $(($(date +%s) - $(stat -c %Y "$cache_file"))) -lt 300 ]]; then
        cat "$cache_file"
        return 0
    fi

    # Fast fallback: Use lightweight project detection instead of heavy analyzer
    local project_type="Unknown"
    local confidence=50

    if [[ -f "$project_dir/package.json" ]]; then
        if grep -q "next" "$project_dir/package.json" 2>/dev/null; then
            project_type="Next.js"
            confidence=90
        elif grep -q "react" "$project_dir/package.json" 2>/dev/null; then
            project_type="React"
            confidence=85
        elif grep -q "vue" "$project_dir/package.json" 2>/dev/null; then
            project_type="Vue.js"
            confidence=85
        else
            project_type="Node.js"
            confidence=80
        fi
    elif [[ -f "$project_dir/requirements.txt" ]] || [[ -f "$project_dir/pyproject.toml" ]]; then
        project_type="Python"
        confidence=80
    elif [[ -f "$project_dir/Cargo.toml" ]]; then
        project_type="Rust"
        confidence=90
    elif [[ -f "$project_dir/go.mod" ]]; then
        project_type="Go"
        confidence=90
    fi

    # Cache fast result
    echo "{\"project\":{\"primary_type\":\"$project_type\",\"confidence\":$confidence},\"mcps\":{\"essential\":[],\"recommended\":[]},\"patterns\":{\"patterns\":[],\"intensity\":\"conservative\"}}" > "$cache_file"
    cat "$cache_file"
}

# Get active MCP status (optimized with caching)
get_mcp_status() {
    local cache_file="/tmp/claude-mcp-status-cache.txt"
    local cache_ttl=60  # 1 minute cache for performance

    # Use cache if valid
    if [[ -f "$cache_file" ]] && [[ $(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -lt $cache_ttl ]]; then
        cat "$cache_file"
        return 0
    fi

    # Fast detection: Check common MCP indicators
    local active_count=0
    local total_available=8

    # Check for filesystem access (always available in Claude Code)
    [[ -d "$HOME" ]] && ((active_count++))

    # Check for git (available if in git repo)
    [[ -d ".git" ]] && ((active_count++))

    # Quick MCP state check (if available)
    if [[ -f "$MCP_STATES_PATH" ]]; then
        local state_active=($(jq -r '.active_servers[]' "$MCP_STATES_PATH" 2>/dev/null))
        local state_total=$(jq -r '.available_servers // [] | length' "$MCP_STATES_PATH" 2>/dev/null)

        if [[ ${#state_active[@]} -gt 0 ]]; then
            active_count=${#state_active[@]}
        fi
        if [[ $state_total -gt 0 ]]; then
            total_available=$state_total
        fi
    fi

    # Cache result
    local result="${active_count}/${total_available}"
    echo "$result" > "$cache_file"
    echo "$result"
}

# Get active pattern status (optimized)
get_pattern_status() {
    local intelligence="$1"
    local recommended_patterns=($(echo "$intelligence" | jq -r '.patterns.patterns[]?' 2>/dev/null))

    # Fast return if no patterns recommended
    [[ ${#recommended_patterns[@]} -eq 0 ]] && echo "0/0" && return 0

    if [[ -f "$PATTERN_STATES_PATH" ]]; then
        local active_patterns=($(jq -r '.active_patterns[]?' "$PATTERN_STATES_PATH" 2>/dev/null))
        echo "${#active_patterns[@]}/${#recommended_patterns[@]}"
    else
        echo "0/${#recommended_patterns[@]}"
    fi
}

# Get intelligence level indicator
get_intelligence_level() {
    local intelligence="$1"
    local mcp_status="$2"
    local pattern_status="$3"

    local confidence=$(echo "$intelligence" | jq -r '.project.confidence // 0')
    local mcp_active=$(echo "$mcp_status" | cut -d'/' -f1)
    local mcp_total=$(echo "$mcp_status" | cut -d'/' -f2)
    local pattern_active=$(echo "$pattern_status" | cut -d'/' -f1)
    local pattern_total=$(echo "$pattern_status" | cut -d'/' -f2)

    # Calculate intelligence score (0-100)
    local intelligence_score=0

    # Project confidence (0-50 points)
    intelligence_score=$((intelligence_score + confidence / 2))

    # MCP activation (0-30 points)
    if [[ $mcp_total -gt 0 ]]; then
        intelligence_score=$((intelligence_score + (mcp_active * 30 / mcp_total)))
    fi

    # Pattern activation (0-20 points)
    if [[ $pattern_total -gt 0 ]]; then
        intelligence_score=$((intelligence_score + (pattern_active * 20 / pattern_total)))
    fi

    # Return level and icon
    if [[ $intelligence_score -ge 80 ]]; then
        echo "🌟 MAXIMUM"
    elif [[ $intelligence_score -ge 60 ]]; then
        echo "🚀 HIGH"
    elif [[ $intelligence_score -ge 40 ]]; then
        echo "⚡ MEDIUM"
    elif [[ $intelligence_score -ge 20 ]]; then
        echo "🔧 LOW"
    else
        echo "❌ MINIMAL"
    fi
}

# Get special mode indicators
get_special_modes() {
    local intelligence="$1"
    local special_modes=($(echo "$intelligence" | jq -r '.patterns.special_modes[]' 2>/dev/null))
    local modes_text=""

    for mode in "${special_modes[@]}"; do
        case "$mode" in
            "screenshot-debugging") modes_text="$modes_text📸" ;;
            "api-testing") modes_text="$modes_text🔌" ;;
            "data-visualization") modes_text="$modes_text📊" ;;
            "security-scanning") modes_text="$modes_text🔒" ;;
            "performance-monitoring") modes_text="$modes_text⚡" ;;
            "infrastructure-validation") modes_text="$modes_text🏗️" ;;
        esac
    done

    echo "$modes_text"
}

# Get optimization indicators
get_optimization_indicators() {
    local intelligence="$1"
    local primary_type=$(echo "$intelligence" | jq -r '.project.primary_type')
    local intensity=$(echo "$intelligence" | jq -r '.patterns.intensity')
    local confidence=$(echo "$intelligence" | jq -r '.project.confidence')

    local indicators=""

    # Project type optimization
    case "$primary_type" in
        "React"|"Next.js"|"Vue.js") indicators="$indicators🎨" ;;
        "Python Data Science"|"Jupyter Notebook") indicators="$indicators📊" ;;
        "Terraform Infrastructure") indicators="$indicators🏗️" ;;
        "Node.js Backend"|"Django"|"Flask") indicators="$indicators⚙️" ;;
        *) indicators="$indicators🔧" ;;
    esac

    # Intensity indicator
    case "$intensity" in
        "high") indicators="$indicators🔥" ;;
        "experimental") indicators="$indicators🧪" ;;
        "conservative") indicators="$indicators🛡️" ;;
    esac

    # Confidence indicator
    if [[ $confidence -ge 80 ]]; then
        indicators="$indicators✨"
    elif [[ $confidence -ge 60 ]]; then
        indicators="$indicators⭐"
    fi

    echo "$indicators"
}

# Get git information with enhanced status
get_enhanced_git_info() {
    if [[ -d "$cwd/.git" ]]; then
        cd "$cwd"
        local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
        local status=""
        local ahead_behind=""

        # Git Status Indikatoren
        if git diff --quiet 2>/dev/null; then
            if git diff --cached --quiet 2>/dev/null; then
                status="✓"
            else
                status="●" # staged changes
            fi
        else
            status="○" # unstaged changes
        fi

        # Check ahead/behind status
        if git rev-parse --verify @{upstream} >/dev/null 2>&1; then
            local ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo 0)
            local behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null || echo 0)

            if [[ $ahead -gt 0 ]] && [[ $behind -gt 0 ]]; then
                ahead_behind="↕$ahead/$behind"
            elif [[ $ahead -gt 0 ]]; then
                ahead_behind="↑$ahead"
            elif [[ $behind -gt 0 ]]; then
                ahead_behind="↓$behind"
            fi
        fi

        echo "$branch$status$ahead_behind"
    else
        echo ""
    fi
}

# Model detection with Claude 4.5 support
get_model_info() {
    local model_name="$1"

    # Detect Claude version and return appropriate info
    case "$model_name" in
        *"sonnet-4"*|*"Sonnet 4"*|*"4.5"*|*"claude-sonnet-4"*)
            echo "🧠4.5"
            ;;
        *"sonnet"*|*"Sonnet"*)
            echo "🧠S3.5"
            ;;
        *"opus-4"*|*"Opus 4"*)
            echo "🧠O4"
            ;;
        *"opus"*|*"Opus"*)
            echo "🧠O"
            ;;
        *"haiku"*|*"Haiku"*)
            echo "🧠H"
            ;;
        *)
            echo "🧠"
            ;;
    esac
}

# Use enhanced token tracking (shared with existing system)
get_token_info() {
    # Use shared sync tracker for multi-server coordination (prefer v2.0)
    if [[ -x "$SCRIPT_DIR/../.claude/sync-usage-tracker-v2.sh" ]]; then
        "$SCRIPT_DIR/../.claude/sync-usage-tracker-v2.sh" status
    elif [[ -x "/root/.claude/sync-usage-tracker-v2.sh" ]]; then
        "/root/.claude/sync-usage-tracker-v2.sh" status
    elif [[ -x "/root/.claude/sync-usage-tracker.sh" ]]; then
        "/root/.claude/sync-usage-tracker.sh" status
    else
        # Fallback to basic token tracking
        echo "🔋 Unknown"
    fi
}

# Format aquarium animation for UNIVERSAL mode
format_aquarium_animation() {
    local intelligence_level="$1"

    # Extract icon from intelligence level
    local icon=$(echo "$intelligence_level" | cut -d' ' -f1)

    # Enhanced sea creatures based on intelligence level
    case "$icon" in
        "🌟") # MAXIMUM
            local sea_creatures=("🐋" "🦈" "🐙" "🦑" "🐠" "🐟" "🐡" "🦞")
            ;;
        "🚀") # HIGH
            local sea_creatures=("🦈" "🐙" "🐠" "🐟" "🐡" "🦞" "🐢" "🦀")
            ;;
        "⚡") # MEDIUM
            local sea_creatures=("🐠" "🐟" "🐡" "🦞" "🐢" "🦀" "🦐" "🐚")
            ;;
        "🔧") # LOW
            local sea_creatures=("🐟" "🐡" "🐢" "🦀" "🦐" "🐚" "🌊" "💧")
            ;;
        *) # MINIMAL or other
            local sea_creatures=("🐚" "🌊" "💧" "🔵" "💠" "🔷" "💎" "⭐")
            ;;
    esac

    # Slower animation cycle (20 seconds per complete cycle)
    local minutes=$(date +%M)
    local seconds=$(date +%S)
    local time_index=$(((minutes * 60 + seconds) / 20))
    local creature_index=$((time_index % ${#sea_creatures[@]}))
    local current_creature=${sea_creatures[$creature_index]}

    echo "$current_creature"
}

# Build enhanced statusline with intelligence integration
build_enhanced_statusline() {
    local intelligence=$(get_project_intelligence "$cwd")
    local mcp_status=$(get_mcp_status)
    local pattern_status=$(get_pattern_status "$intelligence")
    local intelligence_level=$(get_intelligence_level "$intelligence" "$mcp_status" "$pattern_status")
    local special_modes=$(get_special_modes "$intelligence")
    local optimization_indicators=$(get_optimization_indicators "$intelligence")
    local git_info=$(get_enhanced_git_info)
    local token_info=$(get_token_info)
    local model_info=$(get_model_info "$model")

    # Get project info
    local primary_type=$(echo "$intelligence" | jq -r '.project.primary_type')
    local confidence=$(echo "$intelligence" | jq -r '.project.confidence')

    # Aquarium animation
    local aquarium_creature=$(format_aquarium_animation "$intelligence_level")

    # Start building status
    local status="$aquarium_creature UNIVERSAL"

    # Add model info (Claude 4.5 support)
    status="$status [$model_info]"

    # Add intelligence level with visual indicator
    local level_text=$(echo "$intelligence_level" | cut -d' ' -f2-)
    status="$status [$level_text]"

    # Add MCP status
    status="$status [MCP:$mcp_status]"

    # Add pattern status if patterns are recommended
    local pattern_total=$(echo "$pattern_status" | cut -d'/' -f2)
    if [[ $pattern_total -gt 0 ]]; then
        status="$status [Patterns:$pattern_status]"
    fi

    # Add special modes if any
    if [[ -n "$special_modes" ]]; then
        status="$status [$special_modes]"
    fi

    # Add optimization indicators
    if [[ -n "$optimization_indicators" ]]; then
        status="$status [$optimization_indicators]"
    fi

    # Add project type if detected with confidence
    if [[ "$primary_type" != "Unknown" && "$primary_type" != "Generic" ]]; then
        if [[ $confidence -ge 70 ]]; then
            status="$status [$primary_type]"
        else
            status="$status [${primary_type}?]"
        fi
    fi

    # Add git info
    if [[ -n "$git_info" ]]; then
        status="$status [git:$git_info]"
    fi

    # Add token info
    if [[ -n "$token_info" && "$token_info" != "🔋 Unknown" ]]; then
        status="$status [$token_info]"
    fi

    # Add output style if not default
    if [[ "$output_style" != "default" && "$output_style" != "null" ]]; then
        case "$output_style" in
            "Explanatory") status="$status [📖]" ;;
            "Learning") status="$status [🎓]" ;;
            *) status="$status [$output_style]" ;;
        esac
    fi

    echo "$status"
}

# Generate detailed status for click/hover interactions
generate_detailed_status() {
    local intelligence=$(get_project_intelligence "$cwd")
    local mcp_status=$(get_mcp_status)
    local pattern_status=$(get_pattern_status "$intelligence")

    cat << EOF
🌍 UNIVERSAL MODE - Detailed Status
=====================================

Project Analysis:
  Type: $(echo "$intelligence" | jq -r '.project.primary_type')
  Confidence: $(echo "$intelligence" | jq -r '.project.confidence')%
  Technologies: $(echo "$intelligence" | jq -r '.project.technologies[]' 2>/dev/null | tr '\n' ', ' | sed 's/,$//')

Intelligence Systems:
  Level: $(get_intelligence_level "$intelligence" "$mcp_status" "$pattern_status")
  MCP Servers: $mcp_status active
  Patterns: $pattern_status activated
  Special Modes: $(get_special_modes "$intelligence")

Recommendations:
  Essential MCPs: $(echo "$intelligence" | jq -r '.mcps.essential[]' 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
  Recommended Patterns: $(echo "$intelligence" | jq -r '.patterns.patterns[]' 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
  Intensity: $(echo "$intelligence" | jq -r '.patterns.intensity')

Generated: $(date)
EOF
}

# Main execution
main() {
    local action="${1:-statusline}"

    case "$action" in
        "statusline"|"")
            build_enhanced_statusline
            ;;
        "detailed"|"detail")
            generate_detailed_status
            ;;
        "test")
            echo "Testing enhanced statusbar..."
            echo "Current working directory: $cwd"
            echo "Intelligence level: $(get_intelligence_level "$(get_project_intelligence "$cwd")" "$(get_mcp_status)" "$(get_pattern_status "$(get_project_intelligence "$cwd")")")"
            build_enhanced_statusline
            ;;
        *)
            echo "Usage: $0 [statusline|detailed|test]"
            exit 1
            ;;
    esac
}

# Execute main function with input processing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ -t 0 ]]; then
        # Interactive mode for testing
        echo '{"workspace":{"current_dir":"'$(pwd)'"},"model":{"display_name":"Claude"},"session_id":"test","output_style":{"name":"default"}}' | main "$@"
    else
        # Normal pipe mode
        main "$@"
    fi
else
    # Called as library, process normally
    main "$@"
fi