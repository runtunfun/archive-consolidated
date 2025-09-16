#!/bin/bash
# TEMPORÄRES SCRIPT - liegt eine Ebene über dem homelab Repository
# create-example-config.sh
# Erstellt die Beispiel-Konfiguration für das template-basierte System

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOMELAB_DIR="$SCRIPT_DIR/homelab"

echo "📋 Creating example configuration..."
echo "📁 Script location: $SCRIPT_DIR"
echo "📁 Target homelab repo: $HOMELAB_DIR"
echo ""

# Prüfe ob homelab Repository existiert
if [[ ! -d "$HOMELAB_DIR" ]]; then
    echo "❌ Homelab repository not found at: $HOMELAB_DIR"
    echo "Please run migration from correct directory"
    exit 1
fi

# Erstelle Konfigurationsverzeichnisse im homelab Repository
echo "📁 Creating configuration directories..."
mkdir -p "$HOMELAB_DIR/config-example/environments"

echo "⚙️ Creating configuration files..."
echo ""

# Network Configuration
echo "🌐 Creating network.yml..."
cat > "$HOMELAB_DIR/config-example/network.yml" << 'EOF'
# Network Configuration
# Adjust these values to match your actual network setup

domain:
  internal: "lab.local"
  external: "example.com"  # Optional: your public domain

networks:
  management:
    vlan_id: 10
    subnet: "192.168.10.0/24"
    gateway: "192.168.10.1"
    description: "Management and infrastructure services"
  
  iot:
    vlan_id: 20
    subnet: "192.168.20.0/24"
    gateway: "192.168.20.1"
    description: "IoT devices and home automation"
  
  guest:
    vlan_id: 30
    subnet: "192.168.30.0/24"
    gateway: "192.168.30.1"
    description: "Guest network access"

dns:
  primary: "192.168.10.10"      # Usually your Pi-hole
  secondary: "192.168.10.11"    # Backup DNS or second Pi-hole
  
unifi:
  controller: "192.168.10.5"
  devices:
    - name: "USG-Pro"
      model: "UniFi Security Gateway Pro"
      ip: "192.168.10.1"
    - name: "Switch-Main"
      model: "UniFi Switch 24"
      ip: "192.168.10.2"
    - name: "AP-Living"
      model: "UniFi AC Pro"
      ip: "192.168.10.3"
EOF

# Services Configuration
echo "🐳 Creating services.yml..."
cat > "$HOMELAB_DIR/config-example/services.yml" << 'EOF'
# Services Configuration
# Enable/disable services and configure their details

services:
  pihole:
    enabled: true
    host: "pihole.lab.local"
    ip: "192.168.10.10"
    admin_port: 8080
    description: "Network-wide ad blocking and DNS server"
    version: "latest"
    
  traefik:
    enabled: true
    host: "traefik.lab.local"
    ip: "192.168.10.11"
    dashboard_port: 8080
    description: "Reverse proxy with automatic SSL certificates"
    version: "v2.10"
    
  homeassistant:
    enabled: true
    host: "ha.lab.local"
    ip: "192.168.10.20"
    port: 8123
    description: "Home automation platform"
    version: "latest"
    
  portainer:
    enabled: true
    host: "portainer.lab.local"
    ip: "192.168.10.21"
    port: 9000
    description: "Docker container management"
    
  monitoring:
    prometheus:
      enabled: true
      host: "prometheus.lab.local"
      ip: "192.168.10.30"
      port: 9090
      description: "Metrics collection and alerting"
    
    grafana:
      enabled: true
      host: "grafana.lab.local"
      ip: "192.168.10.31"
      port: 3000
      description: "Metrics visualization and dashboards"
      
    uptime_kuma:
      enabled: true
      host: "uptime.lab.local"
      ip: "192.168.10.32"
      port: 3001
      description: "Service uptime monitoring"

  media:
    plex:
      enabled: false
      host: "plex.lab.local"
      ip: "192.168.10.40"
      port: 32400
      description: "Media server"
      
    jellyfin:
      enabled: true
      host: "jellyfin.lab.local"
      ip: "192.168.10.41"
      port: 8096
      description: "Open source media server"

  productivity:
    nextcloud:
      enabled: true
      host: "nextcloud.lab.local"
      ip: "192.168.10.50"
      port: 80
      description: "File sharing and collaboration"
      
    vaultwarden:
      enabled: true
      host: "vault.lab.local"
      ip: "192.168.10.51"
      port: 8080
      description: "Password manager (Bitwarden compatible)"

docker:
  registry: "registry.lab.local"
  compose_path: "/opt/docker-compose"
  data_path: "/opt/docker-data"
  network: "homelab"
EOF

# Infrastructure Configuration
echo "🖥️ Creating infrastructure.yml..."
cat > "$HOMELAB_DIR/config-example/infrastructure.yml" << 'EOF'
# Infrastructure Configuration
# Details about your physical and virtual infrastructure

servers:
  hypervisor:
    name: "proxmox-01"
    ip: "192.168.10.100"
    role: "virtualization"
    specs:
      cpu: "Intel i7-10700"
      cores: 8
      threads: 16
      ram: "64GB"
      storage: "2x 1TB NVMe RAID1"
      network: "2x 1Gbps"
    notes: "Primary virtualization host running Proxmox VE"
  
  services:
    name: "homelab-services"
    ip: "192.168.10.101"
    role: "docker_host"
    specs:
      cpu: "Intel i5-8400"
      cores: 6
      threads: 6
      ram: "32GB"
      storage: "1TB SSD"
      network: "1Gbps"
    notes: "Docker services and container host"
    
  backup:
    name: "backup-server"
    ip: "192.168.10.102"
    role: "backup"
    specs:
      cpu: "Intel J4125"
      cores: 4
      threads: 4
      ram: "8GB"
      storage: "4TB HDD"
      network: "1Gbps"
    notes: "Dedicated backup and archive server"

storage:
  nas:
    name: "synology-ds920"
    ip: "192.168.10.200"
    model: "Synology DS920+"
    capacity: "16TB"
    raid: "RAID 5"
    shares:
      - name: "media"
        path: "/volume1/media"
        size: "8TB"
        description: "Movies, TV shows, music"
      - name: "backups"
        path: "/volume1/backups"
        size: "4TB"
        description: "System and application backups"
      - name: "documents"
        path: "/volume1/documents"
        size: "2TB"
        description: "Personal and work documents"

backup:
  strategy: "3-2-1 Rule"
  local:
    path: "/mnt/backup"
    retention: "30 days"
    schedule: "Daily incremental"
  offsite:
    provider: "AWS S3"
    bucket: "homelab-backups"
    retention: "1 year"
    schedule: "Weekly full backup"
  archive:
    provider: "AWS Glacier"
    retention: "7 years"
    schedule: "Monthly archive"

networking:
  internet:
    provider: "Local ISP"
    speed: "1000/50 Mbps"
    static_ip: false
  
  firewall:
    model: "UniFi Security Gateway Pro"
    rules: "Restrictive by default"
    vpn: "WireGuard"
    
  switches:
    - name: "Main Switch"
      model: "UniFi Switch 24"
      ports: 24
      poe: true
      location: "Server rack"
      
  access_points:
    - name: "Living Room AP"
      model: "UniFi AC Pro"
      location: "Living room ceiling"
    - name: "Office AP"
      model: "UniFi AC Lite"
      location: "Office"
EOF

# Documentation Configuration
echo "📚 Creating documentation.yml..."
cat > "$HOMELAB_DIR/config-example/documentation.yml" << 'EOF'
# Documentation Configuration
# Settings for the generated documentation site

site:
  name: "My Homelab Documentation"
  description: "Comprehensive homelab infrastructure and services documentation"
  author: "Your Name"
  url: "https://your-username.github.io/homelab"
  repository: "https://github.com/your-username/homelab"

branding:
  logo: "assets/logo.png"
  favicon: "assets/favicon.ico"
  primary_color: "indigo"
  accent_color: "blue"
  theme: "material"

features:
  search: true
  dark_mode: true
  edit_links: true
  git_info: true
  analytics: false
  comments: false
  
social:
  github: "your-username"
  twitter: "your-handle"
  linkedin: "your-profile"

navigation:
  show_automation: true
  show_monitoring: true
  show_security: true
  show_planning: true
  show_troubleshooting: true
  
content:
  show_last_updated: true
  show_edit_page: true
  show_source_link: true
  enable_pdf_export: false

# Analytics (optional)
analytics:
  google_analytics: ""  # GA4 tracking ID
  plausible: ""         # Plausible domain
EOF

# Environment-specific configurations
echo "🔧 Creating environment configurations..."

cat > "$HOMELAB_DIR/config-example/environments/production.yml" << 'EOF'
# Production Environment Overrides
# These settings override the base configuration for production

ansible_env: "production"

# Production-specific domain (if different)
domain:
  internal: "homelab.local"
  external: "yourdomain.com"

# Production network settings (example: different subnets)
networks:
  management:
    subnet: "10.0.10.0/24"
    gateway: "10.0.10.1"
  iot:
    subnet: "10.0.20.0/24"
    gateway: "10.0.20.1"

# Enable all monitoring in production
services:
  monitoring:
    prometheus:
      enabled: true
      retention: "90d"
    grafana:
      enabled: true
    uptime_kuma:
      enabled: true

# Production-specific backup settings
backup:
  local:
    retention: "90 days"
  offsite:
    retention: "2 years"

# Enhanced security for production
security:
  fail2ban: true
  ufw: true
  automatic_updates: true
  ssh_key_only: true
EOF

cat > "$HOMELAB_DIR/config-example/environments/test.yml" << 'EOF'
# Test Environment Overrides
# Minimal configuration for testing

ansible_env: "test"

# Test-specific settings
domain:
  internal: "test.local"

# Minimal services for testing
services:
  pihole:
    enabled: true
  traefik:
    enabled: false
  homeassistant:
    enabled: false
  monitoring:
    prometheus:
      enabled: false
    grafana:
      enabled: false

# Reduced backup retention for testing
backup:
  local:
    retention: "7 days"
  offsite:
    enabled: false
EOF

cat > "$HOMELAB_DIR/config-example/environments/development.yml" << 'EOF'
# Development Environment Overrides
# Local development and testing settings

ansible_env: "development"

domain:
  internal: "dev.local"

# Development-friendly settings
services:
  pihole:
    enabled: true
  traefik:
    enabled: true
  homeassistant:
    enabled: true
  monitoring:
    prometheus:
      enabled: true
    grafana:
      enabled: true

# Local development settings
docker:
  compose_path: "./docker-compose"
  data_path: "./docker-data"

# Minimal backup for development
backup:
  local:
    retention: "3 days"
  offsite:
    enabled: false
EOF

echo ""
echo "✅ Example configuration created successfully!"
echo ""
echo "📋 Created configuration files in homelab repository:"
echo "  - config-example/network.yml           # Network and domain settings"
echo "  - config-example/services.yml          # Service definitions"
echo "  - config-example/infrastructure.yml    # Hardware and infrastructure"
echo "  - config-example/documentation.yml     # Documentation settings"
echo "  - config-example/environments/         # Environment-specific overrides"
echo "    ├── production.yml"
echo "    ├── test.yml"
echo "    └── development.yml"
echo ""
echo "💡 Next steps:"
echo "1. Copy config-example to config-local: cp -r homelab/config-example homelab/config-local"
echo "2. Edit homelab/config-local/*.yml files to match your infrastructure"
echo "3. Run: cd homelab && ./scripts/setup/setup-environment.sh"
echo ""
echo "🔧 To use environment-specific configs:"
echo "  HOMELAB_ENV=production ./homelab/scripts/build/build.sh"
echo "  HOMELAB_ENV=test ./homelab/scripts/build/develop.sh"