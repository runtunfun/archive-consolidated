# MkDocs Setup & Kapitel-Erstellungsanleitung für Homelab-Dokumentation

## 1. MkDocs Grundkonfiguration

### Installation und Setup

```bash
# MkDocs und Theme installieren
pip install mkdocs
pip install mkdocs-material
pip install mkdocs-mermaid2-plugin
pip install mkdocs-table-reader-plugin
pip install mkdocs-minify-plugin

# Projekt initialisieren
mkdocs new homelab-docs
cd homelab-docs
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

### Ordnerstruktur erstellen

```bash
mkdir -p docs/{planning,network,infrastructure,services,security,inventory,operations,appendix}
mkdir -p docs/stylesheets
mkdir -p docs/images
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

### Lokales Testing

```bash
# Dokumentation lokal testen
mkdocs serve

# Build für Produktion
mkdocs build

# Deploy (z.B. GitHub Pages)
mkdocs gh-deploy
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

Diese Struktur ermöglicht es Ihnen, die Dokumentation modular zu erstellen und später nahtlos zusammenzufügen. Jeder Chat fokussiert sich auf einen spezifischen Bereich, behält aber die einheitliche Qualität und den technischen Tonfall bei.