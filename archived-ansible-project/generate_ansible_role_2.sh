#!/bin/bash

# Load variables from .env file (if present)
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo ".env file not found. Using default directory names."
  PLAYBOOKS_DIR="playbooks"
  ROLES_DIR="roles"
  GROUP_VARS_DIR="inventory/group_vars"
  DOCS_DIR_EN="docs/en/roles"
  DOCS_DIR_DE="docs/de/roles"
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

# Dynamic naming with prefixes
PLAYBOOK_NAME="p_${ROLE_NAME}.yml"
ROLE_DIR="${ROLES_DIR}/r_${ROLE_NAME}"
VARS_NAME="v_${ROLE_NAME}.yml"

# Create role structure
echo "Creating role directory: $ROLE_DIR"
mkdir -p "$ROLE_DIR/tasks" "$ROLE_DIR/templates" "$ROLE_DIR/vars"

# Create playbook
echo "Creating playbook: ${PLAYBOOKS_DIR}/${PLAYBOOK_NAME}"
cat <<EOF >"${PLAYBOOKS_DIR}/${PLAYBOOK_NAME}"
---
- name: Configure ${ROLE_NAME}
  hosts: all
  roles:
    - r_${ROLE_NAME}
EOF

# Create variables file
echo "Creating variables file: ${GROUP_VARS_DIR}/${VARS_NAME}"
cat <<EOF >"${GROUP_VARS_DIR}/${VARS_NAME}"
---
# Variables for r_${ROLE_NAME}
variable1: value1
variable2: value2
EOF

# Documentation entries for English and German versions
DOCS_EN="${DOCS_DIR_EN}/r_${ROLE_NAME}.md"
DOCS_DE="${DOCS_DIR_DE}/r_${ROLE_NAME}.md"

echo "Creating documentation for role: $DOCS_EN and $DOCS_DE"
cat <<EOF >"$DOCS_EN"
# Role: r_${ROLE_NAME}

This role configures the ${ROLE_NAME}. Details of tasks, templates, and variables are included in the role structure.

## Playbook Reference
- [p_${ROLE_NAME}.yml](../../../../${PLAYBOOKS_DIR}/p_${ROLE_NAME}.yml)

## Variables Reference
- [v_${ROLE_NAME}.yml](../../../../${GROUP_VARS_DIR}/v_${ROLE_NAME}.yml)
EOF

cat <<EOF >"$DOCS_DE"
# Rolle: r_${ROLE_NAME}

Diese Rolle konfiguriert den ${ROLE_NAME}. Details zu Aufgaben, Vorlagen und Variablen sind in der Rollenstruktur enthalten.

## Playbook-Verweis
- [p_${ROLE_NAME}.yml](../../../../${PLAYBOOKS_DIR}/p_${ROLE_NAME}.yml)

## Variablen-Verweis
- [v_${ROLE_NAME}.yml](../../../../${GROUP_VARS_DIR}/v_${ROLE_NAME}.yml)
EOF

echo "Done! New role and playbook have been created with prefixes."

