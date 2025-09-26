#!/bin/bash

# 🌍 UNIVERSAL MODE - Automatic Best Practices Activation
# Intelligently activates optimal patterns and configurations based on project analysis

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Color definitions for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Icons for visual feedback
ROCKET="🚀"
GEAR="⚙️"
CHECK="✅"
STAR="⭐"
LIGHTNING="⚡"
BRAIN="🧠"
SHIELD="🛡️"
WRENCH="🔧"

# Logging function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case $level in
        "INFO")  echo -e "${GREEN}[INFO]${NC} ${timestamp} - $message" ;;
        "WARN")  echo -e "${YELLOW}[WARN]${NC} ${timestamp} - $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} ${timestamp} - $message" ;;
        "DEBUG") echo -e "${BLUE}[DEBUG]${NC} ${timestamp} - $message" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} ${timestamp} - $message" ;;
    esac
}

# Project analysis function
analyze_project() {
    local cwd=${1:-$(pwd)}
    log "INFO" "${BRAIN} Analyzing project at: $cwd"

    # Initialize analysis variables
    local project_type="generic"
    local confidence=0
    local frameworks=()
    local languages=()
    local tools=()
    local patterns=()

    # Language detection
    if [[ -f "$cwd/package.json" ]]; then
        languages+=("javascript")
        confidence=$((confidence + 20))

        # Framework detection
        if grep -q '"next"' "$cwd/package.json" 2>/dev/null; then
            frameworks+=("nextjs")
            project_type="nextjs"
            confidence=$((confidence + 25))
        elif grep -q '"react"' "$cwd/package.json" 2>/dev/null; then
            frameworks+=("react")
            project_type="react"
            confidence=$((confidence + 25))
        elif grep -q '"vue"' "$cwd/package.json" 2>/dev/null; then
            frameworks+=("vue")
            project_type="vue"
            confidence=$((confidence + 25))
        elif grep -q '"express"' "$cwd/package.json" 2>/dev/null; then
            frameworks+=("express")
            project_type="nodejs-backend"
            confidence=$((confidence + 20))
        else
            project_type="nodejs"
            confidence=$((confidence + 15))
        fi

        # TypeScript detection
        if [[ -f "$cwd/tsconfig.json" ]] || grep -q '"typescript"' "$cwd/package.json" 2>/dev/null; then
            languages+=("typescript")
            confidence=$((confidence + 15))
        fi
    fi

    if [[ -f "$cwd/requirements.txt" ]] || [[ -f "$cwd/pyproject.toml" ]] || [[ -f "$cwd/setup.py" ]]; then
        languages+=("python")
        confidence=$((confidence + 20))

        # Python framework detection
        if grep -q "django" "$cwd/requirements.txt" 2>/dev/null || grep -q "django" "$cwd/pyproject.toml" 2>/dev/null; then
            frameworks+=("django")
            project_type="django"
            confidence=$((confidence + 25))
        elif grep -q "fastapi" "$cwd/requirements.txt" 2>/dev/null || grep -q "fastapi" "$cwd/pyproject.toml" 2>/dev/null; then
            frameworks+=("fastapi")
            project_type="fastapi"
            confidence=$((confidence + 25))
        elif grep -q "flask" "$cwd/requirements.txt" 2>/dev/null; then
            frameworks+=("flask")
            project_type="flask"
            confidence=$((confidence + 20))
        elif grep -q "pandas\|numpy\|scikit-learn\|tensorflow\|pytorch" "$cwd/requirements.txt" 2>/dev/null; then
            project_type="data-science"
            confidence=$((confidence + 25))
        else
            project_type="python"
            confidence=$((confidence + 10))
        fi
    fi

    if [[ -f "$cwd/Cargo.toml" ]]; then
        languages+=("rust")
        project_type="rust"
        confidence=$((confidence + 25))
    fi

    if [[ -f "$cwd/go.mod" ]]; then
        languages+=("go")
        project_type="go"
        confidence=$((confidence + 25))
    fi

    if [[ -f "$cwd/composer.json" ]]; then
        languages+=("php")
        project_type="php"
        confidence=$((confidence + 20))
    fi

    # Infrastructure detection
    if [[ -f "$cwd/Dockerfile" ]] || [[ -f "$cwd/docker-compose.yml" ]]; then
        tools+=("docker")
        confidence=$((confidence + 10))
    fi

    if [[ -f "$cwd/terraform.tf" ]] || [[ -d "$cwd/terraform" ]]; then
        tools+=("terraform")
        project_type="infrastructure"
        confidence=$((confidence + 30))
    fi

    if [[ -d "$cwd/.github/workflows" ]] || [[ -f "$cwd/.gitlab-ci.yml" ]]; then
        tools+=("ci-cd")
        confidence=$((confidence + 10))
    fi

    # Testing framework detection
    if grep -q "jest\|mocha\|cypress\|playwright" "$cwd/package.json" 2>/dev/null; then
        tools+=("testing-js")
        confidence=$((confidence + 5))
    fi

    if grep -q "pytest\|unittest" "$cwd/requirements.txt" 2>/dev/null || [[ -d "$cwd/tests" ]]; then
        tools+=("testing-py")
        confidence=$((confidence + 5))
    fi

    # Database detection
    if grep -q "postgresql\|psycopg2\|pg" "$cwd/package.json" "$cwd/requirements.txt" 2>/dev/null; then
        tools+=("postgresql")
        confidence=$((confidence + 5))
    fi

    if grep -q "mongodb\|mongoose" "$cwd/package.json" "$cwd/requirements.txt" 2>/dev/null; then
        tools+=("mongodb")
        confidence=$((confidence + 5))
    fi

    # Cap confidence at 100
    if [[ $confidence -gt 100 ]]; then
        confidence=100
    fi

    # Output analysis results
    echo "PROJECT_TYPE=$project_type"
    echo "CONFIDENCE=$confidence"
    echo "LANGUAGES=${languages[*]}"
    echo "FRAMEWORKS=${frameworks[*]}"
    echo "TOOLS=${tools[*]}"

    log "SUCCESS" "${CHECK} Project analysis complete: $project_type (${confidence}% confidence)"
}

# Best practices activation function
activate_best_practices() {
    local project_type=$1
    local confidence=$2
    local cwd=${3:-$(pwd)}

    log "INFO" "${ROCKET} Activating best practices for $project_type project (${confidence}% confidence)"

    # Determine intensity level based on confidence
    local intensity="medium"
    if [[ $confidence -ge 80 ]]; then
        intensity="maximum"
    elif [[ $confidence -ge 60 ]]; then
        intensity="high"
    elif [[ $confidence -ge 40 ]]; then
        intensity="medium"
    else
        intensity="minimal"
    fi

    log "INFO" "${LIGHTNING} Using $intensity intensity level"

    # Create project-specific CLAUDE.md if it doesn't exist
    if [[ ! -f "$cwd/CLAUDE.md" ]]; then
        create_project_claude_md "$project_type" "$intensity" "$cwd"
    fi

    # Activate MCPs based on project type
    activate_project_mcps "$project_type" "$cwd"

    # Set up development environment
    setup_dev_environment "$project_type" "$cwd"

    # Create or update gitignore
    update_gitignore "$project_type" "$cwd"

    # Setup pre-commit hooks if applicable
    setup_precommit_hooks "$project_type" "$cwd"

    log "SUCCESS" "${STAR} Best practices activation complete!"
}

# Create project-specific CLAUDE.md
create_project_claude_md() {
    local project_type=$1
    local intensity=$2
    local cwd=$3

    log "INFO" "${GEAR} Creating project-specific CLAUDE.md"

    local claude_content="# ${project_type^^} Project - UNIVERSAL MODE Configuration\n\n"
    claude_content+="## Project Context\n"
    claude_content+="- **Type**: $project_type\n"
    claude_content+="- **Intensity**: $intensity\n"
    claude_content+="- **Generated**: $(date '+%Y-%m-%d %H:%M:%S')\n\n"

    # Add project-specific patterns
    claude_content+="## Active Patterns\n"
    case $project_type in
        "react"|"nextjs"|"vue")
            claude_content+="- Visual-First Development (screenshots for UI iteration)\n"
            claude_content+="- Component-Driven Architecture\n"
            claude_content+="- TDD with Jest/Testing Library\n"
            claude_content+="- Performance Optimization Focus\n"
            ;;
        "nodejs"|"nodejs-backend")
            claude_content+="- API-First Development\n"
            claude_content+="- Security-First Patterns\n"
            claude_content+="- Test-Driven Development\n"
            claude_content+="- Documentation-As-Code\n"
            ;;
        "python"|"django"|"fastapi"|"flask")
            claude_content+="- Type Hints Enforcement\n"
            claude_content+="- Pytest-Based TDD\n"
            claude_content+="- Security Best Practices\n"
            claude_content+="- API Documentation Generation\n"
            ;;
        "data-science")
            claude_content+="- Jupyter Notebook Integration\n"
            claude_content+="- Data Pipeline Automation\n"
            claude_content+="- Model Version Control\n"
            claude_content+="- Reproducible Research Patterns\n"
            ;;
        "infrastructure")
            claude_content+="- Infrastructure as Code\n"
            claude_content+="- Security Scanning Integration\n"
            claude_content+="- Automated Documentation\n"
            claude_content+="- Compliance Checking\n"
            ;;
        *)
            claude_content+="- Checkpoint-Driven Development\n"
            claude_content+="- Assumption Tracking\n"
            claude_content+="- Documentation Focus\n"
            ;;
    esac

    claude_content+="\n## MCP Configuration\n"
    claude_content+="Always use available MCPs:\n"
    claude_content+="- filesystem (for file operations)\n"
    claude_content+="- git (for version control)\n"

    case $project_type in
        "react"|"nextjs"|"vue"|"nodejs")
            claude_content+="- puppeteer (for testing and automation)\n"
            claude_content+="- browser (for web testing)\n"
            ;;
        "python"|"django"|"fastapi"|"data-science")
            claude_content+="- postgres (for database operations)\n"
            claude_content+="- memory (for context persistence)\n"
            ;;
        "infrastructure")
            claude_content+="- docker (for containerization)\n"
            claude_content+="- kubernetes (for orchestration)\n"
            ;;
    esac

    claude_content+="\n## Development Workflow\n"
    claude_content+="1. **EXPLORE**: Understand codebase and requirements\n"
    claude_content+="2. **PLAN**: Create detailed implementation strategy\n"
    claude_content+="3. **CODE**: Implement with continuous testing\n"
    claude_content+="4. **COMMIT**: Document changes and update roadmap\n"

    echo -e "$claude_content" > "$cwd/CLAUDE.md"
    log "SUCCESS" "${CHECK} Created $cwd/CLAUDE.md"
}

# Activate project-specific MCPs
activate_project_mcps() {
    local project_type=$1
    local cwd=$2

    log "INFO" "${GEAR} Configuring MCPs for $project_type"

    # Ensure MCP configuration exists
    local mcp_config="/root/.claude/mcp.json"
    if [[ ! -f "$mcp_config" ]]; then
        log "WARN" "MCP configuration not found, creating basic setup"
        echo '{"mcpServers": {}}' > "$mcp_config"
    fi

    # Add project-specific MCP recommendations to a local file
    local mcp_recommendations="$cwd/.claude-mcp-recommendations.json"
    echo "{" > "$mcp_recommendations"
    echo '  "recommended_mcps": {' >> "$mcp_recommendations"

    case $project_type in
        "react"|"nextjs"|"vue")
            echo '    "puppeteer": "Browser automation and testing",' >> "$mcp_recommendations"
            echo '    "browser": "Web interaction and testing",' >> "$mcp_recommendations"
            echo '    "playwright": "End-to-end testing"' >> "$mcp_recommendations"
            ;;
        "nodejs"|"nodejs-backend")
            echo '    "postgres": "Database operations",' >> "$mcp_recommendations"
            echo '    "docker": "Containerization",' >> "$mcp_recommendations"
            echo '    "sentry": "Error tracking"' >> "$mcp_recommendations"
            ;;
        "python"|"django"|"fastapi")
            echo '    "postgres": "Database operations",' >> "$mcp_recommendations"
            echo '    "memory": "Context persistence",' >> "$mcp_recommendations"
            echo '    "sentry": "Error tracking"' >> "$mcp_recommendations"
            ;;
        "infrastructure")
            echo '    "docker": "Container management",' >> "$mcp_recommendations"
            echo '    "kubernetes": "Orchestration",' >> "$mcp_recommendations"
            echo '    "sentry": "Infrastructure monitoring"' >> "$mcp_recommendations"
            ;;
    esac

    echo '  },' >> "$mcp_recommendations"
    echo '  "project_type": "'$project_type'",' >> "$mcp_recommendations"
    echo '  "generated": "'$(date -Iseconds)'"' >> "$mcp_recommendations"
    echo '}' >> "$mcp_recommendations"

    log "SUCCESS" "${CHECK} MCP recommendations saved to $mcp_recommendations"
}

# Setup development environment
setup_dev_environment() {
    local project_type=$1
    local cwd=$2

    log "INFO" "${WRENCH} Setting up development environment for $project_type"

    case $project_type in
        "react"|"nextjs"|"vue")
            # Create .vscode settings for frontend projects
            mkdir -p "$cwd/.vscode"
            cat > "$cwd/.vscode/settings.json" << EOF
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "typescript.preferences.importModuleSpecifier": "relative",
  "emmet.includeLanguages": {
    "javascript": "javascriptreact",
    "typescript": "typescriptreact"
  }
}
EOF
            log "SUCCESS" "${CHECK} Created VS Code settings for frontend development"
            ;;
        "python"|"django"|"fastapi")
            # Create .vscode settings for Python projects
            mkdir -p "$cwd/.vscode"
            cat > "$cwd/.vscode/settings.json" << EOF
{
  "editor.formatOnSave": true,
  "python.defaultInterpreterPath": "./venv/bin/python",
  "python.formatting.provider": "black",
  "python.linting.enabled": true,
  "python.linting.flake8Enabled": true,
  "python.testing.pytestEnabled": true
}
EOF
            log "SUCCESS" "${CHECK} Created VS Code settings for Python development"
            ;;
    esac
}

# Update gitignore
update_gitignore() {
    local project_type=$1
    local cwd=$2

    if [[ -f "$cwd/.gitignore" ]]; then
        log "INFO" "Gitignore already exists, checking for Claude-specific entries"
    else
        log "INFO" "${GEAR} Creating .gitignore for $project_type"
        touch "$cwd/.gitignore"
    fi

    # Add Claude-specific ignores if not present
    if ! grep -q "# Claude Code" "$cwd/.gitignore" 2>/dev/null; then
        echo "" >> "$cwd/.gitignore"
        echo "# Claude Code" >> "$cwd/.gitignore"
        echo ".claude-mcp-recommendations.json" >> "$cwd/.gitignore"
        echo ".claude-session-*" >> "$cwd/.gitignore"
        log "SUCCESS" "${CHECK} Added Claude-specific entries to .gitignore"
    fi
}

# Setup pre-commit hooks
setup_precommit_hooks() {
    local project_type=$1
    local cwd=$2

    # Only setup if git repo exists and pre-commit not already configured
    if [[ -d "$cwd/.git" ]] && [[ ! -f "$cwd/.pre-commit-config.yaml" ]]; then
        log "INFO" "${SHIELD} Setting up pre-commit hooks for $project_type"

        case $project_type in
            "python"|"django"|"fastapi")
                cat > "$cwd/.pre-commit-config.yaml" << EOF
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
  - repo: https://github.com/psf/black
    rev: 23.3.0
    hooks:
      - id: black
  - repo: https://github.com/pycqa/flake8
    rev: 6.0.0
    hooks:
      - id: flake8
EOF
                log "SUCCESS" "${CHECK} Created pre-commit config for Python"
                ;;
            "react"|"nextjs"|"vue"|"nodejs")
                cat > "$cwd/.pre-commit-config.yaml" << EOF
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-json
      - id: check-added-large-files
  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: v3.0.0
    hooks:
      - id: prettier
EOF
                log "SUCCESS" "${CHECK} Created pre-commit config for JavaScript/TypeScript"
                ;;
        esac
    fi
}

# Main execution function
main() {
    local cwd=${1:-$(pwd)}

    echo -e "${WHITE}${ROCKET} UNIVERSAL MODE - Automatic Best Practices Activation${NC}"
    echo -e "${BLUE}===========================================${NC}"

    # Analyze project
    local analysis_result=$(analyze_project "$cwd")

    # Parse analysis results
    local project_type=$(echo "$analysis_result" | grep "PROJECT_TYPE=" | cut -d'=' -f2)
    local confidence=$(echo "$analysis_result" | grep "CONFIDENCE=" | cut -d'=' -f2)
    local languages=$(echo "$analysis_result" | grep "LANGUAGES=" | cut -d'=' -f2-)
    local frameworks=$(echo "$analysis_result" | grep "FRAMEWORKS=" | cut -d'=' -f2-)
    local tools=$(echo "$analysis_result" | grep "TOOLS=" | cut -d'=' -f2-)

    echo -e "\n${CYAN}Project Analysis Results:${NC}"
    echo -e "  ${STAR} Type: ${WHITE}$project_type${NC}"
    echo -e "  ${STAR} Confidence: ${WHITE}$confidence%${NC}"
    echo -e "  ${STAR} Languages: ${WHITE}$languages${NC}"
    echo -e "  ${STAR} Frameworks: ${WHITE}$frameworks${NC}"
    echo -e "  ${STAR} Tools: ${WHITE}$tools${NC}"

    # Activate best practices
    echo -e "\n${PURPLE}Activating best practices...${NC}"
    activate_best_practices "$project_type" "$confidence" "$cwd"

    # Summary
    echo -e "\n${GREEN}${STAR} UNIVERSAL MODE Activation Complete!${NC}"
    echo -e "${WHITE}Your $project_type project is now optimized with:${NC}"
    echo -e "  ${CHECK} Project-specific CLAUDE.md configuration"
    echo -e "  ${CHECK} Optimized MCP server recommendations"
    echo -e "  ${CHECK} Development environment setup"
    echo -e "  ${CHECK} Code quality tools and pre-commit hooks"
    echo -e "\n${CYAN}Next steps:${NC}"
    echo -e "  1. Review and customize ${WHITE}CLAUDE.md${NC} if needed"
    echo -e "  2. Install recommended MCPs: ${WHITE}cat .claude-mcp-recommendations.json${NC}"
    echo -e "  3. Start development with optimized patterns active"

    return 0
}

# Script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi