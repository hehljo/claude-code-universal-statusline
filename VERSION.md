# 🌍 CLAUDE UNIVERSAL MODE - Version History

## v2.1.0 - "Claude 4.5 & Weekly Limits" (2025-10-07)

### 🚀 Major Updates
- **Claude 4.5 Support**: Full detection and display for Claude Sonnet 4.5 (claude-sonnet-4-5)
- **Weekly Rate Limits**: Dual-limit tracking with weekly + 5h rolling window (August 2025 update)
- **Message-Based Tracking**: Switched from token to message-based limit display
- **Performance Optimizations**: 15% faster statusbar rendering (<1s execution time)

### 📊 Rate Limit System (2025)
- **Claude Pro**: 40-80h/week Sonnet 4.5, ~45 msg/5h, ~1,440 msg/week
- **Claude Max 5x**: 140-280h/week Sonnet 4.5 + 15-35h/week Opus 4, ~225 msg/5h
- **Claude Max 20x**: 240-480h/week Sonnet 4.5 + 24-40h/week Opus 4, ~900 msg/5h
- **Smart Display**: Shows more restrictive limit (5h or weekly)
- **Weekly Reset**: Every Monday automatic reset

### 🧠 Model Detection
- **🧠4.5**: Claude Sonnet 4.5 (latest 2025 model)
- **🧠S3.5**: Claude Sonnet 3.5
- **🧠O4**: Claude Opus 4 (when available)
- **🧠H**: Claude Haiku
- **🧠O**: Claude Opus 3

### ⚡ Performance Improvements
- **Fast Cache Strategy**: 5min project cache (reduced from 30min)
- **Optimized MCP Detection**: 1min cache with quick detection
- **Lightweight Project Analysis**: Fast file-based type detection
- **Reduced I/O Operations**: Minimized disk access and jq parsing
- **Execution Time**: ~960ms (down from 1,118ms)

### 🔧 Technical Changes
- Updated token tracking logic for dual-limit system
- Enhanced model detection with Claude 4.5 patterns
- Improved caching strategy for Claude Code v2.0.1
- Optimized jq queries with safe array access (`[]?`)
- Better error handling for missing cache files

---

## v2.0.0 - "Intelligence Revolution" (2024-09-20)

### 🚀 Major Features
- **Fully Automatic UNIVERSAL MODE**: Zero-configuration global activation
- **Enhanced Intelligence System**: 18+ MCP servers with automatic project detection
- **Real-time Statusbar**: Dynamic aquarium animation with intelligence levels
- **Specialized Agents**: NodeJS, Python, React, DevOps, Security specialists
- **Automatic Best Practices**: Context-aware pattern activation

### 🧠 Intelligence Features
- **Project Auto-Detection**: Supports 20+ programming languages and frameworks
- **Dynamic MCP Activation**: Context-aware server selection and management
- **Pattern Synergy**: Intelligent combination of development patterns
- **Performance Optimization**: 115ms system analysis speed
- **Cross-Project Learning**: Shared intelligence across different project types

### 🎯 User Experience
- **German Command Support**: Natural language activation
- **One-Command Activation**: `aktiviere_universal_mode` works globally
- **Automatic Session Loading**: Loads in every Claude Code session
- **Visual Intelligence Feedback**: Real-time status with marine life animation
- **Zero Manual Configuration**: Works automatically in any project directory

### 📊 Technical Improvements
- **Task Master MCP Integration**: Enhanced with agent creation capabilities
- **System Health Monitoring**: Automatic error detection and recovery
- **Fast Project Detection**: Optimized analysis algorithms
- **Clean Installation**: Fixed bash compatibility issues
- **Global Path Integration**: Works from any directory

### 🔧 Development Tools
- 18+ MCP Servers: filesystem, git, postgres, puppeteer, docker, kubernetes, etc.
- 5+ Specialized Agents: Language-specific AI assistants
- 12+ UNIVERSAL Patterns: From minimal to maximum optimization
- Automatic CLAUDE.md generation for any project
- Pre-commit hooks and development environment setup

### 🌟 Intelligence Levels
- 🌟 **MAXIMUM (80-100%)**: Full AI optimization with all systems active
- 🚀 **HIGH (60-79%)**: Strong optimization with key systems engaged
- ⚡ **MEDIUM (40-59%)**: Moderate optimization for mixed projects
- 🔧 **LOW (20-39%)**: Basic optimization for unclear project contexts
- ❌ **MINIMAL (<20%)**: Fallback mode with essential tools only

---

## v1.0.0 - "Foundation" (2024-09-05)

### Initial Release
- Basic Claude Code statusbar integration
- Token tracking system
- Initial MCP server support
- Project-neutral configuration system

---

**Current Version**: v2.1.0
**Release Date**: October 7, 2025
**Compatibility**: Claude Code v2.0.1+, Claude 4.5 (Sonnet/Opus)
**Status**: Production Ready 🚀
**Performance**: <1s execution, 15% faster than v2.0.0