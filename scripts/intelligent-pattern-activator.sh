#!/bin/bash

# 🎯 Intelligent Pattern Activation System for UNIVERSAL MODE
# Automatically activates and manages universal patterns based on project context

# Script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Pattern state management
PATTERN_STATES_PATH="$HOME/.claude/pattern-states.json"
PATTERN_CONFIGS_PATH="$HOME/.claude/pattern-configs"
PATTERN_TEMPLATES_PATH="$HOME/.claude/pattern-templates"

mkdir -p "$PATTERN_CONFIGS_PATH" "$PATTERN_TEMPLATES_PATH"

# Universal pattern definitions with activation criteria
declare -A UNIVERSAL_PATTERNS=(
    ["TDD"]="Test-Driven Development with comprehensive test coverage"
    ["Visual-Iteration"]="Screenshot-based debugging and UI iteration"
    ["Checkpoint-Strategy"]="Strategic checkpoints before autonomous work"
    ["Assumption-Tracking"]="Mark and verify code assumptions systematically"
    ["Auto-Accept"]="Enable autonomous development for appropriate tasks"
    ["Security-Patterns"]="Security-first development and compliance checks"
    ["Documentation-Synthesis"]="Automatic documentation generation and updates"
    ["Slot-Machine"]="30-minute autonomous work cycles with state management"
    ["Persistent-Tools"]="Build reusable tools instead of throwaway solutions"
    ["Infrastructure-Patterns"]="Infrastructure-as-code best practices"
    ["Performance-Optimization"]="Continuous performance monitoring and optimization"
    ["API-Integration"]="Automated API testing and documentation"
)

# Pattern activation rules based on project intelligence
declare -A PATTERN_RULES=(
    ["TDD"]="confidence>=60,technologies:Testing,not:experimental"
    ["Visual-Iteration"]="primary_type:React|Vue|Angular|Frontend,confidence>=50"
    ["Checkpoint-Strategy"]="intensity:experimental|high,confidence>=40"
    ["Assumption-Tracking"]="confidence>=30"
    ["Auto-Accept"]="confidence>=70,intensity:high,technologies:TypeScript"
    ["Security-Patterns"]="technologies:Security|Infrastructure|Kubernetes,confidence>=50"
    ["Documentation-Synthesis"]="technologies:Infrastructure|Security,confidence>=60"
    ["Slot-Machine"]="primary_type:Data Science|ML/AI|Jupyter,confidence>=50"
    ["Persistent-Tools"]="primary_type:Data Science|ML/AI,confidence>=60"
    ["Infrastructure-Patterns"]="primary_type:Terraform|Infrastructure,confidence>=60"
    ["Performance-Optimization"]="primary_type:Backend|API,confidence>=70"
    ["API-Integration"]="primary_type:Backend|API,technologies:REST|GraphQL,confidence>=60"
)

# Initialize pattern management system
init_pattern_system() {
    echo "🎯 Initializing Intelligent Pattern Activation System..."

    # Initialize pattern states
    if [[ ! -f "$PATTERN_STATES_PATH" ]]; then
        cat > "$PATTERN_STATES_PATH" << 'EOF'
{
  "active_patterns": [],
  "pattern_history": {},
  "auto_activation": true,
  "user_overrides": {},
  "last_update": null,
  "success_metrics": {}
}
EOF
        echo "✅ Initialized pattern states tracking"
    fi

    # Create pattern configuration templates
    create_pattern_templates

    echo "✅ Pattern system initialized"
}

# Create pattern-specific configuration templates
create_pattern_templates() {
    echo "📝 Creating pattern templates..."

    # TDD Pattern Template
    cat > "$PATTERN_TEMPLATES_PATH/TDD.md" << 'EOF'
# 🧪 Test-Driven Development Pattern

## Activation Criteria
- Project has testing framework configured
- Confidence level >= 60%
- Not in experimental mode

## Implementation Strategy
1. **Red Phase**: Write failing test first
2. **Green Phase**: Write minimal code to pass
3. **Refactor Phase**: Improve code while maintaining tests

## Workflow Integration
- Create tests before implementing features
- Use test coverage as quality metric
- Integrate with CI/CD pipeline
- Document test scenarios and edge cases

## Success Metrics
- Test coverage percentage
- Test execution time
- Bug detection rate
- Development velocity
EOF

    # Visual Iteration Pattern Template
    cat > "$PATTERN_TEMPLATES_PATH/Visual-Iteration.md" << 'EOF'
# 📸 Visual Iteration Pattern

## Activation Criteria
- Frontend project (React, Vue, Angular)
- UI/UX focused development
- Confidence level >= 50%

## Implementation Strategy
1. **Screenshot Baseline**: Capture current state
2. **Implement Changes**: Make UI modifications
3. **Visual Comparison**: Compare before/after
4. **Iterate**: Refine based on visual feedback

## Workflow Integration
- Use Claude Code screenshot capabilities
- Document visual changes with comparisons
- Test across different screen sizes
- Maintain visual regression test suite

## Success Metrics
- Visual consistency score
- UI/UX iteration speed
- Cross-browser compatibility
- User satisfaction metrics
EOF

    # Checkpoint Strategy Pattern Template
    cat > "$PATTERN_TEMPLATES_PATH/Checkpoint-Strategy.md" << 'EOF'
# 🔄 Checkpoint Strategy Pattern

## Activation Criteria
- Experimental or high-intensity development
- Complex refactoring tasks
- Confidence level >= 40%

## Implementation Strategy
1. **Pre-Work Checkpoint**: Save clean state
2. **Autonomous Work**: Let Claude work independently
3. **Evaluation**: Review results after time limit
4. **Decision**: Accept, modify, or rollback

## Workflow Integration
- Git commit before autonomous work
- Set time limits for autonomous cycles
- Use assumption tracking during work
- Document checkpoint decisions

## Success Metrics
- Success rate of autonomous work
- Time savings vs manual approach
- Code quality of autonomous output
- Learning from rollback scenarios
EOF

    # Security Patterns Template
    cat > "$PATTERN_TEMPLATES_PATH/Security-Patterns.md" << 'EOF'
# 🔒 Security Patterns

## Activation Criteria
- Security-focused projects
- Infrastructure or compliance requirements
- Confidence level >= 50%

## Implementation Strategy
1. **Threat Modeling**: Identify potential threats
2. **Security by Design**: Implement security controls
3. **Continuous Monitoring**: Automated security checks
4. **Incident Response**: Prepare for security incidents

## Workflow Integration
- Security review for all code changes
- Automated vulnerability scanning
- Compliance documentation generation
- Regular security audit cycles

## Success Metrics
- Vulnerability count reduction
- Compliance score improvement
- Security incident response time
- Security awareness level
EOF

    # Slot Machine Pattern Template
    cat > "$PATTERN_TEMPLATES_PATH/Slot-Machine.md" << 'EOF'
# 🎰 Slot Machine Pattern

## Activation Criteria
- Data Science or ML/AI projects
- Exploratory data analysis
- Confidence level >= 50%

## Implementation Strategy
1. **Save State**: Checkpoint current work
2. **30-Min Cycle**: Let Claude work autonomously
3. **Evaluate Results**: Review generated analysis
4. **Accept or Restart**: Keep results or start fresh

## Workflow Integration
- Use for exploratory data analysis
- Build reusable analysis pipelines
- Document hypotheses and findings
- Create permanent tools from successful experiments

## Success Metrics
- Experiment success rate
- Insight generation speed
- Tool reusability score
- Knowledge discovery rate
EOF

    echo "✅ Pattern templates created"
}

# Evaluate pattern activation rules
evaluate_pattern_rules() {
    local pattern="$1"
    local intelligence="$2"

    local rules="${PATTERN_RULES[$pattern]}"
    if [[ -z "$rules" ]]; then
        return 1
    fi

    # Extract intelligence data
    local primary_type=$(echo "$intelligence" | jq -r '.project.primary_type // "Unknown"')
    local confidence=$(echo "$intelligence" | jq -r '.project.confidence // 0')
    local intensity=$(echo "$intelligence" | jq -r '.patterns.intensity // "conservative"')
    local technologies=$(echo "$intelligence" | jq -r '.project.technologies[]' 2>/dev/null | tr '\n' '|' | sed 's/|$//')

    # Parse and evaluate rules
    IFS=',' read -ra RULE_PARTS <<< "$rules"
    local all_match=true

    for rule in "${RULE_PARTS[@]}"; do
        rule=$(echo "$rule" | xargs) # trim whitespace

        case "$rule" in
            "confidence>="*)
                local required_confidence=${rule#confidence>=}
                if [[ $confidence -lt $required_confidence ]]; then
                    all_match=false
                    break
                fi
                ;;
            "technologies:"*)
                local required_tech=${rule#technologies:}
                if [[ ! "$technologies" =~ $required_tech ]]; then
                    all_match=false
                    break
                fi
                ;;
            "primary_type:"*)
                local required_types=${rule#primary_type:}
                if [[ ! "$primary_type" =~ $required_types ]]; then
                    all_match=false
                    break
                fi
                ;;
            "intensity:"*)
                local required_intensity=${rule#intensity:}
                if [[ ! "$intensity" =~ $required_intensity ]]; then
                    all_match=false
                    break
                fi
                ;;
            "not:"*)
                local excluded_value=${rule#not:}
                if [[ "$intensity" == "$excluded_value" ]] || [[ "$primary_type" == "$excluded_value" ]]; then
                    all_match=false
                    break
                fi
                ;;
        esac
    done

    if [[ "$all_match" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

# Get recommended patterns for project
get_recommended_patterns() {
    local project_dir="$1"
    local intelligence=$("$SCRIPT_DIR/intelligent-project-detector.sh" analyze "$project_dir" 2>/dev/null)

    if [[ $? -ne 0 ]]; then
        echo "[]"
        return 1
    fi

    local recommended_patterns=()

    # Evaluate each pattern
    for pattern in "${!UNIVERSAL_PATTERNS[@]}"; do
        if evaluate_pattern_rules "$pattern" "$intelligence"; then
            recommended_patterns+=("$pattern")
        fi
    done

    # Output as JSON array
    printf '%s\n' "${recommended_patterns[@]}" | jq -R . | jq -s .
}

# Activate patterns for project
activate_patterns() {
    local project_dir="$1"
    local force_patterns=("${@:2}")

    echo "🎯 Activating intelligent patterns for project..."

    # Get current state
    local current_state=$(cat "$PATTERN_STATES_PATH" 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        init_pattern_system
        current_state=$(cat "$PATTERN_STATES_PATH")
    fi

    # Get intelligence and recommended patterns
    local intelligence=$("$SCRIPT_DIR/intelligent-project-detector.sh" analyze "$project_dir" 2>/dev/null)
    local recommended_patterns

    if [[ ${#force_patterns[@]} -gt 0 ]]; then
        # Use forced patterns
        recommended_patterns=($(printf '%s\n' "${force_patterns[@]}" | jq -R . | jq -s . | jq -r '.[]'))
        echo "🔧 Using manually specified patterns: ${force_patterns[*]}"
    else
        # Use intelligent recommendations
        local patterns_json=$(get_recommended_patterns "$project_dir")
        recommended_patterns=($(echo "$patterns_json" | jq -r '.[]' 2>/dev/null))
        echo "🧠 Intelligent pattern recommendations: ${recommended_patterns[*]}"
    fi

    # Update pattern states
    local project_hash=$(echo "$project_dir" | md5sum | cut -d' ' -f1)
    local updated_state=$(echo "$current_state" | jq \
        --arg hash "$project_hash" \
        --arg path "$project_dir" \
        --argjson patterns "$(printf '%s\n' "${recommended_patterns[@]}" | jq -R . | jq -s .)" \
        '
        .active_patterns = $patterns |
        .pattern_history[$hash] = {
            "project_path": $path,
            "patterns": $patterns,
            "activated_at": now,
            "intelligence": ($patterns | length > 0)
        } |
        .last_update = now
        ')

    echo "$updated_state" > "$PATTERN_STATES_PATH"

    # Generate project-specific pattern configuration
    generate_pattern_config "$project_dir" "${recommended_patterns[@]}"

    echo "✅ Pattern activation complete"
    echo "Active patterns: ${recommended_patterns[*]:-none}"
}

# Generate project-specific pattern configuration
generate_pattern_config() {
    local project_dir="$1"
    local patterns=("${@:2}")

    local config_file="$project_dir/CLAUDE-PATTERNS.md"

    echo "📝 Generating pattern configuration..."

    cat > "$config_file" << EOF
# 🎯 Active UNIVERSAL Patterns Configuration
*Auto-generated on $(date) for intelligent project optimization*

## Active Patterns (${#patterns[@]})

EOF

    # Add each active pattern with its configuration
    for pattern in "${patterns[@]}"; do
        local description="${UNIVERSAL_PATTERNS[$pattern]}"
        local template_file="$PATTERN_TEMPLATES_PATH/$pattern.md"

        echo "### $pattern" >> "$config_file"
        echo "$description" >> "$config_file"
        echo "" >> "$config_file"

        if [[ -f "$template_file" ]]; then
            echo "#### Configuration" >> "$config_file"
            tail -n +2 "$template_file" >> "$config_file"  # Skip first line (title)
            echo "" >> "$config_file"
        fi

        echo "---" >> "$config_file"
        echo "" >> "$config_file"
    done

    cat >> "$config_file" << EOF
## Pattern Synergy

When multiple patterns are active, they work together to provide:

- **Enhanced Development Flow**: Patterns complement each other for optimal workflow
- **Quality Assurance**: Multiple layers of verification and testing
- **Performance Optimization**: Continuous monitoring and improvement
- **Knowledge Retention**: Documentation and learning from each session

## Pattern Commands

Use these commands to interact with active patterns:

\`\`\`bash
/pattern-status          # Show current pattern status
/pattern-toggle <name>   # Enable/disable specific pattern
/pattern-metrics         # Show pattern performance metrics
/pattern-help <name>     # Get help for specific pattern
\`\`\`

## Automatic Optimization

This configuration automatically optimizes based on:
- Project type and complexity
- Development phase and goals
- Team preferences and success metrics
- Continuous learning from usage patterns

---
*🎯 Managed by UNIVERSAL MODE Intelligent Pattern System*
EOF

    echo "✅ Generated pattern configuration: $config_file"
}

# Show pattern status and metrics
show_pattern_status() {
    local project_dir="${1:-$(pwd)}"

    echo "🎯 UNIVERSAL Pattern Status"
    echo "=========================="

    if [[ ! -f "$PATTERN_STATES_PATH" ]]; then
        echo "❌ Pattern system not initialized. Run 'init' first."
        return 1
    fi

    local state=$(cat "$PATTERN_STATES_PATH")
    local active_patterns=($(echo "$state" | jq -r '.active_patterns[]' 2>/dev/null))
    local auto_activation=$(echo "$state" | jq -r '.auto_activation // true')

    echo "Auto-activation: $auto_activation"
    echo "Active patterns (${#active_patterns[@]}):"

    if [[ ${#active_patterns[@]} -eq 0 ]]; then
        echo "  (none)"
    else
        for pattern in "${active_patterns[@]}"; do
            local description="${UNIVERSAL_PATTERNS[$pattern]}"
            echo "  ✅ $pattern - $description"
        done
    fi

    echo ""
    echo "Available patterns:"
    for pattern in "${!UNIVERSAL_PATTERNS[@]}"; do
        local description="${UNIVERSAL_PATTERNS[$pattern]}"
        local status="❌"
        if [[ " ${active_patterns[*]} " =~ " ${pattern} " ]]; then
            status="✅"
        fi
        echo "  $status $pattern - $description"
    done

    # Show recommendations for current project
    echo ""
    echo "Recommendations for current project:"
    local recommendations=$(get_recommended_patterns "$project_dir")
    local rec_patterns=($(echo "$recommendations" | jq -r '.[]' 2>/dev/null))

    if [[ ${#rec_patterns[@]} -eq 0 ]]; then
        echo "  No specific recommendations (using conservative defaults)"
    else
        for pattern in "${rec_patterns[@]}"; do
            local active_marker=""
            if [[ " ${active_patterns[*]} " =~ " ${pattern} " ]]; then
                active_marker=" (active)"
            fi
            echo "  💡 $pattern${active_marker}"
        done
    fi
}

# Toggle specific pattern
toggle_pattern() {
    local pattern="$1"
    local project_dir="${2:-$(pwd)}"

    if [[ -z "$pattern" ]]; then
        echo "❌ Pattern name required"
        return 1
    fi

    if [[ -z "${UNIVERSAL_PATTERNS[$pattern]}" ]]; then
        echo "❌ Unknown pattern: $pattern"
        echo "Available patterns: ${!UNIVERSAL_PATTERNS[*]}"
        return 1
    fi

    local state=$(cat "$PATTERN_STATES_PATH" 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        init_pattern_system
        state=$(cat "$PATTERN_STATES_PATH")
    fi

    local active_patterns=($(echo "$state" | jq -r '.active_patterns[]' 2>/dev/null))

    # Check if pattern is currently active
    if [[ " ${active_patterns[*]} " =~ " ${pattern} " ]]; then
        # Deactivate pattern
        local new_patterns=($(printf '%s\n' "${active_patterns[@]}" | grep -v "^${pattern}$"))
        echo "🔽 Deactivating pattern: $pattern"
    else
        # Activate pattern
        active_patterns+=("$pattern")
        local new_patterns=("${active_patterns[@]}")
        echo "🔼 Activating pattern: $pattern"
    fi

    # Update state
    local project_hash=$(echo "$project_dir" | md5sum | cut -d' ' -f1)
    local updated_state=$(echo "$state" | jq \
        --argjson patterns "$(printf '%s\n' "${new_patterns[@]}" | jq -R . | jq -s .)" \
        --arg hash "$project_hash" \
        --arg pattern "$pattern" \
        '
        .active_patterns = $patterns |
        .user_overrides[$hash] = (.user_overrides[$hash] // {}) |
        .user_overrides[$hash][$pattern] = {
            "toggled_at": now,
            "action": (if ($patterns | map(select(. == $pattern)) | length) > 0 then "activated" else "deactivated" end)
        } |
        .last_update = now
        ')

    echo "$updated_state" > "$PATTERN_STATES_PATH"

    # Regenerate pattern configuration
    generate_pattern_config "$project_dir" "${new_patterns[@]}"

    echo "✅ Pattern toggle complete"
}

# Main execution
main() {
    local action="$1"
    shift

    case "$action" in
        "init")
            init_pattern_system
            ;;
        "activate"|"auto")
            activate_patterns "$@"
            ;;
        "status"|"list")
            show_pattern_status "$@"
            ;;
        "toggle")
            toggle_pattern "$@"
            ;;
        "recommend")
            local project_dir="${1:-$(pwd)}"
            echo "Recommended patterns for $project_dir:"
            get_recommended_patterns "$project_dir" | jq -r '.[]' | while read pattern; do
                echo "  💡 $pattern - ${UNIVERSAL_PATTERNS[$pattern]}"
            done
            ;;
        "templates")
            echo "Available pattern templates:"
            ls -1 "$PATTERN_TEMPLATES_PATH"/*.md 2>/dev/null | sed 's/.*\///g; s/\.md$//g' | sed 's/^/  - /'
            ;;
        *)
            echo "Intelligent Pattern Activation System"
            echo "===================================="
            echo ""
            echo "Usage: $0 <command> [options]"
            echo ""
            echo "Commands:"
            echo "  init                    - Initialize pattern system"
            echo "  activate [dir] [patterns...] - Auto-activate or force specific patterns"
            echo "  status [dir]           - Show pattern status and recommendations"
            echo "  toggle <pattern> [dir] - Toggle specific pattern on/off"
            echo "  recommend [dir]        - Show pattern recommendations"
            echo "  templates              - List available pattern templates"
            echo ""
            echo "Examples:"
            echo "  $0 init                              # Initialize system"
            echo "  $0 activate                          # Auto-activate for current project"
            echo "  $0 activate /path/proj TDD Security  # Force specific patterns"
            echo "  $0 status                           # Check current status"
            echo "  $0 toggle TDD                       # Toggle TDD pattern"
            echo "  $0 recommend /path/proj             # Get recommendations"
            exit 1
            ;;
    esac
}

# Execute if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi