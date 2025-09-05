#!/bin/bash

# Roadmap Auto-Detection und -Erstellung für UNIVERSAL MODE
# Wird automatisch von der Statusline aufgerufen

PROJECT_DIR="$1"
PROJECT_TYPE="$2"

if [[ -z "$PROJECT_DIR" ]]; then
    echo "Usage: $0 <project_dir> [project_type]"
    exit 1
fi

cd "$PROJECT_DIR" || exit 1

# Prüfe ob bereits eine Roadmap existiert
if [[ -f "Roadmap.md" ]] || [[ -f "ROADMAP.md" ]]; then
    echo "Roadmap bereits vorhanden"
    exit 0
fi

# Auto-Generiere Roadmap basierend auf Projekt-Typ
generate_roadmap() {
    local roadmap_file="Roadmap.md"
    
    cat > "$roadmap_file" << 'EOF'
# Roadmap

## 🎯 Projekt Übersicht
- [ ] Projekt-Setup und Initialisierung
- [ ] Entwicklungsumgebung konfiguriert
- [ ] Basis-Architektur implementiert

## 🔧 Entwicklung
- [ ] Core Features entwickelt
- [ ] UI/UX Design implementiert
- [ ] API Endpoints erstellt
- [ ] Datenbank Schema definiert

## ✅ Qualitätssicherung
- [ ] Unit Tests geschrieben (80%+ Coverage)
- [ ] Integration Tests implementiert
- [ ] Security Audit durchgeführt
- [ ] Performance optimiert

## 🚀 Deployment
- [ ] CI/CD Pipeline eingerichtet
- [ ] Production Environment vorbereitet
- [ ] Monitoring und Logging konfiguriert
- [ ] Go-Live durchgeführt

## 📚 Dokumentation
- [ ] API Dokumentation erstellt
- [ ] User Guide geschrieben
- [ ] Deployment Guide verfasst
- [ ] Wartungshandbuch aktualisiert

---
*Auto-generiert vom UNIVERSAL MODE System*
EOF

    echo "Roadmap.md automatisch erstellt"
}

# Projekt-spezifische Roadmap-Anpassungen
case "$PROJECT_TYPE" in
    "Next.js"|"React")
        generate_roadmap
        # Füge spezifische Frontend-Tasks hinzu
        ;;
    "Node.js")
        generate_roadmap
        # Füge Backend-spezifische Tasks hinzu
        ;;
    "Python")
        generate_roadmap
        # Füge Python-spezifische Tasks hinzu
        ;;
    *)
        generate_roadmap
        ;;
esac