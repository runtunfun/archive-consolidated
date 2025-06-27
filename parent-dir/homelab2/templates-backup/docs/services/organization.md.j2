# Service Organisation

Die Service-Organisation ist das Herzstück des Homelabs und definiert, wie alle Container-Services strukturiert, verwaltet und bereitgestellt werden. Eine durchdachte Organisation ermöglicht:

- **Konsistente Verwaltung** aller Services
- **Einfache Reproduzierbarkeit** auf neuer Hardware
- **Sichere Secrets-Verwaltung** ohne Git-Exposition
- **Automatisierte Deployments** und Updates

## Einheitliche Ordnerstruktur

Alle Docker-Services verwenden eine **konsistente Ordnerstruktur** unter `/opt/homelab/` für maximale Wartbarkeit und Automatisierung.

```bash
/opt/homelab/
├── dns-stack/              # Raspberry Pi DNS (Pi-hole + Unbound)
│   ├── docker-compose.yml  # DNS-Service Stack
│   ├── .env                 # Pi-spezifische Umgebungsvariablen
│   ├── .env.example         # Template für neue Setups
│   ├── unbound.conf         # Unbound DNS-Konfiguration
│   └── gravity-sync/        # Synchronisation zwischen Pis
├── traefik/                # Zentraler Reverse Proxy
│   ├── docker-compose.yml  # Traefik + SSL-Terminierung
│   ├── .env                 # netcup API Credentials
│   └── .env.example         # Template
├── homeassistant/          # Home Assistant Stack
│   ├── docker-compose.yml  # HA + Addons
│   ├── .env                 # HA-spezifische Variablen
│   ├── .env.example         # Template
│   └── config/             # Home Assistant Konfiguration
├── monitoring/             # Monitoring-Suite
│   ├── docker-compose.yml  # Grafana, InfluxDB, Prometheus
│   ├── .env                 # Monitoring-Credentials
│   ├── .env.example         # Template
│   └── config/             # Dashboards, Configs
├── portainer/              # Docker Management
│   ├── docker-compose.yml  # Portainer CE
│   ├── .env                 # Portainer-Einstellungen
│   └── .env.example         # Template
├── scripts/                # Automatisierung
│   ├── init-environment.sh # Environment Setup
│   ├── backup-secrets.sh   # Backup-Automatisierung
│   └── restore-secrets.sh  # Recovery-Scripts
└── secrets/                # Sichere Datenverwaltung
    ├── gpg-keys/           # GPG Schlüssel (nicht in Git)
    ├── encrypted-backups/  # Verschlüsselte Backups
    └── .gitignore          # Schutz vor versehentlichem Commit
```

!!! note "Ordner-Berechtigung"
    Alle Service-Ordner sollten restriktive Berechtigungen haben:
    ```bash
    chmod 755 /opt/homelab/
    chmod 700 /opt/homelab/secrets/
    find /opt/homelab -name ".env" -exec chmod 600 {} \;
    ```

## Docker Compose Standards

### Template-System für Environment-Dateien

**Jeder Service hat:**

- `.env.example` - Versioniert in Git (Template)
- `.env` - Lokal, nicht in Git (echte Secrets)

**Beispiel:** `/opt/homelab/homeassistant/.env.example`

```bash title=".env.example"
# Home Assistant Environment Template
HA_VERSION=2024.12
HA_TZ=Europe/Berlin

# Database Configuration
HA_DB_TYPE=postgresql
HA_DB_HOST=postgres-01.lab.homelab.example
HA_DB_NAME=homeassistant
HA_DB_USER=homeassistant
HA_DB_PASSWORD=CHANGE_ME_TO_SECURE_DB_PASSWORD

# Security
HA_ADMIN_PASSWORD=CHANGE_ME_TO_SECURE_ADMIN_PASSWORD

# Integrations
MQTT_BROKER=mqtt-01.lab.homelab.example
MQTT_USER=homeassistant
MQTT_PASSWORD=CHANGE_ME_TO_SECURE_MQTT_PASSWORD

# Monitoring
INFLUXDB_HOST=influx-01.lab.homelab.example
INFLUXDB_TOKEN=CHANGE_ME_TO_SECURE_INFLUX_TOKEN
```

### Docker Compose Konventionen

**Standard-Labels für alle Services:**

```yaml title="Standard Labels"
labels:
  # Traefik Integration (falls Web-Interface vorhanden)
  - "traefik.enable=true"
  - "traefik.http.routers.${SERVICE_NAME}.rule=Host(`${SERVICE_NAME}-01.lab.homelab.example`)"
  - "traefik.http.routers.${SERVICE_NAME}.tls.certresolver=letsencrypt"
  - "traefik.http.services.${SERVICE_NAME}.loadbalancer.server.port=${SERVICE_PORT}"
  
  # Service-Metadaten
  - "homelab.service.name=${SERVICE_NAME}"
  - "homelab.service.version=${SERVICE_VERSION}"
  - "homelab.service.category=${CATEGORY}"  # core, monitoring, iot, etc.
```

**Standard-Networks:**

```yaml title="Network Configuration"
networks:
  traefik:
    external: true  # Für Services mit Web-Interface
  homelab-internal:
    external: true  # Für Service-zu-Service Kommunikation
```

!!! warning "Network-Voraussetzungen"
    Die externen Networks müssen vorher erstellt werden:
    ```bash
    docker network create --driver overlay traefik
    docker network create --driver overlay homelab-internal
    ```

## Service-Kategorien

### Core Services
- **Traefik** - Reverse Proxy und SSL-Terminierung
- **Pi-hole** - DNS-Server und Ad-Blocking
- **Portainer** - Docker Management Interface

### IOT Services
- **Home Assistant** - Smart Home Zentrale
- **MQTT Broker** - Message Queue für IOT-Geräte
- **Node-RED** - Flow-basierte Automatisierung (optional)

### Monitoring Services
- **Grafana** - Dashboard und Visualisierung
- **InfluxDB** - Time-Series Datenbank
- **Prometheus** - Metrics Collection
- **Loki** - Log Aggregation

### Storage Services
- **PostgreSQL** - Relationale Datenbank
- **Redis** - In-Memory Cache
- **NFS/SMB** - File Storage (via TrueNAS)

## Environment-Management

### Initialization Script

Das Init-Script erstellt automatisch alle `.env`-Dateien aus Templates:

```bash title="/opt/homelab/scripts/init-environment.sh"
#!/bin/bash

echo "🔧 Homelab Environment Setup"
echo "=============================="

# Services mit .env.example Templates
SERVICES=("dns-stack" "traefik" "homeassistant" "monitoring" "portainer")

for service in "${SERVICES[@]}"; do
    SERVICE_DIR="/opt/homelab/$service"
    
    if [ -f "$SERVICE_DIR/.env.example" ]; then
        if [ ! -f "$SERVICE_DIR/.env" ]; then
            echo "📝 Erstelle .env für $service..."
            cp "$SERVICE_DIR/.env.example" "$SERVICE_DIR/.env"
            echo "⚠️  WICHTIG: Editiere $SERVICE_DIR/.env mit echten Werten!"
        else
            echo "✅ .env bereits vorhanden für $service"
        fi
    else
        echo "⚠️  Template fehlt: $SERVICE_DIR/.env.example"
    fi
done

# Sichere Berechtigungen setzen
echo ""
echo "🔒 Setze sichere Berechtigungen..."
find /opt/homelab -name ".env" -exec chmod 600 {} \; 2>/dev/null
chmod 700 /opt/homelab/secrets 2>/dev/null
chmod +x /opt/homelab/scripts/*.sh 2>/dev/null

echo ""
echo "🎯 Setup abgeschlossen!"
echo ""
echo "📋 Nächste Schritte:"
echo "   1. Editiere alle .env Dateien mit echten Werten"
echo "   2. Erstelle GPG-Key: gpg --full-generate-key"
echo "   3. Backup erstellen: ./scripts/backup-secrets.sh"
echo "   4. Teste Services: cd dns-stack && docker-compose up -d"
```

### Git-Integration

**Was gehört in Git:**

```bash title=".gitignore Ausschnitt"
# === SENSITIVE DATA ===
# Environment-Dateien mit echten Secrets
**/.env
!**/.env.example
!**/.env.template

# GPG-Keys und verschlüsselte Backups  
**/secrets/gpg-keys/
**/secrets/encrypted-backups/
**/backup/*.tar.gz
**/backup/*.gpg

# === ALLOWED IN GIT ===
# Templates sind erlaubt (enthalten keine echten Secrets)
!**/README.md
!**/docker-compose.yml
!**/unbound.conf
!**/scripts/*.sh
```

!!! danger "Secrets-Schutz"
    Niemals echte Credentials in Git committen! Das Template-System verhindert versehentliche Exposition von Secrets.

## Deployment-Workflow

### 1. Service-Vorbereitung

```bash
# Environment aus Template erstellen
./scripts/init-environment.sh

# Echte Werte in .env eintragen
nano homeassistant/.env
nano monitoring/.env
```

### 2. Docker Networks

```bash
# Externe Networks erstellen (einmalig)
docker network create --driver overlay traefik
docker network create --driver overlay homelab-internal
```

### 3. Service-Deployment

```bash
# Docker Compose Services
cd dns-stack && docker-compose up -d

# Docker Swarm Services  
docker stack deploy -c traefik/docker-compose.yml traefik
docker stack deploy -c homeassistant/docker-compose.yml homeassistant
docker stack deploy -c monitoring/docker-compose.yml monitoring
```

### 4. Verifikation

```bash
# Service-Status prüfen
docker service ls
docker ps

# DNS-Auflösung testen
nslookup ha-prod-01.lab.homelab.example 192.168.1.3

# HTTPS-Zugriff testen
curl -k https://ha-prod-01.lab.homelab.example
curl -k https://grafana-01.lab.homelab.example
```

## Service-Updates

### Rolling Updates

```bash
# Image Updates ziehen
cd /opt/homelab/homeassistant
docker-compose pull

# Service neu starten
docker-compose up -d

# Für Docker Swarm
docker stack deploy --prune -c docker-compose.yml homeassistant
```

### Automatisierte Updates

```bash title="Crontab für automatische Updates"
# Wöchentliche Updates (Sonntag 04:00)
0 4 * * 0 cd /opt/homelab/dns-stack && docker-compose pull && docker-compose up -d
0 4 * * 0 docker stack deploy --prune -c /opt/homelab/traefik/docker-compose.yml traefik
0 5 * * 0 docker stack deploy --prune -c /opt/homelab/homeassistant/docker-compose.yml homeassistant
```

!!! tip "Update-Strategie"
    Staggered Updates vermeiden Totalausfälle:
    
    1. DNS-Services (kritisch)
    2. Core Infrastructure (Traefik)
    3. Application Services (HA, Monitoring)
    4. Optional Services

---

**⏱️ Aufwandsschätzung:**

- **Initial Setup:** 2-4 Stunden
- **Service hinzufügen:** 30-60 Minuten
- **Wartung pro Monat:** 1-2 Stunden
- **Major Updates:** 2-3 Stunde# Service Organisation

Die Service-Organisation ist das Herzstück des Homelabs und definiert, wie alle Container-Services strukturiert, verwaltet und bereitgestellt werden. Eine durchdachte Organisation ermöglicht:

- **Konsistente Verwaltung** aller Services
- **Einfache Reproduzierbarkeit** auf neuer Hardware
- **Sichere Secrets-Verwaltung** ohne Git-Exposition
- **Automatisierte Deployments** und Updates

## Einheitliche Ordnerstruktur

Alle Docker-Services verwenden eine **konsistente Ordnerstruktur** unter `/opt/homelab/` für maximale Wartbarkeit und Automatisierung.

```bash
/opt/homelab/
├── dns-stack/              # Raspberry Pi DNS (Pi-hole + Unbound)
│   ├── docker-compose.yml  # DNS-Service Stack
│   ├── .env                 # Pi-spezifische Umgebungsvariablen
│   ├── .env.example         # Template für neue Setups
│   ├── unbound.conf         # Unbound DNS-Konfiguration
│   └── gravity-sync/        # Synchronisation zwischen Pis
├── traefik/                # Zentraler Reverse Proxy
│   ├── docker-compose.yml  # Traefik + SSL-Terminierung
│   ├── .env                 # netcup API Credentials
│   └── .env.example         # Template
├── homeassistant/          # Home Assistant Stack
│   ├── docker-compose.yml  # HA + Addons
│   ├── .env                 # HA-spezifische Variablen
│   ├── .env.example         # Template
│   └── config/             # Home Assistant Konfiguration
├── monitoring/             # Monitoring-Suite
│   ├── docker-compose.yml  # Grafana, InfluxDB, Prometheus
│   ├── .env                 # Monitoring-Credentials
│   ├── .env.example         # Template
│   └── config/             # Dashboards, Configs
├── portainer/              # Docker Management
│   ├── docker-compose.yml  # Portainer CE
│   ├── .env                 # Portainer-Einstellungen
│   └── .env.example         # Template
├── scripts/                # Automatisierung
│   ├── init-environment.sh # Environment Setup
│   ├── backup-secrets.sh   # Backup-Automatisierung
│   └── restore-secrets.sh  # Recovery-Scripts
└── secrets/                # Sichere Datenverwaltung
    ├── gpg-keys/           # GPG Schlüssel (nicht in Git)
    ├── encrypted-backups/  # Verschlüsselte Backups
    └── .gitignore          # Schutz vor versehentlichem Commit
```

!!! note "Ordner-Berechtigung"
    Alle Service-Ordner sollten restriktive Berechtigungen haben:
    ```bash
    chmod 755 /opt/homelab/
    chmod 700 /opt/homelab/secrets/
    find /opt/homelab -name ".env" -exec chmod 600 {} \;
    ```

## Docker Compose Standards

### Template-System für Environment-Dateien

**Jeder Service hat:**

- `.env.example` - Versioniert in Git (Template)
- `.env` - Lokal, nicht in Git (echte Secrets)

**Beispiel:** `/opt/homelab/homeassistant/.env.example`

```bash title=".env.example"
# Home Assistant Environment Template
HA_VERSION=2024.12
HA_TZ=Europe/Berlin

# Database Configuration
HA_DB_TYPE=postgresql
HA_DB_HOST=postgres-01.lab.homelab.example
HA_DB_NAME=homeassistant
HA_DB_USER=homeassistant
HA_DB_PASSWORD=CHANGE_ME_TO_SECURE_DB_PASSWORD

# Security
HA_ADMIN_PASSWORD=CHANGE_ME_TO_SECURE_ADMIN_PASSWORD

# Integrations
MQTT_BROKER=mqtt-01.lab.homelab.example
MQTT_USER=homeassistant
MQTT_PASSWORD=CHANGE_ME_TO_SECURE_MQTT_PASSWORD

# Monitoring
INFLUXDB_HOST=influx-01.lab.homelab.example
INFLUXDB_TOKEN=CHANGE_ME_TO_SECURE_INFLUX_TOKEN
```

### Docker Compose Konventionen

**Standard-Labels für alle Services:**

```yaml title="Standard Labels"
labels:
  # Traefik Integration (falls Web-Interface vorhanden)
  - "traefik.enable=true"
  - "traefik.http.routers.${SERVICE_NAME}.rule=Host(`${SERVICE_NAME}-01.lab.homelab.example`)"
  - "traefik.http.routers.${SERVICE_NAME}.tls.certresolver=letsencrypt"
  - "traefik.http.services.${SERVICE_NAME}.loadbalancer.server.port=${SERVICE_PORT}"
  
  # Service-Metadaten
  - "homelab.service.name=${SERVICE_NAME}"
  - "homelab.service.version=${SERVICE_VERSION}"
  - "homelab.service.category=${CATEGORY}"  # core, monitoring, iot, etc.
```

**Standard-Networks:**

```yaml title="Network Configuration"
networks:
  traefik:
    external: true  # Für Services mit Web-Interface
  homelab-internal:
    external: true  # Für Service-zu-Service Kommunikation
```

!!! warning "Network-Voraussetzungen"
    Die externen Networks müssen vorher erstellt werden:
    ```bash
    docker network create --driver overlay traefik
    docker network create --driver overlay homelab-internal
    ```

## Service-Kategorien

### Core Services
- **Traefik** - Reverse Proxy und SSL-Terminierung
- **Pi-hole** - DNS-Server und Ad-Blocking
- **Portainer** - Docker Management Interface

### IOT Services
- **Home Assistant** - Smart Home Zentrale
- **MQTT Broker** - Message Queue für IOT-Geräte
- **Node-RED** - Flow-basierte Automatisierung (optional)

### Monitoring Services
- **Grafana** - Dashboard und Visualisierung
- **InfluxDB** - Time-Series Datenbank
- **Prometheus** - Metrics Collection
- **Loki** - Log Aggregation

### Storage Services
- **PostgreSQL** - Relationale Datenbank
- **Redis** - In-Memory Cache
- **NFS/SMB** - File Storage (via TrueNAS)

## Environment-Management

### Initialization Script

Das Init-Script erstellt automatisch alle `.env`-Dateien aus Templates:

```bash title="/opt/homelab/scripts/init-environment.sh"
#!/bin/bash

echo "🔧 Homelab Environment Setup"
echo "=============================="

# Services mit .env.example Templates
SERVICES=("dns-stack" "traefik" "homeassistant" "monitoring" "portainer")

for service in "${SERVICES[@]}"; do
    SERVICE_DIR="/opt/homelab/$service"
    
    if [ -f "$SERVICE_DIR/.env.example" ]; then
        if [ ! -f "$SERVICE_DIR/.env" ]; then
            echo "📝 Erstelle .env für $service..."
            cp "$SERVICE_DIR/.env.example" "$SERVICE_DIR/.env"
            echo "⚠️  WICHTIG: Editiere $SERVICE_DIR/.env mit echten Werten!"
        else
            echo "✅ .env bereits vorhanden für $service"
        fi
    else
        echo "⚠️  Template fehlt: $SERVICE_DIR/.env.example"
    fi
done

# Sichere Berechtigungen setzen
echo ""
echo "🔒 Setze sichere Berechtigungen..."
find /opt/homelab -name ".env" -exec chmod 600 {} \; 2>/dev/null
chmod 700 /opt/homelab/secrets 2>/dev/null
chmod +x /opt/homelab/scripts/*.sh 2>/dev/null

echo ""
echo "🎯 Setup abgeschlossen!"
echo ""
echo "📋 Nächste Schritte:"
echo "   1. Editiere alle .env Dateien mit echten Werten"
echo "   2. Erstelle GPG-Key: gpg --full-generate-key"
echo "   3. Backup erstellen: ./scripts/backup-secrets.sh"
echo "   4. Teste Services: cd dns-stack && docker-compose up -d"
```

### Git-Integration

**Was gehört in Git:**

```bash title=".gitignore Ausschnitt"
# === SENSITIVE DATA ===
# Environment-Dateien mit echten Secrets
**/.env
!**/.env.example
!**/.env.template

# GPG-Keys und verschlüsselte Backups  
**/secrets/gpg-keys/
**/secrets/encrypted-backups/
**/backup/*.tar.gz
**/backup/*.gpg

# === ALLOWED IN GIT ===
# Templates sind erlaubt (enthalten keine echten Secrets)
!**/README.md
!**/docker-compose.yml
!**/unbound.conf
!**/scripts/*.sh
```

!!! danger "Secrets-Schutz"
    Niemals echte Credentials in Git committen! Das Template-System verhindert versehentliche Exposition von Secrets.

## Deployment-Workflow

### 1. Service-Vorbereitung

```bash
# Environment aus Template erstellen
./scripts/init-environment.sh

# Echte Werte in .env eintragen
nano homeassistant/.env
nano monitoring/.env
```

### 2. Docker Networks

```bash
# Externe Networks erstellen (einmalig)
docker network create --driver overlay traefik
docker network create --driver overlay homelab-internal
```

### 3. Service-Deployment

```bash
# Docker Compose Services
cd dns-stack && docker-compose up -d

# Docker Swarm Services  
docker stack deploy -c traefik/docker-compose.yml traefik
docker stack deploy -c homeassistant/docker-compose.yml homeassistant
docker stack deploy -c monitoring/docker-compose.yml monitoring
```

### 4. Verifikation

```bash
# Service-Status prüfen
docker service ls
docker ps

# DNS-Auflösung testen
nslookup ha-prod-01.lab.homelab.example 192.168.1.3

# HTTPS-Zugriff testen
curl -k https://ha-prod-01.lab.homelab.example
curl -k https://grafana-01.lab.homelab.example
```

## Service-Updates

### Rolling Updates

```bash
# Image Updates ziehen
cd /opt/homelab/homeassistant
docker-compose pull

# Service neu starten
docker-compose up -d

# Für Docker Swarm
docker stack deploy --prune -c docker-compose.yml homeassistant
```

### Automatisierte Updates

```bash title="Crontab für automatische Updates"
# Wöchentliche Updates (Sonntag 04:00)
0 4 * * 0 cd /opt/homelab/dns-stack && docker-compose pull && docker-compose up -d
0 4 * * 0 docker stack deploy --prune -c /opt/homelab/traefik/docker-compose.yml traefik
0 5 * * 0 docker stack deploy --prune -c /opt/homelab/homeassistant/docker-compose.yml homeassistant
```

!!! tip "Update-Strategie"
    Staggered Updates vermeiden Totalausfälle:
    
    1. DNS-Services (kritisch)
    2. Core Infrastructure (Traefik)
    3. Application Services (HA, Monitoring)
    4. Optional Services

---

**⏱️ Aufwandsschätzung:**

- **Initial Setup:** 2-4 Stunden
- **Service hinzufügen:** 30-60 Minuten
- **Wartung pro Monat:** 1-2 Stunden
- **Major Updates:** 2-3 Stundenn
