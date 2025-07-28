# Homelab Multi-Location Netzwerk-Architektur

## 1. Projektübersicht

Multi-Location Homelab mit Zero-Trust VPN-Zugang über Internet-VPS und einheitlichem HTTPS-Zugriff über Traefik.

### 1.1 Locations
1. **Homelab** - Hauptstandort mit Proxmox-Cluster, Docker Swarm, UniFi-Netzwerk
2. **CamperVan** - Mobile Installation mit Raspberry Pi und LTE-Router
3. **Internet-VPS** - 3 VPS für VPN-Server und externe Konnektivität

## 2. VPN-Architektur

### 2.1 VPN-Server auf Internet-VPS
| VPS | Domain | VPN-Software | VPN-Netzbereich | Primäre Zielgruppe |
|-----|--------|-------------|----------------|-------------------|
| **VPS-1** | ds9.enzmann.online | Pangolin (newt) | 10.1.0.0/24 | Homelab Services |
| **VPS-2** | ds9.lafritzn.de | Pangolin (newt) | 10.2.0.0/24 | CamperVan (primär) |
| **VPS-3** | ds9.runtunfun.de | Headscale | 100.64.0.0/24 | Fallback/Redundanz |

### 2.2 VPN-Client Konzept
**Funktionsweise:**
- Clients installieren VPN-Software (`newt` oder `tailscale`)
- Authentifizierung beim jeweiligen VPN-Server
- **Server weist automatisch VPN-IP zu** (nicht statisch geplant)
- Client erhält Dual-Homing: lokale IP + VPN-IP

**Homelab VPN-Clients (ds9.enzmann.online):**
- Proxmox-Host: `newt client` → zugewiesene IP aus 10.1.0.0/24
- Home Assistant: `newt client` → zugewiesene IP aus 10.1.0.0/24
- Traefik: `newt client` → zugewiesene IP aus 10.1.0.0/24
- Pi-hole: `newt client` → zugewiesene IP aus 10.1.0.0/24

**CamperVan VPN-Client (ds9.lafritzn.de):**
- Raspberry Pi: `newt client` → zugewiesene IP aus 10.2.0.0/24

**Fallback (ds9.runtunfun.de):**
- Alle Services können zusätzlich `tailscale` → zugewiesene IP aus 100.64.0.0/24

## 3. Lokale Netzwerke

### 3.1 Homelab-Netzwerk (bestehend)
| VLAN | Name | Subnetz | Gateway | Zweck |
|------|------|---------|---------|-------|
| **1** | Standard-LAN | 192.168.1.0/24 | 192.168.1.1 | Homelab & Management |
| **100** | IOT-VLAN | 192.168.100.0/22 | 192.168.100.1 | Smart Home + Mobile Clients |
| **200** | Gäste-VLAN | 192.168.200.0/24 | 192.168.200.1 | Gast-Zugang |

**DNS-Server:**
- Primary: 192.168.1.3 (Pi-hole #1)
- Secondary: 192.168.1.4 (Pi-hole #2)

### 3.2 CamperVan-Netzwerk
| Komponente | IP-Bereich | Gateway | Zweck |
|------------|------------|---------|-------|
| **LTE-Router** | 192.168.50.1 | - | Internet-Gateway |
| **Raspberry Pi** | 192.168.50.10 | 192.168.50.1 | Home Assistant + VPN-Client |
| **DHCP Pool** | 192.168.50.20-50 | 192.168.50.1 | Mobile Geräte |

## 4. HTTPS/Traefik-Architektur

### 4.1 Traefik-Instanzen
| Location | Installation | Lokale IP | VPN-IP | Zertifikat-Domains |
|----------|-------------|-----------|--------|--------------------|
| **Homelab** | Docker Swarm | 192.168.1.50 | zugewiesen aus 10.1.0.0/24 | *.lab.enzmann.online<br>*.iot.enzmann.online |
| **CamperVan** | HA Add-on/Docker | 192.168.50.10 | zugewiesen aus 10.2.0.0/24 | *.van.lafritzn.de |

### 4.2 Service-Routing Homelab
| Service | Lokale IP | HTTPS-URL | Traefik-Route |
|---------|-----------|-----------|---------------|
| **Proxmox** | 192.168.1.21:8006 | https://pve.lab.enzmann.online | traefik → 192.168.1.21:8006 |
| **Home Assistant** | 192.168.1.45:8123 | https://ha.lab.enzmann.online | traefik → 192.168.1.45:8123 |
| **Pi-hole** | 192.168.1.3:80 | https://dns.lab.enzmann.online | traefik → 192.168.1.3:80 |
| **Unifi Controller** | 192.168.1.10:8443 | https://unifi.lab.enzmann.online | traefik → 192.168.1.10:8443 |
| **IoT-Dashboard** | 192.168.1.46:3000 | https://dashboard.iot.enzmann.online | traefik → 192.168.1.46:3000 |
| **Traefik Dashboard** | 192.168.1.50:8080 | https://traefik.lab.enzmann.online | - |

### 4.3 Service-Routing CamperVan
| Service | Lokale IP | HTTPS-URL | Traefik-Route |
|---------|-----------|-----------|---------------|
| **Home Assistant** | 192.168.50.10:8123 | https://ha.van.lafritzn.de | traefik → localhost:8123 |
| **Traefik Dashboard** | 192.168.50.10:8080 | https://traefik.van.lafritzn.de | - |

## 5. DNS-Architektur

### 5.1 Domain-Verteilung
| Domain | DNS-Hoster | Zertifikat-Authority | Verwendung |
|--------|------------|---------------------|------------|
| **enzmann.online** | Hoster-1 | Let's Encrypt | Homelab (lab + iot) |
| **lafritzn.de** | Hoster-2 | Let's Encrypt | CamperVan |
| **runtunfun.de** | Hoster-3 | Let's Encrypt | Fallback/Redundanz |

### 5.2 DNS-Auflösung Split-Brain
**Lokale Auflösung (Pi-hole):**
- `lab.enzmann.online` → 192.168.1.50 (Traefik lokal)
- `iot.enzmann.online` → 192.168.1.50 (Traefik lokal)
- `van.lafritzn.de` → 192.168.50.10 (Traefik CamperVan)

**VPN-Auflösung (über VPN-DNS):**
- `lab.enzmann.online` → VPN-IP von Traefik
- `iot.enzmann.online` → VPN-IP von Traefik
- `van.lafritzn.de` → VPN-IP von CamperVan Pi

## 6. Zertifikat-Management

### 6.1 Let's Encrypt DNS-Challenge
**Homelab (enzmann.online):**
```yaml
certificatesResolvers:
  letsencrypt-enzmann:
    acme:
      email: admin@enzmann.online
      storage: /data/acme-enzmann.json
      dnsChallenge:
        provider: ${DNS_PROVIDER_ENZMANN}
```

**CamperVan (lafritzn.de):**
```yaml
certificatesResolvers:
  letsencrypt-lafritzn:
    acme:
      email: admin@lafritzn.de
      storage: /data/acme-lafritzn.json
      dnsChallenge:
        provider: ${DNS_PROVIDER_LAFRITZN}
```

### 6.2 Wildcard-Zertifikate
- **Homelab:** `*.lab.enzmann.online`, `*.iot.enzmann.online`
- **CamperVan:** `*.van.lafritzn.de`
- **Fallback:** `*.fallback.runtunfun.de`

## 7. Netzwerk-Flow Beispiele

### 7.1 Lokaler Zugriff (Homelab)
```
Client (192.168.1.100) → https://ha.lab.enzmann.online
→ Pi-hole DNS: 192.168.1.50
→ Traefik (192.168.1.50:443)
→ Home Assistant (192.168.1.45:8123)
```

### 7.2 VPN-Zugriff (extern)
```
VPN-Client (10.1.0.15) → https://ha.lab.enzmann.online
→ VPN-DNS: Traefik-VPN-IP
→ Traefik (VPN-IP:443)
→ Home Assistant (192.168.1.45:8123)
```

### 7.3 CamperVan Remote-Zugriff
```
VPN-Client → https://ha.van.lafritzn.de
→ VPN-Route zu CamperVan Pi (VPN-IP)
→ Traefik auf Pi
→ Home Assistant (localhost:8123)
```

## 8. Sicherheitskonzept

### 8.1 Zero-Trust Prinzipien
- **Kein Port-Forwarding** zu Homelab oder CamperVan
- **Ausschließlich VPN-Zugang** für externe Erreichbarkeit
- **End-to-End HTTPS** über Let's Encrypt Zertifikate
- **Netzwerk-Segmentierung** im Homelab (VLANs)

### 8.2 Redundanz-Strategie
- **Primär:** Homelab → ds9.enzmann.online, CamperVan → ds9.lafritzn.de
- **Fallback:** Beide → ds9.runtunfun.de (Headscale)
- **DNS-Failover:** Automatisch über DNS-TTL
- **Multi-Provider:** 3 verschiedene VPS-Hoster

## 9. Infrastructure as Code

### 9.1 Ansible-Integration
```yaml
# Beispiel: VPN-Client Installation
- name: Install Pangolin client
  shell: curl -sSL https://{{ vpn_server }}/install | sh

- name: Authenticate VPN client
  shell: newt auth --server {{ vpn_server }}
  # Server weist automatisch VPN-IP zu

- name: Deploy Traefik with VPN support
  docker_stack:
    name: traefik
    compose:
      - traefik-compose.yml
```

### 9.2 Konfigurationsverwaltung
- **Git-Repository:** Alle Ansible Playbooks und Konfigurationen
- **Secrets:** Ansible Vault für DNS-API-Keys und Zertifikate
- **Versionierung:** Vollständig reproduzierbare Infrastruktur
- **Dokumentation:** Markdown in Git-Repository

## 10. Vorteile dieser Architektur

### 10.1 Sicherheit
- **End-to-End HTTPS** für alle Services über Let's Encrypt
- **Keine selbst-signierten Zertifikate** - professionelle PKI
- **DNS-Challenge ohne Port-Forwards** - keine Firewall-Öffnungen nötig
- **Zero-Trust-Prinzip** - ausschließlich authentifizierte VPN-Zugriffe
- **Netzwerk-Segmentierung** - IoT getrennt von Management-Netz
- **Multi-Provider-Redundanz** - Ausfallsicherheit durch 3 VPS-Hoster

### 10.2 Wartbarkeit
- **Zentrale SSL/TLS-Verwaltung** über Traefik und DNS-Challenge
- **Automatische Zertifikat-Erneuerung** - keine manuellen Eingriffe
- **Service-Discovery über Labels** - neue Services einfach hinzufügbar
- **Infrastructure as Code** - vollständig reproduzierbare Konfiguration
- **Einheitliche Standards** - Debian, Docker, Ansible überall
- **Git-basierte Versionierung** - Änderungen nachvollziehbar

### 10.3 Flexibilität
- **Services einfach hinzufügbar** - Container mit Traefik-Labels
- **Lokaler + VPN-Zugriff transparent** - gleiche URLs, verschiedene Routen
- **Skalierbar über Docker Swarm** - horizontale Erweiterung möglich
- **Multi-Location-fähig** - einheitliches Konzept für alle Standorte
- **Provider-unabhängig** - VPS und DNS-Hoster austauschbar
- **Mobile Integration** - CamperVan nahtlos eingebunden

## 11. Implementierungsreihenfolge

### 11.1 Phase 0: Netzwerk-Grundlagen
1. **Homelab-Netzwerk etablieren**
   - UniFi-Hardware Setup und VLAN-Konfiguration
   - Pi-hole Installation und DNS-Konfiguration
   - Proxmox-Cluster Setup
2. **CamperVan-Netzwerk etablieren**
   - LTE-Router Konfiguration
   - Raspberry Pi Setup mit Home Assistant
3. **Basis-Services etablieren**
   - Grundlegende Container-Services
   - Lokale HTTP-Erreichbarkeit sicherstellen

### 11.2 Phase 1: VPN-Infrastruktur
1. VPS-Setup und Domain-Konfiguration
2. Pangolin/Headscale Installation auf VPS
3. VPN-Client Installation in Homelab und CamperVan
4. Grundlegende VPN-Konnektivität testen

### 11.3 Phase 2: HTTPS/Traefik
1. Traefik-Setup im Homelab (Docker Swarm)
2. DNS-Challenge Konfiguration für Let's Encrypt
3. Service-Migration zu HTTPS
4. Lokale und VPN-basierte HTTPS-Zugriffe testen

### 11.4 Phase 3: CamperVan Integration
1. Traefik-Setup als Home Assistant Add-on oder Docker
2. VPN-Integration und End-to-End Tests
3. Mobile DNS-Konfiguration und Failover-Tests

### 11.5 Phase 4: Monitoring & Automatisierung
1. Monitoring-Lösung (CheckMK Raw Edition oder Prometheus/Grafana)
2. Ansible-Automatisierung für alle Komponenten
3. Backup-Strategien implementieren

**Hinweis:** Die aktuell definierten Services sind Zwischenschritte - im Projektverlauf werden weitere Services detailliert konfiguriert und hinzugefügt.

## 12. Offene Punkte für Detailplanung

### 12.1 Nächste Module
- [ ] **DNS-Provider APIs und Konfiguration** - als separates Modul angehen
- [ ] **Monitoring-Stack Definition** - CheckMK Raw Edition als Zwischenlösung (aufgrund vorhandener Erfahrung), später optional Prometheus/Grafana
- [ ] **Security Hardening Checklists** - VPS, Container, Netzwerk-Sicherheit

### 12.2 Backup-Strategie für VPN-Konfigurationen
**Was muss gesichert werden:**
- **VPN-Server Konfiguration** (Pangolin/Headscale auf VPS)
  - Server-Keys und Zertifikate
  - Client-Registrierungen und Berechtigungen
  - ACL-Regeln und Routing-Tabellen
- **Client-Konfigurationen**
  - Client-Keys und Auth-Tokens
  - Lokale VPN-Interface-Konfiguration

**Backup-Ansatz:**
- **VPS-Level:** Automatische VPS-Snapshots beim Hoster
- **Konfigurations-Level:** Git-Repository mit Ansible-Playbooks
- **Schlüssel-Level:** Verschlüsselte Sicherung der Private Keys
- **Disaster Recovery:** Komplette Neuerstellung über Ansible möglich

### 12.3 Spätere Planungsrunden
- [ ] **Ansible-Repository-Struktur** - eigener Chat für detaillierte Entwicklung
- [ ] **Disaster Recovery Procedures** - eigener Chat für Notfall-Szenarien