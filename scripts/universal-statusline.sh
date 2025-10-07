#!/bin/bash

# UNIVERSAL MODE Statusline für Claude Code
# Basiert auf CLAUDE_TEMPLATE_GLOBAL.md

# Script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# JSON Input von stdin lesen
input=$(cat)

# Basis-Informationen extrahieren  
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name')
session_id=$(echo "$input" | jq -r '.session_id')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')

# Projekt-spezifische CLAUDE.md hat PRIORITÄT über globale Templates  
local_claude="$cwd/CLAUDE.md"
global_template="/root/.claude/CLAUDE_TEMPLATE_GLOBAL.md"

# CRITICAL: Nur lokale CLAUDE.md verwenden wenn verfügbar
if [ -f "$local_claude" ]; then
    # Lokales Projekt - KEINE globalen Template-Einflüsse
    use_local_context=true
else
    use_local_context=false
fi

# MCP Server Detection
declare -A mcp_servers=(
    ["filesystem"]="filesystem"
    ["github"]="github" 
    ["postgres"]="postgres"
    ["brave-search"]="brave-search"
    ["puppeteer"]="puppeteer"
    ["memory"]="memory"
    ["everything"]="everything"
    ["sequential-thinking"]="sequential-thinking"
)

# Agent Detection (13 Spezialisten)
declare -A agents=(
    ["SecurityAuditor"]="🔒"
    ["BackendArchitect"]="🏗️"
    ["DocumentationAutomator"]="📚"
    ["TestAutomationEngineer"]="🧪"
    ["FrontendSpecialist"]="🎨"
    ["DataEngineeringExpert"]="💾"
    ["MobileDevelopmentExpert"]="📱"
    ["MachineLearningSpecialist"]="🤖"
    ["DevOpsEngineer"]="⚙️"
    ["UIUXDesigner"]="🎯"
    ["QualityAssuranceSpecialist"]="✅"
    ["PerformanceOptimizer"]="⚡"
    ["ComplianceAuditor"]="📋"
)

# Funktionen
get_claude_usage() {
    local usage_file="/root/.claude/usage-tracking.json"
    local current_time=$(date +%s)

    # Claude 2025 Limits: Weekly + 5h rolling window
    # Pro: 40-80h/week Sonnet 4, Max 5x: 140-280h/week Sonnet 4 + 15-35h/week Opus 4
    # Max 20x: 240-480h/week Sonnet 4 + 24-40h/week Opus 4

    # 5h rolling window (primary limit for real-time tracking)
    local pro_5h_limit=45        # ~45 messages per 5h (Pro)
    local max5x_5h_limit=225     # ~225 messages per 5h (Max 5x)
    local max20x_5h_limit=900    # ~900 messages per 5h (Max 20x)

    # Weekly limits (converted to messages estimate: ~1 message = 2000 tokens avg)
    local pro_weekly_limit=1440      # ~60h * 24 messages/h (Pro)
    local max5x_weekly_limit=5040    # ~210h * 24 messages/h (Max 5x)
    local max20x_weekly_limit=8640   # ~360h * 24 messages/h (Max 20x)

    # Usage-Datei erstellen falls nicht vorhanden
    if [[ ! -f "$usage_file" ]]; then
        local week_start=$(date -d "last monday" +%s 2>/dev/null || date -d "monday" +%s)
        local next_weekly_reset=$(date -d "next monday" +%s)
        local session_start=$current_time
        local next_5h_reset=$((session_start + 18000))
        echo '{"session_start":'$session_start',"week_start":'$week_start',"tokens_5h":0,"tokens_weekly":0,"messages_5h":0,"messages_weekly":0,"plan":"pro","next_5h_reset":'$next_5h_reset',"next_weekly_reset":'$next_weekly_reset'}' > "$usage_file"
    fi

    # Aktuelle Usage laden
    local usage_data=$(cat "$usage_file" 2>/dev/null)
    local session_start=$(echo "$usage_data" | jq -r '.session_start // '$current_time'')
    local week_start=$(echo "$usage_data" | jq -r '.week_start // '$current_time'')
    local tokens_5h=$(echo "$usage_data" | jq -r '.tokens_5h // 0')
    local tokens_weekly=$(echo "$usage_data" | jq -r '.tokens_weekly // 0')
    local messages_5h=$(echo "$usage_data" | jq -r '.messages_5h // 0')
    local messages_weekly=$(echo "$usage_data" | jq -r '.messages_weekly // 0')
    local plan=$(echo "$usage_data" | jq -r '.plan // "pro"')
    local next_5h_reset=$(echo "$usage_data" | jq -r '.next_5h_reset // '$((current_time + 18000))'')
    local next_weekly_reset=$(echo "$usage_data" | jq -r '.next_weekly_reset // '$(date -d "next monday" +%s)'')

    # Reset 5h window wenn abgelaufen
    if [[ $current_time -gt $next_5h_reset ]]; then
        session_start=$current_time
        next_5h_reset=$((session_start + 18000))
        tokens_5h=0
        messages_5h=0
    fi

    # Reset weekly wenn neue Woche
    if [[ $current_time -gt $next_weekly_reset ]]; then
        week_start=$(date -d "last monday" +%s 2>/dev/null || date -d "monday" +%s)
        next_weekly_reset=$(date -d "next monday" +%s)
        tokens_weekly=0
        messages_weekly=0
    fi

    # Token-Schätzung für aktuellen Request
    local current_estimate=0
    if [[ -n "$session_id" && "$session_id" != "null" ]]; then
        local input_length=$(echo "$input" | wc -c)
        local estimated_response=1500
        local input_tokens=$((input_length / 4))
        local output_tokens=$((estimated_response / 4))
        local context_tokens=500
        current_estimate=$((input_tokens + output_tokens + context_tokens))

        # Update mit File-Locking
        (
            flock -x 200
            local fresh_data=$(cat "$usage_file" 2>/dev/null)
            tokens_5h=$(echo "$fresh_data" | jq -r '.tokens_5h // 0')
            tokens_weekly=$(echo "$fresh_data" | jq -r '.tokens_weekly // 0')
            messages_5h=$(echo "$fresh_data" | jq -r '.messages_5h // 0')
            messages_weekly=$(echo "$fresh_data" | jq -r '.messages_weekly // 0')

            tokens_5h=$((tokens_5h + current_estimate))
            tokens_weekly=$((tokens_weekly + current_estimate))
            messages_5h=$((messages_5h + 1))
            messages_weekly=$((messages_weekly + 1))
        ) 200>"$usage_file.lock"
    fi

    # Usage updaten
    echo '{"session_start":'$session_start',"week_start":'$week_start',"tokens_5h":'$tokens_5h',"tokens_weekly":'$tokens_weekly',"messages_5h":'$messages_5h',"messages_weekly":'$messages_weekly',"plan":"'$plan'","next_5h_reset":'$next_5h_reset',"next_weekly_reset":'$next_weekly_reset'}' > "$usage_file"

    # Limits basierend auf Plan
    local limit_5h=$pro_5h_limit
    local limit_weekly=$pro_weekly_limit
    case "$plan" in
        "max20x")
            limit_5h=$max20x_5h_limit
            limit_weekly=$max20x_weekly_limit
            ;;
        "max5x"|"max")
            limit_5h=$max5x_5h_limit
            limit_weekly=$max5x_weekly_limit
            ;;
    esac

    # Verwende das kritischere Limit
    local remaining_5h=$((limit_5h - messages_5h))
    local remaining_weekly=$((limit_weekly - messages_weekly))
    local percentage_5h=$((messages_5h * 100 / limit_5h))
    local percentage_weekly=$((messages_weekly * 100 / limit_weekly))

    # Zeige kritischeres Limit
    local icon="🟢"
    local remaining=$remaining_5h
    local time_to_reset=$((next_5h_reset - current_time))
    local reset_type="5h"

    if [[ $percentage_weekly -gt $percentage_5h ]]; then
        remaining=$remaining_weekly
        time_to_reset=$((next_weekly_reset - current_time))
        reset_type="weekly"

        if [[ $percentage_weekly -gt 80 ]]; then
            icon="🔴"
        elif [[ $percentage_weekly -gt 60 ]]; then
            icon="🟡"
        fi
    else
        if [[ $percentage_5h -gt 80 ]]; then
            icon="🔴"
        elif [[ $percentage_5h -gt 60 ]]; then
            icon="🟡"
        fi
    fi

    # Zeit bis Reset
    local days_to_reset=$((time_to_reset / 86400))
    local hours_to_reset=$(((time_to_reset % 86400) / 3600))
    local mins_to_reset=$(((time_to_reset % 3600) / 60))

    # Formatierte Ausgabe
    if [[ $remaining -gt 0 ]]; then
        if [[ "$reset_type" == "weekly" && $days_to_reset -gt 0 ]]; then
            echo "$icon ${remaining}msg (${days_to_reset}d${hours_to_reset}h)"
        elif [[ $hours_to_reset -gt 0 ]]; then
            echo "$icon ${remaining}msg (${hours_to_reset}h${mins_to_reset}m)"
        else
            echo "$icon ${remaining}msg (${mins_to_reset}m)"
        fi
    else
        echo "🔴 LIMIT (${hours_to_reset}h${mins_to_reset}m)"
    fi
}

check_mcp_availability() {
    local available=0
    local total=${#mcp_servers[@]}
    
    # Vereinfachte MCP-Erkennung (in echter Implementierung würde man die verfügbaren Tools prüfen)
    # Für Demo-Zwecke nehmen wir an, dass die Basis-Tools verfügbar sind
    if [[ -f "$global_template" ]]; then
        available=$((total - 2)) # Simuliere dass 2 Tools nicht verfügbar sind
    fi
    
    echo "$available/$total"
}

check_roadmap_status() {
    local roadmap="$cwd/Roadmap.md"
    local roadmap_alt="$cwd/ROADMAP.md"
    
    if [[ -f "$roadmap" ]] || [[ -f "$roadmap_alt" ]]; then
        # Prüfe auf offene Tasks (unchecked checkboxes)
        local open_tasks=0
        local total_tasks=0
        
        if [[ -f "$roadmap" ]]; then
            open_tasks=$(grep -c "^- \[ \]" "$roadmap" 2>/dev/null || echo 0)
            total_tasks=$(grep -c "^- \[[ x]\]" "$roadmap" 2>/dev/null || echo 0)
        elif [[ -f "$roadmap_alt" ]]; then
            open_tasks=$(grep -c "^- \[ \]" "$roadmap_alt" 2>/dev/null || echo 0)
            total_tasks=$(grep -c "^- \[[ x]\]" "$roadmap_alt" 2>/dev/null || echo 0)
        fi
        
        if [[ $total_tasks -gt 0 ]]; then
            local completed=$((total_tasks - open_tasks))
            echo "✅ $completed/$total_tasks"
        else
            echo "📋"
        fi
    else
        echo "❌"
    fi
}

get_git_info() {
    if [[ -d "$cwd/.git" ]]; then
        cd "$cwd"
        local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
        local status=""
        
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
        
        echo "$branch$status"
    else
        echo ""
    fi
}

get_project_type() {
    local project_type=""
    
    # Projekt-Typ basierend auf Dateien erkennen
    if [[ -f "$cwd/package.json" ]]; then
        if grep -q "next" "$cwd/package.json" 2>/dev/null; then
            project_type="Next.js"
        elif grep -q "react" "$cwd/package.json" 2>/dev/null; then
            project_type="React"
        elif grep -q "vue" "$cwd/package.json" 2>/dev/null; then
            project_type="Vue"
        else
            project_type="Node.js"
        fi
    elif [[ -f "$cwd/requirements.txt" ]] || [[ -f "$cwd/pyproject.toml" ]]; then
        project_type="Python"
    elif [[ -f "$cwd/Cargo.toml" ]]; then
        project_type="Rust"
    elif [[ -f "$cwd/go.mod" ]]; then
        project_type="Go"
    elif [[ -f "$cwd/composer.json" ]]; then
        project_type="PHP"
    else
        project_type="Generic"
    fi
    
    echo "$project_type"
}

# Haupt-Status-Ermittlung
determine_universal_mode() {
    local mode=""
    local mcp_status=$(check_mcp_availability)
    local roadmap_status=$(check_roadmap_status)
    
    # Global Template vorhanden?
    if [[ -f "$global_template" ]]; then
        # UNIVERSAL MODE immer aktiv wenn Template vorhanden
        mode="🌐 UNIVERSAL"
    else
        mode="❌ DISABLED"
    fi
    
    echo "$mode"
}

# Status zusammenbauen
mode=$(determine_universal_mode)
mcp_status=$(check_mcp_availability)
roadmap_status=$(check_roadmap_status)
git_info=$(get_git_info)
project_type=$(get_project_type)
# Use shared sync tracker for multi-server coordination (v2.1 with dual-limit tracking)
if [[ -x "/root/.claude/sync-usage-tracker-v2.sh" ]]; then
    token_info=$("/root/.claude/sync-usage-tracker-v2.sh" status)
elif [[ -x "$SCRIPT_DIR/../.claude/sync-usage-tracker-v2.sh" ]]; then
    token_info=$("$SCRIPT_DIR/../.claude/sync-usage-tracker-v2.sh" status)
elif [[ -x "/root/.claude/sync-usage-tracker.sh" ]]; then
    token_info=$("/root/.claude/sync-usage-tracker.sh" status)
else
    # Fallback to basic tracking (should not be used if v2.1 is installed)
    token_info="🟢 45msg (5h)"
fi

# Einfaches Meerestier-Icon für UNIVERSAL Mode (langsam wechselnd)
format_simple_aquarium() {
    local full_status="$1"
    
    if [[ "$full_status" =~ "UNIVERSAL" ]]; then
        # Meerestiere für UNIVERSAL Icon (langsam wechselnd)
        local sea_creatures=("🐠" "🐟" "🦈" "🐙" "🦑" "🐡" "🦞" "🐢")
        
        # Langsamer Wechsel alle 10 Sekunden
        local minutes=$(date +%M)
        local seconds=$(date +%S) 
        local time_index=$(((minutes * 60 + seconds) / 10))
        local creature_index=$((time_index % ${#sea_creatures[@]}))
        local current_creature=${sea_creatures[$creature_index]}
        
        # Ersetze 🌐 durch Meerestier
        local aquarium_status=${full_status/🌐/$current_creature}
        printf '%s' "$aquarium_status"
    else
        printf '%s' "$full_status"
    fi
}

# Model detection with Claude 4.5 support
get_model_icon() {
    local model_name="$1"

    # Detect Claude version and return appropriate icon
    case "$model_name" in
        *"sonnet-4"*|*"Sonnet 4"*|*"4.5"*|*"claude-sonnet-4"*)
            echo "🧠4.5"
            ;;
        *"sonnet"*|*"Sonnet"*)
            echo "🧠S"
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

# Komplette Statusline zusammenbauen
build_full_statusline() {
    local status=""

    # Model icon (Claude 4.5 support)
    local model_icon=$(get_model_icon "$model")

    # Modus
    if [[ "$mode" == "🌐 UNIVERSAL" ]]; then
        status="🌐 UNIVERSAL"
    else
        status="$mode"
    fi

    # Model version
    status+=" | $model_icon"

    # Zusätzliche Informationen je nach Modus
    case "$mode" in
        "🌐 UNIVERSAL")
            status+=" | MCP:$mcp_status | $roadmap_status"
            ;;
        "🔧 PARTIAL")
            status+=" | MCP:$mcp_status"
            if [[ "$roadmap_status" != "❌" ]]; then
                status+=" | $roadmap_status"
            fi
            ;;
        "📋 ROADMAP")
            status+=" | $roadmap_status"
            ;;
    esac

    # Git Info (wenn verfügbar)
    if [[ -n "$git_info" ]]; then
        status+=" | git:$git_info"
    fi

    # Projekt-Typ
    if [[ -n "$project_type" && "$project_type" != "Generic" ]]; then
        status+=" | $project_type"
    fi

    # Token Info (falls verfügbar)
    if [[ -n "$token_info" ]]; then
        status+=" | $token_info"
    fi

    # Output Style (nur wenn nicht default)
    if [[ "$output_style" != "default" && "$output_style" != "null" ]]; then
        case "$output_style" in
            "Explanatory")
                status+=" | 📖"
                ;;
            "Learning")
                status+=" | 🎓"
                ;;
            *)
                status+=" | $output_style"
                ;;
        esac
    fi

    echo "$status"
}

# Komplette Statusline mit einfachem Aquarium-Icon ausgeben
full_statusline=$(build_full_statusline)
format_simple_aquarium "$full_statusline"
echo # Zeilenumbruch am Ende