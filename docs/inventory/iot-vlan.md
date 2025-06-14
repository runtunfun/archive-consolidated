# IOT-VLAN Inventar

Das IOT-VLAN (192.168.100.0/22) ist speziell für Smart Home Geräte und mobile Clients konzipiert. Es bietet eine sichere Segmentierung zwischen IOT-Geräten und der kritischen Homelab-Infrastruktur, während gleichzeitig kontrollierter Zugriff auf notwendige Services ermöglicht wird.

## Netzwerk-Übersicht

```yaml
VLAN: 100
Subnetz: 192.168.100.0/22 (1024 IPs)
Gateway: 192.168.100.1
DNS-Server: 192.168.1.3, 192.168.1.4 (Standard-LAN)
Domain: iot.homelab.example
WiFi-Netzwerk: "Enzian-IOT"
```

!!! info "Adressraumaufteilung"
    Das IOT-VLAN verwendet eine raumbasierte IP-Segmentierung für bessere Organisation:
    
    - **192.168.100.x:** Unterverteilung (Zentrale Steuergeräte)
    - **192.168.100.x:** Flur (Sensoren, Schalter)
    - **192.168.100.x:** Arbeitszimmer (Beleuchtung, Sensoren)
    - **192.168.100.x:** Schlafzimmer (Beleuchtung, Klima)
    - **192.168.101.x:** Wohnzimmer (Entertainment, Beleuchtung)
    - **192.168.101.x:** Küche (Geräte, Beleuchtung)
    - **192.168.101.x:** Bad (Sensoren, Lüftung)
    - **192.168.101.x:** Mobile Clients (Smartphones, Tablets)

## Unterverteilung (192.168.100.1 - 192.168.100.62)

### Zentrale Steuergeräte

| Gerät | IP | DNS-Name | Web-Interface | Hersteller | Modell | Funktion |
|-------|----|---------|--------------|-----------|---------|---------| 
| **Homematic CCU** | 192.168.100.10 | hm-ccu-uv-01.iot.homelab.example | http://192.168.100.10 | eQ-3 | CCU3 | Zentrale Homematic Steuerung |
| **UniFi Switch IOT** | 192.168.100.11 | switch-uv-01.iot.homelab.example | - | Ubiquiti | US-8-60W | POE Switch für IOT (optional) |

### Technische Spezifikationen

#### Homematic CCU3
```yaml
Hardware: ARM Cortex-A9 (800 MHz)
RAM: 512 MB
Storage: 8 GB eMMC
Connectivity: 
  - Ethernet 10/100 Mbit
  - Homematic Funk (868 MHz)
  - Homematic IP Funk (868 MHz)
Protokolle: XML-RPC, WebUI, REST API
Max. Geräte: 500 Homematic/IP Geräte
```

!!! tip "CCU Alternatives"
    - **RaspberryMatic:** Läuft auf Raspberry Pi oder als Docker Container
    - **Home Assistant + RFXcom:** Direkte Integration ohne separate CCU
    - **Homegear:** Open-Source CCU-Alternative

## Flur (192.168.100.65 - 192.168.100.126)

### Beleuchtung & Sensoren

| Gerät | IP | DNS-Name | Hersteller | Modell | Raum-Detail | Funktion |
|-------|----|---------|-----------|---------|-----------|---------| 
| **Shelly 1 Deckenlampe** | 192.168.100.70 | shelly-1-flur-01.iot.homelab.example | Allterco | Shelly 1 | Hauptlicht | Deckenbeleuchtung |
| **Homematic Bewegungsmelder** | 192.168.100.71 | hm-motion-flur-01.iot.homelab.example | eQ-3 | HmIP-SMI | Eingangsbereich | Bewegungsdetection |
| **Homematic Türkontakt** | 192.168.100.72 | hm-door-flur-01.iot.homelab.example | eQ-3 | HmIP-SWDO | Haustür | Öffnungsüberwachung |

### Geräte-Konfiguration

#### Shelly 1 (Relais)
```yaml
Firmware: Latest Shelly Firmware
Schaltung: 230V AC Relais
Max. Last: 16A (3680W)
MQTT: Aktiviert (Broker: 192.168.1.55)
HTTP API: http://192.168.100.70/status
Autoconfig: Home Assistant Discovery
```

#### Homematic Bewegungsmelder
```yaml
Typ: Infrarot-Bewegungsmelder (innen)
Batterie: 3x AAA (Lebensdauer ~2 Jahre)
Erfassungswinkel: 105° horizontal
Reichweite: 8m
Helligkeit: Integrierter Helligkeitssensor
CCU Integration: Via Funk 868 MHz
```

!!! warning "Batterie-Monitoring"
    Homematic Geräte senden Batterie-Status an die CCU. Niedrige Batterien sollten über Home Assistant überwacht und gemeldet werden.

## Arbeitszimmer (192.168.100.129 - 192.168.100.190)

### Arbeitsplatz-Beleuchtung

| Gerät | IP | DNS-Name | Hersteller | Modell | Position | Funktion |
|-------|----|---------|-----------|---------|---------|---------| 
| **Shelly Dimmer** | 192.168.100.135 | shelly-dimmer-az-01.iot.homelab.example | Allterco | Shelly Dimmer 2 | Schreibtisch | Dimmbare Arbeitsplatzleuchte |
| **Hue Strip** | 192.168.100.136 | hue-az-01.iot.homelab.example | Philips | Hue Lightstrip Plus | Monitor | RGB Backlight |
| **Homematic Fenster** | 192.168.100.137 | hm-window-az-01.iot.homelab.example | eQ-3 | HmIP-SWDO | Gartenfenster | Fensterüberwachung |

### Erweiterte Konfiguration

#### Shelly Dimmer 2
```yaml
Firmware: Latest Shelly Firmware
Schaltung: Phasenanschnitt-Dimmer
Dimmbereich: 1-100% (LED-optimiert)
Kalibrierung: Auto-Kalibrierung für LED-Last
MQTT Topics:
  - shellies/shellydt-az01/light/0/command
  - shellies/shellydt-az01/light/0/status
  - shellies/shellydt-az01/temperature
Power Monitoring: Ja (Watt, kWh)
```

#### Philips Hue Lightstrip
```yaml
Länge: 2m (erweiterbar bis 10m)
Lichtfarben: 16 Millionen (RGB + CCT)
Helligkeit: 1600 Lumen/m
Bridge: hue-wz-bridge01 (192.168.101.1)
Szenen: Arbeiten, Entspannen, Gaming
Synchronisation: Mit PC-Audio über Hue Sync
```

## Schlafzimmer (192.168.100.193 - 192.168.100.254)

### Beleuchtung & Klimakontrolle

| Gerät | IP | DNS-Name | Hersteller | Modell | Position | Funktion |
|-------|----|---------|-----------|---------|---------|---------| 
| **Hue Lampe Links** | 192.168.100.200 | hue-sz-01.iot.homelab.example | Philips | Hue White and Color | Nachttisch links | Stimmungsbeleuchtung |
| **Hue Lampe Rechts** | 192.168.100.201 | hue-sz-02.iot.homelab.example | Philips | Hue White and Color | Nachttisch rechts | Stimmungsbeleuchtung |
| **Homematic Fensterkontakt** | 192.168.100.202 | hm-window-sz-01.iot.homelab.example | eQ-3 | HmIP-SWDO | Straßenfenster | Sicherheitsüberwachung |
| **Homematic Thermostat** | 192.168.100.203 | hm-thermo-sz-01.iot.homelab.example | eQ-3 | HmIP-eTRV | Heizkörper | Temperaturregelung |

### Smart Sleep Integration

#### Automatisierungen
```yaml
Aufwachen:
  - Trigger: 06:30 (Wochentage)
  - Aktion: Langsames Aufhellen Hue-Lampen (30min)
  - Thermostat: +2°C vor Aufwachzeit

Schlafen gehen:
  - Trigger: 22:30 
  - Aktion: Warmweißes Licht dimmen (15min)
  - Thermostat: Nachtabsenkung -3°C
  - Fenster: Prüfung ob geschlossen

Sicherheit:
  - Fenster offen + Abwesenheit: Benachrichtigung
  - Bewegung bei Nacht: Schwaches rotes Licht
```

## Wohnzimmer (192.168.101.1 - 192.168.101.62)

### Entertainment & Ambiente

| Gerät | IP | DNS-Name | Hersteller | Modell | Position | Funktion |
|-------|----|---------|-----------|---------|---------|---------| 
| **Hue Bridge** | 192.168.101.1 | hue-wz-bridge01.iot.homelab.example | Philips | Hue Bridge v2 | TV-Schrank | Zentrale Hue Steuerung |
| **Sonos One** | 192.168.101.10 | sonos-wz-01.iot.homelab.example | Sonos | Sonos One | Regal | Musikwiedergabe + Alexa |
| **Hue Deckenlampe** | 192.168.101.11 | hue-wz-01.iot.homelab.example | Philips | Hue White Ambiance | Decke | Hauptbeleuchtung |
| **Hue Stehlampe** | 192.168.101.12 | hue-wz-02.iot.homelab.example | Philips | Hue Go | Sofa-Ecke | Ambientelicht |
| **Samsung TV** | 192.168.101.15 | tv-wz-01.iot.homelab.example | Samsung | QE55Q80A | Wand | Smart TV + Gaming |

### Entertainment-Integration

#### Philips Hue Bridge v2
```yaml
Protokoll: Zigbee 3.0
Max. Geräte: 50 Hue-Geräte
API: RESTful API + WebSocket
Home Assistant: Native Integration
Szenen: Gespeichert auf Bridge
Sync: Hue Sync App für PC/Mac
Third-Party: Kompatibel mit vielen Apps
```

#### Sonos System
```yaml
Audio: Stereo (Alexa Built-in)
Streaming: Spotify, Apple Music, Amazon Music
Multi-Room: Gruppierung mit anderen Sonos
Voice Control: Alexa, Google Assistant
Home Assistant: Native Integration
AirPlay 2: Ja (iPhone/iPad/Mac)
```

#### Samsung Smart TV Integration
```yaml
Betriebssystem: Tizen OS
Home Assistant: Samsung Smart TV Integration
Steuerung: Samsung SmartThings API
HDMI-CEC: Ja (automatisches Ein-/Ausschalten)
Screen Mirroring: Windows, macOS, Android, iOS
Gaming: Auto Game Mode + VRR
```

!!! tip "Szenen-Automatisierung"
    **Filmabend:** TV ein → Hue dimmen → Sonos leise
    **Gaming:** TV Game Mode → Hue Gaming-Szene → Sonos aus
    **Party:** Hue Disco → Sonos laut → TV Musik-Visualizer

## Küche (192.168.101.65 - 192.168.101.126)

### Geräte & Ambiente

| Gerät | IP | DNS-Name | Hersteller | Modell | Position | Funktion |
|-------|----|---------|-----------|---------|---------|---------| 
| **Shelly 1PM Dunstabzug** | 192.168.101.70 | shelly-pro1pm-kueche-01.iot.homelab.example | Allterco | Shelly Pro 1PM | Dunstabzug | Automatische Lüftung |
| **Hue Unterbauleuchte** | 192.168.101.71 | hue-kueche-01.iot.homelab.example | Philips | Hue Lightstrip Plus | Arbeitsplatte | Küchenbeleuchtung |
| **Sonos One SL** | 192.168.101.72 | sonos-kueche-01.iot.homelab.example | Sonos | Sonos One SL | Regal | Küchenmusik |
| **Homematic Temp** | 192.168.101.73 | hm-temp-kueche-01.iot.homelab.example | eQ-3 | HmIP-STH | Küchenschrank | Temperatur/Luftfeuchte |

### Küchenautomatisierung

#### Shelly Pro 1PM (Professional)
```yaml
Schaltung: 230V AC Relais (16A)
Power Monitoring: Echtzeit (Watt, kWh, Spannung)
DIN Rail: Montage in Unterverteilung
MQTT: Enhanced Topics mit Statistiken
Scripting: Lua Scripts on-device
HTTP API: RESTful + WebSocket
Sicherheit: TLS 1.2, Certificate Pinning
```

#### Intelligente Dunstabzug-Steuerung
```yaml
Automatisierung:
  Kochfeld ein: 
    - Trigger: Stromverbrauch > 500W (Herd)
    - Aktion: Dunstabzug Stufe 1 nach 2min
  
  Intensivkkochen:
    - Trigger: Dampf-Sensor (optional)
    - Aktion: Dunstabzug Stufe 2-3
  
  Auto-Aus:
    - Trigger: Kochfeld aus + 10min Nachlauf
    - Aktion: Dunstabzug aus
```

## Bad (192.168.101.129 - 192.168.101.190)

### Lüftung & Überwachung

| Gerät | IP | DNS-Name | Hersteller | Modell | Position | Funktion |
|-------|----|---------|-----------|---------|---------|---------| 
| **Shelly 1 Lüftung** | 192.168.101.135 | shelly-1-bad-01.iot.homelab.example | Allterco | Shelly 1 | Lüfter | Automatische Lüftung |
| **Homematic Feuchte** | 192.168.101.136 | hm-humid-bad-01.iot.homelab.example | eQ-3 | HmIP-STH | Wand | Luftfeuchtigkeitsüberwachung |
| **Hue Spiegellampe** | 192.168.101.137 | hue-bad-01.iot.homelab.example | Philips | Hue White | Spiegel | Funktionale Beleuchtung |

### Bad-Automatisierung

#### Feuchtigkeitsbasierte Lüftung
```yaml
Sensor: HmIP-STH (Temperatur + Luftfeuchte)
Schwellwerte:
  - Normal: < 60% rF
  - Erhöht: 60-75% rF → Lüftung Stufe 1
  - Kritisch: > 75% rF → Lüftung Stufe 2
  
Nachlauf: 15min nach Unterschreitung 65% rF
Manuell: Schalter übersteuert Automatik
```

## Mobile Clients (192.168.101.191 - 192.168.101.230)

### Smartphones & Tablets

| Gerät | IP | DNS-Name | Besitzer | Primäre Apps | Funktion |
|-------|----|---------|---------|-----------|---------| 
| **iPhone Admin** | 192.168.101.200 | iphone-admin-01.iot.homelab.example | Admin | Home Assistant, Hue, Sonos | Hauptsteuerung |
| **iPad Wohnzimmer** | 192.168.101.201 | ipad-wz-01.iot.homelab.example | Familie | Home Assistant Dashboard | Wandmontiertes Control Panel |
| **Android Tablet** | 192.168.101.202 | tablet-android-01.iot.homelab.example | Familie | Küchen-Dashboard, Rezepte | Küchen-Terminal |

### Dashboard-Konfiguration

#### iPad Wohnzimmer (Kiosk-Modus)
```yaml
Hardware: iPad 9th Gen (Wi-Fi)
Montage: Wandhalterung mit Power
Apps: 
  - Home Assistant (Kiosk-Browser)
  - Guided Access (iOS Kiosk-Lock)
Dashboards:
  - Hauptsteuerung (Lichter, Musik, TV)
  - Klimaübersicht (alle Räume)
  - Sicherheitsstatus (Fenster, Türen)
Auto-Sleep: Deaktiviert
Helligkeit: Automatisch (Umgebungssensor)
```

#### Smartphone Home Assistant Apps
```yaml
iOS App: Home Assistant Companion
Features:
  - Push Notifications
  - GPS-Tracking (Home/Away)
  - Shortcuts Integration
  - Widget Support
  - Apple Watch Companion
  
Android App: Home Assistant Companion  
Features:
  - Push Notifications
  - Location Tracking
  - Tasker Integration
  - Widget Support
  - Wear OS Support
```

### Verfügbare Adressen

```yaml
192.168.101.203-230: 28 weitere Mobile-IPs verfügbar
Verwendung:
  - Gäste-Smartphones (temporär)
  - Weitere Tablets/E-Reader
  - Smart Watches
  - Portable Gaming-Geräte
  - IOT-Geräte mit DHCP
```

## Sicherheit & Zugriffskontrolle

### VLAN-Firewall-Regeln

!!! info "IOT → Standard-LAN (Limited Access)"
    **Erlaubte Verbindungen:**
    
    - **Port 53 (DNS):** Zu Pi-hole (192.168.1.3, 192.168.1.4)
    - **Port 123 (NTP):** Zeitserver für Geräte-Synchronisation
    - **Port 8123 (HTTP):** Home Assistant Web-Interface
    - **Port 1883/8883 (MQTT):** MQTT Broker für IOT-Kommunikation
    - **Port 5353 (mDNS):** Device Discovery für Hue, Sonos, etc.

!!! warning "Blockierte Verbindungen"
    **IOT-VLAN kann NICHT zugreifen auf:**
    
    - Proxmox Web-Interface (Port 8006)
    - UniFi Controller (Port 8443)
    - Traefik Dashboard (Port 443)
    - SSH-Zugang zu Servern (Port 22)
    - Docker-APIs (Port 2376/2377)

### Device-Management

#### MAC-Adress-Reservierung
```bash
# UniFi Controller → Settings → Networks → DHCP
# Für kritische IOT-Geräte statische IP-Zuweisung

Homematic CCU: MAC xx:xx:xx:xx:xx:xx → 192.168.100.10
Hue Bridge: MAC xx:xx:xx:xx:xx:xx → 192.168.101.1
Sonos Wohnzimmer: MAC xx:xx:xx:xx:xx:xx → 192.168.101.10
```

#### Device-Tracking
```yaml
Home Assistant Device Tracker:
  - Ping-basiert (alle 30 Sekunden)
  - MQTT Last Will (für MQTT-Geräte)
  - UPnP Discovery (für Sonos, Hue)
  - UniFi Integration (Client-Status)

Alerting bei:
  - Gerät länger als 5min offline
  - Unbekannte Geräte im VLAN
  - Kritische Geräte offline (CCU, Hue Bridge)
```

## Monitoring & Wartung

### Automatisierte Überwachung

```yaml
Home Assistant Automations:
  Battery Monitoring:
    - Homematic Geräte < 20% → Notification
    - Quartalweise Battery-Report
  
  Device Health:
    - Ping-Monitor alle IOT-Geräte
    - MQTT Last-Seen Tracking
    - Firmware-Update Notifications
    
  Performance:
    - Response-Time Monitoring
    - WiFi-Signal-Stärke (UniFi)
    - Netzwerk-Traffic-Analyse
```

### Wartungsroutinen

#### Wöchentlich
```bash
# IOT-Geräte Status-Check
ping -c 1 192.168.100.10  # Homematic CCU
curl -s http://192.168.101.1/api/0/config | jq .name  # Hue Bridge
curl -s http://192.168.101.10:1400/status  # Sonos

# MQTT-Broker Health
mosquitto_pub -h 192.168.1.55 -t test/health -m "check"
mosquitto_sub -h 192.168.1.55 -t test/health -C 1
```

#### Monatlich
```bash
# Firmware-Updates prüfen
# Shelly-Geräte: /ota/update über HTTP API
# Hue: über Hue App oder Home Assistant
# Homematic: über CCU Web-Interface

# Performance-Analyse
# UniFi Controller → Insights → Client Performance
# Home Assistant → Developer Tools → Statistics
```

### Backup-Strategie

```yaml
Homematic CCU:
  - Wöchentlich: Vollbackup über CCU Web-Interface
  - Täglich: Konfiguration via Home Assistant Backup
  
Philips Hue:
  - Szenen und Geräte: Automatisch via Home Assistant
  - Bridge-Backup: Hue App → Sicherung & Wiederherstellung
  
Shelly-Geräte:
  - Konfiguration: HTTP API Export
  - Settings: Home Assistant YAML-Backup
```

## Aufwandsschätzung

| Aktivität | Zeitaufwand | Häufigkeit | Komplexität |
|-----------|-------------|------------|-------------|
| **Initiale IOT-Setup** | 6-10 Stunden | Einmalig | Mittel |
| **Gerät hinzufügen** | 15-30 Minuten | Nach Bedarf | Niedrig |
| **Firmware-Updates** | 1-2 Stunden | Monatlich | Niedrig |
| **Automatisierung erstellen** | 30-60 Minuten | Nach Bedarf | Mittel |
| **Troubleshooting** | 15-45 Minuten | Nach Bedarf | Mittel |
| **Performance-Tuning** | 2-3 Stunden | Halbjährlich | Hoch |

**Gesamtaufwand:** ~3-4 Stunden/Monat für IOT-VLAN Betrieb und Erweiterungen.

!!! success "Skalierungsempfehlungen"
    Das IOT-VLAN ist für bis zu 1000 Geräte ausgelegt. Bei mehr als 100 aktiven Geräten sollten folgende Optimierungen implementiert werden:
    
    - **Zusätzliche Access Points** für bessere WiFi-Abdeckung
    - **MQTT-Broker Clustering** für höhere Verfügbarkeit  
    - **Separate Hue Bridges** pro Raum (max. 50 Geräte/Bridge)
    - **Dedizierte IOT-Switches** mit POE+ für kabelgebundene Geräte
