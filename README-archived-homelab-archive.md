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

- **🎨 Template-Based Documentation** - Share publicly without exposing sensitive information
- **🤖 Infrastructure Automation** - Proven Ansible playbooks for common homelab services
- **📖 Intelligent Documentation** - Auto-generated content with cross-references
- **🔒 Privacy & Security** - Configurable anonymization and environment isolation

## 🚀 Quick Start

```bash
# 1. Clone and setup
git clone https://github.com/your-username/homelab.git
cd homelab
./scripts/setup/setup-environment.sh && source venv/bin/activate

# 2. Configure for your environment
cp -r config-example config-local
vim config-local/network.yml config-local/services.yml

# 3. Generate documentation
HOMELAB_CONFIG_PATH=./config-local ./scripts/build/develop.sh

# 4. Deploy infrastructure (optional)
cd ansible && ansible-playbook -i inventories/production playbooks/site.yml
```

**👉 Complete setup guide:** [QUICKSTART.md](QUICKSTART.md) (15-minute guide)

## 📁 Repository Structure

```
homelab/
├── 📝 templates/              # Documentation templates (shareable)
├── 🤖 ansible/               # Infrastructure automation
├── 🔧 scripts/               # Build and deployment scripts
├── 📋 config-example/         # Example configuration (safe to share)
├── 📖 docs/                   # Generated documentation (git-ignored)
└── 🌐 site/                   # Built website (git-ignored)
```

**👉 Detailed architecture:** [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

## ⚙️ How It Works

1. **Templates** contain example data (lab.local, 192.168.x.x) - safe to share publicly
2. **Configuration files** contain your real data - kept private
3. **Generator** combines templates + config = personalized documentation
4. **Ansible** automates your infrastructure deployment

```yaml
# Your config-local/network.yml
domain:
  internal: "your-lab.local"
networks:
  management:
    subnet: "192.168.10.0/24"
```

```markdown
<!-- Generated docs/network.md -->
# Network: your-lab.local
Management network: 192.168.10.0/24
```

**👉 Configuration guide:** [docs/CONFIGURATION.md](docs/CONFIGURATION.md)

## 🏗️ Supported Infrastructure

- **🐳 Container Services:** Pi-hole, Traefik, Home Assistant, Monitoring stack
- **🔐 Security:** fail2ban, UFW, SSH hardening, automated updates
- **🌐 Network:** UniFi integration, VLAN configuration, DNS management

**👉 Complete service list:** [docs/SERVICES.md](docs/SERVICES.md)

## 📚 Documentation

| Guide | Purpose |
|-------|---------|
| [QUICKSTART.md](QUICKSTART.md) | **15-minute setup guide** |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Technical design and structure |
| [docs/CONFIGURATION.md](docs/CONFIGURATION.md) | Configuration system details |
| [docs/TEMPLATES.md](docs/TEMPLATES.md) | Template development guide |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute |

## 🤝 Contributing

We welcome all types of contributions:

- 🚀 **Service Templates** - Add documentation for new services
- 🤖 **Ansible Roles** - Infrastructure automation improvements  
- 📚 **Documentation** - Guides, tutorials, best practices
- 🐛 **Bug Reports** - Help us improve the system

**👉 Full contribution guide:** [CONTRIBUTING.md](CONTRIBUTING.md)

## 🔗 Quick Links

- **📖 [Live Demo](https://your-username.github.io/homelab)** - See the generated documentation
- **💬 [Discussions](https://github.com/your-username/homelab/discussions)** - Community chat
- **🐛 [Issues](https://github.com/your-username/homelab/issues)** - Bug reports & feature requests
- **🌟 [Examples](https://github.com/topics/homelab-documentation)** - Community setups

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Ready to transform your homelab documentation?** Start with the [Quick Start](#-quick-start) above!

*⭐ Star this repository if you find it useful!*
