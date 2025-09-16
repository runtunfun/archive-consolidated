# Homelab Repository Struktur - Multi-Location Infrastructure

## Projektübersicht

Gesamtprojekt für Multi-Location Homelab mit Infrastructure as Code, Dokumentation und Automation-Scripts für drei Standorte: Homelab, Internet-VPS und CamperVan.

### Ziel-Locations
- **Homelab:** Proxmox-Cluster, Docker Swarm, UniFi-Netzwerk
- **Internet-VPS:** 3 VPS für VPN-Server (Pangolin/Headscale)  
- **CamperVan:** Raspberry Pi mit Home Assistant

## Repository-Root-Struktur

```
homelab/
├── README.md
├── .gitignore
├── LICENSE
│
├── docs/
│   ├── README.md
│   ├── architecture/
│   │   ├── network-design.md
│   │   ├── vpn-architecture.md
│   │   └── security-concept.md
│   ├── deployment/
│   │   ├── installation-guide.md
│   │   ├── troubleshooting.md
│   │   └── maintenance.md
│   ├── services/
│   │   ├── traefik-setup.md
│   │   ├── home-assistant.md
│   │   └── monitoring.md
│   └── changelog/
│       ├── CHANGELOG.md
│       └── migration-notes.md
│
├── project-knowledge/
│   ├── README.md
│   ├── 01_technische_praemissen.md
│   ├── 02_netzwerk_architektur.md
│   ├── 03_ansible_repository_struktur.md
│   ├── 04_vpn_konzept.md
│   ├── planning-sessions/
│   │   ├── 2025-01-28_initial_planning.md
│   │   ├── 2025-01-28_ansible_structure.md
│   │   └── session_template.md
│   └── decisions/
│       ├── architecture_decisions.md
│       ├── technology_choices.md
│       └── naming_conventions.md
│
├── scripts/
│   ├── README.md
│   ├── setup/
│   │   ├── bootstrap_ansible.sh
│   │   ├── generate_ssh_keys.sh
│   │   └── setup_vps.sh
│   ├── maintenance/
│   │   ├── backup_configs.sh
│   │   ├── update_certificates.sh
│   │   └── health_check.sh
│   ├── monitoring/
│   │   ├── check_vpn_status.sh
│   │   ├── service_status.sh
│   │   └── network_diagnostics.sh
│   └── deployment/
│       ├── deploy_location.sh
│       ├── rollback_deployment.sh
│       └── test_connectivity.sh
│
├── ansible/
│   ├── README.md
│   ├── ansible.cfg
│   ├── requirements.yml
│   ├── .ansible-vault-pass
│   ├── Makefile
│   │
│   ├── inventory/
│   ├── inventory/
│   │   ├── production/
│   │   │   ├── hosts.yml
│   │   │   └── group_vars/
│   │   ├── staging/
│   │   │   ├── hosts.yml
│   │   │   └── group_vars/
│   │   └── group_vars/
│   │       ├── all.yml
│   │       ├── homelab.yml
│   │       ├── internet_vps.yml
│   │       └── campervan.yml
│   │
│   ├── playbooks/
│   │   ├── site.yml
│   │   ├── homelab.yml
│   │   ├── internet-vps.yml
│   │   └── campervan.yml
│   │
│   ├── roles/
│   │   ├── common/
│   │   ├── vpn-client/
│   │   ├── vpn-server/
│   │   ├── traefik/
│   │   ├── pihole/
│   │   ├── docker-swarm/
│   │   └── home-assistant/
│   │
│   ├── files/
│   │   ├── certificates/
│   │   ├── ssh-keys/
│   │   └── config-templates/
│   │
│   ├── templates/
│   │   ├── traefik/
│   │   ├── docker/
│   │   └── systemd/
│   │
│   ├── vars/
│   │   ├── network-config.yml
│   │   ├── service-config.yml
│   │   └── domain-config.yml
│   │
│   └── vault/
│       ├── homelab.yml
│       ├── internet-vps.yml
│       └── campervan.yml
```

## Inventory-Konfiguration

### Production Hosts

**ansible/inventory/production/hosts.yml**
```yaml
all:
  children:
    homelab:
      hosts:
        pve-node-1:
          ansible_host: 192.168.1.21
          node_role: proxmox_primary
        pve-node-2:
          ansible_host: 192.168.1.22
          node_role: proxmox_secondary
        pihole-primary:
          ansible_host: 192.168.1.3
          service_role: dns_primary
        pihole-secondary:
          ansible_host: 192.168.1.4
          service_role: dns_secondary
        home-assistant-lab:
          ansible_host: 192.168.1.45
          service_role: home_automation
        traefik-manager:
          ansible_host: 192.168.1.50
          service_role: reverse_proxy
        docker-swarm-nodes:
          ansible_host: 192.168.1.51
          service_role: container_host
    
    internet_vps:
      hosts:
        vps-enzmann:
          ansible_host: ds9.enzmann.online
          vpn_network: 10.1.0.0/24
          vpn_software: pangolin
          domain: enzmann.online
          dns_provider: hoster_1
        vps-lafritzn:
          ansible_host: ds9.lafritzn.de
          vpn_network: 10.2.0.0/24
          vpn_software: pangolin
          domain: lafritzn.de
          dns_provider: hoster_2
        vps-runtunfun:
          ansible_host: ds9.runtunfun.de
          vpn_network: 100.64.0.0/24
          vpn_software: headscale
          domain: runtunfun.de
          dns_provider: hoster_3
    
    campervan:
      hosts:
        raspberry-pi-van:
          ansible_host: 192.168.50.10
          service_role: mobile_hub
          lte_router: 192.168.50.1
          vpn_primary: ds9.lafritzn.de
          vpn_fallback: ds9.runtunfun.de
```

### Global Variables

**ansible/inventory/group_vars/all.yml**
```yaml
# Infrastructure Standards
os_standard: debian_bookworm
ansible_user: tu_ansible
ansible_python_interpreter: /usr/bin/python3
ansible_ssh_private_key_file: ~/.ssh/homelab_ansible

# Base Packages
base_packages:
  - curl
  - wget
  - git
  - vim
  - htop
  - unattended-upgrades
  - fail2ban
  - ufw

# Global DNS Fallback
fallback_dns_servers:
  - 1.1.1.1
  - 8.8.8.8

# Timezone
system_timezone: Europe/Berlin

# Security Settings
ssh_port: 22
ssh_password_auth: false
ssh_root_login: false
```

**ansible/inventory/group_vars/homelab.yml**
```yaml
# Homelab Network Configuration
homelab_networks:
  standard_lan:
    vlan_id: 1
    subnet: 192.168.1.0/24
    gateway: 192.168.1.1
    description: "Management and Core Services"
  iot_network:
    vlan_id: 100
    subnet: 192.168.100.0/22
    gateway: 192.168.100.1
    description: "IoT Devices and Smart Home"
  guest_network:
    vlan_id: 200
    subnet: 192.168.200.0/24
    gateway: 192.168.200.1
    description: "Guest Access"

# DNS Configuration
homelab_dns:
  primary_server: 192.168.1.3
  secondary_server: 192.168.1.4
  local_domains:
    - lab.enzmann.online
    - iot.enzmann.online

# Docker Swarm Configuration
docker_swarm:
  manager_ip: 192.168.1.50
  advertise_addr: 192.168.1.50
  data_path_port: 7946
```

## Playbook-Struktur

### Master Playbook

**ansible/playbooks/site.yml**
```yaml
---
- name: Deploy Complete Infrastructure
  import_playbook: internet-vps.yml
  tags: ['vps', 'infrastructure']

- name: Deploy Homelab Infrastructure  
  import_playbook: homelab.yml
  tags: ['homelab', 'local']

- name: Deploy CamperVan Infrastructure
  import_playbook: campervan.yml
  tags: ['campervan', 'mobile']
```

### Location-Specific Playbooks

**ansible/playbooks/homelab.yml**
```yaml
---
- name: Configure Homelab Base Infrastructure
  hosts: homelab
  become: yes
  serial: "{{ ansible_serial | default(5) }}"
  roles:
    - common
    - docker-swarm
    - vpn-client
  tags: ['base']

- name: Configure DNS Infrastructure
  hosts: homelab
  become: yes
  roles:
    - pihole
  when: service_role in ['dns_primary', 'dns_secondary']
  tags: ['dns']

- name: Configure Reverse Proxy
  hosts: homelab
  become: yes
  roles:
    - traefik
  when: service_role == 'reverse_proxy'
  tags: ['proxy']

- name: Configure Home Assistant
  hosts: homelab
  become: yes
  roles:
    - home-assistant
  when: service_role == 'home_automation'
  tags: ['ha']
```

**ansible/playbooks/internet-vps.yml**
```yaml
---
- name: Configure VPS Base Infrastructure
  hosts: internet_vps
  become: yes
  roles:
    - common
    - vpn-server
  tags: ['base', 'vpn']

- name: Configure Pangolin VPN Servers
  hosts: internet_vps
  become: yes
  roles:
    - role: vpn-server
      vpn_type: pangolin
  when: vpn_software == "pangolin"
  tags: ['pangolin']

- name: Configure Headscale VPN Server
  hosts: internet_vps
  become: yes
  roles:
    - role: vpn-server
      vpn_type: headscale
  when: vpn_software == "headscale"
  tags: ['headscale']
```

## Rollen-Architektur

### Common Role Structure

**ansible/roles/common/tasks/main.yml**
```yaml
---
- name: Include OS-specific variables
  include_vars: "{{ ansible_os_family }}.yml"

- name: Update package cache
  apt:
    update_cache: yes
    cache_valid_time: 3600
  when: ansible_os_family == "Debian"

- name: Install base packages
  apt:
    name: "{{ base_packages }}"
    state: present
    update_cache: yes

- name: Configure system timezone
  timezone:
    name: "{{ system_timezone }}"

- name: Setup ansible user
  include_tasks: setup_ansible_user.yml

- name: Configure SSH security
  include_tasks: configure_ssh.yml

- name: Setup basic firewall
  include_tasks: configure_firewall.yml

- name: Configure unattended upgrades
  template:
    src: 50unattended-upgrades.j2
    dest: /etc/apt/apt.conf.d/50unattended-upgrades
    backup: yes
  notify: restart unattended-upgrades
```

### VPN Client Role

**ansible/roles/vpn-client/tasks/main.yml**
```yaml
---
- name: Include VPN-specific variables
  include_vars: "{{ vpn_software }}.yml"

- name: Install Pangolin VPN client
  block:
    - name: Download and install Pangolin
      shell: |
        curl -sSL https://{{ vpn_server_url }}/install | sh
      args:
        creates: /usr/local/bin/newt
    
    - name: Authenticate Pangolin client
      shell: |
        echo "{{ vpn_auth_key }}" | newt auth --server {{ vpn_server_url }}
      when: vpn_auth_key is defined
  when: vpn_software == "pangolin"

- name: Install Tailscale client
  block:
    - name: Add Tailscale repository key
      apt_key:
        url: https://pkgs.tailscale.com/stable/ubuntu/focal.gpg
        state: present
    
    - name: Add Tailscale repository
      apt_repository:
        repo: "deb https://pkgs.tailscale.com/stable/ubuntu focal main"
        state: present
    
    - name: Install Tailscale
      apt:
        name: tailscale
        state: present
        update_cache: yes
    
    - name: Authenticate Tailscale
      shell: |
        tailscale up --login-server={{ headscale_server_url }} --authkey={{ tailscale_auth_key }}
      when: tailscale_auth_key is defined
  when: vpn_software == "headscale"

- name: Enable VPN service autostart
  systemd:
    name: "{{ vpn_service_name }}"
    enabled: yes
    state: started
```

### Traefik Role

**ansible/roles/traefik/tasks/main.yml**
```yaml
---
- name: Create traefik system user
  user:
    name: tu_traefik
    system: yes
    shell: /bin/false
    home: /var/lib/traefik
    create_home: yes

- name: Create traefik directories
  file:
    path: "{{ item }}"
    state: directory
    owner: tu_traefik
    group: tu_traefik
    mode: '0755'
  loop:
    - /etc/traefik
    - /var/lib/traefik
    - /var/log/traefik

- name: Generate traefik static configuration
  template:
    src: traefik.yml.j2
    dest: /etc/traefik/traefik.yml
    owner: tu_traefik
    group: tu_traefik
    mode: '0644'
    backup: yes
  notify: restart traefik

- name: Generate traefik dynamic configuration
  template:
    src: dynamic.yml.j2
    dest: /etc/traefik/dynamic.yml
    owner: tu_traefik
    group: tu_traefik
    mode: '0644'
  notify: reload traefik

- name: Create traefik docker compose configuration
  template:
    src: docker-compose.yml.j2
    dest: /opt/traefik/docker-compose.yml
    owner: tu_traefik
    group: tu_traefik
    mode: '0644'
  notify: restart traefik docker stack

- name: Start traefik docker stack
  docker_compose:
    project_src: /opt/traefik
    state: present
  become_user: tu_traefik
```

## Template-Konfigurationen

### Traefik Static Configuration

**ansible/roles/traefik/templates/traefik.yml.j2**
```yaml
global:
  checkNewVersion: false
  sendAnonymousUsage: false

api:
  dashboard: true
  insecure: false

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entrypoint:
          to: websecure
          scheme: https
          permanent: true
  websecure:
    address: ":443"

certificatesResolvers:
  letsencrypt-{{ location_name }}:
    acme:
      email: {{ acme_email }}
      storage: /var/lib/traefik/acme-{{ location_name }}.json
      dnsChallenge:
        provider: {{ dns_provider }}
        resolvers:
          - "1.1.1.1:53"
          - "8.8.8.8:53"
        delayBeforeCheck: 60

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    network: traefik-public
  file:
    filename: /etc/traefik/dynamic.yml
    watch: true

log:
  level: INFO
  filePath: /var/log/traefik/traefik.log

accessLog:
  filePath: /var/log/traefik/access.log

metrics:
  prometheus:
    addEntryPointsLabels: true
    addServicesLabels: true
```

## Secrets Management

### Vault-Struktur

**ansible/vault/homelab.yml** (encrypted with ansible-vault)
```yaml
# DNS Provider API Keys
dns_api_credentials:
  hoster_1_api_key: !vault |
    $ANSIBLE_VAULT;1.1;AES256
    66336461646...
  hoster_2_api_key: !vault |
    $ANSIBLE_VAULT;1.1;AES256  
    33663364616...
  hoster_3_api_key: !vault |
    $ANSIBLE_VAULT;1.1;AES256
    64336461646...

# VPN Authentication Keys
vpn_authentication:
  pangolin_auth_keys:
    homelab_key: !vault |
      $ANSIBLE_VAULT;1.1;AES256
      61646366343...
    campervan_key: !vault |
      $ANSIBLE_VAULT;1.1;AES256
      34663634636...
  headscale_pre_auth_keys:
    fallback_key: !vault |
      $ANSIBLE_VAULT;1.1;AES256
      63346166343...

# ACME Email Addresses
acme_email_addresses:
  enzmann_online: admin@enzmann.online
  lafritzn_de: admin@lafritzn.de
  runtunfun_de: admin@runtunfun.de

# SSH Keys
ssh_public_keys:
  tu_ansible_key: !vault |
    $ANSIBLE_VAULT;1.1;AES256
    64653336346...
```

## Automatisierung

### Makefile für Deployment-Workflows

**ansible/Makefile**
```makefile
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
```

### Ansible Configuration

**ansible/ansible.cfg**
```ini
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
```

## Deployment-Strategie

### Phasen-basierte Implementierung

**Phase 1: VPS-Infrastruktur**
```bash
cd ansible/
# Deploy VPS base infrastructure
make deploy-vps

# Verify VPN connectivity
ansible internet_vps -m ping
```

**Phase 2: Homelab-Grundlagen**
```bash
cd ansible/
# Deploy homelab base services
ansible-playbook -i inventory/production playbooks/homelab.yml --tags base

# Deploy DNS infrastructure
ansible-playbook -i inventory/production playbooks/homelab.yml --tags dns
```

**Phase 3: Service-Layer**
```bash
cd ansible/
# Deploy reverse proxy
make deploy-traefik

# Deploy remaining services
ansible-playbook -i inventory/production playbooks/homelab.yml --tags ha
```

**Phase 4: CamperVan Integration**
```bash
cd ansible/
# Deploy mobile infrastructure
make deploy-campervan

# Test end-to-end connectivity
ansible campervan -m ping
```

## Scripts-Verzeichnis

### Setup-Scripts
- **bootstrap_ansible.sh:** Initialisiert Ansible-Umgebung und Dependencies
- **generate_ssh_keys.sh:** Erstellt SSH-Schlüssel für alle technischen Benutzer
- **setup_vps.sh:** Grundkonfiguration für neue VPS-Instanzen

### Maintenance-Scripts
- **backup_configs.sh:** Sichert kritische Konfigurationsdateien
- **update_certificates.sh:** Erneuert Let's Encrypt Zertifikate manuell
- **health_check.sh:** Überprüft Status aller Services und Locations

### Monitoring-Scripts
- **check_vpn_status.sh:** Überwacht VPN-Verbindungen zwischen Locations
- **service_status.sh:** Sammelt Status-Informationen aller Services
- **network_diagnostics.sh:** Netzwerk-Konnektivitätstests

### Deployment-Scripts
- **deploy_location.sh:** Wrapper-Script für location-spezifische Deployments
- **rollback_deployment.sh:** Rollback-Mechanismus für fehlerhafte Deployments
- **test_connectivity.sh:** End-to-End Konnektivitätstests

## Dokumentations-Struktur

### Architecture-Dokumentation
- **network-design.md:** Detaillierte Netzwerk-Architektur und VLANs
- **vpn-architecture.md:** VPN-Mesh Design und Routing-Konzepte
- **security-concept.md:** Security-Prinzipien und Access-Control

### Deployment-Guides
- **installation-guide.md:** Schritt-für-Schritt Installations-Anleitung
- **troubleshooting.md:** Häufige Probleme und Lösungsansätze
- **maintenance.md:** Wartungsaufgaben und Backup-Procedures

### Service-Dokumentation
- **traefik-setup.md:** Traefik-Konfiguration und SSL-Management
- **home-assistant.md:** Home Assistant Setup und Integration
- **monitoring.md:** Monitoring-Stack und Alerting-Regeln

## Projektwissen-Archiv

### Hauptdokumente
- **01_technische_praemissen.md:** Grundlegende Designentscheidungen und Standards
- **02_netzwerk_architektur.md:** VPN-Mesh und DNS-Konzept
- **03_ansible_repository_struktur.md:** Infrastructure as Code Architektur
- **04_vpn_konzept.md:** Detaillierte VPN-Implementierung

### Planning-Sessions
- **Datum_thema.md:** Artefakte aus Claude-Chats mit Planungsergebnissen
- **session_template.md:** Template für neue Planungssessions
- **Versionierte Projektentscheidungen** aus Web-Chats

### Architektur-Entscheidungen
- **architecture_decisions.md:** ADRs (Architecture Decision Records)
- **technology_choices.md:** Begründungen für Technologie-Auswahl
- **naming_conventions.md:** Projekt-Standards und Guidelines

## Vorteile der Struktur

### Ganzheitliches Projekt
- **Einheitliches Repository:** Code, Dokumentation und Scripts zentral verwaltet
- **Klare Trennung:** Ansible, Scripts und Docs in separaten Verzeichnissen
- **Standalone-Scripts:** Unabhängig von Ansible verwendbare Tools
- **Erweiterte Dokumentation:** Vollständige Projekt-Dokumentation inkl. Wartung

### Skalierbarkeit
- **Modulare Rollen:** Wiederverwendbare Ansible-Komponenten
- **Location-agnostische Services:** Gleiche Rolle für verschiedene Standorte
- **Tag-basierte Deployments:** Granulare Steuerung möglich
- **Standalone Scripts:** Unabhängig von Ansible verwendbare Automation
- **Erweiterte Dokumentation:** Vollständige Projekt-Dokumentation

### Wartbarkeit
- **Infrastructure as Code:** Vollständig reproduzierbare Infrastruktur
- **Versionskontrolle:** Git-basierte Änderungsverfolgung für Code und Docs
- **Secrets Management:** Verschlüsselte Credentials mit ansible-vault
- **Konsistente Standards:** Einheitliche Konfiguration über alle Locations
- **Wartungs-Scripts:** Automatisierte Maintenance-Aufgaben

### Sicherheit
- **Encrypted Secrets:** Alle sensiblen Daten in Vault verschlüsselt
- **SSH-basierte Authentifizierung:** Keine Passwort-Authentifizierung
- **Granulare Berechtigungen:** Role-basierte Zugriffskontrolle
- **Audit-Trail:** Alle Änderungen in Git nachverfolgbar
- **Security-Scripts:** Automatisierte Security-Checks und Updates
- **Documentation Security:** Sichere Dokumentation ohne Secrets

## Nächste Implementierungsschritte

1. **Repository-Setup:** Git-Repository erstellen und Grundstruktur anlegen
2. **Script-Development:** Setup-Scripts für automatisierte Initialisierung
3. **VPS-Baseline:** Common-Role implementieren und auf VPS testen
4. **VPN-Integration:** VPN-Server und Client-Rollen entwickeln
5. **Service-Migration:** Bestehende Services auf Ansible-Management umstellen
6. **Monitoring-Integration:** Überwachung der Ansible-verwalteten Infrastruktur
7. **Dokumentation:** Vollständige Dokumentation aller Komponenten

**Repository-URL:** `git@github.com:username/homelab.git`

## Arbeitsweise mit Projektwissen

### Archivierung von Claude-Chat-Artefakten

**Hauptdokumente:**
```bash
# Artefakte aus Web-Chats in nummerierte Dateien
cp "Technische Prämissen.md" project-knowledge/01_technische_praemissen.md
cp "Netzwerk-Architektur.md" project-knowledge/02_netzwerk_architektur.md
cp "Ansible Repository Struktur.md" project-knowledge/03_ansible_repository_struktur.md
```

**Planning-Sessions:**
```bash
# Chat-Artefakte mit Datum und Thema archivieren
cp "Chat-Artefakt.md" project-knowledge/planning-sessions/2025-01-28_ansible_structure.md
# Wichtige Designentscheidungen in decisions/ kategorisieren
```

**Versionierung:**
- **Git-Commits:** Jede Chat-Session als separater Commit
- **Branch-Strategie:** `feature/planning-session-datum` für größere Änderungen
- **Tags:** Meilensteine in der Projektplanung markieren