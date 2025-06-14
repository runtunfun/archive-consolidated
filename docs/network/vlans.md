# VLAN-Konfiguration und IP-Bereiche

## Übersicht

Die detaillierte IP-Adresszuteilung folgt einem strukturierten Schema, das Skalierbarkeit und einfache Verwaltung ermöglicht. Jedes VLAN hat klar definierte Bereiche für verschiedene Gerätekategorien.

## Standard-LAN (192.168.1.0/24)

Das Standard-LAN beherbergt die Homelab-Infrastruktur und Management-Geräte. Es hat vollständigen Zugriff auf alle Netzwerkressourcen.

### IP-Bereiche Standard-LAN

| Bereich | IP-Bereich | Anzahl IPs | Verwendung |
|---------|------------|------------|------------|
| **Gateway** | 192.168.1.1 | 1 | UniFi Gateway |
| **Core Infrastructure** | 192.168.1.2 - 192.168.1.20 | 19 | UniFi Controller, Pi-hole, Switches, APs |
| **Homelab Core** | 192.168.1.21 - 192.168.1.40 | 20 | Proxmox Hosts, Storage |
| **Homelab Services** | 192.168.1.41 - 192.168.1.99 | 59 | VMs, Docker Container, Services |
| **DHCP Pool** | 192.168.1.100 - 192.168.1.200 | 101 | Automatische Zuweisung |
| **Client Devices** | 192.168.1.201 - 192.168.1.220 | 20 | Desktop, Laptop (Management) |
| **Reserve** | 192.168.1.221 - 192.168.1.254 | 34 | Für zukünftige Erweiterungen |

### Core Infrastructure (192.168.1.2-20)

```yaml
192.168.1.2:    unifi-controller-01.lab.enzmann.online
192.168.1.3:    pihole-01.lab.enzmann.online
192.168.1.4:    pihole-02.lab.enzmann.online
192.168.1.10:   switch-main-01.lab.enzmann.online
192.168.1.11:   ap-wz-01.lab.enzmann.online
192.168.1.12:   ap-sz-01.lab.enzmann.online
# 192.168.1.13-20: Reserve für weitere Infrastructure
```

### Homelab Services (192.168.1.41-99)

```yaml
192.168.1.41:   ha-prod-01.lab.enzmann.online
192.168.1.42:   ha-test-01.lab.enzmann.online
192.168.1.45:   docker-01.lab.enzmann.online
192.168.1.48:   traefik-01.lab.enzmann.online
192.168.1.50:   portainer-01.lab.enzmann.online
192.168.1.51:   grafana-01.lab.enzmann.online
192.168.1.52:   influx-01.lab.enzmann.online
192.168.1.55:   mqtt-01.lab.enzmann.online
# 192.168.1.60-99: Reserve für weitere Services
```

!!! note "Statische vs. DHCP"
    Alle Infrastruktur- und Service-Adressen werden statisch vergeben. Der DHCP-Pool ist ausschließlich für temporäre Clients reserviert.

## IOT-VLAN (192.168.100.0/22)

Das IOT-VLAN nutzt einen /22 Adressraum (1024 IPs) für umfangreiche Smart Home Deployments und mobile Clients.

### Raum-basierte IP-Bereiche

| Raum/Bereich | IP-Bereich | Anzahl IPs | Verwendung |
|--------------|------------|------------|------------|
| **Unterverteilung** | 192.168.100.1 - 192.168.100.62 | 62 | Zentrale Steuergeräte, Homematic CCU |
| **Flur** | 192.168.100.65 - 192.168.100.126 | 62 | Shelly Schalter, Sensoren |
| **Arbeitszimmer** | 192.168.100.129 - 192.168.100.190 | 62 | Shelly Relais, Hue Arbeitsplatz |
| **Schlafzimmer** | 192.168.100.193 - 192.168.100.254 | 62 | Hue Lampen, Klimasensoren |
| **Wohnzimmer** | 192.168.101.1 - 192.168.101.62 | 62 | Hue Lampen, Sonos, TV-Geräte |
| **Küche** | 192.168.101.65 - 192.168.101.126 | 62 | Küchengeräte, Sonos |
| **Bad** | 192.168.101.129 - 192.168.101.190 | 62 | Feuchtigkeitssensoren, Lüftung |
| **Mobile Clients** | 192.168.101.191 - 192.168.101.230 | 40 | Smartphones, Tablets, Smart-TVs |
| **Reserve** | 192.168.101.231 - 192.168.103.254 | 536 | Für zukünftige Erweiterungen |

### IOT-Geräte-Beispiele

#### Unterverteilung (192.168.100.1-62)

```yaml
192.168.100.10:  hm-ccu-uv-01.iot.enzmann.online         # Homematic CCU
192.168.100.11:  switch-uv-01.iot.enzmann.online         # IOT Switch (optional)
```

#### Wohnzimmer (192.168.101.1-62)

```yaml
192.168.101.1:   hue-wz-bridge01.iot.enzmann.online      # Hue Bridge
192.168.101.10:  sonos-wz-01.iot.enzmann.online          # Sonos One
192.168.101.11:  hue-wz-01.iot.enzmann.online            # Hue Deckenlampe
192.168.101.15:  tv-wz-01.iot.enzmann.online             # Samsung Smart TV
```

#### Mobile Clients (192.168.101.191-230)

```yaml
192.168.101.200: iphone-admin-01.iot.enzmann.online      # iPhone Admin
192.168.101.201: ipad-wz-01.iot.enzmann.online          # iPad Wohnzimmer
192.168.101.202: tablet-android-01.iot.enzmann.online   # Android Tablet
```

!!! tip "Raum-basierte Organisation"
    Die Aufteilung nach Räumen erleichtert die Fehlersuche und macht Automatisierungen intuitiver.

## Gäste-VLAN (192.168.200.0/24)

Das Gäste-VLAN bietet isolierten Internet-Zugang ohne Zugriff auf lokale Ressourcen.

### IP-Bereiche Gäste-VLAN

| Bereich | IP-Bereich | Anzahl IPs | Verwendung |
|---------|------------|------------|------------|
| **Gateway** | 192.168.200.1 | 1 | VLAN Gateway |
| **Reserve** | 192.168.200.2 - 192.168.200.9 | 8 | Für spezielle Konfiguration |
| **DHCP Pool** | 192.168.200.10 - 192.168.200.250 | 241 | Gäste-Geräte (automatisch) |
| **Reserve** | 192.168.200.251 - 192.168.200.254 | 4 | Für zukünftige Erweiterungen |

### DHCP-Konfiguration für Gäste

```yaml
Lease-Zeit:       4 Stunden (kurz für bessere Sicherheit)
DNS-Server:       192.168.1.3 (Pi-hole für Ad-Blocking)
Gateway:          192.168.200.1
Domäne:          guest.enzmann.online
Client-Isolation: Aktiviert
```

!!! warning "Gäste-Sicherheit"
    Alle Gäste-Geräte sind vollständig voneinander und vom lokalen Netzwerk isoliert. Nur Internet-Zugang ist erlaubt.

## DHCP-Reservierungen

### Kritische Infrastruktur (statische IPs)

```yaml
# Pi-hole Server (MAC-basierte Reservierung)
aa:bb:cc:dd:ee:01 → 192.168.1.3  (pihole-01)
aa:bb:cc:dd:ee:02 → 192.168.1.4  (pihole-02)

# UniFi Hardware
aa:bb:cc:dd:ee:10 → 192.168.1.10 (switch-main-01)
aa:bb:cc:dd:ee:11 → 192.168.1.11 (ap-wz-01)
aa:bb:cc:dd:ee:12 → 192.168.1.12 (ap-sz-01)
```

### IOT-Geräte (statische IPs empfohlen)

```yaml
# Wichtige Smart Home Hubs
aa:bb:cc:dd:ee:20 → 192.168.100.10 (hm-ccu-uv-01)
aa:bb:cc:dd:ee:21 → 192.168.101.1  (hue-wz-bridge01)

# Shelly Devices (nach Installation konfigurieren)
aa:bb:cc:dd:ee:30 → 192.168.100.70 (shelly-1-flur-01)
aa:bb:cc:dd:ee:31 → 192.168.100.135 (shelly-dimmer-az-01)
```

!!! note "MAC-Adressen-Management"
    Dokumentiere alle MAC-Adressen in einer separaten Datei für einfache DHCP-Reservierungen.

## Subnetz-Rechnung

### IOT-VLAN (/22) Aufschlüsselung

```bash
Netzwerk:     192.168.100.0/22
Subnetz-Maske: 255.255.252.0
Anzahl Hosts: 1022 (1024 - 2 für Netzwerk/Broadcast)
IP-Bereiche:  192.168.100.0 - 192.168.103.255

# Verfügbare Subnetze:
192.168.100.0/24  # 254 Hosts (Unterverteilung, Flur, Arbeitszimmer, Schlafzimmer)
192.168.101.0/24  # 254 Hosts (Wohnzimmer, Küche, Bad, Mobile Clients)
192.168.102.0/24  # 254 Hosts (Reserve für Erweiterungen)
192.168.103.0/24  # 254 Hosts (Reserve für Erweiterungen)
```

### Erweiterungsmöglichkeiten

```yaml
Standard-LAN:   84 freie IPs für weitere Services
IOT-VLAN:      536 freie IPs für Smart Home Expansion
Gäste-VLAN:    245 freie IPs (mehr als ausreichend)
```

!!! tip "Zukunftssicherheit"
    Die großzügige IP-Adresszuteilung ermöglicht erhebliche Erweiterungen ohne Umstrukturierung.

## DNS-Integration

### Pi-hole Konfiguration

```bash
# Lokale DNS-Einträge für alle VLANs
# Standard-LAN
192.168.1.41    ha-prod-01.lab.enzmann.online
192.168.1.48    traefik-01.lab.enzmann.online

# IOT-VLAN
192.168.100.10  hm-ccu-uv-01.iot.enzmann.online
192.168.101.1   hue-wz-bridge01.iot.enzmann.online

# Gäste-VLAN (nur bei Bedarf)
192.168.200.100 guest-device-01.guest.enzmann.online
```

### Wildcard-Domains

```bash
# dnsmasq Wildcard-Konfiguration
address=/lab.enzmann.online/192.168.1.48      # → Traefik
address=/iot.enzmann.online/192.168.1.48      # → Traefik
address=/guest.enzmann.online/192.168.1.48    # → Traefik
```

## Aufwandsschätzung

| Phase | Aufwand | Beschreibung |
|-------|---------|--------------|
| **IP-Planung** | 1-2 Stunden | Detaillierte Adresszuteilung |
| **VLAN-Erstellung** | 30 Minuten | UniFi VLAN-Konfiguration |
| **DHCP-Setup** | 1 Stunde | Bereiche und Reservierungen |
| **DNS-Einträge** | 2-3 Stunden | Pi-hole Konfiguration |
| **Testing** | 1-2 Stunden | Konnektivität aller Bereiche |

**Gesamtaufwand**: 5-8 Stunden für komplette VLAN-Infrastruktur
