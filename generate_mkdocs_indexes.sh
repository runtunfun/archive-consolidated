#!/bin/bash

# Load variables from .env_structure file
if [ -f .env_strucure ]; then
  export $(grep -v '^#' .env_strucure | xargs)
else
  echo ".env_strucure file not found. Exiting!"
  exit 1
fi

# Variables for output files
OUTPUT_FILE_EN="${DOCS_DIR_EN}/index.md"
OUTPUT_FILE_DE="${DOCS_DIR_DE}/index.md"

# Create English index.md
echo "# Project Overview" > "$OUTPUT_FILE_EN"
echo "" >> "$OUTPUT_FILE_EN"

# Roles
echo "## Roles" >> "$OUTPUT_FILE_EN"
for role in ${ROLES_DIR}/role_*; do
  echo "- [$(basename $role)]($role/)" >> "$OUTPUT_FILE_EN"
done
echo "" >> "$OUTPUT_FILE_EN"

# Playbooks
echo "## Playbooks" >> "$OUTPUT_FILE_EN"
for playbook in ${PLAYBOOKS_DIR}/playbook_*.yml; do
  echo "- [$(basename $playbook .yml)]($playbook)" >> "$OUTPUT_FILE_EN"
done
echo "" >> "$OUTPUT_FILE_EN"

# Variables
echo "## Variables" >> "$OUTPUT_FILE_EN"
for vars in ${GROUP_VARS_DIR}/vars_*.yml; do
  echo "- $(basename $vars .yml)" >> "$OUTPUT_FILE_EN"
done
echo "English index file created successfully!"

# Create German index.md
echo "# Projektübersicht" > "$OUTPUT_FILE_DE"
echo "" >> "$OUTPUT_FILE_DE"

# Rollen
echo "## Rollen" >> "$OUTPUT_FILE_DE"
for role in ${ROLES_DIR}/role_*; do
  echo "- [$(basename $role)]($role/)" >> "$OUTPUT_FILE_DE"
done
echo "" >> "$OUTPUT_FILE_DE"

# Playbooks
echo "## Playbooks" >> "$OUTPUT_FILE_DE"
for playbook in ${PLAYBOOKS_DIR}/playbook_*.yml; do
  echo "- [$(basename $playbook .yml)]($playbook)" >> "$OUTPUT_FILE_DE"
done
echo "" >> "$OUTPUT_FILE_DE"

# Variablen
echo "## Variablen" >> "$OUTPUT_FILE_DE"
for vars in ${GROUP_VARS_DIR}/vars_*.yml; do
  echo "- $(basename $vars .yml)" >> "$OUTPUT_FILE_DE"
done
echo "German index file created successfully!"

