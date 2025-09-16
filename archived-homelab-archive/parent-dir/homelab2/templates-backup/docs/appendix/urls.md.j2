# URL-Referenz

Nach erfolgreichem Deployment sind folgende URLs verfügbar. Alle Services verwenden HTTPS mit gültigen Let's Encrypt Zertifikaten.

!!! info "Domain-Schema"
    Alle URLs folgen dem Schema: `https://[service]-[nummer].[subdomain].homelab.example`

## Management-Interfaces

### Core Infrastructure

| Service | URL | Beschreibung | Standard-Port |
|---------|-----|--------------|---------------|
| **Pi-hole Primary** | [https://pihole-01.lab.homelab.example](https://pihole-01.lab.homelab.example) | DNS-Management, Ad-Blocking | 80/443 |
| **Pi-hole Secondary** | [https://pihole-02.lab.homelab.example](https://pihole-02.lab.homelab.example) | Backup DNS-Server | 80/443 |
| **Traefik Dashboard** | [https://traefik-01.lab.homelab.example](https://traefik-01.lab.homelab.example) | Reverse Proxy Management | 80/443 |

!!! warning "Zugriffskontrolle"
    Management-Interfaces sind nur im Standard-LAN (192.168.1.0/24) erreichbar.

### UniFi Ecosystem

| Service | URL | Beschreibung | Bemerkung |
|---------|-----|--------------|-----------|
| **UniFi Controller** | `https://unifi-controller-01.lab.homelab.example:8443` | Netzwerk-Management | Port 8443 |
| **UniFi Network** | `https://unifi.ui.com` | Cloud-Management | Alternative |

!!! tip "Lokaler Zugriff"
    Der UniFi Controller ist auch direkt über IP erreichbar: `https://192.168.1.2:8443`

### Virtualisierung (Optional)

| Service | URL | Beschreibung | Standard-Port |
|---------|-----|--------------|---------------|
| **Proxmox Host 1** | `https://pve-01.lab.homelab.example:8006` | VM-Management | 8006 |
| **Proxmox Host 2** | `https://pve-02.lab.homelab.example:8006` | Backup/Cluster | 8006 |
| **TrueNAS Scale** | [https://nas-01.lab.homelab.example](https://nas-01.lab.homelab.example) | Storage-Management | 80/443 |

## Docker Management

### Container-Orchestrierung

| Service | URL | Beschreibung | Features |
|---------|-----|--------------|----------|
| **Portainer** | [https://portainer-01.lab.homelab.example](https://portainer-01.lab.homelab.example) | Docker GUI-Management | Stacks, Services, Volumes |
| **Traefik API** | `https://traefik-01.lab.homelab.example/api/rawdata` | REST API | JSON-Export |

### Development Tools

!!! note "Entwicklungsumgebung"
    Diese Services sind optional und nur bei Bedarf zu deployen.

| Service | URL | Beschreibung | Verwendung |
|---------|-----|--------------|------------|
| **GitLab CE** | [https://gitlab-01.lab.homelab.example](https://gitlab-01.lab.homelab.example) | Code-Repository | Git, CI/CD |
| **Registry** | [https://registry-01.lab.homelab.example](https://registry-01.lab.homelab.example) | Container-Registry | Docker Images |

## Homelab-Services

### Smart Home Platform

| Service | URL | Beschreibung | Zugriff |
|---------|-----|--------------|---------|
| **Home Assistant Prod** | [https://ha-prod-01.lab.homelab.example](https://ha-prod-01.lab.homelab.example) | Smart Home Dashboard | Standard-LAN + IOT-VLAN |
| **Home Assistant Test** | [https://ha-test-01.lab.homelab.example](https://ha-test-01.lab.homelab.example) | Entwicklungsinstanz | Standard-LAN |

!!! success "Mobile App"
    Die Home Assistant Companion App funktioniert automatisch mit der HTTPS-URL.

### Database Services

| Service | URL | Beschreibung | Protokoll |
|---------|-----|--------------|-----------|
| **PostgreSQL** | `postgres-ha-01.lab.homelab.example:5432` | Home Assistant DB | TCP 5432 |
| **InfluxDB** | `http://influx-01.lab.homelab.example:8086` | Time-Series Database | HTTP |
| **Redis** | `redis-01.lab.homelab.example:6379` | Caching-Layer | TCP 6379 |

!!! warning "Direkter Zugriff"
    Datenbank-Services sind nur über interne Docker-Networks erreichbar.

### Messaging

| Service | URL | Beschreibung | Protokoll |
|---------|-----|--------------|-----------|
| **MQTT Broker** | `mqtt-01.lab.homelab.example:1883` | IOT-Kommunikation | MQTT |
| **MQTT SSL** | `mqtt-01.lab.homelab.example:8883` | Verschlüsseltes MQTT | MQTTS |

## Monitoring & Observability

### Metriken & Dashboards

| Service | URL | Beschreibung | Funktion |
|---------|-----|--------------|----------|
| **Grafana** | [https://grafana-01.lab.homelab.example](https://grafana-01.lab.homelab.example) | Monitoring-Dashboard | Visualisierung |
| **Prometheus** | `http://prometheus-01.lab.homelab.example:9090` | Metrics Collection | Time-Series |
| **AlertManager** | `http://alertmanager-01.lab.homelab.example:9093` | Alert-Routing | Benachrichtigungen |

### Logging

| Service | URL | Beschreibung | Funktion |
|---------|-----|--------------|----------|
| **Loki** | `http://loki-01.lab.homelab.example:3100` | Log-Aggregation | Zentrale Logs |
| **Promtail** | `http://promtail-01.lab.homelab.example:9080` | Log-Shipper | Log-Collection |

### Tracing

| Service | URL | Beschreibung | Funktion |
|---------|-----|--------------|----------|
| **Jaeger** | `http://jaeger-01.lab.homelab.example:16686` | Distributed Tracing | Performance-Analyse |

!!! info "Grafana Integration"
    Alle Monitoring-Services sind in Grafana als Datenquellen konfiguriert.

## IOT-Geräte

### Central Bridges

| Gerät | URL | Hersteller | Funktion |
|-------|-----|------------|----------|
| **Homematic CCU** | `http://hm-ccu-uv-01.iot.homelab.example` | eQ-3 | Smart Home Zentrale |
| **Hue Bridge** | `http://hue-wz-bridge01.iot.homelab.example` | Philips | Lighting Control |

### Device Management

!!! tip "Home Assistant Discovery"
    Die meisten IOT-Geräte werden automatisch von Home Assistant erkannt.

| Bereich | Device-Pattern | Beispiel-URL |
|---------|----------------|--------------|
| **Shelly Geräte** | `http://shelly-*-[raum]-[nr].iot.homelab.example` | `http://shelly-dimmer-az-01.iot.homelab.example` |
| **Homematic Sensoren** | `http://hm-*-[raum]-[nr].iot.homelab.example` | `http://hm-temp-sz-01.iot.homelab.example` |
| **Sonos Speaker** | `http://sonos-[raum]-[nr].iot.homelab.example` | `http://sonos-wz-01.iot.homelab.example` |

## Backup & Recovery

### Backup-Interfaces

| Service | URL | Beschreibung | Zweck |
|---------|-----|--------------|-------|
| **Proxmox Backup** | `https://backup-01.lab.homelab.example:8007` | Backup-Server | VM-Backups |
| **TrueNAS Replication** | `https://nas-01.lab.homelab.example/ui/tasks/rsync` | Sync-Tasks | Daten-Replikation |

### Cloud-Backup

!!! warning "Externe Services"
    Cloud-Backup-URLs variieren je nach Provider.

| Provider | Interface | Verwendung |
|----------|-----------|------------|
| **Nextcloud** | `https://cloud.example.com` | Verschlüsselte Backups |
| **AWS S3** | `https://s3.console.aws.amazon.com` | Offsite-Backup |

## Testing & Debugging

### Connectivity Tests

```bash
# DNS-Auflösung testen
nslookup ha-prod-01.lab.homelab.example 192.168.1.3

# HTTPS-Erreichbarkeit
curl -k https://grafana-01.lab.homelab.example

# Service-Health
curl -k https://ha-prod-01.lab.homelab.example/api/
```

### Troubleshooting URLs

| URL | Zweck | Verwendung |
|-----|-------|------------|
| **Traefik API** | `https://traefik-01.lab.homelab.example/api/rawdata` | Router/Service Status |
| **Pi-hole Query Log** | `https://pihole-01.lab.homelab.example/admin/queries.php` | DNS-Debug |
| **Docker Logs** | SSH + `docker service logs <service>` | Container-Debugging |

## Browser-Bookmarks

!!! tip "Bookmark-Import"
    Erstelle eine Bookmark-Sammlung für effizientes Management.

### Management Bookmarks

```
🏠 Homelab Management/
├── 📡 DNS & Network/
│   ├── Pi-hole Primary (https://pihole-01.lab.homelab.example)
│   ├── UniFi Controller (https://unifi-controller-01.lab.homelab.example:8443)
│   └── Traefik Dashboard (https://traefik-01.lab.homelab.example)
├── 🐳 Docker/
│   └── Portainer (https://portainer-01.lab.homelab.example)
├── 🏡 Smart Home/
│   └── Home Assistant (https://ha-prod-01.lab.homelab.example)
└── 📊 Monitoring/
    ├── Grafana (https://grafana-01.lab.homelab.example)
    └── Prometheus (http://prometheus-01.lab.homelab.example:9090)
```

### Quick Access URLs

Für mobile Geräte und häufig verwendete Services:

| Alias | URL | Verwendung |
|-------|-----|------------|
| **ha** | [https://ha-prod-01.lab.homelab.example](https://ha-prod-01.lab.homelab.example) | Smartphone-Widget |
| **grafana** | [https://grafana-01.lab.homelab.example](https://grafana-01.lab.homelab.example) | Performance-Check |
| **pihole** | [https://pihole-01.lab.homelab.example](https://pihole-01.lab.homelab.example) | DNS-Management |

## Service-Status Dashboard

### Uptime Monitoring

!!! info "Automatische Überwachung"
    Alle Services werden automatisch via Prometheus überwacht.

| Kategorie | Services | Health-Check |
|-----------|----------|--------------|
| **Critical** | DNS, Traefik, UniFi | < 30s Downtime → Alert |
| **Important** | Home Assistant, Database | < 2min Downtime → Alert |
| **Monitoring** | Grafana, Prometheus | < 5min Downtime → Alert |
| **Optional** | Development Tools | Manueller Check |

### Performance Benchmarks

| Service | Response-Zeit | Verfügbarkeit | SLA-Ziel |
|---------|---------------|---------------|----------|
| **Pi-hole** | < 50ms | 99.9% | DNS-kritisch |
| **Home Assistant** | < 2s | 99.5% | IOT-wichtig |
| **Grafana** | < 1s | 98% | Monitoring |
| **Traefik** | < 100ms | 99.8% | Proxy-kritisch |

!!! success "URL-Referenz komplett"
    Alle wichtigen Services sind jetzt über konsistente HTTPS-URLs erreichbar.

## Wartungshinweise

### URL-Updates

```bash
# DNS-Einträge prüfen
nslookup traefik-01.lab.homelab.example 192.168.1.3

# Zertifikat-Erneuerung überwachen
docker service logs traefik_traefik | grep "acme"

# Neue Services hinzufügen
# 1. DNS-Eintrag in Pi-hole
# 2. Traefik-Labels in docker-compose.yml
# 3. URL-Dokumentation aktualisieren
```

**Aufwand für URL-Setup:** ~15 Minuten pro Service
