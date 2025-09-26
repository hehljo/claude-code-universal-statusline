#!/bin/bash

# 🔧 Automatic Configuration Manager for UNIVERSAL MODE
# Intelligently configures project-specific settings based on detected context

# Script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration paths
GLOBAL_CONFIG="$HOME/.claude/CLAUDE.md"
TEMPLATE_DIR="$HOME/.claude/templates"
CONFIG_CACHE="$HOME/.claude/config-cache"

mkdir -p "$TEMPLATE_DIR" "$CONFIG_CACHE"

# Project-specific configuration templates
init_configuration_templates() {
    echo "🔧 Initializing configuration templates..."

    # React/Frontend Template
    cat > "$TEMPLATE_DIR/react-frontend.md" << 'EOF'
# 🎨 React Frontend UNIVERSAL MODE Configuration

## Active Patterns
- TDD with Jest/Vitest
- Visual Iteration with screenshots
- Component-driven development
- Auto-Accept for UI prototyping

## Preferred Workflows
- Create checkpoint before major UI changes
- Use screenshot debugging for visual issues
- Implement responsive design mobile-first
- Test components in isolation

## Project-Specific Commands
/component-test - Run component tests
/visual-debug - Take screenshot comparison
/responsive-check - Test all breakpoints
/accessibility-audit - Run a11y checks

## MCPs Priority
Essential: filesystem, git, github
Recommended: puppeteer, brave-search
Optional: memory, sequential-thinking
EOF

    # Backend API Template
    cat > "$TEMPLATE_DIR/backend-api.md" << 'EOF'
# ⚙️ Backend API UNIVERSAL MODE Configuration

## Active Patterns
- TDD with comprehensive test coverage
- Security-first development
- API documentation generation
- Performance monitoring

## Preferred Workflows
- Write tests before implementation
- Document API endpoints automatically
- Validate input/output schemas
- Monitor performance metrics

## Project-Specific Commands
/api-test - Run API endpoint tests
/security-scan - Check for vulnerabilities
/performance-profile - Analyze bottlenecks
/docs-generate - Update API documentation

## MCPs Priority
Essential: filesystem, git, github, postgres
Recommended: memory, sequential-thinking, brave-search
Optional: puppeteer
EOF

    # Data Science Template
    cat > "$TEMPLATE_DIR/data-science.md" << 'EOF'
# 📊 Data Science UNIVERSAL MODE Configuration

## Active Patterns
- Slot Machine methodology (30min autonomous work)
- Persistent tool building over throwaway notebooks
- Assumption tracking for hypotheses
- Visual-first data exploration

## Preferred Workflows
- Save state before experimental analysis
- Build reusable visualization dashboards
- Document data sources and transformations
- Version control datasets and models

## Project-Specific Commands
/data-explore - Interactive data exploration
/model-train - Train ML model with tracking
/viz-dashboard - Create visualization dashboard
/experiment-log - Log hypothesis and results

## MCPs Priority
Essential: filesystem, git, postgres, memory
Recommended: sequential-thinking, brave-search
Optional: github, puppeteer
EOF

    # Infrastructure/DevOps Template
    cat > "$TEMPLATE_DIR/infrastructure.md" << 'EOF'
# 🏗️ Infrastructure UNIVERSAL MODE Configuration

## Active Patterns
- Security-first infrastructure design
- Documentation synthesis for runbooks
- Conservative checkpoint strategy
- Stack trace analysis for debugging

## Preferred Workflows
- Plan -> Review -> Apply for infrastructure changes
- Document all infrastructure as code
- Automate security compliance checks
- Monitor infrastructure health

## Project-Specific Commands
/infra-plan - Review Terraform plan
/security-check - Run security compliance scan
/deploy-validate - Validate deployment
/rollback-prepare - Prepare rollback strategy

## MCPs Priority
Essential: filesystem, git, github, memory
Recommended: brave-search, sequential-thinking
Optional: postgres, puppeteer
EOF

    # Security/Compliance Template
    cat > "$TEMPLATE_DIR/security.md" << 'EOF'
# 🔒 Security UNIVERSAL MODE Configuration

## Active Patterns
- Security-first development approach
- Comprehensive documentation synthesis
- Threat modeling and risk assessment
- Compliance automation

## Preferred Workflows
- Security review for all code changes
- Automated vulnerability scanning
- Regular security audit cycles
- Incident response documentation

## Project-Specific Commands
/security-audit - Run comprehensive security audit
/threat-model - Generate threat model
/compliance-check - Verify compliance requirements
/incident-response - Activate incident response

## MCPs Priority
Essential: filesystem, git, github, memory, sequential-thinking
Recommended: brave-search, postgres
Optional: puppeteer
EOF

    echo "✅ Configuration templates initialized"
}

# Detect optimal configuration based on project intelligence
detect_optimal_config() {
    local project_dir="$1"
    local intelligence=$("$SCRIPT_DIR/intelligent-project-detector.sh" analyze "$project_dir" 2>/dev/null)

    if [[ $? -ne 0 ]]; then
        echo "conservative"
        return 1
    fi

    local primary_type=$(echo "$intelligence" | jq -r '.project.primary_type')
    local technologies=$(echo "$intelligence" | jq -r '.project.technologies[]' 2>/dev/null | tr '\n' ' ')
    local frameworks=$(echo "$intelligence" | jq -r '.project.frameworks[]' 2>/dev/null | tr '\n' ' ')

    # Determine configuration type
    case "$primary_type" in
        "React"|"Next.js"|"Vue.js"|"Nuxt.js"|"Angular")
            echo "react-frontend"
            ;;
        "Node.js Backend"|"Django"|"Flask"|"FastAPI"|"Go"|"Rust")
            echo "backend-api"
            ;;
        "Python Data Science"|"Python ML/AI"|"Jupyter Notebook")
            echo "data-science"
            ;;
        "Terraform Infrastructure")
            echo "infrastructure"
            ;;
        *)
            # Check for security-related technologies
            if echo "$technologies" | grep -q "Security\|Kubernetes\|Docker"; then
                echo "infrastructure"
            elif echo "$technologies" | grep -q "SQL\|Database"; then
                echo "backend-api"
            elif echo "$technologies" | grep -q "Jupyter\|Data"; then
                echo "data-science"
            else
                echo "conservative"
            fi
            ;;
    esac
}

# Generate project-specific CLAUDE.md
generate_project_config() {
    local project_dir="$1"
    local config_type="$2"
    local force_update="${3:-false}"

    local project_claude="$project_dir/CLAUDE.md"

    # Check if project config already exists and is recent
    if [[ -f "$project_claude" && "$force_update" != "true" ]]; then
        if [[ $(($(date +%s) - $(stat -c %Y "$project_claude"))) -lt 86400 ]]; then
            echo "✅ Project configuration is recent, skipping update"
            return 0
        fi
    fi

    echo "🔧 Generating project-specific configuration..."

    # Get project intelligence
    local intelligence=$("$SCRIPT_DIR/intelligent-project-detector.sh" analyze "$project_dir" 2>/dev/null)
    local primary_type=$(echo "$intelligence" | jq -r '.project.primary_type // "Unknown"')
    local confidence=$(echo "$intelligence" | jq -r '.project.confidence // 0')
    local technologies=$(echo "$intelligence" | jq -r '.project.technologies[]' 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
    local frameworks=$(echo "$intelligence" | jq -r '.project.frameworks[]' 2>/dev/null | tr '\n' ', ' | sed 's/,$//')

    # Load base template
    local template_file="$TEMPLATE_DIR/$config_type.md"
    local base_template=""

    if [[ -f "$template_file" ]]; then
        base_template=$(cat "$template_file")
    else
        # Fallback to minimal template
        base_template="# 🌍 UNIVERSAL MODE Project Configuration

## Auto-detected Configuration
Project appears to be a general-purpose project.

## Active Patterns
- Assumption tracking
- Checkpoint strategy
- Documentation synthesis

## Preferred Workflows
- Explore -> Plan -> Code -> Commit
- Test-driven development when applicable
- Regular checkpoints for experimental work"
    fi

    # Generate enhanced project configuration
    cat > "$project_claude" << EOF
# 🌍 UNIVERSAL MODE - Auto-Generated Project Configuration
*Generated on $(date) based on intelligent project analysis*

## 📊 Project Analysis Results
- **Type**: $primary_type
- **Confidence**: ${confidence}%
- **Technologies**: $technologies
- **Frameworks**: $frameworks

$base_template

## 🚀 Auto-Configuration Features
- Intelligent MCP activation based on project needs
- Context-aware pattern selection
- Performance-optimized workflows
- Real-time intelligence monitoring

## 📈 Performance Tracking
This configuration is optimized for:
- Reduced development time through intelligent automation
- Improved code quality through pattern-driven development
- Enhanced debugging through visual and analytical tools
- Streamlined workflows through project-specific commands

## 🔄 Auto-Update Notice
This configuration is automatically updated when significant project changes are detected.
Last analysis: $(date -Iseconds)

---
*🤖 Generated by UNIVERSAL MODE Auto-Configuration System*
EOF

    echo "✅ Generated project configuration: $project_claude"

    # Cache configuration metadata
    local cache_file="$CONFIG_CACHE/$(echo "$project_dir" | md5sum | cut -d' ' -f1).json"
    cat > "$cache_file" << EOF
{
  "project_path": "$project_dir",
  "config_type": "$config_type",
  "generated_at": "$(date -Iseconds)",
  "primary_type": "$primary_type",
  "confidence": $confidence,
  "template_used": "$config_type"
}
EOF
}

# Setup environment variables and system configurations
setup_environment_config() {
    local project_dir="$1"
    local intelligence=$("$SCRIPT_DIR/intelligent-project-detector.sh" analyze "$project_dir" 2>/dev/null)

    echo "🌍 Setting up environment configuration..."

    # Create .env template if it doesn't exist
    local env_file="$project_dir/.env.example"
    if [[ ! -f "$env_file" && ! -f "$project_dir/.env" ]]; then
        local primary_type=$(echo "$intelligence" | jq -r '.project.primary_type')

        case "$primary_type" in
            "React"|"Next.js"|"Vue.js"|"Nuxt.js"|"Angular")
                cat > "$env_file" << 'EOF'
# 🎨 Frontend Environment Configuration
REACT_APP_API_URL=http://localhost:3001
REACT_APP_ENVIRONMENT=development
REACT_APP_DEBUG=true

# Optional: For services that require API keys
# REACT_APP_ANALYTICS_KEY=your_analytics_key
# REACT_APP_MAPS_API_KEY=your_maps_key
EOF
                ;;
            "Node.js Backend"|"Django"|"Flask"|"FastAPI")
                cat > "$env_file" << 'EOF'
# ⚙️ Backend Environment Configuration
NODE_ENV=development
PORT=3001
DEBUG=true

# Database Configuration
DATABASE_URL=postgresql://username:password@localhost:5432/database_name
REDIS_URL=redis://localhost:6379

# Security
JWT_SECRET=your_jwt_secret_here
BCRYPT_ROUNDS=12

# External APIs
# API_KEY=your_api_key
# WEBHOOK_SECRET=your_webhook_secret
EOF
                ;;
            "Python Data Science"|"Jupyter Notebook")
                cat > "$env_file" << 'EOF'
# 📊 Data Science Environment Configuration
JUPYTER_ENABLE_LAB=yes
PYTHONPATH=./src:./lib

# Data Sources
DATABASE_URL=postgresql://username:password@localhost:5432/data_warehouse
DATA_DIR=./data
MODELS_DIR=./models

# ML/AI Services
# OPENAI_API_KEY=your_openai_key
# HUGGINGFACE_TOKEN=your_hf_token

# Visualization
PLOT_BACKEND=plotly
FIGURE_FORMAT=png
EOF
                ;;
        esac

        if [[ -f "$env_file" ]]; then
            echo "✅ Created environment template: $env_file"
        fi
    fi

    # Setup VS Code settings for better Claude Code integration
    local vscode_dir="$project_dir/.vscode"
    local settings_file="$vscode_dir/settings.json"

    if [[ ! -d "$vscode_dir" ]]; then
        mkdir -p "$vscode_dir"
    fi

    if [[ ! -f "$settings_file" ]]; then
        cat > "$settings_file" << 'EOF'
{
  "claude.universalMode": true,
  "claude.autoActivation": true,
  "claude.statusbar.enabled": true,
  "claude.statusbar.showIntelligence": true,
  "claude.statusbar.showMCPs": true,
  "claude.statusbar.showPatterns": true,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "files.autoSave": "onDelay",
  "files.autoSaveDelay": 1000
}
EOF
        echo "✅ Created VS Code settings for Claude Code integration"
    fi
}

# Install project-specific dependencies and tools
install_project_dependencies() {
    local project_dir="$1"
    local intelligence=$("$SCRIPT_DIR/intelligent-project-detector.sh" analyze "$project_dir" 2>/dev/null)
    local primary_type=$(echo "$intelligence" | jq -r '.project.primary_type')

    echo "📦 Checking project-specific dependencies..."

    cd "$project_dir"

    case "$primary_type" in
        "React"|"Next.js"|"Vue.js"|"Angular")
            # Ensure testing frameworks are available
            if [[ -f "package.json" ]]; then
                local has_testing=$(cat package.json | jq -r '.devDependencies | has("jest") or has("vitest") or has("@testing-library/react")')
                if [[ "$has_testing" != "true" ]]; then
                    echo "💡 Consider adding testing framework: npm install --save-dev jest @testing-library/react @testing-library/jest-dom"
                fi
            fi
            ;;
        "Python Data Science"|"Jupyter Notebook")
            # Check for common data science packages
            if [[ -f "requirements.txt" ]]; then
                local missing_packages=()
                for pkg in "pandas" "numpy" "matplotlib" "seaborn" "jupyter"; do
                    if ! grep -q "$pkg" requirements.txt; then
                        missing_packages+=("$pkg")
                    fi
                done
                if [[ ${#missing_packages[@]} -gt 0 ]]; then
                    echo "💡 Consider adding packages: ${missing_packages[*]}"
                fi
            fi
            ;;
        "Terraform Infrastructure")
            # Check for terraform validation tools
            if ! command -v terraform-docs >/dev/null; then
                echo "💡 Consider installing terraform-docs for better documentation"
            fi
            if ! command -v tflint >/dev/null; then
                echo "💡 Consider installing tflint for terraform linting"
            fi
            ;;
    esac
}

# Validate configuration and provide recommendations
validate_configuration() {
    local project_dir="$1"
    local config_file="$project_dir/CLAUDE.md"

    echo "🔍 Validating project configuration..."

    local issues=()
    local recommendations=()

    # Check if CLAUDE.md exists
    if [[ ! -f "$config_file" ]]; then
        issues+=("No CLAUDE.md configuration found")
        recommendations+=("Run auto-config to generate project-specific configuration")
    fi

    # Check if .env is properly configured
    if [[ -f "$project_dir/.env" ]]; then
        # Check for common security issues
        if grep -q "password\|secret\|key" "$project_dir/.env" 2>/dev/null; then
            if grep -q "your_\|change_me\|example" "$project_dir/.env" 2>/dev/null; then
                issues+=("Environment file contains placeholder values")
                recommendations+=("Update .env with actual configuration values")
            fi
        fi
    fi

    # Check for gitignore
    if [[ ! -f "$project_dir/.gitignore" ]]; then
        issues+=("No .gitignore file found")
        recommendations+=("Add .gitignore to prevent committing sensitive files")
    fi

    # Report results
    if [[ ${#issues[@]} -eq 0 ]]; then
        echo "✅ Configuration validation passed"
    else
        echo "⚠️  Configuration issues found:"
        for issue in "${issues[@]}"; do
            echo "  - $issue"
        done
        echo ""
        echo "💡 Recommendations:"
        for rec in "${recommendations[@]}"; do
            echo "  - $rec"
        done
    fi
}

# Main execution
main() {
    local action="$1"
    local project_dir="${2:-$(pwd)}"

    case "$action" in
        "init")
            init_configuration_templates
            ;;
        "auto-config"|"generate")
            local config_type=$(detect_optimal_config "$project_dir")
            echo "🔍 Detected optimal configuration: $config_type"
            generate_project_config "$project_dir" "$config_type" "$3"
            setup_environment_config "$project_dir"
            install_project_dependencies "$project_dir"
            ;;
        "validate")
            validate_configuration "$project_dir"
            ;;
        "setup")
            # Full setup: init + auto-config + validation
            init_configuration_templates
            local config_type=$(detect_optimal_config "$project_dir")
            echo "🔍 Detected optimal configuration: $config_type"
            generate_project_config "$project_dir" "$config_type" "false"
            setup_environment_config "$project_dir"
            install_project_dependencies "$project_dir"
            validate_configuration "$project_dir"
            echo "✅ Full configuration setup complete"
            ;;
        "detect")
            detect_optimal_config "$project_dir"
            ;;
        "templates")
            echo "Available configuration templates:"
            ls -1 "$TEMPLATE_DIR"/*.md 2>/dev/null | sed 's/.*\///g; s/\.md$//g' | sed 's/^/  - /'
            ;;
        *)
            echo "Automatic Configuration Manager for UNIVERSAL MODE"
            echo "=================================================="
            echo ""
            echo "Usage: $0 <command> [project_dir] [options]"
            echo ""
            echo "Commands:"
            echo "  init              - Initialize configuration templates"
            echo "  auto-config       - Generate optimal project configuration"
            echo "  validate          - Validate current project configuration"
            echo "  setup             - Full setup (init + auto-config + validate)"
            echo "  detect            - Detect optimal configuration type"
            echo "  templates         - List available configuration templates"
            echo ""
            echo "Examples:"
            echo "  $0 setup                    # Setup configuration for current directory"
            echo "  $0 auto-config /path/proj  # Generate config for specific project"
            echo "  $0 validate                # Validate current project"
            echo "  $0 detect /path/proj       # Detect optimal config type"
            exit 1
            ;;
    esac
}

# Execute if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi