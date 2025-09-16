#!/bin/bash
cd ~/projects/homelab-docs
source venv/bin/activate
echo "🔨 Building documentation..."
mkdocs build
echo "✅ Build complete. Files in ./site/"
echo ""
echo "📤 Deploy options:"
echo "   mkdocs gh-deploy    # GitHub Pages"
echo "   rsync -av site/ user@server:/var/www/docs/  # Own server"
