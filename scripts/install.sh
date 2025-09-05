#!/bin/bash

# Claude Universal Mode - Installation Script
# Automatische Installation und Konfiguration

set -e

echo "🌐 Claude Universal Mode - Installation"
echo "======================================"

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper Functions
log_info() { echo -e "${GREEN}ℹ️  $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Check Dependencies
check_dependencies() {
    log_info "Prüfe Abhängigkeiten..."
    
    local missing_deps=()
    
    # Essential tools
    command -v jq >/dev/null 2>&1 || missing_deps+=("jq")
    command -v git >/dev/null 2>&1 || missing_deps+=("git")
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Fehlende Abhängigkeiten: ${missing_deps[*]}"
        echo "Installiere diese mit:"
        echo "  Ubuntu/Debian: sudo apt install ${missing_deps[*]}"
        echo "  macOS: brew install ${missing_deps[*]}"
        exit 1
    fi
    
    log_info "✅ Alle Abhängigkeiten verfügbar"
}

# Create Directory Structure
setup_directories() {
    log_info "Erstelle Verzeichnisstruktur..."
    
    mkdir -p ~/.config/claude-code/
    mkdir -p /root/.claude/
    mkdir -p /tmp/claude-statusline-cache/
    
    log_info "✅ Verzeichnisse erstellt"
}

# Install Main Scripts
install_scripts() {
    log_info "Installiere Hauptskripte..."
    
    # Copy main statusline script
    cp scripts/universal-statusline.sh /root/.claude/
    chmod +x /root/.claude/universal-statusline.sh
    
    # Copy roadmap detector
    cp scripts/roadmap-detector.sh /root/.claude/
    chmod +x /root/.claude/roadmap-detector.sh
    
    log_info "✅ Skripte installiert"
}

# Setup Claude Code Configuration
setup_claude_config() {
    log_info "Konfiguriere Claude Code..."
    
    local config_file="$HOME/.config/claude-code/statusline.json"
    
    if [ -f "$config_file" ]; then
        log_warn "Existierende Konfiguration gefunden - erstelle Backup"
        cp "$config_file" "$config_file.backup.$(date +%Y%m%d%H%M%S)"
    fi
    
    cat > "$config_file" << 'EOF'
{
  "command": "/root/.claude/universal-statusline.sh",
  "update_interval": 2,
  "enabled": true
}
EOF
    
    log_info "✅ Claude Code konfiguriert"
}

# Setup Global Template
setup_global_template() {
    log_info "Setup Global Template..."
    
    local template_file="/root/.claude/CLAUDE_TEMPLATE_GLOBAL.md"
    
    if [ ! -f "$template_file" ]; then
        log_warn "CLAUDE_TEMPLATE_GLOBAL.md nicht gefunden - erstelle Standard-Template"
        
        cat > "$template_file" << 'EOF'
# CLAUDE.md - GLOBALE VORLAGE 2025

This file provides guidance to Claude Code (claude.ai/code) when working with code repositories.

## 🔥 KRITISCHE ANWEISUNGEN

- **SPRACHE:** Schreibe ALLES auf Deutsch - Antworten, Kommentare, Dokumentation
- **AUTO-COMPACT:** Verwende IMMER auto-compact für alle Antworten - kurz und präzise
- **KEINE AUTOMATISCHEN DATEIEN:** Erstelle NIE automatisch README.md, CHANGELOG.md oder andere .md Dateien
- **SECURITY FIRST:** Führe bei JEDEM Code-Change automatische Sicherheitschecks durch
- **FILE VALIDATION:** Prüfe IMMER Dateipfade und -existenz vor Edits mit Read-Tool

## 🛠 GLOBALE MCP TOOLS & AGENTS

### Verfügbare MCP Server
- **filesystem:** Erweiterte Dateisystem-Operationen
- **github:** Repository-Management und GitHub-Integration  
- **postgres:** Direkte PostgreSQL-Operationen
- **brave-search:** Web-Recherche für aktuelle Informationen
- **puppeteer:** Browser-Automation für E2E-Testing
- **memory:** Persistente Wissensspeicherung zwischen Sessions
- **everything:** Referenz-Server für Testing und Development
- **sequential-thinking:** Komplexe Problem-Lösung durch strukturiertes Denken

### Verfügbare Claude Agents
- **SecurityAuditor:** Security-Scans und DSGVO-Compliance
- **BackendArchitect:** Server-Architektur und API-Design
- **DocumentationAutomator:** Automatische Dokumentation
- **TestAutomationEngineer:** Test-Strategien und -Implementierung
- **FrontendSpecialist:** UI/UX und Frontend-Optimierung
EOF
        
        log_info "✅ Standard Global Template erstellt"
    else
        log_info "✅ Existierendes Global Template gefunden"
    fi
}

# Test Installation
test_installation() {
    log_info "Teste Installation..."
    
    # Test statusline script
    local test_input='{"workspace":{"current_dir":"/root"},"model":{"display_name":"sonnet"},"output_style":{"name":"explanatory"}}'
    
    if echo "$test_input" | /root/.claude/universal-statusline.sh >/dev/null 2>&1; then
        log_info "✅ Statusline Script funktioniert"
    else
        log_error "Statusline Script Test fehlgeschlagen"
        return 1
    fi
    
    # Test MCP detection
    if /root/.claude/universal-statusline.sh --detect-mcp >/dev/null 2>&1; then
        log_info "✅ MCP Detection funktioniert"
    else
        log_warn "MCP Detection Test fehlgeschlagen (möglicherweise keine MCP Server installiert)"
    fi
    
    log_info "✅ Installation erfolgreich getestet"
}

# Show MCP Status
show_mcp_status() {
    log_info "MCP Server Status:"
    
    local mcp_servers=("filesystem" "github" "postgres" "brave-search" "puppeteer" "memory" "everything" "sequential-thinking")
    local available=0
    
    for server in "${mcp_servers[@]}"; do
        if npm list -g "@modelcontextprotocol/server-$server" >/dev/null 2>&1; then
            echo -e "  ✅ $server"
            ((available++))
        else
            echo -e "  ❌ $server"
        fi
    done
    
    echo -e "Verfügbar: $available/${#mcp_servers[@]}"
    
    if [ $available -eq 0 ]; then
        log_warn "Keine MCP Server gefunden - installiere sie mit:"
        echo "  npm install -g @modelcontextprotocol/server-filesystem"
        echo "  npm install -g @modelcontextprotocol/server-github"
        echo "  # etc..."
    fi
}

# Main Installation Flow
main() {
    echo "Starte Installation..."
    echo
    
    check_dependencies
    setup_directories  
    install_scripts
    setup_claude_config
    setup_global_template
    test_installation
    
    echo
    log_info "🎉 Installation erfolgreich abgeschlossen!"
    echo
    
    echo "📊 System Status:"
    show_mcp_status
    
    echo
    echo "🚀 Next Steps:"
    echo "1. Restart Claude Code um die neue Statusline zu aktivieren"
    echo "2. Installiere MCP Server für erweiterte Funktionalität"  
    echo "3. Teste die Statusline in einem Projekt-Ordner"
    echo
    
    echo "📖 Dokumentation:"
    echo "- Vollständige Anleitung: docs/UNIVERSAL_MODE_README.md"
    echo "- Statusline Guide: docs/STATUSLINE_GUIDE.md"
    echo "- API Referenz: docs/API.md"
    echo
    
    log_info "Universal Mode ist bereit! 🌐"
}

# Run installation
main "$@"