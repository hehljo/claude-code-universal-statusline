# Installation Guide - Claude Universal Mode

## 🚀 Quick Install

```bash
# 1. Klone/Download das Projekt
cd /root/ClaudeUniversalMode

# 2. Mache Scripts ausführbar  
chmod +x scripts/*.sh

# 3. Führe Installation aus
./scripts/install.sh

# 4. Verifiziere Installation
./scripts/universal-statusline.sh --test
```

## 📋 Voraussetzungen

### System Requirements:
- **Linux/macOS/WSL** (Bash-kompatibel)
- **jq** für JSON-Parsing
- **git** für Repository-Erkennung
- **Claude Code** installiert

### Dependency Check:

```bash
# Prüfe ob alle Tools verfügbar sind
command -v jq >/dev/null 2>&1 || echo "❌ jq fehlt: sudo apt install jq"
command -v git >/dev/null 2>&1 || echo "❌ git fehlt: sudo apt install git"
command -v npm >/dev/null 2>&1 || echo "⚠️ npm nicht gefunden (optional)"
```

## 🛠️ Manuelle Installation

### Schritt 1: Basis-Setup

```bash
# Erstelle Verzeichnisstruktur
mkdir -p ~/.config/claude-code/
mkdir -p /root/.claude/

# Kopiere Hauptskript
cp scripts/universal-statusline.sh /root/.claude/
chmod +x /root/.claude/universal-statusline.sh
```

### Schritt 2: Claude Code Konfiguration

```bash
# Erstelle/update Claude Code Config
cat > ~/.config/claude-code/statusline.json << 'EOF'
{
  "command": "/root/.claude/universal-statusline.sh",
  "update_interval": 2,
  "enabled": true
}
EOF
```

### Schritt 3: Global Template

```bash
# Stelle sicher, dass Global Template existiert
if [ ! -f "/root/.claude/CLAUDE_TEMPLATE_GLOBAL.md" ]; then
    echo "⚠️ Erstelle CLAUDE_TEMPLATE_GLOBAL.md..."
    cp config/default-global-template.md /root/.claude/CLAUDE_TEMPLATE_GLOBAL.md
fi
```

## 🔧 MCP Server Setup

### Auto-Detection für verfügbare MCP Server:

```bash
# Prüfe NPM Global Packages
npm list -g --depth=0 2>/dev/null | grep -E "(server-|mcp-)" || echo "Keine MCP Server gefunden"

# Standard MCP Server installieren
npm install -g @modelcontextprotocol/server-filesystem
npm install -g @modelcontextprotocol/server-github  
npm install -g @supabase/mcp-server-supabase
```

### Claude Desktop MCP Config:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem"]
    },
    "github": {
      "command": "npx", 
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your-token"
      }
    }
  }
}
```

## 🧪 Testing

### Basis-Funktionalität testen:

```bash
# Test 1: Script Execution
echo '{"cwd":"/root/test","model":{"display_name":"sonnet"}}' | ./scripts/universal-statusline.sh

# Test 2: MCP Detection  
./scripts/universal-statusline.sh --detect-mcp

# Test 3: Roadmap Generation
cd /path/to/project && /root/.claude/roadmap-detector.sh
```

### Erwartete Ausgabe:

```bash
🌐 UNIVERSAL | MCP:3/8 | 0/0 | git:main✓ | Unknown | 🧠S | 📖
```

## 🔍 Troubleshooting

### Problem: "jq: command not found"

```bash
# Ubuntu/Debian:
sudo apt update && sudo apt install jq

# macOS:
brew install jq

# Alpine Linux:
apk add jq
```

### Problem: MCP Server nicht erkannt

```bash
# Prüfe NPM Installation
npm list -g --depth=0

# Prüfe Claude Desktop Config
cat ~/.config/claude-desktop/config.json

# Debug MCP Detection
DEBUG=1 ./scripts/universal-statusline.sh --detect-mcp
```

### Problem: Git Status nicht angezeigt

```bash
# Prüfe Git Repository
cd /path/to/project
git status

# Prüfe Git Config
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### Problem: Statusline nicht aktualisiert

```bash
# Prüfe Claude Code Config
cat ~/.config/claude-code/statusline.json

# Restart Claude Code
pkill claude-code && claude-code

# Debug Mode
DEBUG=1 /root/.claude/universal-statusline.sh
```

## ⚙️ Erweiterte Konfiguration

### Custom Project Types:

```bash
# In universal-statusline.sh erweitern
detect_project_type() {
    if [ -f "Cargo.toml" ]; then echo "Rust"
    elif [ -f "go.mod" ]; then echo "Go" 
    elif [ -f "requirements.txt" ]; then echo "Python"
    elif [ -f "composer.json" ]; then echo "PHP"
    # ... weitere Types
    fi
}
```

### Performance Optimierung:

```bash
# Cache für teure Operationen
cache_dir="/tmp/claude-statusline-cache"
mkdir -p "$cache_dir"

# MCP Detection cachen (30 Sekunden)
cache_file="$cache_dir/mcp-status-$(date +%Y%m%d%H%M | sed 's/..$//').cache"
```

## ✅ Verifikation

Nach erfolgreicher Installation sollten Sie sehen:

1. **Statusline aktiv** - Claude Code zeigt Universal Mode Status
2. **MCP Detection** - Verfügbare Server werden erkannt  
3. **Auto-Roadmap** - Neue Projekte erhalten automatisch Roadmap.md
4. **Progress Tracking** - Tasks werden automatisch getrackt

Installation erfolgreich! 🎉