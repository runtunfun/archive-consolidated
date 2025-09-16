#!/bin/bash
# PERMANENTES SCRIPT - wird ins Git eingecheckt
# scripts/maintenance/generate-ansible-templates.sh
# Generiert Dokumentations-Templates für Ansible-Komponenten

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo "🤖 Generating Ansible documentation templates..."
echo "📁 Project root: $PROJECT_ROOT"
echo ""

# Erstelle alle benötigten Verzeichnisse
echo "📁 Creating template directories..."
mkdir -p "$PROJECT_ROOT/templates/docs/automation/roles"
mkdir -p "$PROJECT_ROOT/templates/docs/automation/playbooks"

# Erstelle Automation Index Template
echo "📝 Creating automation index template..."
cat > "$PROJECT_ROOT/templates/docs/automation/index.md.j2" << 'AUTOMATION_INDEX_EOF'
{#
Template: Automation Overview
Description: Main automation documentation index
Variables:
  - site: Site configuration
  - services: Service definitions
  - ansible_env: Ansible environment
#}

# Infrastructure Automation

Welcome to the automation documentation for {{ site.name | default("the homelab") }}.

## 🏗️ Infrastructure as Code

Our homelab infrastructure is fully automated using Ansible, providing:
- **Consistent deployments** across all environments
- **Version-controlled configuration**
- **Repeatable infrastructure setup**
- **Automated service deployment**

## 📚 Documentation Sections

- [**Ansible Overview**](ansible-overview.md) - Complete automation setup
- [**Roles Documentation**](roles.md) - Available Ansible roles
- [**Playbooks**](playbooks.md) - Automation playbooks
- [**Inventories**](inventories.md) - Environment definitions

## 🚀 Quick Start

### System Setup
```bash
cd ansible
ansible-playbook -i inventories/{{ ansible_env | default("production") }} playbooks/system-setup.yml
```

### Service Deployment  
```bash
ansible-playbook -i inventories/{{ ansible_env | default("production") }} playbooks/docker-services.yml
```

## 🎯 Common Tasks

### Update All Systems
```bash
ansible-playbook -i inventories/{{ ansible_env | default("production") }} playbooks/system-update.yml
```

### Deploy Security Configuration
```bash
ansible-playbook -i inventories/{{ ansible_env | default("production") }} playbooks/security-setup.yml
```

### Service-Specific Deployments
{% for service_name, service_config in services.items() %}
{% if service_config.enabled %}
```bash
# Deploy {{ service_name | title }}
ansible-playbook -i inventories/{{ ansible_env | default("production") }} playbooks/{{ service_name }}-deploy.yml
```
{% endif %}
{% endfor %}

## 📊 Infrastructure Status

| Component | Status | Environment |
|-----------|--------|-------------|
| Automation | ✅ Active | {{ ansible_env | default("production") }} |
| Services | {{ services | length }} configured | {{ services | selectattr("enabled") | list | length }} enabled |
| Environments | Multiple | test, production |

## 🔧 Configuration

Central configuration is managed through:
- `group_vars/all.yml` - Global variables
- `inventories/*/group_vars/` - Environment-specific settings
- External configuration files (this documentation system)
AUTOMATION_INDEX_EOF

# Erstelle Ansible Overview Template
echo "📝 Creating ansible overview template..."
cat > "$PROJECT_ROOT/templates/docs/automation/ansible-overview.md.j2" << 'ANSIBLE_OVERVIEW_EOF'
{#
Template: Ansible Overview
Description: Detailed Ansible setup documentation
Variables:
  - site: Site configuration
  - domain: Domain settings
  - networks: Network configuration
  - services: Service definitions
  - ansible_env: Environment name
#}

# Ansible Automation Overview

This document provides a comprehensive overview of the Ansible automation setup for {{ site.name | default("the homelab") }}.

## 🏗️ Infrastructure as Code Philosophy

Our infrastructure follows the Infrastructure as Code (IaC) principles:

- **Version Control**: All configuration is stored in Git
- **Reproducibility**: Infrastructure can be recreated from scratch
- **Documentation**: Code serves as living documentation
- **Testing**: Changes can be tested before production deployment
- **Collaboration**: Team members can review and contribute

## 📁 Repository Structure

```
ansible/
├── playbooks/              # Main automation playbooks
│   ├── site.yml            # Main site deployment
│   ├── system-setup.yml    # Initial system configuration
│   ├── security-setup.yml  # Security hardening
│   └── service-*.yml       # Service-specific deployments
├── roles/                  # Reusable automation roles
│   ├── r_apt_update/       # System package management
│   ├── r_install_docker/   # Docker installation
│   ├── r_configure_fail2ban/ # Security configuration
│   └── r_docker_install_*/ # Service deployment roles
├── inventories/            # Environment definitions
│   ├── production/         # Production servers
│   ├── test/              # Testing environment
│   └── development/       # Development setup
└── group_vars/            # Configuration variables
    ├── all.yml            # Global configuration
    └── */                 # Group-specific variables
```

## 🎯 Core Commands

### System Management
```bash
# Update all systems
ansible-playbook -i inventories/{{ ansible_env | default("production") }} playbooks/system-update.yml

# Deploy security configurations
ansible-playbook -i inventories/{{ ansible_env | default("production") }} playbooks/security-setup.yml

# Check system status
ansible -i inventories/{{ ansible_env | default("production") }} all -m ping
```

### Service Deployment
```bash
# Deploy all services
ansible-playbook -i inventories/{{ ansible_env | default("production") }} playbooks/site.yml

# Deploy specific services
{% for service_name, service_config in services.items() %}
{% if service_config.enabled %}
ansible-playbook -i inventories/{{ ansible_env | default("production") }} playbooks/{{ service_name }}-deploy.yml
{% endif %}
{% endfor %}
```

### Dry Run and Testing
```bash
# Test without making changes
ansible-playbook -i inventories/{{ ansible_env | default("production") }} playbooks/site.yml --check

# Verbose output for debugging
ansible-playbook -i inventories/{{ ansible_env | default("production") }} playbooks/site.yml -vvv
```

## 🔧 Configuration Management

### Global Variables
Central configuration is managed in `group_vars/all.yml`:

```yaml
# Domain configuration
internal_domain: "{{ domain.internal }}"
external_domain: "{{ domain.external | default('') }}"

# Network configuration
{% for network_name, network_config in networks.items() %}
{{ network_name }}_vlan: {{ network_config.vlan_id }}
{{ network_name }}_subnet: "{{ network_config.subnet }}"
{{ network_name }}_gateway: "{{ network_config.gateway }}"
{% endfor %}

# Service configuration
{% for service_name, service_config in services.items() %}
{% if service_config.enabled %}
{{ service_name }}_enabled: true
{{ service_name }}_host: "{{ service_config.host }}"
{{ service_name }}_ip: "{{ service_config.ip }}"
{% endif %}
{% endfor %}
```

### Environment-Specific Configuration
Each environment can override global settings:

- `inventories/production/group_vars/all.yml` - Production overrides
- `inventories/test/group_vars/all.yml` - Test environment settings
- `inventories/development/group_vars/all.yml` - Development configuration

## 🛡️ Security Considerations

### SSH Key Management
```bash
# Generate SSH key for Ansible
ssh-keygen -t ed25519 -f ~/.ssh/ansible_key

# Deploy public key to servers
ssh-copy-id -i ~/.ssh/ansible_key.pub user@server
```

### Vault for Secrets
```bash
# Create encrypted vault file
ansible-vault create group_vars/all/vault.yml

# Edit existing vault
ansible-vault edit group_vars/all/vault.yml

# Run playbook with vault
ansible-playbook -i inventories/production playbooks/site.yml --ask-vault-pass
```

## 📊 Monitoring and Maintenance

### Regular Tasks
- **Daily**: Automated security updates
- **Weekly**: Full system updates via Ansible
- **Monthly**: Security audit and role updates
- **Quarterly**: Infrastructure review and optimization

### Health Checks
```bash
# Check all services are running
ansible -i inventories/{{ ansible_env | default("production") }} all -m service -a "name=docker state=started"

# Verify disk space
ansible -i inventories/{{ ansible_env | default("production") }} all -m shell -a "df -h"

# Check system load
ansible -i inventories/{{ ansible_env | default("production") }} all -m shell -a "uptime"
```

## 🔄 Development Workflow

### Making Changes
1. **Create branch**: `git checkout -b feature/new-service`
2. **Develop locally**: Test in development environment
3. **Test staging**: Deploy to test environment
4. **Code review**: Create pull request
5. **Deploy production**: Merge and deploy

### Testing Strategy
```bash
# Test syntax
ansible-playbook --syntax-check playbooks/site.yml

# Test with check mode
ansible-playbook -i inventories/test playbooks/site.yml --check

# Deploy to test environment
ansible-playbook -i inventories/test playbooks/site.yml

# Deploy to production
ansible-playbook -i inventories/production playbooks/site.yml
```

## 📚 Best Practices

### Role Development
- Keep roles focused and single-purpose
- Use meaningful variable names
- Include comprehensive README files
- Write idempotent tasks
- Use handlers for service restarts

### Playbook Organization
- Group related tasks into roles
- Use descriptive playbook names
- Include task documentation
- Implement proper error handling
- Use tags for selective execution

### Security Guidelines
- Never store secrets in plain text
- Use Ansible Vault for sensitive data
- Regularly update roles and playbooks
- Implement least privilege access
- Monitor automation logs

## 🚨 Troubleshooting

### Common Issues
- **Connection failures**: Check SSH keys and network connectivity
- **Permission errors**: Verify sudo access and user privileges
- **Service failures**: Check service logs and dependencies
- **Variable errors**: Validate YAML syntax and variable definitions

### Debug Commands
```bash
# Verbose output
ansible-playbook -vvv playbooks/site.yml

# Connection testing
ansible -m ping all

# Gather system facts
ansible -m setup hostname

# Check specific service
ansible -m service -a "name=docker" hostname
```
ANSIBLE_OVERVIEW_EOF

# Erstelle Roles Template
echo "📝 Creating roles template..."
cat > "$PROJECT_ROOT/templates/docs/automation/roles.md.j2" << 'ROLES_EOF'
{#
Template: Ansible Roles
Description: Documentation for all Ansible roles
Variables:
  - services: Service configuration
  - domain: Domain settings
#}

# Ansible Roles

This document describes all available Ansible roles in our infrastructure automation.

## 🛠️ System Management Roles

### Package Management
| Role | Description | Usage | Frequency |
|------|-------------|-------|-----------|
| `r_apt_update` | System updates via APT | System maintenance | Daily |
| `r_apt_software_cleanup` | Remove unused packages | Cleanup automation | Weekly |

### User and Security Management
| Role | Description | Usage | Frequency |
|------|-------------|-------|-----------|
| `r_create_config_mgmt_user` | Configuration management user | Initial setup | Once |
| `r_configure_fail2ban` | Intrusion detection setup | Security hardening | Initial + updates |

## 🐳 Container Platform Roles

### Docker Infrastructure
| Role | Description | Prerequisites | Platforms |
|------|-------------|---------------|-----------|
| `r_install_docker` | Docker & Docker Compose installation | Ubuntu/Debian | All servers |

## 📦 Service Deployment Roles

### Core Services
{% for service_name, service_config in services.items() %}
{% if service_config.enabled %}
| `r_docker_install_{{ service_name }}` | {{ service_config.description | default(service_name | title + " deployment") }} | Docker | [{{ service_config.host }}](http://{{ service_config.host }}) |
{% endif %}
{% endfor %}

## 🔧 Role Usage Examples

### Complete System Setup
```yaml
---
- name: Complete system setup
  hosts: all
  become: yes
  roles:
    # System preparation
    - r_apt_update
    - r_create_config_mgmt_user
    
    # Security hardening
    - r_configure_fail2ban
    
    # Container platform
    - r_install_docker
    
    # Services deployment
{% for service_name, service_config in services.items() %}
{% if service_config.enabled %}
    - r_docker_install_{{ service_name }}
{% endif %}
{% endfor %}
```

### Selective Service Deployment
```yaml
---
- name: Deploy monitoring services
  hosts: monitoring_servers
  become: yes
  roles:
{% for service_name, service_config in services.items() %}
{% if service_config.enabled and 'monitoring' in service_name %}
    - r_docker_install_{{ service_name }}
{% endif %}
{% endfor %}
```

### Security-Only Deployment
```yaml
---
- name: Security hardening
  hosts: all
  become: yes
  roles:
    - r_configure_fail2ban
    - r_apt_update
```

## 📝 Role Development Guidelines

### Directory Structure
Each role follows the standard Ansible structure:
```
roles/role_name/
├── README.md              # Role documentation
├── defaults/main.yml      # Default variables
├── vars/main.yml          # Role variables
├── tasks/main.yml         # Main tasks
├── handlers/main.yml      # Handlers (service restarts, etc.)
├── templates/             # Jinja2 templates
├── files/                 # Static files
├── meta/main.yml          # Role metadata and dependencies
└── tests/                 # Role tests
```

### Variable Naming Convention
- Role-specific variables: `rolename_variable`
- Global variables: `global_variable`
- Service-specific: `service_name_setting`

### Best Practices
1. **Idempotency**: Roles can be run multiple times safely
2. **Error Handling**: Proper error handling and validation
3. **Documentation**: Clear README with examples
4. **Testing**: Include test scenarios
5. **Dependencies**: Declare role dependencies in meta/main.yml

## 🧪 Testing Roles

### Local Testing
```bash
# Test role syntax
ansible-playbook --syntax-check site.yml

# Test with check mode (dry run)
ansible-playbook -i inventories/test site.yml --check

# Test specific role
ansible-playbook -i inventories/test site.yml --tags "docker"
```

### Role Dependencies
Some roles have dependencies on others:
- Container services → `r_install_docker`
- All services → `r_apt_update`
- Security services → `r_configure_fail2ban`

## 📊 Role Status and Maintenance

### Role Lifecycle
- **Development**: New roles in feature branches
- **Testing**: Validation in test environment
- **Production**: Deployed to production after testing
- **Maintenance**: Regular updates and security patches

### Update Schedule
- **Security roles**: As needed (immediate for security issues)
- **System roles**: Monthly updates
- **Service roles**: With application updates
- **All roles**: Quarterly review and optimization
ROLES_EOF

# Erstelle Playbooks Template
echo "📝 Creating playbooks template..."
cat > "$PROJECT_ROOT/templates/docs/automation/playbooks.md.j2" << 'PLAYBOOKS_EOF'
{#
Template: Ansible Playbooks
Description: Documentation for all Ansible playbooks
Variables:
  - services: Service configuration
  - ansible_env: Environment name
#}

# Ansible Playbooks

This document describes all available Ansible playbooks for infrastructure automation.

## 🎭 Main Playbooks

### Site-wide Deployment
| Playbook | Description | Target | Usage |
|----------|-------------|--------|--------|
| `site.yml` | Complete infrastructure deployment | All hosts | Initial setup, full deployment |
| `system-setup.yml` | Basic system configuration | All hosts | Initial system preparation |
| `security-setup.yml` | Security hardening | All hosts | Security configuration |

### System Management
| Playbook | Description | Schedule | Impact |
|----------|-------------|----------|--------|
| `system-update.yml` | System package updates | Daily | Low |
| `system-cleanup.yml` | Cleanup and maintenance | Weekly | Low |
| `backup-setup.yml` | Backup configuration | Monthly | Medium |

## 🐳 Service Deployment Playbooks

### Individual Services
{% for service_name, service_config in services.items() %}
{% if service_config.enabled %}
| `{{ service_name }}-deploy.yml` | Deploy {{ service_config.description | default(service_name | title) }} | Service host | [{{ service_config.host }}](http://{{ service_config.host }}) |
{% endif %}
{% endfor %}

### Service Groups
| Playbook | Services | Purpose |
|----------|----------|---------|
| `monitoring-deploy.yml` | Prometheus, Grafana, Uptime Kuma | Complete monitoring stack |
| `media-deploy.yml` | Jellyfin, Plex | Media server setup |
| `productivity-deploy.yml` | Nextcloud, Vaultwarden | Productivity services |

## 🎯 Usage Examples

### Initial Infrastructure Setup
```bash
# Complete infrastructure deployment
ansible-playbook -i inventories/{{ ansible_env | default("production") }} site.yml

# Step-by-step deployment
ansible-playbook -i inventories/{{ ansible_env | default("production") }} system-setup.yml
ansible-playbook -i inventories/{{ ansible_env | default("production") }} security-setup.yml
ansible-playbook -i inventories/{{ ansible_env | default("production") }} docker-services.yml
```

### Regular Maintenance
```bash
# Daily: System updates
ansible-playbook -i inventories/{{ ansible_env | default("production") }} system-update.yml

# Weekly: System cleanup
ansible-playbook -i inventories/{{ ansible_env | default("production") }} system-cleanup.yml

# Monthly: Security audit
ansible-playbook -i inventories/{{ ansible_env | default("production") }} security-audit.yml
```

### Service Management
```bash
{% for service_name, service_config in services.items() %}
{% if service_config.enabled %}
# Deploy {{ service_name | title }}
ansible-playbook -i inventories/{{ ansible_env | default("production") }} {{ service_name }}-deploy.yml

{% endif %}
{% endfor %}
```

### Emergency Procedures
```bash
# Stop all services
ansible-playbook -i inventories/{{ ansible_env | default("production") }} emergency-stop.yml

# Restore from backup
ansible-playbook -i inventories/{{ ansible_env | default("production") }} restore-backup.yml

# Security incident response
ansible-playbook -i inventories/{{ ansible_env | default("production") }} incident-response.yml
```

## 🏷️ Playbook Tags

Use tags for selective execution:

### System Tags
- `system`: System-level tasks
- `security`: Security-related tasks
- `packages`: Package management
- `users`: User management

### Service Tags
- `docker`: Docker-related tasks
- `monitoring`: Monitoring services
- `media`: Media services
- `productivity`: Productivity tools

### Operational Tags
- `deploy`: Deployment tasks
- `config`: Configuration updates
- `restart`: Service restarts
- `backup`: Backup operations

### Tag Usage Examples
```bash
# Only security tasks
ansible-playbook -i inventories/production site.yml --tags "security"

# Everything except restarts
ansible-playbook -i inventories/production site.yml --skip-tags "restart"

# Only Docker services
ansible-playbook -i inventories/production site.yml --tags "docker"
```

## 🔧 Playbook Variables

### Global Variables
Available in all playbooks through `group_vars/all.yml`:
- `internal_domain`: {{ domain.internal }}
- `external_domain`: {{ domain.external | default("Not configured") }}
- Network configurations for all VLANs
- Service configurations for all enabled services

### Environment-Specific Variables
Override global settings per environment:
- Production: Enhanced security, full monitoring
- Test: Minimal services, relaxed security
- Development: Local paths, debug enabled

## 📊 Execution Patterns

### Safe Deployment Pattern
```bash
# 1. Test syntax
ansible-playbook --syntax-check site.yml

# 2. Dry run
ansible-playbook -i inventories/test site.yml --check

# 3. Deploy to test environment
ansible-playbook -i inventories/test site.yml

# 4. Deploy to production
ansible-playbook -i inventories/production site.yml
```

### Rolling Updates Pattern
```bash
# Update one host at a time
ansible-playbook -i inventories/production site.yml --serial 1

# Update specific group
ansible-playbook -i inventories/production site.yml --limit webservers
```

### Maintenance Window Pattern
```bash
# Stop services
ansible-playbook -i inventories/production service-stop.yml

# Perform maintenance
ansible-playbook -i inventories/production maintenance.yml

# Start services
ansible-playbook -i inventories/production service-start.yml
```

## 🚨 Troubleshooting Playbooks

### Common Issues and Solutions

#### Playbook Hangs
```bash
# Add timeout and increase verbosity
ansible-playbook -i inventories/production site.yml -vvv --timeout=60
```

#### Connection Issues
```bash
# Test connectivity first
ansible -i inventories/production all -m ping

# Use specific user
ansible-playbook -i inventories/production site.yml -u ansible_user
```

#### Permission Problems
```bash
# Verify sudo access
ansible -i inventories/production all -m shell -a "sudo whoami" --become

# Check SSH key authentication
ansible -i inventories/production all -m shell -a "whoami"
```

### Debug Mode
```bash
# Maximum verbosity
ansible-playbook -i inventories/production site.yml -vvvv

# Step through tasks
ansible-playbook -i inventories/production site.yml --step

# Start from specific task
ansible-playbook -i inventories/production site.yml --start-at-task="Install Docker"
```

## 📈 Performance Optimization

### Parallel Execution
```yaml
# In playbook
strategy: free
serial: 5  # Process 5 hosts at a time
```

### Fact Caching
```yaml
# In ansible.cfg
fact_caching = redis
fact_caching_timeout = 86400
```

### Connection Optimization
```yaml
# In inventory
[all:vars]
ansible_ssh_pipelining=true
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

This playbook documentation ensures efficient and reliable infrastructure automation across all environments.
PLAYBOOKS_EOF

echo ""
echo "✅ Ansible template generation completed successfully!"
echo ""
echo "📋 Generated templates:"
echo "  - templates/docs/automation/index.md.j2"
echo "  - templates/docs/automation/ansible-overview.md.j2"
echo "  - templates/docs/automation/roles.md.j2"
echo "  - templates/docs/automation/playbooks.md.j2"
echo ""
echo "🎯 These templates will be populated with your actual:"
echo "  - Service configurations from services.yml"
echo "  - Network settings from network.yml"
echo "  - Environment settings"
echo ""
echo "💡 Regenerate these templates anytime by running this script again."