#!/bin/bash
# TEMPORÄRES SCRIPT - liegt eine Ebene über dem homelab Repository
# update-template-variables.sh
# Ersetzt statische Werte in Templates durch Jinja2-Variablen

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOMELAB_DIR="$SCRIPT_DIR/homelab"

echo "🔄 Adding template variables to documentation..."
echo "📁 Script location: $SCRIPT_DIR"
echo "📁 Target homelab repo: $HOMELAB_DIR"
echo ""

# Prüfe ob homelab Repository existiert
if [[ ! -d "$HOMELAB_DIR" ]]; then
    echo "❌ Homelab repository not found at: $HOMELAB_DIR"
    echo "Please run migration from correct directory"
    exit 1
fi

# Prüfe ob templates/docs Verzeichnis existiert
if [[ ! -d "$HOMELAB_DIR/templates/docs" ]]; then
    echo "❌ templates/docs directory not found in homelab repository!"
    echo "Please run migrate-documentation.sh first."
    exit 1
fi

# Wechsle ins homelab Verzeichnis
cd "$HOMELAB_DIR"

# Backup erstellen
echo "💾 Creating backup of templates..."
if [[ ! -d "templates-backup" ]]; then
    cp -r templates templates-backup
    echo "✅ Backup created: templates-backup/"
fi

# Funktion um statische Werte durch Template-Variablen zu ersetzen
update_template_file() {
    local file="$1"
    local temp_file
    temp_file=$(mktemp)
    
    echo "  - Processing: $(basename "$file")"
    
    # Ersetze häufige statische Werte durch Jinja2-Variablen
    sed -E \
        -e 's/192\.168\.10\.([0-9]+)/{{ networks.management.subnet | replace("\/24", "") | replace("0", "\1") }}/g' \
        -e 's/192\.168\.20\.([0-9]+)/{{ networks.iot.subnet | replace("\/24", "") | replace("0", "\1") }}/g' \
        -e 's/192\.168\.30\.([0-9]+)/{{ networks.guest.subnet | replace("\/24", "") | replace("0", "\1") }}/g' \
        -e 's/192\.168\.[0-9]+\.[0-9]+/{{ networks.management.gateway | default("192.168.10.1") }}/g' \
        -e 's/lab\.local/{{ domain.internal | default("lab.local") }}/g' \
        -e 's/example\.com/{{ domain.external | default("example.com") }}/g' \
        -e 's/My Homelab Documentation/{{ site.name | default("My Homelab Documentation") }}/g' \
        -e 's/My Homelab/{{ site.name | default("My Homelab") }}/g' \
        -e 's/homelab\.local/{{ domain.internal | default("homelab.local") }}/g' \
        -e 's/pi-?hole\.([a-zA-Z0-9.-]+)/pihole.{{ domain.internal | default("lab.local") }}/g' \
        -e 's/traefik\.([a-zA-Z0-9.-]+)/traefik.{{ domain.internal | default("lab.local") }}/g' \
        -e 's/ha\.([a-zA-Z0-9.-]+)/ha.{{ domain.internal | default("lab.local") }}/g' \
        -e 's/prometheus\.([a-zA-Z0-9.-]+)/prometheus.{{ domain.internal | default("lab.local") }}/g' \
        -e 's/grafana\.([a-zA-Z0-9.-]+)/grafana.{{ domain.internal | default("lab.local") }}/g' \
        "$file" > "$temp_file"
    
    # Zusätzliche spezifische Ersetzungen für häufige Patterns
    sed -i -E \
        -e 's/VLAN 10/VLAN {{ networks.management.vlan_id | default(10) }}/g' \
        -e 's/VLAN 20/VLAN {{ networks.iot.vlan_id | default(20) }}/g' \
        -e 's/VLAN 30/VLAN {{ networks.guest.vlan_id | default(30) }}/g' \
        -e 's/Port 8080/Port {{ services.pihole.admin_port | default(8080) }}/g' \
        -e 's/Port 8123/Port {{ services.homeassistant.port | default(8123) }}/g' \
        "$temp_file"
    
    # Überschreibe Original nur wenn Änderungen gemacht wurden
    if ! cmp -s "$file" "$temp_file"; then
        mv "$temp_file" "$file"
        return 0
    else
        rm -f "$temp_file"
        return 1
    fi
}

# Zähler für Statistiken
updated_files=0
total_files=0

echo "🔍 Processing template files..."
echo ""

# Update alle Template-Dateien
while IFS= read -r -d '' file; do
    ((total_files++))
    if update_template_file "$file"; then
        ((updated_files++))
    fi
done < <(find templates/docs -name "*.j2" -type f -print0)

echo ""
echo "📊 Template update statistics:"
echo "  - Total files processed: $total_files"
echo "  - Files updated: $updated_files"
echo "  - Files unchanged: $((total_files - updated_files))"

# Spezielle Template-Ergänzungen
echo ""
echo "🎨 Adding template headers to key files..."

# Füge Template-Header zur index.md.j2 hinzu (falls vorhanden)
if [[ -f "templates/docs/index.md.j2" ]]; then
    temp_file=$(mktemp)
    cat > "$temp_file" << 'EOF'
{#
Template: Main documentation index
Description: Homepage for the homelab documentation
Variables:
  - site: Site configuration (name, description, author)
  - domain: Domain configuration (internal, external)
  - networks: Network configuration (management, iot, guest)
  - services: Service configuration (all enabled services)
#}

EOF
    cat "templates/docs/index.md.j2" >> "$temp_file"
    mv "$temp_file" "templates/docs/index.md.j2"
    echo "  - Added template header to index.md.j2"
fi

# Update MkDocs template falls vorhanden
if [[ -f "templates/mkdocs.yml.j2" ]]; then
    echo "  - Updating MkDocs template with variables..."
    temp_file=$(mktemp)
    cat > "$temp_file" << 'EOF'
{#
Template: MkDocs configuration
Description: Main MkDocs configuration with template variables
Variables:
  - site: Site configuration
  - domain: Domain settings
  - features: Feature toggles
#}

EOF
    # Ersetze statische Werte in mkdocs.yml
    sed -E \
        -e 's/site_name:.*/site_name: "{{ site.name | default(\"Homelab Documentation\") }}"/g' \
        -e 's/site_description:.*/site_description: "{{ site.description | default(\"Comprehensive homelab infrastructure documentation\") }}"/g' \
        -e 's/site_author:.*/site_author: "{{ site.author | default(\"Homelab Owner\") }}"/g' \
        -e 's|site_url:.*|site_url: "{{ site.url | default(\"https://homelab.local\") }}"|g' \
        "templates/mkdocs.yml.j2" >> "$temp_file"
    mv "$temp_file" "templates/mkdocs.yml.j2"
    echo "  - Updated mkdocs.yml.j2 with template variables"
fi

# Zurück zum Script-Verzeichnis
cd "$SCRIPT_DIR"

echo ""
echo "✅ Template variables update completed successfully!"
echo ""
echo "📋 What was changed:"
echo "  - IP addresses -> {{ networks.*.gateway }} variables"
echo "  - Domain names -> {{ domain.internal/external }} variables"
echo "  - Service names -> {{ services.*.host }} variables"
echo "  - VLAN IDs -> {{ networks.*.vlan_id }} variables"
echo "  - Site information -> {{ site.* }} variables"
echo ""
echo "💡 Next step: Run ./create-example-config.sh"
echo "📝 Review homelab/templates-backup/ if you need to check original content"