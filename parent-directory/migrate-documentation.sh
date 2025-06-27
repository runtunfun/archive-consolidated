#!/bin/bash
# TEMPORÄRES SCRIPT - liegt eine Ebene über dem homelab Repository
# migrate-documentation.sh
# Migriert das homelab-docs Repository ins neue template-basierte System

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOMELAB_DIR="$SCRIPT_DIR/homelab"
HOMELAB_DOCS_PATH="${1:-$SCRIPT_DIR/homelab-docs}"

echo "📚 Migrating homelab-docs repository..."
echo "📁 Script location: $SCRIPT_DIR"
echo "📁 Target homelab repo: $HOMELAB_DIR"
echo "📁 Source homelab-docs: $HOMELAB_DOCS_PATH"
echo ""

# Prüfe ob homelab Repository existiert
if [[ ! -d "$HOMELAB_DIR" ]]; then
    echo "❌ Homelab repository not found at: $HOMELAB_DIR"
    echo ""
    echo "Please create homelab repository first or run migration from correct directory"
    exit 1
fi

# Prüfe ob homelab-docs Repository existiert
if [[ ! -d "$HOMELAB_DOCS_PATH" ]]; then
    echo "❌ homelab-docs repository not found at: $HOMELAB_DOCS_PATH"
    echo ""
    echo "Usage: $0 [path-to-homelab-docs-repo]"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Uses ./homelab-docs"
    echo "  $0 /path/to/homelab-docs             # Uses custom path"
    echo "  $0 ../old-homelab-docs               # Uses relative path"
    exit 1
fi

# Erstelle benötigte Verzeichnisse
echo "📁 Creating template directories in homelab repository..."
mkdir -p "$HOMELAB_DIR"/{templates/{docs,assets,stylesheets},migration-reference/old-scripts}

echo ""
echo "📝 Converting documentation to templates..."
if [[ -d "$HOMELAB_DOCS_PATH/docs" ]]; then
    # Konvertiere alle Markdown-Dateien zu Templates
    find "$HOMELAB_DOCS_PATH/docs" -name "*.md" -type f | while read -r file; do
        # Berechne relativen Pfad
        relative_path="${file#$HOMELAB_DOCS_PATH/docs/}"
        template_path="$HOMELAB_DIR/templates/docs/$relative_path.j2"
        
        # Erstelle Verzeichnis falls nötig
        mkdir -p "$(dirname "$template_path")"
        
        # Kopiere und konvertiere Datei
        cp "$file" "$template_path"
        echo "  - Converting: $relative_path -> $relative_path.j2"
    done
    echo "✅ Documentation converted to templates"
else
    echo "⚠️  No docs directory found in $HOMELAB_DOCS_PATH"
fi

echo ""
echo "🎨 Copying assets and stylesheets..."

# Kopiere Stylesheets
if [[ -d "$HOMELAB_DOCS_PATH/docs/stylesheets" ]]; then
    cp -r "$HOMELAB_DOCS_PATH/docs/stylesheets"/* "$HOMELAB_DIR/templates/stylesheets/" 2>/dev/null || true
    echo "✅ Stylesheets copied to templates/stylesheets/"
else
    echo "⚠️  No stylesheets directory found"
fi

# Kopiere Assets
if [[ -d "$HOMELAB_DOCS_PATH/docs/assets" ]]; then
    cp -r "$HOMELAB_DOCS_PATH/docs/assets"/* "$HOMELAB_DIR/templates/assets/" 2>/dev/null || true
    echo "✅ Assets copied to templates/assets/"
else
    echo "ℹ️  No assets directory found"
fi

# Kopiere weitere Asset-Verzeichnisse falls vorhanden
for asset_dir in images img media; do
    if [[ -d "$HOMELAB_DOCS_PATH/docs/$asset_dir" ]]; then
        mkdir -p "$HOMELAB_DIR/templates/$asset_dir"
        cp -r "$HOMELAB_DOCS_PATH/docs/$asset_dir"/* "$HOMELAB_DIR/templates/$asset_dir/" 2>/dev/null || true
        echo "✅ $asset_dir copied to templates/$asset_dir/"
    fi
done

echo ""
echo "⚙️ Converting MkDocs configuration..."
if [[ -f "$HOMELAB_DOCS_PATH/mkdocs.yml" ]]; then
    cp "$HOMELAB_DOCS_PATH/mkdocs.yml" "$HOMELAB_DIR/templates/mkdocs.yml.j2"
    echo "✅ MkDocs config converted to template: templates/mkdocs.yml.j2"
    echo "💡 You may need to manually add Jinja2 variables to this template"
else
    echo "⚠️  No mkdocs.yml found in $HOMELAB_DOCS_PATH"
fi

echo ""
echo "📋 Preserving old scripts for reference..."
if [[ -d "$HOMELAB_DOCS_PATH/scripts" ]]; then
    # Kopiere alte Scripts als Referenz (aber nicht als ausführbare Scripts)
    cp -r "$HOMELAB_DOCS_PATH/scripts"/* "$HOMELAB_DIR/migration-reference/old-scripts/" 2>/dev/null || true
    echo "✅ Old scripts saved in migration-reference/old-scripts/"
    echo "ℹ️  These are for reference only and won't be used in the new system"
else
    echo "ℹ️  No scripts directory found to preserve"
fi

# Kopiere weitere nützliche Dateien
echo ""
echo "📄 Copying additional useful files..."
for file in requirements.txt pip-requirements.txt dependencies.txt; do
    if [[ -f "$HOMELAB_DOCS_PATH/$file" ]]; then
        cp "$HOMELAB_DOCS_PATH/$file" "$HOMELAB_DIR/migration-reference/$file.old"
        echo "  - Preserved: $file -> migration-reference/$file.old"
    fi
done

echo ""
echo "✅ Documentation migration completed successfully!"
echo ""
echo "📋 Migration Summary:"
echo "  - Documentation templates: $HOMELAB_DIR/templates/docs/"
echo "  - Stylesheets: $HOMELAB_DIR/templates/stylesheets/"
echo "  - Assets: $HOMELAB_DIR/templates/assets/"
echo "  - MkDocs template: $HOMELAB_DIR/templates/mkdocs.yml.j2"
echo "  - Reference files: $HOMELAB_DIR/migration-reference/"
echo ""
echo "💡 Next step: Run ./update-template-variables.sh"