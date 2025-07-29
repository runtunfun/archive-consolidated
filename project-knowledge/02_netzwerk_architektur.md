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

### 4.2 Service-Discovery Prinzip
**Homelab-Services:**
- Alle Services nutzen konsistente Namenskonvention: `[location]-[service]-[nummer].[subdomain].[domain]`
- Traefik-Labels automatisch generiert basierend auf Namensschema
- Let's Encrypt Wildcard-Zertifikate für `*.lab.enzmann.online` und `*.iot.enzmann.online`

**CamperVan-Services:**
- Vereinfachte Struktur: `[location]-[service]-[nummer].[domain]`
- Separate Domain für Mobile-Installation: `*.van.lafritzn.de`

**Beispiel-Service-Konfiguration:**
```yaml
# Docker-Compose Service-Labels
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.SERVICE_NAME.rule=Host(`FQDN`)"
  - "traefik.http.routers.SERVICE_NAME.tls.certresolver=letsencrypt"
```

*Detaillierte Service-Zuordnungen siehe: [Homelab Infrastructure Inventory](homelab-inventory.ini)*

## 5. DNS-Architektur

### 5.1 Domain-Verteilung
| Domain | DNS-Hoster | Zertifikat-Authority | Verwendung |
|--------|------------|---------------------|------------|
| **enzmann.online** | Hoster-1 | Let's Encrypt | Homelab (lab + iot) |
| **lafritzn.de** | Hoster-2 | Let's Encrypt | CamperVan |
| **runtunfun.de** | Hoster-3 | Let's Encrypt | Fallback/Redundanz |

### 5.2 DNS-Auflösung Split-Brain

**Konzept:**
- **Lokale Clients:** DNS zeigt auf lokale IPs (192.168.x.x)
- **VPN-Clients:** DNS zeigt auf VPN-IPs (10.x.x.x)
- **Gleiche FQDNs:** Transparenter Zugriff unabhängig vom Standort

**Namenskonvention:**
```bash
# Schema: [location]-[service]-[nummer].[subdomain].[domain]
lab-traefik-01.lab.enzmann.online          # Homelab Services
lab-dashboard-01.iot.enzmann.online        # IoT Services  
van-ha-01.van.lafritzn.de                  # CamperVan Services
```

**DNS-Weiterleitung:**
- **Lokale Auflösung:** Pi-hole → lokale Traefik-Instanz
- **VPN-Auflösung:** VPN-DNS → VPN-IP der Traefik-Instanz
- **Wildcard-Domains:** `*.lab.enzmann.online` → Traefik (automatische Service-Discovery)

*Konkrete DNS-Einträge siehe: [Homelab Infrastructure Inventory](homelab-inventory.ini)*

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
Client (Standard-LAN) → https://lab-ha-prod-01.lab.enzmann.online
→ Pi-hole DNS: [TRAEFIK_LOCAL_IP]
→ Traefik (Local Interface:443)
→ Home Assistant (Service IP:8123)
```

### 7.2 VPN-Zugriff (extern)
```
VPN-Client (VPN-Netz) → https://lab-ha-prod-01.lab.enzmann.online
→ VPN-DNS: [TRAEFIK_VPN_IP]
→ Traefik (VPN Interface:443)
→ Home Assistant (Service IP:8123)
```

### 7.3 CamperVan Remote-Zugriff
```
VPN-Client → https://van-ha-01.van.lafritzn.de
→ VPN-Route zu CamperVan Pi (VPN-IP)
→ Traefik auf Pi (VPN Interface)
→ Home Assistant (localhost:8123)
```

**Dual-Homing Konzept:**
- Services sind sowohl lokal als auch über VPN erreichbar
- Gleiche FQDNs, unterschiedliche IP-Auflösung je nach Client-Standort
- Transparenter Failover zwischen lokalen und VPN-Verbindungen

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

### 9.1 Ansible-Integration Konzept
```yaml
# Inventory-basierte Automation
ansible-playbook -i homelab-inventory.ini deploy-vpn-clients.yml

# VPN-Client Installation (automatisch basierend auf Inventory)
- name: Install VPN clients on designated hosts
  hosts: vpn_clients
  tasks:
    - name: Install Pangolin client
      shell: curl -sSL https://{{ vpn_server }}/install | sh
      when: vpn_server is defined
      
    - name: Authenticate VPN client  
      shell: newt auth --server {{ vpn_server }}
      when: vpn_server is defined

# Traefik-Route Generierung (basierend auf Inventory-Metadaten)
- name: Generate Traefik labels
  set_fact:
    traefik_labels:
      - "traefik.enable=true"
      - "traefik.http.routers.{{ inventory_hostname_short }}.rule=Host(`{{ https_url | regex_replace('https://') }}`)"
      - "traefik.http.routers.{{ inventory_hostname_short }}.tls.certresolver=letsencrypt"
  when: https_url is defined
```

### 9.2 Konfigurationsverwaltung
- **Inventory-Datei:** `homelab-inventory.ini` - Single Source of Truth für alle IP-Zuweisungen
- **Playbooks:** Automatische Service-Konfiguration basierend auf Inventory-Metadaten
- **Secrets:** Ansible Vault für DNS-API-Keys und Zertifikate
- **Templates:** Jinja2-Templates nutzen Inventory-Variablen für Service-Generierung

*Detaillierte Ansible-Repository-Struktur wird in separatem Planungs-Chat entwickelt*

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

## 12. Dokumentations-Architektur

### 12.1 Dokument-Aufteilung
**Diese Architektur-Dokumentation:**
- Konzeptionelle Netzwerk-Architektur und Design-Prinzipien
- VPN-Mesh-Konzept und Security-Modell  
- Traefik/HTTPS-Integration und Zertifikat-Management
- Implementierungs-Phasen und Deployment-Strategie

**Homelab Infrastructure Inventory (homelab-inventory.ini):**
- Konkrete IP-Zuweisungen und Hostnamen
- Device-Metadaten (Hersteller, Modell, Protokoll, Raum)
- Ansible-kompatible Gruppierungen und Variablen
- Service-spezifische Konfiguration (Ports, URLs, VPN-Zuweisungen)

### 12.2 Arbeitsweise
1. **Architektur-Änderungen:** In diesem Dokument planen und dokumentieren
2. **Konkrete Umsetzung:** IP-Zuweisungen und Device-Details im Inventory verwalten
3. **Automation:** Ansible-Playbooks nutzen Inventory als Single Source of Truth
4. **Wartung:** Beide Dokumente synchron halten, aber klare Trennung der Verantwortlichkeiten

### 12.3 Vorteile der Trennung
- **Wartbarkeit:** IP-Änderungen ohne Architektur-Updates
- **Automation:** Inventory direkt von Scripts und Ansible nutzbar  
- **Flexibilität:** Verschiedene Umgebungen (Prod/Test) mit eigenen Inventories
- **Übersichtlichkeit:** Architektur bleibt konzeptionell und lesbar

## 13. Offene Punkte für Detailplanung

### 13.1 Nächste Module
- [ ] **DNS-Provider APIs und Konfiguration** - als separates Modul angehen
- [ ] **Monitoring-Stack Definition** - CheckMK Raw Edition als Zwischenlösung (aufgrund vorhandener Erfahrung), später optional Prometheus/Grafana
- [ ] **Security Hardening Checklists** - VPS, Container, Netzwerk-Sicherheit
- [ ] **Inventory-Synchronisation** - Scripts für automatische Updates zwischen Dokumentation und realem Netzwerk

### 13.2 Backup-Strategie für VPN-Konfigurationen
**Was muss gesichert werden:**
- **VPN-Server Konfiguration** (Pangolin/Headscale auf VPS)
  - Server-Keys und Zertifikate
  - Client-Registrierungen und Berechtigungen
  - ACL-Regeln und Routing-Tabellen
- **Client-Konfigurationen**
  - Client-Keys und Auth-Tokens
  - Lokale VPN-Interface-Konfiguration
- **Inventory-Konsistenz**
  - VPN-IP-Zuweisungen mit tatsächlicher VPN-Konfiguration abgleichen

**Backup-Ansatz:**
- **VPS-Level:** Automatische VPS-Snapshots beim Hoster
- **Konfigurations-Level:** Git-Repository mit Ansible-Playbooks + Inventory
- **Schlüssel-Level:** Verschlüsselte Sicherung der Private Keys
- **Disaster Recovery:** Komplette Neuerstellung über Ansible + Inventory möglich

### 13.3 Implementation Ready
Die Architektur ist vollständig dokumentiert und bereit für die praktische Umsetzung. Die nächsten Schritte erfolgen in separaten, spezialisierten Planungsrunden.

*Siehe: [00_Planungsrunden.md](00_Planungsrunden.md) für detaillierte Aufgabenliste und Planungsmodule*