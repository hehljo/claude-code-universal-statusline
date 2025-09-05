# Statusline Guide - Claude Universal Mode

## 🧠 Claude Model Indikatoren

Das **Hirn-Emoji mit Buchstabe** in der Statusline zeigt das aktuell verwendete Claude-Modell an:

### Model Mapping:

| Statusline | Vollständiger Name | Beschreibung |
|------------|-------------------|--------------|
| **🧠S** | **Claude Sonnet** | Ausgewogenes Modell - Standard für die meisten Aufgaben |
| **🧠H** | **Claude Haiku** | Schnelles, leichtgewichtiges Modell für einfache Tasks |
| **🧠O** | **Claude Opus** | Mächtigstes Modell für komplexe Aufgaben (falls verfügbar) |
| **🧠4** | **Claude Sonnet 4** | Neueste Sonnet Version mit erweiterten Fähigkeiten |

### 🎯 Model Selection Logic

```bash
case "$model" in
    *"sonnet-4"*) model_icon="🧠4" ;;
    *"sonnet"*) model_icon="🧠S" ;;
    *"haiku"*) model_icon="🧠H" ;;
    *"opus"*) model_icon="🧠O" ;;
    *) model_icon="🧠?" ;;
esac
```

## 📖 Output Style Indikatoren

Das letzte Symbol zeigt den konfigurierten Output-Style:

| Symbol | Style | Beschreibung |
|--------|-------|--------------|
| **📖** | **Explanatory** | Detaillierte Erklärungen und Kontext |
| **🎓** | **Learning** | Lern-fokussierte Antworten mit Beispielen |
| **⚡** | **Concise** | Kurze, prägnante Antworten |
| **🔧** | **Technical** | Technisch-fokussierte Ausgabe |
| **📝** | **Default** | Standard Claude Antworten |

## 📊 Komplette Statusline Erklärung

```bash
🌐 UNIVERSAL | MCP:6/8 | 12/24 | git:main✓ | Next.js | 🧠S | 📖
```

### Aufschlüsselung:

1. **🌐 UNIVERSAL** 
   - System voll aktiv
   - Alle MCP Tools verfügbar
   - Auto-Roadmap funktioniert

2. **MCP:6/8**
   - 6 von 8 MCP Servern verfügbar
   - Fehlende: z.B. postgres, memory

3. **12/24**
   - 12 von 24 Roadmap-Tasks erledigt
   - 50% Projekt-Fortschritt

4. **git:main✓**
   - Git Branch: main
   - Status: ✓ (clean), ○ (changes), ● (staged)

5. **Next.js**
   - Erkannter Projekt-Typ
   - Auto-detection basierend auf package.json

6. **🧠S**
   - Claude Sonnet Modell aktiv
   - Optimale Balance für die meisten Tasks

7. **📖**
   - Explanatory Output Style
   - Detaillierte, erklärende Antworten

## 🔧 Konfiguration

Die Statusline kann über folgende Dateien angepasst werden:

- **Global:** `/root/.claude/settings.json`
- **Projekt:** `./claude/statusline-config.json`

### Beispiel-Konfiguration:

```json
{
  "statusline": {
    "show_model": true,
    "show_mcp_count": true,
    "show_roadmap_progress": true,
    "show_git_status": true,
    "compact_mode": false
  }
}
```

## 🎨 Anpassung

### Custom Model Icons:

```bash
# In universal-statusline.sh
custom_model_icons() {
    case "$1" in
        "custom-model") echo "🤖C" ;;
        "experimental") echo "🧪E" ;;
        *) echo "🧠?" ;;
    esac
}
```

### Neue Status Modi:

```bash
# Eigene Status-Modi hinzufügen
case "$mode" in
    "development") echo "🚧 DEV MODE" ;;
    "production") echo "🚀 PROD MODE" ;;
    "testing") echo "🧪 TEST MODE" ;;
esac
```

Das System ist vollständig anpassbar und erweiterbar!