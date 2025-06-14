# Troubleshooting Guide

## Homelab-spezifische Probleme

### VM nicht erreichbar

**Symptome:**
- SSH-Verbindung schlägt fehl
- Web-Interface nicht verfügbar
- Ping-Timeouts

**Diagnose:**
```bash
# Proxmox Host-Status prüfen
pvesh get /version
pct list  # Container auflisten
qm list   # VMs auflisten

# VM-Status detailliert
qm status {vmid}
qm config {vmid}

# Console-Zugriff für direkte Diagnose
qm terminal {vmid}
```

**Netzwerk-Diagnose:**
```bash
# Bridge-Konfiguration prüfen
ip link show
brctl show vmbr0

# VM-Interface Status
qm monitor {vmid}
info network
```

**Lösungsansätze:**
```bash
# VM neu starten
qm stop {vmid}
qm start {vmid}

# Network Interface Reset
qm monitor {vmid}
device_del net0
device_add virtio-net-pci,netdev=net0,mac=XX:XX:XX:XX:XX:XX
```

!!! warning "Kritische VMs"
    Bei kritischen Services (DNS, Gateway) immer erst Backup-System aktivieren bevor Änderungen vorgenommen werden.

### Docker Service nicht verfügbar

**Symptome:**
- Service nicht erreichbar über HTTPS
- Container startet nicht
- Swarm-Probleme

**Diagnose:**
```bash
# Swarm Status prüfen
docker node ls
docker service ls
docker service ps {service-name} --no-trunc

# Service-Details analysieren
docker service inspect {service-name}
docker service logs {service-name} --tail 50

# Container direkt prüfen (falls vorhanden)
docker ps -a
docker logs {container-id} --tail 50 --follow
```

**Netzwerk-Diagnose:**
```bash
# Docker Networks prüfen
docker network ls
docker network inspect traefik
docker network inspect homelab-internal

# Port-Bindings kontrollieren
netstat -tuln | grep :80
netstat -tuln | grep :443
```

**Lösungsansätze:**
```bash
# Service neu deployen
docker service update --force {service-name}

# Komplettes Stack-Restart
docker stack rm {stack-name}
sleep 30
docker stack deploy -c docker-compose.yml {stack-name}

# Node-spezifische Probleme
docker node update --availability drain {node-id}
docker node update --availability active {node-id}
```

### Home Assistant Verbindungsprobleme zu IOT

**Symptome:**
- IOT-Geräte als "unavailable" angezeigt
- Automatisierungen funktionieren nicht
- MQTT-Nachrichten kommen nicht an

**Firewall-Diagnose:**
```bash
# UniFi Zone Matrix prüfen
# Controller → Settings → Security → Zone Matrix
# Standard-LAN → IOT-VLAN: Limited Allow konfiguriert?

# Spezifische Ports testen
telnet 192.168.100.10 80   # HTTP zu IOT-Gerät
telnet 192.168.1.55 1883   # MQTT Broker
```

**mDNS-Diagnose:**
```bash
# mDNS Reflector Status (UniFi Controller)
# Settings → Networks → Advanced → Multicast DNS: Enable

# mDNS Discovery testen
avahi-browse -at | grep "_http._tcp"
```

**MQTT-Diagnose:**
```bash
# MQTT Broker Erreichbarkeit
mosquitto_pub -h mqtt-01.lab.enzmann.online -t test -m "hello"
mosquitto_sub -h mqtt-01.lab.enzmann.online -t test

# Home Assistant MQTT Integration
# Developer Tools → Services → mqtt.publish
```

**Home Assistant Logs:**
```bash
# Container Logs analysieren
docker service logs homeassistant_homeassistant --tail 100 --follow

# Spezifische Integration-Logs
# HA Web-Interface → Settings → System → Logs
# Filter: "homeassistant.components.{integration}"
```

!!! tip "IOT-Gerät Neukonfiguration"
    Bei hartnäckigen Verbindungsproblemen IOT-Gerät komplett aus HA entfernen und neu hinzufügen.

## HTTPS/Traefik Probleme

### Zertifikat nicht erstellt

**Symptome:**
- Browser zeigt "Certificate Error"
- Traefik Dashboard zeigt keine Zertifikate
- Let's Encrypt Rate Limit Errors

**Traefik-Diagnose:**
```bash
# Traefik Logs detailliert
docker service logs traefik_traefik --tail 100 --follow

# ACME Challenge Status
docker exec -it $(docker ps -q -f name=traefik) cat /letsencrypt/acme.json | jq .
```

**netcup API Test:**
```bash
# API Credentials testen
curl -X POST https://ccp.netcup.net/run/webservice/servers/endpoint.php \
  -H "Content-Type: application/json" \
  -d '{
    "action":"login",
    "param":{
      "customernumber":"123456",
      "apikey":"YOUR_API_KEY",
      "apipassword":"YOUR_API_PASSWORD"
    }
  }'
```

**DNS Challenge Verifikation:**
```bash
# TXT Records für ACME Challenge prüfen
dig TXT _acme-challenge.lab.enzmann.online
dig TXT _acme-challenge.iot.enzmann.online @8.8.8.8

# Let's Encrypt Staging für Tests
# In Traefik Config: acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory
```

**Lösungsansätze:**
```bash
# ACME Storage löschen und neu generieren
docker exec -it $(docker ps -q -f name=traefik) rm /letsencrypt/acme.json
docker service update --force traefik_traefik

# Rate Limit Check
# https://letsencrypt.org/docs/rate-limits/
# Max 50 Zertifikate pro Domain pro Woche
```

### Service nicht erreichbar über HTTPS

**Symptome:**
- Traefik Dashboard zeigt Service, aber 404/502 Error
- Direct IP-Zugriff funktioniert, HTTPS nicht

**DNS-Diagnose:**
```bash
# Lokale DNS Auflösung testen
nslookup ha-prod-01.lab.enzmann.online 192.168.1.3
dig ha-prod-01.lab.enzmann.online @192.168.1.3

# Wildcard-Domain testen
nslookup test.lab.enzmann.online 192.168.1.3
```

**Traefik Router-Diagnose:**
```bash
# Traefik Dashboard öffnen
curl -k https://traefik-01.lab.enzmann.online/dashboard/

# Service Labels überprüfen
docker service inspect homeassistant_homeassistant | jq '.[0].Spec.Labels'

# Router-Konfiguration in Dashboard
# HTTP → Routers → Service-Name → Details
```

**Backend-Erreichbarkeit:**
```bash
# Direkter Service-Zugriff (ohne Traefik)
curl -v http://192.168.1.41:8123  # Home Assistant direkt
curl -v http://192.168.1.51:3000  # Grafana direkt

# Docker Service Network
docker service ps homeassistant_homeassistant
docker network inspect traefik | jq '.[0].Containers'
```

**Lösungsansätze:**
```bash
# Service-Labels korrigieren
docker service update \
  --label-add "traefik.http.routers.ha.rule=Host(\`ha-prod-01.lab.enzmann.online\`)" \
  --label-add "traefik.http.services.ha.loadbalancer.server.port=8123" \
  homeassistant_homeassistant

# Traefik Config reload
docker service update --force traefik_traefik
```

## DNS-Probleme (Pi-hole + Unbound)

### Lokale Domain nicht auflösbar

**Symptome:**
- `nslookup ha-prod-01.lab.enzmann.online` schlägt fehl
- Wildcard-Domains funktionieren nicht
- Externe Domains OK, lokale nicht

**Container-Status prüfen:**
```bash
# Pi-hole + Unbound Status
docker ps | grep -E "(pihole|unbound)"
docker logs $(docker ps -q -f name=pihole) --tail 50
docker logs $(docker ps -q -f name=unbound) --tail 50
```

**DNS-Kette testen:**
```bash
# Direkter Pi-hole Test
nslookup ha-prod-01.lab.enzmann.online 192.168.1.3
dig @192.168.1.3 ha-prod-01.lab.enzmann.online

# Unbound-Chain Test (von Pi-hole Container aus)
docker exec -it $(docker ps -q -f name=pihole) nslookup google.com 172.20.0.2
```

**Pi-hole Konfiguration:**
```bash
# Lokale DNS-Einträge prüfen
# Web-Interface: https://pihole-01.lab.enzmann.online
# Local DNS → DNS Records

# Wildcard-Config prüfen
docker exec -it $(docker ps -q -f name=pihole) cat /etc/dnsmasq.d/02-lab-wildcard.conf
```

**Lösungsansätze:**
```bash
# Pi-hole DNS Cache leeren
docker exec -it $(docker ps -q -f name=pihole) pihole restartdns

# Wildcard-Domains neu konfigurieren
docker exec -it $(docker ps -q -f name=pihole) sh -c "echo 'address=/lab.enzmann.online/192.168.1.48' > /etc/dnsmasq.d/02-lab-wildcard.conf"
docker exec -it $(docker ps -q -f name=pihole) pihole restartdns
```

### Unbound nicht erreichbar

**Symptome:**
- Pi-hole kann nicht zu Unbound forwarden
- Recursive DNS funktioniert nicht
- Externe Domain-Auflösung langsam/fehlerhaft

**Container-Netzwerk prüfen:**
```bash
# Docker Network Inspektion
docker network inspect dns-stack_dns-internal

# Unbound Container IP bestätigen
docker inspect $(docker ps -q -f name=unbound) | jq '.[0].NetworkSettings.Networks'
```

**Unbound-Konfiguration:**
```bash
# Config-Syntax prüfen
docker exec -it $(docker ps -q -f name=unbound) unbound-checkconf

# Unbound-Statistiken
docker exec -it $(docker ps -q -f name=unbound) unbound-control stats_noreset
```

**Forward-Zonen testen:**
```bash
# Unbound Forward-Config prüfen
docker exec -it $(docker ps -q -f name=unbound) cat /opt/unbound/etc/unbound/unbound.conf | grep -A2 "forward-zone"

# Pi-hole → Unbound Verbindung testen
docker exec -it $(docker ps -q -f name=pihole) nslookup google.com 172.20.0.2
```

### DNS-Performance Probleme

**Symptome:**
- Langsame Webseiten-Ladezeiten
- Timeouts bei Domain-Auflösung
- Hohe DNS-Latenz

**Performance-Messung:**
```bash
# DNS-Query Zeit messen
dig @192.168.1.3 google.com +stats
time nslookup google.com 192.168.1.3

# Cache-Hit-Rate prüfen
docker exec -it $(docker ps -q -f name=unbound) unbound-control stats | grep "num.query"
```

**Cache-Optimierung:**
```bash
# Pi-hole Cache leeren
docker exec -it $(docker ps -q -f name=pihole) pihole restartdns

# Unbound Cache leeren
docker exec -it $(docker ps -q -f name=unbound) unbound-control flush_zone .

# Unbound Cache-Größe erhöhen (unbound.conf)
# msg-cache-size: 100m
# rrset-cache-size: 200m
```

!!! info "DNS-Performance Tuning"
    Bei >100 IOT-Geräten sollte Unbound Cache-Größe verdoppelt und Prefetch aktiviert werden.

## VLAN-spezifische Probleme

### IOT-Geräte nicht erreichbar

**Symptome:**
- Ping zu IOT-Gerät schlägt fehl
- Home Assistant kann Gerät nicht finden
- Gerät zeigt als "offline"

**VLAN-Zuordnung prüfen:**
```bash
# UniFi Controller → Clients → Gerät suchen
# VLAN-Spalte: Sollte "IOT-VLAN (100)" zeigen

# DHCP-Lease erneuern (am Gerät)
# Oder in UniFi: Client → Reconnect
```

**Firewall-Regeln testen:**
```bash
# Inter-VLAN Ping testen (von Standard-LAN)
ping 192.168.100.10  # Homematic CCU
ping 192.168.101.1   # Hue Bridge

# Port-spezifische Tests
telnet 192.168.100.10 80   # HTTP-Interface
nmap -p 80,443 192.168.100.10
```

**UniFi Firewall-Konfiguration:**
```bash
# Zone Matrix kontrollieren
# Settings → Security → Zone Matrix
# Standard-LAN → IOT-VLAN: Limited Allow?

# Traffic Rules prüfen
# Settings → Security → Traffic Rules
# Regel für Port 8123 (Home Assistant) vorhanden?
```

### Gäste haben keinen Internet-Zugang

**Symptome:**
- Gäste-WiFi verbindet, aber keine Internetseiten
- DNS-Auflösung schlägt fehl
- IP-Adresse wird nicht vergeben

**VLAN-Konfiguration prüfen:**
```bash
# UniFi Controller → Networks → Gäste-VLAN
# VLAN ID: 200, Gateway: 192.168.200.1
# DHCP: Enabled, Range: 192.168.200.10-250

# WiFi-Zuordnung prüfen
# WiFi → "Enzian-Gast" → VLAN: Gäste-VLAN (200)
```

**Routing-Diagnose:**
```bash
# Gateway-Erreichbarkeit von Gäste-VLAN testen
ping 192.168.200.1  # Gateway
ping 8.8.8.8        # Internet

# DNS-Test von Gäste-Gerät
nslookup google.com 192.168.1.3
```

**Firewall-Regeln korrigieren:**
```bash
# Zone Matrix: Gäste → Internet: Allow
# Zone Matrix: Gäste → Standard-LAN: Limited (nur DNS Port 53)
# Zone Matrix: Gäste → IOT-VLAN: Block
```

### Ungewollter Zugriff zwischen VLANs

**Symptome:**
- Gäste können auf Homelab-Services zugreifen
- IOT-Geräte können auf Management-Interfaces
- Client-Isolation funktioniert nicht

**Firewall-Audit:**
```bash
# Zone Matrix komplett überprüfen
# Standard-LAN → IOT: Limited (nur benötigte Ports)
# IOT → Standard-LAN: Limited (nur DNS, NTP, MQTT)
# Gäste → alle anderen: Block (außer Internet)
```

**Traffic-Monitoring:**
```bash
# UniFi Controller → Insights → Traffic Identification
# Ungewöhnlichen Inter-VLAN Traffic identifizieren

# DPI für verdächtigen Traffic
# Settings → Deep Packet Inspection → Enable
```

**Client-Isolation testen:**
```bash
# Von Gäste-Gerät andere Gäste-Geräte pingen
ping 192.168.200.X  # Sollte fehlschlagen

# Home Assistant Web-Interface testen (sollte blockiert sein)
curl -m 5 http://192.168.1.48  # Timeout erwartet
```

## Quick-Fix Kommandos

### Service-Neustarts

```bash
# Pi-hole + Unbound Stack
cd /opt/homelab/dns-stack
docker-compose restart

# Einzelne Services im Swarm
docker service update --force traefik_traefik
docker service update --force homeassistant_homeassistant
docker service update --force monitoring_grafana

# Kompletter Stack-Neustart
docker stack rm homeassistant
sleep 30
docker stack deploy -c docker-compose.yml homeassistant
```

### Netzwerk-Resets

```bash
# Docker Networks neu erstellen
docker network rm traefik homelab-internal
docker network create --driver overlay traefik
docker network create --driver overlay homelab-internal

# UniFi Controller Restart
# Web-Interface: Settings → System → Restart

# DHCP-Lease-Renewal erzwingen
# Controller → Clients → {Client} → Reconnect
```

### Cache-Clearing

```bash
# DNS-Caches leeren
docker exec -it $(docker ps -q -f name=pihole) pihole restartdns
docker exec -it $(docker ps -q -f name=unbound) unbound-control reload

# System DNS-Cache (Ubuntu/Debian)
sudo systemctl restart systemd-resolved

# Browser DNS-Cache
# Chrome: chrome://net-internals/#dns → Clear host cache
# Firefox: about:networking#dns → Clear DNS Cache
```

### Emergency-Recovery

```bash
# Minimal-DNS für Notfall (wenn Pi-hole down)
# UniFi Controller → Networks → Standard-LAN → DNS: 8.8.8.8, 1.1.1.1

# Traefik Bypass (direkte Service-IPs verwenden)
# http://192.168.1.41:8123  # Home Assistant
# http://192.168.1.51:3000  # Grafana

# Docker Swarm Leave/Rejoin (letzter Ausweg)
docker swarm leave --force
docker swarm init --advertise-addr 192.168.1.45
# Alle Services neu deployen
```

!!! danger "Emergency Contacts"
    **Bei kritischen Problemen:**
    
    - Hardware-Support: [Local IT Support]
    - Internet-Provider: [ISP Hotline]
    - Domain-Provider: netcup.de Support
    - Backup-Recovery: [Recovery Service/Person]

!!! success "Troubleshooting Aufwand"
    **Typische Problemlösungszeiten:**
    
    - DNS-Probleme: 15-30 Minuten
    - Docker/Service-Issues: 30-60 Minuten
    - VLAN/Firewall-Probleme: 60-120 Minuten
    - HTTPS/Certificate-Issues: 30-90 Minuten
    
    **Mit diesem Guide: 50% Zeitersparnis durch strukturierte Diagnose**
