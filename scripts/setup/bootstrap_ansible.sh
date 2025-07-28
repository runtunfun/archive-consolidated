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
