# Homelab-Projekt: Technische Prämissen

## Projektübersicht

Multi-Location Homelab mit einheitlichen Standards und zentraler Verwaltung über Infrastructure as Code.

### Ziel-Locations
1. **Homelab** - Hauptstandort mit Proxmox-Cluster
2. **Internet-Server** - 3 VPS für externe Konnektivität
3. **CamperVan** - Mobile Installation

## Übergreifende Standards

### Betriebssysteme
- **Standard:** Debian Bookworm
- **Raspberry Pi:** Raspberry Pi OS (Debian-basiert)
- **Begründete Ausnahme:** Home Assistant OS

### Infrastructure Management
- **Konfiguration:** Ansible Playbooks
- **Versionierung:** Git-Repository für alle Komponenten
- **Arbeitsweise:** VSCode mit Claude Plugin → Claude Code für Git-Implementierung

## Location-spezifische Konfigurationen

### Homelab
**Netzwerk-Infrastruktur:**
- Unifi-Netzwerk-Hardware
- Netzwerk-Segmentierung: Standard / IoT / Gast
- Entsprechende WLAN-Netzwerke pro Segment
- DNS: 2x Raspberry Pi (Redundanz)

**Compute-Infrastruktur:**
- **Primär:** Proxmox-Cluster für VMs
- **Sekundär:** Docker Swarm auf Raspberry Pi
- **Heimautomatisierung:** Home Assistant (dedizierte Installation)

### Internet-Infrastruktur
**Hosting-Setup:**
- 1x DNS-Hoster mit E-Mail-Capability
- 3x DNS-Domains
- 2x VPS-Hoster
- 3x VPS (1 VPS pro Domain)

**Connectivity:**
- VPN: Pangolin und/oder Headscale auf allen 3 VPS
- **Sicherheitsprinzip:** Kein Port-Forwarding zu Homelab/CamperVan

### CamperVan
**Hardware:**
- Teltonika LTE-Router
- 1x Raspberry Pi für Home Assistant

## Kritische Designentscheidungen

### VPN-Architektur
**Konzept:** 3 VPS als zentrale VPN-Knoten
- Je 1 VPS pro DNS-Domain als zentraler Knoten
- Redundanz durch parallele Domain-Pflege
- Geografische/Provider-Verteilung für Ausfallsicherheit

### DNS-Hierarchie
**Interne Auflösung:**
- `lab.TLD` - Homelab-Services
- `iot.TLD` - IoT-Geräte
- DNS-Server: 2x Raspberry Pi im Homelab

**Externe Erreichbarkeit:**
- Internet-DNS-Hoster verweist auf VPS (Pangolin/Headscale)
- Kein direkter Homelab-Zugriff von außen
- VPN-basierter Zugang über Internet-VPS

### Backup-Strategie
**Infrastructure as Code Prinzip:**
- Ansible-Playbooks + Git = vollständig reproduzierbare Infrastruktur
- Server und Services jederzeit durch Code neu erstellbar
- Daten-Backup ergänzend zu Configuration Management
- Disaster Recovery durch Code-Rebuild

### Monitoring
**Zentrale Überwachung:**
- Single Point of Truth für alle Locations
- Zentrale Monitoring-Instanz (vermutlich Homelab-Proxmox)
- Überwachung aller drei Locations von einem System

## Architektur-Implikationen

### Netzwerk-Design
- **VPN-Mesh:** Alle Locations über Internet-VPS verbunden
- **DNS-Split:** Getrennte interne/externe Namensauflösung
- **Zero-Trust:** Ausschließlich VPN-basierter Zugang

### Security-Model
- Keine direkten Port-Forwardings
- VPN-Gateway über Internet-VPS
- Netzwerk-Segmentierung im Homelab

### Operational Model
- Git-basierte Konfigurationsverwaltung
- Ansible für automatisierte Deployments
- Zentrale Dokumentation und Standards

## Nächste Schritte
1. Netzwerk-Subnetting definieren
2. Ansible-Repository-Struktur entwickeln
3. VPN-Mesh-Architektur detaillieren
4. Monitoring-Stack spezifizieren