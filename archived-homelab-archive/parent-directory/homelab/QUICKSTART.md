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

### Clone the Repository
```bash
# Clone the repository
git clone https://github.com/your-username/homelab.git
cd homelab

# Make scripts executable
chmod +x scripts/**/*.sh
```

### Environment Setup
```bash
# Run the automated setup script
./scripts/setup/setup-environment.sh

# Activate the Python virtual environment
source venv/bin/activate
```

**What this does:**
- Creates Python virtual environment
- Installs all required dependencies
- Sets up directory structure
- Validates system requirements

## ⚙️ Step 2: Configuration

### Option A: Start with Example Configuration (Recommended)
```bash
# Copy example configuration for customization
cp -r config-example config-local

# Edit configuration files to match your setup
nano config-local/network.yml
nano config-local/services.yml
nano config-local/infrastructure.yml
```

### Option B: Use External Configuration Repository
```bash
# Clone your private configuration repository
git clone https://github.com/your-username/homelab-config.git config-private

# Or create a symbolic link to existing configuration
ln -s /path/to/your/config config-private
```

### Option C: Migration from Existing Repositories
```bash
# Migrate from existing Infrastructure and homelab-docs repositories
./scripts/setup/migrate-from-repos.sh ../Infrastructure ../homelab-docs

# Review migrated templates and configurations
ls -la templates/docs/
ls -la config-example/
```

## 📝 Step 3: Configuration Customization

### Basic Network Configuration
Edit `config-local/network.yml`:

```yaml
domain:
  internal: "your-lab.local"        # ← Change this
  external: "your-domain.com"      # ← Optional: Your external domain

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
```

### Service Configuration
Edit `config-local/services.yml`:

```yaml
services:
  pihole:
    enabled: true                   # ← Enable/disable services
    host: "pihole.your-lab.local"  # ← Adjust hostnames
    ip: "192.168.10.10"            # ← Service IP addresses
    admin_port: 8080
    
  homeassistant:
    enabled: true
    host: "ha.your-lab.local"
    ip: "192.168.10.20"
    port: 8123
```

### Infrastructure Details
Edit `config-local/infrastructure.yml`:

```yaml
servers:
  hypervisor:
    name: "your-proxmox"           # ← Your server names
    ip: "192.168.10.100"
    specs:
      cpu: "Your CPU Model"        # ← Your hardware specs
      ram: "Amount of RAM"
      storage: "Storage details"
```

## 🏗️ Step 4: Generate Documentation

### Development Mode (Live Preview)
```bash
# Start development server with live reload
HOMELAB_CONFIG_PATH=./config-local ./scripts/build/develop.sh
```

**This will:**
- Generate documentation from templates + your configuration
- Start MkDocs development server at `http://127.0.0.1:8000`
- Auto-reload when you make changes
- Show validation errors if configuration is incomplete

### Production Build
```bash
# Validate configuration
python scripts/generator/generate-docs.py --config ./config-local --validate-only

# Generate final documentation
HOMELAB_CONFIG_PATH=./config-local ./scripts/build/build.sh
```

**Output locations:**
- **Generated docs:** `docs/` directory
- **Built website:** `site/` directory
- **MkDocs config:** `mkdocs.yml`

## 🌐 Step 5: Deploy Documentation

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
```

## 🤖 Step 6: Infrastructure Automation (Optional)

### Ansible Setup
```bash
# Navigate to ansible directory
cd ansible

# Test connectivity to your servers
ansible -i inventories/production all -m ping

# Run a specific playbook
ansible-playbook -i inventories/production playbooks/docker-install.yml

# Run all infrastructure setup
ansible-playbook -i inventories/production playbooks/site.yml
```

### Service Deployment
```bash
# Deploy Pi-hole
ansible-playbook -i inventories/production playbooks/pihole-deploy.yml

# Deploy Traefik reverse proxy
ansible-playbook -i inventories/production playbooks/traefik-deploy.yml

# Deploy monitoring stack
ansible-playbook -i inventories/production playbooks/monitoring-deploy.yml
```

## 🔧 Step 7: Verification & Testing

### Documentation Verification
```bash
# Check generated documentation
ls -la docs/
ls -la site/

# Validate all links (optional)
# Install linkchecker: pip install linkchecker
linkchecker http://127.0.0.1:8000
```

### Configuration Validation
```bash
# Validate YAML syntax
python -c "import yaml; yaml.safe_load(open('config-local/network.yml'))"

# Run configuration validator
python scripts/generator/generate-docs.py --config ./config-local --validate-only
```

### Infrastructure Validation
```bash
# Test Ansible connectivity
ansible -i ansible/inventories/production all -m ping

# Dry-run infrastructure changes
ansible-playbook -i ansible/inventories/production --check ansible/playbooks/site.yml
```

## 🎯 Common Use Cases

### Use Case 1: Documentation Only
**Perfect for:** Sharing your homelab setup, creating knowledge base

```bash
# Setup and customize configuration
cp -r config-example config-local
# Edit config-local/* files

# Generate and serve documentation
./scripts/build/develop.sh
```

### Use Case 2: Full Infrastructure Management
**Perfect for:** Complete homelab automation and documentation

```bash
# Setup everything
./scripts/setup/setup-environment.sh
cp -r config-example config-local

# Deploy infrastructure
cd ansible
ansible-playbook -i inventories/production playbooks/site.yml

# Generate documentation
cd ..
./scripts/build/build.sh
```

### Use Case 3: Multi-Environment Setup
**Perfect for:** Separate test/production environments

```bash
# Create environment-specific configurations
cp -r config-example config-production
cp -r config-example config-test

# Generate documentation for each environment
HOMELAB_ENV=production HOMELAB_CONFIG_PATH=./config-production ./scripts/build/build.sh
HOMELAB_ENV=test HOMELAB_CONFIG_PATH=./config-test ./scripts/build/develop.sh
```

## 🔄 Daily Workflow

### Making Changes
```bash
# 1. Edit configuration
nano config-local/services.yml

# 2. Preview changes in development mode
./scripts/build/develop.sh

# 3. Apply infrastructure changes (if using Ansible)
cd ansible
ansible-playbook -i inventories/production playbooks/affected-service.yml

# 4. Generate final documentation
cd ..
./scripts/build/build.sh
```

### Keeping Up to Date
```bash
# Update repository
git pull origin main

# Update Python dependencies
source venv/bin/activate
pip install --upgrade -r requirements.txt

# Regenerate documentation with latest templates
./scripts/build/build.sh
```

## ❓ Troubleshooting

### Common Issues and Solutions

#### Python Virtual Environment Issues
```bash
# If virtual environment activation fails
python3 -m venv venv --clear
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

#### Template Rendering Errors
```bash
# Check YAML syntax
python -c "import yaml; yaml.safe_load(open('config-local/network.yml'))"

# Validate configuration
python scripts/generator/generate-docs.py --config ./config-local --validate-only

# Check detailed error output
python scripts/generator/generate-docs.py --config ./config-local --verbose
```

#### MkDocs Build Failures
```bash
# Clear previous builds
rm -rf docs/ site/ mkdocs.yml

# Regenerate everything
./scripts/build/build.sh

# Check MkDocs directly
mkdocs build --verbose
```

#### Ansible Connection Issues
```bash
# Test connectivity
ansible -i ansible/inventories/production all -m ping

# Check SSH configuration
ssh -v user@your-server

# Verify inventory file
ansible-inventory -i ansible/inventories/production --list
```

### Getting Help

1. **Check the logs:** Most scripts provide verbose output with `--verbose` flag
2. **Validate configuration:** Use the validation script before building
3. **Review examples:** Compare your config with `config-example/`
4. **Create an issue:** If you find a bug, create a GitHub issue with:
   - Your operating system
   - Python version (`python --version`)
   - Error messages (anonymize sensitive data)
   - Configuration files (anonymized)

## 🎉 What's Next?

### Immediate Next Steps
1. **Customize templates** in `templates/docs/` to match your needs
2. **Add new services** to your configuration
3. **Set up automated deployments** with GitHub Actions
4. **Share your setup** with the community

### Advanced Features
- **Multi-environment management** (dev/test/prod)
- **Private configuration repositories** with Git submodules
- **Automated infrastructure testing** with Molecule
- **Monitoring integration** with Prometheus/Grafana
- **Backup automation** with Ansible

### Community Resources
- **GitHub Discussions** - Ask questions and share setups
- **Example Configurations** - Browse community configs
- **Template Library** - Contribute new service templates
- **Best Practices Guide** - Learn from experienced users

---

**🎯 Success Criteria**

You've successfully completed the quick start when you can:

- ✅ Generate documentation from templates and your configuration
- ✅ Access your documentation at `http://127.0.0.1:8000`
- ✅ See your actual network details in the generated docs
- ✅ Make configuration changes and see them reflected in the documentation

**⏱️ Total time:** Typically 10-15 minutes for documentation setup, additional time for infrastructure deployment.

**🚀 Ready to dive deeper?** Check out the [full documentation](README.md) and [contribution guidelines](CONTRIBUTING.md)!