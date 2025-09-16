# 🚀 Quick Start Guide

This guide will get you up and running with the homelab infrastructure and documentation system in **under 15 minutes**.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Git** (version 2.20+)
- **Python** (version 3.8+)
- **Ansible** (version 2.9+) - *Optional for documentation-only usage*

### System Compatibility
- ✅ **Linux** (Ubuntu 20.04+, Debian 11+, RHEL 8+)
- ✅ **macOS** (10.15+)
- ✅ **Windows** (WSL2 recommended)

## 🔧 Step 1: Repository Setup

### Option A: Fresh Installation
```bash
# Clone the repository
git clone https://github.com/your-username/homelab.git
cd homelab

# Run automated setup
./scripts/setup/setup-environment.sh
source venv/bin/activate
```

### Option B: Migration from Existing Repositories
```bash
# Clone new repository
git clone https://github.com/your-username/homelab.git
cd homelab

# Setup environment
./scripts/setup/setup-environment.sh

# Migrate from existing repositories
./scripts/setup/migrate-from-repos.sh ../Infrastructure ../homelab-docs

# Review migrated content
ls -la templates/docs/
ls -la config-example/
```

**What the setup does:**
- Creates Python virtual environment
- Installs all required dependencies (Jinja2, PyYAML, MkDocs)
- Sets up directory structure
- Validates system requirements

## ⚙️ Step 2: Configuration

### Quick Start (Recommended)
```bash
# Copy example configuration for customization
cp -r config-example config-local

# Edit configuration files to match your setup
vim config-local/network.yml      # Network settings
vim config-local/services.yml     # Service definitions  
vim config-local/infrastructure.yml # Hardware specs
vim config-local/documentation.yml  # Site customization
```

### Advanced: External Configuration Repository
```bash
# For private configuration repositories
git clone https://github.com/your-username/homelab-config.git config-private

# Or create symbolic link to existing configuration
ln -s /path/to/your/existing/config config-private

# Use with build scripts
HOMELAB_CONFIG_PATH=./config-private ./scripts/build/develop.sh
```

### Configuration Files Overview

#### `config-local/network.yml` - Network Configuration
```yaml
domain:
  internal: "your-lab.local"        # ← Change this to your domain
  external: "your-domain.com"      # ← Optional external domain

networks:
  management:
    vlan_id: 10
    subnet: "192.168.10.0/24"      # ← Adjust to your network
    gateway: "192.168.10.1"        # ← Your gateway IP
  
  iot:
    vlan_id: 20
    subnet: "192.168.20.0/24"      # ← Your IoT network
    gateway: "192.168.20.1"

dns:
  primary: "192.168.10.10"         # ← Your primary DNS (Pi-hole)
  secondary: "192.168.10.11"       # ← Your secondary DNS

unifi:
  controller: "192.168.10.5"       # ← UniFi controller IP
  devices:
    - name: "USG-Pro"
      model: "UniFi Security Gateway Pro"
      ip: "192.168.10.1"
```

#### `config-local/services.yml` - Service Configuration
```yaml
services:
  pihole:
    enabled: true                   # ← Enable/disable services
    host: "pihole.your-lab.local"  # ← Adjust hostnames
    ip: "192.168.10.10"            # ← Service IP addresses
    admin_port: 8080
    description: "Network-wide ad blocking and DNS"
    
  traefik:
    enabled: true
    host: "traefik.your-lab.local"
    ip: "192.168.10.11"
    dashboard_port: 8080
    description: "Reverse proxy with automatic SSL"
    
  homeassistant:
    enabled: true
    host: "ha.your-lab.local"
    ip: "192.168.10.20"
    port: 8123
    description: "Home automation platform"
    
  monitoring:
    prometheus:
      enabled: true
      host: "prometheus.your-lab.local"
      ip: "192.168.10.30"
    
    grafana:
      enabled: true
      host: "grafana.your-lab.local"
      ip: "192.168.10.31"

docker:
  registry: "registry.your-lab.local"
  compose_path: "/opt/docker-compose"
```

#### `config-local/infrastructure.yml` - Hardware Details
```yaml
servers:
  hypervisor:
    name: "your-proxmox"           # ← Your server names
    ip: "192.168.10.100"
    specs:
      cpu: "Intel i7-10700"       # ← Your hardware specs
      ram: "64GB"
      storage: "2x 1TB NVMe"
  
  services:
    name: "homelab-services"
    ip: "192.168.10.101"
    specs:
      cpu: "Intel i5-8400"
      ram: "32GB"
      storage: "1TB SSD"

storage:
  nas:
    name: "synology-ds920"
    ip: "192.168.10.200"
    capacity: "16TB"
    raid: "RAID 5"

backup:
  strategy: "3-2-1"
  local: "/mnt/backup"
  cloud: "AWS S3"
  retention: "30 days local, 1 year cloud"
```

#### `config-local/documentation.yml` - Site Customization
```yaml
site:
  name: "My Homelab Documentation"
  description: "Comprehensive homelab infrastructure documentation"
  author: "Your Name"
  url: "https://your-username.github.io/homelab"

branding:
  logo: "assets/logo.png"
  primary_color: "indigo"
  accent_color: "blue"

features:
  search: true
  dark_mode: true
  edit_links: true
  git_info: true

navigation:
  show_automation: true
  show_monitoring: true
  show_security: true
```

## 🏗️ Step 3: Generate Documentation

### Development Mode (Live Preview)
```bash
# Start development server with live reload
HOMELAB_CONFIG_PATH=./config-local ./scripts/build/develop.sh

# Or with specific environment
HOMELAB_ENV=development HOMELAB_CONFIG_PATH=./config-local ./scripts/build/develop.sh
```

**This will:**
- Generate documentation from templates + your configuration
- Start MkDocs development server at `http://127.0.0.1:8000`
- Auto-reload when you make changes
- Show validation errors if configuration is incomplete

### Production Build
```bash
# Validate configuration first
python scripts/generator/generate-docs.py --config ./config-local --validate-only

# Generate final documentation
HOMELAB_CONFIG_PATH=./config-local ./scripts/build/build.sh

# With specific environment
HOMELAB_ENV=production HOMELAB_CONFIG_PATH=./config-local ./scripts/build/build.sh
```

**Output locations:**
- **Generated docs:** `docs/` directory
- **Built website:** `site/` directory  
- **MkDocs config:** `mkdocs.yml`

### Multi-Environment Setup
```bash
# Create environment-specific configurations
cp -r config-example config-production
cp -r config-example config-test

# Edit environment-specific files
vim config-production/environments/production.yml
vim config-test/environments/test.yml

# Generate documentation for each environment
HOMELAB_ENV=production HOMELAB_CONFIG_PATH=./config-production ./scripts/build/build.sh
HOMELAB_ENV=test HOMELAB_CONFIG_PATH=./config-test ./scripts/build/develop.sh
```

## 🌐 Step 4: Deploy Documentation

### Local Deployment
```bash
# Build and serve locally
./scripts/build/build.sh
python -m http.server -d site 8080

# Access at: http://localhost:8080
```

### GitHub Pages Deployment
```bash
# Deploy to GitHub Pages
./scripts/build/deploy.sh github

# Your documentation will be available at:
# https://your-username.github.io/homelab
```

### Custom Deployment
```bash
# Build static site
./scripts/build/build.sh

# Copy site/ directory to your web server
rsync -av site/ user@server:/var/www/html/
scp -r site/* user@server:/var/www/html/
```

## 🤖 Step 5: Infrastructure Automation (Optional)

### Ansible Setup
```bash
# Navigate to ansible directory
cd ansible

# Edit inventory for your environment
vim inventories/production/hosts.yml

# Edit group variables
vim group_vars/all.yml

# Test connectivity to your servers
ansible -i inventories/production all -m ping

# Run a specific playbook
ansible-playbook -i inventories/production playbooks/docker-install.yml

# Run all infrastructure setup
ansible-playbook -i inventories/production playbooks/site.yml
```

### Service Deployment Examples
```bash
# Deploy Pi-hole DNS server
ansible-playbook -i inventories/production playbooks/pihole-deploy.yml

# Deploy Traefik reverse proxy
ansible-playbook -i inventories/production playbooks/traefik-deploy.yml

# Deploy monitoring stack (Prometheus + Grafana)
ansible-playbook -i inventories/production playbooks/monitoring-deploy.yml

# Deploy all services
ansible-playbook -i inventories/production playbooks/services-deploy.yml
```

## 🔧 Step 6: Verification & Testing

### Documentation Verification
```bash
# Check generated documentation
ls -la docs/
ls -la site/

# Test local documentation server
python -m http.server -d site 8000

# Validate all internal links (optional)
# pip install linkchecker
linkchecker http://127.0.0.1:8000
```

### Configuration Validation
```bash
# Validate YAML syntax
python -c "import yaml; yaml.safe_load(open('config-local/network.yml'))"
python -c "import yaml; yaml.safe_load(open('config-local/services.yml'))"

# Run comprehensive configuration validator
python scripts/generator/generate-docs.py --config ./config-local --validate-only

# Verbose validation with detailed errors
python scripts/generator/generate-docs.py --config ./config-local --validate-only --verbose
```

### Infrastructure Validation
```bash
# Test Ansible connectivity
ansible -i ansible/inventories/production all -m ping

# Dry-run infrastructure changes (check mode)
ansible-playbook -i ansible/inventories/production --check ansible/playbooks/site.yml

# Validate Ansible syntax
ansible-playbook --syntax-check ansible/playbooks/site.yml
```

## 🎯 Common Use Cases

### Use Case 1: Documentation Only
**Perfect for:** Sharing your homelab setup, creating knowledge base

```bash
# Quick setup for documentation
cp -r config-example config-local
vim config-local/network.yml config-local/services.yml

# Generate and view documentation
./scripts/build/develop.sh
# Visit http://127.0.0.1:8000

# Deploy to GitHub Pages
./scripts/build/deploy.sh github
```

### Use Case 2: Full Infrastructure Management
**Perfect for:** Complete homelab automation and documentation

```bash
# Setup everything
./scripts/setup/setup-environment.sh
cp -r config-example config-local

# Configure for your environment
vim config-local/* ansible/inventories/production/hosts.yml

# Deploy infrastructure
cd ansible && ansible-playbook -i inventories/production playbooks/site.yml

# Generate documentation
cd .. && ./scripts/build/build.sh
```

### Use Case 3: Migration from Existing Setup
**Perfect for:** Upgrading from manual documentation or separate repos

```bash
# Migrate existing repositories
./scripts/setup/migrate-from-repos.sh ../Infrastructure ../homelab-docs

# Review and update migrated templates
find templates/docs/ -name "*.j2" -exec vim {} \;

# Create configuration from migrated content
cp -r config-example config-local
# Edit config-local/* based on your existing setup

# Generate updated documentation
./scripts/build/develop.sh
```

### Use Case 4: Team/Multi-Environment
**Perfect for:** Different configurations for dev/test/prod environments

```bash
# Setup shared repository
git clone https://github.com/team/homelab.git
cd homelab && ./scripts/setup/setup-environment.sh

# Each team member maintains private config
git clone https://github.com/user/homelab-config.git config-private

# Generate personalized documentation
HOMELAB_CONFIG_PATH=./config-private ./scripts/build/develop.sh

# Share templates, keep configs private
git add templates/ ansible/ scripts/
git commit -m "feat: updated shared templates"
```

## 🔄 Daily Workflow

### Making Configuration Changes
```bash
# 1. Edit configuration
vim config-local/services.yml

# 2. Preview changes in development mode
./scripts/build/develop.sh
# Check http://127.0.0.1:8000 for changes

# 3. Apply infrastructure changes (if using Ansible)
cd ansible
ansible-playbook -i inventories/production playbooks/affected-service.yml

# 4. Generate final documentation
cd .. && ./scripts/build/build.sh

# 5. Deploy updated documentation
./scripts/build/deploy.sh github
```

### Updating Templates
```bash
# 1. Edit templates
vim templates/docs/services/new-service.md.j2

# 2. Test with your configuration
./scripts/build/develop.sh

# 3. Contribute back to main repository
git add templates/docs/services/new-service.md.j2
git commit -m "feat: add template for new service"
git push origin feature/new-service-template
```

### Keeping Up to Date
```bash
# Update repository and dependencies
git pull origin main
source venv/bin/activate
pip install --upgrade -r requirements.txt

# Regenerate documentation with latest templates
./scripts/build/build.sh

# Update infrastructure
cd ansible && ansible-playbook -i inventories/production playbooks/updates.yml
```

## ❓ Troubleshooting

### Common Issues and Solutions

#### Python Virtual Environment Issues
```bash
# If virtual environment activation fails
rm -rf venv
python3 -m venv venv --clear
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

#### Template Rendering Errors
```bash
# Check YAML syntax errors
python -c "import yaml; print('Valid YAML')" && \
  for file in config-local/*.yml; do \
    echo "Checking $file..."; \
    python -c "import yaml; yaml.safe_load(open('$file'))"; \
  done

# Validate configuration with detailed error output
python scripts/generator/generate-docs.py \
  --config ./config-local \
  --validate-only \
  --verbose

# Check for missing required fields
python scripts/generator/generate-docs.py \
  --config ./config-local \
  --check-required
```

#### MkDocs Build Failures
```bash
# Clear previous builds and regenerate
rm -rf docs/ site/ mkdocs.yml
./scripts/build/build.sh

# Check MkDocs configuration directly
mkdocs build --verbose --clean

# Test with minimal configuration
echo "site_name: Test" > mkdocs-minimal.yml
echo "docs_dir: docs" >> mkdocs-minimal.yml
mkdocs build -f mkdocs-minimal.yml
```

#### Ansible Connection Issues
```bash
# Test SSH connectivity manually
ssh -v user@your-server

# Check Ansible inventory syntax
ansible-inventory -i ansible/inventories/production --list

# Test with increased verbosity
ansible -i ansible/inventories/production all -m ping -vvv

# Verify SSH key authentication
ssh-add -l
ssh user@server "echo 'Connection successful'"
```

#### Permission Issues
```bash
# Fix script permissions
find scripts/ -name "*.sh" -exec chmod +x {} \;

# Fix Python path issues
which python3
python3 --version
pip3 --version

# Fix Ansible permissions
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

### Advanced Troubleshooting

#### Debug Template Generation
```bash
# Enable debug mode
export HOMELAB_DEBUG=true
python scripts/generator/generate-docs.py --config ./config-local --debug

# Test individual templates
python -c "
from jinja2 import Environment, FileSystemLoader
env = Environment(loader=FileSystemLoader('templates'))
template = env.get_template('docs/index.md.j2')
print(template.render(config={'site': {'name': 'Test'}}))
"
```

#### Network Connectivity Issues
```bash
# Test internal DNS resolution
nslookup your-service.your-lab.local

# Test service connectivity
curl -I http://your-service.your-lab.local
telnet your-service.your-lab.local 80

# Check port forwarding/firewall
sudo netstat -tlnp | grep :8000
sudo ufw status
```

### Getting Help

1. **Check the logs:** Most scripts provide verbose output with `--verbose` flag
2. **Validate configuration:** Always run validation before building
3. **Review examples:** Compare your config with `config-example/`
4. **Check documentation:** See `docs/` for detailed guides
5. **Community support:**
   - **GitHub Discussions** - Questions and community chat
   - **GitHub Issues** - Bug reports with template
   - **Discord/Matrix** - Real-time community help

#### Bug Report Template
When reporting issues, include:
- Operating system and version
- Python version (`python --version`)
- Error messages (full traceback)
- Configuration files (anonymized)
- Steps to reproduce

## 🎉 What's Next?

### Immediate Next Steps
1. **Customize templates** in `templates/docs/` to match your needs
2. **Add new services** to your configuration
3. **Set up automated deployments** with GitHub Actions
4. **Share your setup** with the community

### Advanced Features to Explore
- **Multi-environment management** (dev/test/prod) - See [docs/ENVIRONMENTS.md](docs/ENVIRONMENTS.md)
- **Custom templates** - See [docs/TEMPLATES.md](docs/TEMPLATES.md)
- **Automated testing** with Molecule - See [docs/TESTING.md](docs/TESTING.md)
- **Monitoring integration** - See [docs/MONITORING.md](docs/MONITORING.md)
- **Backup automation** - See [docs/BACKUP.md](docs/BACKUP.md)

### Community Resources
- **GitHub Discussions** - Ask questions and share setups
- **Example Configurations** - Browse community configs at [examples/](examples/)
- **Template Library** - Contribute new service templates
- **Best Practices Guide** - Learn from experienced users

---

**🎯 Success Criteria**

You've successfully completed the quick start when you can:

- ✅ Generate documentation from templates and your configuration
- ✅ Access your documentation at `http://127.0.0.1:8000`
- ✅ See your actual network details in the generated docs
- ✅ Make configuration changes and see them reflected in the documentation
- ✅ (Optional) Deploy services with Ansible

**⏱️ Total time:** Typically 10-15 minutes for documentation setup, additional time for infrastructure deployment.

**🚀 Ready to dive deeper?** Check out the detailed [documentation guides](docs/) and [contribution guidelines](CONTRIBUTING.md)!
