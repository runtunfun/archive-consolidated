# IOT-Netzwerk Dokumentation

## Allgemeine Netzwerkkonfiguration

**VLAN ID:** 10 (IOT-VLAN)  
**Subnetz:** 192.168.10.0/22  
**Gateway:** 192.168.10.1  
**DNS:** 192.168.10.1, 8.8.8.8  
**DHCP-Bereich:** 192.168.12.1 - 192.168.12.254 (für automatische Zuweisung)

## Raumaufteilung und IP-Bereiche

| Raum | IP-Bereich | Anzahl IPs | Verwendung |
|------|------------|------------|------------|
| Unterverteilung | 192.168.10.1 - 192.168.10.62 | 62 | Zentrale Steuergeräte, Homematic CCU |
| Flur | 192.168.10.65 - 192.168.10.126 | 62 | Shelly Schalter, Homematic Sensoren |
| Arbeitszimmer | 192.168.10.129 - 192.168.10.190 | 62 | Shelly Relais, Hue Arbeitsplatz |
| Schlafzimmer | 192.168.10.193 - 192.168.10.254 | 62 | Hue Lampen, Klimasensoren, Jalousien |
| Wohnzimmer | 192.168.11.1 - 192.168.11.62 | 62 | Hue Lampen, Sonos Lautsprecher, TV-Geräte |
| Küche | 192.168.11.65 - 192.168.11.126 | 62 | Küchengeräte, Sonos, Hue Unterschrank |
| Bad | 192.168.11.129 - 192.168.11.190 | 62 | Feuchtigkeitssensoren, Lüftungssteuerung |
| Reserve | 192.168.11.193 - 192.168.13.254 | 574 | Für zukünftige Erweiterungen |

## DNS-Naming-Konvention

**Schema:** `[geraetetype]-[raum]-[nummer].iot.local`

### Gerätetypen (Präfixe)

#### Technische Geräte (detailliert)
- **shelly-dimmer-** : Shelly Dimmer
- **shelly-pro1pm-** : Shelly Pro 1PM (mit Leistungsmessung)
- **shelly-1-** : Shelly 1 (Relais)
- **shelly-button1-** : Shelly Button1
- **shelly-flood-** : Shelly Flood Sensor
- **hm-window-** : Homematic Fensterkontakt
- **hm-motion-** : Homematic Bewegungsmelder
- **hm-thermo-** : Homematic Thermostat
- **hm-temp-** : Homematic Temperatursensor
- **hm-humid-** : Homematic Feuchtigkeitssensor
- **hm-smoke-** : Homematic Rauchmelder

#### Consumer-Geräte (einfach)
- **hue-** : Philips Hue Lampen, Sensoren, Bridge
- **sonos-** : Sonos Lautsprecher

#### Infrastruktur
- **switch-** : Netzwerk-Switches
- **ap-** : Access Points

### Raum-Abkürzungen
- **flur** : Flur
- **wz** : Wohnzimmer
- **sz** : Schlafzimmer
- **az** : Arbeitszimmer
- **bad** : Bad
- **kueche** : Küche
- **uv** : Unterverteilung

### Beispiele
```
shelly-dimmer-flur-01.iot.local    → Shelly Dimmer im Flur
shelly-pro1pm-kueche-01.iot.local  → Shelly Pro 1PM in der Küche
hue-wz-03.iot.local                → Hue Lampe im Wohnzimmer
sonos-kueche-01.iot.local          → Sonos in der Küche
hm-temp-sz-01.iot.local            → Homematic Temperatursensor Schlafzimmer
hm-window-sz-01.iot.local          → Homematic Fensterkontakt Schlafzimmer
```

## UniFi-spezifische Konfiguration

### VLAN-Einstellungen
1. **Netzwerk erstellen:**
   - Name: "IOT-VLAN"
   - VLAN ID: 10
   - Subnetz: 192.168.10.0/22
   - DHCP aktivieren: Ja (für Fallback)

2. **WiFi-Netzwerk:**
   - Name: "IOT-WiFi"
   - Sicherheit: WPA2/WPA3
   - VLAN: IOT-VLAN (10)
   - Gast-Isolation: Aktiviert

3. **Firewall-Regeln:**
   - IOT → Internet: Erlaubt
   - IOT → Hauptnetzwerk: Blockiert
   - Hauptnetzwerk → IOT: Nur spezifische Ports (Admin)

### DHCP-Reservierungen
Für wichtige Geräte statische IP-Adressen vergeben:
```
Homematic CCU: 192.168.10.10 → hm-ccu-uv-01.iot.local
Hue Bridge: 192.168.11.1 → hue-wz-bridge01.iot.local
Sonos Bridge: 192.168.11.2 → sonos-wz-bridge01.iot.local
```

## Geräte-Inventar

### Unterverteilung (192.168.10.1 - 192.168.10.62)
| Gerät | IP | DNS-Name | MAC | Notizen |
|-------|----|---------|----|---------|
| Homematic CCU | 192.168.10.10 | hm-ccu-uv-01.iot.local | - | Zentrale |
| UniFi Switch | 192.168.10.11 | switch-uv-01.iot.local | - | Hauptverteiler |

### Flur (192.168.10.65 - 192.168.10.126)
| Gerät | IP | DNS-Name | MAC | Notizen |
|-------|----|---------|----|---------|
| Shelly 1 (Deckenlampe) | 192.168.10.70 | shelly-1-flur-01.iot.local | - | Hauptlicht |
| Homematic Bewegungsmelder | 192.168.10.71 | hm-motion-flur-01.iot.local | - | Eingang |

### Arbeitszimmer (192.168.10.129 - 192.168.10.190)
| Gerät | IP | DNS-Name | MAC | Notizen |
|-------|----|---------|----|---------|
| Shelly Dimmer | 192.168.10.135 | shelly-dimmer-az-01.iot.local | - | Schreibtischlampe |
| Hue Strip | 192.168.10.136 | hue-az-01.iot.local | - | Monitor-Backlight |

### Schlafzimmer (192.168.10.193 - 192.168.10.254)
| Gerät | IP | DNS-Name | MAC | Notizen |
|-------|----|---------|----|---------|
| Hue Lampe Links | 192.168.10.200 | hue-sz-01.iot.local | - | Nachttischlampe |
| Hue Lampe Rechts | 192.168.10.201 | hue-sz-02.iot.local | - | Nachttischlampe |
| Homematic Fensterkontakt | 192.168.10.202 | hm-window-sz-01.iot.local | - | Fenster Straßenseite |

### Wohnzimmer (192.168.11.1 - 192.168.11.62)
| Gerät | IP | DNS-Name | MAC | Notizen |
|-------|----|---------|----|---------|
| Hue Bridge | 192.168.11.1 | hue-wz-bridge01.iot.local | - | Zentrale Bridge |
| Sonos One | 192.168.11.10 | sonos-wz-01.iot.local | - | Musikwiedergabe |
| Hue Deckenlampe | 192.168.11.11 | hue-wz-01.iot.local | - | Hauptbeleuchtung |
| Hue Stehlampe | 192.168.11.12 | hue-wz-02.iot.local | - | Ambientelicht |

### Küche (192.168.11.65 - 192.168.11.126)
| Gerät | IP | DNS-Name | MAC | Notizen |
|-------|----|---------|----|---------|
| Shelly 1PM (Dunstabzug) | 192.168.11.70 | shelly-pro1pm-kueche-01.iot.local | - | Dunstabzugsteuerung |
| Hue Unterbauleuchte | 192.168.11.71 | hue-kueche-01.iot.local | - | Arbeitsplatte |
| Sonos One SL | 192.168.11.72 | sonos-kueche-01.iot.local | - | Küchenmusik |
| Homematic Temperatursensor | 192.168.11.73 | hm-temp-kueche-01.iot.local | - | Raumtemperatur |

### Bad (192.168.11.129 - 192.168.11.190)
| Gerät | IP | DNS-Name | MAC | Notizen |
|-------|----|---------|----|---------|
| Shelly 1 (Lüftung) | 192.168.11.135 | shelly-1-bad-01.iot.local | - | Lüftungssteuerung |
| Homematic Feuchtigkeitssensor | 192.168.11.136 | hm-humid-bad-01.iot.local | - | Luftfeuchtigkeit |
| Hue Spiegellampe | 192.168.11.137 | hue-bad-01.iot.local | - | Spiegelbeleuchtung |

*[Weitere Räume nach gleichem Schema]*

## Wartungshinweise

- **Backup-Intervall:** Wöchentlich (UniFi Controller)
- **Update-Fenster:** Sonntag 02:00-04:00 Uhr
- **Monitoring:** Ping-Tests alle 5 Minuten
- **Dokumentation aktualisieren:** Bei jeder Geräteerweiterung

## Troubleshooting

### Häufige Probleme
1. **Gerät nicht erreichbar:**
   - VLAN-Zuordnung prüfen
   - DHCP-Lease erneuern
   - Firewall-Regeln überprüfen

2. **DNS-Auflösung funktioniert nicht:**
   - Controller-DNS-Einstellungen prüfen
   - mDNS-Reflector aktivieren

3. **Schlechte Performance:**
   - Bandbreiten-Limits prüfen
   - QoS-Einstellungen anpassen

---
**Erstellt:** [Datum]  
**Letzte Aktualisierung:** [Datum]  
**Version:** 1.0