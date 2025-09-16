# Backup & Recovery

## Backup-Strategien

!!! info "3-2-1 Backup-Regel"
    - **3** Kopien der Daten (Original + 2 Backups)
    - **2** verschiedene Medientypen (lokal + extern)
    - **1** Offsite-Backup (Cloud, externe Aufbewahrung)

### Backup-Frequenzen

Die Homelab-Infrastruktur implementiert gestaffelte Backup-Zyklen je nach Kritikalität und Änderungsfrequenz der Daten:

| Kategorie | Häufigkeit | Automatisierung | Aufbewahrung |
|-----------|------------|-----------------|--------------|
| **Secrets & Configs** | Wöchentlich | Cron | 6 Monate |
| **Docker Volumes** | Täglich | Cron | 4 Wochen |
| **System Snapshots** | Monatlich | Proxmox | 3 Monate |
| **GPG Keys** | Monatlich | Manuell | Permanent |
| **Externe Kopien** | Quartalsweise | Manuell | Permanent |

## Automatisierte Backup-Scripts

### Wöchentliches Secrets-Backup

Erstellen Sie einen Cron-Job für automatisierte Secrets-Backups:

```bash title="Crontab-Einträge"
# Wöchentliches Secrets-Backup (Sonntag 03:00)
0 3 * * 0 /opt/homelab/scripts/backup-secrets.sh

# Monatliches GPG-Key-Backup (1. des Monats, 03:00)
0 3 1 * * /opt/homelab/scripts/backup-gpg-keys.sh

# Tägliches Docker-Volume-Backup (02:00)
0 2 * * * /opt/homelab/scripts/backup-docker-volumes.sh
```

### Docker-Volume Backup Script

```bash title="/opt/homelab/scripts/backup-docker-volumes.sh"
#!/bin/bash

BACKUP_DIR="/opt/homelab/backup"
DATE=$(date +%Y%m%d)
RETENTION_DAYS=30

echo "🗂️ Erstelle Docker Volume Backup..."

# Backup-Verzeichnis erstellen
mkdir -p "$BACKUP_DIR"

# Docker Volumes sichern
docker run --rm \
    -v /var/lib/docker/volumes:/source:ro \
    -v "$BACKUP_DIR:/backup" \
    alpine \
    tar czf "/backup/docker-volumes-$DATE.tar.gz" -C /source .

# Alte Backups aufräumen (älter als RETENTION_DAYS)
find "$BACKUP_DIR" -name "docker-volumes-*.tar.gz" -mtime +$RETENTION_DAYS -delete

echo "✅ Docker Volume Backup erstellt: docker-volumes-$DATE.tar.gz"
echo "🗑️  Backups älter als $RETENTION_DAYS Tage wurden gelöscht"
```

### Home Assistant Backup Script

```bash title="/opt/homelab/scripts/backup-homeassistant.sh"
#!/bin/bash

HA_CONTAINER=$(docker ps -q -f name=homeassistant)
BACKUP_DIR="/opt/homelab/backup/homeassistant"
DATE=$(date +%Y%m%d-%H%M)

echo "🏠 Erstelle Home Assistant Backup..."

if [ -z "$HA_CONTAINER" ]; then
    echo "❌ Home Assistant Container nicht gefunden"
    exit 1
fi

# Backup-Verzeichnis erstellen
mkdir -p "$BACKUP_DIR"

# Home Assistant Backup erstellen (über API)
docker exec "$HA_CONTAINER" \
    curl -X POST \
    -H "Authorization: Bearer $HA_LONG_LIVED_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"name": "automated-backup-'$DATE'"}' \
    http://localhost:8123/api/services/backup/create

# Config-Verzeichnis zusätzlich sichern
docker run --rm \
    -v homeassistant_ha_config:/source:ro \
    -v "$BACKUP_DIR:/backup" \
    alpine \
    tar czf "/backup/ha-config-$DATE.tar.gz" -C /source .

echo "✅ Home Assistant Backup erstellt"
```

### System-Level Backup Script

```bash title="/opt/homelab/scripts/backup-system.sh"
#!/bin/bash

BACKUP_DIR="/opt/homelab/backup/system"
DATE=$(date +%Y%m%d)

echo "⚙️ Erstelle System-Backup..."

mkdir -p "$BACKUP_DIR"

# Wichtige System-Konfigurationen sichern
tar czf "$BACKUP_DIR/system-config-$DATE.tar.gz" \
    /etc/systemd/system/*.service \
    /etc/cron.d/* \
    /etc/docker/daemon.json \
    /opt/homelab/scripts/ \
    2>/dev/null

# Docker Compose Files sichern
tar czf "$BACKUP_DIR/docker-configs-$DATE.tar.gz" \
    --exclude='*.env' \
    /opt/homelab/*/docker-compose.yml \
    /opt/homelab/*/*.conf \
    2>/dev/null

# Netzwerk-Konfiguration sichern
cp /etc/netplan/*.yaml "$BACKUP_DIR/netplan-$DATE.yaml" 2>/dev/null

echo "✅ System-Backup erstellt"
```

## Externe Backup-Strategien

### Cloud-Storage Integration

```bash title="rclone-Konfiguration für Nextcloud"
# rclone installieren
curl https://rclone.org/install.sh | sudo bash

# Nextcloud konfigurieren
rclone config

# Automatischer Upload der verschlüsselten Backups
rclone copy /opt/homelab/secrets/encrypted-backups/ nextcloud:homelab-backups/ --progress
```

```bash title="/opt/homelab/scripts/upload-backups.sh"
#!/bin/bash

REMOTE_NAME="nextcloud"
LOCAL_PATH="/opt/homelab/secrets/encrypted-backups/"
REMOTE_PATH="homelab-backups/"

echo "☁️ Uploade Backups zu Cloud-Storage..."

# Prüfen ob rclone konfiguriert ist
if ! rclone listremotes | grep -q "$REMOTE_NAME"; then
    echo "❌ Remote '$REMOTE_NAME' nicht konfiguriert"
    echo "   Führe aus: rclone config"
    exit 1
fi

# Upload der verschlüsselten Backups
rclone copy "$LOCAL_PATH" "$REMOTE_NAME:$REMOTE_PATH" \
    --progress \
    --exclude "*.tmp" \
    --max-age 7d

echo "✅ Cloud-Upload abgeschlossen"
```

### USB-Backup Automatisierung

```bash title="/opt/homelab/scripts/usb-backup.sh"
#!/bin/bash

USB_MOUNT="/media/usb-backup"
SOURCE_DIR="/opt/homelab/secrets/encrypted-backups"

echo "💾 USB-Backup wird erstellt..."

# Prüfen ob USB-Stick gemountet ist
if [ ! -d "$USB_MOUNT" ]; then
    echo "❌ USB-Stick nicht gefunden unter $USB_MOUNT"
    echo "   Stecke USB-Stick ein und mounte unter $USB_MOUNT"
    exit 1
fi

# Verfügbaren Speicherplatz prüfen
AVAILABLE=$(df "$USB_MOUNT" | awk 'NR==2 {print $4}')
NEEDED=$(du -s "$SOURCE_DIR" | awk '{print $1}')

if [ "$AVAILABLE" -lt "$NEEDED" ]; then
    echo "❌ Nicht genügend Speicherplatz auf USB-Stick"
    echo "   Benötigt: ${NEEDED}KB, Verfügbar: ${AVAILABLE}KB"
    exit 1
fi

# Backup kopieren
rsync -av --progress "$SOURCE_DIR/" "$USB_MOUNT/homelab-backups/"

echo "✅ USB-Backup abgeschlossen"
```

## Recovery-Prozeduren

### Komplette System-Wiederherstellung

!!! warning "Recovery-Vorbereitung"
    Testen Sie Recovery-Prozeduren regelmäßig auf einem separaten System. Ein nicht getesteter Backup ist kein Backup.

#### Schritt 1: Basis-System vorbereiten

```bash title="Neue Hardware-Einrichtung"
# 1. Ubuntu Server installieren
# 2. Updates einspielen
sudo apt update && sudo apt upgrade -y

# 3. Docker installieren
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# 4. Git-Repository klonen
sudo mkdir -p /opt/homelab
sudo chown -R $USER:$USER /opt/homelab
cd /opt/homelab
git clone <your-homelab-repo> .
```

#### Schritt 2: GPG-Keys wiederherstellen

```bash title="GPG-Recovery"
# Verschlüsselte Key-Backups von externem Medium holen
# (Cloud, USB-Stick, etc.)

# GPG-Backup entschlüsseln
gpg -d gpg-backup-20241215.tar.gz.gpg | tar -xz -C /opt/homelab/secrets/gpg-keys/

# Keys importieren
/opt/homelab/scripts/restore-gpg-keys.sh

# Funktionstest
gpg --list-secret-keys
```

#### Schritt 3: Secrets wiederherstellen

```bash title="Secrets-Recovery"
# Secrets-Backup entschlüsseln und extrahieren
gpg -d secrets-20241215.tar.gz.gpg | tar -xz -C /

# Environment-Setup ausführen
/opt/homelab/scripts/init-environment.sh

# Berechtigungen setzen
find /opt/homelab -name ".env" -exec chmod 600 {} \;
```

#### Schritt 4: Services starten

```bash title="Service-Wiederherstellung"
# Docker Swarm initialisieren
docker swarm init --advertise-addr <your-ip>

# Networks erstellen
docker network create --driver overlay traefik
docker network create --driver overlay homelab-internal

# Services Schritt für Schritt starten
cd /opt/homelab/dns-stack && docker-compose up -d
cd /opt/homelab/traefik && docker stack deploy -c docker-compose.yml traefik
cd /opt/homelab/homeassistant && docker stack deploy -c docker-compose.yml homeassistant
```

### Partielle Recovery-Szenarien

#### Service-spezifische Wiederherstellung

```bash title="Home Assistant Recovery"
# Home Assistant Backup wiederherstellen
docker run --rm \
    -v homeassistant_ha_config:/target \
    -v /opt/homelab/backup/homeassistant:/backup \
    alpine \
    tar xzf /backup/ha-config-latest.tar.gz -C /target

# Service neu starten
docker service update --force homeassistant_homeassistant
```

#### Docker Volume Recovery

```bash title="Volume-Wiederherstellung"
# Spezifisches Volume wiederherstellen
docker run --rm \
    -v target_volume:/target \
    -v /opt/homelab/backup:/backup \
    alpine \
    tar xzf /backup/docker-volumes-20241215.tar.gz -C /target --strip-components=1 target_volume/
```

## Backup-Überwachung

### Monitoring-Integration

```yaml title="Prometheus Alerting Rules"
groups:
  - name: backup_alerts
    rules:
      - alert: BackupMissing
        expr: time() - last_backup_timestamp > 86400 * 2  # 2 Tage
        for: 1h
        labels:
          severity: warning
        annotations:
          summary: "Backup fehlt für {{ $labels.job }}"
          description: "Seit über 2 Tagen kein Backup erstellt"

      - alert: BackupFailed
        expr: backup_last_result != 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Backup fehlgeschlagen für {{ $labels.job }}"
```

### Health-Check Script

```bash title="/opt/homelab/scripts/check-backups.sh"
#!/bin/bash

BACKUP_DIR="/opt/homelab/secrets/encrypted-backups"
MAX_AGE_HOURS=48

echo "🔍 Überprüfe Backup-Status..."

# Letztes Secrets-Backup prüfen
LATEST_SECRETS=$(find "$BACKUP_DIR" -name "secrets-*.tar.gz.gpg" -printf '%T@ %p\n' | sort -n | tail -1)
if [ -z "$LATEST_SECRETS" ]; then
    echo "❌ Keine Secrets-Backups gefunden"
    exit 1
fi

LATEST_TIME=$(echo "$LATEST_SECRETS" | awk '{print $1}')
CURRENT_TIME=$(date +%s)
AGE_HOURS=$(( (CURRENT_TIME - LATEST_TIME) / 3600 ))

if [ "$AGE_HOURS" -gt "$MAX_AGE_HOURS" ]; then
    echo "⚠️  Letztes Backup ist $AGE_HOURS Stunden alt (> $MAX_AGE_HOURS)"
    exit 1
else
    echo "✅ Backup-Status: OK (vor $AGE_HOURS Stunden)"
fi

# GPG-Verschlüsselung testen
LATEST_FILE=$(echo "$LATEST_SECRETS" | awk '{print $2}')
if gpg --list-packets "$LATEST_FILE" >/dev/null 2>&1; then
    echo "✅ GPG-Verschlüsselung: OK"
else
    echo "❌ GPG-Verschlüsselung defekt"
    exit 1
fi

echo "🎯 Alle Backup-Checks bestanden"
```

## Offsite-Backup-Strategie

### Physische Medien

```bash title="Quartalsweise USB-Rotation"
#!/bin/bash

# USB-Stick Rotationsschema:
# - USB-A: Januar, April, Juli, Oktober  
# - USB-B: Februar, Mai, August, November
# - USB-C: März, Juni, September, Dezember

MONTH=$(date +%m)
USB_LABELS=("USB-C" "USB-A" "USB-A" "USB-B" "USB-B" "USB-C" "USB-C" "USB-A" "USB-A" "USB-B" "USB-B" "USB-C")
CURRENT_USB=${USB_LABELS[$((10#$MONTH - 1))]}

echo "📅 Aktueller Monat: $(date +%B)"
echo "💾 Verwende USB-Stick: $CURRENT_USB"
echo ""
echo "📋 Aufgaben:"
echo "   1. USB-Stick '$CURRENT_USB' bereithalten"
echo "   2. Vollständiges Backup erstellen"
echo "   3. USB-Stick sicher verwahren (Tresor/Offsite)"
echo "   4. Vorherigen USB-Stick zurückholen"
```

### Vertrauensperson-Backup

!!! info "Offsite-Strategie"
    Lagern Sie quartalsweise einen USB-Stick bei einer Vertrauensperson ein. Bei Wohnungsbrand oder Diebstahl sind lokale Backups nutzlos.

```bash title="Offsite-Backup Checkliste"
# Quartalsweise Offsite-Rotation:

# Q1 (März): USB bei Familie
# Q2 (Juni): USB bei Freunden  
# Q3 (September): USB im Büro/Bankschließfach
# Q4 (Dezember): USB bei Familie (neuer Stick)

# Inhalt USB-Stick:
# - Verschlüsselte GPG-Key-Backups
# - Verschlüsselte Secrets-Backups (letzten 3 Monate)
# - Anleitung für Recovery (unverschlüsselt)
# - Notfall-Kontaktdaten
```

---

## Aufwandsschätzung

| Aufgabe | Zeitaufwand | Häufigkeit |
|---------|-------------|------------|
| **Backup-System Einrichtung** | 4-6 Stunden | Einmalig |
| **Script-Entwicklung** | 3-4 Stunden | Einmalig |
| **Automatisierung (Cron)** | 1 Stunde | Einmalig |
| **Wöchentliche Kontrolle** | 15 Minuten | Wöchentlich |
| **Monatliche Wartung** | 30 Minuten | Monatlich |
| **Quartals-Offsite-Backup** | 2 Stunden | Quartalsweise |
| **Jährlicher Recovery-Test** | 8 Stunden | Jährlich |

**Gesamtaufwand Ersteinrichtung**: ~10 Stunden  
**Laufender Aufwand**: ~3 Stunden/Monat
