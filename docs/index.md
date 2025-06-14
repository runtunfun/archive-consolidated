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
