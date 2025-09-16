# Zone Matrix und Firewall-Konfiguration

## Übersicht

Die UniFi Zone Matrix bietet granulare Kontrolle über die Inter-VLAN-Kommunikation. Sie implementiert das Prinzip der geringsten Privilegien und ermöglicht es, präzise zu definieren, welche Netzwerke miteinander kommunizieren dürfen.

## Zone-Definitionen

### Built-in Zones

UniFi bietet standardmäßig drei vordefinierte Zones:

```yaml
Internal:   Automatisch für Standard-LAN (Default VLAN)
Hotspot:    Für Gäste-Netzwerke mit eingeschränktem Zugriff
Internet:   Externe Verbindungen (WAN)
```

### Custom Zone: IOT

Für das Smart Home VLAN wird eine zusätzliche Zone erstellt:

```yaml
Zone Name:     IOT
Description:   Smart Home und Mobile Clients
Networks:      IOT-VLAN (192.168.100.0/22)
Type:         Custom Zone
```

#### IOT Zone erstellen (GUI)

1. **Settings → Security → Zones → Create New Zone**
2. **Zone Configuration**:
   - Name: `IOT`
   - Description: `Smart Home und Mobile Clients`
   - Type: `Custom Zone`
3. **Network Assignment**:
   - Add Network: `IOT-VLAN`
   - Apply Changes

!!! note "Zone-Naming"
    Verwende aussagekräftige Namen für Zones. Dies erleichtert das Verständnis der Firewall-Regeln erheblich.

## Zone Matrix Konfiguration

### Komplette Zone Matrix

Die Zone Matrix definiert die erlaubte Kommunikation zwischen allen Netzwerk-Zones:

| Von → Nach | Internal | IOT | Hotspot | Internet |
|------------|----------|-----|---------|----------|
| **Internal** | ✅ Allow | ✅ Allow | ❌ Block | ✅ Allow |
| **IOT** | 🔸 Limited | ✅ Allow | ❌ Block | ✅ Allow |
| **Hotspot** | 🔸 Limited | ❌ Block | ✅ Allow | ✅ Allow |
| **Internet** | ✅ Allow | ✅ Allow | ✅ Allow | ✅ Allow |

### Matrix-Erklärung

#### Internal Zone (Standard-LAN)

```yaml
→ Internal:   Allow     # Management-Geräte untereinander
→ IOT:        Allow     # Vollzugriff auf Smart Home (Management)
→ Hotspot:    Block     # Keine Verbindung zu Gästen
→ Internet:   Allow     # Uneingeschränkter Internet-Zugang
```

#### IOT Zone (Smart Home)

```yaml
→ Internal:   Limited   # Nur spezifische Services (DNS, NTP, HA)
→ IOT:        Allow     # IOT-Geräte untereinander kommunizieren
→ Hotspot:    Block     # Keine Verbindung zu Gästen
→ Internet:   Allow     # Internet für Updates und Cloud-Services
```

#### Hotspot Zone (Gäste)

```yaml
→ Internal:   Limited   # Nur DNS für Namensauflösung
→ IOT:        Block     # Kein Zugriff auf Smart Home
→ Hotspot:    Allow     # Gäste untereinander (falls Client-Isolation deaktiviert)
→ Internet:   Allow     # Internet-Zugang für Gäste
```

!!! warning "Sicherheits-Prinzip"
    Standardmäßig wird alles blockiert. Nur explizit benötigte Verbindungen werden erlaubt.

## Firewall-Regeln

### Internal → IOT (Allow)

Diese Zone-Paarung ermöglicht vollständigen Management-Zugriff vom Standard-LAN auf das IOT-VLAN:

```yaml
Rule Type:    Zone-to-Zone Allow
Source:       Internal Zone
Destination:  IOT Zone
Action:       Allow All Traffic
Priority:     High
```

**Verwendungszwecke:**
- Home Assistant Zugriff auf IOT-Geräte
- Management und Konfiguration von Smart Home Devices
- Monitoring und Logging von IOT-Geräten

### IOT → Internal (Limited)

Spezifische Regeln für notwendige Services vom IOT-VLAN zum Standard-LAN:

#### DNS-Zugriff (Pi-hole)

```yaml
Rule Name:        IOT-to-DNS
Source Zone:      IOT
Destination Zone: Internal
Action:          Allow
Protocol:        TCP/UDP
Port:            53
Destination:     192.168.1.3, 192.168.1.4
Description:     DNS-Auflösung über Pi-hole
```

#### NTP-Zeitserver

```yaml
Rule Name:        IOT-to-NTP
Source Zone:      IOT
Destination Zone: Internal
Action:          Allow
Protocol:        UDP
Port:            123
Destination:     Any (für lokale NTP-Server)
Description:     Zeitsynchronisation für IOT-Geräte
```

#### Home Assistant API

```yaml
Rule Name:        IOT-to-HomeAssistant
Source Zone:      IOT
Destination Zone: Internal
Action:          Allow
Protocol:        TCP
Port:            8123
Destination:     192.168.1.41
Description:     IOT-Geräte → Home Assistant Webhook/API
```

#### MQTT Broker

```yaml
Rule Name:        IOT-to-MQTT
Source Zone:      IOT
Destination Zone: Internal
Action:          Allow
Protocol:        TCP
Port:            1883, 8883
Destination:     192.168.1.55
Description:     MQTT-Kommunikation für Smart Home
```

#### mDNS für Device Discovery

```yaml
Rule Name:        IOT-to-mDNS
Source Zone:      IOT
Destination Zone: Internal
Action:          Allow
Protocol:        UDP
Port:            5353
Destination:     224.0.0.251 (Multicast)
Description:     Service Discovery (Bonjour/Avahi)
```

!!! tip "Minimal-Prinzip"
    Nur die absolut notwendigen Ports und Services werden für IOT → Internal erlaubt.

### Hotspot → Internal (Limited)

Gäste benötigen minimalen Zugriff auf lokale Services:

#### DNS-Zugriff

```yaml
Rule Name:        Guest-to-DNS
Source Zone:      Hotspot
Destination Zone: Internal
Action:          Allow
Protocol:        TCP/UDP
Port:            53
Destination:     192.168.1.3
Description:     DNS-Auflösung für Gäste (mit Ad-Blocking)
```

#### NTP-Zeitserver

```yaml
Rule Name:        Guest-to-NTP
Source Zone:      Hotspot
Destination Zone: Internal
Action:          Allow
Protocol:        UDP
Port:            123
Destination:     Any
Description:     Zeitsynchronisation für Gäste-Geräte
```

**Explizit blockiert für Gäste:**
- Alle anderen lokalen Services
- Homelab-Management-Interfaces
- Smart Home Geräte und Hubs

### Default-Deny-Regeln

Alle nicht explizit erlaubten Verbindungen werden blockiert:

```yaml
Rule Name:        IOT-to-Internal-Block
Source Zone:      IOT
Destination Zone: Internal
Action:          Block
Protocol:        Any
Port:            Any (außer explizit erlaubte)
Logging:         Enabled
```

## GUI-Konfiguration der Zone Matrix

### Zone Matrix aktivieren

1. **Settings → Security → Firewall & Security → Zone Matrix**
2. **Enable Zone Matrix**: `✓`
3. **Default Action**: `Block` (sicherer Standard)

### Matrix-Einträge konfigurieren

Für jede Zone-Paarung:

1. **Zelle in Matrix anklicken**
2. **Aktion wählen**:
   - `Allow`: Vollzugriff zwischen Zones
   - `Block`: Komplette Blockierung
   - `Limited`: Nur spezifische Firewall-Regeln
3. **Apply Changes**

### Custom Firewall Rules erstellen

Für "Limited" Zone-Pairings werden spezifische Regeln benötigt:

1. **Settings → Security → Firewall & Security → Internet & Zone Threat Management**
2. **Create New Rule**:
   - Rule Type: `Zone to Zone`
   - Source Zone: `[Quell-Zone]`
   - Destination Zone: `[Ziel-Zone]`
   - Action: `Allow`
   - Protocol: `TCP/UDP/Both`
   - Port: `[Spezifischer Port]`
   - Destination: `[IP oder Any]`

!!! warning "Regel-Reihenfolge"
    Firewall-Regeln werden in der Reihenfolge ihrer Priorität abgearbeitet. Allow-Regeln müssen vor den entsprechenden Block-Regeln stehen.

## Erweiterte Konfigurationen

### Client Device Isolation

Zusätzlich zur Zone Matrix kann Client Isolation aktiviert werden:

#### WiFi-Level Isolation

```yaml
Network:              Enzian-Gast
Client Device Isolation: Enabled
Effect:               Gäste-Geräte können sich nicht untereinander erreichen
```

#### VLAN-Level Isolation

```yaml
Network:              IOT-VLAN
Private VLAN:         Disabled (IOT-Geräte müssen kommunizieren)
Multicast DNS:        Enabled (für Device Discovery)
```

### Threat Management

Erweiterte Sicherheitsfeatures für Zone-basierte Erkennung:

```yaml
IPS (Intrusion Prevention): Enabled
IDS (Intrusion Detection):  Enabled
Country Restrictions:       Optional (blockiere bestimmte Länder)
Honeypot:                  Optional (für erweiterte Überwachung)
```

#### Threat Management Konfiguration

1. **Settings → Security → Firewall & Security → Internet & Zone Threat Management**
2. **Threat Management**:
   - Enable Threat Management: `✓`
   - Categories: `All` oder spezifische Bedrohungstypen
   - Sensitivity: `Medium` (balance zwischen Sicherheit und False Positives)

### Geographic Restrictions

Optional: Blockiere Traffic aus bestimmten Ländern:

```yaml
Countries to Block:   CN, RU, KP (China, Russland, Nordkorea)
Apply to:            WAN Only (nicht für lokale VLANs)
Exceptions:          Keine (für maximale Sicherheit)
```

!!! note "Performance-Impact"
    Threat Management und Geographic Restrictions können die Gateway-Performance beeinträchtigen. Teste die Auswirkungen nach der Aktivierung.

## Monitoring und Logging

### Firewall-Logs

Wichtige Log-Ereignisse überwachen:

```yaml
Log Dropped Packets:   Enabled (für Troubleshooting)
Log Allowed Packets:   Disabled (reduziert Log-Volume)
Log Level:            Notice (für wichtige Ereignisse)
Syslog Server:        192.168.1.52 (InfluxDB für Analyse)
```

### Zone Matrix Monitoring

Regelmäßige Überprüfung der Zone Matrix:

1. **Unifi Network → Insights → Client Insights**
2. **Traffic Analysis**: Inter-VLAN-Traffic überwachen
3. **Blocked Connections**: Fehlgeschlagene Verbindungsversuche analysieren
4. **Top Talkers**: Geräte mit hohem Netzwerk-Traffic identifizieren

### Log-Analyse mit Tools

```bash
# Firewall-Logs auswerten (bei SSH-Zugang zum Gateway)
tail -f /var/log/messages | grep -i firewall

# Traffic-Statistiken
iptables -L -n -v

# Connection Tracking
cat /proc/net/nf_conntrack | grep -E "(192\.168\.1\.|192\.168\.100\.|192\.168\.200\.)"
```

## Troubleshooting

### Häufige Zone Matrix Probleme

#### Service nicht erreichbar zwischen VLANs

```bash
# Diagnose-Schritte:
1. Zone Matrix Konfiguration überprüfen
2. Spezifische Firewall-Regel für Service erstellt?
3. Richtige Ports und Protokolle konfiguriert?
4. DNS-Auflösung zwischen VLANs funktioniert?
```

#### IOT-Geräte können Home Assistant nicht erreichen

```bash
# Häufige Ursachen:
1. IOT → Internal Zone nicht auf "Limited" gesetzt
2. Port 8123 (HA) nicht in Firewall-Regel erlaubt
3. mDNS-Traffic blockiert (Port 5353)
4. Geräte in falschem VLAN registriert
```

#### Gäste haben Zugriff auf lokale Services

```bash
# Sicherheitscheck:
1. Hotspot → Internal auf "Limited" oder "Block"?
2. Guest Policy im Gäste-VLAN aktiviert?
3. Client Device Isolation im Gäste-WiFi aktiviert?
4. Firewall-Regeln für Gäste minimal?
```

### Testing der Zone Matrix

#### Konnektivitäts-Tests

```bash
# Von Standard-LAN zu IOT (sollte funktionieren)
ping 192.168.100.10  # Homematic CCU
curl http://192.168.101.1  # Hue Bridge

# Von IOT zu Standard-LAN (nur erlaubte Services)
nslookup ha-prod-01.lab.homelab.example 192.168.1.3  # DNS sollte funktionieren
curl -m 5 http://192.168.1.48  # Traefik sollte funktionieren (falls erlaubt)
curl -m 5 http://192.168.1.50  # Portainer sollte blockiert sein

# Von Gäste-VLAN (sollte größtenteils blockiert sein)
ping 192.168.1.1   # Gateway sollte funktionieren
ping 192.168.1.41  # Home Assistant sollte blockiert sein
nslookup google.com 192.168.1.3  # DNS sollte funktionieren
```

#### Port-spezifische Tests

```bash
# MQTT-Zugriff von IOT zu Standard-LAN
mosquitto_pub -h 192.168.1.55 -t test -m "hello"  # Sollte funktionieren

# HTTP-Zugriff von IOT zu Homelab-Services
curl -m 5 http://192.168.1.51:3000  # Grafana sollte blockiert sein
curl -m 5 http://192.168.1.41:8123  # Home Assistant sollte funktionieren
```

## Best Practices

### Sicherheits-Richtlinien

1. **Minimal Privilege**: Nur absolut notwendige Verbindungen erlauben
2. **Regular Audits**: Monatliche Überprüfung der Zone Matrix
3. **Logging**: Alle blockierten Verbindungen loggen und analysieren
4. **Documentation**: Jede Firewall-Regel dokumentieren

### Performance-Optimierung

```yaml
Rule Optimization:     Häufig verwendete Regeln nach oben
Protocol Specificity:  TCP/UDP statt "Any" wenn möglich
IP-Range Limitation:   Spezifische IPs statt "Any"
Log Reduction:        Nur kritische Events loggen
```

### Wartung und Updates

```yaml
Monatlich:    Zone Matrix Konfiguration überprüfen
Quarterly:    Firewall-Regeln auf Relevanz prüfen
Halbjährlich: Complete Security Audit durchführen
Bei Bedarf:   Neue Services in Firewall-Regeln aufnehmen
```

!!! tip "Backup vor Änderungen"
    Erstelle immer ein Controller-Backup vor größeren Änderungen an der Zone Matrix. Fehlerhafte Konfigurationen können das gesamte Netzwerk beeinträchtigen.

## Aufwandsschätzung

| Phase | Aufwand | Beschreibung |
|-------|---------|--------------|
| **Zone-Setup** | 30 Minuten | IOT Zone erstellen und Networks zuweisen |
| **Matrix-Konfiguration** | 1 Stunde | Basis Zone Matrix konfigurieren |
| **Firewall-Regeln** | 2-3 Stunden | Detaillierte Limited-Regeln erstellen |
| **Testing** | 1-2 Stunden | Alle Zone-Verbindungen testen |
| **Threat Management** | 30 Minuten | IPS/IDS aktivieren und konfigurieren |
| **Monitoring Setup** | 1 Stunde | Logging und Alerting einrichten |
| **Dokumentation** | 1 Stunde | Regeln und Konfiguration dokumentieren |

**Gesamtaufwand**: 6-9 Stunden für komplette Zone Matrix Implementierung
