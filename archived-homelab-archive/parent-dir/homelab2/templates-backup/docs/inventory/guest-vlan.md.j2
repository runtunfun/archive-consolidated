# Gäste-VLAN Inventar

Das Gäste-VLAN (192.168.200.0/24) stellt einen isolierten Internetzugang für Besucher bereit, ohne Zugriff auf interne Homelab-Ressourcen oder IOT-Geräte. Diese Lösung gewährleistet maximale Sicherheit bei gleichzeitig einfacher Nutzung für Gäste.

## Netzwerk-Übersicht

```yaml
VLAN: 200
Subnetz: 192.168.200.0/24 (254 IPs)
Gateway: 192.168.200.1
DNS-Server: 192.168.1.3 (nur DNS-Auflösung)
Domain: guest.homelab.example
WiFi-Netzwerk: "Enzian-Gast"
WiFi-Passwort: [Einfaches, gästefreundliches Passwort]
```

!!! info "Design-Prinzipien"
    **Sicherheit durch Isolation:**
    
    - ✅ **Internet-Zugang:** Vollständiger HTTP/HTTPS-Zugang
    - ✅ **DNS-Auflösung:** Über zentrale Pi-hole Server
    - ❌ **Standard-LAN:** Kein Zugriff auf Homelab-Services
    - ❌ **IOT-VLAN:** Kein Zugriff auf Smart Home Geräte
    - ❌ **Inter-Client:** Client-Isolation zwischen Gäste-Geräten
    - ❌ **Management:** Kein Zugriff auf UniFi, Proxmox, etc.

## DHCP-Konfiguration

### Adressbereiche

| Bereich | IP-Bereich | Anzahl IPs | Lease-Zeit | Verwendung |
|---------|------------|------------|------------|------------|
| **Gateway** | 192.168.200.1 | 1 | - | VLAN Gateway |
| **Reserve** | 192.168.200.2-9 | 8 | - | Management/Konfiguration |
| **Smartphones** | 192.168.200.10-50 | 41 | 4 Stunden | Gäste-Handys |
| **Laptops** | 192.168.200.51-100 | 50 | 4 Stunden | Gäste-Notebooks |
| **Tablets** | 192.168.200.101-150 | 50 | 4 Stunden | iPads, Android Tablets |
| **Smart Devices** | 192.168.200.151-200 | 50 | 8 Stunden | Smart-TVs, Streaming |
| **Overflow** | 192.168.200.201-250 | 50 | 4 Stunden | Zusätzliche Geräte |
| **Reserve** | 192.168.200.251-254 | 4 | - | Zukünftige Konfiguration |

### DHCP-Einstellungen

```yaml
# UniFi Controller → Networks → Guest-VLAN
DHCP-Server: Aktiviert
Lease-Zeit: 4 Stunden (kurz für bessere Sicherheit)
Domain-Name: guest.homelab.example
DNS-Server: 192.168.1.3, 8.8.8.8 (Fallback)
NTP-Server: 192.168.1.3 (falls verfügbar), pool.ntp.org
Default-Gateway: 192.168.200.1
```

!!! tip "Kurze Lease-Zeiten"
    Die 4-Stunden-Lease-Zeit sorgt für:
    
    - **Bessere Sicherheit:** Regelmäßige IP-Erneuerung
    - **Mehr verfügbare IPs:** Schnellere Wiederverwendung
    - **Einfache Gäste-Verwaltung:** Automatisches "Aussortieren" nach Besuch

## WiFi-Konfiguration

### Gäste-WiFi "Enzian-Gast"

```yaml
SSID: "Enzian-Gast"
Sicherheit: WPA2/WPA3-Personal
Passwort: [Einfach merkbares Passwort, z.B. "Willkommen2024"]
Band: Dual-Band (2.4 GHz + 5 GHz)
VLAN: 200 (Gäste-VLAN)
Bandbreiten-Limit: 50 Mbit/s Download, 10 Mbit/s Upload (optional)
```

### Erweiterte WiFi-Einstellungen

```yaml
# UniFi Controller → WiFi → Enzian-Gast → Advanced
Guest-Isolation: Aktiviert (Clients können sich nicht sehen)
Block-LAN-to-WLAN-Multicast: Aktiviert
Hide-SSID: Deaktiviert (Gäste sollen es finden)
Fast-Roaming: Deaktiviert (nicht nötig für Gäste)
Load-Balancing: Nach Bedarf
Minimum-RSSI: -70 dBm (schwache Verbindungen abweisen)
```

!!! warning "Gäste-Passwort"
    Das WiFi-Passwort sollte:
    
    - **Einfach kommunizierbar** sein (keine komplexen Sonderzeichen)
    - **Auf einem Kärtchen** für Gäste bereitstehen
    - **Regelmäßig geändert** werden (halbjährlich)
    - **QR-Code verfügbar** haben für einfache Verbindung

## Firewall-Regeln

### Zone Matrix Konfiguration

```yaml
# UniFi Controller → Settings → Security → Zone Matrix
Von Hotspot-Zone ZU:
  Internet: ✅ Allow (Vollzugriff auf Internet)
  Internal-Zone: 🔸 Limited (nur DNS + NTP)
  IOT-Zone: ❌ Block (kein Smart Home Zugriff)
  Hotspot-Zone: ❌ Block (Client-Isolation)
```

### Detaillierte Zugriffsregeln

#### Erlaubte Verbindungen (Gäste → Standard-LAN)

```yaml
DNS-Auflösung:
  Port: 53 (UDP/TCP)
  Ziel: 192.168.1.3, 192.168.1.4
  Zweck: Domain-Namen auflösen

NTP-Zeitsynchronisation:
  Port: 123 (UDP)
  Ziel: 192.168.1.3 (falls NTP-Server aktiv)
  Zweck: Korrekte Uhrzeit für Geräte
```

#### Blockierte Verbindungen

```yaml
Homelab-Services:
  - Proxmox (Port 8006)
  - UniFi Controller (Port 8443)
  - Home Assistant (Port 8123)
  - Grafana (Port 3000)
  - Portainer (Port 9000)
  - Traefik Dashboard (Port 443)

IOT-Geräte:
  - Komplettes IOT-VLAN (192.168.100.0/22)
  - MQTT Broker (Port 1883)
  - Hue Bridge (Port 80)
  - Sonos-Geräte (Port 1400)

Management:
  - SSH (Port 22)
  - SNMP (Port 161)
  - Docker APIs (Port 2376/2377)
```

### Traffic-Shaping (Optional)

```yaml
# QoS-Regeln für Gäste-Traffic
Download-Limit: 50 Mbit/s pro Client
Upload-Limit: 10 Mbit/s pro Client
Priorität: Normal (nicht bevorzugt)
Traffic-Kategorien:
  - Web-Browsing: Normal
  - Video-Streaming: Normal
  - P2P/Torrents: Niedrig (optional blockieren)
  - Gaming: Normal
```

!!! note "Bandbreiten-Management"
    Bandbreiten-Limits sind optional, aber empfohlen um:
    
    - **Gäste-Traffic von wichtigem Traffic zu trennen**
    - **Missbrauch zu verhindern** (exzessive Downloads)
    - **Gleichmäßige Verteilung** zwischen mehreren Gästen zu gewährleisten

## Typische Gäste-Geräte

### Smartphones (192.168.200.10-50)

| Gerätetyp | Häufige IP-Range | Typische Nutzung | Besonderheiten |
|-----------|------------------|------------------|----------------|
| **iPhone** | .10-.25 | Safari, Apps, iMessage | iCloud-Sync, AirDrop (lokal blockiert) |
| **Android** | .26-.40 | Chrome, Apps, WhatsApp | Google-Sync, Hotspot-Erkennung |
| **Andere** | .41-.50 | Browser, Social Media | - |

### Laptops & Notebooks (192.168.200.51-100)

| Gerätetyp | Häufige IP-Range | Typische Nutzung | Besonderheiten |
|-----------|------------------|------------------|----------------|
| **Windows** | .51-.70 | Browser, Office, Teams | Windows Update, OneDrive |
| **macOS** | .71-.85 | Safari, Office, iCloud | macOS Updates, iCloud-Sync |
| **Linux** | .86-.95 | Browser, Terminal | Automatische Updates möglich |
| **Chromebook** | .96-.100 | Chrome Browser | Ausschließlich Web-basiert |

### Tablets & E-Reader (192.168.200.101-150)

| Gerätetyp | Häufige IP-Range | Typische Nutzung | Besonderheiten |
|-----------|------------------|------------------|----------------|
| **iPad** | .101-.120 | Safari, Apps, Apple-Ecosystem | App Store, iCloud |
| **Android Tablet** | .121-.135 | Chrome, Play Store | Google Play Services |
| **Kindle** | .136-.145 | E-Books, minimaler Web | Sehr geringer Traffic |
| **E-Reader** | .146-.150 | E-Books, Basic Web | Meist nur Software-Updates |

### Smart Devices (192.168.200.151-200)

| Gerätetyp | Häufige IP-Range | Typische Nutzung | Besonderheiten |
|-----------|------------------|------------------|----------------|
| **Smart TV** | .151-.165 | Netflix, YouTube, Apps | Hohes Datenvolumen |
| **Streaming-Stick** | .166-.175 | Fire TV, Chromecast, Roku | Video-Streaming |
| **Gaming-Konsole** | .176-.185 | Online-Gaming, Updates | Downloads bis 100GB |
| **Sonstige** | .186-.200 | IoT ohne Setup | Gäste-IoT (selten) |

## Monitoring & Logging

### UniFi-basiertes Monitoring

```yaml
Client-Tracking:
  - Automatische Erkennung neuer Gäste-Geräte
  - Bandwidth-Nutzung pro Client
  - Verbindungsstatistiken (Signal, Qualität)
  - Session-Dauer Tracking

Traffic-Analyse:
  - Top-Websites/Domains
  - Download/Upload-Volumen
  - Protokoll-Verteilung (HTTP/HTTPS)
  - Anomalieerkennung
```

### Home Assistant Integration

```yaml
# Gäste-Anwesenheit über UniFi
sensor:
  - platform: unifi
    host: 192.168.1.2
    username: !secret unifi_username
    password: !secret unifi_password
    monitored_conditions:
      - www
      - wlan
      - lan
    detection_time: 180  # 3 Minuten
    
automation:
  - alias: "Neue Gäste erkannt"
    trigger:
      platform: state
      entity_id: device_tracker.guest_device
      from: 'not_home'
      to: 'home'
    action:
      service: notify.admin
      data:
        message: "Neuer Gast im Netzwerk: {{ trigger.entity_id }}"
```

### Sicherheits-Monitoring

```yaml
Überwachung auf:
  Ungewöhnliche Verbindungsversuche:
    - Scans auf Standard-LAN (Port 22, 8006, 8443)
    - Versuche auf IOT-VLAN zuzugreifen
    - DNS-Tunneling-Versuche
  
  Anomalien:
    - Excessive Downloads (>10GB/Tag)
    - Ungewöhnliche Ports/Protokolle
    - Längerfristige Verbindungen (>24h)
  
  Alerting:
    - E-Mail bei Sicherheitsereignissen
    - Home Assistant Benachrichtigungen
    - UniFi-Logs für forensische Analyse
```

!!! warning "Datenschutz"
    Beim Monitoring von Gäste-Devices sind Datenschutzbestimmungen zu beachten:
    
    - **Nur Metadaten** (nicht Inhalte) überwachen
    - **Transparenz:** Gäste über Monitoring informieren
    - **Retention:** Logs nur temporär speichern (7-30 Tage)
    - **Anonymisierung:** Persönliche Daten nach Besuch löschen

## Wartung & Administration

### Routinemäßige Aufgaben

#### Täglich (automatisch)
```bash
# Log-Rotation für Gäste-Traffic
# Automatische Bereinigung alter DHCP-Leases
# Traffic-Statistiken sammeln
```

#### Wöchentlich
```bash
# Gäste-Device-Liste bereinigen
# Bandwidth-Statistiken prüfen
# Sicherheits-Logs auswerten

# UniFi Controller → Insights → Guest Network
# Überprüfung auf Anomalien oder Missbrauch
```

#### Monatlich
```bash
# WiFi-Passwort bewerten (bei Bedarf ändern)
# Firewall-Logs analysieren
# Gäste-Feedback einholen (falls möglich)

# Performance-Check
ping -c 10 8.8.8.8  # Internet-Konnektivität
speedtest-cli        # Bandbreiten-Test vom Gateway
```

### Gäste-Support

#### Häufige Probleme & Lösungen

**Problem: "Kein Internet trotz WiFi-Verbindung"**
```bash
Diagnose:
1. DNS-Test: nslookup google.com 192.168.1.3
2. Gateway-Test: ping 192.168.200.1
3. Internet-Test: ping 8.8.8.8

Lösungen:
- DHCP-Lease erneuern (Client trennen/neu verbinden)
- DNS-Cache leeren (Gerät neu starten)
- Firewall-Regeln prüfen
```

**Problem: "Sehr langsame Geschwindigkeit"**
```bash
Diagnose:
1. Client-Count prüfen (zu viele gleichzeitige Nutzer?)
2. Signal-Stärke prüfen (RSSI < -70 dBm?)
3. Bandbreiten-Limits überprüfen

Lösungen:
- QoS-Limits temporär erhöhen
- Gäste zu anderem Access Point leiten
- Traffic-Shaping anpassen
```

**Problem: "Kann bestimmte Seite nicht erreichen"**
```bash
Diagnose:
1. DNS-Auflösung: dig domain.com @192.168.1.3
2. Pi-hole Blocklist prüfen
3. Firewall-Logs für blockierte Verbindungen

Lösungen:
- Temporäres Pi-hole Whitelisting
- Alternative DNS verwenden (8.8.8.8)
- Spezifische Firewall-Regel hinzufügen
```

#### Self-Service für Gäste

**Informations-Kärtchen:**
```
WLAN: "Enzian-Gast"
Passwort: [Aktuelles Passwort]

QR-Code: [WiFi QR-Code]

Support:
- Bei Problemen: [Kontakt-Info]
- Internet-Zugang: ✓
- Lokale Geräte: ✗
- Drucker: ✗

Bandbreite: Bis 50 Mbit/s
```

**Digitales Portal (optional):**
```yaml
Captive Portal:
  URL: http://guest.homelab.example
  Features:
    - Willkommens-Seite
    - Nutzungsbedingungen
    - Selbst-Test Tools
    - Kontakt-Information
    - Speed-Test Link
```

## Erweiterungsmöglichkeiten

### Captive Portal Integration

```yaml
# Erweiterte Gäste-Verwaltung mit Captive Portal
Features:
  - Registrierung mit E-Mail/Name
  - Zeitbasierte Zugangscodes
  - Unterschiedliche Bandbreiten-Profile
  - Selbstservice-Portal für Gäste
  - Automatische Deaktivierung nach Zeit

UniFi Integration:
  - UniFi Guest Portal aktivieren
  - Voucher-System für Zugangscodes
  - Social Media Login (optional)
  - Terms & Conditions vor Zugang
```

### Gäste-Kategorien

```yaml
Standard-Gast:
  Bandbreite: 50 Mbit/s
  Zeit-Limit: 24 Stunden
  Services: Web + E-Mail nur

Premium-Gast:
  Bandbreite: 100 Mbit/s
  Zeit-Limit: 7 Tage
  Services: Web + Streaming + Gaming

Langzeit-Gast:
  Bandbreite: 25 Mbit/s
  Zeit-Limit: 30 Tage
  Services: Basis Web-Zugang
```

### Integration mit Smart Home

```yaml
# Optionale Integration für besondere Gäste
Automatisierung:
  - Gast erkannt → Willkommens-Licht
  - Check-out → Automatische Deaktivierung
  - Feedback-Sammlung via Tablet
  
Home Assistant:
  - Gäste-Dashboard auf Tablet
  - Musik-Steuerung für Gäste-Zimmer
  - Licht-Steuerung im Gäste-Bereich
```

## Aufwandsschätzung

| Aktivität | Zeitaufwand | Häufigkeit | Automatisierbar |
|-----------|-------------|------------|-----------------|
| **Initiale Einrichtung** | 2-3 Stunden | Einmalig | Teilweise |
| **Gäste onboarding** | 2 Minuten | Pro Gast | Vollständig |
| **Passwort ändern** | 5 Minuten | Halbjährlich | Nein |
| **Monitoring überprüfen** | 10 Minuten | Wöchentlich | Größtenteils |
| **Support-Anfragen** | 5-15 Minuten | Nach Bedarf | Teilweise |
| **Log-Auswertung** | 20 Minuten | Monatlich | Größtenteils |

**Gesamtaufwand:** ~1 Stunde/Monat für Gäste-VLAN Verwaltung.

!!! success "Best Practices"
    **Erfolgsfaktoren für gute Gäste-Erfahrung:**
    
    ✅ **Einfacher WiFi-Zugang** mit QR-Code  
    ✅ **Klare Kommunikation** über verfügbare Services  
    ✅ **Schnelle Internet-Geschwindigkeit** (mindestens 25 Mbit/s)  
    ✅ **Proaktiver Support** bei Problemen  
    ✅ **Automatische Bereinigung** nach Besuch  
    ✅ **Datenschutz-konformes** Monitoring  

!!! tip "Kostenoptimierung"
    Das Gäste-VLAN verursacht minimal zusätzliche Kosten:
    
    - **Hardware:** Nutzt vorhandene UniFi-Infrastruktur
    - **Bandbreite:** Teilt sich Internet-Anschluss
    - **Wartung:** Größtenteils automatisiert
    - **Support:** Minimaler Aufwand durch gute Dokumentation
