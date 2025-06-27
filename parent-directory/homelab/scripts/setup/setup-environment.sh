#!/bin/bash
# PERMANENTES SCRIPT - wird ins Git eingecheckt
# scripts/setup/setup-environment.sh
# Einmalige Einrichtung der Python-Umgebung und Dependencies

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo "🔧 Setting up homelab development environment..."
echo "📁 Project root: $PROJECT_ROOT"
echo ""

# Prüfe Python-Version
echo "🐍 Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed or not in PATH"
    echo "Please install Python 3.8 or higher"
    exit 1
fi

python_version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
echo "✅ Found Python $python_version"

if [[ $(python3 -c "import sys; print(int(sys.version_info.major >= 3 and sys.version_info.minor >= 8))") != "1" ]]; then
    echo "❌ Python 3.8 or higher is required"
    echo "Current version: $python_version"
    exit 1
fi

# Erstelle Python Virtual Environment
echo ""
echo "📦 Setting up Python virtual environment..."
if [[ -d "$PROJECT_ROOT/venv" ]]; then
    echo "ℹ️  Virtual environment already exists"
    read -p "🔄 Recreate virtual environment? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  Removing existing virtual environment..."
        rm -rf "$PROJECT_ROOT/venv"
    fi
fi

if [[ ! -d "$PROJECT_ROOT/venv" ]]; then
    echo "🏗️  Creating new virtual environment..."
    cd "$PROJECT_ROOT"
    python3 -m venv venv
    echo "✅ Virtual environment created"
fi

# Aktiviere Virtual Environment
echo "🔌 Activating virtual environment..."
cd "$PROJECT_ROOT"
source venv/bin/activate

# Upgrade pip
echo "⬆️  Upgrading pip..."
python -m pip install --upgrade pip

# Installiere Dependencies
echo ""
echo "📥 Installing Python dependencies..."
if [[ -f "$PROJECT_ROOT/requirements.txt" ]]; then
    pip install -r requirements.txt
    echo "✅ Dependencies installed from requirements.txt"
else
    echo "⚠️  requirements.txt not found, installing minimal dependencies..."
    pip install mkdocs mkdocs-material jinja2 pyyaml
fi

# Erstelle lokale Konfiguration falls nicht vorhanden
echo ""
echo "📋 Setting up local configuration..."
if [[ ! -d "$PROJECT_ROOT/config-local" ]]; then
    if [[ -d "$PROJECT_ROOT/config-example" ]]; then
        echo "📁 Creating local configuration from example..."
        cp -r "$PROJECT_ROOT/config-example" "$PROJECT_ROOT/config-local"
        echo "✅ Configuration copied to config-local/"
        echo "💡 Edit files in config-local/ to match your infrastructure"
    else
        echo "⚠️  config-example directory not found"
        echo "Run migration scripts first to create example configuration"
    fi
else
    echo "ℹ️  Local configuration already exists in config-local/"
fi

# Mache Scripts ausführbar
echo ""
echo "🔧 Making scripts executable..."
find "$PROJECT_ROOT/scripts" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
find "$PROJECT_ROOT/scripts" -name "*.py" -type f -exec chmod +x {} \; 2>/dev/null || true
echo "✅ Scripts made executable"

# Teste Installation
echo ""
echo "🧪 Testing installation..."

# Test Python imports
echo "🔍 Testing Python dependencies..."
python -c "
import sys
required_modules = ['yaml', 'jinja2']
try:
    import mkdocs
    print('✅ MkDocs available')
except ImportError:
    print('⚠️  MkDocs not available')

for module in required_modules:
    try:
        __import__(module)
        print(f'✅ {module} available')
    except ImportError:
        print(f'❌ {module} not available')
        sys.exit(1)
"

# Test Dokumentations-Generator
if [[ -f "$PROJECT_ROOT/scripts/generator/generate-docs.py" ]] && [[ -d "$PROJECT_ROOT/config-local" ]]; then
    echo "🔍 Testing documentation generator..."
    if python "$PROJECT_ROOT/scripts/generator/generate-docs.py" --config "$PROJECT_ROOT/config-local" --validate-only 2>/dev/null; then
        echo "✅ Documentation generator works"
    else
        echo "⚠️  Documentation generator test failed (check configuration)"
    fi
fi

echo ""
echo "✅ Environment setup completed successfully!"
echo ""
echo "📋 Summary:"
echo "  - Python virtual environment: venv/"
echo "  - Dependencies installed from requirements.txt"
echo "  - Local configuration: config-local/"
echo "  - Scripts made executable"
echo ""
echo "🚀 Next steps:"
echo ""
echo "1. Activate the virtual environment:"
echo "   source venv/bin/activate"
echo ""
echo "2. Edit your configuration:"
echo "   nano config-local/network.yml"
echo "   nano config-local/services.yml"
echo ""
echo "3. Generate documentation:"
echo "   ./scripts/build/develop.sh"
echo "   # Opens http://127.0.0.1:8000"
echo ""
echo "4. Build for production:"
echo "   ./scripts/build/build.sh"
echo ""
echo "💡 Useful commands:"
echo "  - Development server: ./scripts/build/develop.sh"
echo "  - Production build: ./scripts/build/build.sh"
echo "  - Validate config: python scripts/generator/generate-docs.py --config config-local --validate-only"
echo "  - Different environment: HOMELAB_ENV=test ./scripts/build/develop.sh"
echo ""
echo "📚 Documentation:"
echo "  - README.md: Project overview"
echo "  - QUICKSTART.md: Detailed setup guide"
echo "  - CONTRIBUTING.md: Development guide"