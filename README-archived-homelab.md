# Homelab - Multi-Location Infrastructure

Gesamtprojekt für Multi-Location Homelab mit Infrastructure as Code, Dokumentation und Automation-Scripts.

## Struktur

- **ansible/**: Infrastructure as Code mit Ansible
- **scripts/**: Automation und Maintenance Scripts  
- **docs/**: Projekt-Dokumentation
- **project-knowledge/**: Archivierte Planungsdokumente und Entscheidungen

## Quick Start

```bash
# Ansible-Umgebung initialisieren
./scripts/setup/bootstrap_ansible.sh

# VPS-Infrastruktur deployen
cd ansible && make deploy-vps

# Homelab-Services deployen
make deploy-homelab
```

## Weitere Informationen

- [Technische Prämissen](project-knowledge/01_technische_praemissen.md)
- [Netzwerk-Architektur](project-knowledge/02_netzwerk_architektur.md)  
- [Ansible Repository Struktur](project-knowledge/03_ansible_repository_struktur.md)
