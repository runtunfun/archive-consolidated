# Deployment Guide

## Quick Start (Minimum-Setup)

!!! info "Zielgruppe"
    Dieser Guide richtet sich an Administratoren mit grundlegenden Linux- und Docker-Kenntnissen.

### Hardware-Vorbereitung

**Minimum-Anforderungen:**

- 1x Raspberry Pi 4B (4GB RAM) für DNS-Services
- 1x Server/Mini-PC (8GB RAM, 500GB SSD) für Docker Swarm
- 1x UniFi Gateway (UDM Pro/SE oder Gateway + separate Hardware)
- 1x Managed Switch mit VLAN-Support

!!! warning "Hardware-Kompatibilität"
    Alle IP-Adressen müssen vor Deployment angepasst werden. Das Standard-Schema verwendet 192.168.1.0/24.

### Phase 1: Basis-Netzwerk einrichten

#### UniFi Controller Initial Setup

```bash
# Über Web-Interface (https://unifi.ui.com oder lokal)
# 1. Account erstellen/anmelden
# 2. Gateway adoptieren
# 3. Initiale Konfiguration
```

#### Netzwerk-Struktur erstellen

```bash
# Standard-LAN (bereits vorhanden)
# - Name: "Standard-LAN"
# - Subnetz: 192.168.1.0/24
# - VLAN: Default/Untagged

# IOT-VLAN erstellen
# - Name: "IOT-VLAN" 
# - VLAN ID: 100
# - Subnetz: 192.168.100.0/22
# - DHCP: Aktiviert

# WiFi-Netzwerke
# - "Enzian" → Standard-LAN
# - "Enzian-IOT" → IOT-VLAN (100)
```

**Aufwand:** ~45 Minuten

### Phase 2: DNS-Server deployen

#### Raspberry Pi Setup

```bash
# Raspberry Pi OS (64-bit) installieren
# SSH aktivieren, Standard-User: pi

# Statische IP konfigurieren
sudo nano /etc/dhcpcd.conf
```

```bash
# /etc/dhcpcd.conf
interface eth0
static ip_address=192.168.1.3/24
static routers=192.168.1.1
static domain_name_servers=8.8.8.8
```

#### Docker Installation

```bash
# Docker installieren
sudo curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker pi

# Docker Compose installieren (falls nicht enthalten)
sudo apt update && sudo apt install -y docker-compose-plugin

# Neuanmeldung für Gruppenzugehörigkeit
sudo reboot
```

#### Homelab-Struktur erstellen

```bash
# Basis-Ordnerstruktur
sudo mkdir -p /opt/homelab/{dns-stack,scripts,secrets}
sudo chown -R pi:pi /opt/homelab

# Zur Homelab-Struktur wechseln
cd /opt/homelab
```

#### DNS-Stack Konfiguration

```bash
# DNS-Stack Ordner erstellen
mkdir -p dns-stack
cd dns-stack
```

Erstelle `docker-compose.yml`:

```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v3.0
    hostname: traefik-pi-${PI_NUMBER}
    command:
      - "--api.dashboard=true"
      - "--api.insecure=false"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--entrypoints.web.http.redirections.entrypoint.to=websecure"
      - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
      - "--certificatesresolvers.letsencrypt.acme.dnschallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=netcup"
      - "--certificatesresolvers.letsencrypt.acme.email=admin@homelab.example"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
    environment:
      NETCUP_CUSTOMER_NUMBER: "${NETCUP_CUSTOMER_NUMBER}"
      NETCUP_API_KEY: "${NETCUP_API_KEY}"
      NETCUP_API_PASSWORD: "${NETCUP_API_PASSWORD}"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik_letsencrypt:/letsencrypt
    ports:
      - "80:80"
      - "443:443"
    networks:
      - dns-internal
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.dashboard.rule=Host(`traefik-pi-${PI_NUMBER}.lab.homelab.example`)"
      - "traefik.http.routers.dashboard.service=api@internal"
      - "traefik.http.routers.dashboard.tls.certresolver=letsencrypt"
    restart: unless-stopped

  unbound:
    image: mvance/unbound-rpi:latest
    hostname: unbound-${PI_NUMBER}
    environment:
      TZ: 'Europe/Berlin'
    volumes:
      - unbound_config:/opt/unbound/etc/unbound
      - ./unbound.conf:/opt/unbound/etc/unbound/unbound.conf:ro
    networks:
      dns-internal:
        ipv4_address: 172.20.0.2
    restart: unless-stopped

  pihole:
    image: pihole/pihole:latest
    hostname: pihole-${PI_NUMBER}
    environment:
      TZ: 'Europe/Berlin'
      WEBPASSWORD: '${PIHOLE_PASSWORD}'
      VIRTUAL_HOST: 'pihole-${PI_NUMBER}.lab.homelab.example'
      FTLCONF_LOCAL_IPV4: '${PI_IP}'
      PIHOLE_DNS_: '172.20.0.2#5053'
    volumes:
      - pihole_config:/etc/pihole
      - pihole_dnsmasq:/etc/dnsmasq.d
    ports:
      - "53:53/tcp"
      - "53:53/udp"
    networks:
      dns-internal:
        ipv4_address: 172.20.0.3
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.pihole.rule=Host(`pihole-${PI_NUMBER}.lab.homelab.example`)"
      - "traefik.http.routers.pihole.tls.certresolver=letsencrypt"
      - "traefik.http.services.pihole.loadbalancer.server.port=80"
    depends_on:
      - unbound
      - traefik
    restart: unless-stopped

volumes:
  pihole_config:
  pihole_dnsmasq:
  unbound_config:
  traefik_letsencrypt:

networks:
  dns-internal:
    ipam:
      config:
        - subnet: 172.20.0.0/24
```

Erstelle `.env`:

```bash
# Pi-hole Configuration
PI_NUMBER=01
PI_IP=192.168.1.3
PIHOLE_PASSWORD=secure-admin-password-change-me

# netcup API Credentials
NETCUP_CUSTOMER_NUMBER=YOUR_CUSTOMER_NUMBER
NETCUP_API_KEY=YOUR_API_KEY
NETCUP_API_PASSWORD=YOUR_API_PASSWORD
```

Erstelle `unbound.conf`:

```ini
server:
    interface: 0.0.0.0
    port: 5053
    do-ip4: yes
    do-ip6: no
    do-udp: yes
    do-tcp: yes
    harden-glue: yes
    harden-dnssec-stripped: yes
    use-caps-for-id: no
    edns-buffer-size: 1232
    prefetch: yes
    num-threads: 2
    so-rcvbuf: 1m
    private-address: 192.168.0.0/16
    private-address: 172.16.0.0/12
    private-address: 10.0.0.0/8
    verbosity: 1
    log-queries: no
    hide-identity: yes
    hide-version: yes
    qname-minimisation: yes
    minimal-responses: yes
    msg-cache-size: 50m
    rrset-cache-size: 100m
    cache-max-ttl: 86400

forward-zone:
    name: "lab.homelab.example"
    forward-addr: 172.20.0.3@53

forward-zone:
    name: "iot.homelab.example"  
    forward-addr: 172.20.0.3@53

forward-zone:
    name: "guest.homelab.example"
    forward-addr: 172.20.0.3@53
```

#### DNS-Stack starten

```bash
# Stack starten
docker-compose up -d

# Logs überprüfen
docker-compose logs -f

# Status prüfen
docker-compose ps
```

!!! success "Checkpoint"
    DNS sollte jetzt unter https://pihole-01.lab.homelab.example erreichbar sein.

#### UniFi DNS umstellen

```bash
# Im UniFi Controller:
# Settings → Networks → Standard-LAN → Advanced
# DHCP Name Server: Manual
# DNS Server 1: 192.168.1.3
# DNS Server 2: 8.8.8.8 (Fallback)
```

**Aufwand:** ~2 Stunden

### Phase 3: Docker Swarm einrichten

#### Server-Setup

```bash
# Ubuntu Server 22.04 LTS installieren
# Statische IP: 192.168.1.45

# Docker installieren
sudo curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Neuanmeldung
logout
```

#### Swarm Initialisierung

```bash
# Swarm initialisieren
docker swarm init --advertise-addr 192.168.1.45

# Basis-Networks erstellen
docker network create --driver overlay traefik
docker network create --driver overlay homelab-internal

# Node-Status prüfen
docker node ls
```

#### Homelab-Struktur kopieren

```bash
# Struktur erstellen
sudo mkdir -p /opt/homelab
sudo chown -R $USER:$USER /opt/homelab

# Von Pi-hole Server kopieren (falls Repository vorhanden)
# oder manuell erstellen
cd /opt/homelab
```

**Aufwand:** ~30 Minuten

### Phase 4: Core Services deployen

#### Traefik (Reverse Proxy)

```bash
mkdir -p traefik
cd traefik
```

Erstelle `docker-compose.yml`:

```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v3.0
    command:
      - "--api.dashboard=true"
      - "--api.insecure=false"
      - "--providers.docker=true"
      - "--providers.docker.swarmMode=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--entrypoints.web.http.redirections.entrypoint.to=websecure"
      - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
      - "--certificatesresolvers.letsencrypt.acme.dnschallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=netcup"
      - "--certificatesresolvers.letsencrypt.acme.email=admin@homelab.example"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
    environment:
      NETCUP_CUSTOMER_NUMBER: "${NETCUP_CUSTOMER_NUMBER}"
      NETCUP_API_KEY: "${NETCUP_API_KEY}"
      NETCUP_API_PASSWORD: "${NETCUP_API_PASSWORD}"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik_letsencrypt:/letsencrypt
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.dashboard.rule=Host(`traefik-01.lab.homelab.example`)"
      - "traefik.http.routers.dashboard.service=api@internal"
      - "traefik.http.routers.dashboard.tls.certresolver=letsencrypt"
    networks:
      - traefik
    deploy:
      placement:
        constraints:
          - node.role == manager

volumes:
  traefik_letsencrypt:

networks:
  traefik:
    external: true
```

Erstelle `.env`:

```bash
# netcup API Credentials (identisch wie bei Pi-hole)
NETCUP_CUSTOMER_NUMBER=YOUR_CUSTOMER_NUMBER
NETCUP_API_KEY=YOUR_API_KEY
NETCUP_API_PASSWORD=YOUR_API_PASSWORD
```

Deployen:

```bash
# Stack deployen
docker stack deploy -c docker-compose.yml traefik

# Status prüfen
docker service ls
docker service logs traefik_traefik
```

#### Home Assistant

```bash
cd /opt/homelab
mkdir -p homeassistant
cd homeassistant
```

Erstelle `docker-compose.yml`:

```yaml
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
      - "8123:8123"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.homeassistant.rule=Host(`ha-prod-01.lab.homelab.example`)"
      - "traefik.http.routers.homeassistant.tls.certresolver=letsencrypt"
      - "traefik.http.services.homeassistant.loadbalancer.server.port=8123"
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
      - "1883:1883"
      - "8883:8883"
    networks:
      - homelab-internal
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

Erstelle `.env`:

```bash
# Home Assistant Configuration
HA_VERSION=2024.12
HA_TZ=Europe/Berlin

# Database
HA_DB_NAME=homeassistant
HA_DB_USER=homeassistant
HA_DB_PASSWORD=secure-db-password-change-me
```

Deployen:

```bash
# Stack deployen
docker stack deploy -c docker-compose.yml homeassistant

# Logs prüfen
docker service logs homeassistant_homeassistant
```

**Aufwand:** ~1 Stunde

### Phase 5: System-Tests

#### DNS-Tests

```bash
# Lokale Auflösung testen
nslookup ha-prod-01.lab.homelab.example 192.168.1.3
dig @192.168.1.3 traefik-01.lab.homelab.example

# Pi-hole Web-Interface
curl -k https://pihole-01.lab.homelab.example
```

#### HTTPS-Tests

```bash
# Service-Erreichbarkeit
curl -k https://ha-prod-01.lab.homelab.example
curl -k https://traefik-01.lab.homelab.example

# Zertifikat-Status prüfen
openssl s_client -connect traefik-01.lab.homelab.example:443 -servername traefik-01.lab.homelab.example
```

#### Netzwerk-Tests

```bash
# VLAN-Konnektivität (von Standard-LAN zu IOT)
ping 192.168.100.1

# Docker Service-Kommunikation
docker exec -it $(docker ps -q -f name=homeassistant) ping postgres-ha-01
```

!!! success "Deployment abgeschlossen"
    Das Basis-Setup ist jetzt funktionsfähig. Alle Services sind über HTTPS erreichbar.

**Gesamtaufwand:** ~4-5 Stunden

## Erweiterte Einrichtung

### Hochverfügbarkeit

#### Zweiter Raspberry Pi

!!! tip "Redundanz"
    Ein zweiter Pi-hole Server erhöht die DNS-Verfügbarkeit deutlich.

```bash
# Identisches Setup wie Pi #1
# Nur IP-Adressen anpassen:
# PI_IP=192.168.1.4
# PI_NUMBER=02

# Gravity Sync für Synchronisation einrichten
# SSH-Keys zwischen beiden Pis austauschen
ssh-keygen -t rsa -b 4096
ssh-copy-id pi@192.168.1.3
```

#### Docker Swarm Cluster

```bash
# Weitere Worker-Nodes hinzufügen
# Auf zusätzlichen Servern:
docker swarm join --token <worker-token> 192.168.1.45:2377

# Service-Replikation erhöhen
docker service update --replicas 2 homeassistant_homeassistant
```

#### Monitoring-Stack

```bash
mkdir -p /opt/homelab/monitoring
cd monitoring
```

Monitoring `docker-compose.yml`:

```yaml
version: '3.8'

services:
  grafana:
    image: grafana/grafana:latest
    hostname: grafana-01
    environment:
      GF_SERVER_ROOT_URL: "https://grafana-01.lab.homelab.example"
      GF_SECURITY_ADMIN_PASSWORD: "${GRAFANA_ADMIN_PASSWORD}"
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - traefik
      - homelab-internal
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.grafana.rule=Host(`grafana-01.lab.homelab.example`)"
      - "traefik.http.routers.grafana.tls.certresolver=letsencrypt"
      - "traefik.http.services.grafana.loadbalancer.server.port=3000"
    deploy:
      placement:
        constraints:
          - node.role == manager

  influxdb:
    image: influxdb:2.7
    hostname: influx-01
    environment:
      INFLUXDB_DB: "${INFLUXDB_DATABASE}"
      INFLUXDB_ADMIN_USER: "${INFLUXDB_ADMIN_USER}"
      INFLUXDB_ADMIN_PASSWORD: "${INFLUXDB_ADMIN_PASSWORD}"
    volumes:
      - influxdb_data:/var/lib/influxdb2
    networks:
      - homelab-internal
    ports:
      - "8086:8086"
    deploy:
      placement:
        constraints:
          - node.role == manager

volumes:
  grafana_data:
  influxdb_data:

networks:
  traefik:
    external: true
  homelab-internal:
    external: true
```

**Aufwand:** ~2-3 Stunden zusätzlich

### Proxmox Integration

!!! note "Optional"
    Proxmox bietet VM-Management und erweiterte Backup-Funktionen.

```bash
# Proxmox VE auf dedizierter Hardware installieren
# VMs für Docker Swarm Worker erstellen
# Hochverfügbarkeits-Cluster einrichten
```

**Aufwand:** ~4-6 Stunden

## Automatisierungsscripts

### Environment-Setup Script

Erstelle `/opt/homelab/scripts/init-environment.sh`:

```bash
#!/bin/bash

echo "🔧 Homelab Environment Setup"
echo "=============================="

SERVICES=("dns-stack" "traefik" "homeassistant" "monitoring")

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
    fi
done

echo ""
echo "🔒 Setze sichere Berechtigungen..."
find /opt/homelab -name ".env" -exec chmod 600 {} \; 2>/dev/null
chmod 700 /opt/homelab/secrets 2>/dev/null
chmod +x /opt/homelab/scripts/*.sh 2>/dev/null

echo ""
echo "🎯 Setup abgeschlossen!"
```

### Health-Check Script

Erstelle `/opt/homelab/scripts/health-check.sh`:

```bash
#!/bin/bash

echo "🔍 Homelab Health Check"
echo "======================="

# DNS-Tests
echo "📡 DNS-Tests..."
nslookup ha-prod-01.lab.homelab.example 192.168.1.3 > /dev/null && echo "✅ DNS funktioniert" || echo "❌ DNS Problem"

# Service-Tests
echo "🌐 Service-Tests..."
curl -s -k https://traefik-01.lab.homelab.example > /dev/null && echo "✅ Traefik erreichbar" || echo "❌ Traefik Problem"
curl -s -k https://ha-prod-01.lab.homelab.example > /dev/null && echo "✅ Home Assistant erreichbar" || echo "❌ HA Problem"

# Docker Swarm Status
echo "🐳 Docker Swarm..."
docker node ls --format "table {{.Hostname}}\t{{.Status}}\t{{.Availability}}"

echo ""
echo "Health Check abgeschlossen."
```

```bash
# Scripts ausführbar machen
chmod +x /opt/homelab/scripts/*.sh
```

**Aufwand:** ~30 Minuten
