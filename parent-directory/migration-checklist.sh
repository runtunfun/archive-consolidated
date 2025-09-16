#!/bin/bash
# TEMPORÄRES SCRIPT - liegt eine Ebene über dem homelab Repository
# migration-checklist.sh
# Validiert die erfolgreiche Migration der Repositories

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOMELAB_DIR="$SCRIPT_DIR/homelab"

echo "📋 Migration Validation Checklist"
echo "=================================="
echo "📁 Script location: $SCRIPT_DIR"
echo "📁 Target homelab repo: $HOMELAB_DIR"
echo ""

# Farbige Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

failed_checks=0
passed_checks=0
warning_checks=0

check_item() {
    local description="$1"
    local check_command="$2"
    local is_critical="${3:-true}"
    
    printf "%-50s " "$description"
    
    # Führe Check im homelab Verzeichnis aus
    if (cd "$HOMELAB_DIR" && eval "$check_command") >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((passed_checks++))
        return 0
    else
        if [[ "$is_critical" == "true" ]]; then
            echo -e "${RED}❌ FAIL${NC}"
            ((failed_checks++))
        else
            echo -e "${YELLOW}⚠️  WARN${NC}"
            ((warning_checks++))
        fi
        return 1
    fi
}

info_item() {
    local description="$1"
    local info="$2"
    printf "%-50s ${BLUE}ℹ️  %s${NC}\n" "$description" "$info"
}

# Prüfe ob homelab Repository existiert
if [[ ! -d "$HOMELAB_DIR" ]]; then
    echo -e "${RED}❌ Homelab repository not found at: $HOMELAB_DIR${NC}"
    echo ""
    echo "Please run migration first or check directory structure."
    exit 1
fi

echo "🏗️ Repository Structure Validation"
echo "-----------------------------------"

check_item "Homelab repository exists" "test -d ."
check_item "Templates directory" "test -d templates/docs && ls templates/docs/*.j2 >/dev/null 2>&1"
check_item "Ansible directory structure" "test -d ansible/roles && test -d ansible/playbooks"
check_item "Scripts directory structure" "test -d scripts/setup && test -d scripts/build && test -d scripts/generator"
check_item "Configuration examples" "test -f config-example/network.yml && test -f config-example/services.yml"

echo ""
echo "📦 Ansible Migration Validation"
echo "-------------------------------"

check_item "Ansible roles migrated" "test -d ansible/roles && ls ansible/roles/ | grep -q 'r_'" false
check_item "Ansible playbooks migrated" "test -d ansible/playbooks && find ansible/playbooks -name '*.yml' | grep -q '.'" false
check_item "Ansible inventories migrated" "test -d ansible/inventories" false
check_item "Group vars present" "test -d ansible/group_vars || test -f ansible/group_vars/all.yml" false

# Zähle migrierte Komponenten
if [[ -d "$HOMELAB_DIR/ansible/roles" ]]; then
    role_count=$(find "$HOMELAB_DIR/ansible/roles" -maxdepth 1 -type d | grep -c 'r_' || echo "0")
    info_item "Migrated roles count" "$role_count roles"
fi

if [[ -d "$HOMELAB_DIR/ansible/playbooks" ]]; then
    playbook_count=$(find "$HOMELAB_DIR/ansible/playbooks" -name "*.yml" | wc -l || echo "0")
    info_item "Migrated playbooks count" "$playbook_count playbooks"
fi

echo ""
echo "📚 Documentation Migration Validation"
echo "------------------------------------"

check_item "Documentation templates created" "find templates/docs -name '*.j2' | grep -q '.'"
check_item "MkDocs template created" "test -f templates/mkdocs.yml.j2"
check_item "Template variables added" "grep -q '{{.*}}' templates/docs/*.j2" false
check_item "Assets migrated" "test -d templates/assets || test -d templates/stylesheets" false

# Zähle Template-Dateien
if [[ -d "$HOMELAB_DIR/templates/docs" ]]; then
    template_count=$(find "$HOMELAB_DIR/templates/docs" -name "*.j2" | wc -l)
    info_item "Template files created" "$template_count templates"
fi

echo ""
echo "⚙️ Configuration System Validation"
echo "---------------------------------"

check_item "Example configuration created" "test -f config-example/network.yml && test -f config-example/services.yml"
check_item "Infrastructure config created" "test -f config-example/infrastructure.yml && test -f config-example/documentation.yml"
check_item "Environment configs created" "test -d config-example/environments"
check_item "Local config directory created" "test -d config-local" false

# Validiere YAML-Syntax der Konfigurationsdateien
echo ""
echo "🔍 Configuration File Validation"
echo "-------------------------------"

config_files=(
    "config-example/network.yml"
    "config-example/services.yml" 
    "config-example/infrastructure.yml"
    "config-example/documentation.yml"
)

for config_file in "${config_files[@]}"; do
    if [[ -f "$HOMELAB_DIR/$config_file" ]]; then
        check_item "YAML syntax: $(basename "$config_file")" "python3 -c \"import yaml; yaml.safe_load(open('$config_file'))\"" false
    fi
done

echo ""
echo "🐍 Build System Validation"
echo "-------------------------"

check_item "Python environment setup" "test -d venv" false
check_item "Requirements file exists" "test -f requirements.txt"
check_item "Build scripts executable" "test -x scripts/build/develop.sh && test -x scripts/build/build.sh"
check_item "Documentation generator present" "test -f scripts/generator/generate-docs.py"
check_item "Setup script present" "test -f scripts/setup/setup-environment.sh"

echo ""
echo "🧪 Functional Testing"
echo "--------------------"

# Test ob Python environment funktioniert
if [[ -d "$HOMELAB_DIR/venv" ]] && [[ -f "$HOMELAB_DIR/venv/bin/activate" ]]; then
    check_item "Python virtual environment" "source venv/bin/activate && python --version" false
    check_item "Required Python packages" "source venv/bin/activate && python -c 'import yaml, jinja2'" false
else
    echo -e "⚠️  Python environment not set up - run ${YELLOW}cd homelab && ./scripts/setup/setup-environment.sh${NC}"
fi

# Test Dokumentations-Generierung (nur wenn config-local existiert)
if [[ -d "$HOMELAB_DIR/config-local" ]]; then
    check_item "Documentation generation test" "python scripts/generator/generate-docs.py --config config-local --validate-only" false
else
    echo -e "ℹ️  Local config not found - copy ${BLUE}config-example${NC} to ${BLUE}config-local${NC} to test generation"
fi

echo ""
echo "📝 Git Repository Validation"
echo "---------------------------"

check_item "Git repository initialized" "test -d .git"
check_item "Gitignore file present" "test -f .gitignore"
check_item "Initial commit exists" "git log --oneline | grep -q '.'" false

# Prüfe ob wichtige Dateien im Git sind
git_files=(
    "scripts/setup/setup-environment.sh"
    "scripts/build/develop.sh"
    "scripts/generator/generate-docs.py"
    "templates/mkdocs.yml.j2"
    "config-example/network.yml"
)

echo ""
echo "📂 Git Tracked Files Validation"
echo "------------------------------"

for file in "${git_files[@]}"; do
    if [[ -f "$HOMELAB_DIR/$file" ]]; then
        check_item "Git tracking: $(basename "$file")" "git ls-files --error-unmatch '$file'" false
    fi
done

echo ""
echo "🔒 Security and Cleanup Validation"
echo "---------------------------------"

check_item "Private configs not in git" "! git ls-files | grep -q 'config-local/'" false
check_item "Virtual env not in git" "! git ls-files | grep -q 'venv/'" false
check_item "Generated docs not in git" "! git ls-files | grep -q 'docs/\\|site/'" false

# Prüfe ob temporäre Scripts außerhalb des Repositories sind
echo ""
echo "🧹 Temporary Scripts Location"
echo "----------------------------"

temp_scripts=(
    "migrate-infrastructure.sh"
    "migrate-documentation.sh"
    "update-template-variables.sh"
    "create-example-config.sh"
    "complete-migration.sh"
    "migration-checklist.sh"
)

for script in "${temp_scripts[@]}"; do
    if [[ -f "$SCRIPT_DIR/$script" ]]; then
        echo -e "✅ Temporary script outside repo: ${GREEN}$script${NC}"
    else
        echo -e "⚠️  Missing temporary script: ${YELLOW}$script${NC}"
    fi
done

echo ""
echo "📊 Migration Summary"
echo "==================="

total_checks=$((passed_checks + failed_checks + warning_checks))

echo -e "Total checks: ${BLUE}$total_checks${NC}"
echo -e "Passed: ${GREEN}$passed_checks${NC}"
echo -e "Failed: ${RED}$failed_checks${NC}"
echo -e "Warnings: ${YELLOW}$warning_checks${NC}"

echo ""

if [[ $failed_checks -eq 0 ]]; then
    echo -e "${GREEN}🎉 Migration validation SUCCESSFUL!${NC}"
    echo ""
    echo "✅ All critical checks passed"
    if [[ $warning_checks -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  $warning_checks warnings - review items above${NC}"
    fi
    echo ""
    echo "🚀 Ready to proceed:"
    echo ""
    echo "  1. Test documentation generation:"
    echo "     cd $HOMELAB_DIR"
    echo "     source venv/bin/activate"
    echo "     ./scripts/build/develop.sh"
    echo ""
    echo "  2. Clean up temporary migration scripts:"
    echo "     rm $SCRIPT_DIR/migrate-*.sh"
    echo "     rm $SCRIPT_DIR/create-example-config.sh"
    echo "     rm $SCRIPT_DIR/complete-migration.sh"
    echo "     rm $SCRIPT_DIR/migration-checklist.sh"
    echo "     rm $SCRIPT_DIR/update-template-variables.sh"
    echo ""
    echo "  3. Push to remote repository:"
    echo "     cd $HOMELAB_DIR"
    echo "     git remote add origin https://github.com/your-username/homelab.git"
    echo "     git push -u origin main"
    
else
    echo -e "${RED}❌ Migration validation FAILED${NC}"
    echo ""
    echo -e "${RED}$failed_checks critical issues found.${NC}"
    echo "Please review and fix the failed checks above before proceeding."
    echo ""
    echo "Common solutions:"
    echo "  - Run missing migration scripts from $SCRIPT_DIR"
    echo "  - Check file permissions: chmod +x $HOMELAB_DIR/scripts/**/*.sh"
    echo "  - Verify source repository paths"
    echo "  - Install required dependencies"
fi

echo ""
echo "📋 For detailed setup instructions, see:"
echo "  - $HOMELAB_DIR/README.md: Project overview"
echo "  - $HOMELAB_DIR/QUICKSTART.md: Step-by-step setup guide"
echo "  - $HOMELAB_DIR/CONTRIBUTING.md: Development information"

exit $failed_checks