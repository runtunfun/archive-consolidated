#!/bin/bash
# TEMPORÄRES SCRIPT - liegt eine Ebene über dem homelab Repository
# complete-migration.sh
# Führt die komplette Migration von Infrastructure und homelab-docs durch

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOMELAB_DIR="$SCRIPT_DIR/homelab"
INFRASTRUCTURE_PATH="${1:-$SCRIPT_DIR/Infrastructure}"
HOMELAB_DOCS_PATH="${2:-$SCRIPT_DIR/homelab-docs}"

echo "🚀 Starting complete homelab repository migration..."
echo "======================================================="
echo ""
echo "📁 Script location: $SCRIPT_DIR"
echo "📁 Target homelab repository: $HOMELAB_DIR"
echo "📁 Source repositories:"
echo "  Infrastructure:  $INFRASTRUCTURE_PATH"
echo "  homelab-docs:    $HOMELAB_DOCS_PATH"
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
    echo "  # Add permanent scripts to scripts/ directories"
    echo ""
    echo "Then run this migration from the parent directory."
    exit 1
fi

# Prüfe ob beide Source-Repositories existieren
missing_repos=()
if [[ ! -d "$INFRASTRUCTURE_PATH" ]]; then
    missing_repos+=("Infrastructure: $INFRASTRUCTURE_PATH")
fi
if [[ ! -d "$HOMELAB_DOCS_PATH" ]]; then
    missing_repos+=("homelab-docs: $HOMELAB_DOCS_PATH")
fi

if [[ ${#missing_repos[@]} -gt 0 ]]; then
    echo "❌ Missing source repositories:"
    printf '  %s\n' "${missing_repos[@]}"
    echo ""
    echo "Usage: $0 [infrastructure-path] [homelab-docs-path]"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Use ./Infrastructure and ./homelab-docs"
    echo "  $0 /path/to/Infrastructure           # Custom Infrastructure path"
    echo "  $0 ./Infrastructure ./old-docs      # Custom paths for both"
    exit 1
fi

# Prüfe ob erforderliche temporäre Scripts vorhanden sind
required_scripts=(
    "migrate-infrastructure.sh"
    "migrate-documentation.sh" 
    "update-template-variables.sh"
    "create-example-config.sh"
)

missing_scripts=()
for script in "${required_scripts[@]}"; do
    if [[ ! -f "$SCRIPT_DIR/$script" ]]; then
        missing_scripts+=("$script")
    fi
done

if [[ ${#missing_scripts[@]} -gt 0 ]]; then
    echo "❌ Missing required migration scripts in $SCRIPT_DIR:"
    printf '  %s\n' "${missing_scripts[@]}"
    echo ""
    echo "Please download all migration scripts to the same directory."
    exit 1
fi

# Prüfe ob permanente Scripts im homelab Repository vorhanden sind
required_permanent_scripts=(
    "scripts/setup/setup-environment.sh"
    "scripts/generator/generate-docs.py"
    "scripts/build/develop.sh"
    "scripts/build/build.sh"
    "scripts/maintenance/generate-ansible-templates.sh"
)

missing_permanent_scripts=()
for script in "${required_permanent_scripts[@]}"; do
    if [[ ! -f "$HOMELAB_DIR/$script" ]]; then
        missing_permanent_scripts+=("$script")
    fi
done

if [[ ${#missing_permanent_scripts[@]} -gt 0 ]]; then
    echo "❌ Missing required permanent scripts in homelab repository:"
    printf '  %s\n' "${missing_permanent_scripts[@]}"
    echo ""
    echo "Please download and place permanent scripts in homelab/scripts/ first."
    exit 1
fi

# Mache alle Scripts ausführbar
echo "🔧 Making migration scripts executable..."
chmod +x "$SCRIPT_DIR"/*.sh
chmod +x "$HOMELAB_DIR/scripts"/**/*.sh "$HOMELAB_DIR/scripts"/**/*.py 2>/dev/null || true

echo ""
echo "📋 Migration will proceed in the following steps:"
echo "  1. Migrate Infrastructure repository (Ansible code, concepts)"
echo "  2. Migrate homelab-docs repository (documentation, assets)"
echo "  3. Update templates with variables"
echo "  4. Create example configuration"
echo "  5. Setup Python environment"
echo "  6. Create initial Git commit"
echo ""

read -p "🤔 Continue with migration? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Migration cancelled by user"
    exit 1
fi

echo ""
echo "🎬 Starting migration..."

# Step 1: Infrastructure Migration
echo ""
echo "=================================="
echo "📦 Step 1: Infrastructure Migration"
echo "=================================="
if "$SCRIPT_DIR/migrate-infrastructure.sh" "$INFRASTRUCTURE_PATH"; then
    echo "✅ Infrastructure migration completed"
else
    echo "❌ Infrastructure migration failed"
    exit 1
fi

# Step 2: Documentation Migration
echo ""
echo "===================================="
echo "📚 Step 2: Documentation Migration"
echo "===================================="
if "$SCRIPT_DIR/migrate-documentation.sh" "$HOMELAB_DOCS_PATH"; then
    echo "✅ Documentation migration completed"
else
    echo "❌ Documentation migration failed"
    exit 1
fi

# Step 3: Template Variables Update
echo ""
echo "====================================="
echo "🔄 Step 3: Template Variables Update"
echo "====================================="
if "$SCRIPT_DIR/update-template-variables.sh"; then
    echo "✅ Template variables update completed"
else
    echo "❌ Template variables update failed"
    exit 1
fi

# Step 4: Create Configuration
echo ""
echo "=================================="
echo "⚙️ Step 4: Create Configuration"
echo "=================================="
if "$SCRIPT_DIR/create-example-config.sh"; then
    echo "✅ Configuration creation completed"
else
    echo "❌ Configuration creation failed"
    exit 1
fi

# Step 5: Setup Environment
echo ""
echo "=========================="
echo "🐍 Step 5: Setup Environment"
echo "=========================="
cd "$HOMELAB_DIR"
if ./scripts/setup/setup-environment.sh; then
    echo "✅ Environment setup completed"
else
    echo "❌ Environment setup failed"
    exit 1
fi

# Step 6: Git Operations
echo ""
echo "========================="
echo "📝 Step 6: Git Operations"
echo "========================="

# Prüfe ob Git Repository initialisiert ist
if [[ ! -d "$HOMELAB_DIR/.git" ]]; then
    echo "🔄 Initializing Git repository in homelab..."
    git init
fi

# Staging nur permanente Dateien (temporäre Scripts werden ignoriert)
echo "📋 Staging files for commit..."
git add scripts/ templates/ ansible/ config-example/ requirements.txt .gitignore 2>/dev/null || true

# Füge nur existierende README, QUICKSTART, CONTRIBUTING hinzu
for file in README.md QUICKSTART.md CONTRIBUTING.md; do
    if [[ -f "$file" ]]; then
        git add "$file"
        echo "  - Added: $file"
    fi
done

# Initial commit
echo "💾 Creating initial commit..."
git commit -m "feat: consolidate Infrastructure and homelab-docs repositories

- Migrate Ansible automation from Infrastructure repository
- Convert documentation to template-based system  
- Add configuration-based documentation generation
- Implement new build pipeline with Python generator
- Create example configurations for multiple environments

Breaking changes:
- Documentation now requires configuration files
- Build process changed from static to template-based

Migration completed on $(date)
Migration scripts located in: $SCRIPT_DIR" || echo "⚠️  Commit may have failed (possibly nothing to commit)"

# Zurück zum Script-Verzeichnis
cd "$SCRIPT_DIR"

echo ""
echo "🎉 Migration completed successfully!"
echo "====================================="
echo ""
echo "📋 What was migrated:"
echo "  ✅ Ansible code and roles from Infrastructure"
echo "  ✅ Documentation converted to templates"
echo "  ✅ Assets and stylesheets preserved"
echo "  ✅ Configuration system created"
echo "  ✅ Build pipeline implemented"
echo "  ✅ Git repository initialized with clean commit"
echo ""
echo "📁 Repository structure:"
echo "  📂 $HOMELAB_DIR/ansible/              # Migrated Ansible automation"
echo "  📂 $HOMELAB_DIR/templates/            # Documentation templates"
echo "  📂 $HOMELAB_DIR/scripts/              # Build and maintenance scripts"
echo "  📂 $HOMELAB_DIR/config-example/       # Example configuration"
echo "  📂 $HOMELAB_DIR/config-local/         # Your local configuration (created)"
echo ""
echo "🚀 Next steps:"
echo ""
echo "  1. Review and edit configuration:"
echo "     nano homelab/config-local/network.yml"
echo "     nano homelab/config-local/services.yml"
echo ""
echo "  2. Test documentation generation:"
echo "     cd homelab"
echo "     source venv/bin/activate"
echo "     ./scripts/build/develop.sh"
echo "     # Open http://127.0.0.1:8000"
echo ""
echo "  3. Clean up temporary migration scripts:"
echo "     rm $SCRIPT_DIR/migrate-*.sh"
echo "     rm $SCRIPT_DIR/create-example-config.sh"
echo "     rm $SCRIPT_DIR/complete-migration.sh"
echo "     rm $SCRIPT_DIR/migration-checklist.sh"
echo "     rm $SCRIPT_DIR/update-template-variables.sh"
echo ""
echo "  4. Push to remote repository:"
echo "     cd homelab"
echo "     git remote add origin https://github.com/your-username/homelab.git"
echo "     git branch -M main"
echo "     git push -u origin main"
echo ""
echo "  5. Create migration tag:"
echo "     cd homelab"
echo "     git tag v1.0.0-migration"
echo "     git push origin v1.0.0-migration"
echo ""
echo "💡 Documentation:"
echo "  - homelab/README.md: Project overview and features"
echo "  - homelab/QUICKSTART.md: Detailed setup instructions"
echo "  - homelab/CONTRIBUTING.md: Development and contribution guide"
echo ""
echo "🎯 Success! Your homelab repositories are now consolidated."
echo "🏠 All files are in: $HOMELAB_DIR"
echo "📁 Migration scripts remain in: $SCRIPT_DIR (for cleanup/reference)"