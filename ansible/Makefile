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
