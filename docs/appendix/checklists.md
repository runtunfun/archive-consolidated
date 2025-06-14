# Checklisten

## Backup-Checklisten

### Tägliche Backups (Automatisiert)

!!! info "Automatisierung"
    Diese Backups laufen automatisch via Cron-Jobs und Docker-Health-Checks.

- [ ] **Home Assistant Konfiguration**
    - Automatisches Backup via HA-Addon
    - Speicherort: `/config/backups/`
    - Retention: 7 Tage lokal

- [ ] **Docker Container Logs**
    - Zentrales Logging via Loki
    - Rotation: 1GB oder 7 Tage
    - Alert bei Log-Fehlern

- [ ] **System-Metriken**
    - InfluxDB: Performance-Daten
    - Prometheus: Hardware-Monitoring
    - Retention: 30 Tage

```bash
# Cron-Eintrag für tägliche HA-Backups
0 2 * * * cd /opt/homelab/homeassistant && docker-compose exec homeassistant ha backup create
```

**Aufwand:** Einmalig 30min Setup, dann automatisch

### Wöchentliche Backups (Semi-Automatisiert)

!!! warning "Manuelle Kontrolle erforderlich"
    Diese Backups benötigen regelmäßige Überprüfung.

#### Secrets & Konfiguration

- [ ] **Environment-Dateien sichern**
    ```bash
    # Ausführen: Sonntag 03:00 Uhr
    /opt/homelab/scripts/backup-secrets.sh
    ```
    - Alle `.env` Dateien verschlüsselt
    - GPG-Verschlüsselung mit Master-Passwort
    - Speicherort: `/opt/homelab/secrets/encrypted-backups/`

- [ ] **Docker-Volumes sichern**
    ```bash
    # Ausführen: Sonntag 02:00 Uhr
    docker run --rm -v /var/lib/docker/volumes:/source \
      -v /opt/homelab/backup:/backup alpine \
      tar czf /backup/docker-volumes-$(date +%Y%m%d).tar.gz -C /source .
    ```

- [ ] **UniFi Controller Konfiguration**
    - Manuell via Controller-Interface
    - Settings → System → Backup
    - Download und sichere Speicherung

#### Status-Überprüfung

- [ ] **Pi-hole Synchronisation** (bei 2 Pis)
    ```bash
    # Gravity Sync Status prüfen
    docker exec dns-stack_gravity-sync_1 gravity-sync compare
    ```

- [ ] **Zertifikat-Status**
    ```bash
    # Let's Encrypt Zertifikate prüfen
    docker exec traefik_traefik_1 cat /letsencrypt/acme.json | jq '.netcup'
    ```

- [ ] **Service-Health-Check**
    ```bash
    # Alle Services erreichbar?
    /opt/homelab/scripts/health-check.sh
    ```

**Aufwand:** ~30 Minuten pro Woche

### Monatliche Backups (Manuell)

#### Vollständige System-Sicherung

- [ ] **GPG-Key Backup erstellen**
    ```bash
    /opt/homelab/scripts/backup-gpg-keys.sh
    ```
    - Private und Public Keys
    - Trust-Database
    - Revocation-Certificate

- [ ] **Proxmox Cluster Backup** (falls vorhanden)
    - VM-Snapshots aller kritischen VMs
    - Proxmox-Konfiguration exportieren
    - Storage-Health prüfen

- [ ] **Dokumentation aktualisieren**
    - IP-Adress-Inventar überprüfen
    - Passwort-Änderungen dokumentieren
    - Neue Services in URL-Liste

#### Externe Speicherung

- [ ] **Cloud-Upload**
    ```bash
    # Beispiel mit rclone
    rclone copy /opt/homelab/secrets/encrypted-backups/ \
      nextcloud:homelab-backups/
    ```

- [ ] **USB-Stick Backup**
    - Verschlüsselte Backup-Dateien
    - Hardware-Rotation (2 USB-Sticks)
    - Sichere physische Aufbewahrung

- [ ] **Offsite-Backup** (quartalsweise)
    - Kopie bei Vertrauensperson
    - Separates Master-Passwort-Dokument
    - Recovery-Test durchführen

**Aufwand:** ~2 Stunden pro Monat

### Backup-Restore Test (Halbjährlich)

!!! danger "Kritisch"
    Ungetestete Backups sind wertlos. Regelmäßige Recovery-Tests sind essentiell.

#### Test-Environment Setup

- [ ] **Separate Test-Hardware vorbereiten**
    - Raspberry Pi (für DNS-Test)
    - Test-Server (für Docker Services)
    - Isoliertes Test-VLAN

- [ ] **Recovery-Procedure testen**
    ```bash
    # GPG-Keys wiederherstellen
    ./scripts/restore-gpg-keys.sh
    
    # Secrets entschlüsseln
    gpg -d secrets-backup.tar.gz.gpg | tar -xz
    
    # Services neu deployen
    cd dns-stack && docker-compose up -d
    ```

- [ ] **Funktions-Tests**
    - DNS-Auflösung funktional
    - Home Assistant startet mit alter Konfiguration
    - Monitoring-Daten korrekt
    - IOT-Geräte-Integration

#### Recovery-Dokumentation

- [ ] **Recovery-Zeit messen**
    - Ziel: < 4 Stunden kompletter Restore
    - Bottlenecks identifizieren
    - Verbesserungen dokumentieren

- [ ] **Recovery-Anleitung aktualisieren**
    - Step-by-step Procedure
    - Häufige Probleme und Lösungen
    - Kontakt-Informationen für Notfall

**Aufwand:** ~4-6 Stunden pro Test

## Sicherheits-Checklisten

### Netzwerk-Sicherheit

#### VLAN-Konfiguration

- [ ] **VLAN-Segmentierung aktiv**
    - Standard-LAN: 192.168.1.0/24
    - IOT-VLAN: 192.168.100.0/22
    - Gäste-VLAN: 192.168.200.0/24

- [ ] **Firewall-Regeln minimal**
    ```bash
    # UniFi Zone-Matrix prüfen
    # Standard → IOT: Limited Access (nur benötigte Ports)
    # IOT → Standard: Limited Access (DNS, NTP)
    # Gäste → Standard: Blocked (außer DNS)
    # Gäste → IOT: Blocked
    ```

- [ ] **Inter-VLAN Routing kontrolliert**
    - Nur explizit erlaubte Verbindungen
    - Logging von blockierten Zugriffen
    - Regelmäßige Review der Firewall-Logs

#### WiFi-Sicherheit

- [ ] **WiFi-Standards**
    - WPA3 (oder WPA2 falls WPA3 nicht verfügbar)
    - Starke Passwörter (min. 20 Zeichen)
    - Passwort-Rotation alle 6 Monate

- [ ] **Gäste-Isolation**
    - Client-Isolation aktiviert
    - Bandbreiten-Limit (optional)
    - Zeit-basierte Zugriffskontrolle

- [ ] **Management-Zugang**
    - Separate SSID für Management (optional)
    - MAC-Adress-Filterung für Admin-Geräte
    - VPN-Zugang für Remote-Management

**Aufwand:** ~45 Minuten monatlich

### Service-Sicherheit

#### Authentifizierung & Autorisierung

- [ ] **Starke Passwörter**
    - Mindestens 16 Zeichen
    - Gemischte Zeichen (Groß, Klein, Zahlen, Sonderzeichen)
    - Unique pro Service
    - Passwort-Manager verwenden

- [ ] **2FA aktiviert** (wo möglich)
    - Home Assistant: TOTP
    - UniFi Controller: 2FA
    - Proxmox: 2FA
    - Cloud-Services: 2FA

- [ ] **Service-Accounts**
    - Separate Accounts für Services
    - Minimale Berechtigungen (Principle of Least Privilege)
    - Service-Account-Rotation halbjährlich

#### HTTPS & Zertifikate

- [ ] **SSL/TLS überall**
    - Alle Web-Services über HTTPS
    - Let's Encrypt Wildcard-Zertifikate
    - Automatische Erneuerung funktional

- [ ] **Zertifikat-Monitoring**
    ```bash
    # Zertifikat-Ablauf prüfen
    openssl s_client -connect ha-prod-01.lab.enzmann.online:443 \
      -servername ha-prod-01.lab.enzmann.online | \
      openssl x509 -noout -dates
    ```

- [ ] **SSL-Labs Test** (falls extern erreichbar)
    - A+ Rating anstreben
    - Schwache Cipher deaktiviert
    - HSTS-Header aktiv

#### Container-Sicherheit

- [ ] **Image-Updates**
    - Wöchentliche Image-Updates
    - Security-Patches zeitnah
    - Image-Vulnerability-Scans

- [ ] **Non-Root Container**
    - Services laufen als Non-Root User
    - Read-Only Filesystems wo möglich
    - Capabilities-Dropping

- [ ] **Network-Isolation**
    - Services nur in notwendigen Networks
    - Minimale Port-Exposition
    - Internal-Only für Backend-Services

**Aufwand:** ~1 Stunde monatlich

### Zugriffskontrollen

#### SSH-Sicherheit

- [ ] **SSH-Key Authentication**
    - Passwort-Login deaktiviert
    - ED25519 oder RSA-4096 Keys
    - Key-Rotation jährlich

- [ ] **SSH-Härtung**
    ```bash
    # /etc/ssh/sshd_config
    PermitRootLogin no
    PasswordAuthentication no
    PubkeyAuthentication yes
    Protocol 2
    ```

- [ ] **SSH-Monitoring**
    - Failed-Login-Attempts loggen
    - Fail2ban für Brute-Force-Schutz
    - Unusual-Login-Pattern Detection

#### Physical Security

- [ ] **Hardware-Zugang**
    - Server in abschließbarem Schrank/Raum
    - USV für kritische Komponenten
    - Temperatur-Monitoring

- [ ] **Backup-Medium-Sicherheit**
    - USB-Sticks verschlüsselt
    - Sichere physische Aufbewahrung
    - Access-Log für Backup-Zugriffe

**Aufwand:** ~30 Minuten monatlich

### Incident Response

#### Monitoring & Alerting

- [ ] **Security-Monitoring aktiv**
    - Failed-Login-Attempts
    - Unusual Network Traffic
    - Service-Downtimes
    - Certificate-Expiry

- [ ] **Incident-Response-Plan**
    - Kontakt-Informationen aktuell
    - Escalation-Procedures dokumentiert
    - Recovery-Procedures getestet

- [ ] **Log-Aggregation**
    - Zentrale Log-Collection (Loki)
    - Log-Retention-Policy
    - Automated Log-Analysis

#### Vulnerability Management

- [ ] **Security-Scans** (monatlich)
    ```bash
    # Netzwerk-Scan von externem Host
    nmap -sC -sV 192.168.1.0/24
    
    # Docker-Vulnerability-Scan
    docker scan <image-name>
    
    # System-Updates prüfen
    apt list --upgradable
    ```

- [ ] **Penetration Testing** (halbjährlich)
    - Externe Security-Assessment
    - Web-Application Security Testing
    - Network-Segmentation Testing

**Aufwand:** ~2 Stunden monatlich

## Update-Checklisten

### Infrastruktur-Updates

#### Pre-Update Vorbereitung

- [ ] **Backup erstellen**
    ```bash
    # Vollständiges Backup vor kritischen Updates
    /opt/homelab/scripts/backup-secrets.sh
    ```

- [ ] **Maintenance-Window planen**
    - Zeitfenster: Sonntag 02:00-06:00 Uhr
    - Stakeholder informieren
    - Rollback-Plan vorbereiten

- [ ] **Change-Management**
    - Update-Changelog erstellen
    - Risiko-Assessment durchführen
    - Go/No-Go Decision dokumentieren

#### Update-Reihenfolge

1. **Pi-hole/DNS** (Kritisch, zuerst)
    ```bash
    cd /opt/homelab/dns-stack
    docker-compose pull
    docker-compose up -d
    ```

2. **UniFi Controller**
    - Backup via Web-Interface
    - Controller-Update via Interface
    - Neustart aller UniFi-Geräte

3. **Proxmox** (falls vorhanden)
    ```bash
    apt update && apt upgrade
    pveam update
    ```

4. **Docker Services**
    ```bash
    docker service update --image <new-image> <service>
    ```

#### Post-Update Validation

- [ ] **Funktions-Tests**
    ```bash
    # DNS-Resolution
    nslookup ha-prod-01.lab.enzmann.online 192.168.1.3
    
    # Service-Availability
    curl -k https://ha-prod-01.lab.enzmann.online
    
    # IOT-Device-Connectivity
    # Home Assistant → Developer Tools → Services → device_tracker.see
    ```

- [ ] **Performance-Check**
    - Service-Response-Times
    - Resource-Utilization
    - Error-Logs Review

- [ ] **Rollback-Preparedness**
    ```bash
    # Rollback-Commands vorbereitet für Notfall
    docker service update --image <previous-image> <service>
    ```

**Aufwand:** ~2-3 Stunden pro Update-Zyklus

### Service-Updates

#### Weekly Service Updates

- [ ] **Home Assistant**
    ```bash
    # Release Notes prüfen
    curl -s https://api.github.com/repos/home-assistant/core/releases/latest | jq '.tag_name'
    
    # Update durchführen
    docker service update --image homeassistant/home-assistant:latest homeassistant_homeassistant
    ```

- [ ] **Pi-hole**
    ```bash
    cd /opt/homelab/dns-stack
    docker-compose pull pihole
    docker-compose up -d pihole
    ```

- [ ] **Monitoring Stack**
    ```bash
    # Grafana, InfluxDB, Prometheus Updates
    docker stack deploy --prune -c docker-compose.yml monitoring
    ```

#### IOT-Device Updates

- [ ] **Firmware-Updates planen**
    - Hersteller-Release-Notes prüfen
    - Home Assistant Kompatibilität verifizieren
    - Rolling-Updates (nicht alle gleichzeitig)

- [ ] **Shelly-Geräte**
    ```bash
    # Via Shelly Cloud oder lokale Web-Interfaces
    # Automatische Update-Benachrichtigung in HA
    ```

- [ ] **Homematic-Geräte**
    ```bash
    # Via CCU Web-Interface
    # System-Control → Firmware-Updates
    ```

**Aufwand:** ~1 Stunde wöchentlich

## Monitoring-Checklisten

### Performance-Monitoring

#### System-Resources

- [ ] **CPU-Auslastung** (< 70% Average)
    ```bash
    # Grafana Dashboard: "System Overview"
    # Alert bei > 80% für > 5 Minuten
    ```

- [ ] **Memory-Usage** (< 80%)
    ```bash
    # Docker Stats
    docker stats --no-stream
    
    # System Memory
    free -h
    ```

- [ ] **Disk-Space** (< 85%)
    ```bash
    # Docker Volume Usage
    docker system df
    
    # Host Disk Usage
    df -h
    ```

- [ ] **Network-Throughput**
    ```bash
    # UniFi Controller → Insights → Bandwidth
    # Inter-VLAN Traffic Analysis
    ```

#### Service-Health

- [ ] **Response-Times**
    - Home Assistant: < 2 Sekunden
    - Pi-hole: < 50ms
    - Grafana: < 1 Sekunde
    - Traefik: < 100ms

- [ ] **Availability**
    - Critical Services: 99.9% Uptime
    - Important Services: 99.5% Uptime
    - Optional Services: 99% Uptime

- [ ] **Error-Rates**
    ```bash
    # HTTP 5xx Errors < 0.1%
    # Docker Restart-Loops: 0
    # DNS-Query-Failures < 0.01%
    ```

#### IOT-Device Health

- [ ] **Device-Connectivity**
    ```bash
    # Home Assistant Device Tracker
    # Ping-basierte Überwachung alle 5 Minuten
    ```

- [ ] **Battery-Status**
    - Batterie-Sensoren < 20% → Alert
    - Trend-Analysis für Battery-Drain
    - Proaktive Replacement-Planung

- [ ] **Signal-Quality**
    - WiFi RSSI > -70 dBm
    - Zigbee LQI > 200
    - Z-Wave Signal-Strength > 3/5

**Aufwand:** ~30 Minuten täglich (automatisiert + manuelle Kontrolle)

### Alerting-Konfiguration

#### Critical Alerts (Sofort)

- [ ] **DNS-Service Down**
    ```yaml
    # Prometheus Alert
    - alert: DNSServiceDown
      expr: up{job="pihole"} == 0
      for: 30s
    ```

- [ ] **Home Assistant Unavailable**
    ```yaml
    - alert: HomeAssistantDown
      expr: up{job="homeassistant"} == 0
      for: 2m
    ```

- [ ] **Security-Incidents**
    - Multiple Failed-Logins
    - Unauthorized Network Access
    - Certificate Expiry < 7 days

#### Warning Alerts (Binnen 4 Stunden)

- [ ] **High Resource Usage**
    - CPU > 80% for 10 minutes
    - Memory > 85% for 10 minutes
    - Disk > 90% for 5 minutes

- [ ] **Performance Degradation**
    - Response-Time > 2x Baseline
    - Error-Rate > 1%
    - Failed Health-Checks

#### Info Alerts (Binnen 24 Stunden)

- [ ] **Maintenance Required**
    - Security-Updates available
    - Log-Rotation needed
    - Configuration-Drift detected

**Aufwand:** Einmalig 2 Stunden Setup, dann automatisch

## Compliance & Dokumentation

### Change-Management

- [ ] **Infrastructure Changes**
    - Alle Änderungen in Git dokumentiert
    - Peer-Review für kritische Changes
    - Rollback-Plan für alle Changes

- [ ] **Configuration Management**
    - Infrastructure as Code
    - Versionierte Konfigurationsdateien
    - Automated Configuration-Drift Detection

### Audit-Trail

- [ ] **Access-Logs**
    - Wer hat wann auf welche Services zugegriffen
    - Administrative Actions geloggt
    - Log-Integrity-Schutz

- [ ] **Change-Logs**
    - Software-Updates dokumentiert
    - Configuration-Changes nachverfolgbar
    - Security-Incident-Logs

**Aufwand:** ~1 Stunde pro Woche für Dokumentation

!!! success "Checklisten-System etabliert"
    Mit diesen Checklisten ist ein strukturiertes und sicheres Homelab-Management gewährleistet.
