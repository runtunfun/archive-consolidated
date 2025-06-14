# Support & Ressourcen

## Offizielle Dokumentation

### Core Infrastructure

#### Docker & Container

| Komponente | Offizielle Docs | Community | GitHub |
|------------|-----------------|-----------|---------|
| **Docker Swarm** | [docs.docker.com/engine/swarm](https://docs.docker.com/engine/swarm/) | [Docker Community](https://www.docker.com/community/) | [moby/moby](https://github.com/moby/moby) |
| **Docker Compose** | [docs.docker.com/compose](https://docs.docker.com/compose/) | [Docker Forums](https://forums.docker.com/) | [docker/compose](https://github.com/docker/compose) |
| **Portainer** | [docs.portainer.io](https://docs.portainer.io/) | [Portainer Community](https://www.portainer.io/community/) | [portainer/portainer](https://github.com/portainer/portainer) |

#### DNS & Networking

| Service | Dokumentation | Support-Forum | Repository |
|---------|---------------|---------------|------------|
| **Pi-hole** | [docs.pi-hole.net](https://docs.pi-hole.net/) | [Pi-hole Discourse](https://discourse.pi-hole.net/) | [pi-hole/pi-hole](https://github.com/pi-hole/pi-hole) |
| **Unbound** | [unbound.docs.nlnetlabs.nl](https://unbound.docs.nlnetlabs.nl/) | [NLnet Labs](https://www.nlnetlabs.nl/contact/) | [NLnetLabs/unbound](https://github.com/NLnetLabs/unbound) |
| **Traefik** | [doc.traefik.io/traefik](https://doc.traefik.io/traefik/) | [Traefik Community](https://community.traefik.io/) | [traefik/traefik](https://github.com/traefik/traefik) |

!!! tip "Versionsspezifische Docs"
    Verwende immer die Dokumentation für deine spezifische Version. Links führen zur aktuellen Stable-Version.

#### UniFi Ecosystem

| Produkt | Dokumentation | Support | Community |
|---------|---------------|---------|-----------|
| **UniFi Controller** | [help.ui.com](https://help.ui.com/) | [UI Support](https://help.ui.com/contact) | [UI Community](https://community.ui.com/) |
| **UniFi Network** | [help.ui.com/unifi-network](https://help.ui.com/categories/unifi-network) | Ticket-System | [r/Ubiquiti](https://reddit.com/r/Ubiquiti) |
| **UniFi OS** | [help.ui.com/unifi-os](https://help.ui.com/categories/unifi-os) | Telefon-Support | [UI Forums](https://community.ui.com/unifi-os) |

### Smart Home & IOT

#### Home Assistant

| Bereich | Ressource | URL | Bemerkung |
|---------|-----------|-----|-----------|
| **Hauptdokumentation** | Official Docs | [home-assistant.io/docs](https://www.home-assistant.io/docs/) | Umfassende Dokumentation |
| **Installation** | Installation Guide | [home-assistant.io/installation](https://www.home-assistant.io/installation/) | Docker-spezifisch |
| **Integrationen** | Integrations | [home-assistant.io/integrations](https://www.home-assistant.io/integrations/) | 3000+ Integrationen |
| **Community** | HA Community | [community.home-assistant.io](https://community.home-assistant.io/) | Aktive Community |
| **Discord** | HA Discord | [discord.gg/home-assistant](https://discord.gg/home-assistant) | Real-time Chat |

#### Device-Spezifische Ressourcen

| Hersteller | Produkt | Dokumentation | HA-Integration |
|------------|---------|---------------|----------------|
| **Allterco** | Shelly Devices | [shelly-api-docs.shelly.cloud](https://shelly-api-docs.shelly.cloud/) | [Shelly Integration](https://www.home-assistant.io/integrations/shelly/) |
| **eQ-3** | Homematic | [homematic-ip.com](https://www.homematic-ip.com/en/support) | [HomematicIP](https://www.home-assistant.io/integrations/homematicip_cloud/) |
| **Philips** | Hue | [developers.meethue.com](https://developers.meethue.com/) | [Philips Hue](https://www.home-assistant.io/integrations/hue/) |
| **Sonos** | Sonos Speakers | [developer.sonos.com](https://developer.sonos.com/) | [Sonos](https://www.home-assistant.io/integrations/sonos/) |

!!! info "Integration-Updates"
    Home Assistant Integrationen werden regelmäßig aktualisiert. Prüfe Release Notes bei Updates.

### Monitoring & Observability

#### Grafana Stack

| Tool | Dokumentation | Tutorials | Community |
|------|---------------|-----------|-----------|
| **Grafana** | [grafana.com/docs](https://grafana.com/docs/) | [Grafana Tutorials](https://grafana.com/tutorials/) | [Grafana Community](https://community.grafana.com/) |
| **Prometheus** | [prometheus.io/docs](https://prometheus.io/docs/) | [Prometheus Tutorials](https://prometheus.io/docs/tutorials/) | [CNCF Slack](https://slack.cncf.io/) |
| **InfluxDB** | [docs.influxdata.com](https://docs.influxdata.com/) | [InfluxDB University](https://university.influxdata.com/) | [InfluxDB Community](https://community.influxdata.com/) |
| **Loki** | [grafana.com/docs/loki](https://grafana.com/docs/loki/) | [Loki Tutorials](https://grafana.com/docs/loki/latest/tutorials/) | [Grafana Slack](https://grafana.slack.com/) |

#### Alert Management

```yaml
# Beispiel Alertmanager-Konfiguration
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@enzmann.online'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://127.0.0.1:5001/'
```

## Community Support

### Deutsche Communities

#### Reddit Communities

| Subreddit | Fokus | Sprache | Aktivität |
|-----------|-------|---------|-----------|
| **r/de_EDV** | [reddit.com/r/de_EDV](https://reddit.com/r/de_EDV) | IT-Allgemein | Deutsch | Sehr aktiv |
| **r/homelab** | [reddit.com/r/homelab](https://reddit.com/r/homelab) | Homelab-Setup | Englisch | Sehr aktiv |
| **r/selfhosted** | [reddit.com/r/selfhosted](https://reddit.com/r/selfhosted) | Self-Hosting | Englisch | Sehr aktiv |
| **r/HomeAssistant** | [reddit.com/r/HomeAssistant](https://reddit.com/r/HomeAssistant) | Smart Home | Englisch | Sehr aktiv |
| **r/smarthome** | [reddit.com/r/smarthome](https://reddit.com/r/smarthome) | Smart Home | Mixed | Aktiv |

#### Discord-Server

| Server | Fokus | Invite | Sprache |
|--------|-------|--------|---------|
| **Homelab DE** | Deutsche Homelab-Community | [discord.gg/homelab-de](https://discord.gg/homelab-de) | Deutsch |
| **Self-Hosted** | Self-Hosting Services | [discord.gg/self-hosted](https://discord.gg/self-hosted) | Englisch |
| **Home Assistant** | HA-spezifischer Support | [discord.gg/home-assistant](https://discord.gg/home-assistant) | Englisch |

!!! warning "Community-Regeln"
    Beachte die spezifischen Regeln jeder Community. Verwende Suchfunktionen vor dem Posten.

### YouTube-Kanäle (Deutsch)

| Kanal | Fokus | Subscriber | Qualität |
|-------|-------|------------|----------|
| **Technik Tim** | Smart Home Tutorials | 500K+ | Sehr gut |
| **SmartHome Rookie** | Einsteiger-Tutorials | 100K+ | Gut |
| **ioBroker** | ioBroker-spezifisch | 50K+ | Spezialisiert |

### YouTube-Kanäle (Englisch)

| Kanal | Fokus | Besonderheit |
|-------|-------|--------------|
| **NetworkChuck** | Networking & Homelab | Unterhaltsam, anfängerfreundlich |
| **Craft Computing** | Homelab Hardware | Hardware-Reviews, Builds |
| **Techno Tim** | Homelab Software | Docker, Kubernetes Tutorials |
| **Lawrence Systems** | Business IT/Homelab | Professioneller Ansatz |

## Troubleshooting-Ressourcen

### Allgemeine Debugging-Tools

#### Netzwerk-Diagnose

```bash
# Grundlegende Netzwerk-Tests
ping 8.8.8.8                    # Internet-Konnektivität
nslookup google.com 192.168.1.3 # DNS-Auflösung
traceroute 8.8.8.8              # Routing-Pfad
arp -a                          # ARP-Tabelle

# UniFi-spezifische Tools
# Controller → Insights → Deep Packet Inspection
# Controller → Events → Anomalies
```

#### Docker-Debugging

```bash
# Container-Status
docker ps -a
docker stats --no-stream

# Service-Logs
docker service logs <service-name> --tail 50 --follow

# Container-Zugriff
docker exec -it <container-id> /bin/bash

# Netzwerk-Analyse
docker network ls
docker network inspect <network-name>

# Volume-Management
docker volume ls
docker volume inspect <volume-name>
```

#### System-Monitoring

```bash
# Ressourcen-Übersicht
htop
iotop
free -h
df -h

# Prozess-Analyse
ps aux | grep <service>
netstat -tulpn | grep <port>
ss -tulpn | grep <port>

# Log-Analyse
journalctl -u docker.service --since today
tail -f /var/log/syslog
```

### Service-Spezifische Troubleshooting

#### Pi-hole Debug

```bash
# Pi-hole Diagnostic
pihole -d

# Query-Log in Echtzeit
tail -f /var/log/pihole.log

# DNS-Auflösung testen
dig @192.168.1.3 example.com +short
nslookup example.com 192.168.1.3

# Gravity-Database prüfen
sqlite3 /etc/pihole/gravity.db ".tables"
```

#### Home Assistant Debug

```bash
# HA-Logs
docker logs homeassistant --tail 100 --follow

# Konfiguration validieren
docker exec homeassistant ha config check

# Integration-spezifische Logs
# Web-Interface → Settings → System → Logs

# Database-Probleme
# Settings → System → Storage → Database
```

#### Traefik Debug

```bash
# Traefik-Dashboard
curl -k https://traefik-01.lab.enzmann.online/api/rawdata

# Service-Discovery
docker service ls --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}"

# Let's Encrypt Logs
docker logs traefik_traefik | grep "acme"

# Certificate-Status
openssl s_client -connect <service>.lab.enzmann.online:443 -servername <service>.lab.enzmann.online
```

### Häufige Probleme & Lösungen

#### DNS-Probleme

!!! bug "Problem: Lokale Domains nicht auflösbar"
    **Ursache:** Pi-hole/Unbound Konfigurationsfehler
    
    **Lösung:**
    ```bash
    # Pi-hole DNS-Einträge prüfen
    # Web-Interface → Local DNS → DNS Records
    
    # Unbound Forward-Zonen prüfen
    docker exec unbound cat /opt/unbound/etc/unbound/unbound.conf
    
    # DNS-Cache leeren
    docker restart dns-stack_pihole_1
    docker restart dns-stack_unbound_1
    ```

#### HTTPS/Certificate-Probleme

!!! bug "Problem: SSL-Zertifikat nicht erstellt"
    **Ursache:** netcup API-Konfiguration oder DNS-Challenge Fehler
    
    **Lösung:**
    ```bash
    # netcup API-Credentials prüfen
    curl -X POST https://ccp.netcup.net/run/webservice/servers/endpoint.php \
      -H "Content-Type: application/json" \
      -d '{"action":"login","param":{"customernumber":"123456","apikey":"YOUR_API_KEY","apipassword":"YOUR_API_PASSWORD"}}'
    
    # Traefik ACME-Logs
    docker logs traefik_traefik | grep "challenge"
    
    # DNS-Challenge manuell testen
    dig TXT _acme-challenge.lab.enzmann.online
    ```

#### Docker Swarm-Probleme

!!! bug "Problem: Service nicht erreichbar"
    **Ursache:** Netzwerk-Konfiguration oder Service-Discovery Fehler
    
    **Lösung:**
    ```bash
    # Service-Status prüfen
    docker service ps <service-name>
    docker service inspect <service-name>
    
    # Netzwerk-Konnektivität
    docker exec <container-id> ping <target-service>
    
    # Service neu deployen
    docker service update --force <service-name>
    ```

## Notfall-Kontakte

### Hardware-Support

#### Homelab-Hardware

| Kategorie | Kontakt | Verfügbarkeit | Bemerkung |
|-----------|---------|---------------|-----------|
| **Raspberry Pi** | [rpi.org/support](https://rpi.org/support) | 24/7 | Community-Support |
| **UniFi Hardware** | [help.ui.com/contact](https://help.ui.com/contact) | Werktags 9-17 | Telefon + Ticket |
| **Proxmox Support** | [proxmox.com/support](https://proxmox.com/support) | Enterprise only | Kostenpflichtig |

#### Internet & Domain

| Service | Provider | Support-Hotline | Notfall |
|---------|----------|-----------------|---------|
| **Internet** | [Ihr ISP] | [ISP-Hotline] | 24/7 |
| **Domain/DNS** | netcup.de | +49 2632 987 123 | Werktags |
| **DynDNS** | [DynDNS-Provider] | [Provider-Support] | Varies |

!!! danger "Notfall-Informationen"
    Halte diese Informationen auch offline verfügbar (ausgedruckt oder auf separatem Gerät).

### Emergency Recovery

#### Kritische Ausfälle

**DNS komplett ausgefallen:**
```bash
# Temporärer Fix - manueller DNS
# Auf Router/Gateway:
# DNS Server 1: 8.8.8.8
# DNS Server 2: 1.1.1.1

# Schneller Pi-hole Restore
docker-compose -f /opt/homelab/dns-stack/docker-compose.yml up -d
```

**Kompletter Homelab-Ausfall:**
```bash
# Recovery-Prioritäten:
# 1. Internet/Netzwerk wiederherstellen
# 2. DNS-Services (Pi-hole)
# 3. Core-Services (Traefik, Home Assistant)
# 4. Monitoring & Nice-to-have

# Minimale Wiederherstellung
cd /opt/homelab/dns-stack && docker-compose up -d
cd /opt/homelab/traefik && docker stack deploy -c docker-compose.yml traefik
cd /opt/homelab/homeassistant && docker stack deploy -c docker-compose.yml homeassistant
```

**Backup-Recovery benötigt:**
```bash
# GPG-Keys wiederherstellen
./scripts/restore-gpg-keys.sh

# Secrets entschlüsseln
gpg -d /path/to/backup/secrets-backup.tar.gz.gpg | tar -xz -C /

# Services neu starten
./scripts/health-check.sh
```

## Weiterführende Ressourcen

### Bücher & E-Books

#### Homelab & Self-Hosting

| Titel | Autor | Verlag | Bewertung |
|-------|-------|--------|-----------|
| **"The DevOps Handbook"** | Gene Kim | IT Revolution | ⭐⭐⭐⭐⭐ |
| **"Docker Deep Dive"** | Nigel Poulton | Self-Published | ⭐⭐⭐⭐ |
| **"Kubernetes Up & Running"** | Kelsey Hightower | O'Reilly | ⭐⭐⭐⭐⭐ |

#### Netzwerk & Sicherheit

| Titel | Autor | Schwerpunkt |
|-------|-------|-------------|
| **"Network Security Assessment"** | Chris McNab | Security Testing |
| **"TCP/IP Illustrated"** | W. Richard Stevens | Netzwerk-Grundlagen |
| **"Practical Packet Analysis"** | Chris Sanders | Wireshark/Troubleshooting |

### Online-Kurse

#### Udemy-Kurse (Deutsch)

| Kurs | Instructor | Dauer | Preis |
|------|-----------|-------|-------|
| **"Docker Mastery"** | Bret Fisher | 20h | €89 |
| **"Home Assistant Komplettkurs"** | Smart Home Akademie | 15h | €69 |
| **"Netzwerk-Administration"** | IT-Akademie | 25h | €149 |

#### YouTube-Playlists

| Playlist | Kanal | Fokus | Dauer |
|----------|-------|-------|-------|
| **"Homelab Basics"** | NetworkChuck | Grundlagen | 10h |
| **"Docker für Anfänger"** | Technik Tim | Docker DE | 8h |
| **"Home Assistant Advanced"** | DrZzs | HA Advanced | 15h |

### Tools & Software

#### Kostenlose Tools

| Tool | Zweck | Plattform | Download |
|------|-------|-----------|----------|
| **Putty** | SSH-Client | Windows | [putty.org](https://putty.org/) |
| **WinSCP** | SCP/SFTP-Client | Windows | [winscp.net](https://winscp.net/) |
| **Visual Studio Code** | Editor/IDE | Multi | [code.visualstudio.com](https://code.visualstudio.com/) |
| **Wireshark** | Netzwerk-Analyse | Multi | [wireshark.org](https://wireshark.org/) |

#### Browser-Extensions

| Extension | Browser | Zweck |
|-----------|---------|-------|
| **JSON Formatter** | Chrome/Firefox | API-Debug |
| **Wappalyzer** | Chrome/Firefox | Technology Detection |
| **User-Agent Switcher** | Chrome/Firefox | Testing |

### Zertifizierungen

!!! tip "Karriere-Entwicklung"
    Diese Zertifizierungen können das Homelab-Wissen professionell validieren.

#### Docker & Container

| Zertifizierung | Anbieter | Schwierigkeit | Kosten |
|----------------|----------|---------------|--------|
| **Docker Certified Associate** | Docker Inc. | Mittel | $195 |
| **Certified Kubernetes Administrator** | CNCF | Schwer | $375 |

#### Netzwerk & Security

| Zertifizierung | Anbieter | Fokus | Kosten |
|----------------|----------|-------|--------|
| **CompTIA Network+** | CompTIA | Netzwerk-Grundlagen | $350 |
| **CISSP** | (ISC)² | Security-Management | $749 |

### Changelog & Roadmap

#### Dokumentation Updates

!!! info "Version 5.0 (Aktuell)"
    - ✅ Vollständige Neustrukturierung der Dokumentation
    - ✅ Schritt-für-Schritt Deployment-Guide
    - ✅ Umfassende Troubleshooting-Sektion
    - ✅ Sicherheits- und Backup-Konzepte
    - ✅ Erweiterte VLAN-Matrix mit Gäste-Netz

#### Geplante Verbesserungen (v5.1)

- [ ] **Automatisierte Deployment-Scripts**
    - Ansible-Playbooks für komplette Einrichtung
    - Infrastructure as Code (IaC) Templates
    - Zero-Touch-Deployment

- [ ] **Erweiterte Health-Checks**
    - Automatisierte Service-Validierung
    - Performance-Regression-Tests
    - SLA-Monitoring mit Alerts

- [ ] **Backup-Automation**
    - Automatisierte Cloud-Synchronisation
    - Backup-Verification-Tests
    - Disaster-Recovery-Automation

- [ ] **Security-Improvements**
    - Vulnerability-Scanning-Integration
    - Security-Hardening-Scripts
    - Compliance-Reporting

#### Zukünftige Features (v6.0)

- [ ] **Kubernetes-Migration** (Optional)
    - k3s-Cluster für Container-Orchestrierung
    - Helm-Charts für Service-Deployment
    - Advanced Service-Mesh (Istio/Linkerd)

- [ ] **Advanced Networking**
    - VPN-Server Integration (Wireguard)
    - Advanced Firewall-Rules (pfSense)
    - Network-Automation (NAPALM)

- [ ] **Multi-Site Deployment**
    - Site-to-Site VPN
    - Distributed Monitoring
    - Disaster-Recovery-Sites

- [ ] **AI/ML Integration**
    - Predictive Monitoring
    - Automated Optimization
    - Anomaly Detection

### Support-Matrix

#### Prioritäten bei Support-Anfragen

| Kategorie | Response-Zeit | Escalation | Channels |
|-----------|---------------|------------|----------|
| **Critical** | < 1 Stunde | Sofortige Hardware-Beschaffung | Telefon, SMS |
| **High** | < 4 Stunden | Hardware-Bestellung | Email, Ticket |
| **Medium** | < 24 Stunden | Community-Support | Forum, Discord |
| **Low** | < 72 Stunden | Dokumentation-Update | GitHub Issues |

!!! success "Support-System etabliert"
    Mit diesen Ressourcen steht umfassender Support für alle Aspekte des Homelabs zur Verfügung.

**Aufwand für Support-Setup:** ~2 Stunden initial, dann nach Bedarf
