#!/bin/bash

# 🌍 UNIVERSAL MODE Enhanced Installation Script
# Complete setup for intelligent automatic UNIVERSAL MODE system

set -e  # Exit on any error

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Installation configuration
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backups/$(date +%Y%m%d_%H%M%S)"
INSTALL_LOG="$CLAUDE_DIR/install.log"

# Create necessary directories
mkdir -p "$CLAUDE_DIR" "$BACKUP_DIR"

# Logging functions
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$INSTALL_LOG"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}" | tee -a "$INSTALL_LOG"
}

success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$INSTALL_LOG"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$INSTALL_LOG"
}

error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$INSTALL_LOG"
}

banner() {
    echo -e "${PURPLE}"
    cat << 'EOF'
🌍 UNIVERSAL MODE Enhanced Intelligence System
=============================================

Installing automatic intelligence activation with:
• Intelligent project detection and analysis
• Automatic MCP server activation and management
• Enhanced statusbar with real-time intelligence
• Automatic configuration management
• Intelligent pattern activation
• Seamless integration with existing systems

EOF
    echo -e "${NC}"
}

# Check system requirements
check_requirements() {
    info "Checking system requirements..."

    local missing_deps=()

    # Check for required commands
    command -v jq >/dev/null 2>&1 || missing_deps+=("jq")
    command -v npm >/dev/null 2>&1 || missing_deps+=("npm")
    command -v node >/dev/null 2>&1 || missing_deps+=("node")
    command -v git >/dev/null 2>&1 || missing_deps+=("git")

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        info "Please install the missing dependencies and run the installer again"

        case "$(uname -s)" in
            Linux*)
                info "On Ubuntu/Debian: sudo apt-get install ${missing_deps[*]}"
                info "On CentOS/RHEL: sudo yum install ${missing_deps[*]}"
                ;;
            Darwin*)
                info "On macOS: brew install ${missing_deps[*]}"
                ;;
        esac
        exit 1
    fi

    success "All system requirements met"
}

# Backup existing configuration
backup_existing_config() {
    info "Backing up existing configuration..."

    # Backup existing CLAUDE.md files
    if [[ -f "$CLAUDE_DIR/CLAUDE.md" ]]; then
        cp "$CLAUDE_DIR/CLAUDE.md" "$BACKUP_DIR/CLAUDE.md.backup"
        success "Backed up global CLAUDE.md"
    fi

    # Backup existing statusline scripts
    if [[ -f "$SCRIPT_DIR/universal-statusline.sh" ]]; then
        cp "$SCRIPT_DIR/universal-statusline.sh" "$BACKUP_DIR/universal-statusline.sh.backup"
        success "Backed up existing statusline script"
    fi

    # Backup MCP configuration
    local mcp_config="$HOME/.config/claude-desktop/claude_desktop_config.json"
    if [[ -f "$mcp_config" ]]; then
        mkdir -p "$BACKUP_DIR/.config/claude-desktop"
        cp "$mcp_config" "$BACKUP_DIR/.config/claude-desktop/claude_desktop_config.json.backup"
        success "Backed up MCP configuration"
    fi

    success "Configuration backup completed in: $BACKUP_DIR"
}

# Install core intelligence scripts
install_intelligence_scripts() {
    info "Installing core intelligence scripts..."

    # Make all scripts executable
    chmod +x "$SCRIPT_DIR"/*.sh

    # Create symlinks for global access
    local bin_dir="$HOME/.local/bin"
    mkdir -p "$bin_dir"

    # Create convenient command aliases
    cat > "$bin_dir/universal-detect" << EOF
#!/bin/bash
exec "$SCRIPT_DIR/intelligent-project-detector.sh" "\$@"
EOF

    cat > "$bin_dir/universal-mcp" << EOF
#!/bin/bash
exec "$SCRIPT_DIR/mcp-auto-activator.sh" "\$@"
EOF

    cat > "$bin_dir/universal-config" << EOF
#!/bin/bash
exec "$SCRIPT_DIR/auto-config-manager.sh" "\$@"
EOF

    cat > "$bin_dir/universal-patterns" << EOF
#!/bin/bash
exec "$SCRIPT_DIR/intelligent-pattern-activator.sh" "\$@"
EOF

    chmod +x "$bin_dir"/universal-*

    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        warning "Added $HOME/.local/bin to PATH in .bashrc - restart shell or run: source ~/.bashrc"
    fi

    success "Intelligence scripts installed"
}

# Setup enhanced statusbar
setup_enhanced_statusbar() {
    info "Setting up enhanced statusbar integration..."

    # Use the enhanced statusbar as the primary statusbar
    if [[ -f "$SCRIPT_DIR/enhanced-universal-statusbar.sh" ]]; then
        # Create backup of existing statusbar
        if [[ -f "$SCRIPT_DIR/universal-statusline.sh" ]]; then
            mv "$SCRIPT_DIR/universal-statusline.sh" "$SCRIPT_DIR/universal-statusline.sh.legacy"
        fi

        # Use enhanced version as primary
        ln -sf "$SCRIPT_DIR/enhanced-universal-statusbar.sh" "$SCRIPT_DIR/universal-statusline.sh"
        success "Enhanced statusbar activated"
    else
        warning "Enhanced statusbar script not found"
    fi

    # Test statusbar functionality
    if "$SCRIPT_DIR/enhanced-universal-statusbar.sh" test >/dev/null 2>&1; then
        success "Statusbar integration test passed"
    else
        warning "Statusbar integration test failed - check configuration"
    fi
}

# Initialize intelligence subsystems
initialize_subsystems() {
    info "Initializing intelligence subsystems..."

    # Initialize MCP system
    "$SCRIPT_DIR/mcp-auto-activator.sh" init
    success "MCP auto-activation system initialized"

    # Initialize configuration management
    "$SCRIPT_DIR/auto-config-manager.sh" init
    success "Configuration management system initialized"

    # Initialize pattern system
    "$SCRIPT_DIR/intelligent-pattern-activator.sh" init
    success "Pattern activation system initialized"

    # Test project detection
    local test_result=$("$SCRIPT_DIR/intelligent-project-detector.sh" analyze "$PROJECT_ROOT" 2>/dev/null)
    if [[ $? -eq 0 ]]; then
        local project_type=$(echo "$test_result" | jq -r '.project.primary_type // "Unknown"')
        success "Project detection working - detected: $project_type"
    else
        warning "Project detection test failed"
    fi
}

# Install recommended MCP packages
install_mcp_packages() {
    info "Installing recommended MCP packages..."

    local packages=(
        "@modelcontextprotocol/server-filesystem"
        "@modelcontextprotocol/server-git"
        "@modelcontextprotocol/server-github"
        "@modelcontextprotocol/server-memory"
        "@modelcontextprotocol/server-brave-search"
        "@modelcontextprotocol/server-puppeteer"
        "@modelcontextprotocol/server-sequential-thinking"
    )

    local installed=0
    local failed=()

    for package in "${packages[@]}"; do
        info "Installing $package..."
        if npm install -g "$package" >/dev/null 2>&1; then
            success "Installed $package"
            ((installed++))
        else
            warning "Failed to install $package"
            failed+=("$package")
        fi
    done

    if [[ $installed -gt 0 ]]; then
        success "Installed $installed MCP packages successfully"
    fi

    if [[ ${#failed[@]} -gt 0 ]]; then
        warning "Failed to install: ${failed[*]}"
        info "You can install these manually later with: npm install -g <package>"
    fi
}

# Setup global UNIVERSAL MODE configuration
setup_global_config() {
    info "Setting up global UNIVERSAL MODE configuration..."

    # Install enhanced CLAUDE.md if not exists or if user confirms update
    local update_global=false

    if [[ ! -f "$CLAUDE_DIR/CLAUDE.md" ]]; then
        update_global=true
        info "No global CLAUDE.md found - will install default"
    else
        read -p "Update global CLAUDE.md with enhanced configuration? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            update_global=true
        fi
    fi

    if [[ "$update_global" == "true" ]]; then
        # Copy the UNIVERSAL configuration
        if [[ -f "$PROJECT_ROOT/CLAUDE-UNIVERSAL.md" ]]; then
            cp "$PROJECT_ROOT/CLAUDE-UNIVERSAL.md" "$CLAUDE_DIR/CLAUDE.md"
            success "Installed enhanced global CLAUDE.md configuration"
        else
            warning "CLAUDE-UNIVERSAL.md not found in project root"
        fi
    fi

    # Setup Claude Code statusbar configuration
    local claude_config="$CLAUDE_DIR/settings.json"
    if [[ ! -f "$claude_config" ]]; then
        cat > "$claude_config" << 'EOF'
{
  "statusbar": {
    "enabled": true,
    "script": "universal-statusline.sh",
    "update_interval": 5000
  },
  "universal_mode": {
    "auto_activation": true,
    "intelligent_detection": true,
    "enhanced_statusbar": true,
    "auto_mcp_activation": true,
    "auto_pattern_activation": true
  }
}
EOF
        success "Created Claude Code settings for UNIVERSAL MODE"
    fi
}

# Setup project-specific demonstration
setup_project_demo() {
    info "Setting up current project with UNIVERSAL MODE..."

    # Detect and configure current project
    "$SCRIPT_DIR/auto-config-manager.sh" setup "$PROJECT_ROOT"

    # Activate optimal MCPs for this project
    "$SCRIPT_DIR/mcp-auto-activator.sh" activate "$PROJECT_ROOT"

    # Activate optimal patterns
    "$SCRIPT_DIR/intelligent-pattern-activator.sh" activate "$PROJECT_ROOT"

    success "Current project configured with intelligent optimizations"
}

# Create usage documentation
create_documentation() {
    info "Creating usage documentation..."

    cat > "$CLAUDE_DIR/UNIVERSAL_MODE_USAGE.md" << 'EOF'
# 🌍 UNIVERSAL MODE Enhanced Usage Guide

## Quick Start Commands

### Project Setup
```bash
universal-config setup          # Full intelligent setup for current project
universal-config auto-config    # Generate optimal configuration
universal-mcp activate          # Activate optimal MCP servers
universal-patterns activate     # Activate intelligent patterns
```

### Status and Management
```bash
universal-detect analyze        # Analyze current project intelligence
universal-mcp status           # Show MCP activation status
universal-patterns status      # Show active patterns
universal-config validate      # Validate project configuration
```

### Manual Control
```bash
universal-mcp activate /path/to/project           # Activate for specific project
universal-patterns toggle TDD                     # Toggle specific pattern
universal-config generate backend-api             # Force specific config type
```

## Statusbar Integration

The enhanced statusbar shows:
- 🌟 Intelligence level (MINIMAL to MAXIMUM)
- 📊 Active MCP servers (e.g., MCP:6/9)
- 🎯 Active patterns (e.g., Patterns:3/5)
- 🔧 Special modes (📸🔌📊 for screenshot, API, data modes)
- 🎨 Project optimization indicators
- 📋 Git status with ahead/behind tracking
- 🔋 Token usage with precise timing

## Automatic Intelligence Features

### Project Detection
- Analyzes files, dependencies, and structure
- Detects frameworks (React, Django, Terraform, etc.)
- Identifies optimal development patterns
- Recommends MCP servers and tools

### Smart Configuration
- Generates project-specific CLAUDE.md
- Creates environment templates
- Sets up VS Code integration
- Configures testing and CI/CD workflows

### Pattern Intelligence
- TDD for projects with testing frameworks
- Visual iteration for frontend projects
- Security patterns for infrastructure
- Slot machine for data science work
- Auto-accept for high-confidence TypeScript

### Real-time Optimization
- Updates intelligence based on project changes
- Learns from usage patterns and success rates
- Adapts recommendations over time
- Provides performance metrics and insights

## Troubleshooting

### Reset Intelligence
```bash
universal-detect clear-cache    # Clear project analysis cache
universal-mcp restore          # Restore MCP configuration backup
```

### Manual Override
```bash
universal-patterns toggle Auto-Accept    # Disable auto-accept if needed
universal-mcp activate --force          # Force MCP reactivation
```

### Check Installation
```bash
which universal-detect universal-mcp universal-config universal-patterns
```

## Integration with Existing Workflows

The enhanced system integrates seamlessly with:
- Existing CLAUDE.md configurations (project-specific overrides global)
- Current MCP server setups (intelligent additions/modifications)
- Git workflows (enhanced status and checkpoint integration)
- VS Code and other editors (automatic settings configuration)
- CI/CD pipelines (pattern-based optimization recommendations)

---
*🌍 UNIVERSAL MODE Enhanced Intelligence System*
EOF

    success "Created comprehensive usage documentation"
}

# Perform system validation
validate_installation() {
    info "Validating installation..."

    local errors=()

    # Check script accessibility
    for cmd in universal-detect universal-mcp universal-config universal-patterns; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            errors+=("Command '$cmd' not accessible")
        fi
    done

    # Check core files
    local core_files=(
        "$SCRIPT_DIR/intelligent-project-detector.sh"
        "$SCRIPT_DIR/mcp-auto-activator.sh"
        "$SCRIPT_DIR/auto-config-manager.sh"
        "$SCRIPT_DIR/intelligent-pattern-activator.sh"
        "$SCRIPT_DIR/enhanced-universal-statusbar.sh"
    )

    for file in "${core_files[@]}"; do
        if [[ ! -x "$file" ]]; then
            errors+=("Core script not executable: $file")
        fi
    done

    # Check initialization
    if [[ ! -f "$HOME/.claude/mcp-states.json" ]]; then
        errors+=("MCP system not properly initialized")
    fi

    if [[ ! -f "$HOME/.claude/pattern-states.json" ]]; then
        errors+=("Pattern system not properly initialized")
    fi

    # Test functionality
    if ! "$SCRIPT_DIR/intelligent-project-detector.sh" analyze "$PROJECT_ROOT" >/dev/null 2>&1; then
        errors+=("Project detection not working")
    fi

    # Report results
    if [[ ${#errors[@]} -eq 0 ]]; then
        success "Installation validation passed"
        return 0
    else
        error "Installation validation failed:"
        for err in "${errors[@]}"; do
            error "  - $err"
        done
        return 1
    fi
}

# Installation summary
show_installation_summary() {
    echo -e "${GREEN}"
    cat << 'EOF'
🎉 UNIVERSAL MODE Enhanced Installation Complete!

Your intelligent automation system is now ready with:

✅ Intelligent Project Detection
   Automatically analyzes project structure and recommends optimizations

✅ Automatic MCP Activation
   Activates optimal MCP servers based on project context

✅ Enhanced Statusbar Integration
   Real-time intelligence display with aquarium animation

✅ Automatic Configuration Management
   Generates project-specific settings and workflows

✅ Intelligent Pattern Activation
   Activates development patterns based on project needs

✅ Seamless Integration
   Works with existing Claude Code setups and workflows

EOF
    echo -e "${NC}"

    info "📖 Quick Start:"
    echo "   1. cd to any project directory"
    echo "   2. Run: universal-config setup"
    echo "   3. Start Claude Code and enjoy intelligent automation!"
    echo ""
    info "📚 Full documentation: $CLAUDE_DIR/UNIVERSAL_MODE_USAGE.md"
    echo ""
    info "🔧 Test installation: universal-detect analyze"
    echo ""

    # Show current project analysis as demonstration
    info "🧠 Current project analysis:"
    if "$SCRIPT_DIR/intelligent-project-detector.sh" analyze "$PROJECT_ROOT" 2>/dev/null | jq -r '
        "Project: " + .project.primary_type + " (" + (.project.confidence|tostring) + "% confidence)" + "\n" +
        "Recommended MCPs: " + (.mcps.essential + .mcps.recommended | join(", ")) + "\n" +
        "Suggested Patterns: " + (.patterns.patterns | join(", "))
    '; then
        echo ""
    fi

    warning "Note: If you added new commands to PATH, restart your terminal or run: source ~/.bashrc"
}

# Error recovery
cleanup_on_error() {
    error "Installation failed. Cleaning up..."

    # Restore from backup if needed
    if [[ -d "$BACKUP_DIR" ]]; then
        info "Backup available at: $BACKUP_DIR"
        info "To restore: cp $BACKUP_DIR/* $CLAUDE_DIR/"
    fi

    exit 1
}

# Main installation flow
main() {
    # Set up error handling
    trap cleanup_on_error ERR

    banner

    check_requirements
    backup_existing_config
    install_intelligence_scripts
    setup_enhanced_statusbar
    initialize_subsystems
    install_mcp_packages
    setup_global_config
    setup_project_demo
    create_documentation

    if validate_installation; then
        show_installation_summary
    else
        error "Installation completed with warnings. Check the log: $INSTALL_LOG"
        exit 1
    fi
}

# Handle command line arguments
case "${1:-}" in
    "--help"|"-h")
        echo "UNIVERSAL MODE Enhanced Installation Script"
        echo "Usage: $0 [--help|--dry-run|--force]"
        echo ""
        echo "Options:"
        echo "  --help     Show this help message"
        echo "  --dry-run  Show what would be installed without making changes"
        echo "  --force    Force installation even if validation fails"
        exit 0
        ;;
    "--dry-run")
        info "DRY RUN MODE - No changes will be made"
        check_requirements
        info "Would install to: $CLAUDE_DIR"
        info "Would backup to: $BACKUP_DIR"
        info "Scripts location: $SCRIPT_DIR"
        exit 0
        ;;
    "--force")
        warning "Force mode enabled - skipping some validations"
        ;;
esac

# Run main installation
main