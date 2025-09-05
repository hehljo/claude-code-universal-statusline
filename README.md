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
- **Intelligent Caching**: <200ms execution time with smart caching

### 🎯 **Claude Code Optimized**
- **JSON Input/Output**: Perfect integration with Claude Code's statusline system
- **Performance First**: Optimized for speed and reliability
- **Error Handling**: Graceful fallbacks and user-friendly error messages

## 🖥️ **Statusline Preview**

```bash
🌐 UNIVERSAL | MCP:6/8 | 12/24 | git:main✓ | Next.js | 🧠S | 📖
```

**Legend:**
- `🌐 UNIVERSAL` - System fully active
- `MCP:6/8` - 6 of 8 MCP servers available
- `12/24` - 12 of 24 roadmap tasks completed
- `git:main✓` - Git branch + status (✓=clean, ○=modified, ●=staged)
- `Next.js` - Detected project type
- `🧠S` - Claude Sonnet active
- `📖` - Explanatory output style

## 🧠 **Model Icons**

The brain emoji with letter shows your current Claude model:

| Icon | Model | Description |
|------|---------|-------------|
| **🧠S** | **Claude Sonnet** | Standard model for most tasks |
| **🧠H** | **Claude Haiku** | Fast, lightweight model |
| **🧠O** | **Claude Opus** | Most powerful model (if available) |
| **🧠4** | **Claude Sonnet 4** | Latest version with enhanced capabilities |

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

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) - Official Claude Code documentation
- [MCP Servers](https://github.com/modelcontextprotocol/servers) - Model Context Protocol servers

---

**Made with ❤️ for the Claude Code community**