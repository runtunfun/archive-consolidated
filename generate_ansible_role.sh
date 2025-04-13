#!/bin/bash
# Script: generate_ansible_role.sh
# Description: This script creates an Ansible role along with a playbook, variables, 
#              and role documentation (in English and German).
# Usage: Run the script and provide the role name when prompted.

# Load variables from .env_structure file
if [ -f .env_structure ]; then
  export $(grep -v '^#' .env_structure | xargs)
else
  echo ".env_structure file not found. Exiting!"
  exit 1
fi

# Variables for dynamic input
ROLE_NAME=""
PLAYBOOK_NAME=""
VARS_NAME=""

echo "Please enter the role name (e.g., webserver):"
read ROLE_NAME

# Check for empty input
if [ -z "$ROLE_NAME" ]; then
  echo "Role name must be defined. Exiting!"
  exit 1
fi

# Dynamic naming
PLAYBOOK_NAME="playbook_${ROLE_NAME}.yml"
ROLE_DIR="${ROLES_DIR}/role_${ROLE_NAME}"
VARS_NAME="vars_${ROLE_NAME}.yml"

# Create role structure
echo "Creating role directory: $ROLE_DIR"
mkdir -p "$ROLE_DIR/tasks" "$ROLE_DIR/templates" "$ROLE_DIR/vars"

# Create playbook
echo "Creating playbook: ${PLAYBOOKS_DIR}/${PLAYBOOK_NAME}"
cat <<EOF >"${PLAYBOOKS_DIR}/${PLAYBOOK_NAME}"
---
- name: Configure $ROLE_NAME
  hosts: all
  roles:
    - role_${ROLE_NAME}
EOF

# Create variables file
echo "Creating variables file: ${GROUP_VARS_DIR}/${VARS_NAME}"
cat <<EOF >"${GROUP_VARS_DIR}/${VARS_NAME}"
---
# Variables for $ROLE_NAME
variable1: value1
variable2: value2
EOF

# Documentation entries for English and German versions
DOCS_EN="${DOCS_DIR_EN}/${ROLE_NAME}.md"
DOCS_DE="${DOCS_DIR_DE}/${ROLE_NAME}.md"

echo "Creating documentation for role: $DOCS_EN and $DOCS_DE"
cat <<EOF >"$DOCS_EN"
# Role: $ROLE_NAME

This role configures the ${ROLE_NAME}. Details of tasks and templates are included in the role structure.
EOF

cat <<EOF >"$DOCS_DE"
# Rolle: $ROLE_NAME

Diese Rolle konfiguriert den ${ROLE_NAME}. Details der Aufgaben und Vorlagen sind in der Rollenstruktur enthalten.
EOF

echo "Done! The new role and playbook have been created successfully."

