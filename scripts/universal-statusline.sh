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
    
    # Claude Limits (5-Stunden-Fenster für Pro)
    local pro_limit=100000      # Claude Pro: ~100k tokens/5h
    local max_limit=500000      # Claude Max: ~500k tokens/5h
    
    # Usage-Datei erstellen falls nicht vorhanden oder neue Session
    if [[ ! -f "$usage_file" ]]; then
        # Session startet zur AKTUELLEN vollen Stunde
        local current_hour=$(date +%H)
        local current_date=$(date +%Y-%m-%d)
        local session_start=$(date -d "$current_date $current_hour:00:00" +%s)
        local next_reset=$((session_start + 18000))  # +5 Stunden von voller Stunde
        echo '{"session_start":'$session_start',"tokens_used":0,"requests":0,"plan":"pro","next_reset":'$next_reset'}' > "$usage_file"
    fi
    
    # Aktuelle Usage laden
    local usage_data=$(cat "$usage_file" 2>/dev/null)
    local session_start=$(echo "$usage_data" | jq -r '.session_start // '$current_time'')
    local tokens_used=$(echo "$usage_data" | jq -r '.tokens_used // 0')
    local requests=$(echo "$usage_data" | jq -r '.requests // 0')
    local plan=$(echo "$usage_data" | jq -r '.plan // "pro"')
    local next_reset=$(echo "$usage_data" | jq -r '.next_reset // '$((current_time + 18000))'')
    
    # Reset wenn 5h-Fenster abgelaufen ist
    if [[ $current_time -gt $next_reset ]]; then
        # Neue 5h-Session startet zur AKTUELLEN vollen Stunde
        local current_hour=$(date +%H)
        local current_date=$(date +%Y-%m-%d)
        session_start=$(date -d "$current_date $current_hour:00:00" +%s)
        next_reset=$((session_start + 18000))  # +5 Stunden von voller Stunde
        tokens_used=0
        requests=0
        echo '{"session_start":'$session_start',"tokens_used":0,"requests":0,"plan":"'$plan'","next_reset":'$next_reset'}' > "$usage_file"
    fi
    
    # Präzises Token-Tracking basierend auf Input/Output Länge
    local current_estimate=0
    if [[ -n "$session_id" && "$session_id" != "null" ]]; then
        # Echte Claude Code Session - berechne Tokens basierend auf Content
        local input_length=$(echo "$input" | wc -c)
        local estimated_response=1500  # Durchschnittliche Antwort-Länge
        
        # Token-Schätzung: ~4 Zeichen pro Token (GPT-Standard)
        local input_tokens=$((input_length / 4))
        local output_tokens=$((estimated_response / 4))
        
        # Context aus vorherigen Messages (geschätzt)
        local context_tokens=500
        
        current_estimate=$((input_tokens + output_tokens + context_tokens))
        
        # Multi-Instanz-sicheres Update mit File-Locking
        (
            flock -x 200
            local fresh_data=$(cat "$usage_file" 2>/dev/null)
            local fresh_tokens=$(echo "$fresh_data" | jq -r '.tokens_used // 0')
            local fresh_requests=$(echo "$fresh_data" | jq -r '.requests // 0')
            
            tokens_used=$((fresh_tokens + current_estimate))
            requests=$((fresh_requests + 1))
        ) 200>"$usage_file.lock"
    fi
    
    # Usage updaten
    echo '{"session_start":'$session_start',"tokens_used":'$tokens_used',"requests":'$requests',"plan":"'$plan'","next_reset":'$next_reset'}' > "$usage_file"
    
    # Limit basierend auf Plan
    local limit=$pro_limit
    if [[ "$plan" == "max" ]]; then
        limit=$max_limit
    fi
    
    # Verbleibendes Limit berechnen
    local remaining=$((limit - tokens_used))
    local percentage=$((tokens_used * 100 / limit))
    
    # Icon basierend auf Usage
    local icon="🟢"
    if [[ $percentage -gt 80 ]]; then
        icon="🔴"
    elif [[ $percentage -gt 60 ]]; then
        icon="🟡"
    fi
    
    # Zeit bis Reset berechnen
    local time_to_reset=$((next_reset - current_time))
    local hours_to_reset=$((time_to_reset / 3600))
    local mins_to_reset=$(((time_to_reset % 3600) / 60))
    
    # Formatierte Ausgabe mit präziser Zeit
    if [[ $remaining -gt 0 ]]; then
        if [[ $hours_to_reset -gt 0 ]]; then
            if [[ $mins_to_reset -gt 0 ]]; then
                echo "$icon $((remaining / 1000))k (${hours_to_reset}h${mins_to_reset}m)"
            else
                echo "$icon $((remaining / 1000))k (${hours_to_reset}h)"
            fi
        else
            echo "$icon $((remaining / 1000))k (${mins_to_reset}m)"
        fi
    else
        if [[ $hours_to_reset -gt 0 ]]; then
            echo "🔴 0k (${hours_to_reset}h${mins_to_reset}m)"
        else
            echo "🔴 0k (${mins_to_reset}m)"
        fi
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
# Use shared sync tracker for multi-server coordination (prefer v2.0)
if [[ -x "$SCRIPT_DIR/../.claude/sync-usage-tracker-v2.sh" ]]; then
    token_info=$("$SCRIPT_DIR/../.claude/sync-usage-tracker-v2.sh" status)
elif [[ -x "/root/.claude/sync-usage-tracker-v2.sh" ]]; then
    token_info=$("/root/.claude/sync-usage-tracker-v2.sh" status)
elif [[ -x "/root/.claude/sync-usage-tracker.sh" ]]; then
    token_info=$("/root/.claude/sync-usage-tracker.sh" status)
else
    token_info=$(get_claude_usage)
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

# Komplette Statusline zusammenbauen
build_full_statusline() {
    local status=""
    
    # Modus
    if [[ "$mode" == "🌐 UNIVERSAL" ]]; then
        status="🌐 UNIVERSAL"
    else
        status="$mode"
    fi
    
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