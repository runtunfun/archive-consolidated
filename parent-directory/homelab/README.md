# 🏠 Homelab Infrastructure & Documentation

> **A comprehensive, template-based homelab management system combining infrastructure automation with dynamic documentation generation.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Documentation](https://img.shields.io/badge/docs-mkdocs-blue.svg)](https://mkdocs.org)
[![Ansible](https://img.shields.io/badge/automation-ansible-red.svg)](https://www.ansible.com)
[![Python](https://img.shields.io/badge/generator-python-green.svg)](https://python.org)

## 🎯 What is this?

This repository provides a **unified solution** for homelab infrastructure management, combining:

- **🤖 Infrastructure as Code** - Ansible automation for consistent deployments
- **📚 Dynamic Documentation** - Template-based docs that adapt to your specific setup
- **⚙️ Configuration Management** - Centralized config with environment-specific overrides
- **🔧 Build Pipeline** - Automated generation of personalized documentation

Instead of maintaining static documentation that quickly becomes outdated, this system generates **living documentation** from your actual infrastructure configuration.

## ✨ Key Features

### 🎨 Template-Based Documentation
- **Example data in templates** - Share publicly without exposing sensitive information
- **Real data in config** - Keep your actual network details private
- **Jinja2 templating** - Dynamic content generation based on your configuration
- **Multi-environment support** - Different configs for production, testing, development

### 🤖 Infrastructure Automation
- **Ansible playbooks & roles** - Proven automation for common homelab services
- **Docker service deployment** - Pi-hole, Traefik, monitoring stack, and more
- **Security hardening** - fail2ban, user management, system maintenance
- **Modular design** - Pick and choose components that fit your needs

### 📖 Intelligent Documentation
- **Auto-generated content** - Network diagrams, service inventories, configuration tables
- **Cross-referenced information** - Links between related services and configurations
- **Searchable knowledge base** - Find information quickly with full-text search
- **Mobile-friendly** - Access your documentation from any device

### 🔒 Privacy & Security
- **Configurable anonymization** - Templates use example data (lab.local, 192.168.x.x)
- **Sensitive data separation** - Real configuration kept in separate, private repositories
- **Environment isolation** - Different configs for different environments
- **Secrets management** - Proper handling of credentials and sensitive data

## 🚀 Quick Start

### 1. Clone and Setup
```bash
git clone https://github.com/your-username/homelab.git
cd homelab

# Setup Python environment and dependencies
./scripts/setup/setup-environment.sh
source venv/bin/activate
```

### 2. Create Your Configuration
```bash
# Start with example configuration
cp -r config-example config-local

# Edit to match your infrastructure
vim config-local/network.yml
vim config-local/services.yml
vim config-local/infrastructure.yml
```

### 3. Generate Documentation
```bash
# Development server with live reload
HOMELAB_CONFIG_PATH=./config-local ./scripts/build/develop.sh

# Production build
HOMELAB_CONFIG_PATH=./config-local ./scripts/build/build.sh
```

### 4. Deploy Infrastructure
```bash
# Run Ansible playbooks
cd ansible
ansible-playbook -i inventories/production playbooks/site.yml
```

## 📁 Repository Structure

```
homelab/
├── 📝 templates/              # Documentation templates with example data
│   ├── docs/                  # Markdown templates (*.md.j2)
│   ├── mkdocs.yml.j2          # MkDocs configuration template
│   └── assets/                # Static assets (images, CSS)
├── 🤖 ansible/               # Infrastructure automation
│   ├── playbooks/             # Ansible playbooks
│   ├── roles/                 # Reusable Ansible roles
│   ├── inventories/           # Environment-specific inventories
│   └── group_vars/            # Ansible variables
├── 🔧 scripts/               # Automation scripts
│   ├── generator/             # Documentation generator
│   ├── build/                 # Build and deployment scripts
│   └── setup/                 # Environment setup scripts
├── 📋 config-example/         # Example configuration (safe to share)
│   ├── network.yml            # Network configuration
│   ├── services.yml           # Service definitions
│   ├── infrastructure.yml     # Hardware specifications
│   └── environments/          # Environment-specific overrides
├── 📖 docs/                   # Generated documentation (git-ignored)
└── 🌐 site/                   # Built website (git-ignored)
```

## ⚙️ Configuration System

The template system uses YAML configuration files to generate personalized documentation:

### Basic Structure
```yaml
# network.yml - Network configuration
domain:
  internal: "lab.local"
  external: "example.com"

networks:
  management:
    vlan_id: 10
    subnet: "192.168.10.0/24"

# services.yml - Service definitions  
services:
  pihole:
    enabled: true
    host: "pihole.lab.local"
    ip: "192.168.10.10"
```

### Environment Support
```bash
# Production environment
HOMELAB_ENV=production ./scripts/build/build.sh

# Test environment  
HOMELAB_ENV=test ./scripts/build/develop.sh

# Custom configuration path
HOMELAB_CONFIG_PATH=./my-config ./scripts/build/build.sh
```

**For complete configuration examples and detailed setup:** [→ **Configuration Guide**](QUICKSTART.md#-step-2-configuration)

## 🎨 Template Examples

### Dynamic Service Lists
Templates automatically generate service documentation based on your configuration:

```markdown
<!-- Template input -->
{% for service_name, service_config in services.items() %}
{% if service_config.enabled %}
- **{{ service_name | title }}:** [{{ service_config.host }}](http://{{ service_config.host }})
{% endif %}
{% endfor %}

<!-- Generated output -->
- **Pihole:** [pihole.lab.local](http://pihole.lab.local)
- **Home Assistant:** [ha.lab.local](http://ha.lab.local)
```

### Network Documentation
VLAN configurations are automatically documented:

```markdown
| VLAN ID | Name | Subnet | Purpose |
|---------|------|--------|---------|
{% for vlan_name, vlan_config in networks.items() %}
| {{ vlan_config.vlan_id }} | {{ vlan_name | title }} | {{ vlan_config.subnet }} | {{ vlan_name | title }} network |
{% endfor %}
```

## 🔄 Workflow Examples

### Development Workflow
```bash
# 1. Edit configuration
vim config-local/services.yml

# 2. Preview changes with live reload
./scripts/build/develop.sh

# 3. Apply infrastructure changes
cd ansible && ansible-playbook -i inventories/production playbooks/site.yml
```

### Production Deployment
```bash
# Build and deploy documentation
HOMELAB_ENV=production ./scripts/build/build.sh
./scripts/build/deploy.sh github

# Apply infrastructure automation
cd ansible && ansible-playbook -i inventories/production playbooks/site.yml
```

### Multi-Environment Management
```bash
# Separate configurations for different environments
HOMELAB_CONFIG_PATH=./config-production ./scripts/build/build.sh
HOMELAB_CONFIG_PATH=./config-test ./scripts/build/develop.sh
```

**For detailed workflows, use cases, and troubleshooting:** [→ **Quick Start Guide**](QUICKSTART.md#-common-use-cases)

## 🏗️ Supported Infrastructure

### 🐳 Container Services
- **Pi-hole** - Network-wide ad blocking and DNS
- **Traefik** - Reverse proxy with automatic SSL
- **Home Assistant** - Home automation platform
- **Prometheus & Grafana** - Monitoring and visualization
- **Portainer** - Docker container management

### 🔐 Security & Management
- **fail2ban** - Intrusion detection and prevention
- **UFW** - Uncomplicated firewall configuration
- **Unattended upgrades** - Automatic security updates
- **SSH hardening** - Secure remote access configuration

### 🌐 Network Infrastructure
- **UniFi integration** - Ubiquiti network equipment management
- **VLAN configuration** - Network segmentation
- **DNS management** - Internal and external DNS setup
- **SSL/TLS certificates** - Automated certificate management

## 📚 Documentation Features

### 📊 Auto-Generated Content
- **Network topology diagrams** - Visual representation of your network
- **Service dependency maps** - Understanding service relationships
- **Hardware inventory** - Detailed equipment specifications
- **Monitoring dashboards** - Links to all monitoring interfaces

### 🔍 Enhanced Navigation
- **Tabbed interface** - Organized content sections
- **Search functionality** - Find information quickly
- **Cross-references** - Links between related topics
- **Mobile responsive** - Access from any device

### 🎨 Customization
- **Theme selection** - Light/dark modes
- **Branding options** - Custom logos and colors
- **Content organization** - Flexible navigation structure
- **Export options** - PDF generation for offline access

## 🚀 Migration from Existing Setups

### Automated Migration
```bash
# Migrate from existing Infrastructure and homelab-docs repositories
./scripts/setup/migrate-from-repos.sh ../Infrastructure ../homelab-docs
```

### Manual Migration Steps
1. **Copy existing docs** to `templates/docs/` and add `.j2` extension
2. **Replace static values** with template variables 
3. **Create configuration files** with your actual values
4. **Generate and review** the output

**For detailed migration instructions and troubleshooting:** [→ **Migration Guide**](QUICKSTART.md#option-c-migration-from-existing-repositories)

## 🤝 Contributing

We welcome all types of contributions! See our [**📋 Contributing Guide**](CONTRIBUTING.md) for detailed information on:

- 🐛 **Bug Reports** - Templates and guidelines for effective reporting
- 💡 **Feature Requests** - How to propose new features and improvements
- 🔧 **Code Contributions** - Standards for Python, Bash, and Ansible code
- 📚 **Documentation** - Template development and documentation standards
- 🎨 **Design & UI** - Themes, styling, and user experience improvements
- 🧪 **Testing** - Unit tests, integration tests, and quality assurance

### Quick Contribution Types

| Type | Description | Get Started |
|------|-------------|-------------|
| 🚀 **Templates** | Add new service documentation templates | [Template Guide](CONTRIBUTING.md#-template-contributions) |
| 🤖 **Ansible** | Infrastructure automation roles/playbooks | [Ansible Standards](CONTRIBUTING.md#ansible-code) |
| 📖 **Docs** | Improve guides and documentation | [Documentation Standards](CONTRIBUTING.md#-documentation-contributions) |
| 🐛 **Bugs** | Report issues or submit fixes | [Bug Report Template](CONTRIBUTING.md#-bug-reports) |

**First time contributing?** We offer [mentorship and guidance](CONTRIBUTING.md#-getting-help) for new contributors.

**Quick start for contributors:** [→ **Development Setup Guide**](CONTRIBUTING.md#-getting-started)

## 📋 Requirements

### System Requirements
- **Python 3.8+** - For documentation generation
- **Ansible 2.9+** - For infrastructure automation
- **Git** - For version control and submodules

### Python Dependencies
- **Jinja2** - Template processing
- **PyYAML** - Configuration file parsing
- **MkDocs** - Documentation site generation
- **MkDocs Material** - Modern documentation theme

### Supported Target Systems
- **Debian/Ubuntu** - Primary support
- **RHEL/CentOS** - Basic support
- **Docker hosts** - Any Docker-compatible system

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **MkDocs community** - For the excellent documentation framework
- **Ansible community** - For robust automation tools
- **Homelab community** - For inspiration and shared knowledge
- **UniFi ecosystem** - For reliable network infrastructure

## 🔗 Related Projects

- [Awesome Homelab](https://github.com/awesome-selfhosted/awesome-selfhosted) - Curated list of self-hosted services
- [Infrastructure as Code](https://github.com/topics/infrastructure-as-code) - Related IaC projects
- [MkDocs Themes](https://github.com/mkdocs/mkdocs/wiki/MkDocs-Themes) - Documentation themes

---

**Ready to transform your homelab documentation?** Start with the [Quick Start](#-quick-start) guide above!

*Star ⭐ this repository if you find it useful!*