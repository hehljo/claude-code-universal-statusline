# UltraThink Usage Tracking - Dokumentation

## 🧠 Übersicht

Das UltraThink Usage Tracking System überwacht automatisch deine Claude Code Token-Usage und zeigt sie in der Universal Mode Statusbar an - **vollständig automatisch, ohne manuellen Eingriff**.

## ⚡ Features

- ✅ **Automatische Updates** bei jedem Tool-Use (Bash, Read, Edit, etc.)
- ✅ **Intelligente Inkrementierung** basierend auf geschätztem Token-Verbrauch
- ✅ **Echtzeit-Anzeige** in der Statusbar
- ✅ **5h-Fenster & Wochen-Limit** Tracking
- ✅ **Farbkodierte Icons**: 🟢 (gut) → 🟡 (warnung) → 🔴 (kritisch)

## 📊 Statusbar-Anzeige

```
🟢5h:37.4% 🟢W:74.1%
```

- **5h**: Current session (5-Stunden Rolling Window)
- **W**: Current week (Wochenlimit)
- **Farben**:
  - 🟢 Grün: 0-74% (sicher)
  - 🟡 Gelb: 75-89% (Achtung)
  - 🔴 Rot: 90-100% (kritisch)

## 🔧 Technische Komponenten

### 1. PostToolUse Hook
**Datei**: `/root/.claude/token-tracking-hook.sh`

Wird automatisch nach jedem Tool-Use ausgeführt:
- Inkrementiert Usage-Cache um ~2000 Tokens pro Tool
- Berechnet neue Prozentsätze
- Schreibt in `/tmp/claude-usage-cache.json`

### 2. Usage Tracker
**Datei**: `/root/ClaudeOrchester/src/automation/claude_usage_tracker.py`

Python-Modul das:
- Cache ausliest
- Prozentsätze formatiert
- Statusbar-String generiert

### 3. Enhanced Statusbar
**Datei**: `/root/ClaudeUniversalMode/scripts/enhanced-universal-statusbar.sh`

Integriert Usage-Daten in Universal Mode Statusbar:
- Ruft `claude_usage_tracker.py statusbar` auf
- Zeigt formatierte Usage an

### 4. Usage Cache
**Datei**: `/tmp/claude-usage-cache.json`

JSON-Cache mit aktuellen Werten:
```json
{
  "timestamp": "2025-10-09T17:31:53Z",
  "5h_window": {
    "used": 187000,
    "limit": 500000,
    "percentage": 37.4
  },
  "weekly": {
    "used": 2222000,
    "limit": 3000000,
    "percentage": 74.1
  },
  "_note": "UltraThink: Auto-incremented based on tool usage"
}
```

## 🚀 Installation

Bereits installiert und aktiv! Das System ist vollständig in Claude Code integriert.

### Voraussetzungen

- Claude Code v2.0.1+
- ClaudeOrchester Installation
- Universal Mode Statusbar

### Konfiguration

In `/root/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash /root/ClaudeUniversalMode/scripts/enhanced-universal-statusbar.sh"
  },
  "hooks": {
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

## 📈 Funktionsweise

```
Tool Use (z.B. Bash)
    ↓
PostToolUse Hook triggered
    ↓
token-tracking-hook.sh
    ↓
update_usage_cache()
    ↓
Liest /tmp/claude-usage-cache.json
    ↓
Addiert ~2000 Tokens
    ↓
Berechnet neue %
    ↓
Schreibt zurück in Cache
    ↓
Statusbar liest Cache
    ↓
Zeigt neue % an
```

## 🔍 Monitoring & Debugging

### Cache prüfen
```bash
cat /tmp/claude-usage-cache.json | jq
```

### Aktuelle Usage anzeigen
```bash
python3 -m src.automation.claude_usage_tracker statusbar
```

### Hook-Log überprüfen
```bash
tail -f /root/.claude/hook-tracking.log
```

### Statusbar testen
```bash
echo '{"workspace":{"current_dir":"/root"},"model":{"display_name":"Claude 4.5"},"session_id":"test"}' | \
  /root/ClaudeUniversalMode/scripts/enhanced-universal-statusbar.sh
```

## ⚙️ Anpassungen

### Token-Schätzung ändern

In `/root/.claude/token-tracking-hook.sh`, Zeile ~97:
```bash
local estimated_tokens=2000  # Erhöhe/verringere für genauere Schätzung
```

### Limits anpassen

In `/root/ClaudeOrchester/src/automation/claude_usage_tracker.py`:
```python
limit_5h = 500000      # 500k Tokens im 5h-Fenster
limit_week = 3000000   # 3M Tokens pro Woche
```

### Farbschwellen ändern

In `/root/ClaudeOrchester/src/automation/claude_usage_tracker.py`:
```python
icon_5h = "🔴" if pct_5h >= 90 else "🟡" if pct_5h >= 75 else "🟢"
```

## 🐛 Troubleshooting

### Usage wird nicht angezeigt
```bash
# Prüfe ob Cache existiert
ls -la /tmp/claude-usage-cache.json

# Erstelle initialen Cache
cat > /tmp/claude-usage-cache.json <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "5h_window": {"used": 0, "limit": 500000, "percentage": 0.0},
  "weekly": {"used": 0, "limit": 3000000, "percentage": 0.0}
}
EOF
```

### Usage wird nicht aktualisiert
```bash
# Prüfe ob Hook ausgeführt wird
tail -f /root/.claude/hook-tracking.log

# Manuell triggern
echo '{}' | bash /root/.claude/token-tracking-hook.sh post-tool
```

### Statusbar zeigt alte Werte
```bash
# Statusbar neu laden (neue Claude Session starten)
# oder Cache manuell setzen
python3 -m src.automation.claude_usage_tracker statusbar
```

## 🎯 Best Practices

1. **Initiale Werte setzen**: Nach `/usage` in Claude Code die Werte manuell setzen:
   ```bash
   cat > /tmp/claude-usage-cache.json <<EOF
   {
     "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
     "5h_window": {"used": 185000, "limit": 500000, "percentage": 37.0},
     "weekly": {"used": 2220000, "limit": 3000000, "percentage": 74.0}
   }
   EOF
   ```

2. **Regelmäßige Kalibrierung**: Gelegentlich mit echten `/usage` Werten abgleichen

3. **Hook-Logs überwachen**: Bei Problemen Log checken

4. **Cache-Backups**: Bei wichtigen Sessions Cache sichern

## 📝 Changelog

### v3.0 (2025-10-09) - UltraThink Release
- ✅ Vollautomatisches Token-Tracking via PostToolUse Hook
- ✅ Intelligente Inkrementierung (2000 Tokens/Tool)
- ✅ Integration in Universal Mode Statusbar
- ✅ Entfernung alter sync-tracker Dependencies
- ✅ Vereinfachtes System ohne manuelle Eingriffe

### v2.0
- Background-Daemon Ansatz (deprecated)
- Expect-Script Versuche (deprecated)

### v1.0
- Manuelle Usage-Updates

## 🔗 Verwandte Dokumentation

- [Claude Code Hooks](https://docs.claude.com/claude-code/hooks)
- [Universal Mode Setup](/root/ClaudeUniversalMode/README.md)
- [ClaudeOrchester](/root/ClaudeOrchester/CLAUDE.md)

## 💡 Weitere Ideen

- [ ] Integration mit OpenProject für Projekt-basiertes Token-Tracking
- [ ] Alerts bei >90% Usage
- [ ] Historische Usage-Charts
- [ ] Per-Projekt Token-Attribution
- [ ] API-basiertes Tracking (wenn verfügbar)

---

**🧠 UltraThink Mode**: Vollautomatische Intelligence ohne manuelle Eingriffe
