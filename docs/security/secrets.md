# Secrets Management

## Problemstellung und Lösungsansatz

!!! danger "Kritisches Sicherheitsrisiko"
    Sensitive Daten wie API-Keys und Passwörter dürfen **niemals** in Git gespeichert werden. Ein einziger Commit mit Credentials kann die gesamte Infrastruktur kompromittieren.

Die Herausforderung bei Homelab-Infrastrukturen liegt darin, eine reproduzierbare Umgebung zu schaffen, ohne dabei Sicherheit zu kompromittieren. Unsere Lösung implementiert ein **Multi-Layer Security**-Konzept:

### Lösungsarchitektur

1. **Template-System**: `.env.example` Dateien in Git (ohne echte Secrets)
2. **Lokale Environment-Dateien**: `.env` Dateien lokal (mit echten Secrets)
3. **GPG-Verschlüsselung**: Sichere Backups der echten Secrets
4. **Git-Schutz**: `.gitignore` verhindert versehentliche Commits

## Git-Schutz Konfiguration

### Zentrale .gitignore

Die folgende `.gitignore`-Konfiguration muss im Root-Verzeichnis `/opt/homelab/.gitignore` platziert werden:

```bash title="/opt/homelab/.gitignore"
# === SENSITIVE DATA ===
# Environment-Dateien mit echten Secrets
**/.env
!**/.env.example
!**/.env.template

# GPG-Keys und verschlüsselte Backups  
**/secrets/gpg-keys/
**/secrets/encrypted-backups/
**/backup/*.tar.gz
**/backup/*.gpg

# Temporary und Cache-Dateien
**/.sops.yaml.bak
**/sops-key-*.asc
**/.gnupg/
**/node_modules/
**/__pycache__/
**/.DS_Store

# === ALLOWED IN GIT ===
# Templates sind erlaubt (enthalten keine echten Secrets)
!**/README.md
!**/docker-compose.yml
!**/unbound.conf
!**/scripts/*.sh
```

!!! info "Pattern-Erklärung"
    - `**/.env` blockiert alle `.env` Dateien rekursiv
    - `!**/.env.example` erlaubt explizit alle `.env.example` Templates
    - `**/secrets/` blockiert den gesamten Secrets-Ordner

## Template-System

### Standard-Templates für Services

Jeder Service verwendet ein einheitliches Template-System:

```bash title="/opt/homelab/dns-stack/.env.example"
PI_NUMBER=01
PI_IP=192.168.1.3
REMOTE_PI_IP=192.168.1.4
PIHOLE_PASSWORD=CHANGE_ME_TO_SECURE_PASSWORD

# netcup API Credentials (von netcup Customer Control Panel)
NETCUP_CUSTOMER_NUMBER=YOUR_CUSTOMER_NUMBER
NETCUP_API_KEY=YOUR_API_KEY  
NETCUP_API_PASSWORD=YOUR_API_PASSWORD
```

```bash title="/opt/homelab/traefik/.env.example"
# netcup API Credentials (identisch wie bei Pi-hole)
NETCUP_CUSTOMER_NUMBER=YOUR_CUSTOMER_NUMBER
NETCUP_API_KEY=YOUR_API_KEY
NETCUP_API_PASSWORD=YOUR_API_PASSWORD
```

```bash title="/opt/homelab/homeassistant/.env.example"
HA_DB_PASSWORD=CHANGE_ME_TO_SECURE_DB_PASSWORD
HA_ADMIN_PASSWORD=CHANGE_ME_TO_SECURE_ADMIN_PASSWORD
MQTT_PASSWORD=CHANGE_ME_TO_SECURE_MQTT_PASSWORD
```

### Template-Naming-Konventionen

!!! tip "Best Practices"
    - **Eindeutige Placeholder**: `CHANGE_ME_TO_SECURE_*` für Passwörter
    - **Service-Kontext**: `YOUR_*` für externe Credentials
    - **Dokumentation**: Inline-Kommentare für Credential-Beschaffung

## GPG-basierte Verschlüsselung

### Einmalige GPG-Einrichtung

```bash title="GPG-Key erstellen"
# GPG Key erstellen (einmalig)
gpg --full-generate-key

# Auswahl treffen:
# - Schlüsseltyp: RSA (4096 bit)
# - Gültigkeitsdauer: 2 Jahre  
# - Name: Homelab Administration
# - Email: admin@enzmann.online
```

```bash title="Key-ID ermitteln"
# Key-ID für Scripts ermitteln
gpg --list-secret-keys --keyid-format LONG

# Output-Beispiel:
# sec   rsa4096/ABC123DEF456789A 2024-12-15 [SC] [expires: 2026-12-15]
#       Key-ID ist: ABC123DEF456789A
```

### Secrets-Infrastruktur erstellen

```bash title="Verzeichnisstruktur erstellen"
# Secrets-Ordner einrichten
mkdir -p /opt/homelab/secrets/{gpg-keys,encrypted-backups}
chmod 700 /opt/homelab/secrets

# Scripts-Ordner für Automatisierung
mkdir -p /opt/homelab/scripts
```

## Automatisierte Scripts

### Environment-Setup Script

```bash title="/opt/homelab/scripts/init-environment.sh"
#!/bin/bash

echo "🔧 Homelab Environment Setup"
echo "=============================="

# Services mit .env.example Templates
SERVICES=("dns-stack" "traefik" "homeassistant" "monitoring" "portainer")

for service in "${SERVICES[@]}"; do
    SERVICE_DIR="/opt/homelab/$service"
    
    if [ -f "$SERVICE_DIR/.env.example" ]; then
        if [ ! -f "$SERVICE_DIR/.env" ]; then
            echo "📝 Erstelle .env für $service..."
            cp "$SERVICE_DIR/.env.example" "$SERVICE_DIR/.env"
            echo "⚠️  WICHTIG: Editiere $SERVICE_DIR/.env mit echten Werten!"
        else
            echo "✅ .env bereits vorhanden für $service"
        fi
    else
        echo "⚠️  Template fehlt: $SERVICE_DIR/.env.example"
    fi
done

# Sichere Berechtigungen setzen
echo ""
echo "🔒 Setze sichere Berechtigungen..."
find /opt/homelab -name ".env" -exec chmod 600 {} \; 2>/dev/null
chmod 700 /opt/homelab/secrets 2>/dev/null
chmod +x /opt/homelab/scripts/*.sh 2>/dev/null

echo ""
echo "🎯 Setup abgeschlossen!"
echo ""
echo "📋 Nächste Schritte:"
echo "   1. Editiere alle .env Dateien mit echten Werten"
echo "   2. Erstelle GPG-Key: gpg --full-generate-key"
echo "   3. Backup erstellen: ./scripts/backup-secrets.sh"
echo "   4. Teste Services: cd dns-stack && docker-compose up -d"
```

### GPG Key-Backup Script

```bash title="/opt/homelab/scripts/backup-gpg-keys.sh"
#!/bin/bash

# Konfiguration (anpassen!)
KEY_ID=$(gpg --list-secret-keys --keyid-format LONG | grep "sec" | head -1 | cut -d'/' -f2 | cut -d' ' -f1)
BACKUP_DIR="/opt/homelab/secrets/gpg-keys"
DATE=$(date +%Y%m%d)

echo "🔐 GPG Key Backup wird erstellt..."
echo "Key-ID: $KEY_ID"

# Backup-Ordner erstellen
mkdir -p "$BACKUP_DIR"

# Private Key mit Passwort-Schutz exportieren
gpg --armor --export-secret-keys "$KEY_ID" > "$BACKUP_DIR/private-key-backup.asc"

# Public Key exportieren  
gpg --armor --export "$KEY_ID" > "$BACKUP_DIR/public-key.asc"

# Trust-Database exportieren
gpg --export-ownertrust > "$BACKUP_DIR/ownertrust.txt"

# Revocation Certificate erstellen (falls nicht vorhanden)
if [ ! -f "$BACKUP_DIR/revocation.asc" ]; then
    echo "📋 Erstelle Revocation Certificate..."
    gpg --gen-revoke "$KEY_ID" > "$BACKUP_DIR/revocation.asc"
fi

# Komprimieren und verschlüsseln für externe Aufbewahrung
tar -czf "/tmp/gpg-backup-$DATE.tar.gz" -C "$BACKUP_DIR" .
gpg --cipher-algo AES256 --symmetric \
    --output "/opt/homelab/secrets/encrypted-backups/gpg-backup-$DATE.tar.gz.gpg" \
    "/tmp/gpg-backup-$DATE.tar.gz"

# Temporäre Datei löschen
rm "/tmp/gpg-backup-$DATE.tar.gz"

echo "✅ GPG Backup erstellt:"
echo "   📁 Lokal: $BACKUP_DIR/"
echo "   🔒 Verschlüsselt: /opt/homelab/secrets/encrypted-backups/gpg-backup-$DATE.tar.gz.gpg"
echo ""
echo "🎯 Nächste Schritte:"
echo "   1. Verschlüsselte Datei in Cloud speichern"
echo "   2. Zusätzlich auf USB-Stick kopieren und sicher verwahren"
echo "   3. Master-Passwort separat notieren!"
```

### Secrets-Backup Script

```bash title="/opt/homelab/scripts/backup-secrets.sh"
#!/bin/bash

BACKUP_DIR="/opt/homelab/secrets/encrypted-backups"
DATE=$(date +%Y%m%d-%H%M)

echo "🔒 Erstelle verschlüsseltes Backup aller Secrets..."

# Alle .env Dateien sammeln
tar -czf "/tmp/secrets-$DATE.tar.gz" \
    --exclude='*.example' \
    --exclude='*.template' \
    $(find /opt/homelab -name ".env" 2>/dev/null)

# Mit GPG verschlüsseln
gpg --cipher-algo AES256 --compress-algo 1 --symmetric \
    --output "$BACKUP_DIR/secrets-$DATE.tar.gz.gpg" \
    "/tmp/secrets-$DATE.tar.gz"

# Unverschlüsselte Datei löschen
rm "/tmp/secrets-$DATE.tar.gz"

echo "✅ Secrets Backup erstellt: $BACKUP_DIR/secrets-$DATE.tar.gz.gpg"
echo "💡 Datei in Cloud und auf USB-Stick speichern!"
```

### Recovery Script

```bash title="/opt/homelab/scripts/restore-gpg-keys.sh"
#!/bin/bash

BACKUP_DIR="/opt/homelab/secrets/gpg-keys"

echo "🔓 GPG Key Wiederherstellung..."

if [ -f "$BACKUP_DIR/private-key-backup.asc" ]; then
    echo "📥 Importiere private GPG Keys..."
    gpg --import "$BACKUP_DIR/private-key-backup.asc"
    gpg --import "$BACKUP_DIR/public-key.asc"
    
    if [ -f "$BACKUP_DIR/ownertrust.txt" ]; then
        gpg --import-ownertrust "$BACKUP_DIR/ownertrust.txt"
    fi
    
    echo "✅ GPG Keys erfolgreich wiederhergestellt!"
    echo ""
    echo "🧪 Tests:"
    echo "   📋 Liste Keys: gpg --list-secret-keys"
    echo "   🔓 Test Entschlüsselung: echo 'test' | gpg --encrypt -r YOUR_EMAIL | gpg --decrypt"
else
    echo "❌ Keine lokalen Key-Backups gefunden in $BACKUP_DIR"
    echo ""
    echo "🔍 Externe Recovery-Optionen:"
    echo "   1. Verschlüsselte Backup-Datei von Cloud/USB holen"
    echo "   2. Mit Master-Passwort entschlüsseln:"
    echo "      gpg -d gpg-backup-YYYYMMDD.tar.gz.gpg | tar -xz -C $BACKUP_DIR/"
    echo "   3. Dieses Script erneut ausführen"
fi
```

## Script-Installation

```bash title="Scripts ausführbar machen"
chmod +x /opt/homelab/scripts/*.sh
```

!!! warning "Script-Sicherheit"
    Prüfen Sie alle Scripts vor der Ausführung auf unerwünschte Befehle. Scripts mit Root-Berechtigung können das System beschädigen.

---

## Aufwandsschätzung

| Aufgabe | Zeitaufwand | Häufigkeit |
|---------|-------------|------------|
| **Ersteinrichtung** | 2-3 Stunden | Einmalig |
| **GPG-Key Erstellung** | 30 Minuten | Alle 2 Jahre |
| **Template-Erstellung** | 15 Minuten | Pro neuer Service |
| **Script-Wartung** | 1 Stunde | Quartalsweise |
| **Secrets-Rotation** | 2 Stunden | Jährlich |

**Gesamtaufwand Ersteinrichtung**: ~4 Stunden  
**Laufender Aufwand**: ~30 Minuten/Monat
