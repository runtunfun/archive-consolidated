# UniFi-Konfiguration

## Übersicht

Die UniFi-Konfiguration bildet das Herzstück der Netzwerk-Infrastruktur. Diese Anleitung führt durch die komplette Einrichtung von VLANs, WiFi-Netzwerken und DHCP-Servern im UniFi Controller.

## UniFi Controller Setup

### Grundlegende Einstellungen

Nach der ersten Einrichtung des UniFi Controllers sind folgende Basis-Konfigurationen vorzunehmen:

```yaml
Controller-URL:    https://unifi-controller-01.lab.enzmann.online:8443
Admin-Account:     admin (starkes Passwort verwenden)
Standort-Name:     Homelab
Zeitzone:         Europe/Berlin
Update-Kanal:     Stable (für Produktionsumgebung)
```

!!! warning "Controller-Sicherheit"
    Verwende immer starke Passwörter und aktiviere 2FA für den UniFi Controller. Der Controller hat vollständigen Zugriff auf die Netzwerk-Infrastruktur.

### Network Settings

Die grundlegenden Netzwerk-Einstellungen werden unter **Settings → Networks** konfiguriert:

```yaml
Auto Optimize Network:     Deaktiviert (manuelle Kontrolle)
Band Steering:            Aktiviert
Fast Roaming:             Aktiviert (für WiFi 6 APs)
UAPSD:                    Aktiviert
```

## VLAN-Konfiguration

### Standard-LAN Netzwerk

Das Standard-LAN ist bereits vorkonfiguriert, sollte aber angepasst werden:

```yaml
Name:                Standard-LAN
VLAN:               Default (untagged)
Gateway/Subnet:     192.168.1.1/24
DHCP Mode:          UniFi
DHCP Range:         192.168.1.100 - 192.168.1.200
Lease Time:         24 Stunden
DNS Server:         192.168.1.3, 192.168.1.4, 8.8.8.8
Domain Name:        lab.enzmann.online
IPv6:              Deaktiviert (optional)
```

#### Standard-LAN Konfiguration (GUI)

1. **Settings → Networks → Default**
2. **General Settings**:
   - Name: `Standard-LAN`
   - Gateway IP: `192.168.1.1`
   - Subnet: `192.168.1.0/24`
   - VLAN: Default (nicht ändern)
3. **DHCP Settings**:
   - DHCP Mode: `UniFi`
   - DHCP Range: `192.168.1.100` - `192.168.1.200`
   - Lease Time: `24 hours`
4. **DNS Settings**:
   - DNS Server 1: `192.168.1.3`
   - DNS Server 2: `192.168.1.4`
   - DNS Server 3: `8.8.8.8`
   - Domain Name: `lab.enzmann.online`

### IOT-VLAN Erstellen

Das IOT-VLAN wird als neues Netzwerk erstellt:

```yaml
Name:                IOT-VLAN
VLAN ID:            100
Gateway/Subnet:     192.168.100.1/22
DHCP Mode:          UniFi
DHCP Range:         192.168.100.50 - 192.168.103.200
Lease Time:         8 Stunden (kürzer für IOT-Geräte)
DNS Server:         192.168.1.3, 192.168.1.4
Domain Name:        iot.enzmann.online
```

#### IOT-VLAN Konfiguration (GUI)

1. **Settings → Networks → Create New Network**
2. **General Settings**:
   - Name: `IOT-VLAN`
   - Gateway IP: `192.168.100.1`
   - Subnet: `192.168.100.0/22`
   - VLAN ID: `100`
3. **Advanced Settings**:
   - Multicast DNS: `Enabled` (für Device Discovery)
   - IGMP Snooping: `Enabled`
4. **DHCP Settings**:
   - DHCP Mode: `UniFi`
   - DHCP Range: `192.168.100.50` - `192.168.103.200`
   - Lease Time: `8 hours`
5. **DNS Settings**:
   - DNS Server 1: `192.168.1.3`
   - DNS Server 2: `192.168.1.4`
   - Domain Name: `iot.enzmann.online`

### Gäste-VLAN Erstellen

Das Gäste-VLAN mit vollständiger Isolation:

```yaml
Name:                Gäste-VLAN
VLAN ID:            200
Gateway/Subnet:     192.168.200.1/24
DHCP Mode:          UniFi
DHCP Range:         192.168.200.10 - 192.168.200.250
Lease Time:         4 Stunden (kurz für Gäste)
DNS Server:         192.168.1.3, 8.8.8.8
Domain Name:        guest.enzmann.online
Guest Policy:       Aktiviert
```

#### Gäste-VLAN Konfiguration (GUI)

1. **Settings → Networks → Create New Network**
2. **General Settings**:
   - Name: `Gäste-VLAN`
   - Gateway IP: `192.168.200.1`
   - Subnet: `192.168.200.0/24`
   - VLAN ID: `200`
3. **Guest Policy**:
   - Guest Policy: `Enabled`
   - Pre-Authorization Access: `None`
4. **DHCP Settings**:
   - DHCP Mode: `UniFi`
   - DHCP Range: `192.168.200.10` - `192.168.200.250`
   - Lease Time: `4 hours`

!!! note "Guest Policy Effekt"
    Die Guest Policy blockiert automatisch den Zugriff auf lokale Netzwerke und ermöglicht nur Internet-Zugang.

## WiFi-Netzwerk-Konfiguration

### WiFi "Enzian" (Standard-LAN)

Das Haupt-WiFi-Netzwerk für vertrauenswürdige Geräte:

```yaml
Name:               Enzian
Security:           WPA2/WPA3 (Personal)
Password:           [Starkes WiFi-Passwort]
Network:            Standard-LAN (Default VLAN)
WiFi Band:          2.4 GHz + 5 GHz
Channel Width:      80 MHz (5 GHz), 20 MHz (2.4 GHz)
Fast Roaming:       Enabled (bei mehreren APs)
Band Steering:      Enabled
```

#### WiFi Standard-LAN Setup (GUI)

1. **Settings → WiFi → Create New WiFi Network**
2. **General Settings**:
   - Name: `Enzian`
   - Enabled: `✓`
   - Security Protocol: `WPA2/WPA3`
   - Password: `[Starkes Passwort]`
3. **Advanced Settings**:
   - Network: `Standard-LAN`
   - WiFi Band: `Both`
   - Channel Width: `80 MHz`
   - Fast Roaming: `Enabled`

### WiFi "Enzian-IOT" (IOT-VLAN)

Separates WiFi-Netzwerk für Smart Home Geräte:

```yaml
Name:               Enzian-IOT
Security:           WPA2/WPA3 (Personal)
Password:           [IOT-spezifisches Passwort]
Network:            IOT-VLAN (VLAN 100)
WiFi Band:          2.4 GHz + 5 GHz
Guest Network:      Disabled
Client Device Isolation: Disabled (IOT-Geräte kommunizieren)
```

#### WiFi IOT-VLAN Setup (GUI)

1. **Settings → WiFi → Create New WiFi Network**
2. **General Settings**:
   - Name: `Enzian-IOT`
   - Security Protocol: `WPA2/WPA3`
   - Password: `[IOT-Passwort]`
3. **Advanced Settings**:
   - Network: `IOT-VLAN`
   - Guest Network: `Disabled`
   - Client Device Isolation: `Disabled`

### WiFi "Enzian-Gast" (Gäste-VLAN)

Gäste-WiFi mit vollständiger Isolation:

```yaml
Name:               Enzian-Gast
Security:           WPA2/WPA3 (Personal)
Password:           [Einfaches Gäste-Passwort]
Network:            Gäste-VLAN (VLAN 200)
WiFi Band:          2.4 GHz + 5 GHz
Guest Network:      Enabled
Client Device Isolation: Enabled (Gäste isoliert)
Bandwidth Limit:    50 Mbit/s (optional)
Schedule:           Immer aktiv (oder zeitgesteuert)
```

#### WiFi Gäste-VLAN Setup (GUI)

1. **Settings → WiFi → Create New WiFi Network**
2. **General Settings**:
   - Name: `Enzian-Gast`
   - Security Protocol: `WPA2/WPA3`
   - Password: `[Einfaches Passwort]`
3. **Advanced Settings**:
   - Network: `Gäste-VLAN`
   - Guest Network: `Enabled`
   - Client Device Isolation: `Enabled`
4. **Guest Access Settings**:
   - Bandwidth Limit Down: `50 Mbps`
   - Bandwidth Limit Up: `10 Mbps`

!!! tip "Gäste-Passwort"
    Verwende ein einfaches, aber sicheres Passwort für Gäste (z.B. "Gast2024!"). Es sollte leicht zu kommunizieren, aber nicht trivial zu erraten sein.

## DHCP-Reservierungen

### Kritische Infrastruktur

Statische DHCP-Reservierungen für wichtige Geräte werden unter **Settings → Networks → [Network] → DHCP** konfiguriert:

```yaml
# Pi-hole Server
MAC: aa:bb:cc:dd:ee:01 → IP: 192.168.1.3  (pihole-01)
MAC: aa:bb:cc:dd:ee:02 → IP: 192.168.1.4  (pihole-02)

# UniFi Hardware (automatisch erkannt)
switch-main-01         → IP: 192.168.1.10
ap-wz-01              → IP: 192.168.1.11
ap-sz-01              → IP: 192.168.1.12
```

#### DHCP-Reservierung erstellen (GUI)

1. **Clients → [Gerät auswählen] → Settings**
2. **Network Configuration**:
   - Use Fixed IP Address: `✓`
   - Fixed IP Address: `[Gewünschte IP]`
3. **Apply Changes**

### IOT-Geräte Reservierungen

```yaml
# Smart Home Hubs
hm-ccu-uv-01          → IP: 192.168.100.10
hue-wz-bridge01       → IP: 192.168.101.1

# Wichtige Shelly Devices
shelly-1-flur-01      → IP: 192.168.100.70
shelly-dimmer-az-01   → IP: 192.168.100.135
```

!!! note "Automatische Adoption"
    UniFi-Geräte werden automatisch adoptiert und erhalten passende Reservierungen. Drittanbieter-Geräte müssen manuell konfiguriert werden.

## Switch-Konfiguration

### Port-Profile

Erstelle Port-Profile für verschiedene Gerätekategorien unter **Settings → Profiles → Switch Ports**:

```yaml
# Profile "Standard-LAN"
Name:           Standard-LAN
Native VLAN:    Default
Tagged VLANs:   None
Port Isolation: Disabled
Storm Control:  Enabled

# Profile "IOT-Devices"  
Name:           IOT-Devices
Native VLAN:    100 (IOT-VLAN)
Tagged VLANs:   None
Port Isolation: Disabled
Storm Control:  Enabled

# Profile "Trunk"
Name:           Trunk
Native VLAN:    Default
Tagged VLANs:   100, 200 (alle VLANs)
Port Isolation: Disabled
```

### Port-Zuweisungen

Beispiel-Zuweisungen für einen 16-Port Switch:

```yaml
Port 1-4:    Trunk (für Access Points mit mehreren VLANs)
Port 5-8:    Standard-LAN (Homelab-Server)
Port 9-12:   IOT-Devices (kabelgebundene IOT-Geräte)
Port 13-16:  Standard-LAN (Management-PCs)
```

## Access Point Konfiguration

### Radio-Einstellungen

Optimale Einstellungen für WiFi 6 Access Points:

#### 2.4 GHz Band

```yaml
Channel:        Auto (oder 1, 6, 11 bei Interferenz)
Channel Width:  20 MHz (HT20)
Transmit Power: Auto (oder manuell bei Überlappung)
Min RSSI:      -70 dBm (für automatisches Roaming)
```

#### 5 GHz Band

```yaml
Channel:        Auto (DFS-Kanäle erlaubt)
Channel Width:  80 MHz (VHT80) oder 160 MHz (WiFi 6)
Transmit Power: Auto
Min RSSI:      -65 dBm
```

### WiFi-Optimierungen

```yaml
Band Steering:       Enabled (bevorzugt 5 GHz)
Fast Roaming:        Enabled (bei mehreren APs)
UAPSD:              Enabled (Power Saving)
Multicast Enhancement: Enabled (für Streaming)
Airtime Fairness:    Enabled (verhindert langsamere Geräte)
```

!!! tip "Channel Planning"
    Bei mehreren Access Points plane die Kanäle manuell um Interferenzen zu vermeiden. Verwende WiFi-Analyzer-Apps zur Überwachung.

## Monitoring und Wartung

### UniFi Network Application Dashboard

Wichtige Metriken zur regelmäßigen Überwachung:

```yaml
Client Count:       Anzahl verbundener Geräte pro VLAN
Throughput:        Bandbreitennutzung pro Netzwerk
Channel Utilization: WiFi-Kanal-Auslastung
RF Environment:     Interferenzen und Nachbar-APs
```

### Health Checks

Wöchentliche Kontrollen:

1. **Device Status**: Alle UniFi-Geräte online?
2. **Firmware Updates**: Verfügbare Updates installieren
3. **Client Connectivity**: Problematische Verbindungen identifizieren
4. **Performance**: Bandbreiten-Engpässe erkennen

### Backup-Strategie

```yaml
Automatisches Backup: Täglich um 03:00 Uhr
Backup-Location:     Lokaler Controller-Storage
Manueller Export:    Monatlich (Settings → System → Download Backup)
Aufbewahrung:       3 Monate automatisch, 1 Jahr manuell
```

!!! warning "Controller-Backup"
    Regelmäßige Backups der UniFi Controller-Konfiguration sind kritisch. Bei Ausfall müssten sonst alle Einstellungen manuell rekonfiguriert werden.

## Troubleshooting

### Häufige Probleme

#### VLAN-Zuordnung funktioniert nicht

```bash
# Checks:
1. VLAN-ID korrekt am Switch-Port?
2. WiFi-Netzwerk der richtigen VLAN zugeordnet?
3. DHCP-Server für VLAN aktiviert?
4. Firewall-Regeln blockieren Traffic?
```

#### WiFi-Verbindungsprobleme

```bash
# Diagnose:
1. RF Environment im Controller prüfen
2. Kanal-Interferenzen identifizieren
3. Transmit Power adjustieren
4. Client-Gerät WLAN-Adapter aktualisieren
```

#### DHCP-Lease-Probleme

```bash
# Troubleshooting:
1. DHCP-Pool ausgeschöpft?
2. IP-Konflikte durch doppelte Reservierungen?
3. Lease-Zeit zu kurz für IOT-Geräte?
4. DNS-Server erreichbar?
```

### Log-Analyse

Wichtige Log-Kategorien im UniFi Controller:

```yaml
Events:     Gerät-Adoption, Disconnects, Roaming
Alerts:     Performance-Probleme, Ausfälle
Threats:    Sicherheitsereignisse (optional)
```

## Aufwandsschätzung

| Phase | Aufwand | Beschreibung |
|-------|---------|--------------|
| **Controller Setup** | 1-2 Stunden | Grundkonfiguration, Admin-Account |
| **VLAN-Erstellung** | 1 Stunde | Alle drei VLANs konfigurieren |
| **WiFi-Netzwerke** | 30 Minuten | Drei WiFi-Netzwerke einrichten |
| **DHCP-Konfiguration** | 1 Stunde | Bereiche und Reservierungen |
| **Switch-Konfiguration** | 30 Minuten | Port-Profile und Zuweisungen |
| **Access Point Setup** | 1 Stunde | Radio-Optimierung, Positionierung |
| **Testing** | 1-2 Stunden | Alle VLANs und WiFi-Netzwerke testen |
| **Feintuning** | 1-2 Stunden | Performance-Optimierung |

**Gesamtaufwand**: 6-9 Stunden für komplette UniFi-Konfiguration
