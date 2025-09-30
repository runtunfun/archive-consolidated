# Homelab & IOT Infrastructure - Komplettdokumentation

**Version:** 5.0  
**Erstellt:** Dezember 2024  
**Letzte Aktualisierung:** Dezember 2024

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
Internet (netcup Domain)
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

### 1.4 Technologie-Stack

| Komponente | Technologie | Zweck |
|------------|-------------|-------|
| **Netzwerk** | UniFi | VLAN-Management, WiFi, Firewall |
| **DNS** | Pi-hole + Unbound | Lokale Auflösung, Ad-Blocking, Recursive DNS |
| **Reverse Proxy** | Traefik | HTTPS-Terminierung, Let's Encrypt |
| **Container** | Docker Swarm | Service-Orchestrierung |
| **Smart Home** | Home Assistant | IOT-Integration, Automatisierung |
| **Monitoring** | Grafana + InfluxDB | Metriken, Dashboards |
| **Secrets** | GPG + Git | Sichere Konfigurationsverwaltung |
| **Domain** | netcup | DNS-Provider für Let's Encrypt |

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
- **Standard-LAN:** `[geraetetype]-[nummer].lab.enzmann.online`
- **IOT-VLAN:** `[geraetetype]-[raum]-[nummer].iot.enzmann.online`
- **Gäste-VLAN:** `[geraetetype]-[nummer].guest.enzmann.online`

#### Gerätetypen (Präfixe)

**Homelab & Infrastructure (Standard-LAN):**
- `pve-` : Proxmox VE Hosts
- `vm-` : Virtuelle Maschinen
- `docker-` : Docker Hosts/Swarm Nodes
- `ha-` : Home Assistant Instanzen
- `nas-` : NAS/Storage Systeme
- `unifi-` : UniFi Controller
- `switch-` : Managed Switches
- `ap-` : Access Points

**Smart Home Geräte (IOT-VLAN):**
- `shelly-dimmer-` : Shelly Dimmer
- `shelly-pro1pm-` : Shelly Pro 1PM
- `shelly-1-` : Shelly 1 (Relais)
- `hm-window-` : Homematic Fensterkontakt
- `hm-motion-` : Homematic Bewegungsmelder
- `hm-temp-` : Homematic Temperatursensor
- `hue-` : Philips Hue Geräte
- `sonos-` : Sonos Lautsprecher

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
pve-01.lab.enzmann.online                   → Proxmox Host 1
ha-prod-01.lab.enzmann.online               → Home Assistant Produktiv
traefik-01.lab.enzmann.online               → Traefik Reverse Proxy

# IOT-VLAN (Smart Home)
shelly-dimmer-flur-01.iot.enzmann.online    → Shelly Dimmer im Flur
hue-wz-03.iot.enzmann.online                → Hue Lampe im Wohnzimmer
hm-temp-sz-01.iot.enzmann.online            → Temperatursensor Schlafzimmer
```

### 2.4 UniFi-Konfiguration

#### Standard-LAN Einstellungen
1. **Standard-Netzwerk (Default):**
   - Name: "Standard-LAN"
   - VLAN: Untagged/Default
   - Subnetz: 192.168.1.0/24
   - DHCP: Aktiviert
   - DNS: 192.168.1.3, 192.168.1.4
   - Domain: lab.enzmann.online

2. **WiFi-Netzwerk "Enzian":**
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
   - Domain: iot.enzmann.online

2. **WiFi-Netzwerk "Enzian-IOT":**
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
   - Domain: guest.enzmann.online

2. **WiFi-Netzwerk "Enzian-Gast":**
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
Pi-hole Primary:   192.168.1.3 → pihole-01.lab.enzmann.online
Pi-hole Secondary: 192.168.1.4 → pihole-02.lab.enzmann.online

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
    hostname: traefik-pi-${PI_NUMBER}
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
      
      # Let's Encrypt mit netcup DNS-Challenge
      - "--certificatesresolvers.letsencrypt.acme.dnschallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=netcup"
      - "--certificatesresolvers.letsencrypt.acme.email=admin@enzmann.online"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
      
      # Logging
      - "--log.level=INFO"
      - "--accesslog=true"
    
    environment:
      # netcup API Credentials
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
      # Traefik Dashboard
      - "traefik.enable=true"
      - "traefik.http.routers.dashboard.rule=Host(`traefik-pi-${PI_NUMBER}.lab.enzmann.online`)"
      - "traefik.http.routers.dashboard.service=api@internal"
      - "traefik.http.routers.dashboard.tls.certresolver=letsencrypt"
      - "traefik.http.routers.dashboard.middlewares=auth"
      
      # Basic Auth für Dashboard
      - "traefik.http.middlewares.auth.basicauth.users=admin:$$2y$$10$$..."  # htpasswd generiert
    
    restart: unless-stopped

  unbound:
    image: mvance/unbound-rpi:latest  # ARM-optimiert
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
      VIRTUAL_HOST: 'pihole-${PI_NUMBER}.lab.enzmann.online'
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
      - "traefik.http.routers.pihole.rule=Host(`pihole-${PI_NUMBER}.lab.enzmann.online`)"
      - "traefik.http.routers.pihole.tls.certresolver=letsencrypt"
      - "traefik.http.services.pihole.loadbalancer.server.port=80"
    depends_on:
      - unbound
      - traefik
    restart: unless-stopped

  gravity-sync:
    image: vmstan/gravity-sync:latest
    hostname: gravity-sync-${PI_NUMBER}
    environment:
      GS_REMOTE_HOST: "${REMOTE_PI_IP}"
      GS_REMOTE_USER: "pi"
      GS_AUTO_MODE: "true"
    volumes:
      - pihole_config:/etc/pihole
      - ./gravity-sync:/root/gravity-sync
      - ~/.ssh:/root/.ssh:ro
    depends_on:
      - pihole
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
PIHOLE_PASSWORD=secure-admin-password

# netcup API Credentials (für Let's Encrypt DNS-Challenge)
NETCUP_CUSTOMER_NUMBER=123456
NETCUP_API_KEY=your-api-key
NETCUP_API_PASSWORD=your-api-password
```

**Pi #2:** `/opt/homelab/dns-stack/.env`
```bash
PI_NUMBER=02
PI_IP=192.168.1.4
REMOTE_PI_IP=192.168.1.3
PIHOLE_PASSWORD=secure-admin-password

# netcup API Credentials (identisch auf beiden Pis)
NETCUP_CUSTOMER_NUMBER=123456
NETCUP_API_KEY=your-api-key
NETCUP_API_PASSWORD=your-api-password
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
    name: "lab.enzmann.online"
    forward-addr: 172.20.0.3@53

forward-zone:
    name: "iot.enzmann.online"  
    forward-addr: 172.20.0.3@53

forward-zone:
    name: "guest.enzmann.online"
    forward-addr: 172.20.0.3@53
```

#### 3.1.6 Deployment-Strategie

**Phase 1: Erstes Raspberry Pi**

```bash
# 1. Raspberry Pi OS installieren
# 2. Docker installieren
sudo curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker pi

# 3. Basis-Ordnerstruktur erstellen
sudo mkdir -p /opt/homelab/dns-stack
sudo chown -R pi:pi /opt/homelab

# 4. Konfigurationsdateien erstellen
cd /opt/homelab/dns-stack
# docker-compose.yml, .env, unbound.conf erstellen

# 5. Stack starten
docker-compose up -d

# 6. HTTPS-Zugriff testen
curl -k https://pihole-01.lab.enzmann.online

# 7. Als Primary DNS in UniFi eintragen (192.168.1.3)
```

**Phase 2: Zweites Raspberry Pi (optional für Hochverfügbarkeit)**

```bash
# 1. Konfiguration von Pi #1 kopieren
scp -r pi@192.168.1.3:/opt/homelab/dns-stack/* /opt/homelab/dns-stack/

# 2. Environment für Pi #2 anpassen
# .env editieren: PI_NUMBER=02, IP=192.168.1.4, REMOTE_PI_IP=192.168.1.3

# 3. SSH-Keys für Gravity Sync einrichten
ssh-keygen -t rsa -b 4096 -C "gravity-sync"
ssh-copy-id pi@192.168.1.3

# 4. Stack starten
docker-compose up -d

# 5. Als Secondary DNS in UniFi hinzufügen (192.168.1.4)
```

#### 3.1.7 Pi-hole DNS-Einträge

**Lokale DNS-Einträge (via Pi-hole Web-Interface):**

```bash
# Core Infrastructure
192.168.1.2    unifi-controller-01.lab.enzmann.online
192.168.1.3    pihole-01.lab.enzmann.online
192.168.1.4    pihole-02.lab.enzmann.online

# Homelab Core
192.168.1.21   pve-01.lab.enzmann.online
192.168.1.22   pve-02.lab.enzmann.online
192.168.1.25   nas-01.lab.enzmann.online

# Homelab Services
192.168.1.41   ha-prod-01.lab.enzmann.online
192.168.1.48   traefik-01.lab.enzmann.online
192.168.1.50   portainer-01.lab.enzmann.online
192.168.1.51   grafana-01.lab.enzmann.online

# IOT-Geräte (wichtigste)
192.168.100.10  hm-ccu-uv-01.iot.enzmann.online
192.168.101.1   hue-wz-bridge01.iot.enzmann.online
```

**Wildcard-Domains (via dnsmasq config):**

```bash
# /etc/dnsmasq.d/02-lab-wildcard.conf
address=/lab.enzmann.online/192.168.1.48

# /etc/dnsmasq.d/03-iot-wildcard.conf  
address=/iot.enzmann.online/192.168.1.48

# /etc/dnsmasq.d/04-guest-wildcard.conf
address=/guest.enzmann.online/192.168.1.48
```

### 3.2 HTTPS & Reverse Proxy

#### 3.2.1 Traefik Übersicht

Alle Homelab-Services werden über HTTPS mit echten Let's Encrypt Zertifikaten bereitgestellt:
- **Domain:** enzmann.online (gehostet bei netcup)
- **Reverse Proxy:** Traefik mit automatischer SSL-Terminierung
- **Zertifikate:** Let's Encrypt Wildcard via DNS-Challenge (netcup API)

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
      
      # Let's Encrypt mit netcup DNS-Challenge für Wildcards
      - "--certificatesresolvers.letsencrypt.acme.dnschallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=netcup"
      - "--certificatesresolvers.letsencrypt.acme.email=admin@enzmann.online"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
      
      # Logging
      - "--log.level=INFO"
      - "--accesslog=true"
      
    ports:
      - "80:80"
      - "443:443"
      
    environment:
      # netcup API Credentials
      NETCUP_CUSTOMER_NUMBER: "${NETCUP_CUSTOMER_NUMBER}"
      NETCUP_API_KEY: "${NETCUP_API_KEY}"
      NETCUP_API_PASSWORD: "${NETCUP_API_PASSWORD}"
      
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik_letsencrypt:/letsencrypt
      
    labels:
      # Traefik Dashboard
      - "traefik.enable=true"
      - "traefik.http.routers.dashboard.rule=Host(`traefik-01.lab.enzmann.online`)"
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

**Environment-Datei:** `/opt/homelab/traefik/.env`

```bash
# netcup API Credentials (von netcup Customer Control Panel)
NETCUP_CUSTOMER_NUMBER=123456
NETCUP_API_KEY=abcdefghijklmnopqrstuvwxyz
NETCUP_API_PASSWORD=your-api-password
```

#### 3.2.3 netcup DNS API Setup

**1. API-Zugang aktivieren:**
1. Bei netcup im Customer Control Panel anmelden
2. **Stammdaten → API** aufrufen
3. **API-Key** und **API-Password** generieren
4. **DNS-API** Berechtigung aktivieren

**2. DNS-Struktur bei netcup:**
```
# Wildcard für alle Services (automatisch von Traefik verwaltet)
*.enzmann.online          → DNS-Challenge TXT Records

# Keine manuellen A-Records für lokale Services nötig!
# Traefik erstellt automatisch TXT-Records für Let's Encrypt
```

#### 3.2.4 Service-Integration Beispiele

**Home Assistant:**
```yaml
# /opt/homelab/homeassistant/docker-compose.yml
services:
  homeassistant:
    image: homeassistant/home-assistant:stable
    volumes:
      - ha_config:/config
    networks:
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.homeassistant.rule=Host(`ha-prod-01.lab.enzmann.online`)"
      - "traefik.http.routers.homeassistant.tls.certresolver=letsencrypt"
      - "traefik.http.services.homeassistant.loadbalancer.server.port=8123"

networks:
  traefik:
    external: true
```

**Grafana:**
```yaml
# /opt/homelab/monitoring/docker-compose.yml (Ausschnitt)
services:
  grafana:
    image: grafana/grafana:latest
    environment:
      - GF_SERVER_ROOT_URL=https://grafana-01.lab.enzmann.online
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD}
    networks:
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.grafana.rule=Host(`grafana-01.lab.enzmann.online`)"
      - "traefik.http.routers.grafana.tls.certresolver=letsencrypt"
      - "traefik.http.services.grafana.loadbalancer.server.port=3000"
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

### 4.2 Docker Compose Standards

#### Template-System für Environment-Dateien

**Jeder Service hat:**
- `.env.example` - Versioniert in Git (Template)
- `.env` - Lokal, nicht in Git (echte Secrets)

**Beispiel:** `/opt/homelab/homeassistant/.env.example`
```bash
# Home Assistant Environment Template
HA_VERSION=2024.12
HA_TZ=Europe/Berlin

# Database Configuration
HA_DB_TYPE=postgresql
HA_DB_HOST=postgres-01.lab.enzmann.online
HA_DB_NAME=homeassistant
HA_DB_USER=homeassistant
HA_DB_PASSWORD=CHANGE_ME_TO_SECURE_DB_PASSWORD

# Security
HA_ADMIN_PASSWORD=CHANGE_ME_TO_SECURE_ADMIN_PASSWORD

# Integrations
MQTT_BROKER=mqtt-01.lab.enzmann.online
MQTT_USER=homeassistant
MQTT_PASSWORD=CHANGE_ME_TO_SECURE_MQTT_PASSWORD

# Monitoring
INFLUXDB_HOST=influx-01.lab.enzmann.online
INFLUXDB_TOKEN=CHANGE_ME_TO_SECURE_INFLUX_TOKEN
```

#### Docker Compose Konventionen

**Standard-Labels für alle Services:**
```yaml
labels:
  # Traefik Integration (falls Web-Interface vorhanden)
  - "traefik.enable=true"
  - "traefik.http.routers.${SERVICE_NAME}.rule=Host(`${SERVICE_NAME}-01.lab.enzmann.online`)"
  - "traefik.http.routers.${SERVICE_NAME}.tls.certresolver=letsencrypt"
  - "traefik.http.services.${SERVICE_NAME}.loadbalancer.server.port=${SERVICE_PORT}"
  
  # Service-Metadaten
  - "homelab.service.name=${SERVICE_NAME}"
  - "homelab.service.version=${SERVICE_VERSION}"
  - "homelab.service.category=${CATEGORY}"  # core, monitoring, iot, etc.
```

**Standard-Networks:**
```yaml
networks:
  traefik:
    external: true  # Für Services mit Web-Interface
  homelab-internal:
    external: true  # Für Service-zu-Service Kommunikation
```

### 4.3 Service-Deployment

#### 4.3.1 Home Assistant Stack

**Datei:** `/opt/homelab/homeassistant/docker-compose.yml`

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
      - "8123:8123"  # Direkter Zugriff für IOT-Geräte
    labels:
      # Traefik Labels
      - "traefik.enable=true"
      - "traefik.http.routers.homeassistant.rule=Host(`ha-prod-01.lab.enzmann.online`)"
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

**Environment:** `/opt/homelab/homeassistant/.env.example`
```bash
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

#### 4.3.2 Monitoring Stack

**Datei:** `/opt/homelab/monitoring/docker-compose.yml`

```yaml
version: '3.8'

services:
  grafana:
    image: grafana/grafana:${GRAFANA_VERSION}
    hostname: grafana-01
    environment:
      GF_SERVER_ROOT_URL: "https://grafana-01.lab.enzmann.online"
      GF_SECURITY_ADMIN_PASSWORD: "${GRAFANA_ADMIN_PASSWORD}"
      GF_INSTALL_PLUGINS: "grafana-clock-panel,grafana-simple-json-datasource"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./config/grafana/provisioning:/etc/grafana/provisioning
    networks:
      - traefik
      - homelab-internal
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.grafana.rule=Host(`grafana-01.lab.enzmann.online`)"
      - "traefik.http.routers.grafana.tls.certresolver=letsencrypt"
      - "traefik.http.services.grafana.loadbalancer.server.port=3000"
      - "homelab.service.name=grafana"
      - "homelab.service.category=monitoring"
    deploy:
      placement:
        constraints:
          - node.role == manager

  influxdb:
    image: influxdb:${INFLUXDB_VERSION}
    hostname: influx-01
    environment:
      INFLUXDB_DB: "${INFLUXDB_DATABASE}"
      INFLUXDB_ADMIN_USER: "${INFLUXDB_ADMIN_USER}"
      INFLUXDB_ADMIN_PASSWORD: "${INFLUXDB_ADMIN_PASSWORD}"
    volumes:
      - influxdb_data:/var/lib/influxdb
    networks:
      - homelab-internal
    ports:
      - "8086:8086"
    labels:
      - "homelab.service.name=influxdb"
      - "homelab.service.category=monitoring"
    deploy:
      placement:
        constraints:
          - node.role == manager

  prometheus:
    image: prom/prometheus:${PROMETHEUS_VERSION}
    hostname: prometheus-01
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    volumes:
      - prometheus_data:/prometheus
      - ./config/prometheus:/etc/prometheus
    networks:
      - homelab-internal
    labels:
      - "homelab.service.name=prometheus"
      - "homelab.service.category=monitoring"
    deploy:
      placement:
        constraints:
          - node.role == manager

volumes:
  grafana_data:
  influxdb_data:
  prometheus_data:

networks:
  traefik:
    external: true
  homelab-internal:
    external: true
```

**Environment:** `/opt/homelab/monitoring/.env.example`
```bash
# Monitoring Stack Configuration
GRAFANA_VERSION=latest
INFLUXDB_VERSION=1.8
PROMETHEUS_VERSION=latest

# Grafana
GRAFANA_ADMIN_PASSWORD=CHANGE_ME_TO_SECURE_ADMIN_PASSWORD

# InfluxDB
INFLUXDB_DATABASE=homelab
INFLUXDB_ADMIN_USER=admin
INFLUXDB_ADMIN_PASSWORD=CHANGE_ME_TO_SECURE_INFLUX_PASSWORD

# Prometheus
PROMETHEUS_RETENTION=30d
```

#### 4.3.3 Portainer Management

**Datei:** `/opt/homelab/portainer/docker-compose.yml`

```yaml
version: '3.8'

services:
  portainer:
    image: portainer/portainer-ce:${PORTAINER_VERSION}
    hostname: portainer-01
    command: -H unix:///var/run/docker.sock
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    networks:
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.portainer.rule=Host(`portainer-01.lab.enzmann.online`)"
      - "traefik.http.routers.portainer.tls.certresolver=letsencrypt"
      - "traefik.http.services.portainer.loadbalancer.server.port=9000"
      - "homelab.service.name=portainer"
      - "homelab.service.category=management"
    deploy:
      placement:
        constraints:
          - node.role == manager

volumes:
  portainer_data:

networks:
  traefik:
    external: true
```

**Environment:** `/opt/homelab/portainer/.env.example`
```bash
# Portainer Configuration
PORTAINER_VERSION=latest
PORTAINER_ADMIN_PASSWORD=CHANGE_ME_TO_SECURE_PORTAINER_PASSWORD
```

---

## 5. Sicherheit & Verwaltung

### 5.1 Secrets-Management

#### 5.1.1 Problem & Lösungsansatz

**Problemstellung:**
Sensitive Daten wie API-Keys und Passwörter dürfen **nicht** in Git gespeichert werden, aber die Infrastruktur soll trotzdem reproduzierbar sein.

**Lösungsansatz: Multi-Layer Security**
1. **Template-System:** `.env.example` Dateien in Git (ohne echte Secrets)
2. **Lokale Environment-Dateien:** `.env` Dateien lokal (mit echten Secrets)
3. **GPG-Verschlüsselung:** Sichere Backups der echten Secrets
4. **Git-Schutz:** `.gitignore` verhindert versehentliche Commits

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

#### 5.1.3 Template-System

**Standard-Templates für alle Services:**

```bash
# /opt/homelab/dns-stack/.env.example
PI_NUMBER=01
PI_IP=192.168.1.3
REMOTE_PI_IP=192.168.1.4
PIHOLE_PASSWORD=CHANGE_ME_TO_SECURE_PASSWORD

# netcup API Credentials (von netcup Customer Control Panel)
NETCUP_CUSTOMER_NUMBER=YOUR_CUSTOMER_NUMBER
NETCUP_API_KEY=YOUR_API_KEY  
NETCUP_API_PASSWORD=YOUR_API_PASSWORD

# /opt/homelab/traefik/.env.example
# netcup API Credentials (identisch wie bei Pi-hole)
NETCUP_CUSTOMER_NUMBER=YOUR_CUSTOMER_NUMBER
NETCUP_API_KEY=YOUR_API_KEY
NETCUP_API_PASSWORD=YOUR_API_PASSWORD

# /opt/homelab/homeassistant/.env.example
HA_DB_PASSWORD=CHANGE_ME_TO_SECURE_DB_PASSWORD
HA_ADMIN_PASSWORD=CHANGE_ME_TO_SECURE_ADMIN_PASSWORD
MQTT_PASSWORD=CHANGE_ME_TO_SECURE_MQTT_PASSWORD
```

#### 5.1.4 GPG-basierte Verschlüsselung

**Einmalige GPG-Setup:**

```bash
# GPG Key erstellen (einmalig)
gpg --full-generate-key
# Auswahl: RSA (4096 bit), Gültigkeitsdauer: 2 Jahre
# Name: Homelab Administration
# Email: admin@enzmann.online

# Key-ID ermitteln für Scripts
gpg --list-secret-keys --keyid-format LONG
# Merken: Die 16-stellige Key-ID nach "sec   rsa4096/"
```

**Secrets-Infrastruktur erstellen:**

```bash
# Secrets-Ordner einrichten
mkdir -p /opt/homelab/secrets/{gpg-keys,encrypted-backups}
chmod 700 /opt/homelab/secrets

# Scripts-Ordner für Automatisierung
mkdir -p /opt/homelab/scripts
```

### 5.2 Backup & Recovery

#### 5.2.1 Automatisierte Scripts

**Environment-Setup Script:** `/opt/homelab/scripts/init-environment.sh`

```bash
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

**GPG Key-Backup Script:** `/opt/homelab/scripts/backup-gpg-keys.sh`

```bash
#!/bin/bash

# Konfiguration (anpassen!)
KEY_ID=$(gpg --list-secret-keys --keyid-format LONG | grep "sec" | head -1 | cut -d'/' -f2 | cut -d' ' -f1)
BACKUP_DIR="/opt/homelab/secrets/gpg-keys"
DATE=$(date +%Y%m%d)

echo "🔐 GPG Key Backup wird erstellt..."
echo "Key-ID: $KEY_ID"

# Backup-Ordner erstellen
mkdir -p "$BACKUP_DIR"

# Private Key mit Passwort-Schutz exportieren
gpg --armor --export-secret-keys "$KEY_ID" > "$BACKUP_DIR/private-key-backup.asc"

# Public Key exportieren  
gpg --armor --export "$KEY_ID" > "$BACKUP_DIR/public-key.asc"

# Trust-Database exportieren
gpg --export-ownertrust > "$BACKUP_DIR/ownertrust.txt"

# Revocation Certificate erstellen (falls nicht vorhanden)
if [ ! -f "$BACKUP_DIR/revocation.asc" ]; then
    echo "📋 Erstelle Revocation Certificate..."
    gpg --gen-revoke "$KEY_ID" > "$BACKUP_DIR/revocation.asc"
fi

# Komprimieren und verschlüsseln für externe Aufbewahrung
tar -czf "/tmp/gpg-backup-$DATE.tar.gz" -C "$BACKUP_DIR" .
gpg --cipher-algo AES256 --symmetric \
    --output "/opt/homelab/secrets/encrypted-backups/gpg-backup-$DATE.tar.gz.gpg" \
    "/tmp/gpg-backup-$DATE.tar.gz"

# Temporäre Datei löschen
rm "/tmp/gpg-backup-$DATE.tar.gz"

echo "✅ GPG Backup erstellt:"
echo "   📁 Lokal: $BACKUP_DIR/"
echo "   🔒 Verschlüsselt: /opt/homelab/secrets/encrypted-backups/gpg-backup-$DATE.tar.gz.gpg"
echo ""
echo "🎯 Nächste Schritte:"
echo "   1. Verschlüsselte Datei in Cloud speichern"
echo "   2. Zusätzlich auf USB-Stick kopieren und sicher verwahren"
echo "   3. Master-Passwort separat notieren!"
```

**Secrets-Backup Script:** `/opt/homelab/scripts/backup-secrets.sh`

```bash
#!/bin/bash

BACKUP_DIR="/opt/homelab/secrets/encrypted-backups"
DATE=$(date +%Y%m%d-%H%M)

echo "🔒 Erstelle verschlüsseltes Backup aller Secrets..."

# Alle .env Dateien sammeln
tar -czf "/tmp/secrets-$DATE.tar.gz" \
    --exclude='*.example' \
    --exclude='*.template' \
    $(find /opt/homelab -name ".env" 2>/dev/null)

# Mit GPG verschlüsseln
gpg --cipher-algo AES256 --compress-algo 1 --symmetric \
    --output "$BACKUP_DIR/secrets-$DATE.tar.gz.gpg" \
    "/tmp/secrets-$DATE.tar.gz"

# Unverschlüsselte Datei löschen
rm "/tmp/secrets-$DATE.tar.gz"

echo "✅ Secrets Backup erstellt: $BACKUP_DIR/secrets-$DATE.tar.gz.gpg"
echo "💡 Datei in Cloud und auf USB-Stick speichern!"
```

**Recovery Script:** `/opt/homelab/scripts/restore-gpg-keys.sh`

```bash
#!/bin/bash

BACKUP_DIR="/opt/homelab/secrets/gpg-keys"

echo "🔓 GPG Key Wiederherstellung..."

if [ -f "$BACKUP_DIR/private-key-backup.asc" ]; then
    echo "📥 Importiere private GPG Keys..."
    gpg --import "$BACKUP_DIR/private-key-backup.asc"
    gpg --import "$BACKUP_DIR/public-key.asc"
    
    if [ -f "$BACKUP_DIR/ownertrust.txt" ]; then
        gpg --import-ownertrust "$BACKUP_DIR/ownertrust.txt"
    fi
    
    echo "✅ GPG Keys erfolgreich wiederhergestellt!"
    echo ""
    echo "🧪 Tests:"
    echo "   📋 Liste Keys: gpg --list-secret-keys"
    echo "   🔓 Test Entschlüsselung: echo 'test' | gpg --encrypt -r YOUR_EMAIL | gpg --decrypt"
else
    echo "❌ Keine lokalen Key-Backups gefunden in $BACKUP_DIR"
    echo ""
    echo "🔍 Externe Recovery-Optionen:"
    echo "   1. Verschlüsselte Backup-Datei von Cloud/USB holen"
    echo "   2. Mit Master-Passwort entschlüsseln:"
    echo "      gpg -d gpg-backup-YYYYMMDD.tar.gz.gpg | tar -xz -C $BACKUP_DIR/"
    echo "   3. Dieses Script erneut ausführen"
fi
```

**Alle Scripts ausführbar machen:**

```bash
chmod +x /opt/homelab/scripts/*.sh
```

#### 5.2.2 Backup-Strategien

**Automatisierte Backups (Cron):**

```bash
# Wöchentliches Secrets-Backup
0 3 * * 0 /opt/homelab/scripts/backup-secrets.sh

# Monatliches GPG-Key-Backup  
0 3 1 * * /opt/homelab/scripts/backup-gpg-keys.sh

# Tägliches Docker-Volume-Backup
0 2 * * * docker run --rm -v /var/lib/docker/volumes:/source -v /opt/homelab/backup:/backup alpine tar czf /backup/docker-volumes-$(date +\%Y\%m\%d).tar.gz -C /source .
```

**Externe Aufbewahrung:**

```bash
# Cloud-Storage (Beispiel mit rclone)
rclone copy /opt/homelab/secrets/encrypted-backups/ nextcloud:homelab-backups/

# USB-Stick (manuell)
cp /opt/homelab/secrets/encrypted-backups/* /media/usb-backup/

# Wichtig: Master-Passwort separat und sicher aufbewahren!
```

### 5.3 Git-Integration

#### 5.3.1 Was gehört in Git, was nicht

**✅ Sicher für Git:**
```bash
**/.env.example           # Templates ohne echte Secrets
**/docker-compose.yml     # Service-Definitionen
**/scripts/*.sh          # Automatisierungs-Scripts
**/README.md             # Dokumentation
**/unbound.conf          # DNS-Konfiguration
**/.gitignore            # Git-Schutz
```

**❌ NIEMALS in Git:**
```bash
**/.env                  # Echte Environment-Variablen
**/secrets/gpg-keys/    # Private GPG-Keys
**/*password*           # Passwort-Dateien
**/*key*.pem            # Private Zertifikate
**/backup/*.tar.gz      # Unverschlüsselte Backups
```

#### 5.3.2 Workflow-Beispiele

**Erste Einrichtung:**

```bash
# 1. Repository erstellen/klonen
git clone <your-homelab-repo> /opt/homelab
cd /opt/homelab

# 2. Environment-Setup
./scripts/init-environment.sh

# 3. .env Dateien mit echten Werten befüllen
nano dns-stack/.env
nano traefik/.env
nano homeassistant/.env

# 4. GPG-Key erstellen und Backup
gpg --full-generate-key
./scripts/backup-gpg-keys.sh
./scripts/backup-secrets.sh

# 5. Services starten
cd dns-stack && docker-compose up -d
cd ../traefik && docker-stack deploy -c docker-compose.yml traefik
```

**Täglicher Entwicklungsworkflow:**

```bash
# Änderungen an Infrastruktur
cd /opt/homelab
nano homeassistant/docker-compose.yml

# Nur Templates und Configs committen
git add homeassistant/docker-compose.yml
git add homeassistant/.env.example
git commit -m "Update Home Assistant configuration"
git push

# Secrets sind automatisch durch .gitignore geschützt
```

**Recovery-Szenario:**

```bash
# Neue Hardware einrichten:
# 1. Git Repository klonen
git clone <your-repo> /opt/homelab

# 2. Environment-Setup
cd /opt/homelab
./scripts/init-environment.sh

# 3. Verschlüsselte Backups von Cloud/USB holen
# 4. GPG-Keys wiederherstellen
gpg -d gpg-backup-20241215.tar.gz.gpg | tar -xz -C /opt/homelab/secrets/gpg-keys/
./scripts/restore-gpg-keys.sh

# 5. Secrets wiederherstellen
gpg -d secrets-20241215.tar.gz.gpg | tar -xz -C /

# 6. Services starten
cd dns-stack && docker-compose up -d
```

#### 5.3.3 Sicherheitsrichtlinien

**Master-Passwort Verwaltung:**
- **Niemals digital speichern** (nicht in Passwort-Manager)
- **Physisch notieren** (Papier, Tresor)
- **Backup-Kopie** bei Vertrauensperson
- **Recovery-Test** halbjährlich durchführen

**Key-Rotation:**
- **GPG-Keys** alle 2 Jahre erneuern
- **Service-Passwörter** jährlich ändern
- **API-Keys** bei Verdacht sofort rotieren

**Zugriffskontrolle:**
- **Dateiberechtigungen:** `.env` Dateien 600 (nur Owner)
- **Ordnerberechtigungen:** `/opt/homelab/secrets` 700
- **Git-Historie:** Regelmäßig auf versehentliche Commits prüfen

---

## 6. Geräte-Inventar & Dokumentation

### 6.1 Standard-LAN Inventar

#### 6.1.1 UniFi Infrastructure (192.168.1.2 - 192.168.1.20)

| Gerät | IP | DNS-Name | Öffentlicher Zugang | Notizen |
|-------|----|---------|--------------------|---------|
| **UniFi Controller** | 192.168.1.2 | unifi-controller-01.lab.enzmann.online | - | Controller VM/Hardware |
| **Pi-hole Primary** | 192.168.1.3 | pihole-01.lab.enzmann.online | https://pihole-01.lab.enzmann.online | DNS + Ad-Blocking + Unbound |
| **Pi-hole Secondary** | 192.168.1.4 | pihole-02.lab.enzmann.online | https://pihole-02.lab.enzmann.online | Redundante DNS (optional) |
| **UniFi Switch Main** | 192.168.1.10 | switch-main-01.lab.enzmann.online | - | Hauptswitch Arbeitszimmer |
| **UniFi AP Wohnzimmer** | 192.168.1.11 | ap-wz-01.lab.enzmann.online | - | Access Point Wohnzimmer |
| **UniFi AP Schlafzimmer** | 192.168.1.12 | ap-sz-01.lab.enzmann.online | - | Access Point Schlafzimmer |

#### 6.1.2 Homelab Core (192.168.1.21 - 192.168.1.40)

| Gerät | IP | DNS-Name | Öffentlicher Zugang | Notizen |
|-------|----|---------|--------------------|---------|
| **Proxmox Host 1** | 192.168.1.21 | pve-01.lab.enzmann.online | https://pve-01.lab.enzmann.online:8006 | Hauptserver |
| **Proxmox Host 2** | 192.168.1.22 | pve-02.lab.enzmann.online | https://pve-02.lab.enzmann.online:8006 | Backup/Cluster (optional) |
| **TrueNAS Scale** | 192.168.1.25 | nas-01.lab.enzmann.online | https://nas-01.lab.enzmann.online | Zentraler Storage |

#### 6.1.3 Homelab Services (192.168.1.41 - 192.168.1.99)

| Service | IP | DNS-Name | Öffentlicher Zugang | Kategorie | Notizen |
|---------|----|---------|--------------------|-----------|---------|
| **Home Assistant Prod** | 192.168.1.41 | ha-prod-01.lab.enzmann.online | https://ha-prod-01.lab.enzmann.online | IOT | Produktiv HA Instance |
| **Home Assistant Test** | 192.168.1.42 | ha-test-01.lab.enzmann.online | - | IOT | Test/Development |
| **Docker Swarm Manager** | 192.168.1.45 | docker-01.lab.enzmann.online | - | Core | Swarm Leader |
| **Docker Swarm Worker 1** | 192.168.1.46 | docker-02.lab.enzmann.online | - | Core | Swarm Worker (optional) |
| **Docker Swarm Worker 2** | 192.168.1.47 | docker-03.lab.enzmann.online | - | Core | Swarm Worker (optional) |
| **Traefik Reverse Proxy** | 192.168.1.48 | traefik-01.lab.enzmann.online | https://traefik-01.lab.enzmann.online | Core | SSL-Terminierung |
| **Portainer** | 192.168.1.50 | portainer-01.lab.enzmann.online | https://portainer-01.lab.enzmann.online | Management | Docker Management |
| **Grafana** | 192.168.1.51 | grafana-01.lab.enzmann.online | https://grafana-01.lab.enzmann.online | Monitoring | Dashboard |
| **InfluxDB** | 192.168.1.52 | influx-01.lab.enzmann.online | - | Monitoring | Time Series DB |
| **MQTT Broker** | 192.168.1.55 | mqtt-01.lab.enzmann.online | - | IOT | Mosquitto |
| **Prometheus** | 192.168.1.56 | prometheus-01.lab.enzmann.online | - | Monitoring | Metrics Collection |
| **Node Exporter** | 192.168.1.57 | nodeexp-01.lab.enzmann.online | - | Monitoring | System Metrics |
| **Loki** | 192.168.1.58 | loki-01.lab.enzmann.online | - | Monitoring | Log Aggregation |
| **Jaeger** | 192.168.1.59 | jaeger-01.lab.enzmann.online | - | Monitoring | Distributed Tracing |
| **Reserve** | 192.168.1.60-99 | - | - | - | **40 weitere IPs verfügbar** |

#### 6.1.4 Client Devices (192.168.1.201 - 192.168.1.220)

| Gerät | IP | DNS-Name | Zugriff | Notizen |
|-------|----|---------|---------|---------| 
| **Admin Desktop** | 192.168.1.205 | desktop-admin-01.lab.enzmann.online | Kabelgebunden | Management PC |
| **Admin Laptop** | 192.168.1.206 | laptop-admin-01.lab.enzmann.online | WiFi "Enzian" | Mobile Management |
| **Drucker** | 192.168.1.210 | printer-01.lab.enzmann.online | WiFi "Enzian" | Netzwerkdrucker |
| **Reserve** | 192.168.1.211-220 | - | - | **Weitere Laptops, Geräte** |

### 6.2 IOT-VLAN Inventar

#### 6.2.1 Unterverteilung (192.168.100.1 - 192.168.100.62)

| Gerät | IP | DNS-Name | Hersteller | Notizen |
|-------|----|---------|-----------|---------| 
| **Homematic CCU** | 192.168.100.10 | hm-ccu-uv-01.iot.enzmann.online | eQ-3 | Zentrale Steuerung |
| **UniFi Switch IOT** | 192.168.100.11 | switch-uv-01.iot.enzmann.online | Ubiquiti | Hauptverteiler (optional) |

#### 6.2.2 Flur (192.168.100.65 - 192.168.100.126)

| Gerät | IP | DNS-Name | Hersteller | Modell | Notizen |
|-------|----|---------|-----------|---------|---------| 
| **Shelly 1 Deckenlampe** | 192.168.100.70 | shelly-1-flur-01.iot.enzmann.online | Allterco | Shelly 1 | Hauptlicht |
| **Homematic Bewegungsmelder** | 192.168.100.71 | hm-motion-flur-01.iot.enzmann.online | eQ-3 | HmIP-SMI | Eingang |
| **Homematic Türkontakt** | 192.168.100.72 | hm-door-flur-01.iot.enzmann.online | eQ-3 | HmIP-SWDO | Haustür |

#### 6.2.3 Arbeitszimmer (192.168.100.129 - 192.168.100.190)

| Gerät | IP | DNS-Name | Hersteller | Modell | Notizen |
|-------|----|---------|-----------|---------|---------| 
| **Shelly Dimmer** | 192.168.100.135 | shelly-dimmer-az-01.iot.enzmann.online | Allterco | Shelly Dimmer 2 | Schreibtischlampe |
| **Hue Strip** | 192.168.100.136 | hue-az-01.iot.enzmann.online | Philips | Hue Lightstrip | Monitor-Backlight |
| **Homematic Fenster** | 192.168.100.137 | hm-window-az-01.iot.enzmann.online | eQ-3 | HmIP-SWDO | Fenster Garten |

#### 6.2.4 Schlafzimmer (192.168.100.193 - 192.168.100.254)

| Gerät | IP | DNS-Name | Hersteller | Modell | Notizen |
|-------|----|---------|-----------|---------|---------| 
| **Hue Lampe Links** | 192.168.100.200 | hue-sz-01.iot.enzmann.online | Philips | Hue White and Color | Nachttischlampe |
| **Hue Lampe Rechts** | 192.168.100.201 | hue-sz-02.iot.enzmann.online | Philips | Hue White and Color | Nachttischlampe |
| **Homematic Fensterkontakt** | 192.168.100.202 | hm-window-sz-01.iot.enzmann.online | eQ-3 | HmIP-SWDO | Fenster Straße |
| **Homematic Thermostat** | 192.168.100.203 | hm-thermo-sz-01.iot.enzmann.online | eQ-3 | HmIP-eTRV | Heizkörperthermostat |

#### 6.2.5 Wohnzimmer (192.168.101.1 - 192.168.101.62)

| Gerät | IP | DNS-Name | Hersteller | Modell | Notizen |
|-------|----|---------|-----------|---------|---------| 
| **Hue Bridge** | 192.168.101.1 | hue-wz-bridge01.iot.enzmann.online | Philips | Hue Bridge v2 | Zentrale Bridge |
| **Sonos One** | 192.168.101.10 | sonos-wz-01.iot.enzmann.online | Sonos | Sonos One | Musikwiedergabe |
| **Hue Deckenlampe** | 192.168.101.11 | hue-wz-01.iot.enzmann.online | Philips | Hue White Ambiance | Hauptbeleuchtung |
| **Hue Stehlampe** | 192.168.101.12 | hue-wz-02.iot.enzmann.online | Philips | Hue Go | Ambientelicht |
| **Samsung TV** | 192.168.101.15 | tv-wz-01.iot.enzmann.online | Samsung | QE55Q80A | Smart TV |

#### 6.2.6 Küche (192.168.101.65 - 192.168.101.126)

| Gerät | IP | DNS-Name | Hersteller | Modell | Notizen |
|-------|----|---------|-----------|---------|---------| 
| **Shelly 1PM Dunstabzug** | 192.168.101.70 | shelly-pro1pm-kueche-01.iot.enzmann.online | Allterco | Shelly Pro 1PM | Dunstabzugsteuerung |
| **Hue Unterbauleuchte** | 192.168.101.71 | hue-kueche-01.iot.enzmann.online | Philips | Hue Lightstrip | Arbeitsplatte |
| **Sonos One SL** | 192.168.101.72 | sonos-kueche-01.iot.enzmann.online | Sonos | Sonos One SL | Küchenmusik |
| **Homematic Temp** | 192.168.101.73 | hm-temp-kueche-01.iot.enzmann.online | eQ-3 | HmIP-STH | Raumtemperatur |

#### 6.2.7 Bad (192.168.101.129 - 192.168.101.190)

| Gerät | IP | DNS-Name | Hersteller | Modell | Notizen |
|-------|----|---------|-----------|---------|---------| 
| **Shelly 1 Lüftung** | 192.168.101.135 | shelly-1-bad-01.iot.enzmann.online | Allterco | Shelly 1 | Lüftungssteuerung |
| **Homematic Feuchte** | 192.168.101.136 | hm-humid-bad-01.iot.enzmann.online | eQ-3 | HmIP-STH | Luftfeuchtigkeit |
| **Hue Spiegellampe** | 192.168.101.137 | hue-bad-01.iot.enzmann.online | Philips | Hue White | Spiegelbeleuchtung |

#### 6.2.8 Mobile Clients (192.168.101.191 - 192.168.101.230)

| Gerät | IP | DNS-Name | Hersteller | Notizen |
|-------|----|---------|-----------|---------| 
| **iPhone Admin** | 192.168.101.200 | iphone-admin-01.iot.enzmann.online | Apple | Home Assistant App |
| **iPad Wohnzimmer** | 192.168.101.201 | ipad-wz-01.iot.enzmann.online | Apple | Dashboard, Sonos |
| **Android Tablet** | 192.168.101.202 | tablet-android-01.iot.enzmann.online | Samsung | Küchen-Dashboard |
| **Reserve** | 192.168.101.203-230 | - | - | **Weitere Mobile Geräte** |

### 6.3 Gäste-VLAN Inventar

#### 6.3.1 DHCP-Pool (192.168.200.10 - 192.168.200.250)

| Bereich | Verwendung | Lease-Zeit | Notizen |
|---------|------------|------------|----------| 
| **192.168.200.10-50** | Smartphones | 4 Stunden | Gäste-Handys |
| **192.168.200.51-100** | Laptops | 4 Stunden | Gäste-Notebooks |
| **192.168.200.101-150** | Tablets | 4 Stunden | Gäste-Tablets |
| **192.168.200.151-200** | Smart Devices | 8 Stunden | Gäste-Smart-TVs, etc. |
| **192.168.200.201-250** | Reserve | 4 Stunden | Weitere Gäste-Geräte |

**Zugriffsbeschränkungen:**
- ✅ Internet-Zugang (über Gateway)
- ✅ DNS (zu Pi-hole 192.168.1.3)
- ❌ Standard-LAN (192.168.1.0/24)
- ❌ IOT-VLAN (192.168.100.0/22)
- ❌ Inter-Client-Kommunikation (Client-Isolation)

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

**Externe Aufbewahrung:**
- Cloud-Storage (Nextcloud, Google Drive): Verschlüsselte Backups
- USB-Stick (Tresor): Zusätzliche Kopie der wichtigsten Backups
- Offsite-Backup: Bei Vertrauensperson (quartalsweise)

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
- **Automatisierung:** 
  ```bash
  # Wöchentliche Docker Updates
  0 4 * * 0 cd /opt/homelab/dns-stack && docker-compose pull && docker-compose up -d
  0 4 * * 0 docker stack deploy --prune -c /opt/homelab/traefik/docker-compose.yml traefik
  ```

**IOT-Geräte:**
- **Nach Bedarf, rollierend** (nicht alle gleichzeitig)
- **Firmware-Updates:** Hersteller-spezifisch
- **Kompatibilitätsprüfung:** Mit Home Assistant vor Update

#### 7.1.3 Monitoring

**Homelab-Services:**
- **Grafana Dashboards:** System-Metriken, Service-Status
- **InfluxDB:** Performance-Daten, Verfügbarkeit
- **Prometheus:** Docker-Container, Hardware-Monitoring
- **Loki:** Zentrales Logging aller Services
- **Alerting:** Bei Service-Ausfällen oder Performance-Problemen

**IOT-Geräte:**
- **Home Assistant Device Tracker:** Ping alle 5 Minuten
- **Sensor-Monitoring:** Batteriestatus, Verbindungsqualität
- **Automatisierung:** Benachrichtigung bei Geräte-Ausfällen
- **Trend-Analyse:** Langzeit-Verfügbarkeit, Performance-Trends

**Netzwerk:**
- **UniFi Controller:** Traffic-Statistiken, Client-Verbindungen
- **VLAN-Monitoring:** Inter-VLAN Traffic, Firewall-Logs
- **Bandbreiten-Überwachung:** Upload/Download pro VLAN
- **Sicherheits-Monitoring:** Ungewöhnliche Verbindungen, Failed Logins

### 7.2 Troubleshooting

#### 7.2.1 Homelab-spezifische Probleme

**1. VM nicht erreichbar:**

```bash
# Proxmox Host-Status prüfen
pvesh get /version
pct list  # Container
qm list   # VMs

# VM-Status in Proxmox GUI kontrollieren
# Network Bridge Konfiguration überprüfen
ip link show
brctl show
```

**2. Docker Service nicht verfügbar:**

```bash
# Swarm Status prüfen
docker node ls
docker service ls

# Service-Details analysieren
docker service ps <service-name>
docker service logs <service-name> --tail 50

# Container direkt prüfen
docker ps -a
docker logs <container-id> --tail 50

# Netzwerk-Konnektivität
docker network ls
docker network inspect traefik
```

**3. Home Assistant Verbindungsprobleme zu IOT:**

```bash
# Firewall-Regeln Standard-LAN → IOT prüfen
# UniFi Controller → Settings → Security → Zone Matrix

# mDNS-Reflector Status kontrollieren
# UniFi Controller → Settings → Networks → Advanced → Multicast DNS

# MQTT Broker Erreichbarkeit testen
mosquitto_pub -h mqtt-01.lab.enzmann.online -t test -m "hello"
mosquitto_sub -h mqtt-01.lab.enzmann.online -t test

# Home Assistant Logs
docker logs homeassistant_homeassistant_1 --tail 100
```

#### 7.2.2 HTTPS/Traefik Probleme

**1. Zertifikat nicht erstellt:**

```bash
# Traefik Logs prüfen
docker service logs traefik_traefik --tail 50

# netcup API Credentials testen
curl -X POST https://ccp.netcup.net/run/webservice/servers/endpoint.php \
  -H "Content-Type: application/json" \
  -d '{"action":"login","param":{"customernumber":"123456","apikey":"YOUR_API_KEY","apipassword":"YOUR_API_PASSWORD"}}'

# ACME Challenge prüfen
docker exec -it $(docker ps -q -f name=traefik) cat /letsencrypt/acme.json | jq .
```

**2. Service nicht erreichbar über HTTPS:**

```bash
# DNS Auflösung testen (lokal)
nslookup ha-prod-01.lab.enzmann.online 192.168.1.3
dig ha-prod-01.lab.enzmann.online @192.168.1.3

# Traefik Dashboard prüfen
curl -k https://traefik-01.lab.enzmann.online
# Router und Services Status kontrollieren

# Service Labels überprüfen
docker service inspect homeassistant_homeassistant | jq '.[0].Spec.Labels'

# Port-Mapping testen
curl -v http://192.168.1.41:8123  # Direkter Service-Zugriff
```

**3. Wildcard-Zertifikat Probleme:**

```bash
# DNS Challenge manuell testen
dig TXT _acme-challenge.lab.enzmann.online
dig TXT _acme-challenge.iot.enzmann.online

# netcup DNS API manuell testen
# (DNS-Record erstellen/löschen via API)

# Let's Encrypt Rate Limits prüfen
# https://letsencrypt.org/docs/rate-limits/
```

#### 7.2.3 DNS-Probleme (Pi-hole + Unbound)

**1. Lokale Domain nicht auflösbar:**

```bash
# Pi-hole Status prüfen
docker ps | grep pihole
docker logs $(docker ps -q -f name=pihole) --tail 50

# Unbound Status prüfen
docker logs $(docker ps -q -f name=unbound) --tail 50

# DNS-Auflösung manuell testen
nslookup ha-prod-01.lab.enzmann.online 192.168.1.3
dig @192.168.1.3 ha-prod-01.lab.enzmann.online

# Pi-hole Query-Log prüfen
# Web-Interface: https://pihole-01.lab.enzmann.online → Query Log
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

**3. DNS-Auflösung langsam:**

```bash
# Cache-Hit-Rate prüfen
docker exec -it $(docker ps -q -f name=unbound) unbound-control stats | grep "num.query"

# DNS-Query-Zeit testen
dig @192.168.1.3 google.com +stats
time nslookup google.com 192.168.1.3

# Pi-hole Cache leeren
docker exec -it $(docker ps -q -f name=pihole) pihole restartdns

# Unbound Cache leeren
docker exec -it $(docker ps -q -f name=unbound) unbound-control flush_zone .
```

**4. Wildcard-Domains funktionieren nicht:**

```bash
# dnsmasq Konfiguration prüfen
docker exec -it $(docker ps -q -f name=pihole) cat /etc/dnsmasq.d/02-lab-wildcard.conf

# dnsmasq neu starten
docker exec -it $(docker ps -q -f name=pihole) pihole restartdns

# Unbound Forward-Zonen prüfen
docker exec -it $(docker ps -q -f name=unbound) cat /opt/unbound/etc/unbound/unbound.conf | grep -A2 "forward-zone"

# Wildcard-Test
nslookup test.lab.enzmann.online 192.168.1.3
nslookup test.iot.enzmann.online 192.168.1.3
```

#### 7.2.4 VLAN-spezifische Probleme

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
# UniFi Controller → WiFi → "Enzian-Gast" → VLAN 200 zugewiesen?

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

**3. Gäste können auf lokale Ressourcen zugreifen:**

```bash
# Firewall-Regeln verschärfen
# Gäste-VLAN → Standard-LAN: Block (außer DNS Port 53)
# Gäste-VLAN → IOT-VLAN: Block

# WiFi Gast-Isolation prüfen
# UniFi Controller → WiFi → "Enzian-Gast" → Guest Isolation: Enable

# Client-Isolation testen
ping 192.168.200.X  # Andere Gäste-Clients sollten nicht erreichbar sein

# Zugriff auf Homelab-Services testen (sollte blockiert sein)
curl -m 5 http://192.168.1.48  # Traefik sollte nicht erreichbar sein
```

#### 7.2.5 Performance-Probleme

**1. Netzwerk-Performance:**

```bash
# Switch-Auslastung in UniFi Controller prüfen
# Controller → Insights → Switch Ports

# Bandbreiten-Test zwischen VLANs
iperf3 -s  # Server auf einem VLAN
iperf3 -c <server-ip>  # Client auf anderem VLAN

# QoS-Einstellungen anpassen
# UniFi Controller → Settings → Networks → Advanced → QoS
```

**2. Service-Performance:**

```bash
# Docker Resource-Verbrauch
docker stats
docker system df

# System-Ressourcen
htop
iotop
free -h
df -h

# Service-spezifische Metriken
curl http://influx-01.lab.enzmann.online:8086/health
curl http://grafana-01.lab.enzmann.online:3000/api/health
```

#### 7.2.6 Quick-Fix Kommandos

**Service-Neustarts:**

```bash
# Pi-hole + Unbound
cd /opt/homelab/dns-stack
docker-compose restart

# Traefik
docker service update --force traefik_traefik

# Home Assistant
docker service update --force homeassistant_homeassistant

# Komplettes Stack-Restart
docker stack rm <stack-name>
sleep 30
docker stack deploy -c docker-compose.yml <stack-name>
```

**Netzwerk-Resets:**

```bash
# Docker Networks neu erstellen
docker network rm traefik homelab-internal
docker network create --driver overlay traefik
docker network create --driver overlay homelab-internal

# UniFi Controller Restart
# Controller → Settings → System → Restart

# DHCP-Lease-Renewal erzwingen
# Controller → Clients → Reconnect
```

**DNS-Cache leeren:**

```bash
# Pi-hole
docker exec -it $(docker ps -q -f name=pihole) pihole restartdns

# Unbound
docker exec -it $(docker ps -q -f name=unbound) unbound-control reload

# System DNS-Cache (Ubuntu)
sudo systemctl restart systemd-resolved

# Client DNS-Cache (Windows)
ipconfig /flushdns

# Client DNS-Cache (macOS)
sudo dscacheutil -flushcache
```

---

## 8. Anhang

### 8.1 Schritt-für-Schritt Deployment-Guide

#### Quick Start (Minimum-Setup)

**1. Hardware vorbereiten:**
- 1x Raspberry Pi 4B mit Raspberry Pi OS
- 1x Server/Mini-PC mit Ubuntu Server
- UniFi Gateway + Access Point

**2. Basis-Netzwerk einrichten:**
```bash
# UniFi Controller Setup
# 1. Standard-LAN: 192.168.1.0/24
# 2. IOT-VLAN: 192.168.100.0/22 (VLAN 100)
# 3. WiFi: "Enzian" (Standard-LAN), "Enzian-IOT" (IOT-VLAN)
```

**3. DNS-Server deployen (Raspberry Pi):**
```bash
# Docker installieren
sudo curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker pi

# Homelab-Struktur erstellen
sudo mkdir -p /opt/homelab/dns-stack
sudo chown -R pi:pi /opt/homelab

# Git-Repository klonen oder Dateien erstellen
cd /opt/homelab
git clone <your-repo> . || mkdir -p dns-stack traefik homeassistant

# Environment-Setup
./scripts/init-environment.sh

# DNS-Stack starten
cd dns-stack
docker-compose up -d

# UniFi DNS auf Pi-hole umstellen (192.168.1.3)
```

**4. Docker Swarm einrichten (Server):**
```bash
# Docker installieren
sudo curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Swarm initialisieren
docker swarm init --advertise-addr 192.168.1.45

# Networks erstellen
docker network create --driver overlay traefik
docker network create --driver overlay homelab-internal
```

**5. Traefik deployen:**
```bash
cd /opt/homelab/traefik
# .env mit netcup API-Credentials befüllen
docker stack deploy -c docker-compose.yml traefik
```

**6. Home Assistant deployen:**
```bash
cd /opt/homelab/homeassistant
# .env mit DB-Credentials befüllen
docker stack deploy -c docker-compose.yml homeassistant
```

**7. Monitoring deployen:**
```bash
cd /opt/homelab/monitoring
# .env mit Passwörtern befüllen
docker stack deploy -c docker-compose.yml monitoring
```

**8. Testen:**
```bash
# DNS-Auflösung
nslookup ha-prod-01.lab.enzmann.online 192.168.1.3

# HTTPS-Zugriff
curl -k https://ha-prod-01.lab.enzmann.online
curl -k https://grafana-01.lab.enzmann.online
curl -k https://traefik-01.lab.enzmann.online
```

#### Erweiterte Einrichtung (Hochverfügbarkeit)

**9. Zweiter Raspberry Pi (optional):**
```bash
# Pi #2 Setup identisch zu Pi #1
# Nur .env anpassen: PI_NUMBER=02, IPs tauschen
# Gravity Sync für Pi-hole Synchronisation
```

**10. Proxmox Cluster (optional):**
```bash
# VMs für Docker Swarm Worker erstellen
# Cluster für Hochverfügbarkeit einrichten
```

**11. NAS Integration (optional):**
```bash
# TrueNAS Scale für zentralen Storage
# Docker Volume Mounts auf NFS/SMB
```

### 8.2 Wichtige URLs nach Setup

Nach erfolgreichem Deployment sind folgende URLs verfügbar:

#### Management-Interfaces
```
https://pihole-01.lab.enzmann.online      # Pi-hole Admin (DNS-Management)
https://traefik-01.lab.enzmann.online     # Traefik Dashboard (SSL/Routing)
https://portainer-01.lab.enzmann.online   # Docker Management
https://unifi-controller-01.lab.enzmann.online:8443  # UniFi Controller
https://pve-01.lab.enzmann.online:8006    # Proxmox Web-Interface (optional)
https://nas-01.lab.enzmann.online         # TrueNAS Management (optional)
```

#### Homelab-Services
```
https://ha-prod-01.lab.enzmann.online     # Home Assistant (Smart Home)
https://grafana-01.lab.enzmann.online     # Monitoring Dashboard
http://influx-01.lab.enzmann.online:8086  # InfluxDB (keine HTTPS)
http://mqtt-01.lab.enzmann.online:1883    # MQTT Broker (Port)
```

#### IOT-Geräte (Beispiele)
```
https://hm-ccu-uv-01.iot.enzmann.online   # Homematic CCU
https://hue-wz-bridge01.iot.enzmann.online # Hue Bridge
# Weitere Geräte-IPs siehe Inventar (Kapitel 6)
```

### 8.3 Backup-Checkliste

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

**Halbjährlich:**
- [ ] Komplett-Recovery auf Test-System durchgeführt
- [ ] Passwort-Rotation durchgeführt
- [ ] GPG-Key Gültigkeit geprüft
- [ ] Hardware-Zustand kontrolliert
- [ ] Firmware-Updates geplant

### 8.4 Sicherheits-Checkliste

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

### 8.5 Support & Ressourcen

#### Dokumentation
- **UniFi:** https://help.ui.com/
- **Pi-hole:** https://docs.pi-hole.net/
- **Traefik:** https://doc.traefik.io/traefik/
- **Home Assistant:** https://www.home-assistant.io/docs/
- **Docker Swarm:** https://docs.docker.com/engine/swarm/

#### Community Support
- **UniFi Community:** https://community.ui.com/
- **Pi-hole Discourse:** https://discourse.pi-hole.net/
- **Home Assistant Forum:** https://community.home-assistant.io/
- **Reddit:** r/homelab, r/selfhosted, r/HomeAssistant

#### Emergency Contacts
```
Hardware-Probleme:     [Local IT Support]
Internet-Provider:     [ISP Support Hotline]
Domain-Provider:       netcup.de Support
Backup-Recovery:       [Recovery Service/Person]
```

### 8.6 Changelog & Roadmap

#### Version 5.0 (aktuell)
- ✅ Vollständige Neustrukturierung der Dokumentation
- ✅ Schritt-für-Schritt Deployment-Guide
- ✅ Umfassende Troubleshooting-Sektion
- ✅ Sicherheits- und Backup-Konzepte
- ✅ Erweiterte VLAN-Matrix mit Gäste-Netz

#### Geplante Verbesserungen (v5.1)
- [ ] Automatisierte Deployment-Scripts
- [ ] Docker-Compose Health-Checks
- [ ] Erweiterte Monitoring-Alerts
- [ ] Integration mit externen Backup-Services
- [ ] Performance-Optimierung für ARM-Hardware

#### Zukünftige Features (v6.0)
- [ ] Kubernetes-Migration (optional)
- [ ] VPN-Server Integration
- [ ] Erweiterte IOT-Protokolle (Zigbee, Z-Wave)
- [ ] Multi-Site Deployment
- [ ] Advanced Analytics und Machine Learning

---

**🎯 Das Homelab ist jetzt vollständig dokumentiert und einsatzbereit!**

Dieses Dokument bietet eine komplette Anleitung vom Konzept bis zur Umsetzung einer professionellen Homelab-Infrastruktur mit integrierter Smart Home Verwaltung. Die modulare Struktur ermöglicht es, sowohl mit einem Minimum-Setup zu beginnen als auch eine hochverfügbare Enterprise-ähnliche Umgebung aufzubauen.

Die Kombination aus bewährten Open-Source-Tools, durchdachter Netzwerk-Segmentierung und umfassenden Sicherheitskonzepten schafft eine solide Basis für jahrelangen zuverlässigen Betrieb.

**Bei Fragen oder Verbesserungsvorschlägen:** Dokumentation ist lebendig - Updates und Ergänzungen sind ausdrücklich erwünscht!
