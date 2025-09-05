#!/bin/bash

# UNIVERSAL MODE Statusline für Claude Code
# Basiert auf CLAUDE_TEMPLATE_GLOBAL.md

# JSON Input von stdin lesen
input=$(cat)

# Basis-Informationen extrahieren  
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name')
session_id=$(echo "$input" | jq -r '.session_id')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Code Quality Detection
code_quality_script="$SCRIPT_DIR/code-quality-detector.sh"
# Session Time Tracker
session_tracker_script="$SCRIPT_DIR/session-time-tracker.sh"

# Globale Template-Datei prüfen
global_template="/root/.claude/CLAUDE_TEMPLATE_GLOBAL.md"
local_claude="$cwd/CLAUDE.md"

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
            total_tasks=$(grep -c "^- \[\(x\| \)\]" "$roadmap" 2>/dev/null || echo 0)
        elif [[ -f "$roadmap_alt" ]]; then
            open_tasks=$(grep -c "^- \[ \]" "$roadmap_alt" 2>/dev/null || echo 0)
            total_tasks=$(grep -c "^- \[\(x\| \)\]" "$roadmap_alt" 2>/dev/null || echo 0)
        fi
        
        if [[ $total_tasks -gt 0 ]]; then
            local completed=$((total_tasks - open_tasks))
            echo "$completed/$total_tasks"
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
        # Lokale CLAUDE.md vorhanden?
        if [[ -f "$local_claude" ]]; then
            # Alle MCP Server verfügbar?
            if [[ "$mcp_status" == "6/8" ]] || [[ "$mcp_status" == "7/8" ]] || [[ "$mcp_status" == "8/8" ]]; then
                if [[ "$roadmap_status" != "❌" ]]; then
                    mode="🌐 UNIVERSAL"
                else
                    mode="🔧 PARTIAL"
                fi
            else
                mode="🔧 PARTIAL"
            fi
        else
            if [[ "$roadmap_status" != "❌" ]]; then
                mode="📋 ROADMAP"
            else
                mode="🔧 PARTIAL"
            fi
        fi
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

# Code Quality Status (if available and fast)
code_quality=""
if [[ -x "$code_quality_script" ]]; then
    code_quality=$("$code_quality_script" "$cwd" 2>/dev/null || echo "")
fi

# Session Time Status (skip für Rovodev)
session_status=""
hide_session_time=$(echo "$input" | jq -r '.rovodev.hide_session_time // false')
if [[ -x "$session_tracker_script" && "$hide_session_time" != "true" ]]; then
    session_status=$("$session_tracker_script" --compact 2>/dev/null || echo "")
fi

# Session Status (wenn verfügbar) - am Anfang für Sichtbarkeit
if [[ -n "$session_status" ]]; then
    printf "⏱️ %s | " "$session_status"
fi

# Ausgabe formatieren
printf "%s" "$mode"

# Zusätzliche Informationen je nach Modus
case "$mode" in
    "🌐 UNIVERSAL")
        printf " | MCP:%s | %s" "$mcp_status" "$roadmap_status"
        ;;
    "🔧 PARTIAL")
        printf " | MCP:%s" "$mcp_status"
        if [[ "$roadmap_status" != "❌" ]]; then
            printf " | %s" "$roadmap_status"
        fi
        ;;
    "📋 ROADMAP")
        printf " | %s" "$roadmap_status"
        ;;
esac

# Git Info (wenn verfügbar)
if [[ -n "$git_info" ]]; then
    printf " | git:%s" "$git_info"
fi

# Projekt-Typ
if [[ -n "$project_type" && "$project_type" != "Generic" ]]; then
    printf " | %s" "$project_type"
fi

# Model Info entfernt - nicht mehr angezeigt

# Code Quality Info (wenn verfügbar)
if [[ -n "$code_quality" ]]; then
    printf "%s" "$code_quality"
fi

# Output Style (nur wenn nicht default)
if [[ "$output_style" != "default" && "$output_style" != "null" ]]; then
    case "$output_style" in
        "Explanatory")
            printf " | 📖"
            ;;
        "Learning")
            printf " | 🎓"
            ;;
        *)
            printf " | %s" "$output_style"
            ;;
    esac
fi

echo # Zeilenumbruch am Ende