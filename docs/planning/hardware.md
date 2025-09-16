# Hardware-Anforderungen

## Minimum-Setup (Einstieg)

Das Minimum-Setup ermöglicht den Einstieg in die Homelab-Infrastruktur mit grundlegenden Funktionen und der Möglichkeit zur späteren Erweiterung.

### Core-Komponenten

**DNS-Server (Raspberry Pi)**
```yaml
Modell: Raspberry Pi 4B (4GB RAM)
Storage: 32GB microSD + 120GB USB-SSD
Netzwerk: Gigabit Ethernet (kein WiFi)
Stromversorgung: Offizielles USB-C Netzteil
Gehäuse: Mit aktiver Kühlung empfohlen
```

**Docker-Host (Server/Mini-PC)**
```yaml
CPU: Quad-Core (x86_64)
RAM: 8GB DDR4
Storage: 500GB SSD
Netzwerk: Gigabit Ethernet
Betriebssystem: Ubuntu Server 22.04 LTS
```

**Netzwerk-Equipment**
```yaml
Gateway: UniFi UDM Pro/SE oder Gateway + separate Hardware
Switch: Managed Switch mit VLAN-Support (8+ Ports)
WiFi: 1-2x UniFi Access Points (WiFi 6 empfohlen)
```

!!! info "Budget-Schätzung Minimum-Setup"
    - Raspberry Pi 4B Kit: ~€90
    - Mini-PC (gebraucht): ~€300-500
    - UniFi UDM SE: ~€400
    - UniFi U6-Lite AP: ~€150
    - **Gesamt: ~€940-1140**

### Minimum-Setup Spezifikationen

| Komponente | Modell/Spezifikation | Zweck | Kosten |
|------------|---------------------|-------|--------|
| **DNS-Server** | Raspberry Pi 4B 4GB | Pi-hole + Unbound | €90 |
| **Compute** | Intel NUC oder ähnlich | Docker Services | €400 |
| **Gateway** | UniFi UDM SE | Routing, Firewall, Controller | €400 |
| **Access Point** | UniFi U6-Lite | WiFi für alle VLANs | €150 |
| **Switch** | UniFi Switch Lite 8 PoE | VLAN-Management | €100 |

## Empfohlenes Setup (Hochverfügbarkeit)

Das empfohlene Setup bietet Redundanz, bessere Performance und Enterprise-Features für kritische Anwendungen.

### Erweiterte Infrastruktur

**Redundante DNS-Server**
```yaml
Primary Pi-hole:
  Hardware: Raspberry Pi 4B (4GB)
  IP: 192.168.1.3
  Zusätzlich: USV/Powerbank für Stromausfälle

Secondary Pi-hole:
  Hardware: Raspberry Pi 4B (4GB)  
  IP: 192.168.1.4
  Synchronisation: Gravity Sync
```

**Docker Swarm Cluster**
```yaml
Manager Node:
  CPU: 6-Core (Intel i5/AMD Ryzen 5)
  RAM: 16GB DDR4
  Storage: 1TB NVMe SSD
  IP: 192.168.1.45

Worker Nodes (2-3x):
  CPU: 4-Core
  RAM: 16GB DDR4
  Storage: 500GB SSD
  IPs: 192.168.1.46-48
```

**Proxmox Virtualisierung**
```yaml
Proxmox Hosts (2-3x):
  CPU: 8-Core (Intel Xeon/AMD EPYC)
  RAM: 32-64GB ECC
  Storage: 2TB NVMe + HDD für Backups
  Netzwerk: Dual Gigabit oder 10GbE
  Cluster: Hochverfügbarkeit mit Ceph
```

**Zentraler Storage**
```yaml
NAS-System:
  Lösung: TrueNAS Scale
  CPU: 6-Core mit ECC-Unterstützung
  RAM: 32GB ECC
  Storage: 4x 4TB in RAID-Z1 + SSD-Cache
  Netzwerk: 10GbE für Cluster-Integration
```

### Enterprise-Netzwerk

**UniFi Professional Equipment**
```yaml
Gateway: UniFi UDM Pro Max (10GbE, IPS/IDS)
Core Switch: UniFi Switch Pro 24 PoE
Distribution: UniFi Switch Pro 8 PoE (pro Bereich)
Access Points: UniFi U6-Pro (WiFi 6E, 2.5GbE Uplink)
Management: Dedicated UniFi Controller (VM)
```

!!! warning "Performance-Überlegungen"
    Bei der Hardware-Auswahl sollten folgende Faktoren berücksichtigt werden:
    
    - **CPU**: Moderne Architektur für Container-Workloads
    - **RAM**: Ausreichend für In-Memory-Datenbanken (InfluxDB, Redis)
    - **Storage**: NVMe SSDs für Docker-Volumes und Datenbanken
    - **Netzwerk**: Gigabit minimum, 10GbE für Storage-Traffic

## Hardware-Dimensionierung

### CPU-Anforderungen

**Service-spezifische Anforderungen**:
```yaml
Home Assistant: 2 CPU-Kerne
InfluxDB: 2-4 CPU-Kerne (je nach IOT-Geräte-Anzahl)
Grafana: 1-2 CPU-Kerne
Traefik: 1 CPU-Kern
Pi-hole: 1 CPU-Kern
PostgreSQL: 2-4 CPU-Kerne
```

**Gesamt-Dimensionierung**:
- **Minimum**: 4 Kerne (ohne Virtualisierung)
- **Empfohlen**: 8-12 Kerne (mit Virtualisierung)
- **Enterprise**: 16+ Kerne (Cluster-Setup)

### RAM-Dimensionierung

**Service-Memory-Footprint**:
```yaml
Basis-System (Ubuntu): 1-2GB
Home Assistant: 1-2GB
InfluxDB: 2-4GB (je nach Retention)
PostgreSQL: 1-2GB
Grafana: 512MB-1GB
Traefik: 256-512MB
Monitoring Stack: 2-4GB
```

**Gesamt-Empfehlungen**:
- **Minimum**: 8GB (Single-Host)
- **Empfohlen**: 16-32GB (Swarm-Cluster)
- **Enterprise**: 64GB+ (Proxmox mit VMs)

### Storage-Dimensionierung

**Daten-Wachstum (Beispiel für 50 IOT-Geräte)**:
```yaml
InfluxDB (1 Jahr): 20-50GB
Home Assistant DB: 5-10GB
Grafana Dashboards: <1GB
Docker Images: 10-20GB
System-Logs: 5-10GB
Backups: 50-100GB
```

**Storage-Strategie**:
```yaml
Hot Data (aktiv): NVMe SSD
Warm Data (1-3 Monate): SATA SSD  
Cold Data (Backups): HDD oder Cloud
```

!!! tip "Skalierungs-Strategie"
    Beginnen Sie mit dem Minimum-Setup und erweitern Sie basierend auf tatsächlicher Nutzung:
    
    1. **CPU**: Monitoring der Load Average
    2. **RAM**: Memory-Auslastung der Container überwachen
    3. **Storage**: IOPS und Throughput-Anforderungen messen

## Netzwerk-Hardware

### Switch-Anforderungen

**Port-Planung (pro Bereich)**:
```yaml
Arbeitszimmer (Main):
  - 2x Proxmox Hosts
  - 1x NAS
  - 2x Raspberry Pi
  - 2x Access Points
  - Reserve: 8 Ports
  Gesamt: 16+ Ports

Verteilerswitches:
  - Pro Bereich: 8 Ports
  - PoE für Access Points
  - Uplink: 2x Gigabit (LACP)
```

**VLAN-Features**:
- 802.1Q VLAN-Tagging
- Inter-VLAN-Routing
- PoE+ für Access Points (30W+)
- Link Aggregation (LACP)
- Managed über UniFi Controller

### WiFi-Abdeckung

**Access Point Platzierung**:
```yaml
Hauptbereiche:
  - Wohnzimmer: U6-Pro (zentraler Bereich)
  - Arbeitszimmer: U6-Lite (nahe Clients)
  - Optional: Schlafzimmer bei größeren Wohnungen

Outdoor (optional):
  - Garten/Terrasse: U6-Mesh oder U6-Extender
```

**WiFi-Standards**:
- **Minimum**: WiFi 6 (802.11ax)
- **Empfohlen**: WiFi 6E (6GHz Band)
- **Enterprise**: WiFi 7 (für Zukunftssicherheit)

!!! info "PoE-Budget-Planung"
    Kalkulieren Sie das PoE-Budget für Ihre Switches:
    
    - UniFi U6-Lite: 12W
    - UniFi U6-Pro: 13W  
    - UniFi U6-Enterprise: 23W
    - Zusätzlich: IP-Telefone, Kameras, etc.

## Aufwandsschätzung

### Beschaffung & Setup
- **Minimum-Setup Beschaffung**: 2-3 Tage
- **Hardware-Installation**: 1 Tag
- **Basis-Konfiguration**: 1-2 Tage
- **Service-Deployment**: 2-3 Tage

### Erweiterte Setups
- **Proxmox Cluster Setup**: 2-4 Tage
- **NAS-Integration**: 1-2 Tage
- **Redundanz-Konfiguration**: 1-2 Tage
- **Performance-Tuning**: 1-2 Tage

**Gesamt Implementierungsaufwand**:
- **Minimum**: 6-9 Tage
- **Empfohlen**: 12-18 Tage
- **Enterprise**: 20-30 Tage

### Laufende Wartung
- **Wöchentlich**: 1-2 Stunden (Updates, Monitoring)
- **Monatlich**: 3-4 Stunden (Backups, Optimierung)
- **Quartalsweise**: 8-12 Stunden (Major Updates, Reviews)
