# Real Token Tracking Guide

## Overview

The Claude Code Universal Statusline now includes **Real Token Tracking** - a revolutionary system that shows your actual Claude API token consumption across multiple server instances.

## Why Real Token Tracking?

### Before
```bash
🌐 UNIVERSAL | MCP:6/8 | ✅ 12/24 | git:main✓ | Next.js | 🟢 100k (4h26m)
```
*Always showed static 100k regardless of actual usage*

### After  
```bash
🌐 UNIVERSAL | MCP:6/8 | ✅ 12/24 | git:main✓ | Next.js | 🟢 87k (3h45m)
```
*Shows real consumption: 13k tokens used, 87k remaining*

## Features

### 🔄 **Multi-Server Synchronization**
- All Claude Code instances share the same token pool
- Synchronized via shared NAS storage
- Real-time updates across servers
- Server-specific usage statistics

### 📊 **Detailed Token Breakdown** 
- **Input Tokens**: Tokens used for your prompts/context
- **Output Tokens**: Tokens used for Claude's responses
- **Total Usage**: Combined consumption tracking
- **Request Counter**: Number of API calls made

### ⏰ **5-Hour Window Management**
- Follows Claude's official rate limits (Pro: 100k/5h, Max: 500k/5h)  
- Automatic window reset based on actual usage
- Time-until-reset display
- Historical usage patterns

### 🚦 **Visual Status Indicators**

| Icon | Usage Level | Action Required |
|------|-------------|-----------------|
| 🟢 | 0-60% used | Normal operation |
| 🟡 | 60-80% used | Monitor usage |
| 🔴 | 80-100% used | Reduce usage or wait for reset |

## Installation

### Automatic Installation
```bash
# Clone repository 
git clone [your-repo-url] 
cd claude-code-universal-statusline

# Run installer (includes token tracking)
./scripts/install.sh
```

### Manual Token Tracking Setup
```bash
# Copy token tracking scripts to .claude directory
cp .claude/sync-usage-tracker-v2.sh /root/.claude/
cp .claude/token-tracking-hook.sh /root/.claude/
cp .claude/advanced-token-tracker.sh /root/.claude/

# Make executable
chmod +x /root/.claude/sync-usage-tracker-v2.sh
chmod +x /root/.claude/token-tracking-hook.sh  
chmod +x /root/.claude/advanced-token-tracker.sh

# The statusline script automatically detects and uses these trackers
```

## Usage

### Basic Commands

#### Check Current Status
```bash
# Short status (for statusline)
/root/.claude/sync-usage-tracker-v2.sh status
# Output: 🟢 87k (3h45m)

# Detailed statistics  
/root/.claude/sync-usage-tracker-v2.sh detailed
```

#### Add Token Consumption
```bash
# Add tokens: input_tokens output_tokens
/root/.claude/sync-usage-tracker-v2.sh add 850 1200
# Output: ✅ Added 2050 tokens (850 input + 1200 output)
#         🟢 85k (3h44m)
```

#### Initialize/Reset Tracking
```bash
# Create new tracking file
/root/.claude/sync-usage-tracker-v2.sh init
```

### Advanced Usage

#### Hook System Integration
```bash
# Set up automatic token tracking (future feature)
/root/.claude/token-tracking-hook.sh post-request response.json

# Monitor API responses for token extraction
/root/.claude/advanced-token-tracker.sh monitor /tmp/claude-responses/
```

## Multi-Server Setup

### Server Requirements
1. **Shared Storage**: NAS or network filesystem mounted at `/mnt/fileshare/claude-sync/`
2. **jq**: JSON processor (`apt install jq`)
3. **Claude Code**: Latest version with statusline support

### Server Configuration
Each server automatically identifies itself:
- **LXC containers**: Detected as "LXC115", "LXC116", etc.
- **Main servers**: Detected as "MAIN"
- **Custom naming**: Based on hostname

### Shared File Structure
```
/mnt/fileshare/claude-sync/
├── usage-tracking.json          # Shared usage data (v2.0 format)
├── sync-usage-tracker-v2.sh     # Latest token tracker
├── token-tracking-hook.sh       # Hook system
└── REAL-TOKEN-TRACKING-SETUP.md # Setup guide
```

## JSON Data Structure (v2.0)

### Current Window Data
```json
{
  "version": "2.0",
  "token_usage": {
    "current_window": {
      "total_tokens": 12050,
      "input_tokens": 4850, 
      "output_tokens": 7200,
      "total_requests": 4,
      "first_request": 1757151200,
      "last_request": 1757151535
    }
  },
  "server_tracking": {
    "last_active_server": "MAIN",
    "servers": {
      "MAIN": {
        "session_requests": 4,
        "session_tokens": {
          "total": 12050,
          "input": 4850,
          "output": 7200
        },
        "lifetime_stats": {
          "total_sessions": 1,
          "total_requests": 4,
          "total_tokens": 12050
        }
      }
    }
  }
}
```

### Plan Configuration
```json
{
  "plan_configuration": {
    "current_plan": "pro",
    "limits": {
      "pro": {"total_tokens": 100000, "window_hours": 5},
      "max": {"total_tokens": 500000, "window_hours": 5}
    }
  }
}
```

## Troubleshooting

### Common Issues

**Statusline shows static 100k:**
```bash
# Check if v2.0 tracker is installed
ls -la /root/.claude/sync-usage-tracker-v2.sh

# Test manually
/root/.claude/sync-usage-tracker-v2.sh status

# Check statusline integration
grep -n "sync-usage-tracker-v2" /root/.claude/universal-statusline.sh
```

**Different values between servers:**
- Shared usage data synchronizes automatically
- Check NAS mount: `ls /mnt/fileshare/claude-sync/`
- Verify file permissions: `ls -la /mnt/fileshare/claude-sync/usage-tracking.json`

**Performance issues:**
```bash
# Check for lock files
ls /mnt/fileshare/claude-sync/*.lock

# Clear if stuck
rm /mnt/fileshare/claude-sync/*.lock

# Monitor logs
tail -f /root/.claude/token-usage.log
```

### Debug Mode
```bash
# Enable debug logging
DEBUG=1 /root/.claude/sync-usage-tracker-v2.sh status

# Check log files
tail -20 /root/.claude/token-usage.log
```

## Migration from v1.0

The system automatically migrates v1.0 data to v2.0 format:

```bash
# Run upgrade script
/root/.claude/upgrade-usage-structure.sh upgrade

# Check migration status  
/root/.claude/upgrade-usage-structure.sh status
```

## API Integration (Future)

### Automatic Token Extraction
```bash
# Future: Automatically extract from Claude API responses
echo '{"usage":{"input_tokens":850,"output_tokens":1200}}' | /root/.claude/token-tracking-hook.sh post-request
```

### Claude Code Integration
```json
{
  "hooks": {
    "post_request": "/root/.claude/token-tracking-hook.sh post-request"
  }
}
```

## Best Practices

### Token Management
1. **Monitor Usage**: Keep an eye on the status indicator colors
2. **Plan Usage**: Use detailed stats to understand consumption patterns  
3. **Multi-Server Coordination**: Let the system handle synchronization automatically
4. **Regular Resets**: 5-hour windows reset automatically

### Performance
1. **NAS Storage**: Use fast network storage for shared files
2. **Lock Management**: System handles locks automatically - don't manually interfere
3. **Caching**: Token status is cached for performance

### Security
1. **File Permissions**: Shared files should be readable/writable by Claude Code users
2. **Network Security**: Secure NAS access appropriately
3. **Log Management**: Token usage logs contain no sensitive data

## Support

For issues with token tracking:
1. Check the troubleshooting section above
2. Review log files in `/root/.claude/`
3. Test individual components manually
4. Submit issues with full debug output

---

**Token tracking revolutionizes Claude Code usage awareness!** 🚀