# Netzwerk-Grundlagen

## Übersicht

Das Homelab-Netzwerk basiert auf einer professionellen VLAN-Segmentierung mit drei separaten Netzwerkbereichen. Diese Struktur gewährleistet Sicherheit, Performance und einfache Verwaltung der verschiedenen Gerätekategorien.

## Netzwerk-Architektur

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

## VLAN-Übersicht

| VLAN | Name | Subnetz | Gateway | Zweck |
|------|------|---------|---------|-------|
| **Default/1** | Standard-LAN | 192.168.1.0/24 | 192.168.1.1 | Homelab & Management |
| **100** | IOT-VLAN | 192.168.100.0/22 | 192.168.100.1 | Smart Home + Mobile Clients |
| **200** | Gäste-VLAN | 192.168.200.0/24 | 192.168.200.1 | Gast-Zugang |

!!! note "VLAN-Design-Prinzipien"
    - **Standard-LAN**: Vertrauenswürdige Geräte mit vollem Zugriff
    - **IOT-VLAN**: Isolierte Smart Home Geräte mit eingeschränktem Zugriff
    - **Gäste-VLAN**: Vollständig isolierte Gäste-Geräte

## DNS-Konfiguration

Alle VLANs verwenden dieselbe DNS-Infrastruktur für konsistente Namensauflösung:

```yaml
Primary DNS:   192.168.1.3  # Pi-hole #1
Secondary DNS: 192.168.1.4  # Pi-hole #2 (optional)
Tertiary DNS:  8.8.8.8      # Fallback für externes DNS
```

### DNS-Naming-Konvention

#### Domain-Schema

- **Standard-LAN**: `[geraetetype]-[nummer].lab.enzmann.online`
- **IOT-VLAN**: `[geraetetype]-[raum]-[nummer].iot.enzmann.online`
- **Gäste-VLAN**: `[geraetetype]-[nummer].guest.enzmann.online`

#### Gerätetypen (Präfixe)

**Homelab & Infrastructure (Standard-LAN):**

```yaml
pve-      # Proxmox VE Hosts
vm-       # Virtuelle Maschinen
docker-   # Docker Hosts/Swarm Nodes
ha-       # Home Assistant Instanzen
nas-      # NAS/Storage Systeme
unifi-    # UniFi Controller
switch-   # Managed Switches
ap-       # Access Points
```

**Smart Home Geräte (IOT-VLAN):**

```yaml
shelly-dimmer-    # Shelly Dimmer
shelly-pro1pm-    # Shelly Pro 1PM
shelly-1-         # Shelly 1 (Relais)
hm-window-        # Homematic Fensterkontakt
hm-motion-        # Homematic Bewegungsmelder
hm-temp-          # Homematic Temperatursensor
hue-              # Philips Hue Geräte
sonos-            # Sonos Lautsprecher
```

#### Raum-Abkürzungen

```yaml
flur      # Flur
wz        # Wohnzimmer
sz        # Schlafzimmer
az        # Arbeitszimmer
bad       # Bad
kueche    # Küche
uv        # Unterverteilung
```

#### Naming-Beispiele

```bash
# Standard-LAN (Homelab)
pve-01.lab.enzmann.online                   # Proxmox Host 1
ha-prod-01.lab.enzmann.online               # Home Assistant Produktiv
traefik-01.lab.enzmann.online               # Traefik Reverse Proxy

# IOT-VLAN (Smart Home)
shelly-dimmer-flur-01.iot.enzmann.online    # Shelly Dimmer im Flur
hue-wz-03.iot.enzmann.online                # Hue Lampe im Wohnzimmer
hm-temp-sz-01.iot.enzmann.online            # Temperatursensor Schlafzimmer
```

!!! tip "Konsistente Namensgebung"
    Die einheitliche Naming-Konvention erleichtert die Automatisierung und macht Troubleshooting deutlich effizienter.

## Sicherheitskonzept

### Netzwerk-Segmentierung

Die VLAN-Struktur implementiert das Prinzip der geringsten Privilegien:

1. **Standard-LAN**: Vollzugriff auf alle Ressourcen
2. **IOT-VLAN**: Limitierter Zugriff nur auf notwendige Services
3. **Gäste-VLAN**: Internet-Zugang ohne lokale Netzwerk-Zugriffe

### Inter-VLAN-Kommunikation

```yaml
Standard-LAN → IOT-VLAN:    Vollzugriff (Management)
IOT-VLAN → Standard-LAN:    Limitiert (nur DNS, NTP, HA)
Gäste-VLAN → alle VLANs:    Blockiert (nur Internet)
```

!!! warning "Firewall-Konfiguration"
    Die korrekte Konfiguration der Zone Matrix ist kritisch für die Netzwerk-Sicherheit. Fehler können zu Sicherheitslücken oder blockierten Services führen.

## Technologie-Stack

| Komponente | Technologie | Zweck |
|------------|-------------|-------|
| **Gateway** | UniFi Gateway | Routing, Firewall, VPN |
| **Switching** | UniFi Switches | VLAN-Management, PoE |
| **WiFi** | UniFi Access Points | Drahtloser Zugang |
| **DNS** | Pi-hole + Unbound | Lokale Auflösung, Ad-Blocking |
| **Management** | UniFi Controller | Zentrale Konfiguration |

## Hardware-Anforderungen

### Minimum-Setup

```yaml
Gateway:    UniFi Dream Machine (UDM) oder Gateway + separater Controller
Switch:     UniFi Switch Lite 16 PoE oder vergleichbar
Access Points: 1-2x UniFi Access Points (U6 Lite empfohlen)
DNS-Server: 1x Raspberry Pi 4B (4GB RAM)
```

### Empfohlenes Setup

```yaml
Gateway:    UniFi Dream Machine Pro (UDM Pro)
Switches:   UniFi Pro Switches mit VLAN-Support
Access Points: UniFi WiFi 6 Access Points (strategisch verteilt)
DNS-Server: 2x Raspberry Pi 4B für Redundanz
Management: Dedizierte UniFi Controller VM
```

!!! note "Skalierbarkeit"
    Das Design ist von einem einfachen Single-Switch-Setup bis hin zu einem Multi-Site-Deployment skalierbar.

## Aufwandsschätzung

| Phase | Aufwand | Beschreibung |
|-------|---------|--------------|
| **Planung** | 2-4 Stunden | IP-Bereiche definieren, DNS-Schema entwickeln |
| **Hardware-Setup** | 4-8 Stunden | Geräte installieren und grundkonfigurieren |
| **VLAN-Konfiguration** | 2-3 Stunden | VLANs erstellen und zuweisen |
| **DNS-Setup** | 3-5 Stunden | Pi-hole Installation und Konfiguration |
| **Testing** | 2-4 Stunden | Konnektivität und Sicherheit testen |
| **Dokumentation** | 1-2 Stunden | Konfiguration dokumentieren |

**Gesamtaufwand**: 14-26 Stunden (abhängig von Erfahrung und Setup-Komplexität)
