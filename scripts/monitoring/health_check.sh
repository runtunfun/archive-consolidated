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
