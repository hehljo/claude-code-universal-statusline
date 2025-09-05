# API Reference - Claude Universal Mode

## 🔌 Core API Functions

### `universal-statusline.sh`

Das Hauptskript für die Statusline-Generierung.

#### Input Format:
```json
{
  "workspace": {
    "current_dir": "/path/to/project"
  },
  "model": {
    "display_name": "sonnet",
    "version": "3.5"
  },
  "session_id": "uuid-string",
  "output_style": {
    "name": "explanatory"
  }
}
```

#### Output Format:
```bash
🌐 UNIVERSAL | MCP:6/8 | 12/24 | git:main✓ | Next.js | 🧠S | 📖
```

### `roadmap-detector.sh`

Automatische Roadmap-Erstellung und -Management.

#### Usage:
```bash
# Neue Roadmap erstellen
./scripts/roadmap-detector.sh --create

# Bestehende Roadmap updaten  
./scripts/roadmap-detector.sh --update

# Progress berechnen
./scripts/roadmap-detector.sh --progress
```

## 🛠️ Function Library

### MCP Detection

```bash
detect_mcp_servers() {
    local available=0
    local total=8
    
    for server in filesystem github postgres brave-search puppeteer memory everything sequential-thinking; do
        if check_mcp_server "$server"; then
            ((available++))
        fi
    done
    
    echo "$available/$total"
}

check_mcp_server() {
    local server="$1"
    
    # NPM Global Check
    if npm list -g "@modelcontextprotocol/server-$server" >/dev/null 2>&1; then
        return 0
    fi
    
    # Claude Desktop Config Check
    if grep -q "\"$server\"" ~/.config/claude-desktop/config.json 2>/dev/null; then
        return 0
    fi
    
    return 1
}
```

### Project Type Detection

```bash
detect_project_type() {
    local cwd="$1"
    
    cd "$cwd" || return 1
    
    # JavaScript/TypeScript
    if [ -f "package.json" ]; then
        if jq -e '.dependencies.next' package.json >/dev/null 2>&1; then
            echo "Next.js"
        elif jq -e '.dependencies.react' package.json >/dev/null 2>&1; then
            echo "React"
        elif jq -e '.dependencies.vue' package.json >/dev/null 2>&1; then
            echo "Vue"
        else
            echo "Node.js"
        fi
        return
    fi
    
    # Python
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        echo "Python"
        return
    fi
    
    # Rust
    if [ -f "Cargo.toml" ]; then
        echo "Rust"
        return
    fi
    
    # Go
    if [ -f "go.mod" ]; then
        echo "Go"
        return
    fi
    
    # PHP
    if [ -f "composer.json" ]; then
        echo "PHP"
        return
    fi
    
    echo "Unknown"
}
```

### Git Status Detection

```bash
get_git_status() {
    local cwd="$1"
    
    cd "$cwd" || return 1
    
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "no-git"
        return
    fi
    
    local branch=$(git branch --show-current 2>/dev/null || echo "detached")
    local status_symbol
    
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        if [ -n "$(git diff --cached --name-only 2>/dev/null)" ]; then
            status_symbol="●"  # Staged changes
        else
            status_symbol="○"  # Unstaged changes
        fi
    else
        status_symbol="✓"  # Clean
    fi
    
    echo "git:$branch$status_symbol"
}
```

### Roadmap Progress

```bash
calculate_roadmap_progress() {
    local cwd="$1"
    local roadmap_file="$cwd/Roadmap.md"
    
    if [ ! -f "$roadmap_file" ]; then
        echo "0/0"
        return
    fi
    
    local total=$(grep -c "^- \[" "$roadmap_file" 2>/dev/null || echo 0)
    local completed=$(grep -c "^- \[x\]" "$roadmap_file" 2>/dev/null || echo 0)
    
    echo "$completed/$total"
}
```

### Model Icon Mapping

```bash
get_model_icon() {
    local model="$1"
    
    case "$(echo "$model" | tr '[:upper:]' '[:lower:]')" in
        *"sonnet-4"*|*"sonnet 4"*) echo "🧠4" ;;
        *"sonnet"*) echo "🧠S" ;;
        *"haiku"*) echo "🧠H" ;;
        *"opus"*) echo "🧠O" ;;
        *"claude-3"*) echo "🧠3" ;;
        *) echo "🧠?" ;;
    esac
}
```

### Output Style Icon

```bash
get_output_style_icon() {
    local style="$1"
    
    case "$(echo "$style" | tr '[:upper:]' '[:lower:]')" in
        "explanatory") echo "📖" ;;
        "learning") echo "🎓" ;;
        "concise") echo "⚡" ;;
        "technical") echo "🔧" ;;
        "creative") echo "🎨" ;;
        "default"|"") echo "📝" ;;
        *) echo "❓" ;;
    esac
}
```

## 🎯 Status Mode Logic

```bash
determine_status_mode() {
    local mcp_available="$1"
    local mcp_total="$2"
    local has_local_claude="$3"
    local has_roadmap="$4"
    
    # Parse MCP ratio
    local available=$(echo "$mcp_available" | cut -d'/' -f1)
    local total=$(echo "$mcp_available" | cut -d'/' -f2)
    
    # Universal Mode: 75%+ MCP + Local CLAUDE.md
    if [ "$available" -ge $((total * 3 / 4)) ] && [ "$has_local_claude" = "true" ]; then
        echo "🌐 UNIVERSAL"
        return
    fi
    
    # Partial Mode: 50%+ MCP
    if [ "$available" -ge $((total / 2)) ]; then
        echo "🔧 PARTIAL"
        return
    fi
    
    # Roadmap Only: Has roadmap but limited MCP
    if [ "$has_roadmap" = "true" ]; then
        echo "📋 ROADMAP"
        return
    fi
    
    # Disabled: Minimal functionality
    echo "❌ DISABLED"
}
```

## 🔧 Configuration API

### Settings Structure

```json
{
  "statusline": {
    "enabled": true,
    "update_interval": 2,
    "show_components": {
      "model": true,
      "mcp_status": true,
      "roadmap_progress": true,
      "git_status": true,
      "project_type": true,
      "output_style": true
    },
    "compact_mode": false,
    "custom_icons": {
      "model_sonnet": "🧠S",
      "model_haiku": "🧠H",
      "model_opus": "🧠O"
    }
  }
}
```

### Environment Variables

```bash
# Debug Mode
export DEBUG=1

# Cache Directory  
export CLAUDE_CACHE_DIR="/tmp/claude-statusline"

# Custom MCP Config Path
export MCP_CONFIG_PATH="~/.config/claude-desktop/config.json"

# Roadmap Template
export ROADMAP_TEMPLATE_PATH="/root/.claude/templates/roadmap-template.md"
```

## 📊 Performance Metrics

### Benchmarks

- **Startup Time:** < 100ms
- **MCP Detection:** < 50ms (cached)
- **Git Status:** < 20ms
- **Project Detection:** < 30ms
- **Total Execution:** < 200ms

### Caching Strategy

```bash
# Cache Keys
CACHE_PREFIX="/tmp/claude-statusline"
MCP_CACHE="$CACHE_PREFIX/mcp-status-$(date +%Y%m%d%H%M | sed 's/..$//')0.cache"
PROJECT_CACHE="$CACHE_PREFIX/project-$(pwd | sed 's/\//_/g').cache"

# Cache Lifetime
MCP_CACHE_TTL=300      # 5 minutes
PROJECT_CACHE_TTL=60   # 1 minute
GIT_CACHE_TTL=10       # 10 seconds
```

## 🚀 Extension Points

### Custom Project Types

```bash
# Add to detect_project_type()
add_custom_project_type() {
    local cwd="$1"
    
    # Laravel
    if [ -f "$cwd/artisan" ]; then
        echo "Laravel"
        return
    fi
    
    # Django
    if [ -f "$cwd/manage.py" ]; then
        echo "Django" 
        return
    fi
    
    # Add more...
}
```

### Plugin System

```bash
# Load plugins from directory
load_plugins() {
    local plugin_dir="/root/.claude/statusline-plugins"
    
    if [ -d "$plugin_dir" ]; then
        for plugin in "$plugin_dir"/*.sh; do
            [ -f "$plugin" ] && source "$plugin"
        done
    fi
}
```

Das API ist vollständig dokumentiert und erweiterbar! 🎉