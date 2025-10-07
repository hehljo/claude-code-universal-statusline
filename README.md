# Claude Code Universal Statusline

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/pommesbude)

> 🚀 **Advanced Statusline System for Claude Code CLI** - Automatic MCP Detection, Agent Integration, and Smart Project Recognition

## ✨ Features

### 🔮 **Universal Intelligence**
- **Auto-MCP Detection**: Automatically discovers and displays 8+ MCP servers
- **Multi-Model Support**: Shows current Claude model (Sonnet, Haiku, Opus, Sonnet 4)
- **Smart Project Recognition**: Detects Next.js, React, Python, Rust, Go, PHP, and more
- **Git Integration**: Real-time branch status with clean/modified/staged indicators

### 📊 **Progress Tracking**
- **Auto-Roadmap Management**: Creates and tracks project roadmaps automatically
- **Task Progress Display**: Shows completed/total tasks in statusline
- **Real Token Tracking**: Shows actual Claude API token consumption across servers
- **Multi-Server Sync**: Synchronizes token usage between multiple Claude Code instances
- **Intelligent Caching**: <200ms execution time with smart caching

### 🎯 **Claude Code Optimized**
- **JSON Input/Output**: Perfect integration with Claude Code's statusline system
- **Performance First**: Optimized for speed and reliability
- **Error Handling**: Graceful fallbacks and user-friendly error messages

## 🖥️ **Statusline Preview**

```bash
🌐 UNIVERSAL | 🧠4.5 | MCP:6/8 | ✅ 12/24 | git:main✓ | Next.js | 🟢 320msg (4h)
```

**Legend:**
- `🌐 UNIVERSAL` - System fully active with aquatic icons (🐠🐟🦈🐙🦑🐡🦞🐢)
- `🧠4.5` - Claude Sonnet 4.5 model detected
- `MCP:6/8` - 6 of 8 MCP servers available
- `✅ 12/24` - 12 of 24 roadmap tasks completed
- `git:main✓` - Git branch + status (✓=clean, ○=modified, ●=staged)
- `Next.js` - Detected project type
- `🟢 320msg (4h)` - **Rate limit status**: 320 messages remaining, 4h until reset

## 🧠 **Model Icons**

The brain emoji with version shows your current Claude model:

| Icon | Model | Description |
|------|---------|-------------|
| **🧠4.5** | **Claude Sonnet 4.5** | Latest model with enhanced capabilities (2025) |
| **🧠S3.5** | **Claude Sonnet 3.5** | Standard model for most tasks |
| **🧠O4** | **Claude Opus 4** | Most powerful model for complex tasks |
| **🧠H** | **Claude Haiku** | Fast, lightweight model |
| **🧠O** | **Claude Opus 3** | Previous generation powerful model |

## 🔋 **Real Token Tracking**

**NEW 2025**: Dual-limit tracking with weekly + 5h rolling window!

### Token Status Indicators

| Icon | Status | Description |
|------|--------|-------------|
| **🟢 320msg** | **Healthy** | Plenty of capacity remaining (0-60% used) |
| **🟡 120msg** | **Warning** | Moderate usage (60-80% used) |
| **🔴 LIMIT** | **Critical** | Rate limit reached |

### 2025 Rate Limits (Updated August 2025)

**Claude Pro ($20/month):**
- 40-80h Sonnet 4.5 usage per week
- ~45 messages per 5h rolling window
- ~1,440 messages per week

**Claude Max 5x ($100/month):**
- 140-280h Sonnet 4.5 + 15-35h Opus 4 per week
- ~225 messages per 5h rolling window
- ~5,040 messages per week

**Claude Max 20x ($200/month):**
- 240-480h Sonnet 4.5 + 24-40h Opus 4 per week
- ~900 messages per 5h rolling window
- ~8,640 messages per week

### Dual-Limit Tracking
- **Weekly Limits**: Resets every Monday
- **5h Rolling Window**: Continuously resets every 5 hours
- **Smart Display**: Shows the more restrictive limit
- **Real-Time Updates**: Message consumption synchronized across instances

### Token Tracking Features
```bash
# Add tokens manually
./scripts/sync-usage-tracker-v2.sh add 850 1200  # 850 input + 1200 output

# Check current status
./scripts/sync-usage-tracker-v2.sh status

# View detailed statistics
./scripts/sync-usage-tracker-v2.sh detailed
```

## 🚀 **Quick Installation**

### Prerequisites
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed
- `jq` for JSON processing
- `git` for version control

### Install via Script
```bash
# Clone the repository
git clone https://github.com/your-username/claude-code-universal-statusline.git
cd claude-code-universal-statusline

# Run installation script
./scripts/install.sh

# Test installation
echo '{"workspace":{"current_dir":"'$(pwd)'"},"model":{"display_name":"sonnet"}}' | ./scripts/universal-statusline.sh
```

### Manual Installation
```bash
# 1. Clone repository
git clone https://github.com/your-username/claude-code-universal-statusline.git

# 2. Make scripts executable
chmod +x scripts/*.sh

# 3. Add to Claude Code settings
# Add the path to universal-statusline.sh in your Claude Code statusline configuration
```

## ⚙️ **Configuration**

### Claude Code Integration
Add to your Claude Code settings:

```json
{
  "statusline": {
    "command": "/path/to/claude-code-universal-statusline/scripts/universal-statusline.sh"
  }
}
```

### Input Format
The statusline expects JSON input from Claude Code:

```json
{
  "workspace": {
    "current_dir": "/absolute/path/to/project"
  },
  "model": {
    "display_name": "sonnet|haiku|opus",
    "version": "3.5"
  },
  "session_id": "uuid-string",
  "output_style": {
    "name": "explanatory|concise|default"
  }
}
```

## 🔧 **Usage**

### Basic Usage
```bash
# Manual test
echo '{"workspace":{"current_dir":"'$(pwd)'"},"model":{"display_name":"sonnet"}}' | ./scripts/universal-statusline.sh

# Debug mode
DEBUG=1 ./scripts/universal-statusline.sh

# MCP detection only
./scripts/universal-statusline.sh --detect-mcp --verbose
```

### Advanced Usage
```bash
# Create roadmap for current project
./scripts/roadmap-detector.sh $(pwd)

# Test with specific project type
./scripts/roadmap-detector.sh $(pwd) nextjs

# Performance benchmark
time ./scripts/universal-statusline.sh < test-input.json
```

## 🏗️ **Architecture**

### Core Components
- **`scripts/universal-statusline.sh`** - Main statusline logic with JSON I/O
- **`scripts/roadmap-detector.sh`** - Auto-roadmap creation and progress tracking
- **`scripts/install.sh`** - Fully automated installation with dependency checks

### Key Features
- **MCP Auto-Detection**: Detects MCP servers via NPM/config checking
- **Project Type Recognition**: Intelligent detection of web frameworks and languages
- **Performance Optimized**: Intelligent caching and sub-200ms execution
- **POSIX Compatible**: Works across different Unix-like systems

## 🧪 **Testing**

```bash
# Run all tests
./tests/statusline-tests.sh

# Integration test
echo '{"workspace":{"current_dir":"'$(pwd)'"},"model":{"display_name":"sonnet"}}' | ./scripts/universal-statusline.sh

# Installation test
./scripts/install.sh --dry-run

# Performance test
time ./scripts/universal-statusline.sh < test-input.json
```

## 🔍 **Troubleshooting**

### Common Issues

**Statusline not showing:**
```bash
# Check if script is executable
ls -la scripts/universal-statusline.sh

# Test manually
echo '{"workspace":{"current_dir":"'$(pwd)'"},"model":{"display_name":"sonnet"}}' | ./scripts/universal-statusline.sh
```

**MCP detection failing:**
```bash
# Debug MCP detection
DEBUG=1 ./scripts/universal-statusline.sh --detect-mcp
```

**Performance issues:**
```bash
# Clear cache
rm -rf /tmp/claude-universal-*

# Check system resources
time ./scripts/universal-statusline.sh
```

### Dependencies
```bash
# Check required dependencies
jq --version || echo "jq not installed"
git --version || echo "git not installed"
```

## 📚 **Documentation**

- [Installation Guide](docs/INSTALLATION.md) - Detailed setup instructions
- [Statusline Configuration](docs/STATUSLINE_GUIDE.md) - Advanced configuration
- [API Reference](docs/API.md) - Developer documentation
- [Universal Mode Guide](docs/UNIVERSAL_MODE_README.md) - Complete system overview

## 🤝 **Contributing**

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup
```bash
# Clone and setup development environment
git clone https://github.com/your-username/claude-code-universal-statusline.git
cd claude-code-universal-statusline

# Install development dependencies
./scripts/dev-setup.sh

# Run tests
./tests/run-all-tests.sh
```

## 📋 **Requirements**

- **Claude Code CLI**: Latest version
- **Operating System**: Linux, macOS, WSL
- **Dependencies**: `jq`, `git`, `bash` 4.0+
- **Optional**: `npm` (for MCP detection), `gh` (for GitHub integration)

## 📄 **License**

MIT License - see [LICENSE](LICENSE) for details.

## ☕ **Support**

If you find this project helpful, consider buying me a coffee!

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/pommesbude)

## 🔗 **Related Projects**

- [Rovodev Universal Statusline](https://github.com/hehljo/rovodev-universal-statusline) - Universal statusline for Rovodev CLI
- [MCP Servers](https://github.com/modelcontextprotocol/servers) - Model Context Protocol servers

---

**Made with ❤️ for the developer community**