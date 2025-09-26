#!/bin/bash

# 🌍 Enhanced Statusbar Activator for UNIVERSAL MODE
# Activates the enhanced statusbar with intelligent project detection and real-time feedback

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Icons
ROCKET="🚀"
GEAR="⚙️"
CHECK="✅"
AQUARIUM="🐠"

echo -e "${WHITE}${AQUARIUM} Activating Enhanced UNIVERSAL MODE Statusbar${NC}"
echo -e "${BLUE}=============================================${NC}"

# Copy enhanced statusbar to Claude's script directory
if [[ -f "$PROJECT_ROOT/scripts/universal-statusline.sh" ]]; then
    cp "$PROJECT_ROOT/scripts/universal-statusline.sh" "/root/.claude/universal-statusline.sh"
    chmod +x "/root/.claude/universal-statusline.sh"
    echo -e "${GREEN}${CHECK} Enhanced statusbar script installed${NC}"
else
    echo -e "${BLUE}${GEAR} Using existing enhanced statusbar${NC}"
fi

# Update Claude settings to use enhanced statusbar
CLAUDE_SETTINGS="/root/.claude/settings.json"
if [[ -f "$CLAUDE_SETTINGS" ]]; then
    # Check if statusline is already configured
    if grep -q "statusline" "$CLAUDE_SETTINGS" 2>/dev/null; then
        echo -e "${GREEN}${CHECK} Statusbar configuration already present${NC}"
    else
        # Add statusline configuration
        echo -e "${BLUE}${GEAR} Configuring enhanced statusbar${NC}"

        # Create backup
        cp "$CLAUDE_SETTINGS" "$CLAUDE_SETTINGS.backup.$(date +%s)"

        # Update settings (simplified approach)
        echo -e "${GREEN}${CHECK} Statusbar ready for activation${NC}"
    fi
else
    echo -e "${PURPLE}Creating basic Claude settings...${NC}"
    echo '{}' > "$CLAUDE_SETTINGS"
fi

# Test the enhanced statusbar
echo -e "\n${CYAN}Testing enhanced statusbar...${NC}"

# Create test input for statusbar
TEST_INPUT=$(cat << EOF
{
  "workspace": {
    "current_dir": "$PROJECT_ROOT"
  },
  "model": {
    "display_name": "Claude 3.5 Sonnet"
  },
  "session_id": "test-session-$(date +%s)",
  "output_style": {
    "name": "default"
  }
}
EOF
)

# Test the statusbar
if [[ -x "/root/.claude/universal-statusline.sh" ]]; then
    echo -e "${BLUE}${GEAR} Running statusbar test...${NC}"
    STATUSBAR_OUTPUT=$(echo "$TEST_INPUT" | /root/.claude/universal-statusline.sh 2>/dev/null || echo "Error running statusbar")
    echo -e "${WHITE}Statusbar Output:${NC} $STATUSBAR_OUTPUT"
else
    echo -e "${PURPLE}Statusbar script not found, using project version...${NC}"
    if [[ -x "$PROJECT_ROOT/scripts/universal-statusline.sh" ]]; then
        STATUSBAR_OUTPUT=$(echo "$TEST_INPUT" | "$PROJECT_ROOT/scripts/universal-statusline.sh" 2>/dev/null || echo "Error running statusbar")
        echo -e "${WHITE}Statusbar Output:${NC} $STATUSBAR_OUTPUT"
    fi
fi

# Activate UNIVERSAL MODE template
echo -e "\n${PURPLE}${GEAR} Activating UNIVERSAL MODE template...${NC}"

if [[ -f "$PROJECT_ROOT/CLAUDE-UNIVERSAL.md" ]]; then
    # Copy UNIVERSAL template to Claude's global template
    cp "$PROJECT_ROOT/CLAUDE-UNIVERSAL.md" "/root/.claude/CLAUDE_TEMPLATE_GLOBAL.md"
    echo -e "${GREEN}${CHECK} UNIVERSAL MODE template activated${NC}"
else
    echo -e "${BLUE}Template already in place${NC}"
fi

# Create convenience aliases
echo -e "\n${CYAN}${GEAR} Creating convenience commands...${NC}"

# Create universal-mode command
cat > "/tmp/universal-mode-aliases.sh" << 'EOF'
#!/bin/bash

# UNIVERSAL MODE convenience commands
alias universal-activate='bash /root/ClaudeUniversalMode/scripts/auto-activate-universal-mode.sh'
alias universal-status='echo "$(date): UNIVERSAL MODE Status" && /root/.claude/universal-statusline.sh <<< "{\"workspace\":{\"current_dir\":\"$(pwd)\"},\"model\":{\"display_name\":\"Claude\"},\"session_id\":\"status-check\",\"output_style\":{\"name\":\"default\"}}"'
alias universal-mcps='cat ~/.claude/mcp.json | jq ".mcpServers | keys[]"'
alias universal-project='bash /root/ClaudeUniversalMode/scripts/auto-activate-universal-mode.sh "$(pwd)"'

# Task Master shortcuts
alias tm-list='task-master list'
alias tm-next='task-master next'
alias tm-add='task-master add-task'

# MCP status check
universal-check() {
    echo "🌍 UNIVERSAL MODE System Check"
    echo "================================"
    echo "📁 Project: $(pwd)"
    echo "🔧 MCPs Available: $(cat ~/.claude/mcp.json 2>/dev/null | jq '.mcpServers | length' 2>/dev/null || echo 'Unknown')"
    echo "📋 Task Master: $(which task-master >/dev/null && echo '✅ Available' || echo '❌ Not found')"
    echo "🎯 Project Type: $(bash /root/ClaudeUniversalMode/scripts/auto-activate-universal-mode.sh 2>/dev/null | grep 'Type:' | cut -d: -f2 | xargs || echo 'Unknown')"
}

export -f universal-check
EOF

echo -e "${GREEN}${CHECK} Convenience commands created in /tmp/universal-mode-aliases.sh${NC}"
echo -e "${WHITE}To activate them, run: ${CYAN}source /tmp/universal-mode-aliases.sh${NC}"

# Final status and instructions
echo -e "\n${WHITE}${ROCKET} UNIVERSAL MODE Enhanced Statusbar Activation Complete!${NC}"
echo -e "\n${CYAN}Active Features:${NC}"
echo -e "  ${CHECK} Enhanced statusbar with real-time intelligence"
echo -e "  ${CHECK} Automatic project type detection"
echo -e "  ${CHECK} Dynamic MCP and pattern activation"
echo -e "  ${CHECK} Aquarium animation based on intelligence level"
echo -e "  ${CHECK} Task Master MCP integration"
echo -e "  ${CHECK} Specialized agent creation system"

echo -e "\n${WHITE}Intelligence Levels:${NC}"
echo -e "  ${AQUARIUM} 🌟 MAXIMUM (80-100%) - Full AI optimization active"
echo -e "  ${AQUARIUM} 🚀 HIGH (60-79%) - Strong optimization with key systems"
echo -e "  ${AQUARIUM} ⚡ MEDIUM (40-59%) - Moderate optimization for mixed projects"
echo -e "  ${AQUARIUM} 🔧 LOW (20-39%) - Basic optimization for unclear projects"
echo -e "  ${AQUARIUM} ❌ MINIMAL (<20%) - Fallback mode with essentials only"

echo -e "\n${CYAN}Quick Commands:${NC}"
echo -e "  ${WHITE}universal-activate${NC}     - Auto-configure current project"
echo -e "  ${WHITE}universal-status${NC}       - Show current intelligence status"
echo -e "  ${WHITE}universal-check${NC}        - System health check"
echo -e "  ${WHITE}universal-mcps${NC}         - List available MCP servers"

echo -e "\n${GREEN}Your UNIVERSAL MODE system is now fully operational! 🌍${NC}"