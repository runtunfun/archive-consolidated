# DNS Infrastructure

Die DNS-Infrastruktur bildet das Fundament des Homelabs und stellt lokale Namensauflösung, Ad-Blocking und rekursive DNS-Queries bereit. Diese Implementierung verwendet Pi-hole mit Unbound auf dedizierten Raspberry Pi-Systemen.

## Architektur-Übersicht

### Design-Entscheidungen

Die DNS-Infrastruktur läuft auf dedizierten Raspberry Pi-Systemen statt in VMs aus mehreren kritischen Gründen:

!!! info "Warum dedizierte Hardware?"
    - **Bootstrap-Problem vermeiden**: VMs benötigen DNS zum Starten
    - **Unabhängigkeit**: DNS läuft getrennt vom Proxmox Cluster
    - **Hochverfügbarkeit**: Zwei Raspberry Pis für Redundanz
    - **Kostengünstig**: ~€160 für zwei Pis vs. VM-Ressourcen

### Hardware-Spezifikation

**Pro Raspberry Pi:**

- Raspberry Pi 4B (4GB RAM)
- SSD via USB 3.0 (bessere Performance als SD-Karte)
- Gigabit Ethernet (kein WiFi für kritische Infrastruktur)
- USV/Powerbank (optional für Stromausfälle)

### IP-Adresszuweisung

```bash
Pi-hole Primary:   192.168.1.3 → pihole-01.lab.homelab.example
Pi-hole Secondary: 192.168.1.4 → pihole-02.lab.homelab.example

UniFi DHCP DNS-Server:
Primary DNS:   192.168.1.3
Secondary DNS: 192.168.1.4
Tertiary DNS:  8.8.8.8 (ultimativer Fallback)
```

## Docker Compose Konfiguration

### Hauptkonfiguration

**Datei:** `/opt/homelab/dns-stack/docker-compose.yml`

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
      - "--certificatesresolvers.letsencrypt.acme.email=admin@homelab.example"
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
      - "traefik.http.routers.dashboard.rule=Host(`traefik-pi-${PI_NUMBER}.lab.homelab.example`)"
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
      VIRTUAL_HOST: 'pihole-${PI_NUMBER}.lab.homelab.example'
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
      - "traefik.http.routers.pihole.rule=Host(`pihole-${PI_NUMBER}.lab.homelab.example`)"
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

### Environment-Konfiguration

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

## Unbound Konfiguration

### Rekursive DNS-Auflösung

**Datei:** `/opt/homelab/dns-stack/unbound.conf`

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
    name: "lab.homelab.example"
    forward-addr: 172.20.0.3@53

forward-zone:
    name: "iot.homelab.example"  
    forward-addr: 172.20.0.3@53

forward-zone:
    name: "guest.homelab.example"
    forward-addr: 172.20.0.3@53
```

!!! warning "Forward-Zonen"
    Die Forward-Zonen leiten lokale Domain-Queries zurück an Pi-hole, während externe Domains direkt von Unbound aufgelöst werden.

## Pi-hole DNS-Einträge

### Lokale DNS-Einträge

**Core Infrastructure:**

```bash
192.168.1.2    unifi-controller-01.lab.homelab.example
192.168.1.3    pihole-01.lab.homelab.example
192.168.1.4    pihole-02.lab.homelab.example
```

**Homelab Core:**

```bash
192.168.1.21   pve-01.lab.homelab.example
192.168.1.22   pve-02.lab.homelab.example
192.168.1.25   nas-01.lab.homelab.example
```

**Homelab Services:**

```bash
192.168.1.41   ha-prod-01.lab.homelab.example
192.168.1.48   traefik-01.lab.homelab.example
192.168.1.50   portainer-01.lab.homelab.example
192.168.1.51   grafana-01.lab.homelab.example
```

**IOT-Geräte (wichtigste):**

```bash
192.168.100.10  hm-ccu-uv-01.iot.homelab.example
192.168.101.1   hue-wz-bridge01.iot.homelab.example
```

### Wildcard-Domains

**dnsmasq Konfiguration für Wildcard-Domains:**

```bash
# /etc/dnsmasq.d/02-lab-wildcard.conf
address=/lab.homelab.example/192.168.1.48

# /etc/dnsmasq.d/03-iot-wildcard.conf  
address=/iot.homelab.example/192.168.1.48

# /etc/dnsmasq.d/04-guest-wildcard.conf
address=/guest.homelab.example/192.168.1.48
```

!!! tip "Wildcard-Funktionalität"
    Alle Subdomains werden automatisch an Traefik weitergeleitet, der dann basierend auf Host-Headern die Requests an die entsprechenden Services routet.

## Deployment-Strategie

### Phase 1: Erstes Raspberry Pi

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
curl -k https://pihole-01.lab.homelab.example

# 7. Als Primary DNS in UniFi eintragen (192.168.1.3)
```

### Phase 2: Zweites Raspberry Pi (optional)

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

### Gravity Sync Konfiguration

Gravity Sync synchronisiert Pi-hole-Konfigurationen zwischen beiden Raspberry Pis:

```bash
# SSH-Schlüssel zwischen Pis austauschen
ssh-keygen -t rsa -b 4096
ssh-copy-id pi@<remote-pi-ip>

# Gravity Sync initialisieren
docker exec -it gravity-sync gravity-sync config
docker exec -it gravity-sync gravity-sync auto
```

## Troubleshooting

### DNS-Auflösung testen

```bash
# Pi-hole Status prüfen
docker ps | grep pihole
docker logs $(docker ps -q -f name=pihole) --tail 50

# Unbound Status prüfen
docker logs $(docker ps -q -f name=unbound) --tail 50

# DNS-Auflösung manuell testen
nslookup ha-prod-01.lab.homelab.example 192.168.1.3
dig @192.168.1.3 ha-prod-01.lab.homelab.example
```

### Performance-Optimierung

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

### Häufige Probleme

**Lokale Domain nicht auflösbar:**

```bash
# Pi-hole Query-Log prüfen
# Web-Interface: https://pihole-01.lab.homelab.example → Query Log

# Forward-Zonen in Unbound prüfen
docker exec -it $(docker ps -q -f name=unbound) cat /opt/unbound/etc/unbound/unbound.conf | grep -A2 "forward-zone"
```

**Unbound nicht erreichbar:**

```bash
# Unbound Container IP prüfen
docker network inspect dns-stack_dns-internal

# Unbound von Pi-hole aus testen
docker exec -it $(docker ps -q -f name=pihole) nslookup google.com 172.20.0.2
```

!!! danger "Wichtiger Hinweis"
    Die DNS-Infrastructure ist kritisch für das gesamte Homelab. Stellen Sie sicher, dass mindestens ein Pi-hole immer verfügbar ist.

## Aufwandsschätzung

| Aufgabe | Zeit | Schwierigkeit |
|---------|------|---------------|
| **Hardware-Setup** | 1-2 Stunden | Niedrig |
| **Erste Pi-hole Installation** | 2-3 Stunden | Mittel |
| **Unbound-Integration** | 1-2 Stunden | Mittel |
| **Zweiter Pi + Gravity Sync** | 2-4 Stunden | Hoch |
| **DNS-Einträge & Testing** | 1-2 Stunden | Niedrig |
| **Gesamt (Single Pi)** | **4-7 Stunden** | **Mittel** |
| **Gesamt (Redundant)** | **6-11 Stunden** | **Hoch** |
