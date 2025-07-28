#!/bin/bash

# Homelab Repository Setup Script
# Erstellt die komplette Verzeichnisstruktur für das Multi-Location Homelab

set -e

REPO_NAME="homelab"
REPO_URL="git@github.com:username/homelab.git"  # Anpassen!

echo "=== Homelab Repository Setup ==="
echo "Repository: $REPO_NAME"
echo

# Repository erstellen und initialisieren
if [ ! -d "$REPO_NAME" ]; then
    echo "✓ Erstelle Repository-Verzeichnis..."
    mkdir -p $REPO_NAME
    cd $REPO_NAME
    git init
    echo "Repository initialisiert."
else
    echo "✓ Repository-Verzeichnis existiert bereits"
    cd $REPO_NAME
fi

echo
echo "✓ Erstelle Verzeichnisstruktur..."

# Hauptverzeichnisse
mkdir -p docs/{architecture,deployment,services,changelog}
mkdir -p project-knowledge/{planning-sessions,decisions}
mkdir -p scripts/{setup,maintenance,monitoring,deployment}
mkdir -p ansible/{inventory/{production,staging},playbooks,roles,files,templates,vars,vault}

# Ansible Unterverzeichnisse
mkdir -p ansible/inventory/{production/group_vars,staging/group_vars}
mkdir -p ansible/inventory/group_vars
mkdir -p ansible/files/{certificates,ssh-keys,config-templates}
mkdir -p ansible/templates/{traefik,docker,systemd}
mkdir -p ansible/roles/{common,vpn-client,vpn-server,traefik,pihole,docker-swarm,home-assistant}

# Ansible Rollen-Struktur für common role als Beispiel
mkdir -p ansible/roles/common/{tasks,handlers,templates,files,vars,defaults,meta}

echo "Verzeichnisstruktur erstellt."

echo
echo "✓ Erstelle Basis-Dateien..."

# Root-Level Dateien
cat > README.md << 'EOF'
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
EOF

cat > .gitignore << 'EOF'
# Ansible
ansible/.ansible-vault-pass
ansible/inventory/production/host_vars/
ansible/inventory/staging/host_vars/
*.retry

# Scripts
scripts/**/*.log
scripts/**/tmp/

# SSH Keys
**/*_rsa
**/*_rsa.pub
**/id_*

# Certificates
**/*.pem
**/*.crt
**/*.key

# Temporary files
**/.DS_Store
**/Thumbs.db
**/*.tmp
**/*.swp
**/*.swo
**/~*

# Secrets
**/secrets.yml
**/credentials.yml
EOF

# LICENSE
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 Homelab Project

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

echo "✓ Erstelle Ansible-Konfiguration..."

# Ansible Basiskonfiguration
cat > ansible/ansible.cfg << 'EOF'
[defaults]
inventory = inventory/production
host_key_checking = False
timeout = 30
ansible_managed = Ansible managed - Do not edit manually
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts_cache
fact_caching_timeout = 86400
vault_password_file = .ansible-vault-pass

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
pipelining = True
control_path = /tmp/ansible-ssh-%%h-%%p-%%r
EOF

# Ansible Makefile
cat > ansible/Makefile << 'EOF'
.PHONY: help deploy-all deploy-homelab deploy-vps deploy-campervan check lint vault-edit

# Default target
help:
	@echo "Available targets:"
	@echo "  deploy-all      - Deploy complete infrastructure"
	@echo "  deploy-homelab  - Deploy homelab only"
	@echo "  deploy-vps      - Deploy VPS infrastructure only"
	@echo "  deploy-campervan - Deploy campervan only"
	@echo "  check           - Dry-run deployment"
	@echo "  lint            - Lint ansible playbooks"
	@echo "  vault-edit      - Edit encrypted vault files"

# Deployment targets
deploy-all:
	ansible-playbook -i inventory/production playbooks/site.yml

deploy-homelab:
	ansible-playbook -i inventory/production playbooks/homelab.yml

deploy-vps:
	ansible-playbook -i inventory/production playbooks/internet-vps.yml

deploy-campervan:
	ansible-playbook -i inventory/production playbooks/campervan.yml

# Check and validation
check:
	ansible-playbook -i inventory/production playbooks/site.yml --check --diff

lint:
	ansible-lint playbooks/
	yamllint inventory/ playbooks/ roles/

# Vault management
vault-edit:
	ansible-vault edit vault/homelab.yml

# Specific service deployments
deploy-traefik:
	ansible-playbook -i inventory/production playbooks/homelab.yml --tags proxy

deploy-dns:
	ansible-playbook -i inventory/production playbooks/homelab.yml --tags dns

deploy-vpn:
	ansible-playbook -i inventory/production playbooks/internet-vps.yml --tags vpn
EOF

# Ansible requirements
cat > ansible/requirements.yml << 'EOF'
---
collections:
  - name: community.general
    version: ">=5.0.0"
  - name: community.docker
    version: ">=3.0.0"
  - name: ansible.posix
    version: ">=1.0.0"

roles: []
EOF

echo "✓ Erstelle README-Dateien für Unterverzeichnisse..."

# Documentation README
cat > docs/README.md << 'EOF'
# Homelab Dokumentation

## Struktur

- **architecture/**: System-Architektur und Design-Entscheidungen
- **deployment/**: Installation und Deployment-Guides
- **services/**: Service-spezifische Dokumentation
- **changelog/**: Versionshistorie und Migration-Notes

## Dokumentations-Standards

- Markdown für alle Dokumente
- Klare Kapitelstruktur mit Headers
- Code-Beispiele in entsprechenden Sprach-Blöcken
- Aktuelle Screenshots für UI-Dokumentation
EOF

# Project Knowledge README
cat > project-knowledge/README.md << 'EOF'
# Projektwissen-Archiv

## Zweck

Archivierung aller Planungsdokumente, Designentscheidungen und Chat-Artefakte aus der Projektentwicklung.

## Struktur

- **01_xx_titel.md**: Hauptdokumente in chronologischer Reihenfolge
- **planning-sessions/**: Artefakte aus Claude-Chats mit Datum
- **decisions/**: Architecture Decision Records (ADRs)

## Arbeitsweise

```bash
# Chat-Artefakt archivieren
cp "Chat-Output.md" planning-sessions/$(date +%Y-%m-%d)_thema.md

# Designentscheidung dokumentieren  
cp "Architektur-Entscheidung.md" decisions/architecture_decision_vpn.md
```
EOF

# Scripts README
cat > scripts/README.md << 'EOF'
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
EOF

# Session Template
cat > project-knowledge/planning-sessions/session_template.md << 'EOF'
# Planning Session: [DATUM] - [THEMA]

## Ziel der Session
[Beschreibung des Planungsziels]

## Behandelte Themen
- [ ] Thema 1
- [ ] Thema 2
- [ ] Thema 3

## Entscheidungen
| Entscheidung | Begründung | Auswirkung |
|-------------|------------|------------|
| [Entscheidung] | [Grund] | [Impact] |

## Nächste Schritte
1. [ ] Aufgabe 1
2. [ ] Aufgabe 2
3. [ ] Aufgabe 3

## Artefakte
- [Link zu erzeugten Dokumenten]
- [Link zu Code-Änderungen]

## Offene Punkte
- [ ] Punkt 1
- [ ] Punkt 2
EOF

echo "✓ Erstelle Setup-Scripts..."

# Bootstrap Script
cat > scripts/setup/bootstrap_ansible.sh << 'EOF'
#!/bin/bash

# Bootstrap Ansible Environment
set -e

echo "=== Ansible Environment Bootstrap ==="

# Check if ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "Installing Ansible..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt update
        sudo apt install -y ansible
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install ansible
    else
        echo "Please install Ansible manually"
        exit 1
    fi
fi

# Install Ansible collections
echo "Installing Ansible collections..."
cd ansible/
ansible-galaxy install -r requirements.yml

# Generate vault password file
if [ ! -f .ansible-vault-pass ]; then
    echo "Generating vault password..."
    openssl rand -base64 32 > .ansible-vault-pass
    chmod 600 .ansible-vault-pass
    echo "⚠️  Vault password saved to ansible/.ansible-vault-pass"
    echo "⚠️  Please back up this password securely!"
fi

echo "✓ Ansible environment ready"
echo "Next steps:"
echo "  1. Configure inventory/production/hosts.yml"
echo "  2. Create encrypted vault files"
echo "  3. Test connectivity: ansible all -m ping"
EOF

chmod +x scripts/setup/bootstrap_ansible.sh

# Health Check Script
cat > scripts/monitoring/health_check.sh << 'EOF'
#!/bin/bash

# System Health Check
set -e

echo "=== Homelab Health Check ==="
echo "Timestamp: $(date)"
echo

# Check Ansible connectivity
echo "Checking Ansible connectivity..."
cd ansible/
if ansible all -m ping --one-line 2>/dev/null; then
    echo "✓ All hosts reachable"
else
    echo "⚠️  Some hosts unreachable"
fi

# Check VPN status
echo
echo "Checking VPN status..."
# Add VPN-specific checks here

# Check services
echo
echo "Checking services..."
# Add service-specific checks here

echo
echo "Health check completed."
EOF

chmod +x scripts/monitoring/health_check.sh

echo
echo "✓ Erstelle Git-Tracking..."

# Git Commits
git add .
git commit -m "Initial repository structure

- Complete directory structure for multi-location homelab
- Ansible configuration with Makefile
- Scripts for setup and monitoring  
- Documentation structure
- Project knowledge archive structure"

echo
echo "🎉 Repository Setup abgeschlossen!"
echo
echo "Nächste Schritte:"
echo "1. Repository-URL anpassen: $REPO_URL"
echo "2. Remote hinzufügen: git remote add origin $REPO_URL"
echo "3. Ansible-Umgebung initialisieren: ./scripts/setup/bootstrap_ansible.sh"
echo "4. Inventory konfigurieren: ansible/inventory/production/hosts.yml"
echo "5. Chat-Artefakte archivieren in project-knowledge/"
echo
echo "Repository bereit für Entwicklung! 🚀"