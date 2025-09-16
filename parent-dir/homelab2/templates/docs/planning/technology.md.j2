# Technologie-Stack

## Überblick der Technologien

Die Homelab-Infrastruktur basiert auf bewährten Open-Source-Technologien, die für Stabilität, Sicherheit und Skalierbarkeit optimiert sind.

| Komponente | Technologie | Version | Zweck |
|------------|-------------|---------|-------|
| **Netzwerk** | UniFi | 8.x | VLAN-Management, WiFi, Firewall |
| **DNS** | Pi-hole + Unbound | Latest | Lokale Auflösung, Ad-Blocking, Recursive DNS |
| **Reverse Proxy** | Traefik | v3.0 | HTTPS-Terminierung, Let's Encrypt |
| **Container** | Docker Swarm | Latest | Service-Orchestrierung |
| **Smart Home** | Home Assistant | 2024.x | IOT-Integration, Automatisierung |
| **Monitoring** | Grafana + InfluxDB | Latest | Metriken, Dashboards |
| **Secrets** | GPG + Git | - | Sichere Konfigurationsverwaltung |
| **Domain** | netcup | - | DNS-Provider für Let's Encrypt |

## Netzwerk-Layer

### UniFi Ecosystem

**UniFi Controller**
```yaml
Zweck: Zentrale Verwaltung der Netzwerk-Infrastruktur
Features:
  - VLAN-Management
  - WiFi-Konfiguration  
  - Firewall-Regeln
  - Traffic-Monitoring
  - Zero-Touch-Provisioning

Deployment-Optionen:
  - Integriert (UDM Pro/SE)
  - Standalone (VM/Container)
  - Cloud-basiert (UniFi Cloud)
```

**VLAN-Architektur**
```yaml
Standard-LAN (Default):
  Subnet: 192.168.1.0/24
  Verwendung: Homelab & Management
  
IOT-VLAN (100):
  Subnet: 192.168.100.0/22
  Verwendung: Smart Home + Mobile Clients
  
Gäste-VLAN (200):
  Subnet: 192.168.200.0/24
  Verwendung: Gast-Zugang (isoliert)
```

!!! info "UniFi-Vorteile"
    - **Einheitliche Verwaltung**: Ein Controller für alle Netzwerk-Komponenten
    - **Enterprise-Features**: VLANs, QoS, IDS/IPS, Traffic-Shaping
    - **Skalierbarkeit**: Von Home bis Enterprise
    - **Community**: Große Nutzerbase und Dokumentation

### Firewall & Routing

**Zone-basierte Firewall**
```yaml
Zone-Matrix:
  Internal → IOT: Limited (nur notwendige Ports)
  Internal → Hotspot: Limited (nur DNS/NTP)
  IOT → Internal: Deny (außer Home Assistant)
  Hotspot → Internal/IOT: Deny
  Alle → Internet: Allow
```

**Traffic-Regeln**
```yaml
IOT → Internal (Limited Access):
  - Port 53 (DNS zu Pi-hole)
  - Port 123 (NTP)  
  - Port 8123 (Home Assistant)
  - Port 1883/8883 (MQTT)
  - Port 5353 (mDNS)

Hotspot → Internal (Minimal Access):
  - Port 53 (DNS)
  - Port 123 (NTP)
```

## DNS-Layer

### Pi-hole + Unbound

**Architektur-Vorteile**
```yaml
Pi-hole:
  - Ad-Blocking auf DNS-Ebene
  - Lokale DNS-Records
  - Query-Logging und -Statistiken
  - Web-Interface für Management

Unbound:
  - Recursive DNS-Server
  - DNSSEC-Validierung
  - Caching für Performance
  - Keine Abhängigkeit von externen DNS-Anbietern
```

**DNS-Resolution-Flow**
```mermaid
graph LR
    A[Client] --> B[Pi-hole]
    B --> C{Lokale Domain?}
    C -->|Ja| D[Lokale Records]
    C -->|Nein| E[Unbound]
    E --> F[Root DNS]
    F --> G[Authoritative DNS]
    D --> A
    G --> E --> B --> A
```

**Hochverfügbarkeit**
```yaml
Primary Pi-hole (192.168.1.3):
  - Hauptserver mit lokalen DNS-Records
  - Gravity Sync Master

Secondary Pi-hole (192.168.1.4):  
  - Backup-Server
  - Automatische Synchronisation
  - Failover via DHCP-Konfiguration
```

!!! warning "DNS-Kritikalität"
    DNS ist der kritischste Service in der Infrastruktur. Ohne funktionierende DNS-Auflösung sind keine Services erreichbar. Redundanz ist daher essentiell.

## Container-Layer

### Docker Swarm

**Warum Docker Swarm statt Kubernetes?**
```yaml
Vorteile:
  - Einfache Installation und Verwaltung
  - Integriert in Docker Engine
  - Geringerer Ressourcen-Overhead
  - Perfekt für Homelab-Größe

Nachteile:
  - Weniger Features als Kubernetes
  - Kleinere Community
  - Weniger Third-Party-Tools
```

**Swarm-Architektur**
```yaml
Manager Node (192.168.1.45):
  - Cluster-Management
  - Service-Scheduling
  - Load-Balancing
  - Ingress-Networking

Worker Nodes (192.168.1.46-48):
  - Container-Ausführung
  - Skalierung
  - High Availability
```

**Networking**
```yaml
Overlay Networks:
  traefik:
    - Reverse Proxy Communication
    - External Access
    
  homelab-internal:
    - Service-to-Service Communication
    - Database Connections
    - MQTT-Traffic
```

### Service-Orchestrierung

**Service-Definition Beispiel**
```yaml
version: '3.8'
services:
  homeassistant:
    image: homeassistant/home-assistant:stable
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      update_config:
        parallelism: 1
        delay: 30s
        failure_action: rollback
    networks:
      - traefik
      - homelab-internal
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.ha.rule=Host(`ha-prod-01.lab.homelab.example`)"
```

!!! tip "Container-Best-Practices"
    - **Health Checks**: Alle Services mit Health-Check-Endpoints
    - **Resource Limits**: CPU/Memory-Limits für alle Container
    - **Restart Policies**: Automatischer Neustart bei Fehlern
    - **Update Strategy**: Rolling Updates ohne Downtime

## SSL/TLS-Layer

### Traefik Reverse Proxy

**Automatisierte SSL-Verwaltung**
```yaml
Features:
  - Automatische Service-Discovery
  - Let's Encrypt Integration
  - DNS-Challenge für Wildcard-Zertifikate
  - HTTP → HTTPS Redirect
  - Load Balancing

Providers:
  - Docker (Service-Discovery)
  - File (statische Konfiguration)
  - Consul/etcd (für Cluster)
```

**Let's Encrypt mit netcup**
```yaml
DNS-Challenge-Vorteile:
  - Wildcard-Zertifikate möglich
  - Funktioniert mit internen Services
  - Keine Port 80/443 Exposition nötig
  - Automatische Renewal

netcup-Integration:
  - DNS-API für TXT-Record-Management
  - Automatische Challenge-Records
  - Kostenloser DNS-Service
```

**Certificate-Management**
```yaml
Zertifikat-Struktur:
  *.lab.homelab.example: Wildcard für Homelab-Services
  *.iot.homelab.example: Wildcard für IOT-Services  
  *.guest.homelab.example: Wildcard für Gäste-Services

Renewal-Prozess:
  - Automatisch alle 60 Tage
  - Zero-Downtime-Updates
  - Backup in Docker Volume
```

!!! info "SSL-Sicherheit"
    Alle Services verwenden moderne TLS 1.3-Verschlüsselung mit Perfect Forward Secrecy. Interne Kommunikation zwischen Services erfolgt ebenfalls verschlüsselt.

## Application-Layer

### Home Assistant

**Architektur-Komponenten**
```yaml
Home Assistant Core:
  - Event-Bus für IOT-Integration
  - Automatisierungs-Engine
  - State-Management
  - REST/WebSocket-API

Datenbank-Backend:
  - PostgreSQL für Recorder
  - Bessere Performance als SQLite
  - Backup und Clustering möglich

MQTT-Integration:
  - Eclipse Mosquitto Broker
  - Retained Messages für State
  - QoS-Level für Zuverlässigkeit
```

**IOT-Protokoll-Support**
```yaml
Unterstützte Protokolle:
  - Zigbee (via zigbee2mqtt)
  - Z-Wave (via zwave-js)
  - WiFi (direkte Integration)
  - Bluetooth (Proximity Detection)
  - KNX/EIB (für Gebäudeautomation)
  - Homematic (via CCU)
```

### Monitoring-Stack

**Multi-Layer-Monitoring**
```yaml
Metriken (Prometheus):
  - System-Metriken (Node Exporter)
  - Container-Metriken (cAdvisor)
  - Service-Metriken (Application-specific)

Time-Series (InfluxDB):
  - IOT-Sensor-Daten
  - Home Assistant History
  - Performance-Metriken

Visualisierung (Grafana):
  - System-Dashboards
  - IOT-Dashboards
  - Alerting-Integration
```

**Logging-Strategie**
```yaml
Centralized Logging:
  - Loki für Log-Aggregation
  - Promtail für Log-Collection
  - Docker Log-Driver Integration

Log-Retention:
  - Debug-Logs: 7 Tage
  - System-Logs: 30 Tage
  - Audit-Logs: 1 Jahr
```

!!! warning "Monitoring-Overhead"
    Monitoring kann 10-20% der System-Ressourcen verbrauchen. Planen Sie entsprechend zusätzliche CPU/RAM für das Monitoring ein.

## Sicherheits-Layer

### Secrets-Management

**Multi-Layer-Sicherheit**
```yaml
Entwicklung:
  - .env.example Templates (in Git)
  - Lokale .env Dateien (nicht in Git)
  - .gitignore-Schutz

Produktion:
  - GPG-Verschlüsselung für Backups
  - Separate Key-Verwaltung
  - Automatisierte Backup-Rotation

Recovery:
  - Externe Key-Aufbewahrung
  - Dokumentierte Recovery-Prozesse
  - Regelmäßige Recovery-Tests
```

**Git-Integration**
```yaml
Repository-Struktur:
  ✅ docker-compose.yml (Service-Definitionen)
  ✅ .env.example (Templates)
  ✅ scripts/ (Automatisierung)
  ✅ README.md (Dokumentation)
  
  ❌ .env (echte Secrets)
  ❌ *.key/*.pem (private Keys)
  ❌ backup/*.tar.gz (unverschlüsselte Backups)
```

### Backup-Strategie

**3-2-1-Backup-Regel**
```yaml
3 Kopien der Daten:
  - Original (produktive Services)
  - Lokales Backup (verschlüsselt)
  - Externes Backup (Cloud/USB)

2 verschiedene Medien:
  - Lokale SSDs/HDDs
  - Cloud-Storage (Nextcloud/Google Drive)

1 Offsite-Backup:
  - USB-Stick bei Vertrauensperson
  - Geografisch getrennt
```

!!! info "Recovery-Time-Objective"
    - **RTO** (Recovery Time): < 4 Stunden für kritische Services
    - **RPO** (Recovery Point): < 24 Stunden Datenverlust maximal
    - **Verfügbarkeit**: 99.5% (43 Stunden Downtime/Jahr)

## Aufwandsschätzung

### Technologie-Evaluation
- **UniFi vs. Alternativen**: 4-6 Stunden
- **Container-Orchestrierung**: 3-4 Stunden
- **SSL/DNS-Strategie**: 2-3 Stunden
- **Monitoring-Tools**: 3-5 Stunden

### Implementierung
- **Basis-Services (DNS, Proxy)**: 8-12 Stunden
- **Container-Platform**: 6-10 Stunden
- **Home Assistant Integration**: 4-8 Stunden
- **Monitoring-Setup**: 6-12 Stunden
- **Sicherheits-Implementierung**: 4-8 Stunden

**Gesamt Technologie-Aufwand: 35-65 Stunden**

### Lernkurve
- **Docker Swarm**: 2-3 Tage Einarbeitung
- **Traefik**: 1-2 Tage Setup + Konfiguration
- **Home Assistant**: 3-5 Tage für komplexe Automatisierungen
- **UniFi**: 1-2 Tage für erweiterte Features

### Wartungsaufwand
- **Wöchentlich**: 2-3 Stunden (Updates, Monitoring)
- **Monatlich**: 4-6 Stunden (Optimierung, neue Features)
- **Jährlich**: 20-30 Stunden (Major Updates, Reviews)
