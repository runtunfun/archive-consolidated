# Claude Hybrid-Arbeitsweise für Homelab-Projekte

## Warum zwei Tools parallel nutzen?

### Claude Code + Git (lokales Repository)
✅ **Stärken:**
- Echte Versionskontrolle mit Git
- Direkte Dateibearbeitung ohne Copy&Paste
- IDE-Integration in VSCode
- Strukturierte Codebasis
- Vollständige Repository-Verwaltung

❌ **Schwächen:**
- Keine persistente Chat-Historie
- Kein integriertes Projektwissen-Management
- Verlust strategischer Diskussionen

### Claude Web-Projekte
✅ **Stärken:**
- Persistente Gespräche und Kontext
- Projektwissen-Feature für Standards
- Artefakte-Management mit Update-Funktionen
- Strategische Diskussionen und Planungsrunden
- Komplexe Architektur-Entscheidungen

❌ **Schwächen:**
- Fragmentierte Dateien in Chats
- Keine echte Versionskontrolle
- Artefakte müssen manuell ins Repository übertragen werden

## Empfohlener Hybrid-Ansatz

### 1. Strategische Planung → Claude Web-Projekte

**Anwendungsfälle:**
- Projektinitiierung und Architektur-Diskussionen
- Komplexe Design-Entscheidungen
- Standard-Definitionen und Richtlinien
- Multi-Session Planungsrunden
- Problemanalyse und Troubleshooting-Strategien

**Projektwissen nutzen:**
- Technische Standards und Naming-Conventions
- Arbeitsrichtlinien und Tonfall-Vorgaben
- Architektur-Prämissen und Designentscheidungen

### 2. Aktive Entwicklung → Claude Code + Git

**Anwendungsfälle:**
- Ansible-Playbook Entwicklung
- Docker-Compose Konfigurationen
- Skript-Entwicklung und Automatisierung
- Service-Konfigurationen
- Code-Reviews und Refactoring
- Direkte Datei-Manipulation

**Repository-Integration:**
- Vollständige Versionskontrolle
- Branch-Management für Features
- Continuous Integration Workflows

### 3. Projektwissen-Archivierung → Git Repository

**Workflow für Chat-Artefakte:**
- Wichtige Planungsergebnisse ins Repository übertragen
- Session-Templates für strukturierte Archivierung
- Entscheidungs-Dokumentation in standardisierter Form

## Repository-Struktur für Projektwissen

```
homelab/
├── project-knowledge/
│   ├── README.md
│   ├── 01_technische_praemissen.md
│   ├── 02_netzwerk_architektur.md
│   ├── 03_ansible_repository_struktur.md
│   ├── planning-sessions/
│   │   ├── session_template.md
│   │   ├── 2025-01-28_initial_planning.md
│   │   ├── 2025-01-28_ansible_structure.md
│   │   └── 2025-01-29_vpn_konzept.md
│   └── decisions/
│       ├── architecture_decisions.md
│       ├── technology_choices.md
│       └── naming_conventions.md
```

## Session-Template Verwendung

### 1. Vorbereitung einer Planungssession

**Vor dem Claude Web-Chat:**
```bash
# Template für neue Session kopieren
cp project-knowledge/planning-sessions/session_template.md \
   project-knowledge/planning-sessions/$(date +%Y-%m-%d)_thema.md

# Template öffnen und Ziel definieren
vim project-knowledge/planning-sessions/$(date +%Y-%m-%d)_thema.md
```

**Template-Struktur:**
```markdown
# Planning Session: [DATUM] - [THEMA]

## Ziel der Session
[Beschreibung des Planungsziels]

## Behandelte Themen
- [ ] Thema 1
- [ ] Thema 2
- [ ] Thema 3

## Entscheidungen
| Entscheidung | Begründung | Auswirkung |
|-------------|------------|------------|
| [Entscheidung] | [Grund] | [Impact] |

## Nächste Schritte
1. [ ] Aufgabe 1
2. [ ] Aufgabe 2
3. [ ] Aufgabe 3

## Artefakte
- [Link zu erzeugten Dokumenten]
- [Link zu Code-Änderungen]

## Offene Punkte
- [ ] Punkt 1
- [ ] Punkt 2
```

### 2. Während der Claude Web-Session

**Session-Dokumentation:**
- Template als Referenz für Struktur nutzen
- Wichtige Entscheidungen direkt festhalten
- Artefakte in Claude Web erstellen lassen
- Links zu generierten Dokumenten sammeln

**Beispiel-Workflow:**
1. **Ziel definieren:** "Entwicklung der Ansible-Repository-Struktur"
2. **Themen abarbeiten:** Inventory-Design, Rollen-Struktur, Secrets-Management
3. **Entscheidungen dokumentieren:** Naming-Conventions, Verzeichnis-Layout
4. **Artefakte generieren:** Vollständige Repository-Struktur als Markdown

### 3. Nach der Session - Archivierung

**Sofortige Archivierung:**
```bash
# Hauptartefakt aus Chat kopieren
cp "Ansible Repository Struktur.md" \
   project-knowledge/03_ansible_repository_struktur.md

# Session-Dokumentation vervollständigen
vim project-knowledge/planning-sessions/2025-01-28_ansible_structure.md

# Git-Commit für Session
git add project-knowledge/
git commit -m "Planning Session: Ansible Repository Struktur

- Entwicklung der Multi-Location Repository-Struktur
- Definition von Inventory und Rollen-Architektur  
- Integration von Scripts und Dokumentation
- Entscheidung für tu_* Naming-Convention"
```

**Session-Dokumentation vervollständigen:**
```markdown
# Planning Session: 2025-01-28 - Ansible Repository Struktur

## Ziel der Session
Entwicklung einer strukturierten Ansible-Repository-Architektur für Multi-Location Homelab mit Integration von Scripts und Dokumentation.

## Behandelte Themen
- [x] Repository-Root-Struktur mit separaten Verzeichnissen
- [x] Ansible-Inventory für drei Locations (Homelab, VPS, CamperVan)  
- [x] Rollen-Architektur und Playbook-Organisation
- [x] Secrets-Management mit Ansible Vault
- [x] Integration von Scripts und Dokumentation
- [x] Naming-Conventions für technische Benutzer

## Entscheidungen
| Entscheidung | Begründung | Auswirkung |
|-------------|------------|------------|
| Repository-Name: `homelab` statt `ansible-homelab` | Ganzheitliches Projekt mit Docs und Scripts | Erweiterte Struktur für Gesamtprojekt |
| Technische Benutzer: `tu_*` Präfix | Eindeutige Identifizierung Service-Accounts | Bessere Security-Policies und Monitoring |
| Ansible als Unterverzeichnis `/ansible/` | Trennung von Code, Scripts und Dokumentation | Modulare Projekt-Architektur |
| Projektwissen-Archiv `/project-knowledge/` | Archivierung von Chat-Artefakten | Vollständige Projekt-Historie in Git |

## Nächste Schritte
1. [x] Repository-Setup-Script entwickeln
2. [ ] Ansible-Common-Role implementieren
3. [ ] VPN-Client-Role für alle Locations
4. [ ] Traefik-Role mit SSL-Management
5. [ ] Monitoring-Integration definieren

## Artefakte
- [Homelab Repository Struktur](../03_ansible_repository_struktur.md)
- [Repository Setup Script](../../scripts/setup/setup_homelab_repository.sh)
- [Session Template](session_template.md)

## Offene Punkte
- [ ] DNS-Provider API-Integration für Let's Encrypt
- [ ] Backup-Strategie für VPN-Konfigurationen
- [ ] Monitoring-Stack Definition (CheckMK vs. Prometheus)
```

## Git-Workflow für Projektwissen

### Branch-Strategie für größere Planungen

```bash
# Feature-Branch für komplexe Planungsrunde
git checkout -b feature/planning-session-$(date +%Y-%m-%d)

# Alle Session-Artefakte entwickeln
# ... Planning Session durchführen ...

# Artefakte hinzufügen und committen
git add project-knowledge/
git commit -m "Planning Session: VPN-Konzept und Implementation"

# Zurück zu main und merge
git checkout main
git merge feature/planning-session-$(date +%Y-%m-%d)
git branch -d feature/planning-session-$(date +%Y-%m-%d)
```

### Tagging für Meilensteine

```bash
# Wichtige Planungsmeilensteine taggen
git tag -a v0.1-planning -m "Grundlegende Architektur-Entscheidungen abgeschlossen"
git tag -a v0.2-ansible-struktur -m "Ansible-Repository-Struktur definiert"
```

## Praktische Anwendungsbeispiele

### Beispiel 1: Neue Service-Integration

**Claude Web-Projekt:**
```
Nutzer: "Ich möchte Grafana in mein Homelab integrieren. 
Wie füge ich das in meine bestehende Ansible-Struktur ein?"

Claude: [Analysiert Projektwissen über Ansible-Struktur]
- Erstellt Grafana-Rolle
- Integriert in Traefik-Routing  
- Dokumentiert Service-Konfiguration
```

**Archivierung:**
- Session: `2025-01-30_grafana_integration.md`
- Artefakt: Rolle direkt ins Repository über Claude Code
- Dokumentation: `docs/services/grafana-setup.md`

### Beispiel 2: Troubleshooting und Analyse

**Claude Web-Projekt:**
```
Nutzer: "VPN-Verbindung zwischen Locations fällt regelmäßig aus.
Wie analysiere ich das systematisch?"

Claude: [Nutzt Projektwissen über VPN-Architektur]
- Entwickelt Debugging-Strategie
- Erstellt Monitoring-Scripts
- Dokumentiert Troubleshooting-Workflow
```

**Archivierung:**
- Session: `2025-01-30_vpn_troubleshooting.md`
- Script: `scripts/monitoring/diagnose_vpn_issues.sh`
- Dokumentation: `docs/troubleshooting/vpn-connectivity.md`

## Konsistenz zwischen beiden Umgebungen

### Identische Arbeitsrichtlinien

**In beiden Umgebungen:**
- Technischer, professioneller Tonfall
- Modulare Problemzerlegung
- Konsistente Naming-Conventions (`kebab-case`, `tu_*` für tech. User)
- Structured Outputs mit klaren Kapiteln

### Regelmäßige Synchronisation

**Wöchentlich:**
- Wichtige Standards aus Web-Projekten ins Repository übertragen
- Entscheidungen in `decisions/` dokumentieren
- Template-Updates basierend auf Erfahrungen

**Bei größeren Änderungen:**
- Architektur-Entscheidungen sofort archivieren
- Naming-Convention-Updates in beide Umgebungen
- Backup der Projektwissen-Standards

## Vorteile des Hybrid-Ansatzes

### Strategische Ebene (Web-Projekte)
- **Persistenter Kontext:** Komplexe Diskussionen über mehrere Sessions
- **Projektwissen-Integration:** Standards und Entscheidungen bleiben verfügbar
- **Artefakt-Management:** Strukturierte Dokumenterstellung mit Updates

### Operative Ebene (Claude Code + Git)
- **Direkte Implementation:** Keine Copy&Paste-Workflows
- **Versionskontrolle:** Vollständige Änderungshistorie
- **IDE-Integration:** Professionelle Entwicklungsumgebung

### Archivierung (Git Repository)
- **Single Source of Truth:** Alle wichtigen Entscheidungen zentral verfügbar
- **Nachvollziehbarkeit:** Komplette Projektentwicklung dokumentiert
- **Team-Kollaboration:** Strukturiertes Wissen für andere Entwickler

## Fazit

Die Kombination aus Claude Web-Projekten für strategische Planung und Claude Code für operative Entwicklung, ergänzt durch systematische Archivierung im Git-Repository, ermöglicht:

- **Strukturierte Projektentwicklung** mit persistentem Wissen
- **Professionelle Code-Entwicklung** mit Versionskontrolle
- **Vollständige Dokumentation** aller Entscheidungen und Entwicklungsschritte
- **Konsistente Arbeitsweise** über alle Tools hinweg

Diese Arbeitsweise skaliert von kleinen Scripts bis hin zu komplexen Multi-Location-Infrastrukturen und stellt sicher, dass sowohl Code als auch Projektwissen professionell verwaltet werden.