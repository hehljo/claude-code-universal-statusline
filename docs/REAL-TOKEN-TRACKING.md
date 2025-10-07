# 🎯 Real API Token Tracking - Setup Guide

## Overview

Das Real-Time Token Tracking System v2.1 bietet **echtes** Token- und Message-Tracking für Claude Code mit:

- ✅ **Dual-Limit System**: Wöchentliche + 5h Rolling Window Limits (2025)
- ✅ **Multi-Server Sync**: Synchronisierung zwischen mehreren Claude Code Instanzen
- ✅ **Automatische Plan-Erkennung**: Pro/Max5x/Max20x
- ✅ **Real-Time Updates**: Sofortige Anzeige in der Statusbar
- ✅ **Input/Output Breakdown**: Getrennte Tracking von Input- und Output-Tokens

## 🚀 Quick Start

### 1. Initialis initialization
```bash
/root/.claude/sync-usage-tracker-v2.sh init
```

### 2. Plan setzen
```bash
# Manuell setzen
/root/.claude/auto-detect-plan.sh set pro  # oder max5x, max20x

# Automatisch erkennen
/root/.claude/auto-detect-plan.sh update
```

### 3. Status prüfen
```bash
# Einfacher Status
/root/.claude/sync-usage-tracker-v2.sh status

# Detaillierter Status
/root/.claude/sync-usage-tracker-v2.sh detailed
```

## 📊 2025 Rate Limits

### Claude Pro ($20/month)
```
5h Window:    45 messages
Weekly:       1,440 messages (~40-80h Sonnet 4.5)
```

### Claude Max 5x ($100/month)
```
5h Window:    225 messages
Weekly:       5,040 messages (~140-280h Sonnet 4.5, 15-35h Opus 4)
```

### Claude Max 20x ($200/month)
```
5h Window:    900 messages
Weekly:       8,640 messages (~240-480h Sonnet 4.5, 24-40h Opus 4)
```

## 🔧 Manuelle Token-Addition

Wenn du echte API-Responses hast, kannst du Tokens manuell tracken:

```bash
# Syntax: add <input_tokens> <output_tokens>
/root/.claude/sync-usage-tracker-v2.sh add 5000 8000

# Beispiel-Output:
# ✅ Added 13000 tokens (5000 input + 8000 output) - 1 message tracked
# 🟢 44msg (4h34m)
```

## 🤖 Automatisches Tracking via Hook

### ✅ AKTIVIERT: Claude Code Hooks v2.1

Das Token-Tracking ist **bereits aktiv** via Claude Code Hooks!

**Konfiguration:** `/root/.claude/settings.json`
```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "bash /root/.claude/token-tracking-hook.sh stop"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "bash /root/.claude/token-tracking-hook.sh post-tool"
          }
        ]
      }
    ]
  }
}
```

**Wie es funktioniert:**

1. **Stop Hook**: Wird getriggert wenn Claude fertig antwortet
   - Extrahiert `.usage.input_tokens` und `.usage.output_tokens`
   - Tracked vollständige Conversation-Tokens

2. **PostToolUse Hook**: Wird nach jedem Tool-Use getriggert
   - Extrahiert `.result.usage.input_tokens` und `.result.usage.output_tokens`
   - Tracked tool-spezifische Tokens

3. **Automatische Addition**:
   - Beide Hooks rufen automatisch `sync-usage-tracker-v2.sh add` auf
   - Tokens werden sofort in dual-limit tracking eingefügt
   - Statusbar aktualisiert sich automatisch

**Logging:**
```bash
# Hook-Aktivität anzeigen
tail -f /root/.claude/hook-tracking.log

# Beispiel-Output:
# 2025-10-07 02:35:17 [TOKEN-HOOK-v2.1] Stop hook - Processing response completion
# 2025-10-07 02:35:17 [TOKEN-HOOK-v2.1] Method 1 (Stop hook usage): input=12500, output=18750
# 2025-10-07 02:35:17 [TOKEN-HOOK-v2.1] Tracking tokens: input=12500, output=18750
# ✅ Added 31250 tokens (12500 input + 18750 output) - 1 message tracked
```

### Method 2: Manual API Response Parsing

Wenn du Zugriff auf rohe API-Responses hast:

```bash
# API Response Format (JSON):
{
  "usage": {
    "input_tokens": 5234,
    "output_tokens": 8821
  }
}

# Extract und Track:
INPUT=$(echo "$API_RESPONSE" | jq -r '.usage.input_tokens')
OUTPUT=$(echo "$API_RESPONSE" | jq -r '.usage.output_tokens')
/root/.claude/sync-usage-tracker-v2.sh add $INPUT $OUTPUT
```

## 🔄 Multi-Server Synchronization

Das System synchronisiert automatisch zwischen mehreren Servern via NAS:

```bash
# Server 1 (MAIN)
/root/.claude/sync-usage-tracker-v2.sh add 3000 4000

# Server 2 (LXC115) - sieht sofort das Update
/root/.claude/sync-usage-tracker-v2.sh status
# 🟢 43msg (4h30m)  # Shared state!
```

**Shared File Location:**
- Primary: `/mnt/fileshare/claude-sync/usage-tracking.json`
- Fallback: `/root/.claude/usage-tracking.json`

## 📈 Statusbar Integration

Die Statusbar zeigt automatisch real-time Token-Status:

```bash
# Universal Statusline
🦈 UNIVERSAL | 🧠4.5 | MCP:6/8 | ❌ | 🟢 34msg (4h32m)
                                        ^^^^^^^^^^^^^^^^^
                                        Real Token Status
```

## 🛠️ Troubleshooting

### Problem: Tokens werden nicht getrackt

**Lösung:**
```bash
# 1. Check if tracking file exists
ls -la /mnt/fileshare/claude-sync/usage-tracking.json

# 2. Check log file
tail -f /root/.claude/token-usage.log

# 3. Re-initialize if needed
/root/.claude/sync-usage-tracker-v2.sh init
```

### Problem: Plan-Erkennung falsch

**Lösung:**
```bash
# Manuell korrigieren
/root/.claude/auto-detect-plan.sh set pro  # your actual plan

# Status prüfen
/root/.claude/auto-detect-plan.sh status
```

### Problem: Weekly Reset funktioniert nicht

**Lösung:**
```bash
# Check reset times
jq '.session_management' /mnt/fileshare/claude-sync/usage-tracking.json

# Manual reset (if needed)
jq '.session_management.weekly_session.next_reset = '$(date -d "next monday" +%s) \
   /mnt/fileshare/claude-sync/usage-tracking.json > /tmp/usage.tmp && \
   mv /tmp/usage.tmp /mnt/fileshare/claude-sync/usage-tracking.json
```

## 📝 Data Structure (v2.1)

```json
{
  "version": "2.1",
  "session_management": {
    "current_session_5h": {
      "session_start": 1759795200,
      "next_reset": 1759813200
    },
    "weekly_session": {
      "week_start": 1759701600,
      "next_reset": 1760306400
    }
  },
  "plan_configuration": {
    "current_plan": "pro",
    "limits": {
      "pro": {
        "messages_5h": 45,
        "messages_weekly": 1440
      }
    }
  },
  "token_usage": {
    "window_5h": {
      "total_tokens": 83000,
      "input_tokens": 35000,
      "output_tokens": 48000,
      "total_messages": 11
    },
    "window_weekly": {
      "total_tokens": 83000,
      "input_tokens": 35000,
      "output_tokens": 48000,
      "total_messages": 11
    }
  }
}
```

## 🔐 Security & Privacy

- ✅ Alle Daten bleiben lokal (NAS oder ~/.claude/)
- ✅ Keine Cloud-Synchronisation
- ✅ File-Locking für Multi-Server-Safety
- ✅ Kein Tracking von Message-Content, nur Metadaten

## 🎯 Best Practices

1. **Regelmäßige Status-Checks:**
   ```bash
   /root/.claude/sync-usage-tracker-v2.sh status
   ```

2. **Wöchentliches Plan-Update:**
   ```bash
   /root/.claude/auto-detect-plan.sh update
   ```

3. **Log-Monitoring:**
   ```bash
   tail -f /root/.claude/token-usage.log
   ```

4. **Backup vor größeren Änderungen:**
   ```bash
   cp /mnt/fileshare/claude-sync/usage-tracking.json \
      /mnt/fileshare/claude-sync/usage-tracking.json.backup
   ```

## 📚 See Also

- [Universal Mode v2.1 Release Notes](../VERSION.md)
- [Statusbar Configuration](STATUSLINE_GUIDE.md)
- [Token-Tracking Hook](../../../.claude/token-tracking-hook.sh)
- [Sync Usage Tracker](../../../.claude/sync-usage-tracker-v2.sh)

---

**Version:** 2.1
**Last Updated:** 2025-10-07
**Compatibility:** Claude Code v2.0.1+, Claude 4.5
