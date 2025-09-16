# Wartung und Maintenance

## Backup-Strategie

Eine durchdachte Backup-Strategie ist essentiell für den zuverlässigen Betrieb der Homelab-Infrastruktur. Die Strategie folgt dem 3-2-1-Prinzip: 3 Kopien, 2 verschiedene Medien, 1 Offsite-Backup.

### Tägliche Backups (automatisiert)

**Home Assistant Konfiguration**
```yaml
# automation.yaml - Tägliches HA Backup
- alias: "Daily Home Assistant Backup"
  trigger:
    platform: time
    at: "02:00:00"
  action:
    service: hassio.backup_full
    data:
      name: "Auto Backup {{ now().strftime('%Y-%m-%d') }}"
```

**Docker Container Logs**
```bash
# Loki sammelt automatisch alle Container-Logs
# Retention: 30 Tage lokal, 90 Tage komprimiert
```

**System Metriken**
```bash
# InfluxDB + Prometheus - automatische Sammlung
# Retention: 365 Tage für Dashboards und Trends
```

### Wöchentliche Backups (Cron-gesteuert)

**Secrets-Backup**
```bash
# /etc/cron.d/homelab-backups
0 3 * * 0 root /opt/homelab/scripts/backup-secrets.sh
```

**Docker Volumes**
```bash
# Alle Docker Volumes sichern
0 2 * * 0 root docker run --rm \
  -v /var/lib/docker/volumes:/source:ro \
  -v /opt/homelab/backup:/backup \
  alpine tar czf /backup/docker-volumes-$(date +%Y%m%d).tar.gz -C /source .
```

**UniFi Controller Backup**
```bash
# Automatisches Backup über UniFi Controller Settings
# Settings → System → Backup → Auto Backup: Weekly
# Zusätzlich manuell kontrollieren und herunterladen
```

!!! warning "Backup-Retention"
    Docker Volume Backups werden lokal nur 4 Wochen aufbewahrt. Ältere Backups müssen in externen Storage verschoben werden.

### Monatliche Backups

**GPG-Key Backup**
```bash
# /etc/cron.d/homelab-backups
0 3 1 * * root /opt/homelab/scripts/backup-gpg-keys.sh
```

**Proxmox Cluster Backup**
```bash
# Proxmox Backup Server oder manuell via GUI
# VMs + Container + Konfigurationen
# Retention: 12 Monate
```

**Komplette System-Snapshots**
```bash
# Proxmox: VM Snapshots vor größeren Updates
# TrueNAS: ZFS Snapshots der Datasets
# UniFi: Komplette Konfigurationsexporte
```

### Externe Aufbewahrung

**Cloud-Storage Integration**
```bash
# rclone für automatisierte Cloud-Uploads
# /etc/rclone/rclone.conf
[nextcloud]
type = webdav
url = https://cloud.example.com/remote.php/dav/files/username/
vendor = nextcloud
user = backup-user
pass = encrypted-password

# Sync-Script
#!/bin/bash
rclone copy /opt/homelab/secrets/encrypted-backups/ \
  nextcloud:homelab-backups/ \
  --include "*.gpg" \
  --max-age 30d
```

**USB-Stick Backup (manuell quartalsweise)**
```bash
# Verschlüsselte Backups auf USB-Stick kopieren
cp /opt/homelab/secrets/encrypted-backups/*.gpg /media/usb-backup/
# USB-Stick sicher verwahren (Tresor, Bank-Schließfach)
```

!!! danger "Master-Passwort Aufbewahrung"
    Das GPG Master-Passwort NIEMALS digital speichern! Physisch notieren und an mehreren sicheren Orten verwahren.

## Update-Management

### Infrastructure Updates

**Zeitfenster: Sonntag 02:00-04:00 Uhr**

**Reihenfolge der Updates:**
1. **Pi-hole + Unbound** (DNS Services)
2. **UniFi Controller + Geräte** (Netzwerk-Infrastruktur)  
3. **Proxmox** (Virtualisierung)
4. **TrueNAS** (Storage)

**Pi-hole Update-Prozess:**
```bash
# Backup vor Update
docker exec pihole_pihole_1 pihole -a -t
# Oder: Web-Interface → Settings → Teleporter → Backup

# Update ausführen
cd /opt/homelab/dns-stack
docker-compose pull
docker-compose up -d

# Health-Check
docker-compose ps
nslookup ha-prod-01.lab.homelab.example 192.168.1.3
```

**UniFi Update-Prozess:**
```bash
# 1. Controller Backup herunterladen
# 2. Controller Update via Web-Interface
# 3. Access Point Updates (einzeln, nicht alle gleichzeitig)
# 4. Switch Updates (nach APs)
# 5. Gateway Update (als letztes, kurzer Netzwerk-Ausfall)
```

**Proxmox Update-Prozess:**
```bash
# VM/Container Snapshots erstellen
pvesh create /nodes/{node}/vzdump --vmid {vmid} --mode snapshot

# System Updates
apt update && apt upgrade
pve-manager --version

# Cluster-Status prüfen
pvecm status
```

!!! info "Rollback-Plan"
    Für jeden Update-Schritt muss ein dokumentierter Rollback-Plan existieren. Backups vor Updates sind obligatorisch.

### Service Updates

**Zeitfenster: Sonntag 04:00-06:00 Uhr**

**Automatisierte Docker Updates:**
```bash
# /etc/cron.d/homelab-updates
0 4 * * 0 root cd /opt/homelab/dns-stack && docker-compose pull && docker-compose up -d
0 4 * * 0 root docker stack deploy --prune -c /opt/homelab/traefik/docker-compose.yml traefik
15 4 * * 0 root docker stack deploy --prune -c /opt/homelab/homeassistant/docker-compose.yml homeassistant
30 4 * * 0 root docker stack deploy --prune -c /opt/homelab/monitoring/docker-compose.yml monitoring
```

**Rolling Update-Strategie:**
```bash
# Health-Check Script für automatisierte Updates
#!/bin/bash
check_service_health() {
    local service_url=$1
    local expected_status=$2
    
    status=$(curl -s -o /dev/null -w "%{http_code}" $service_url)
    if [ "$status" = "$expected_status" ]; then
        echo "✅ Service $service_url healthy"
        return 0
    else
        echo "❌ Service $service_url unhealthy (Status: $status)"
        return 1
    fi
}

# Service Health Checks
check_service_health "https://ha-prod-01.lab.homelab.example" "200"
check_service_health "https://grafana-01.lab.homelab.example" "200" 
check_service_health "https://traefik-01.lab.homelab.example" "200"
```

### IOT-Geräte Updates

**Nach Bedarf, rollierend (nie alle gleichzeitig)**

**Update-Kategorien:**
```bash
# Kritische Geräte (zentrale Steuerung)
Priority 1: Homematic CCU, Hue Bridge
# Update-Fenster: Mittwoch 20:00-22:00 Uhr

# Standard-Geräte (Sensoren, Schalter)
Priority 2: Shelly Geräte, Hue Lampen
# Update-Fenster: Samstag 10:00-12:00 Uhr

# Unterhaltung (kann ausfallen)
Priority 3: Sonos, Smart-TVs
# Update-Fenster: Beliebig
```

**Kompatibilitätsprüfung:**
```yaml
# Home Assistant - Vor IOT-Updates prüfen
# 1. Breaking Changes in Release Notes checken
# 2. Integration-Versionen in HACS kontrollieren
# 3. Test-Update in HA-Test-Instanz durchführen
```

!!! tip "Update-Protokoll"
    Führe ein Update-Log mit Datum, Gerät, alter/neuer Version und aufgetretenen Problemen.

## Wartungsaufgaben

### Tägliche Überwachung (5 Minuten)

**Service-Status Dashboard**
```bash
# Grafana Dashboard: "Homelab Overview"
# Key Metrics:
# - Service Uptime (24h)
# - DNS Query Response Time
# - Docker Container Status
# - HTTPS Certificate Expiry
```

**Log-Review (kritische Fehler)**
```bash
# Loki Query für kritische Fehler (letzte 24h)
{job="docker"} |= "ERROR" or |= "CRITICAL" or |= "FATAL"
```

### Wöchentliche Wartung (30 Minuten)

**Service Health Checks**
```bash
#!/bin/bash
# /opt/homelab/scripts/weekly-health-check.sh

echo "🔍 Weekly Homelab Health Check"
echo "================================"

# DNS Performance
echo "📡 DNS Performance:"
dig @192.168.1.3 google.com +stats | grep "Query time"

# Certificate Expiry
echo "🔒 Certificate Status:"
echo | openssl s_client -connect ha-prod-01.lab.homelab.example:443 2>/dev/null | openssl x509 -noout -dates

# Docker System Info
echo "🐳 Docker System:"
docker system df
docker system prune -f --volumes --filter "until=168h"

# Disk Space
echo "💾 Disk Usage:"
df -h | grep -E "(/$|/opt|/var)"

echo "✅ Health Check Complete"
```

**Backup Verification**
```bash
# Überprüfe letzte Backups
ls -la /opt/homelab/secrets/encrypted-backups/ | head -5
ls -la /opt/homelab/backup/ | head -5

# Test GPG-Entschlüsselung
echo "test" | gpg --encrypt -r admin@homelab.example | gpg --decrypt
```

### Monatliche Wartung (2 Stunden)

**Performance-Analyse**
```bash
# System Performance Review
iostat -x 1 5
netstat -i
ss -tuln

# Docker Performance
docker stats --no-stream
docker network ls
docker volume ls --filter "dangling=true"
```

**Sicherheits-Review**
```bash
# Ungewöhnliche Logins prüfen
journalctl -u ssh --since "30 days ago" | grep "Failed"

# Pi-hole Query Log Review
# Web-Interface → Query Log → Top Blocked Domains

# UniFi Security Events
# Controller → Events → Security Tab
```

**Update-Planung**
```bash
# Verfügbare Updates prüfen
apt list --upgradable
docker images --filter "dangling=true"

# Home Assistant Release Notes reviewen
# GitHub: home-assistant/core/releases
```

!!! success "Wartungsaufwand"
    **Geschätzter Zeitaufwand:**
    
    - Tägliche Überwachung: 5 Minuten
    - Wöchentliche Wartung: 30 Minuten  
    - Monatliche Wartung: 2 Stunden
    - Updates: 4 Stunden/Monat
    
    **Gesamt: ~10 Stunden/Monat für professionellen Betrieb**
