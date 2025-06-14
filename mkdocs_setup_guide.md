# MkDocs Setup & Kapitel-Erstellungsanleitung für Homelab-Dokumentation

## 1. MkDocs Grundkonfiguration

### WSL II (Debian) Vorbereitung

```bash
# System aktualisieren
sudo apt update && sudo apt upgrade -y

# Python und Git installieren (falls nicht vorhanden)
sudo apt install -y python3 python3-pip python3-venv git

# Arbeitsverzeichnis erstellen
mkdir -p ~/projects/homelab-docs
cd ~/projects/homelab-docs
```

### Git Repository initialisieren

```bash
# Git Repository initialisieren
git init

# Basis .gitignore erstellen
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
.venv/
site/

# MkDocs
site/
.cache/

# IDEs
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log

# Temporary files
*.tmp
*.temp
EOF

# Erste Struktur committen
git add .gitignore
git commit -m "Initial commit: Add .gitignore"
```

### Python Virtual Environment Setup

```bash
# Virtual Environment erstellen
python3 -m venv venv

# Virtual Environment aktivieren
source venv/bin/activate

# pip upgraden
pip install --upgrade pip

# MkDocs und Plugins installieren
pip install mkdocs
pip install mkdocs-material
pip install mkdocs-mermaid2-plugin
pip install mkdocs-table-reader-plugin
pip install mkdocs-minify-plugin

# Requirements-Datei für Reproduzierbarkeit erstellen
pip freeze > requirements.txt

# Requirements zu Git hinzufügen
git add requirements.txt
git commit -m "Add Python requirements"
```

### Projekt initialisieren

```bash
# MkDocs Projekt initialisieren (überschreibt Standard-Struktur)
mkdocs new .

# Git Status prüfen und Standard-Dateien committen
git add .
git commit -m "Initial MkDocs project structure"
```

### Aktivierungs-Script erstellen (Optional)

```bash
# Convenience-Script für einfache Aktivierung
cat > activate_docs.sh << 'EOF'
#!/bin/bash
cd ~/projects/homelab-docs
source venv/bin/activate
echo "✅ Virtual Environment activated"
echo "📚 MkDocs Commands:"
echo "   mkdocs serve    # Local development server"
echo "   mkdocs build    # Build static site"
echo "   mkdocs --help   # Show all commands"
EOF

chmod +x activate_docs.sh

# Script zu Git hinzufügen
git add activate_docs.sh
git commit -m "Add activation convenience script"
```

### mkdocs.yml Konfiguration

```yaml
site_name: Homelab & IOT Infrastructure
site_description: Professionelle Homelab-Infrastruktur mit integrierter Smart Home Verwaltung
site_author: Admin
site_url: https://homelab-docs.example.com

# Repository
repo_name: homelab-infrastructure
repo_url: https://github.com/username/homelab-infrastructure
edit_uri: edit/main/docs/

# Theme
theme:
  name: material
  language: de
  palette:
    # Palette toggle for light mode
    - scheme: default
      primary: blue grey
      accent: blue
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode
    # Palette toggle for dark mode
    - scheme: slate
      primary: blue grey
      accent: blue
      toggle:
        icon: material/brightness-4
        name: Switch to light mode
  
  features:
    - navigation.tabs
    - navigation.sections
    - navigation.expand
    - navigation.top
    - search.highlight
    - search.share
    - content.code.copy
    - content.code.annotate
    - navigation.footer

  icon:
    repo: fontawesome/brands/github

# Plugins
plugins:
  - search:
      lang: de
  - mermaid2:
      arguments:
        theme: |
          ^(localStorage.getItem('.__palette') || '').includes('slate') ? 'dark' : 'light'
  - table-reader
  - minify:
      minify_html: true

# Extensions
markdown_extensions:
  - admonition
  - pymdownx.details
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:pymdownx.superfences.fence_code_format
  - pymdownx.tabbed:
      alternate_style: true
  - pymdownx.highlight:
      anchor_linenums: true
  - pymdownx.inlinehilite
  - pymdownx.snippets
  - pymdownx.keys
  - tables
  - footnotes
  - attr_list
  - md_in_html
  - toc:
      permalink: true

# Navigation
nav:
  - Home: index.md
  - Planung:
    - Übersicht & Ziele: planning/overview.md
    - Hardware-Anforderungen: planning/hardware.md
    - Technologie-Stack: planning/technology.md
  - Netzwerk:
    - Grundlagen: network/basics.md
    - VLAN-Konfiguration: network/vlans.md
    - UniFi Setup: network/unifi.md
    - Zone Matrix: network/zones.md
  - Infrastructure:
    - DNS-Server: infrastructure/dns.md
    - Reverse Proxy: infrastructure/proxy.md
    - HTTPS & SSL: infrastructure/ssl.md
  - Services:
    - Organisation: services/organization.md
    - Home Assistant: services/homeassistant.md
    - Monitoring: services/monitoring.md
    - Management: services/management.md
  - Sicherheit:
    - Secrets Management: security/secrets.md
    - Backup & Recovery: security/backup.md
    - Git Integration: security/git.md
  - Inventar:
    - Standard-LAN: inventory/standard-lan.md
    - IOT-VLAN: inventory/iot-vlan.md
    - Gäste-VLAN: inventory/guest-vlan.md
  - Betrieb:
    - Wartung: operations/maintenance.md
    - Troubleshooting: operations/troubleshooting.md
    - Monitoring: operations/monitoring.md
  - Anhang:
    - Deployment Guide: appendix/deployment.md
    - URLs & Zugriffe: appendix/urls.md
    - Checklisten: appendix/checklists.md
    - Support: appendix/support.md

# Extra
extra:
  version:
    provider: mike
  social:
    - icon: fontawesome/brands/github
      link: https://github.com/username
    - icon: fontawesome/solid/home
      link: https://homelab.example.com

# CSS
extra_css:
  - stylesheets/extra.css
```

### Ordnerstruktur erstellen und versionieren

```bash
# Dokumentationsstruktur erstellen
mkdir -p docs/{planning,network,infrastructure,services,security,inventory,operations,appendix}
mkdir -p docs/stylesheets
mkdir -p docs/images

# Basis-Dateien erstellen
touch docs/index.md
echo "# Bilder und Diagramme" > docs/images/README.md

# Placeholder-Dateien für Navigation erstellen (werden später überschrieben)
touch docs/planning/{overview,hardware,technology}.md
touch docs/network/{basics,vlans,unifi,zones}.md
touch docs/infrastructure/{dns,proxy,ssl}.md
touch docs/services/{organization,homeassistant,monitoring,management}.md
touch docs/security/{secrets,backup,git}.md
touch docs/inventory/{standard-lan,iot-vlan,guest-vlan}.md
touch docs/operations/{maintenance,troubleshooting,monitoring}.md
touch docs/appendix/{deployment,urls,checklists,support}.md

# Struktur zu Git hinzufügen
git add docs/
git commit -m "Create documentation structure"
```

### Extra CSS (docs/stylesheets/extra.css)

```css
/* Custom styles for technical documentation */
.md-typeset h1 {
  color: var(--md-primary-fg-color);
}

.md-typeset .admonition.estimate {
  border-color: #ff9800;
}

.md-typeset .admonition.estimate > .admonition-title {
  background-color: rgba(255, 152, 0, 0.1);
  border-color: #ff9800;
}

.md-typeset .admonition.estimate > .admonition-title::before {
  background-color: #ff9800;
  mask-image: var(--md-admonition-icon--abstract);
}

/* Code block improvements */
.md-typeset .highlight .filename {
  background: var(--md-code-bg-color);
  border-bottom: 1px solid var(--md-default-fg-color--lightest);
  font-size: 0.85em;
  font-weight: 500;
  padding: 0.5em 1em;
}

/* Table improvements */
.md-typeset table:not([class]) th {
  background-color: var(--md-default-fg-color--lightest);
}
```

## 2. Kapitel-Erstellungsanleitung

### Template für jeden Chat

Verwende diese Vorlage für jeden Kapitel-Chat:

```
Hallo Claude,

erstelle für die Homelab-Dokumentation das Kapitel "[KAPITEL-NAME]" in MkDocs-Format basierend auf dem angehängten Originaldokument.

**Vorgaben:**
- Professioneller, technischer Tonfall (nicht verkäuferisch)
- Strukturiert mit klaren Unterkapiteln
- Code-Blöcke in entsprechenden Sprachen markiert
- Diagramme als Mermaid-Code wo sinnvoll
- Aufwandsschätzung am Ende jedes Hauptabschnitts
- Admonition-Blöcke für wichtige Hinweise

**Zielkapitel:** [SPEZIFISCHE SEKTION AUS ORIGINALDOKUMENT]

**Format:** Erstelle eine oder mehrere Markdown-Dateien mit korrekten Dateinamen für die docs/-Struktur.

Das Ergebnis soll direkt in die MkDocs-Dokumentation kopierbar sein.
```

### Kapitel-Übersicht mit Aufwandsschätzungen

| Kapitel | Seiten | Komplexität | Geschätzter Aufwand | Chat-Reihenfolge |
|---------|--------|-------------|-------------------|------------------|
| **Planung** | 3 | Niedrig | 2-4 Stunden | 1 |
| **Netzwerk** | 4 | Hoch | 8-16 Stunden | 2 |
| **Infrastructure** | 3 | Hoch | 12-20 Stunden | 3 |
| **Services** | 4 | Mittel | 6-12 Stunden | 4 |
| **Sicherheit** | 3 | Hoch | 8-16 Stunden | 5 |
| **Inventar** | 3 | Niedrig | 2-6 Stunden | 6 |
| **Betrieb** | 3 | Mittel | 4-8 Stunden | 7 |
| **Anhang** | 4 | Niedrig | 2-4 Stunden | 8 |

### Tonfall-Richtlinien

**✅ Erwünscht:**
- Präzise technische Beschreibungen
- Schritt-für-Schritt Anleitungen
- Konkrete Beispiele mit echten Werten
- Warnungen vor häufigen Fehlern
- Verweise auf weiterführende Dokumentation

**❌ Vermeiden:**
- Marketing-Sprache ("revolutionär", "innovativ")
- Übertreibungen ("einfach", "mühelos")
- Unspezifische Aussagen
- Persönliche Meinungen ohne technische Begründung

### Admonition-Typen verwenden

```markdown
!!! info "Information"
    Zusätzliche Hintergrundinformationen

!!! warning "Achtung"
    Wichtige Warnungen vor häufigen Fehlern

!!! danger "Kritisch"
    Sicherheitsrelevante Hinweise

!!! tip "Tipp"
    Best Practices und Optimierungen

!!! estimate "Aufwandsschätzung"
    **Geschätzter Zeitaufwand:** 2-4 Stunden
    **Schwierigkeitsgrad:** Mittel
    **Voraussetzungen:** Docker-Grundkenntnisse
```

## 3. Empfohlene Chat-Reihenfolge

### Chat 1: Planung (planning/)
- overview.md: Ziele und Architektur-Übersicht
- hardware.md: Hardware-Anforderungen 
- technology.md: Technologie-Stack

### Chat 2: Netzwerk (network/)
- basics.md: Netzwerkplanung und IP-Bereiche
- vlans.md: VLAN-Konfiguration
- unifi.md: UniFi-Einrichtung
- zones.md: Zone Matrix

### Chat 3: Infrastructure (infrastructure/)
- dns.md: Pi-hole + Unbound Setup
- proxy.md: Traefik Konfiguration
- ssl.md: HTTPS & Let's Encrypt

### Chat 4: Services (services/)
- organization.md: Ordnerstruktur und Standards
- homeassistant.md: Home Assistant Stack
- monitoring.md: Grafana, InfluxDB, Prometheus
- management.md: Portainer

### Chat 5: Sicherheit (security/)
- secrets.md: Secrets Management
- backup.md: Backup & Recovery
- git.md: Git Integration

### Chat 6: Inventar (inventory/)
- standard-lan.md: Standard-LAN Geräte
- iot-vlan.md: IOT-VLAN Geräte
- guest-vlan.md: Gäste-VLAN

### Chat 7: Betrieb (operations/)
- maintenance.md: Wartungshinweise
- troubleshooting.md: Problembehandlung
- monitoring.md: Betriebsüberwachung

### Chat 8: Anhang (appendix/)
- deployment.md: Deployment Guide
- urls.md: Wichtige URLs
- checklists.md: Checklisten
- support.md: Support & Ressourcen

## 4. Finale Zusammenführung

### Kapitel-Dateien integrieren

```bash
# Virtual Environment aktivieren (falls nicht aktiv)
source venv/bin/activate

# Alle erhaltenen Markdown-Dateien in entsprechende Ordner kopieren
# Beispiel für Planung:
cp /path/to/received/overview.md docs/planning/
cp /path/to/received/hardware.md docs/planning/
cp /path/to/received/technology.md docs/planning/

# Nach jedem Kapitel committen
git add docs/planning/
git commit -m "Add planning chapter documentation"

# Diesen Vorgang für alle 8 Kapitel wiederholen
```

### WSL II spezifische Testing-Tipps

```bash
# Entwicklungsserver starten
mkdocs serve

# Output zeigt: Serving on http://127.0.0.1:8000/
# In Windows Browser aufrufen: http://localhost:8000/

# Alternativ: Spezifische IP binden für bessere WSL-Kompatibilität
mkdocs serve --dev-addr=0.0.0.0:8000

# Dann erreichbar unter: http://[WSL-IP]:8000/
# WSL-IP ermitteln: ip addr show eth0
```

### Build und Deployment

```bash
# Dokumentation für Produktion builden
mkdocs build

# Überprüfen der generierten Dateien
ls -la site/

# Site-Ordner zu .gitignore hinzufügen (falls noch nicht)
echo "site/" >> .gitignore

# Vollständige Dokumentation committen
git add .
git commit -m "Complete homelab documentation"

# Optional: Remote Repository hinzufügen
git remote add origin https://github.com/username/homelab-docs.git
git push -u origin main

# Deploy (z.B. GitHub Pages)
mkdocs gh-deploy
```

### Convenience Scripts für tägliche Nutzung

```bash
# Entwicklung-Script erstellen
cat > dev.sh << 'EOF'
#!/bin/bash
cd ~/projects/homelab-docs
source venv/bin/activate
echo "🚀 Starting MkDocs development server..."
mkdocs serve --dev-addr=0.0.0.0:8000
EOF

# Deploy-Script erstellen
cat > deploy.sh << 'EOF'
#!/bin/bash
cd ~/projects/homelab-docs
source venv/bin/activate
echo "🔨 Building documentation..."
mkdocs build
echo "✅ Build complete. Files in ./site/"
echo ""
echo "📤 Deploy options:"
echo "   mkdocs gh-deploy    # GitHub Pages"
echo "   rsync -av site/ user@server:/var/www/docs/  # Own server"
EOF

# Scripts ausführbar machen
chmod +x dev.sh deploy.sh

# Scripts zu Git hinzufügen
git add dev.sh deploy.sh
git commit -m "Add convenience scripts for development and deployment"
```

### Backup und Wartung

```bash
# Requirements regelmäßig aktualisieren
pip list --outdated
pip install --upgrade mkdocs mkdocs-material

# Nach Updates: Requirements neu generieren
pip freeze > requirements.txt
git add requirements.txt
git commit -m "Update Python requirements"

# Dokumentation regelmäßig sichern
git push origin main

# WSL-spezifisches Backup (Optional)
cp -r ~/projects/homelab-docs /mnt/c/backup/homelab-docs-$(date +%Y%m%d)
```

### Index-Seite (docs/index.md)

```markdown
# Homelab & IOT Infrastructure

Willkommen zur technischen Dokumentation einer professionellen Homelab-Infrastruktur mit integrierter Smart Home Verwaltung.

## Übersicht

Diese Dokumentation beschreibt eine vollständige Homelab-Lösung mit:

- **Professionelle Netzwerk-Segmentierung** mit VLANs
- **Lokale DNS-Auflösung** für Unabhängigkeit  
- **Verschlüsselte HTTPS-Services** mit Let's Encrypt
- **Skalierbare Container-Architektur** mit Docker Swarm
- **Smart Home Integration** mit Home Assistant

## Schnellstart

!!! tip "Für Eilige"
    → [Deployment Guide](appendix/deployment.md) für sofortigen Einstieg

## Navigation

Die Dokumentation ist in logische Bereiche strukturiert:

1. **[Planung](planning/overview.md)** - Ziele, Hardware, Technologien
2. **[Netzwerk](network/basics.md)** - VLANs, UniFi, Segmentierung  
3. **[Infrastructure](infrastructure/dns.md)** - DNS, Proxy, SSL
4. **[Services](services/organization.md)** - Container-Services
5. **[Sicherheit](security/secrets.md)** - Secrets, Backup, Git
6. **[Inventar](inventory/standard-lan.md)** - Geräte-Übersicht
7. **[Betrieb](operations/maintenance.md)** - Wartung, Troubleshooting
8. **[Anhang](appendix/deployment.md)** - Guides, Checklisten

## Hardware-Übersicht

**Minimum-Setup:**
- 1x Raspberry Pi 4B (DNS)
- 1x Server/Mini-PC (Services)
- UniFi Gateway + Access Point

**Empfohlen:**
- 2x Raspberry Pi 4B (redundanter DNS)
- 2-3x Server (Cluster)
- Proxmox + NAS + UniFi Ecosystem
```

## 5. Täglicher Workflow

### Dokumentation bearbeiten

```bash
# 1. Terminal öffnen und ins Projekt wechseln
cd ~/projects/homelab-docs

# 2. Virtual Environment aktivieren
source venv/bin/activate

# 3. Entwicklungsserver starten
mkdocs serve --dev-addr=0.0.0.0:8000

# 4. In anderem Terminal/Tab: Dateien bearbeiten
# Änderungen werden automatisch im Browser aktualisiert

# 5. Nach Änderungen: Git Workflow
git add .
git commit -m "Update documentation: beschreibung der änderung"
git push origin main
```

### Schnell-Aktivierung für WSL

```bash
# Alias in .bashrc hinzufügen für schnellen Zugriff
echo 'alias docs="cd ~/projects/homelab-docs && source venv/bin/activate"' >> ~/.bashrc
source ~/.bashrc

# Jetzt reicht: docs
# Gefolgt von: mkdocs serve --dev-addr=0.0.0.0:8000
```

### Troubleshooting WSL II

```bash
# Falls mkdocs serve nicht erreichbar:
# 1. WSL-IP ermitteln
ip addr show eth0 | grep inet

# 2. Windows Firewall prüfen (Windows PowerShell als Admin):
# New-NetFirewallRule -DisplayName "WSL" -Direction Inbound -InterfaceAlias "vEthernet (WSL)" -Action Allow

# 3. Alternative: Port-Forwarding (Windows PowerShell als Admin):
# netsh interface portproxy add v4tov4 listenport=8000 listenaddress=0.0.0.0 connectport=8000 connectaddress=[WSL-IP]

## 6. Kompletter Workflow - Zusammenfassung

### Einmalige Einrichtung (ca. 15 Minuten)

```bash
# 1. Projekt-Setup
mkdir -p ~/projects/homelab-docs && cd ~/projects/homelab-docs
git init
python3 -m venv venv
source venv/bin/activate

# 2. Dependencies installieren
pip install mkdocs mkdocs-material mkdocs-mermaid2-plugin mkdocs-table-reader-plugin mkdocs-minify-plugin
pip freeze > requirements.txt

# 3. MkDocs initialisieren und Struktur erstellen
mkdocs new .
mkdir -p docs/{planning,network,infrastructure,services,security,inventory,operations,appendix}
mkdir -p docs/{stylesheets,images}

# 4. Konfiguration (mkdocs.yml) und CSS erstellen
# [mkdocs.yml und extra.css aus der Anleitung kopieren]

# 5. Git Setup finalisieren
git add .
git commit -m "Initial MkDocs project setup"
```

### Dokumentation integrieren (einmalig nach Chat-Abschluss)

```bash
# 1. Alle 8 Kapitel-Dateien in entsprechende Ordner kopieren
# 2. Index-Seite erstellen (Template aus Anleitung)
# 3. Finaler Commit
git add .
git commit -m "Complete homelab documentation"
git push origin main
```

### Tägliche Nutzung

```bash
# Schnellstart (nach Alias-Setup)
docs                                    # cd + venv aktivieren
mkdocs serve --dev-addr=0.0.0.0:8000  # Entwicklungsserver

# Browser öffnen: http://localhost:8000/
# Dokumentation bearbeiten → Auto-Reload im Browser
# Git Workflow für Änderungen
```

### Deployment-Optionen

```bash
# GitHub Pages (empfohlen)
mkdocs gh-deploy

# Eigener Server
mkdocs build
rsync -av site/ user@server:/var/www/docs/

# Docker Container (erweitert)
# Dockerfile und docker-compose.yml erstellen
```

Diese Struktur ermöglicht es Ihnen, die Dokumentation modular zu erstellen und später nahtlos zusammenzufügen. Jeder Chat fokussiert sich auf einen spezifischen Bereich, behält aber die einheitliche Qualität und den technischen Tonfall bei.

**🎯 Nach diesem Setup haben Sie eine vollständig funktionierende, versionierte und professionelle MkDocs-Dokumentation für Ihr Homelab!**