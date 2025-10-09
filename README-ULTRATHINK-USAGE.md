# 🧠 UltraThink Usage Tracking

> **Automatisches Claude Code Token-Tracking direkt in deiner Statusbar**

[![Claude Code](https://img.shields.io/badge/Claude_Code-v2.0.1+-blue)](https://claude.ai/code)
[![License](https://img.shields.io/badge/license-MIT-green)]()
[![Status](https://img.shields.io/badge/status-production-success)]()

## 🎯 Was ist das?

Ein intelligentes, **vollautomatisches** System das deine Claude Code Token-Usage in Echtzeit trackt und in der Statusbar anzeigt - ohne jeglichen manuellen Eingriff.

### Vorher
```
❌ Keine Ahnung wie viel Usage verbraucht wurde
❌ Manuell /usage eingeben müssen
❌ Keine visuelle Warnung bei hohem Verbrauch
```

### Nachher
```
✅ Automatisches Tracking bei jedem Tool-Use
✅ Live-Anzeige in der Statusbar: 🟢5h:37.8% 🟢W:74.1%
✅ Farbkodierte Warnungen: 🟢 → 🟡 → 🔴
```

## 🚀 Quick Start

### Installation

```bash
# 1. Clone Repository
cd /root
git clone https://github.com/yourusername/ClaudeUniversalMode.git

# 2. Setup Hook
cat >> ~/.claude/settings.json <<'EOF'
{
  "hooks": {
    "PostToolUse": [{
      "matcher": ".*",
      "hooks": [{
        "type": "command",
        "command": "bash /root/.claude/token-tracking-hook.sh post-tool"
      }]
    }]
  },
  "statusLine": {
    "type": "command",
    "command": "bash /root/ClaudeUniversalMode/scripts/enhanced-universal-statusbar.sh"
  }
}
EOF

# 3. Initiale Usage setzen (nach '/usage' in Claude Code)
cat > /tmp/claude-usage-cache.json <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "5h_window": {"used": 0, "limit": 500000, "percentage": 0.0},
  "weekly": {"used": 0, "limit": 3000000, "percentage": 0.0}
}
EOF

# 4. Done! Usage wird ab jetzt automatisch getrackt
```

## 📊 Features

### 🎨 Statusbar-Integration

```
🐢 UNIVERSAL [🧠4.5] [MEDIUM] [MCP:2/8] [🔧🛡️✨] [Python] [git:master○] [🟢5h:37.8% 🟢W:74.1%]
```

Die letzten beiden Werte zeigen deine aktuelle Usage:
- **🟢5h:37.8%** - Current session (5-Stunden Rolling Window)
- **🟢W:74.1%** - Current week (Wochenlimit)

### 🎯 Intelligente Inkrementierung

Das System:
1. Horcht auf **jeden Tool-Use** (Bash, Read, Edit, Write, etc.)
2. Schätzt **~2000 Tokens** pro Tool-Aufruf
3. Aktualisiert **automatisch** den Cache
4. Statusbar zeigt **sofort** neue Werte

### 🚦 Farbkodierte Warnungen

| Icon | Bereich | Bedeutung |
|------|---------|-----------|
| 🟢 | 0-74% | Alles gut, arbeite weiter |
| 🟡 | 75-89% | Achtung, bald am Limit |
| 🔴 | 90-100% | Kritisch, Usage fast aufgebraucht |

## 🔧 Technische Details

### Architektur

```
┌─────────────────┐
│  Claude Code    │
│  Tool Use       │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  PostToolUse    │
│  Hook           │
└────────┬────────┘
         │
         ↓
┌─────────────────────────┐
│  token-tracking-hook.sh │
│  • Liest Cache          │
│  • Addiert ~2k Tokens   │
│  • Berechnet neue %     │
│  • Schreibt zurück      │
└────────┬────────────────┘
         │
         ↓
┌──────────────────────┐
│  Usage Cache (JSON)  │
│  /tmp/claude-...json │
└────────┬─────────────┘
         │
         ↓
┌─────────────────────┐
│  Enhanced Statusbar │
│  • Liest Cache      │
│  • Formatiert %     │
│  • Zeigt Icons      │
└─────────────────────┘
```

### Dateien

| Datei | Beschreibung |
|-------|--------------|
| `/root/.claude/token-tracking-hook.sh` | PostToolUse Hook für Auto-Updates |
| `/root/ClaudeOrchester/src/automation/claude_usage_tracker.py` | Python-Modul für Cache-Verwaltung |
| `/root/ClaudeUniversalMode/scripts/enhanced-universal-statusbar.sh` | Statusbar mit Usage-Integration |
| `/tmp/claude-usage-cache.json` | JSON-Cache mit aktuellen Werten |

## 📖 Verwendung

### Einmalig: Initiale Kalibrierung

Nach der Installation einmal die echten Werte setzen:

```bash
# 1. In Claude Code eingeben: /usage
# 2. Werte notieren (z.B. Session: 35%, Week: 73%)
# 3. Cache setzen:

cat > /tmp/claude-usage-cache.json <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "5h_window": {
    "used": 175000,
    "limit": 500000,
    "percentage": 35.0
  },
  "weekly": {
    "used": 2190000,
    "limit": 3000000,
    "percentage": 73.0
  }
}
EOF
```

### Danach: Vollautomatisch

Ab jetzt passiert **alles automatisch**:
- ✅ Jeder Tool-Use inkrementiert die Usage
- ✅ Statusbar zeigt aktuelle Werte
- ✅ Warnfarben bei hohem Verbrauch
- ✅ **Kein manueller Eingriff** mehr nötig

### Optional: Manuelle Kalibrierung

Wenn du die echten Werte wieder synchronisieren willst:

```bash
# Aktuelle Usage anzeigen
python3 -m src.automation.claude_usage_tracker statusbar

# Manuell setzen (nach /usage Check)
/root/ClaudeOrchester/scripts/update-usage-manual.sh <session%> <week%>
```

## 🐛 Troubleshooting

### Usage wird nicht angezeigt

```bash
# Prüfe Cache
cat /tmp/claude-usage-cache.json

# Erstelle initialen Cache
cat > /tmp/claude-usage-cache.json <<EOF
{"timestamp":"$(date -u +%Y-%m-%dT%H:%M:%SZ)","5h_window":{"used":0,"limit":500000,"percentage":0.0},"weekly":{"used":0,"limit":3000000,"percentage":0.0}}
EOF
```

### Usage wird nicht aktualisiert

```bash
# Prüfe Hook-Log
tail -20 /root/.claude/hook-tracking.log

# Hook manuell testen
echo '{}' | bash /root/.claude/token-tracking-hook.sh post-tool
```

### Statusbar zeigt falsche Werte

```bash
# Statusbar neu testen
echo '{"workspace":{"current_dir":"/root"},"model":{"display_name":"Claude 4.5"},"session_id":"test"}' | \
  /root/ClaudeUniversalMode/scripts/enhanced-universal-statusbar.sh
```

## ⚙️ Konfiguration

### Token-Schätzung anpassen

In `/root/.claude/token-tracking-hook.sh`:
```bash
local estimated_tokens=2000  # Erhöhen/verringern für bessere Genauigkeit
```

### Limits ändern

In `/root/ClaudeOrchester/src/automation/claude_usage_tracker.py`:
```python
limit_5h = 500000      # 500k Tokens im 5h-Fenster (default)
limit_week = 3000000   # 3M Tokens pro Woche (default)
```

### Farbschwellen anpassen

In `/root/ClaudeOrchester/src/automation/claude_usage_tracker.py`:
```python
icon = "🔴" if pct >= 90 else "🟡" if pct >= 75 else "🟢"
#              ^^ kritisch       ^^ warnung      ^^ ok
```

## 🎓 Weiterführende Docs

- [Vollständige Dokumentation](docs/ultrathink-usage-tracking.md)
- [Claude Code Hooks](https://docs.claude.com/claude-code/hooks)
- [Universal Mode Setup](README.md)

## 🤝 Contributing

Contributions welcome! Features die noch implementiert werden könnten:

- [ ] Historische Usage-Charts
- [ ] Per-Projekt Token-Attribution
- [ ] Alerts/Notifications bei >90% Usage
- [ ] Integration mit Claude API für echte Werte
- [ ] Export/Analytics Features

## 📝 License

MIT License - siehe [LICENSE](LICENSE)

## 🙏 Credits

Entwickelt als Teil des **ClaudeOrchester** Projekts.

- **Author**: Rovodev
- **Version**: 3.0 (UltraThink Release)
- **Date**: 2025-10-09

---

**💡 Pro-Tip**: Kombiniere mit [Universal Mode](README.md) für maximale Produktivität! 🚀
