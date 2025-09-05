# UNIVERSAL MODE Statusline System

Das UNIVERSAL MODE System ist eine erweiterte Statusline für Claude Code, die automatisch die verfügbaren MCP Server, Agents und Projekt-Status erkennt und anzeigt.

## 🌐 Status Modi

### 🌐 UNIVERSAL MODE
- Alle MCP Server verfügbar (6-8/8)
- Lokale CLAUDE.md vorhanden
- Roadmap aktiv mit Progress Tracking
- Vollständige Agent Integration

### 🔧 PARTIAL MODE  
- Einige MCP Server fehlen (3-5/8)
- Grundfunktionen verfügbar
- Möglicherweise ohne Roadmap

### 📋 ROADMAP ONLY
- Nur Roadmap Tracking aktiv
- Minimale MCP Integration
- Basis-Funktionalität

### ❌ DISABLED
- CLAUDE_TEMPLATE_GLOBAL.md nicht gefunden
- System deaktiviert
- Fallback auf Standard-Statusline

## 🛠️ Core Features

### Auto-MCP Detection
Erkennt automatisch verfügbare MCP Server:
- **filesystem:** Erweiterte Dateisystem-Operationen
- **github:** Repository-Management und GitHub-Integration  
- **postgres:** Direkte PostgreSQL-Operationen
- **brave-search:** Web-Recherche für aktuelle Informationen
- **puppeteer:** Browser-Automation für E2E-Testing
- **memory:** Persistente Wissensspeicherung zwischen Sessions
- **everything:** Referenz-Server für Testing und Development
- **sequential-thinking:** Komplexe Problem-Lösung

### Agent Integration (13 Spezialisten)
Automatische Erkennung und Integration von:
- 🔒 SecurityAuditor - Security-Scans und DSGVO-Compliance
- 🏗️ BackendArchitect - Server-Architektur und API-Design
- 📚 DocumentationAutomator - Automatische Dokumentation
- 🧪 TestAutomationEngineer - Test-Strategien und -Implementierung
- 🎨 FrontendSpecialist - UI/UX und Frontend-Optimierung
- 💾 DataEngineeringExpert - Datenbanken und ETL-Pipelines
- 📱 MobileDevelopmentExpert - Mobile App Entwicklung
- 🤖 MachineLearningSpecialist - AI/ML Implementierung
- ⚙️ DevOpsEngineer - CI/CD und Infrastructure
- 🎯 UIUXDesigner - Design und User Experience
- ✅ QualityAssuranceSpecialist - Quality Assurance
- ⚡ PerformanceOptimizer - Performance Optimierung
- 📋 ComplianceAuditor - Compliance und Audit

### Auto-Roadmap Creation
- Automatische Erstellung von Roadmap.md bei neuen Projekten
- Projekt-typ-spezifische Task-Templates
- Progress Tracking mit Checkbox-System
- Integration in Statusline

### Git Integration
- Branch-Anzeige mit Status-Indikatoren
- ✓ Clean working directory
- ● Staged changes
- ○ Unstaged changes

### Project Type Detection
Automatische Erkennung von:
- Next.js (next in package.json)
- React (react in package.json)
- Vue.js (vue in package.json)
- Node.js (package.json vorhanden)
- Python (requirements.txt/pyproject.toml)
- Rust (Cargo.toml)
- Go (go.mod)
- PHP (composer.json)

## 📋 Statusline Ausgabe-Format

```
🌐 UNIVERSAL | MCP:6/8 | 12/24 | git:main✓ | Next.js | 🧠S | 📖
```

### Komponenten
1. **Mode:** 🌐 UNIVERSAL / 🔧 PARTIAL / 📋 ROADMAP / ❌ DISABLED
2. **MCP Status:** Verfügbare/Gesamt MCP Server
3. **Roadmap:** Erledigte/Gesamt Tasks
4. **Git:** Branch + Status (✓○●)
5. **Projekt-Typ:** Erkanntes Framework
6. **Model:** 🧠S(onnet) / 🧠H(aiku) / 🧠O(pus)
7. **Output Style:** 📖(Explanatory) / 🎓(Learning)

## 🔧 Installation & Konfiguration

### Automatische Installation
Das System ist bereits konfiguriert mit:
```json
{
  "statusLine": {
    "type": "command",
    "command": "bash /root/.claude/universal-statusline.sh"
  }
}
```

### Dateien
- `/root/.claude/universal-statusline.sh` - Haupt-Statusline Script
- `/root/.claude/roadmap-detector.sh` - Auto-Roadmap Generator
- `/root/.claude/CLAUDE_TEMPLATE_GLOBAL.md` - Globale Konfiguration

### Aktivierung
1. CLAUDE_TEMPLATE_GLOBAL.md muss vorhanden sein
2. Lokale CLAUDE.md für vollständige Funktionalität
3. Roadmap.md wird automatisch erstellt

## 🚀 Verwendung

### Projekt-Start
1. Navigiere zum Projekt-Ordner
2. Statusline erkennt automatisch:
   - Verfügbare MCP Server
   - Projekt-Typ
   - Git-Status
   - Roadmap-Status

### Roadmap Management
- Automatische Erstellung bei neuen Projekten
- Manual: `bash /root/.claude/roadmap-detector.sh /pfad/zum/projekt [projekt-typ]`
- Progress wird automatisch in Statusline angezeigt

### MCP Integration
- Alle verfügbaren MCP Server werden automatisch erkannt
- Status wird in Echtzeit aktualisiert
- Fehlende Server werden angezeigt

## 📊 Status Beispiele

```bash
# Vollständiger UNIVERSAL MODE
🌐 UNIVERSAL | MCP:8/8 | 18/24 | git:main✓ | Next.js | 🧠S

# Teilweise verfügbare Tools
🔧 PARTIAL | MCP:5/8 | 12/24 | git:feature○ | React | 🧠S

# Nur Roadmap aktiv
📋 ROADMAP | 6/18 | git:main● | Node.js | 🧠H

# System deaktiviert
❌ DISABLED | git:main✓ | Python | 🧠S
```

## 🔄 Updates & Anpassungen

Für weitere Änderungen an der Statusline wende dich an den "statusline-setup" Agent. Das System kann kontinuierlich erweitert und angepasst werden.

### Erweiterungsmöglichkeiten
- Zusätzliche MCP Server Integration
- Neue Agent-Spezialisierungen
- Erweiterte Projekt-Typ-Erkennung
- Custom Status-Indikatoren
- Performance-Monitoring Integration

---

**Version:** 1.0.0  
**Erstellt:** September 2025  
**Basiert auf:** CLAUDE_TEMPLATE_GLOBAL.md  
**Kompatibilität:** Claude Code v1.0+