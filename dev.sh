#!/bin/bash
cd ~/projects/homelab-docs
source venv/bin/activate
echo "🚀 Starting MkDocs development server..."
mkdocs serve --dev-addr=0.0.0.0:8000
