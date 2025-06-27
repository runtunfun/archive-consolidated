# Home Assistant Stack

Home Assistant bildet das Herzstück der Smart Home Integration und orchestriert alle IOT-Geräte im Homelab. Der Stack umfasst die Hauptanwendung, eine PostgreSQL-Datenbank für Langzeitspeicherung und einen MQTT-Broker für die Gerätekommunikation.

## Architektur-Übersicht

```mermaid
graph TB
    subgraph "Home Assistant Stack"
        HA[Home Assistant<br/>:8123]
        PG[(PostgreSQL<br/>Database)]
        MQTT[Mosquitto<br/>:1883/8883]
    end
    
    subgraph "External Services"
        TR[Traefik<br/>SSL Proxy]
        INF[InfluxDB<br/>Metrics]
    end
    
    subgraph "IOT Devices"
        HUE[Philips Hue<br/>Bridge]
        SH[Shelly<br/>Switches]
        HM[Homematic<br/>CCU]
    end
    
    TR --> HA
    HA --> PG
    HA --> MQTT
    HA --> INF
    HUE --> HA
    SH --> MQTT
    HM --> HA
```

## Service-Komponenten

### Home Assistant Core
- **Version:** Latest Stable
- **Port:** 8123 (HTTP)
- **HTTPS:** Via Traefik (ha-prod-01.lab.homelab.example)
- **Zweck:** Zentrale Smart Home Steuerung

### PostgreSQL
- **Version:** 15
- **Port:** 5432 (intern)
- **Zweck:** Persistente Datenspeicherung für HA

### Mosquitto MQTT
- **Version:** Latest
- **Ports:** 1883 (MQTT), 8883 (MQTT SSL)
- **Zweck:** Message Queue für IOT-Geräte

## Docker Compose Konfiguration

```yaml title="/opt/homelab/homeassistant/docker-compose.yml"
version: '3.8'

services:
  homeassistant:
    image: homeassistant/home-assistant:${HA_VERSION}
    hostname: ha-prod-01
    environment:
      TZ: "${HA_TZ}"
    volumes:
      - ha_config:/config
      - /etc/localtime:/etc/localtime:ro
    networks:
      - traefik
      - homelab-internal
    ports:
      - "8123:8123"  # Direkter Zugriff für IOT-Geräte
    labels:
      # Traefik Labels
      - "traefik.enable=true"
      - "traefik.http.routers.homeassistant.rule=Host(`ha-prod-01.lab.homelab.example`)"
      - "traefik.http.routers.homeassistant.tls.certresolver=letsencrypt"
      - "traefik.http.services.homeassistant.loadbalancer.server.port=8123"
      
      # Service Metadaten
      - "homelab.service.name=homeassistant"
      - "homelab.service.version=${HA_VERSION}"
      - "homelab.service.category=iot"
    deploy:
      placement:
        constraints:
          - node.role == manager

  postgres:
    image: postgres:15
    hostname: postgres-ha-01
    environment:
      POSTGRES_DB: "${HA_DB_NAME}"
      POSTGRES_USER: "${HA_DB_USER}"
      POSTGRES_PASSWORD: "${HA_DB_PASSWORD}"
      TZ: "${HA_TZ}"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - homelab-internal
    deploy:
      placement:
        constraints:
          - node.role == manager

  mosquitto:
    image: eclipse-mosquitto:latest
    hostname: mqtt-01
    volumes:
      - mosquitto_config:/mosquitto/config
      - mosquitto_data:/mosquitto/data
      - mosquitto_logs:/mosquitto/log
    ports:
      - "1883:1883"  # MQTT
      - "8883:8883"  # MQTT SSL
    networks:
      - homelab-internal
    labels:
      - "homelab.service.name=mosquitto"
      - "homelab.service.category=iot"
    deploy:
      placement:
        constraints:
          - node.role == manager

volumes:
  ha_config:
  postgres_data:
  mosquitto_config:
  mosquitto_data:
  mosquitto_logs:

networks:
  traefik:
    external: true
  homelab-internal:
    external: true
```

## Environment-Konfiguration

```bash title="/opt/homelab/homeassistant/.env.example"
# Home Assistant Stack Configuration
HA_VERSION=2024.12.3
HA_TZ=Europe/Berlin

# Database
HA_DB_NAME=homeassistant
HA_DB_USER=homeassistant
HA_DB_PASSWORD=CHANGE_ME_TO_SECURE_DB_PASSWORD

# MQTT
MQTT_USER=homeassistant
MQTT_PASSWORD=CHANGE_ME_TO_SECURE_MQTT_PASSWORD
```

!!! warning "Produktive Environment"
    Nach dem Kopieren von `.env.example` zu `.env` müssen alle `CHANGE_ME_*` Werte durch sichere Passwörter ersetzt werden.

## Home Assistant Konfiguration

### Database Integration

```yaml title="/config/configuration.yaml"
# Database Configuration
recorder:
  db_url: postgresql://homeassistant:YOUR_PASSWORD@postgres-ha-01:5432/homeassistant
  purge_keep_days: 30
  include:
    entities:
      - sensor.temperature_*
      - sensor.humidity_*
      - light.*
      - switch.*
  exclude:
    entities:
      - sensor.uptime
      - sensor.date*

# History Settings
history:
  include:
    entities:
      - sensor.temperature_*
      - sensor.humidity_*
      - light.*
      - switch.*
```

### MQTT Integration

```yaml title="/config/configuration.yaml"
# MQTT Configuration
mqtt:
  broker: mqtt-01.lab.homelab.example
  port: 1883
  username: !secret mqtt_user
  password: !secret mqtt_password
  discovery: true
  discovery_prefix: homeassistant

# Device Tracker via MQTT
device_tracker:
  - platform: mqtt
    devices:
      admin_phone: 'location/admin_phone'
      admin_laptop: 'location/admin_laptop'
```

### Network Configuration

```yaml title="/config/configuration.yaml"
# Network Configuration
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.18.0.0/16  # Docker Swarm Network
    - 192.168.1.48   # Traefik IP

# Internal URL (für direkte IOT-Zugriffe)
internal_url: "http://192.168.1.41:8123"
external_url: "https://ha-prod-01.lab.homelab.example"
```

## MQTT Broker Konfiguration

### Mosquitto Config

```conf title="/mosquitto/config/mosquitto.conf"
# Basic Configuration
listener 1883
allow_anonymous false
password_file /mosquitto/config/passwd

# SSL Configuration
listener 8883
cafile /mosquitto/config/ca.crt
certfile /mosquitto/config/server.crt
keyfile /mosquitto/config/server.key

# Logging
log_dest file /mosquitto/log/mosquitto.log
log_type error
log_type warning
log_type notice
log_type information

# Persistence
persistence true
persistence_location /mosquitto/data/

# Bridge Configuration (falls externe MQTT Broker)
# connection bridge-01
# address external-mqtt.example.com:1883
# topic # both 2 homeassistant/ homeassistant/
```

### User Management

```bash
# MQTT User erstellen
docker exec -it $(docker ps -q -f name=mosquitto) mosquitto_passwd -c /mosquitto/config/passwd homeassistant

# Weitere User hinzufügen
docker exec -it $(docker ps -q -f name=mosquitto) mosquitto_passwd /mosquitto/config/passwd shelly_user
docker exec -it $(docker ps -q -f name=mosquitto) mosquitto_passwd /mosquitto/config/passwd tasmota_user

# Container neu starten um Konfiguration zu laden
docker-compose restart mosquitto
```

## Integration mit IOT-Geräten

### Shelly Devices

```yaml title="Shelly MQTT Integration"
# Shelly Konfiguration über MQTT
mqtt:
  shelly_dimmer_flur:
    state_topic: "shellies/shelly-dimmer-flur-01/light/0"
    command_topic: "shellies/shelly-dimmer-flur-01/light/0/command"
    brightness_state_topic: "shellies/shelly-dimmer-flur-01/light/0/brightness"
    brightness_command_topic: "shellies/shelly-dimmer-flur-01/light/0/set"
    payload_on: "on"
    payload_off: "off"
```

### Philips Hue Integration

```yaml title="Hue Bridge Integration"
# Hue Bridge automatische Erkennung
hue:
  bridges:
    - host: 192.168.101.1
      allow_unreachable: true
      allow_hue_groups: true
```

### Homematic Integration

```yaml title="Homematic CCU Integration"
# Homematic CCU3 Integration
homematic:
  interfaces:
    wireless:
      host: 192.168.100.10
      port: 2001
    wired:
      host: 192.168.100.10
      port: 2000
  hosts:
    ccu3:
      host: 192.168.100.10
      username: !secret homematic_user
      password: !secret homematic_password
```

## Monitoring Integration

### InfluxDB Integration

```yaml title="InfluxDB Metrics Export"
# InfluxDB Configuration
influxdb:
  host: influx-01.lab.homelab.example
  port: 8086
  database: homeassistant
  username: !secret influxdb_user
  password: !secret influxdb_password
  max_retries: 3
  default_measurement: state
  include:
    entities:
      - sensor.temperature_*
      - sensor.humidity_*
      - sensor.power_*
      - binary_sensor.motion_*
```

### System Monitor

```yaml title="System Monitoring"
# System Monitor
sensor:
  - platform: systemmonitor
    resources:
      - type: disk_use_percent
        arg: /config
      - type: memory_use_percent
      - type: processor_use
      - type: processor_temperature
      - type: last_boot

  # Docker Container Monitoring
  - platform: docker_monitor
    containers:
      - homeassistant_homeassistant_1
      - homeassistant_postgres_1
      - homeassistant_mosquitto_1
```

## Backup & Recovery

### Automatisierte Backups

```yaml title="HA Backup Automation"
# Tägliche Backups um 02:00
automation:
  - alias: "Daily Backup"
    trigger:
      platform: time
      at: "02:00:00"
    action:
      service: hassio.backup_full
      data:
        name: "Automated Backup {{ now().strftime('%Y-%m-%d') }}"
        password: !secret backup_password

  # Backup-Bereinigung (ältere als 7 Tage löschen)
  - alias: "Cleanup Old Backups"
    trigger:
      platform: time
      at: "03:00:00"
    action:
      service: python_script.cleanup_backups
      data:
        keep_days: 7
```

### External Backup Script

```bash title="/opt/homelab/scripts/backup-homeassistant.sh"
#!/bin/bash

# Home Assistant Backup Script
BACKUP_DIR="/opt/homelab/backup/homeassistant"
DATE=$(date +%Y%m%d-%H%M)

mkdir -p "$BACKUP_DIR"

# HA Config Backup
docker run --rm \
  -v homeassistant_ha_config:/source:ro \
  -v "$BACKUP_DIR":/backup \
  alpine tar czf "/backup/ha-config-$DATE.tar.gz" -C /source .

# PostgreSQL Backup
docker exec homeassistant_postgres_1 pg_dump -U homeassistant homeassistant | \
  gzip > "$BACKUP_DIR/ha-database-$DATE.sql.gz"

# MQTT Config Backup
docker run --rm \
  -v homeassistant_mosquitto_config:/source:ro \
  -v "$BACKUP_DIR":/backup \
  alpine tar czf "/backup/mqtt-config-$DATE.tar.gz" -C /source .

echo "✅ Home Assistant Backup completed: $BACKUP_DIR/"
```

## Troubleshooting

### Common Issues

**Service nicht erreichbar:**

```bash
# Service-Status prüfen
docker service ps homeassistant_homeassistant

# Logs ansehen
docker service logs homeassistant_homeassistant --tail 50

# Direkter Container-Zugriff
curl http://192.168.1.41:8123
```

**Database Connection Issues:**

```bash
# PostgreSQL Status prüfen
docker exec homeassistant_postgres_1 pg_isready -U homeassistant

# Database Connection testen
docker exec homeassistant_postgres_1 psql -U homeassistant -c "\l"

# Verbindung von HA aus testen
docker exec homeassistant_homeassistant_1 nc -zv postgres-ha-01 5432
```

**MQTT Problems:**

```bash
# MQTT Broker Status
docker exec homeassistant_mosquitto_1 mosquitto_pub -t test -m "hello"

# Message-Flow testen
mosquitto_sub -h mqtt-01.lab.homelab.example -t homeassistant/# -v

# User-Authentication prüfen
docker exec homeassistant_mosquitto_1 cat /mosquitto/config/passwd
```

!!! tip "Performance Optimization"
    Für bessere Performance bei vielen IOT-Geräten:
    
    - PostgreSQL für Recorder verwenden statt SQLite
    - InfluxDB für Langzeit-Metriken nutzen
    - MQTT-Nachrichten-Throttling konfigurieren
    - Device-Polling-Intervalle optimieren

## Production Checklist

### Pre-Deployment

- [ ] `.env` Datei mit produktiven Werten befüllt
- [ ] Sichere Passwörter für alle Credentials
- [ ] PostgreSQL-Backup-Strategie definiert
- [ ] MQTT-User und -Permissions konfiguriert
- [ ] SSL-Zertifikate für MQTT (optional)

### Post-Deployment

- [ ] HTTPS-Zugriff über Traefik funktioniert
- [ ] Database-Connection aktiv
- [ ] MQTT-Broker erreichbar
- [ ] IOT-Geräte-Integration getestet
- [ ] Backup-Automatisierung aktiviert
- [ ] Monitoring-Integration konfiguriert

### Security Hardening

- [ ] Default-Passwörter geändert
- [ ] API-Token für Integrationen rotiert
- [ ] Network-Segmentierung aktiv (VLAN)
- [ ] Firewall-Regeln minimal
- [ ] HTTPS-Only Zugriff erzwungen

---

**⏱️ Aufwandsschätzung:**

- **Initial Setup:** 3-4 Stunden
- **IOT-Integration:** 1-2 Stunden pro Gerätehersteller
- **Database-Migration:** 1-2 Stunden
- **Backup-Setup:** 1 Stunde
- **Wartung pro Monat:** 2-3 Stunden
