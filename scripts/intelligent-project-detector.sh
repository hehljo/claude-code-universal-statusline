#!/bin/bash

# 🧠 Intelligent Project Detection System for UNIVERSAL MODE
# Analyzes project structure and determines optimal intelligence activation

# Script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Project analysis results cache
CACHE_DIR="$HOME/.claude/project-cache"
mkdir -p "$CACHE_DIR"

# Project type detection with confidence scoring
detect_project_type() {
    local project_dir="$1"
    local confidence=0
    local primary_type=""
    local secondary_types=()
    local technologies=()
    local frameworks=()

    cd "$project_dir" 2>/dev/null || return 1

    # Node.js ecosystem detection
    if [[ -f "package.json" ]]; then
        confidence=$((confidence + 30))

        # Parse package.json for detailed framework detection
        if command -v jq >/dev/null 2>&1; then
            local deps=$(cat package.json | jq -r '.dependencies // {} | keys[]' 2>/dev/null)
            local devDeps=$(cat package.json | jq -r '.devDependencies // {} | keys[]' 2>/dev/null)

            # React ecosystem
            if echo "$deps $devDeps" | grep -q "react"; then
                if echo "$deps $devDeps" | grep -q "next"; then
                    primary_type="Next.js"
                    frameworks+=("React" "Next.js")
                    confidence=$((confidence + 40))
                elif echo "$deps $devDeps" | grep -q "gatsby"; then
                    primary_type="Gatsby"
                    frameworks+=("React" "Gatsby")
                    confidence=$((confidence + 35))
                else
                    primary_type="React"
                    frameworks+=("React")
                    confidence=$((confidence + 35))
                fi
            # Vue ecosystem
            elif echo "$deps $devDeps" | grep -q "vue"; then
                if echo "$deps $devDeps" | grep -q "nuxt"; then
                    primary_type="Nuxt.js"
                    frameworks+=("Vue" "Nuxt.js")
                    confidence=$((confidence + 35))
                else
                    primary_type="Vue.js"
                    frameworks+=("Vue")
                    confidence=$((confidence + 30))
                fi
            # Angular
            elif echo "$deps $devDeps" | grep -q "@angular"; then
                primary_type="Angular"
                frameworks+=("Angular")
                confidence=$((confidence + 30))
            # Express/Backend
            elif echo "$deps $devDeps" | grep -q "express\|fastify\|koa"; then
                primary_type="Node.js Backend"
                frameworks+=("Express" "Node.js")
                confidence=$((confidence + 25))
            # General Node.js
            else
                primary_type="Node.js"
                technologies+=("Node.js")
                confidence=$((confidence + 20))
            fi

            # Additional technology detection
            echo "$deps $devDeps" | grep -q "typescript" && technologies+=("TypeScript") && confidence=$((confidence + 10))
            echo "$deps $devDeps" | grep -q "electron" && technologies+=("Electron") && confidence=$((confidence + 15))
            echo "$deps $devDeps" | grep -q "jest\|mocha\|vitest" && technologies+=("Testing") && confidence=$((confidence + 5))
            echo "$deps $devDeps" | grep -q "tailwind\|styled-components" && technologies+=("CSS-in-JS") && confidence=$((confidence + 5))
        fi
    fi

    # Python ecosystem detection
    if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]] || [[ -f "poetry.lock" ]]; then
        if [[ -z "$primary_type" ]]; then
            confidence=$((confidence + 30))

            # Django detection
            if grep -q "django" requirements.txt pyproject.toml setup.py 2>/dev/null; then
                primary_type="Django"
                frameworks+=("Django" "Python")
                confidence=$((confidence + 25))
            # Flask detection
            elif grep -q "flask" requirements.txt pyproject.toml setup.py 2>/dev/null; then
                primary_type="Flask"
                frameworks+=("Flask" "Python")
                confidence=$((confidence + 20))
            # FastAPI detection
            elif grep -q "fastapi" requirements.txt pyproject.toml setup.py 2>/dev/null; then
                primary_type="FastAPI"
                frameworks+=("FastAPI" "Python")
                confidence=$((confidence + 25))
            # Data Science detection
            elif grep -q "pandas\|numpy\|jupyter\|matplotlib\|seaborn\|plotly" requirements.txt pyproject.toml setup.py 2>/dev/null; then
                primary_type="Python Data Science"
                frameworks+=("Data Science" "Python")
                technologies+=("Jupyter" "Pandas" "NumPy")
                confidence=$((confidence + 30))
            # Machine Learning detection
            elif grep -q "tensorflow\|pytorch\|scikit-learn\|keras" requirements.txt pyproject.toml setup.py 2>/dev/null; then
                primary_type="Python ML/AI"
                frameworks+=("Machine Learning" "Python")
                technologies+=("TensorFlow" "PyTorch" "Scikit-learn")
                confidence=$((confidence + 35))
            else
                primary_type="Python"
                technologies+=("Python")
                confidence=$((confidence + 15))
            fi
        else
            secondary_types+=("Python")
        fi
    fi

    # Jupyter notebook detection
    if find . -name "*.ipynb" -type f | head -1 | grep -q .; then
        if [[ -z "$primary_type" ]]; then
            primary_type="Jupyter Notebook"
            frameworks+=("Jupyter" "Data Science")
            confidence=$((confidence + 25))
        fi
        technologies+=("Jupyter")
        confidence=$((confidence + 10))
    fi

    # Rust detection
    if [[ -f "Cargo.toml" ]]; then
        if [[ -z "$primary_type" ]]; then
            primary_type="Rust"
            technologies+=("Rust")
            confidence=$((confidence + 30))
        else
            secondary_types+=("Rust")
        fi
    fi

    # Go detection
    if [[ -f "go.mod" ]] || [[ -f "go.sum" ]]; then
        if [[ -z "$primary_type" ]]; then
            primary_type="Go"
            technologies+=("Go")
            confidence=$((confidence + 30))
        else
            secondary_types+=("Go")
        fi
    fi

    # PHP detection
    if [[ -f "composer.json" ]]; then
        if [[ -z "$primary_type" ]]; then
            # Laravel detection
            if grep -q "laravel" composer.json 2>/dev/null; then
                primary_type="Laravel"
                frameworks+=("Laravel" "PHP")
                confidence=$((confidence + 25))
            # Symfony detection
            elif grep -q "symfony" composer.json 2>/dev/null; then
                primary_type="Symfony"
                frameworks+=("Symfony" "PHP")
                confidence=$((confidence + 25))
            else
                primary_type="PHP"
                technologies+=("PHP")
                confidence=$((confidence + 20))
            fi
        else
            secondary_types+=("PHP")
        fi
    fi

    # Docker detection
    if [[ -f "Dockerfile" ]] || [[ -f "docker-compose.yml" ]] || [[ -f "docker-compose.yaml" ]]; then
        technologies+=("Docker")
        confidence=$((confidence + 10))
    fi

    # Kubernetes detection
    if find . -name "*.yaml" -o -name "*.yml" | xargs grep -l "apiVersion:\|kind:" 2>/dev/null | head -1 | grep -q .; then
        technologies+=("Kubernetes")
        confidence=$((confidence + 15))
    fi

    # Terraform detection
    if find . -name "*.tf" -type f | head -1 | grep -q .; then
        if [[ -z "$primary_type" ]]; then
            primary_type="Terraform Infrastructure"
            frameworks+=("Terraform" "Infrastructure")
            confidence=$((confidence + 30))
        fi
        technologies+=("Terraform" "Infrastructure")
        confidence=$((confidence + 15))
    fi

    # Database detection
    if [[ -f "schema.sql" ]] || find . -name "*.sql" -type f | head -1 | grep -q .; then
        technologies+=("SQL Database")
        confidence=$((confidence + 5))
    fi

    # CI/CD detection
    if [[ -d ".github/workflows" ]] || [[ -f ".gitlab-ci.yml" ]] || [[ -f "Jenkinsfile" ]]; then
        technologies+=("CI/CD")
        confidence=$((confidence + 5))
    fi

    # Security tools detection
    if find . -name "*.yaml" -o -name "*.yml" | xargs grep -l "security\|vulnerability\|scan" 2>/dev/null | head -1 | grep -q .; then
        technologies+=("Security")
        confidence=$((confidence + 10))
    fi

    # Default fallback
    if [[ -z "$primary_type" ]]; then
        primary_type="Generic"
        confidence=10
    fi

    # Output JSON result
    cat << EOF
{
  "primary_type": "$primary_type",
  "secondary_types": [$(printf '"%s",' "${secondary_types[@]}" | sed 's/,$//g')],
  "technologies": [$(printf '"%s",' "${technologies[@]}" | sed 's/,$//g')],
  "frameworks": [$(printf '"%s",' "${frameworks[@]}" | sed 's/,$//g')],
  "confidence": $confidence,
  "analysis_time": "$(date -Iseconds)"
}
EOF
}

# Determine optimal MCP servers for project type
determine_optimal_mcps() {
    local project_data="$1"
    local primary_type=$(echo "$project_data" | jq -r '.primary_type')
    local technologies=$(echo "$project_data" | jq -r '.technologies[]' 2>/dev/null)
    local frameworks=$(echo "$project_data" | jq -r '.frameworks[]' 2>/dev/null)

    local essential_mcps=()
    local recommended_mcps=()
    local optional_mcps=()

    # Essential MCPs (always needed)
    essential_mcps+=("filesystem" "git")

    # Project-type specific MCPs
    case "$primary_type" in
        "React"|"Next.js"|"Vue.js"|"Nuxt.js"|"Angular"|"Node.js"*)
            essential_mcps+=("github")
            recommended_mcps+=("puppeteer" "brave-search")
            if echo "$technologies" | grep -q "Testing"; then
                recommended_mcps+=("sequential-thinking")
            fi
            ;;
        "Python"*|"Django"|"Flask"|"FastAPI")
            essential_mcps+=("github")
            if echo "$primary_type" | grep -q "Data Science\|ML/AI"; then
                essential_mcps+=("postgres")
                recommended_mcps+=("memory" "sequential-thinking")
            fi
            recommended_mcps+=("brave-search")
            ;;
        "Jupyter Notebook"|"Python Data Science"|"Python ML/AI")
            essential_mcps+=("postgres" "memory")
            recommended_mcps+=("sequential-thinking" "brave-search")
            optional_mcps+=("github")
            ;;
        "Terraform Infrastructure")
            essential_mcps+=("github" "brave-search")
            recommended_mcps+=("memory" "sequential-thinking")
            if echo "$technologies" | grep -q "Kubernetes"; then
                recommended_mcps+=("postgres")
            fi
            ;;
        "Rust"|"Go"|"PHP"|"Laravel"|"Symfony")
            essential_mcps+=("github")
            recommended_mcps+=("brave-search" "sequential-thinking")
            ;;
        *)
            recommended_mcps+=("github" "brave-search")
            ;;
    esac

    # Technology-specific additions
    if echo "$technologies" | grep -q "Docker\|Kubernetes"; then
        recommended_mcps+=("sequential-thinking")
    fi

    if echo "$technologies" | grep -q "Security"; then
        essential_mcps+=("memory" "sequential-thinking")
        recommended_mcps+=("brave-search")
    fi

    if echo "$technologies" | grep -q "CI/CD"; then
        recommended_mcps+=("github" "memory")
    fi

    # Remove duplicates
    essential_mcps=($(printf '%s\n' "${essential_mcps[@]}" | sort -u))
    recommended_mcps=($(printf '%s\n' "${recommended_mcps[@]}" | sort -u))
    optional_mcps=($(printf '%s\n' "${optional_mcps[@]}" | sort -u))

    # Output JSON result
    cat << EOF
{
  "essential": [$(printf '"%s",' "${essential_mcps[@]}" | sed 's/,$//g')],
  "recommended": [$(printf '"%s",' "${recommended_mcps[@]}" | sed 's/,$//g')],
  "optional": [$(printf '"%s",' "${optional_mcps[@]}" | sed 's/,$//g')]
}
EOF
}

# Determine optimal universal patterns
determine_optimal_patterns() {
    local project_data="$1"
    local primary_type=$(echo "$project_data" | jq -r '.primary_type')
    local technologies=$(echo "$project_data" | jq -r '.technologies[]' 2>/dev/null)
    local frameworks=$(echo "$project_data" | jq -r '.frameworks[]' 2>/dev/null)

    local patterns=()
    local intensity="medium"
    local special_modes=()

    case "$primary_type" in
        "React"|"Next.js"|"Vue.js"|"Angular"|"Node.js Frontend")
            patterns+=("TDD" "Visual-Iteration" "Checkpoint-Strategy")
            if echo "$technologies" | grep -q "TypeScript"; then
                patterns+=("Auto-Accept")
                intensity="high"
            fi
            special_modes+=("screenshot-debugging" "prototype-generation")
            ;;
        "Node.js Backend"|"Django"|"Flask"|"FastAPI"|"Go"|"Rust")
            patterns+=("TDD" "Assumption-Tracking" "Security-Patterns")
            if echo "$technologies" | grep -q "Testing"; then
                intensity="high"
                patterns+=("Auto-Accept")
            fi
            special_modes+=("api-testing" "performance-monitoring")
            ;;
        "Python Data Science"|"Python ML/AI"|"Jupyter Notebook")
            patterns+=("Slot-Machine" "Persistent-Tools" "Assumption-Tracking")
            intensity="experimental"
            special_modes+=("data-visualization" "experiment-tracking")
            ;;
        "Terraform Infrastructure")
            patterns+=("Security-Patterns" "Documentation-Synthesis" "Checkpoint-Strategy")
            intensity="conservative"
            special_modes+=("infrastructure-validation" "security-scanning")
            ;;
        "Laravel"|"Symfony"|"PHP")
            patterns+=("TDD" "Security-Patterns" "Documentation-Synthesis")
            intensity="medium"
            special_modes+=("mvc-patterns" "database-optimization")
            ;;
        *)
            patterns+=("Assumption-Tracking" "Checkpoint-Strategy")
            intensity="conservative"
            ;;
    esac

    # Technology-specific pattern additions
    if echo "$technologies" | grep -q "Security"; then
        patterns+=("Security-Patterns" "Documentation-Synthesis")
        special_modes+=("vulnerability-scanning" "compliance-checking")
    fi

    if echo "$technologies" | grep -q "Docker\|Kubernetes"; then
        patterns+=("Infrastructure-Patterns" "Security-Patterns")
        special_modes+=("container-optimization" "orchestration-debugging")
    fi

    if echo "$technologies" | grep -q "CI/CD"; then
        patterns+=("Automation-Patterns" "Testing-Integration")
        special_modes+=("pipeline-optimization" "deployment-validation")
    fi

    # Remove duplicates
    patterns=($(printf '%s\n' "${patterns[@]}" | sort -u))
    special_modes=($(printf '%s\n' "${special_modes[@]}" | sort -u))

    # Output JSON result
    cat << EOF
{
  "patterns": [$(printf '"%s",' "${patterns[@]}" | sed 's/,$//g')],
  "intensity": "$intensity",
  "special_modes": [$(printf '"%s",' "${special_modes[@]}" | sed 's/,$//g')]
}
EOF
}

# Generate project intelligence summary
generate_intelligence_summary() {
    local project_dir="$1"
    local cache_file="$CACHE_DIR/$(echo "$project_dir" | md5sum | cut -d' ' -f1).json"

    # Check if cache is valid (less than 1 hour old)
    if [[ -f "$cache_file" ]] && [[ $(($(date +%s) - $(stat -c %Y "$cache_file"))) -lt 3600 ]]; then
        cat "$cache_file"
        return 0
    fi

    echo "Analyzing project: $project_dir" >&2

    # Detect project type
    local project_data=$(detect_project_type "$project_dir")

    # Determine optimal MCPs
    local mcp_data=$(determine_optimal_mcps "$project_data")

    # Determine optimal patterns
    local pattern_data=$(determine_optimal_patterns "$project_data")

    # Combine results
    local result=$(cat << EOF
{
  "project": $project_data,
  "mcps": $mcp_data,
  "patterns": $pattern_data,
  "generated_at": "$(date -Iseconds)",
  "project_path": "$project_dir"
}
EOF
)

    # Cache result
    echo "$result" > "$cache_file"
    echo "$result"
}

# Main execution
main() {
    local action="$1"
    local project_dir="${2:-$(pwd)}"

    case "$action" in
        "analyze"|"detect")
            generate_intelligence_summary "$project_dir"
            ;;
        "mcps")
            local project_data=$(detect_project_type "$project_dir")
            determine_optimal_mcps "$project_data"
            ;;
        "patterns")
            local project_data=$(detect_project_type "$project_dir")
            determine_optimal_patterns "$project_data"
            ;;
        "clear-cache")
            rm -rf "$CACHE_DIR"/*
            echo "Cache cleared"
            ;;
        *)
            echo "Usage: $0 {analyze|mcps|patterns|clear-cache} [project_dir]"
            echo ""
            echo "Commands:"
            echo "  analyze     - Full project analysis with intelligence recommendations"
            echo "  mcps        - Show optimal MCP servers for project"
            echo "  patterns    - Show optimal UNIVERSAL patterns for project"
            echo "  clear-cache - Clear analysis cache"
            exit 1
            ;;
    esac
}

# Execute if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi