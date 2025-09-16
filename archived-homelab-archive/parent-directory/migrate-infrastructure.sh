#!/bin/bash
# TEMPORÄRES SCRIPT - liegt eine Ebene über dem homelab Repository
# migrate-infrastructure.sh
# Migriert das Infrastructure Repository ins neue homelab Repository

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOMELAB_DIR="$SCRIPT_DIR/homelab"
INFRASTRUCTURE_PATH="${1:-$SCRIPT_DIR/Infrastructure}"

echo "🤖 Migrating Infrastructure repository..."
echo "📁 Script location: $SCRIPT_DIR"
echo "📁 Target homelab repo: $HOMELAB_DIR"
echo "📁 Source Infrastructure: $INFRASTRUCTURE_PATH"
echo ""

# Prüfe ob homelab Repository existiert
if [[ ! -d "$HOMELAB_DIR" ]]; then
    echo "❌ Homelab repository not found at: $HOMELAB_DIR"
    echo ""
    echo "Please create homelab repository first:"
    echo "  mkdir homelab"
    echo "  cd homelab"
    echo "  git init"
    echo "  mkdir -p scripts/{setup,generator,build,maintenance}"
    exit 1
fi

# Prüfe ob Infrastructure Repository existiert
if [[ ! -d "$INFRASTRUCTURE_PATH" ]]; then
    echo "❌ Infrastructure repository not found at: $INFRASTRUCTURE_PATH"
    echo ""
    echo "Usage: $0 [path-to-infrastructure-repo]"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Uses ./Infrastructure"
    echo "  $0 /path/to/Infrastructure           # Uses custom path"
    echo "  $0 ../old-infrastructure             # Uses relative path"
    exit 1
fi

# Erstelle alle benötigten Verzeichnisse im homelab Repository
echo "📁 Creating required directories in homelab repository..."
mkdir -p "$HOMELAB_DIR"/{templates/docs/{automation/roles,infrastructure/software,planning},ansible/{playbooks,roles,inventories,group_vars}}

echo "📦 Copying Ansible code..."
if [[ -d "$INFRASTRUCTURE_PATH/Ansible" ]]; then
    # Kopiere gesamte Ansible-Struktur
    echo "  - Copying Ansible directory structure..."
    cp -r "$INFRASTRUCTURE_PATH/Ansible"/* "$HOMELAB_DIR/ansible/" 2>/dev/null || echo "  - Warning: Some Ansible files may not exist"
    
    # Reorganisiere Playbooks
    echo "  - Reorganizing playbooks..."
    if [[ ! -d "$HOMELAB_DIR/ansible/playbooks" ]]; then
        mkdir -p "$HOMELAB_DIR/ansible/playbooks"
    fi
    
    # Verschiebe Playbook-Dateien (p_*.yml) in playbooks/ Verzeichnis
    find "$HOMELAB_DIR/ansible/" -maxdepth 1 -name "p_*.yml" -print0 2>/dev/null | while IFS= read -r -d '' file; do
        if [[ -f "$file" ]]; then
            echo "    - Moving playbook: $(basename "$file")"
            mv "$file" "$HOMELAB_DIR/ansible/playbooks/"
        fi
    done
    
    # Reorganisiere Inventories (i_* -> *)
    echo "  - Reorganizing inventories..."
    mkdir -p "$HOMELAB_DIR/ansible/inventories"
    find "$HOMELAB_DIR/ansible/" -maxdepth 1 -name "i_*" -print0 2>/dev/null | while IFS= read -r -d '' inventory; do
        if [[ -f "$inventory" || -d "$inventory" ]]; then
            new_name=$(basename "$inventory" | sed 's/^i_//')
            echo "    - Moving inventory: $(basename "$inventory") -> $new_name"
            mv "$inventory" "$HOMELAB_DIR/ansible/inventories/$new_name"
        fi
    done
    
    echo "✅ Ansible code migrated successfully"
else
    echo "⚠️  No Ansible directory found in $INFRASTRUCTURE_PATH"
fi

echo ""
echo "📝 Copying concept documents..."
if [[ -d "$INFRASTRUCTURE_PATH/Concept" ]]; then
    # Konvertiere Konzept-Dokumente zu Templates
    for file in "$INFRASTRUCTURE_PATH/Concept"/*.md; do
        if [[ -f "$file" ]]; then
            filename=$(basename "$file" .md)
            target_file="$HOMELAB_DIR/templates/docs/planning/${filename}.md.j2"
            cp "$file" "$target_file"
            echo "  - Converted: $filename.md -> $filename.md.j2"
        fi
    done
    echo "✅ Concept documents converted to templates"
else
    echo "⚠️  No Concept directory found in $INFRASTRUCTURE_PATH"
fi

echo ""
echo "📚 Copying documentation..."
if [[ -d "$INFRASTRUCTURE_PATH/Documentation" ]]; then
    # Kopiere Software-Dokumentation
    if [[ -d "$INFRASTRUCTURE_PATH/Documentation/docs/Software" ]]; then
        for file in "$INFRASTRUCTURE_PATH/Documentation/docs/Software"/*; do
            if [[ -f "$file" ]]; then
                filename=$(basename "$file")
                target_file="$HOMELAB_DIR/templates/docs/infrastructure/software/${filename}.j2"
                cp "$file" "$target_file"
                echo "  - Converted: $filename -> ${filename}.j2"
            fi
        done
        echo "✅ Software documentation migrated"
    else
        echo "⚠️  No Software documentation found"
    fi
else
    echo "⚠️  No Documentation directory found in $INFRASTRUCTURE_PATH"
fi

echo ""
echo "🔧 Creating Ansible documentation templates..."
if [[ -f "$HOMELAB_DIR/scripts/maintenance/generate-ansible-templates.sh" ]]; then
    chmod +x "$HOMELAB_DIR/scripts/maintenance/generate-ansible-templates.sh"
    cd "$HOMELAB_DIR"
    ./scripts/maintenance/generate-ansible-templates.sh
    cd "$SCRIPT_DIR"
else
    echo "⚠️  generate-ansible-templates.sh not found in homelab/scripts/maintenance/"
    echo "    Please ensure permanent scripts are installed first"
fi

echo ""
echo "✅ Infrastructure migration completed successfully!"
echo ""
echo "📋 Migration Summary:"
echo "  - Ansible code: $HOMELAB_DIR/ansible/"
echo "  - Concept docs: $HOMELAB_DIR/templates/docs/planning/"
echo "  - Software docs: $HOMELAB_DIR/templates/docs/infrastructure/software/"
echo "  - Automation docs: $HOMELAB_DIR/templates/docs/automation/"
echo ""
echo "💡 Next step: Run ./migrate-documentation.sh"