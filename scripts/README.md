# Automation Scripts

## Struktur

- **setup/**: Initialisierung und Bootstrap-Scripts
- **maintenance/**: Wartung und Backup-Scripts
- **monitoring/**: Überwachung und Diagnostik
- **deployment/**: Deployment-Wrapper und Rollback

## Ausführung

Alle Scripts sind aus dem Repository-Root ausführbar:

```bash
# Ansible-Umgebung initialisieren
./scripts/setup/bootstrap_ansible.sh

# System-Health prüfen
./scripts/monitoring/health_check.sh

# Backup durchführen
./scripts/maintenance/backup_configs.sh
```
