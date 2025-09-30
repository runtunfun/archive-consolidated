# Homelab & IOT Infrastructure - Unified Documentation

**Version:** 6.0  
**Erstellt:** Dezember 2024  
**Letzte Aktualisierung:** Januar 2025

---

## 1. Einleitung & Übersicht

### 1.1 Ziele des Homelabs

Diese Dokumentation beschreibt eine professionelle Homelab-Infrastruktur mit integrierter Smart Home (IOT) Verwaltung. Die Lösung kombiniert:

- **Professionelle Netzwerk-Segmentierung** mit VLANs für Sicherheit und Performance
- **Lokale DNS-Auflösung** für Unabhängigkeit und Privatsphäre  
- **Verschlüsselte HTTPS-Services** mit echten Let's Encrypt Zertifikaten
- **Skalierbare Container-Architektur** mit Docker Swarm
- **Smart Home Integration** mit Home Assistant als zentraler Plattform

### 1.2 Architektur-Übersicht

```
Internet (Domain: [DOMAIN])
         |
    UniFi Gateway
         |
    ┌────┼────┐
    │    │    │
Standard│IOT │Gäste
  VLAN  │VLAN│VLAN
         │    │
    Homelab│Smart│Guest
    Services│Home│Access
         │    │
    Pi-hole │    │
    + DNS   │    │
         │    │
    Docker  │    │
    Swarm   │    │
```

### 1.3 Hardware-Anforderungen

#### Minimum-Setup
- **1x Raspberry Pi 4B (4GB)** für DNS (Pi-hole + Unbound)
- **1x Server/Mini-PC** für Docker Swarm (8GB RAM, 500GB SSD)
- **1x UniFi Gateway** (UDM Pro/SE oder Gateway + Separate Hardware)
- **1x Managed Switch** mit VLAN-Support
- **1-2x WiFi Access Points** (UniFi empfohlen)

#### Empfohlenes Setup (Hochverfügbarkeit)
- **2x Raspberry Pi 4B (4GB)** für redundante DNS
- **2-3x Server** für Docker Swarm Cluster (16GB RAM, 1TB SSD pro Server)
- **1x Proxmox Cluster** für VM-Management (optional)
- **1x NAS** für zentralen Storage (TrueNAS Scale)
- **UniFi Ecosystem** (UDM Pro, Pro Switches, Pro APs)

---

## 2. Netzwerk-Grundlagen

### 2.1 Netzwerkplanung

#### VLAN-Übersicht

| VLAN | Name | Subnetz | Gateway | Zweck |
|------|------|---------|---------|-------|
| **Default/1** | Standard-LAN | 192.168.1.0/24 | 192.168.1.1 | Homelab & Management |
| **100** | IOT-VLAN | 192.168.100.0/22 | 192.168.100.1 | Smart Home + Mobile Clients |
| **200** | Gäste-VLAN | 192.168.200.0/24 | 192.168.200.1 | Gast-Zugang |

#### DNS-Konfiguration (alle VLANs)
- **Primary DNS:** 192.168.1.3 (Pi-hole #1)
- **Secondary DNS:** 192.168.1.4 (Pi-hole #2, optional)
- **Fallback DNS:** 8.8.8.8

### 2.2 Detaillierte IP-Bereiche

#### Standard-LAN (192.168.1.0/24) - Homelab & Management

| Bereich | IP-Bereich | Anzahl IPs | Verwendung |
|---------|------------|------------|------------|
| **Gateway** | 192.168.1.1 | 1 | UniFi Gateway |
| **Core Infrastructure** | 192.168.1.2 - 192.168.1.20 | 19 | UniFi Controller, Pi-hole, Switches, APs |
| **Homelab Core** | 192.168.1.21 - 192.168.1.40 | 20 | Proxmox Hosts, Storage |
| **Homelab Services** | 192.168.1.41 - 192.168.1.99 | 59 | VMs, Docker Container, Services |
| **DHCP Pool** | 192.168.1.100 - 192.168.1.200 | 101 | Automatische Zuweisung |
| **Client Devices** | 192.168.1.201 - 192.168.1.220 | 20 | Desktop, Laptop (Management) |
| **Reserve** | 192.168.1.221 - 192.168.1.254 | 34 | Für zukünftige Erweiterungen |

#### IOT-VLAN (192.168.100.0/22) - Smart Home + Mobile Clients

| Raum/Bereich | IP-Bereich | Anzahl IPs | Verwendung |
|--------------|------------|------------|------------|
| **Unterverteilung** | 192.168.100.1 - 192.168.100.62 | 62 | Zentrale Steuergeräte, Homematic CCU |
| **Flur** | 192.168.100.65 - 192.168.100.126 | 62 | Shelly Schalter, Sensoren |
| **Arbeitszimmer** | 192.168.100.129 - 192.168.100.190 | 62 | Shelly Relais, Hue Arbeitsplatz |
| **Schlafzimmer** | 192.168.100.193 - 192.168.100.254 | 62 | Hue Lampen, Klimasensoren |
| **Wohnzimmer** | 192.168.101.1 - 192.168.101.62 | 62 | Hue Lampen, Sonos, TV-Geräte |
| **Küche** | 192.168.101.65 - 192.168.101.126 | 62 | Küchengeräte, Sonos |
| **Bad** | 192.168.101.129 - 192.168.101.190 | 62 | Feuchtigkeitssensoren, Lüftung |
| **Mobile Clients** | 192.168.101.191 - 192.168.101.230 | 40 | **Smartphones, Tablets, Smart-TVs** |
| **Reserve** | 192.168.101.231 - 192.168.103.254 | 536 | Für zukünftige Erweiterungen |

#### Gäste-VLAN (192.168.200.0/24) - Gast-Zugang

| Bereich | IP-Bereich | Anzahl IPs | Verwendung |
|---------|------------|------------|------------|
| **Gateway** | 192.168.200.1 | 1 | VLAN Gateway |
| **Reserve** | 192.168.200.2 - 192.168.200.9 | 8 | Für spezielle Konfiguration |
| **DHCP Pool** | 192.168.200.10 - 192.168.200.250 | 241 | Gäste-Geräte (automatisch) |
| **Reserve** | 192.168.200.251 - 192.168.200.254 | 4 | Für zukünftige Erweiterungen |

### 2.3 DNS-Naming-Konvention

#### Domain-Schema
- **Standard-LAN:** `[raum]-[geraetetype]-[nummer].lab.[DOMAIN]`
- **IOT-VLAN:** `[raum]-[geraetetype]-[nummer].iot.[DOMAIN]`
- **Gäste-VLAN:** `guest-[geraetetype]-[nummer].guest.[DOMAIN]`

#### Gerätetypen (Suffixe)

**Homelab & Infrastructure (Standard-LAN):**
- `-pve` : Proxmox VE Hosts
- `-vm` : Virtuelle Maschinen
- `-docker` : Docker Hosts/Swarm Nodes
- `-ha` : Home Assistant Instanzen
- `-nas` : NAS/Storage Systeme
- `-unifi` : UniFi Controller
- `-switch` : Managed Switches
- `-ap` : Access Points

**Smart Home Geräte (IOT-VLAN):**
- `-shelly-dimmer` : Shelly Dimmer
- `-shelly-pro1pm` : Shelly Pro 1PM
- `-shelly-1` : Shelly 1 (Relais)
- `-hm-window` : Homematic Fensterkontakt
- `-hm-motion` : Homematic Bewegungsmelder
- `-hm-temp` : Homematic Temperatursensor
- `-hue` : Philips Hue Geräte
- `-sonos` : Sonos Lautsprecher

#### Raum-Abkürzungen
- `flur` : Flur
- `wz` : Wohnzimmer
- `sz` : Schlafzimmer
- `az` : Arbeitszimmer
- `bad` : Bad
- `kueche` : Küche
- `uv` : Unterverteilung

#### Beispiele
```
# Standard-LAN (Homelab)
lab-pve-01.lab.[DOMAIN]                     → Proxmox Host 1
lab-ha-prod-01.lab.[DOMAIN]                 → Home Assistant Produktiv
lab-traefik-01.lab.[DOMAIN]                 → Traefik Reverse Proxy

# IOT-VLAN (Smart Home)
flur-shelly-dimmer-01.iot.[DOMAIN]          → Shelly Dimmer im Flur
wz-hue-03.iot.[DOMAIN]                      → Hue Lampe im Wohnzimmer
sz-hm-temp-01.iot.[DOMAIN]                  → Temperatursensor Schlafzimmer
```

### 2.4 UniFi-Konfiguration

#### Standard-LAN Einstellungen
1. **Standard-Netzwerk (Default):**
   - Name: "Standard-LAN"
   - VLAN: Untagged/Default
   - Subnetz: 192.168.1.0/24
   - DHCP: Aktiviert
   - DNS: 192.168.1.3, 192.168.1.4
   - Domain: lab.[DOMAIN]

2. **WiFi-Netzwerk "[WIFI_NAME]":**
   - Sicherheit: WPA2/WPA3
   - VLAN: Standard-LAN (Default)
   - Band: Dual-Band (2.4 + 5 GHz)

#### IOT-VLAN Einstellungen
1. **Netzwerk erstellen:**
   - Name: "IOT-VLAN"
   - VLAN ID: 100
   - Subnetz: 192.168.100.0/22
   - DHCP: Aktiviert
   - DNS: 192.168.1.3, 192.168.1.4
   - Domain: iot.[DOMAIN]

2. **WiFi-Netzwerk "[WIFI_NAME]-IOT":**
   - Sicherheit: WPA2/WPA3
   - VLAN: IOT-VLAN (100)
   - Gast-Isolation: Aktiviert

#### Gäste-VLAN Einstellungen
1. **Netzwerk erstellen:**
   - Name: "Gäste-VLAN"
   - VLAN ID: 200
   - Subnetz: 192.168.200.0/24
   - DHCP: Aktiviert
   - DNS: 192.168.1.3
   - Domain: guest.[DOMAIN]

2. **WiFi-Netzwerk "[WIFI_NAME]-Gast":**
   - Sicherheit: WPA2/WPA3 (einfaches Passwort)
   - VLAN: Gäste-VLAN (200)
   - Gast-Isolation: Aktiviert
   - Bandbreiten-Limit: 50 Mbit/s (optional)

### 2.5 UniFi Zone Matrix Konfiguration

#### Zone-Definitionen

**Zone 1: "Internal" (Built-in)**
- Netzwerke: Standard-LAN (192.168.1.0/24)
- Beschreibung: Homelab und Management

**Zone 2: "IOT" (Neu erstellen)**
- Netzwerke: IOT-VLAN (192.168.100.0/22)
- Beschreibung: Smart Home + Mobile Clients

**Zone 3: "Hotspot" (Built-in)**
- Netzwerke: Gäste-VLAN (192.168.200.0/24)
- Beschreibung: Gäste-Zugang

#### Zone Matrix

| Von → Nach | Internal | IOT | Hotspot | Internet |
|------------|----------|-----|---------|----------|
| **Internal** | ✅ Allow | ✅ Allow | ❌ Block | ✅ Allow |
| **IOT** | 🔸 Limited | ✅ Allow | ❌ Block | ✅ Allow |
| **Hotspot** | 🔸 Limited | ❌ Block | ✅ Allow | ✅ Allow |
| **Internet** | ✅ Allow | ✅ Allow | ✅ Allow | ✅ Allow |

#### Limited Access Rules

**IOT → Internal (🔸 Limited):**
- Port 53 (DNS zu Pi-hole: 192.168.1.3)
- Port 123 (NTP für Zeitserver)
- Port 8123 (Home Assistant Web-Interface)
- Port 1883/8883 (MQTT Broker)
- Port 5353 (mDNS für Device Discovery)

**Hotspot → Internal (🔸 Limited):**
- Port 53 (DNS zu Pi-hole: 192.168.1.3)
- Port 123 (NTP für Zeitserver)

---

## 3. Core Infrastructure Services

### 3.1 DNS-Infrastruktur

#### 3.1.1 Architektur-Entscheidung: Raspberry Pi

**Warum dedizierte Hardware statt VMs?**
- **Bootstrap-Problem vermeiden:** VMs brauchen DNS zum Starten
- **Unabhängigkeit:** DNS läuft getrennt vom Proxmox Cluster
- **Hochverfügbarkeit:** Zwei Raspberry Pis für Redundanz
- **Kostengünstig:** ~€160 für zwei Pis vs. VM-Ressourcen

**Hardware-Spezifikation (pro Pi):**
- Raspberry Pi 4B (4GB RAM)
- SSD via USB 3.0 (bessere Performance als SD-Karte)
- Gigabit Ethernet (kein WiFi für kritische Infrastruktur)
- USV/Powerbank (optional für Stromausfälle)

#### 3.1.2 IP-Adresszuweisung

```
Pi-hole Primary:   192.168.1.3 → lab-pihole-01.lab.[DOMAIN]
Pi-hole Secondary: 192.168.1.4 → lab-pihole-02.lab.[DOMAIN]

UniFi DHCP DNS-Server:
Primary DNS:   192.168.1.3
Secondary DNS: 192.168.1.4
Tertiary DNS:  8.8.8.8 (ultimativer Fallback)
```

#### 3.1.3 Docker Compose Konfiguration

**Datei:** `/opt/homelab/dns-stack/docker-compose.yml` (identisch auf beiden Pis)

```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v3.0
    hostname: lab-traefik-pi-${PI_NUMBER}
    command:
      # API und Dashboard
      - "--api.dashboard=true"
      - "--api.insecure=false"
      
      # Provider
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      
      # Entrypoints
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--entrypoints.web.http.redirections.entrypoint.to=websecure"
      - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
      
      # Let's Encrypt mit DNS-Challenge
      - "--certificatesresolvers.letsencrypt.acme.dnschallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=[DNS_PROVIDER]"
      - "--certificatesresolvers.letsencrypt.acme.email=admin@[DOMAIN]"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
      
      # Logging
      - "--log.level=INFO"
      - "--accesslog=true"
    
    environment:
      # DNS Provider API Credentials
      DNS_PROVIDER_CUSTOMER_NUMBER: "${DNS_PROVIDER_CUSTOMER_NUMBER}"
      DNS_PROVIDER_API_KEY: "${DNS_PROVIDER_API_KEY}"
      DNS_PROVIDER_API_PASSWORD: "${DNS_PROVIDER_API_PASSWORD}"
    
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik_letsencrypt:/letsencrypt
    
    ports:
      - "80:80"
      - "443:443"
    
    networks:
      - dns-internal
    
    labels:
      # Traefik Dashboard
      - "traefik.enable=true"
      - "traefik.http.routers.dashboard.rule=Host(`lab-traefik-pi-${PI_NUMBER}.lab.[DOMAIN]`)"
      - "traefik.http.routers.dashboard.service=api@internal"
      - "traefik.http.routers.dashboard.tls.certresolver=letsencrypt"
      - "traefik.http.routers.dashboard.middlewares=auth"
      
      # Basic Auth für Dashboard
      - "traefik.http.middlewares.auth.basicauth.users=admin:$$2y$$10$$..."  # htpasswd generiert
    
    restart: unless-stopped

  unbound:
    image: mvance/unbound-rpi:latest  # ARM-optimiert
    hostname: lab-unbound-${PI_NUMBER}
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
    hostname: lab-pihole-${PI_NUMBER}
    environment:
      TZ: 'Europe/Berlin'
      WEBPASSWORD: '${PIHOLE_PASSWORD}'
      VIRTUAL_HOST: 'lab-pihole-${PI_NUMBER}.lab.[DOMAIN]'
      FTLCONF_LOCAL_IPV4: '${PI_IP}'
      PIHOLE_DNS_: '172.20.0.2#5053'  # Lokaler Unbound
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
      # Pi-hole über Traefik mit HTTPS
      - "traefik.enable=true"
      - "traefik.http.routers.pihole.rule=Host(`lab-pihole-${PI_NUMBER}.lab.[DOMAIN]`)"
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

#### 3.1.4 Environment-Konfiguration

**Pi #1:** `/opt/homelab/dns-stack/.env`
```bash
PI_NUMBER=01
PI_IP=192.168.1.3
REMOTE_PI_IP=192.168.1.4
PIHOLE_PASSWORD=[SECURE_PASSWORD]

# DNS Provider API Credentials (für Let's Encrypt DNS-Challenge)
DNS_PROVIDER_CUSTOMER_NUMBER=[CUSTOMER_NUMBER]
DNS_PROVIDER_API_KEY=[API_KEY]
DNS_PROVIDER_API_PASSWORD=[API_PASSWORD]
```

**Pi #2:** `/opt/homelab/dns-stack/.env`
```bash
PI_NUMBER=02
PI_IP=192.168.1.4
REMOTE_PI_IP=192.168.1.3
PIHOLE_PASSWORD=[SECURE_PASSWORD]

# DNS Provider API Credentials (identisch auf beiden Pis)
DNS_PROVIDER_CUSTOMER_NUMBER=[CUSTOMER_NUMBER]
DNS_PROVIDER_API_KEY=[API_KEY]
DNS_PROVIDER_API_PASSWORD=[API_PASSWORD]
```

#### 3.1.5 Unbound Konfiguration

**Datei:** `/opt/homelab/dns-stack/unbound.conf` (identisch auf beiden Pis)

```conf
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

# Forward zones für lokale Domains
forward-zone:
    name: "lab.[DOMAIN]"
    forward-addr: 172.20.0.3@53

forward-zone:
    name: "iot.[DOMAIN]"  
    forward-addr: 172.20.0.3@53

forward-zone:
    name: "guest.[DOMAIN]"
    forward-addr: 172.20.0.3@53
```

#### 3.1.6 Pi-hole DNS-Einträge

**Lokale DNS-Einträge (via Pi-hole Web-Interface):**

```bash
# Core Infrastructure
192.168.1.2    lab-unifi-controller-01.lab.[DOMAIN]
192.168.1.3    lab-pihole-01.lab.[DOMAIN]
192.168.1.4    lab-pihole-02.lab.[DOMAIN]

# Homelab Core
192.168.1.21   lab-pve-01.lab.[DOMAIN]
192.168.1.22   lab-pve-02.lab.[DOMAIN]
192.168.1.25   lab-nas-01.lab.[DOMAIN]

# Homelab Services
192.168.1.41   lab-ha-prod-01.lab.[DOMAIN]
192.168.1.48   lab-traefik-01.lab.[DOMAIN]
192.168.1.50   lab-portainer-01.lab.[DOMAIN]
192.168.1.51   lab-grafana-01.lab.[DOMAIN]

# IOT-Geräte (wichtigste)
192.168.100.10  uv-hm-ccu-01.iot.[DOMAIN]
192.168.101.1   wz-hue-bridge-01.iot.[DOMAIN]
```

**Wildcard-Domains (via dnsmasq config):**

```bash
# /etc/dnsmasq.d/02-lab-wildcard.conf
address=/lab.[DOMAIN]/192.168.1.48

# /etc/dnsmasq.d/03-iot-wildcard.conf  
address=/iot.[DOMAIN]/192.168.1.48

# /etc/dnsmasq.d/04-guest-wildcard.conf
address=/guest.[DOMAIN]/192.168.1.48
```

### 3.2 HTTPS & Reverse Proxy

#### 3.2.1 Traefik Übersicht

Alle Homelab-Services werden über HTTPS mit echten Let's Encrypt Zertifikaten bereitgestellt:
- **Domain:** [DOMAIN] (gehostet bei DNS-Provider)
- **Reverse Proxy:** Traefik mit automatischer SSL-Terminierung
- **Zertifikate:** Let's Encrypt Wildcard via DNS-Challenge

#### 3.2.2 Traefik Hauptkonfiguration

**Datei:** `/opt/homelab/traefik/docker-compose.yml`

```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v3.0
    command:
      # API und Dashboard
      - "--api.dashboard=true"
      - "--api.insecure=false"
      
      # Provider
      - "--providers.docker=true"
      - "--providers.docker.swarmMode=true"
      - "--providers.docker.exposedbydefault=false"
      
      # Entrypoints
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--entrypoints.web.http.redirections.entrypoint.to=websecure"
      - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
      
      # Let's Encrypt mit DNS-Challenge für Wildcards
      - "--certificatesresolvers.letsencrypt.acme.dnschallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=[DNS_PROVIDER]"
      - "--certificatesresolvers.letsencrypt.acme.email=admin@[DOMAIN]"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
      
      # Logging
      - "--log.level=INFO"
      - "--accesslog=true"
      
    ports:
      - "80:80"
      - "443:443"
      
    environment:
      # DNS Provider API Credentials
      DNS_PROVIDER_CUSTOMER_NUMBER: "${DNS_PROVIDER_CUSTOMER_NUMBER}"
      DNS_PROVIDER_API_KEY: "${DNS_PROVIDER_API_KEY}"
      DNS_PROVIDER_API_PASSWORD: "${DNS_PROVIDER_API_PASSWORD}"
      
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik_letsencrypt:/letsencrypt
      
    labels:
      # Traefik Dashboard
      - "traefik.enable=true"
      - "traefik.http.routers.dashboard.rule=Host(`lab-traefik-01.lab.[DOMAIN]`)"
      - "traefik.http.routers.dashboard.service=api@internal"
      - "traefik.http.routers.dashboard.tls.certresolver=letsencrypt"
      - "traefik.http.routers.dashboard.middlewares=auth"
      
      # Basic Auth für Dashboard
      - "traefik.http.middlewares.auth.basicauth.users=admin:$$2y$$10$$..."  # htpasswd generiert
      
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

---

## 4. Service-Organisation

### 4.1 Einheitliche Ordnerstruktur

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
│   ├── .env                 # DNS Provider API Credentials
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

### 4.2 Service-Deployment

#### 4.2.1 Home Assistant Stack

**Datei:** `/opt/homelab/homeassistant/docker-compose.yml`

```yaml
version: '3.8'

services:
  homeassistant:
    image: homeassistant/home-assistant:${HA_VERSION}
    hostname: lab-ha-prod-01
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
      - "traefik.http.routers.homeassistant.rule=Host(`lab-ha-prod-01.lab.[DOMAIN]`)"
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
    hostname: lab-postgres-ha-01
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
    hostname: lab-mqtt-01
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

---

## 5. Sicherheit & Verwaltung

### 5.1 Secrets-Management

#### 5.1.1 Template-System

**Standard-Templates für alle Services:**

```bash
# /opt/homelab/dns-stack/.env.example
PI_NUMBER=01
PI_IP=192.168.1.3
REMOTE_PI_IP=192.168.1.4
PIHOLE_PASSWORD=[SECURE_PASSWORD]

# DNS Provider API Credentials
DNS_PROVIDER_CUSTOMER_NUMBER=[CUSTOMER_NUMBER]
DNS_PROVIDER_API_KEY=[API_KEY]
DNS_PROVIDER_API_PASSWORD=[API_PASSWORD]

# /opt/homelab/traefik/.env.example
# DNS Provider API Credentials (identisch wie bei Pi-hole)
DNS_PROVIDER_CUSTOMER_NUMBER=[CUSTOMER_NUMBER]
DNS_PROVIDER_API_KEY=[API_KEY]
DNS_PROVIDER_API_PASSWORD=[API_PASSWORD]

# /opt/homelab/homeassistant/.env.example
HA_DB_PASSWORD=[SECURE_DB_PASSWORD]
HA_ADMIN_PASSWORD=[SECURE_ADMIN_PASSWORD]
MQTT_PASSWORD=[SECURE_MQTT_PASSWORD]
```

#### 5.1.2 .gitignore Konfiguration

**Datei:** `/opt/homelab/.gitignore`

```bash
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

# Temporary und Cache-Dateien
**/.sops.yaml.bak
**/sops-key-*.asc
**/.gnupg/
**/node_modules/
**/__pycache__/
**/.DS_Store

# === ALLOWED IN GIT ===
# Templates sind erlaubt (enthalten keine echten Secrets)
!**/README.md
!**/docker-compose.yml
!**/unbound.conf
!**/scripts/*.sh
```

---

## 6. Geräte-Inventar & Dokumentation

### 6.1 Standard-LAN Inventar

#### 6.1.1 UniFi Infrastructure (192.168.1.2 - 192.168.1.20)

| Gerät | IP | DNS-Name | Öffentlicher Zugang | Notizen |
|-------|----|---------|--------------------|---------|
| **UniFi Controller** | 192.168.1.2 | lab-unifi-controller-01.lab.[DOMAIN] | - | Controller VM/Hardware |
| **Pi-hole Primary** | 192.168.1.3 | lab-pihole-01.lab.[DOMAIN] | https://lab-pihole-01.lab.[DOMAIN] | DNS + Ad-Blocking + Unbound |
| **Pi-hole Secondary** | 192.168.1.4 | lab-pihole-02.lab.[DOMAIN] | https://lab-pihole-02.lab.[DOMAIN] | Redundante DNS (optional) |
| **UniFi Switch Main** | 192.168.1.10 | lab-switch-main-01.lab.[DOMAIN] | - | Hauptswitch Arbeitszimmer |
| **UniFi AP Wohnzimmer** | 192.168.1.11 | wz-ap-01.lab.[DOMAIN] | - | Access Point Wohnzimmer |
| **UniFi AP Schlafzimmer** | 192.168.1.12 | sz-ap-01.lab.[DOMAIN] | - | Access Point Schlafzimmer |

#### 6.1.2 Homelab Core (192.168.1.21 - 192.168.1.40)

| Gerät | IP | DNS-Name | Öffentlicher Zugang | Notizen |
|-------|----|---------|--------------------|---------|
| **Proxmox Host 1** | 192.168.1.21 | lab-pve-01.lab.[DOMAIN] | https://lab-pve-01.lab.[DOMAIN]:8006 | Hauptserver |
| **Proxmox Host 2** | 192.168.1.22 | lab-pve-02.lab.[DOMAIN] | https://lab-pve-02.lab.[DOMAIN]:8006 | Backup/Cluster (optional) |
| **TrueNAS Scale** | 192.168.1.25 | lab-nas-01.lab.[DOMAIN] | https://lab-nas-01.lab.[DOMAIN] | Zentraler Storage |

#### 6.1.3 Homelab Services (192.168.1.41 - 192.168.1.99)

| Service | IP | DNS-Name | Öffentlicher Zugang | Kategorie | Notizen |
|---------|----|---------|--------------------|-----------|---------|
| **Home Assistant Prod** | 192.168.1.41 | lab-ha-prod-01.lab.[DOMAIN] | https://lab-ha-prod-01.lab.[DOMAIN] | IOT | Produktiv HA Instance |
| **Home Assistant Test** | 192.168.1.42 | lab-ha-test-01.lab.[DOMAIN] | - | IOT | Test/Development |
| **Docker Swarm Manager** | 192.168.1.45 | lab-docker-01.lab.[DOMAIN] | - | Core | Swarm Leader |
| **Docker Swarm Worker 1** | 192.168.1.46 | lab-docker-02.lab.[DOMAIN] | - | Core | Swarm Worker (optional) |
| **Docker Swarm Worker 2** | 192.168.1.47 | lab-docker-03.lab.[DOMAIN] | - | Core | Swarm Worker (optional) |
| **Traefik Reverse Proxy** | 192.168.1.48 | lab-traefik-01.lab.[DOMAIN] | https://lab-traefik-01.lab.[DOMAIN] | Core | SSL-Terminierung |
| **Portainer** | 192.168.1.50 | lab-portainer-01.lab.[DOMAIN] | https://lab-portainer-01.lab.[DOMAIN] | Management | Docker Management |
| **Grafana** | 192.168.1.51 | lab-grafana-01.lab.[DOMAIN] | https://lab-grafana-01.lab.[DOMAIN] | Monitoring | Dashboard |
| **InfluxDB** | 192.168.1.52 | lab-influx-01.lab.[DOMAIN] | - | Monitoring | Time Series DB |
| **MQTT Broker** | 192.168.1.55 | lab-mqtt-01.lab.[DOMAIN] | - | IOT | Mosquitto |

### 6.2 IOT-VLAN Inventar

#### 6.2.1 Unterverteilung (192.168.100.1 - 192.168.100.62)

| Gerät | IP | DNS-Name | Hersteller | Notizen |
|-------|----|---------|-----------|---------| 
| **Homematic CCU** | 192.168.100.10 | uv-hm-ccu-01.iot.[DOMAIN] | eQ-3 | Zentrale Steuerung |
| **UniFi Switch IOT** | 192.168.100.11 | uv-switch-01.iot.[DOMAIN] | Ubiquiti | Hauptverteiler (optional) |

#### 6.2.2 Flur (192.168.100.65 - 192.168.100.126)

| Gerät | IP | DNS-Name | Hersteller | Modell | Notizen |
|-------|----|---------|-----------|---------|---------| 
| **Shelly 1 Deckenlampe** | 192.168.100.70 | flur-shelly-1-01.iot.[DOMAIN] | Allterco | Shelly 1 | Hauptlicht |
| **Homematic Bewegungsmelder** | 192.168.100.71 | flur-hm-motion-01.iot.[DOMAIN] | eQ-3 | HmIP-SMI | Eingang |
| **Homematic Türkontakt** | 192.168.100.72 | flur-hm-door-01.iot.[DOMAIN] | eQ-3 | HmIP-SWDO | Haustür |

#### 6.2.3 Arbeitszimmer (192.168.100.129 - 192.168.100.190)

| Gerät | IP | DNS-Name | Hersteller | Modell | Notizen |
|-------|----|---------|-----------|---------|---------| 
| **Shelly Dimmer** | 192.168.100.135 | az-shelly-dimmer-01.iot.[DOMAIN] | Allterco | Shelly Dimmer 2 | Schreibtischlampe |
| **Hue Strip** | 192.168.100.136 | az-hue-01.iot.[DOMAIN] | Philips | Hue Lightstrip | Monitor-Backlight |
| **Homematic Fenster** | 192.168.100.137 | az-hm-window-01.iot.[DOMAIN] | eQ-3 | HmIP-SWDO | Fenster Garten |

#### 6.2.4 Schlafzimmer (192.168.100.193 - 192.168.100.254)

| Gerät | IP | DNS-Name | Hersteller | Modell | Notizen |
|-------|----|---------|-----------|---------|---------| 
| **Hue Lampe Links** | 192.168.100.200 | sz-hue-01.iot.[DOMAIN] | Philips | Hue White and Color | Nachttischlampe |
| **Hue Lampe Rechts** | 192.168.100.201 | sz-hue-02.iot.[DOMAIN] | Philips | Hue White and Color | Nachttischlampe |
| **Homematic Fensterkontakt** | 192.168.100.202 | sz-hm-window-01.iot.[DOMAIN] | eQ-3 | HmIP-SWDO | Fenster Straße |
| **Homematic Thermostat** | 192.168.100.203 | sz-hm-thermo-01.iot.[DOMAIN] | eQ-3 | HmIP-eTRV | Heizkörperthermostat |

#### 6.2.5 Wohnzimmer (192.168.101.1 - 192.168.101.62)

| Gerät | IP | DNS-Name | Hersteller | Modell | Notizen |
|-------|----|---------|-----------|---------|---------| 
| **Hue Bridge** | 192.168.101.1 | wz-hue-bridge-01.iot.[DOMAIN] | Philips | Hue Bridge v2 | Zentrale Bridge |
| **Sonos One** | 192.168.101.10 | wz-sonos-01.iot.[DOMAIN] | Sonos | Sonos One | Musikwiedergabe |
| **Hue Deckenlampe** | 192.168.101.11 | wz-hue-01.iot.[DOMAIN] | Philips | Hue White Ambiance | Hauptbeleuchtung |
| **Hue Stehlampe** | 192.168.101.12 | wz-hue-02.iot.[DOMAIN] | Philips | Hue Go | Ambientelicht |
| **Samsung TV** | 192.168.101.15 | wz-tv-01.iot.[DOMAIN] | Samsung | QE55Q80A | Smart TV |

#### 6.2.6 Küche (192.168.101.65 - 192.168.101.126)

| Gerät | IP | DNS-Name | Hersteller | Modell | Notizen |
|-------|----|---------|-----------|---------|---------| 
| **Shelly 1PM Dunstabzug** | 192.168.101.70 | kueche-shelly-pro1pm-01.iot.[DOMAIN] | Allterco | Shelly Pro 1PM | Dunstabzugsteuerung |
| **Hue Unterbauleuchte** | 192.168.101.71 | kueche-hue-01.iot.[DOMAIN] | Philips | Hue Lightstrip | Arbeitsplatte |
| **Sonos One SL** | 192.168.101.72 | kueche-sonos-01.iot.[DOMAIN] | Sonos | Sonos One SL | Küchenmusik |
| **Homematic Temp** | 192.168.101.73 | kueche-hm-temp-01.iot.[DOMAIN] | eQ-3 | HmIP-STH | Raumtemperatur |

#### 6.2.7 Bad (192.168.101.129 - 192.168.101.190)

| Gerät | IP | DNS-Name | Hersteller | Modell | Notizen |
|-------|----|---------|-----------|---------|---------| 
| **Shelly 1 Lüftung** | 192.168.101.135 | bad-shelly-1-01.iot.[DOMAIN] | Allterco | Shelly 1 | Lüftungssteuerung |
| **Homematic Feuchte** | 192.168.101.136 | bad-hm-humid-01.iot.[DOMAIN] | eQ-3 | HmIP-STH | Luftfeuchtigkeit |
| **Hue Spiegellampe** | 192.168.101.137 | bad-hue-01.iot.[DOMAIN] | Philips | Hue White | Spiegelbeleuchtung |

#### 6.2.8 Mobile Clients (192.168.101.191 - 192.168.101.230)

| Gerät | IP | DNS-Name | Hersteller | Notizen |
|-------|----|---------|-----------|---------| 
| **iPhone Admin** | 192.168.101.200 | mobile-iphone-admin-01.iot.[DOMAIN] | Apple | Home Assistant App |
| **iPad Wohnzimmer** | 192.168.101.201 | mobile-ipad-wz-01.iot.[DOMAIN] | Apple | Dashboard, Sonos |
| **Android Tablet** | 192.168.101.202 | mobile-tablet-android-01.iot.[DOMAIN] | Samsung | Küchen-Dashboard |

---

## 7. Betrieb & Wartung

### 7.1 Wartungshinweise

#### 7.1.1 Backup-Strategie

**Täglich (automatisch):**
- Home Assistant Konfiguration (intern via HA)
- Docker Container Logs (Loki)
- System Metriken (InfluxDB, Prometheus)

**Wöchentlich (automatisch via Cron):**
- Secrets-Backup (verschlüsselt): `0 3 * * 0 /opt/homelab/scripts/backup-secrets.sh`
- Docker Volumes: `0 2 * * 0 docker run --rm -v /var/lib/docker/volumes:/source -v /opt/homelab/backup:/backup alpine tar czf /backup/docker-volumes-$(date +\%Y\%m\%d).tar.gz -C /source .`
- UniFi Controller Backup (manuell kontrollieren)

**Monatlich:**
- GPG-Key Backup: `0 3 1 * * /opt/homelab/scripts/backup-gpg-keys.sh`
- Proxmox Cluster Backup (VMs + Konfiguration)
- Komplette System-Snapshots

#### 7.1.2 Update-Fenster

**Infrastruktur (UniFi, Proxmox, Pi-hole):**
- **Zeitfenster:** Sonntag 02:00-04:00 Uhr
- **Vorbereitung:** Backup der Konfiguration
- **Reihenfolge:** Pi-hole → UniFi → Proxmox
- **Rollback-Plan:** Backup-Wiederherstellung vorbereitet

**Services (Home Assistant, Docker):**
- **Zeitfenster:** Sonntag 04:00-06:00 Uhr
- **Rolling Updates:** Ein Service nach dem anderen
- **Health Checks:** Automatische Verfügbarkeitsprüfung

#### 7.1.3 Monitoring

**Homelab-Services:**
- **Grafana Dashboards:** System-Metriken, Service-Status
- **InfluxDB:** Performance-Daten, Verfügbarkeit
- **Prometheus:** Docker-Container, Hardware-Monitoring
- **Loki:** Zentrales Logging aller Services

**IOT-Geräte:**
- **Home Assistant Device Tracker:** Ping alle 5 Minuten
- **Sensor-Monitoring:** Batteriestatus, Verbindungsqualität
- **Automatisierung:** Benachrichtigung bei Geräte-Ausfällen

### 7.2 Troubleshooting

#### 7.2.1 DNS-Probleme (Pi-hole + Unbound)

**1. Lokale Domain nicht auflösbar:**

```bash
# Pi-hole Status prüfen
docker ps | grep pihole
docker logs $(docker ps -q -f name=pihole) --tail 50

# Unbound Status prüfen
docker logs $(docker ps -q -f name=unbound) --tail 50

# DNS-Auflösung manuell testen
nslookup lab-ha-prod-01.lab.[DOMAIN] 192.168.1.3
dig @192.168.1.3 lab-ha-prod-01.lab.[DOMAIN]

# Pi-hole Query-Log prüfen
# Web-Interface: https://lab-pihole-01.lab.[DOMAIN] → Query Log
```

**2. Unbound nicht erreichbar:**

```bash
# Unbound Container IP prüfen
docker network inspect dns-stack_dns-internal

# Unbound von Pi-hole aus testen
docker exec -it $(docker ps -q -f name=pihole) nslookup google.com 172.20.0.2

# Unbound Konfiguration prüfen
docker exec -it $(docker ps -q -f name=unbound) unbound-checkconf

# Unbound Cache-Statistiken
docker exec -it $(docker ps -q -f name=unbound) unbound-control stats_noreset
```

#### 7.2.2 VLAN-spezifische Probleme

**1. IOT-Geräte nicht erreichbar:**

```bash
# VLAN-Zuordnung prüfen
# UniFi Controller → Clients → VLAN-Status kontrollieren

# DHCP-Lease erneuern (am Gerät)
# Oder: DHCP-Reservation in UniFi erstellen

# Firewall-Regeln überprüfen
# UniFi Controller → Settings → Security → Zone Matrix
# Standard-LAN → IOT-VLAN: Allow/Limited prüfen

# Ping-Test zwischen VLANs
ping 192.168.100.10  # Von Standard-LAN zu IOT
```

**2. Gäste haben keinen Internet-Zugang:**

```bash
# VLAN-Zuordnung prüfen
# UniFi Controller → WiFi → "[WIFI_NAME]-Gast" → VLAN 200 zugewiesen?

# Gateway-Routing für Gäste-VLAN
ip route show table main | grep 192.168.200

# Firewall-Regeln für Internet-Zugang prüfen
# Gäste-VLAN → Internet: Allow in Zone Matrix?

# DNS-Test von Gäste-VLAN
nslookup google.com 192.168.1.3  # Pi-hole sollte antworten

# Gateway-Erreichbarkeit von Gäste-VLAN
ping 192.168.200.1  # Gateway
ping 8.8.8.8       # Internet
```

---

## 8. Anhang

### 8.1 Wichtige URLs nach Setup

Nach erfolgreichem Deployment sind folgende URLs verfügbar:

#### Management-Interfaces
```
https://lab-pihole-01.lab.[DOMAIN]         # Pi-hole Admin (DNS-Management)
https://lab-traefik-01.lab.[DOMAIN]        # Traefik Dashboard (SSL/Routing)
https://lab-portainer-01.lab.[DOMAIN]      # Docker Management
https://lab-unifi-controller-01.lab.[DOMAIN]:8443  # UniFi Controller
https://lab-pve-01.lab.[DOMAIN]:8006       # Proxmox Web-Interface (optional)
https://lab-nas-01.lab.[DOMAIN]            # TrueNAS Management (optional)
```

#### Homelab-Services
```
https://lab-ha-prod-01.lab.[DOMAIN]        # Home Assistant (Smart Home)
https://lab-grafana-01.lab.[DOMAIN]        # Monitoring Dashboard
http://lab-influx-01.lab.[DOMAIN]:8086     # InfluxDB (keine HTTPS)
http://lab-mqtt-01.lab.[DOMAIN]:1883       # MQTT Broker (Port)
```

#### IOT-Geräte (Beispiele)
```
https://uv-hm-ccu-01.iot.[DOMAIN]          # Homematic CCU
https://wz-hue-bridge-01.iot.[DOMAIN]      # Hue Bridge
# Weitere Geräte-IPs siehe Inventar (Kapitel 6)
```

### 8.2 Backup-Checkliste

**Wöchentlich:**
- [ ] Verschlüsselte Secrets-Backup erstellt
- [ ] Docker-Volumes gesichert
- [ ] Home Assistant Backup kontrolliert
- [ ] Pi-hole Konfiguration exportiert
- [ ] UniFi Controller Backup geprüft

**Monatlich:**
- [ ] GPG-Key Backup erstellt
- [ ] Externe Backup-Speicherung aktualisiert (Cloud + USB)
- [ ] Backup-Restore getestet
- [ ] Proxmox/VM Snapshots erstellt
- [ ] Dokumentation aktualisiert

### 8.3 Sicherheits-Checkliste

**Netzwerk-Sicherheit:**
- [ ] VLAN-Segmentierung aktiv
- [ ] Firewall-Regeln minimal und dokumentiert
- [ ] Gäste-Isolation aktiviert
- [ ] WiFi-Passwörter stark und regelmäßig geändert
- [ ] SSH-Keys statt Passwörter verwendet

**Service-Sicherheit:**
- [ ] Alle Services über HTTPS erreichbar
- [ ] Strong Passwörter für alle Admin-Accounts
- [ ] 2FA wo möglich aktiviert
- [ ] Regular Security Updates
- [ ] Log-Monitoring aktiv

**Daten-Sicherheit:**
- [ ] Secrets niemals in Git committed
- [ ] GPG-Verschlüsselung für Backups
- [ ] Master-Passwort sicher verwahrt
- [ ] Backup-Rotation funktioniert
- [ ] Recovery-Plan getestet

### 8.4 Changelog & Roadmap

#### Version 6.0 (aktuell)
- ✅ Vereinheitlichung der beiden Dokumentationen
- ✅ Korrigierte Namens-Konvention (Raum-Gerät-Nummer)
- ✅ Platzhalter für Domain und WiFi-Namen
- ✅ Konsistente DNS-Namen und IP-Zuweisungen
- ✅ Verbesserte Struktur und Lesbarkeit

#### Geplante Verbesserungen (v6.1)
- [ ] Automatisierte Deployment-Scripts
- [ ] Docker-Compose Health-Checks
- [ ] Erweiterte Monitoring-Alerts
- [ ] Integration mit externen Backup-Services
- [ ] Performance-Optimierung für ARM-Hardware

---

**🎯 Die einheitliche Homelab-Dokumentation ist jetzt vollständig konsolidiert!**

Diese Dokumentation bietet eine konsistente und korrigierte Basis für die weitere Entwicklung des Homelab-Setups. Die neue Namens-Konvention (Raum-Gerät-Nummer) und die Verwendung von Platzhaltern ermöglichen eine einfache Anpassung an verschiedene Umgebungen.
