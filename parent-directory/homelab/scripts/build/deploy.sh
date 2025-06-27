#!/bin/bash
# PERMANENTES SCRIPT - wird ins Git eingecheckt
# scripts/build/deploy.sh
# Deployment der Dokumentation zu verschiedenen Zielen

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Farbige Ausgabe
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Homelab Documentation Deployment${NC}"
echo "======================================="
echo ""

# Parameter verarbeiten
DEPLOY_TARGET="${1:-}"
ENVIRONMENT="${HOMELAB_ENV:-production}"
CONFIG_PATH="${HOMELAB_CONFIG_PATH:-$PROJECT_ROOT/config-local}"

if [[ -z "$DEPLOY_TARGET" ]]; then
    echo "❌ No deployment target specified!"
    echo ""
    echo "Usage: $0 <target> [options]"
    echo ""
    echo "Available targets:"
    echo "  github      Deploy to GitHub Pages"
    echo "  netlify     Deploy to Netlify"
    echo "  server      Deploy to custom server via rsync"
    echo "  s3          Deploy to AWS S3"
    echo "  local       Serve locally for testing"
    echo ""
    echo "Examples:"
    echo "  $0 github"
    echo "  $0 server user@example.com:/var/www/html"
    echo "  HOMELAB_ENV=test $0 github"
    exit 1
fi

echo "🎯 Deployment target: $DEPLOY_TARGET"
echo "🔧 Environment: $ENVIRONMENT"
echo "📁 Config path: $CONFIG_PATH"
echo ""

# Prüfe ob Virtual Environment existiert
if [[ ! -d "$PROJECT_ROOT/venv" ]]; then
    echo -e "${RED}❌ Python virtual environment not found!${NC}"
    echo "Run: ./scripts/setup/setup-environment.sh"
    exit 1
fi

# Aktiviere Virtual Environment
source "$PROJECT_ROOT/venv/bin/activate"

# Prüfe ob Build existiert
if [[ ! -d "$PROJECT_ROOT/site" ]]; then
    echo -e "${YELLOW}⚠️  No build found, creating production build...${NC}"
    echo ""
    if ! HOMELAB_ENV="$ENVIRONMENT" HOMELAB_CONFIG_PATH="$CONFIG_PATH" "$PROJECT_ROOT/scripts/build/build.sh"; then
        echo -e "${RED}❌ Build failed!${NC}"
        exit 1
    fi
fi

# Deployment-spezifische Funktionen
deploy_github() {
    echo -e "${BLUE}📤 Deploying to GitHub Pages...${NC}"
    echo ""
    
    # Prüfe ob Git Repository
    if [[ ! -d "$PROJECT_ROOT/.git" ]]; then
        echo -e "${RED}❌ Not a Git repository!${NC}"
        echo "Initialize Git first: git init"
        exit 1
    fi
    
    # Prüfe ob Remote existiert
    if ! git remote get-url origin >/dev/null 2>&1; then
        echo -e "${RED}❌ No Git remote 'origin' found!${NC}"
        echo "Add remote: git remote add origin https://github.com/username/repo.git"
        exit 1
    fi
    
    # GitHub Pages Deployment mit MkDocs
    cd "$PROJECT_ROOT"
    echo "🔧 Using MkDocs GitHub Pages deployment..."
    
    if mkdocs gh-deploy --clean --verbose; then
        echo -e "${GREEN}✅ Successfully deployed to GitHub Pages!${NC}"
        
        # Zeige GitHub Pages URL
        remote_url=$(git remote get-url origin)
        if [[ "$remote_url" =~ github\.com[:/]([^/]+)/([^/.]+) ]]; then
            username="${BASH_REMATCH[1]}"
            repo="${BASH_REMATCH[2]}"
            echo ""
            echo -e "${GREEN}🌐 Your documentation is available at:${NC}"
            echo -e "${BLUE}   https://${username}.github.io/${repo}${NC}"
        fi
    else
        echo -e "${RED}❌ GitHub Pages deployment failed!${NC}"
        exit 1
    fi
}

deploy_netlify() {
    echo -e "${BLUE}📤 Deploying to Netlify...${NC}"
    echo ""
    
    # Prüfe ob Netlify CLI installiert ist
    if ! command -v netlify &> /dev/null; then
        echo -e "${RED}❌ Netlify CLI not found!${NC}"
        echo "Install with: npm install -g netlify-cli"
        echo "Or: curl -L https://cli.netlify.com/install.sh | sh"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
    
    # Netlify Deployment
    echo "🔧 Deploying to Netlify..."
    if netlify deploy --prod --dir=site; then
        echo -e "${GREEN}✅ Successfully deployed to Netlify!${NC}"
    else
        echo -e "${RED}❌ Netlify deployment failed!${NC}"
        exit 1
    fi
}

deploy_server() {
    local server_target="${2:-}"
    
    if [[ -z "$server_target" ]]; then
        echo -e "${RED}❌ Server target not specified!${NC}"
        echo "Usage: $0 server user@hostname:/path/to/webroot"
        echo "Example: $0 server deploy@example.com:/var/www/html"
        exit 1
    fi
    
    echo -e "${BLUE}📤 Deploying to server: $server_target${NC}"
    echo ""
    
    # Prüfe ob rsync verfügbar ist
    if ! command -v rsync &> /dev/null; then
        echo -e "${RED}❌ rsync not found!${NC}"
        echo "Install rsync first"
        exit 1
    fi
    
    # Test SSH-Verbindung
    server_host=$(echo "$server_target" | cut -d: -f1)
    echo "🔍 Testing SSH connection to $server_host..."
    
    if ssh -o ConnectTimeout=10 -o BatchMode=yes "$server_host" exit 2>/dev/null; then
        echo -e "${GREEN}✅ SSH connection successful${NC}"
    else
        echo -e "${RED}❌ SSH connection failed!${NC}"
        echo "Check your SSH key or server access"
        exit 1
    fi
    
    # Rsync Deployment
    echo "📦 Synchronizing files..."
    if rsync -avz --delete --exclude '.git' "$PROJECT_ROOT/site/" "$server_target/"; then
        echo -e "${GREEN}✅ Successfully deployed to server!${NC}"
        echo ""
        echo -e "${BLUE}🌐 Documentation deployed to: $server_target${NC}"
    else
        echo -e "${RED}❌ Server deployment failed!${NC}"
        exit 1
    fi
}

deploy_s3() {
    local s3_bucket="${2:-}"
    
    if [[ -z "$s3_bucket" ]]; then
        echo -e "${RED}❌ S3 bucket not specified!${NC}"
        echo "Usage: $0 s3 s3://your-bucket-name"
        exit 1
    fi
    
    echo -e "${BLUE}📤 Deploying to S3: $s3_bucket${NC}"
    echo ""
    
    # Prüfe ob AWS CLI verfügbar ist
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}❌ AWS CLI not found!${NC}"
        echo "Install AWS CLI first: https://aws.amazon.com/cli/"
        exit 1
    fi
    
    # Test AWS-Konfiguration
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        echo -e "${RED}❌ AWS credentials not configured!${NC}"
        echo "Run: aws configure"
        exit 1
    fi
    
    # S3 Sync
    echo "📦 Synchronizing to S3..."
    if aws s3 sync "$PROJECT_ROOT/site/" "$s3_bucket" --delete; then
        echo -e "${GREEN}✅ Successfully deployed to S3!${NC}"
        echo ""
        echo -e "${BLUE}🌐 Documentation available at: $s3_bucket${NC}"
        
        # Zeige CloudFront URL falls verfügbar
        echo ""
        echo "💡 Don't forget to:"
        echo "  - Configure S3 bucket for static website hosting"
        echo "  - Set up CloudFront distribution (optional)"
        echo "  - Configure custom domain (optional)"
    else
        echo -e "${RED}❌ S3 deployment failed!${NC}"
        exit 1
    fi
}

deploy_local() {
    local port="${2:-8080}"
    
    echo -e "${BLUE}🌐 Starting local server on port $port...${NC}"
    echo ""
    echo -e "${GREEN}📱 Documentation available at:${NC}"
    echo -e "${BLUE}   http://localhost:$port${NC}"
    echo ""
    echo "Press Ctrl+C to stop the server"
    echo ""
    
    cd "$PROJECT_ROOT/site"
    python3 -m http.server "$port"
}

# Hauptlogik für Deployment-Ziel
case "$DEPLOY_TARGET" in
    "github")
        deploy_github
        ;;
    "netlify")
        deploy_netlify
        ;;
    "server")
        deploy_server "$@"
        ;;
    "s3")
        deploy_s3 "$@"
        ;;
    "local")
        deploy_local "$@"
        ;;
    *)
        echo -e "${RED}❌ Unknown deployment target: $DEPLOY_TARGET${NC}"
        echo ""
        echo "Available targets: github, netlify, server, s3, local"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"

# Deployment-spezifische Nachbereitung
case "$DEPLOY_TARGET" in
    "github"|"netlify"|"server"|"s3")
        echo ""
        echo "📊 Deployment Information:"
        echo "  Environment: $ENVIRONMENT"
        echo "  Build time: $(date)"
        echo "  Git commit: $(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
        echo "  Site size: $(du -sh "$PROJECT_ROOT/site" | cut -f1)"
        
        # Zeige wichtige URLs
        echo ""
        echo "🔗 Important links:"
        echo "  - Documentation: Check deployment target output above"
        echo "  - Repository: $(git remote get-url origin 2>/dev/null || echo 'No remote configured')"
        echo "  - Issues: Create GitHub issues for problems"
        ;;
esac

echo ""
echo "💡 Next deployment: Re-run this script after making changes"