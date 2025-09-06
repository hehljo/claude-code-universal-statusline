#!/bin/bash
#
# Usage Structure Upgrade Script
# Erweitert die usage-tracking.json Struktur für besseres Multi-Server Token-Tracking
#

SHARED_FILE="/mnt/fileshare/claude-sync/usage-tracking.json"
LOCAL_FILE="/root/.claude/usage-tracking.json"
BACKUP_DIR="/root/.claude/backups"
LOG_FILE="/root/.claude/upgrade.log"

# Backup erstellen
create_backup() {
    local file="$1"
    local backup_name="$2"
    
    mkdir -p "$BACKUP_DIR"
    if [[ -f "$file" ]]; then
        cp "$file" "$BACKUP_DIR/${backup_name}_$(date +%Y%m%d_%H%M%S).json"
        echo "$(date '+%Y-%m-%d %H:%M:%S') Backup created: $BACKUP_DIR/${backup_name}_$(date +%Y%m%d_%H%M%S).json" >> "$LOG_FILE"
    fi
}

# Neue erweiterte Struktur erstellen
create_enhanced_structure() {
    local current_time=$(date +%s)
    local current_hour=$(date +%H)
    local current_date=$(date +%Y-%m-%d)
    local session_start=$(date -d "$current_date $current_hour:00:00" +%s)
    local next_reset=$((session_start + 18000))  # +5 Stunden
    
    # Server ID bestimmen
    local server_id=$(hostname || echo "unknown")
    if [[ "$server_id" =~ lxc ]]; then
        server_id="LXC115"
    else
        server_id="MAIN"
    fi
    
    # Erweiterte JSON-Struktur
    cat << EOF
{
  "version": "2.0",
  "last_updated": $current_time,
  "session_management": {
    "current_session": {
      "session_start": $session_start,
      "next_reset": $next_reset,
      "duration_seconds": 18000
    },
    "reset_history": []
  },
  "plan_configuration": {
    "current_plan": "pro",
    "limits": {
      "pro": {
        "total_tokens": 100000,
        "window_hours": 5,
        "description": "Claude Pro: 100k tokens per 5h window"
      },
      "max": {
        "total_tokens": 500000,
        "window_hours": 5,
        "description": "Claude Max: 500k tokens per 5h window"
      }
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
    },
    "session_history": [],
    "daily_stats": {}
  },
  "server_tracking": {
    "last_active_server": "$server_id",
    "servers": {
      "$server_id": {
        "last_active": $current_time,
        "session_requests": 0,
        "session_tokens": {
          "total": 0,
          "input": 0,
          "output": 0
        },
        "lifetime_stats": {
          "total_sessions": 1,
          "total_requests": 0,
          "total_tokens": 0,
          "first_seen": $current_time,
          "last_seen": $current_time
        }
      }
    }
  },
  "metadata": {
    "created": $current_time,
    "created_by": "$server_id",
    "upgrade_history": [
      {
        "timestamp": $current_time,
        "version": "2.0",
        "server": "$server_id",
        "action": "structure_upgrade"
      }
    ]
  }
}
EOF
}

# Bestehende Daten migrieren
migrate_existing_data() {
    local old_file="$1"
    local new_structure="$2"
    
    if [[ ! -f "$old_file" ]]; then
        echo "$new_structure"
        return
    fi
    
    # Alte Daten extrahieren
    local old_session_start=$(jq -r '.session_start // null' "$old_file")
    local old_tokens_used=$(jq -r '.tokens_used // 0' "$old_file")
    local old_requests=$(jq -r '.requests // 0' "$old_file")
    local old_plan=$(jq -r '.plan // "pro"' "$old_file")
    local old_next_reset=$(jq -r '.next_reset // null' "$old_file")
    local old_last_server=$(jq -r '.last_server // "MAIN"' "$old_file")
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') Migrating data - tokens: $old_tokens_used, requests: $old_requests, plan: $old_plan" >> "$LOG_FILE"
    
    # Neue Struktur mit migrierten Daten
    echo "$new_structure" | jq \
        --argjson session_start "${old_session_start:-null}" \
        --argjson tokens_used "$old_tokens_used" \
        --argjson requests "$old_requests" \
        --arg plan "$old_plan" \
        --argjson next_reset "${old_next_reset:-null}" \
        --arg last_server "$old_last_server" \
        '
        # Migration der alten Daten
        if $session_start then .session_management.current_session.session_start = $session_start else . end |
        if $next_reset then .session_management.current_session.next_reset = $next_reset else . end |
        .plan_configuration.current_plan = $plan |
        .token_usage.current_window.total_tokens = $tokens_used |
        .token_usage.current_window.total_requests = $requests |
        .server_tracking.last_active_server = $last_server |
        
        # Server-spezifische Daten setzen
        .server_tracking.servers[$last_server].session_requests = $requests |
        .server_tracking.servers[$last_server].session_tokens.total = $tokens_used |
        .server_tracking.servers[$last_server].lifetime_stats.total_requests = $requests |
        .server_tracking.servers[$last_server].lifetime_stats.total_tokens = $tokens_used
        '
}

# Hauptfunktion für Upgrade
upgrade_structure() {
    local target_file="$1"
    local backup_name="$2"
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') Starting upgrade for: $target_file" >> "$LOG_FILE"
    
    # Backup erstellen
    create_backup "$target_file" "$backup_name"
    
    # Neue Struktur generieren
    local new_structure=$(create_enhanced_structure)
    
    # Bestehende Daten migrieren
    local migrated_data=$(migrate_existing_data "$target_file" "$new_structure")
    
    # Neue Datei schreiben
    echo "$migrated_data" > "$target_file"
    
    # Validierung
    if jq empty "$target_file" 2>/dev/null; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') Upgrade successful: $target_file" >> "$LOG_FILE"
        echo "✅ Upgrade successful: $target_file"
        return 0
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') Upgrade failed: Invalid JSON in $target_file" >> "$LOG_FILE"
        echo "❌ Upgrade failed: Invalid JSON generated"
        
        # Restore backup
        local latest_backup=$(ls -t "$BACKUP_DIR/${backup_name}"_*.json 2>/dev/null | head -1)
        if [[ -f "$latest_backup" ]]; then
            cp "$latest_backup" "$target_file"
            echo "🔄 Restored from backup: $latest_backup"
        fi
        return 1
    fi
}

# Status anzeigen
show_status() {
    local file="$1"
    echo "=== Usage Tracking Status: $(basename "$file") ==="
    
    if [[ -f "$file" ]]; then
        local version=$(jq -r '.version // "1.0"' "$file" 2>/dev/null)
        local total_tokens=$(jq -r '.token_usage.current_window.total_tokens // .tokens_used // 0' "$file" 2>/dev/null)
        local plan=$(jq -r '.plan_configuration.current_plan // .plan // "unknown"' "$file" 2>/dev/null)
        local servers=$(jq -r '.server_tracking.servers // .servers // {} | keys | length' "$file" 2>/dev/null)
        
        echo "Version: $version"
        echo "Current tokens used: $total_tokens"
        echo "Plan: $plan"  
        echo "Tracked servers: $servers"
        echo "File size: $(wc -c < "$file") bytes"
    else
        echo "File not found: $file"
    fi
    echo ""
}

# Hauptausführung
main() {
    case "${1:-upgrade}" in
        "upgrade")
            echo "🔄 Starting Usage Tracking Structure Upgrade..."
            echo ""
            
            # Shared file upgraden (falls verfügbar)
            if [[ -d "/mnt/fileshare/claude-sync" ]]; then
                echo "📁 Upgrading shared file..."
                upgrade_structure "$SHARED_FILE" "shared"
                show_status "$SHARED_FILE"
            fi
            
            # Local file upgraden
            echo "📁 Upgrading local file..."
            upgrade_structure "$LOCAL_FILE" "local"
            show_status "$LOCAL_FILE"
            
            echo "✅ Upgrade process completed!"
            echo "📋 Check logs: $LOG_FILE"
            ;;
        "status")
            if [[ -d "/mnt/fileshare/claude-sync" ]]; then
                show_status "$SHARED_FILE"
            fi
            show_status "$LOCAL_FILE"
            ;;
        "backup")
            create_backup "$SHARED_FILE" "shared"
            create_backup "$LOCAL_FILE" "local"
            echo "✅ Backups created in $BACKUP_DIR"
            ;;
        *)
            echo "Usage: $0 [upgrade|status|backup]"
            echo ""
            echo "Commands:"
            echo "  upgrade  - Upgrade usage tracking structure to v2.0"
            echo "  status   - Show current status of tracking files"
            echo "  backup   - Create manual backup of tracking files"
            ;;
    esac
}

# Script ausführen
main "$@"