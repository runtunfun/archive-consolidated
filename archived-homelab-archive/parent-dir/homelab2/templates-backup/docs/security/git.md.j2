# Git Integration

## Sicherheitsrichtlinien für Versionskontrolle

!!! danger "Kritische Sicherheitsregel"
    Ein einziger Git-Commit mit Credentials kann zur Kompromittierung der gesamten Infrastruktur führen. Git-Historie ist praktisch unveränderlich und öffentlich einsehbar.

### Was gehört in Git, was nicht

Die strikte Trennung zwischen öffentlichen Templates und privaten Credentials ist essentiell für sichere Homelab-Verwaltung.

#### ✅ Sicher für Git (öffentlich)

```bash
# Konfigurationstemplates
**/.env.example           # Templates ohne echte Secrets
**/.env.template          # Alternative Template-Namen
**/docker-compose.yml     # Service-Definitionen
**/unbound.conf          # DNS-Konfiguration
**/prometheus.yml        # Monitoring-Configs
**/grafana/dashboards/   # Dashboard-Definitionen

# Automatisierung
**/scripts/*.sh          # Deployment-Scripts
**/Makefile             # Build-Automatisierung
**/README.md            # Dokumentation

# Infrastruktur-Code
**/terraform/*.tf       # Infrastructure as Code
**/ansible/*.yml        # Automatisierung
**/.gitignore           # Git-Schutz
```

#### ❌ NIEMALS in Git (privat)

```bash
# Sensitive Konfiguration
**/.env                  # Echte Environment-Variablen
**/*password*           # Passwort-Dateien aller Art
**/*secret*             # Secret-Dateien
**/*key*.pem            # Private Zertifikate
**/*token*              # API-Tokens

# Backup-Daten
**/backup/*.tar.gz      # Unverschlüsselte Backups
**/secrets/gpg-keys/    # Private GPG-Keys
**/secrets/ssh-keys/    # SSH Private Keys

# Cache und Temporary
**/.gnupg/              # GPG-Verzeichnis
**/node_modules/        # Package-Cache
**/__pycache__/         # Python-Cache
**/.terraform/          # Terraform-Cache
```

## Git-Repository Struktur

### Empfohlene Verzeichnisstruktur

```bash title="Homelab Git-Repository Layout"
homelab-infrastructure/
├── .gitignore                    # Zentrale Git-Schutz-Konfiguration
├── README.md                     # Hauptdokumentation
├── docs/                         # MkDocs-Dokumentation
│   ├── index.md
│   ├── network/
│   ├── services/
│   └── security/
├── services/                     # Service-Definitionen
│   ├── dns-stack/
│   │   ├── docker-compose.yml
│   │   ├── .env.example
│   │   ├── unbound.conf
│   │   └── README.md
│   ├── traefik/
│   │   ├── docker-compose.yml
│   │   ├── .env.example
│   │   └── config/
│   ├── homeassistant/
│   │   ├── docker-compose.yml
│   │   ├── .env.example
│   │   └── config/
│   └── monitoring/
│       ├── docker-compose.yml
│       ├── .env.example
│       └── config/
├── scripts/                      # Automatisierungs-Scripts
│   ├── init-environment.sh
│   ├── backup-secrets.sh
│   ├── deploy-stack.sh
│   └── update-services.sh
├── terraform/                    # Infrastructure as Code (optional)
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── ansible/                      # Konfiguration-Management (optional)
    ├── playbook.yml
    ├── inventory/
    └── roles/
```

### .gitignore Konfiguration

```bash title=".gitignore"
# === SENSIBLE DATEN (NIEMALS COMMITTEN) ===

# Environment-Dateien mit echten Secrets
**/.env
**/.env.local
**/.env.production
**/.env.*.local

# ABER: Templates sind erlaubt
!**/.env.example
!**/.env.template
!**/.env.sample

# Secrets und Credentials
**/secrets/
**/*secret*
**/*password*
**/*credential*
**/*key*.pem
**/*key*.key
**/*token*
**/ssl/private/
**/.ssh/id_*

# Backup-Daten
**/backup/
**/backups/
**/*.tar.gz
**/*.zip
**/*.gpg
!**/*.example.gpg

# GPG und Kryptographie
**/.gnupg/
**/gnupg/
**/gpg/private/
**/.sops.yaml.bak

# === CACHE UND TEMPORARY ===

# System Cache
**/.DS_Store
**/Thumbs.db
**/.directory

# Development Cache
**/node_modules/
**/__pycache__/
**/.pytest_cache/
**/.mypy_cache/
**/*.pyc
**/*.pyo

# Tool-spezifischer Cache
**/.terraform/
**/.terraform.lock.hcl
**/terraform.tfstate*
**/.vagrant/
**/.ansible/tmp/

# Container-Runtime
**/docker-compose.override.yml
**/.docker/

# === LOGS UND MONITORING ===

# Logs
**/*.log
**/logs/
**/log/

# Monitoring-Daten
**/data/prometheus/
**/data/grafana/
**/data/influxdb/

# === ERLAUBTE DATEIEN ===

# Diese Dateien sind explizit erlaubt trotz obiger Regeln
!**/README.md
!**/LICENSE
!**/Dockerfile*
!**/docker-compose*.yml
!**/*.example
!**/*.template
!**/*.sample
```

## Workflow-Beispiele

### Ersteinrichtung mit Git

```bash title="Repository erstellen und klonen"
# 1. Repository erstellen (GitHub/GitLab/Gitea)
# 2. Lokal klonen
git clone git@github.com:username/homelab-infrastructure.git /opt/homelab
cd /opt/homelab

# 3. Basis-Struktur erstellen
mkdir -p {services/{dns-stack,traefik,homeassistant,monitoring},scripts,docs}

# 4. .gitignore erstellen (siehe oben)
# 5. Initiales Template-System
./scripts/init-environment.sh

# 6. Templates committen (OHNE echte Secrets)
git add .
git commit -m "Initial homelab infrastructure setup"
git push origin main
```

### Täglicher Entwicklungsworkflow

```bash title="Sichere Änderungen an Services"
# Änderungen an Service-Konfiguration
cd /opt/homelab
nano services/homeassistant/docker-compose.yml

# Neuen Service hinzufügen
mkdir services/new-service
cp services/template/* services/new-service/
nano services/new-service/.env.example

# Status prüfen (Secrets werden automatisch ignoriert)
git status
# Sollte zeigen:
# Modified: services/homeassistant/docker-compose.yml  
# New: services/new-service/
# NICHT zeigen: *.env Dateien mit echten Secrets

# Nur Templates und Configs committen
git add services/
git commit -m "Add new service and update Home Assistant config"
git push
```

### Multi-Umgebung Workflow

```bash title="Development/Production Branches"
# Development Branch für Tests
git checkout -b development

# Experimentelle Änderungen
nano services/homeassistant/docker-compose.yml
# Neue Features testen auf Dev-Hardware

# Bei Erfolg in Production mergen
git checkout main
git merge development

# Deployment auf Produktiv-System
./scripts/deploy-stack.sh production
```

### Secrets-sicherer Workflow

```bash title="Secrets niemals in Git"
# FALSCH: Echte Credentials committen
echo "API_KEY=real-secret-key" > .env
git add .env  # ❌ NIEMALS!

# RICHTIG: Template erstellen  
echo "API_KEY=YOUR_API_KEY_HERE" > .env.example
git add .env.example  # ✅ Sicher

# RICHTIG: Lokale .env erstellen (automatisch ignoriert)
cp .env.example .env
nano .env  # Echte Werte eintragen
# .env wird automatisch von .gitignore ausgeschlossen
```

## Branch-Strategien

### GitFlow für Homelab

```bash title="Branch-Modell"
main                    # Produktive Infrastruktur
├── develop            # Integration neuer Features
├── feature/           # Feature-Entwicklung
│   ├── feature/traefik-v3
│   ├── feature/ha-automation
│   └── feature/monitoring-alerts
├── release/           # Release-Vorbereitung
│   └── release/v2.1.0
└── hotfix/           # Kritische Fixes
    └── hotfix/dns-security-fix
```

### Environment-spezifische Konfiguration

```bash title="Environment Branches (Alternative)"
main                    # Template und Dokumentation
├── production         # Produktive Konfiguration
├── staging           # Test-Umgebung
└── development       # Entwicklungs-Umgebung

# Jede Umgebung hat eigene .env.example mit umgebungsspezifischen Defaults
```

## Sicherheits-Best-Practices

### Pre-Commit Hooks

```bash title=".git/hooks/pre-commit"
#!/bin/bash

echo "🔍 Überprüfe Commit auf Secrets..."

# Liste kritischer Patterns
PATTERNS=(
    "password\s*=\s*['\"][^'\"]*['\"]"
    "secret\s*=\s*['\"][^'\"]*['\"]"  
    "api[_-]?key\s*=\s*['\"][^'\"]*['\"]"
    "token\s*=\s*['\"][^'\"]*['\"]"
    "-----BEGIN.*PRIVATE KEY-----"
    "NETCUP_API_KEY=(?!YOUR_API_KEY)[a-zA-Z0-9]+"
)

# Zu committende Dateien prüfen
STAGED_FILES=$(git diff --cached --name-only)

for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        for pattern in "${PATTERNS[@]}"; do
            if grep -qE "$pattern" "$file"; then
                echo "❌ POTENTIAL SECRET DETECTED in $file"
                echo "   Pattern: $pattern"
                echo ""
                echo "🚫 Commit abgebrochen!"
                echo "   Entferne Secrets oder verwende .env.example Templates"
                exit 1
            fi
        done
    fi
done

echo "✅ Keine Secrets gefunden. Commit erlaubt."
```

```bash title="Hook installieren"
# Pre-Commit Hook aktivieren
chmod +x .git/hooks/pre-commit

# Globalen Hook für alle Repositories setzen
git config --global init.templatedir ~/.git-templates
mkdir -p ~/.git-templates/hooks
cp .git/hooks/pre-commit ~/.git-templates/hooks/
```

### Git-Historie bereinigen

!!! warning "Historie-Manipulation"
    Das Bereinigen der Git-Historie kann Repositories beschädigen. Erstellen Sie immer ein Backup vor solchen Operationen.

```bash title="Secrets aus Historie entfernen"
# BFG Repo-Cleaner (empfohlen)
# Download von: https://rtyley.github.io/bfg-repo-cleaner/

# Secrets-Pattern-Datei erstellen
cat > secrets-patterns.txt << EOF
password=
api_key=
secret=
token=
NETCUP_API_KEY=
PIHOLE_PASSWORD=
EOF

# Repository bereinigen
bfg --replace-text secrets-patterns.txt --no-blob-protection .git

# Force-Push nach Bereinigung
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force-with-lease origin main

# Alternative: git filter-branch (komplexer)
git filter-branch --force --index-filter \
    'git rm --cached --ignore-unmatch path/to/secret/file' \
    --prune-empty --tag-name-filter cat -- --all
```

### Credential Scanning

```bash title="Automated Secret Detection"
# truffleHog installieren
pip install truffleHog

# Repository scannen
trufflehog --regex --entropy=False /opt/homelab

# GitLeaks verwenden
curl -sSfL https://raw.githubusercontent.com/zricethezav/gitleaks/master/scripts/install.sh | sh -s -- -b /usr/local/bin
gitleaks detect --source /opt/homelab --verbose
```

## Recovery-Szenarien

### Git-Repository wiederherstellen

```bash title="Repository-Recovery"
# Szenario: Lokales Repository beschädigt

# 1. Frische Kopie klonen
cd /tmp
git clone git@github.com:username/homelab-infrastructure.git homelab-recovery

# 2. Lokale Änderungen sichern (falls vorhanden)
cd /opt/homelab
cp -r services/*/. /tmp/local-services-backup/

# 3. Repository ersetzen
cd /opt
mv homelab homelab-broken
mv /tmp/homelab-recovery homelab

# 4. Environment-Setup
cd homelab
./scripts/init-environment.sh

# 5. Secrets aus Backup wiederherstellen
gpg -d /path/to/secrets-backup.tar.gz.gpg | tar -xz -C /
```

### Branch-Recovery

```bash title="Branch wiederherstellen"
# Gelöschten Branch wiederherstellen
git reflog  # Commit-Hash des gelöschten Branches finden
git checkout -b recovered-branch <commit-hash>

# Force-Push rückgängig machen
git reflog origin/main  # Vorherigen Zustand finden
git reset --hard <previous-commit>
git push --force-with-lease origin main
```

## CI/CD Integration

### GitHub Actions Workflow

```yaml title=".github/workflows/security-check.yml"
name: Security Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
      with:
        fetch-depth: 0
    
    - name: Run GitLeaks
      uses: zricethezav/gitleaks-action@v2
      with:
        config-path: .gitleaks.toml
    
    - name: Check for .env files
      run: |
        if find . -name ".env" -not -path "./.env.example" | grep -q .; then
          echo "❌ .env files found in repository!"
          find . -name ".env" -not -path "./.env.example"
          exit 1
        fi
        echo "✅ No .env files found"
    
    - name: Validate Docker Compose
      run: |
        for compose in $(find . -name "docker-compose.yml"); do
          docker-compose -f "$compose" config > /dev/null
        done
```

### Pre-Push Validation

```bash title=".git/hooks/pre-push"
#!/bin/bash

echo "🚀 Pre-Push Validation..."

# Docker Compose Syntax prüfen
for compose_file in $(find . -name "docker-compose.yml"); do
    echo "Validiere $compose_file..."
    if ! docker-compose -f "$compose_file" config > /dev/null 2>&1; then
        echo "❌ Docker Compose Syntax Error in $compose_file"
        exit 1
    fi
done

# Secret-Scan
if command -v gitleaks &> /dev/null; then
    gitleaks detect --source . --quiet
    if [ $? -ne 0 ]; then
        echo "❌ Secrets gefunden! Push abgebrochen."
        exit 1
    fi
fi

echo "✅ Pre-Push Validation erfolgreich"
```

---

## Aufwandsschätzung

| Aufgabe | Zeitaufwand | Häufigkeit |
|---------|-------------|------------|
| **Git-Repository Setup** | 2-3 Stunden | Einmalig |
| **Pre-Commit Hooks** | 1 Stunde | Einmalig |
| **CI/CD Pipeline** | 3-4 Stunden | Einmalig |
| **Branch-Strategie definieren** | 1 Stunde | Einmalig |
| **Secret-Scanning Setup** | 2 Stunden | Einmalig |
| **Täglicher Git-Workflow** | 10 Minuten | Täglich |
| **Repository-Wartung** | 30 Minuten | Monatlich |
| **Sicherheits-Audit** | 2 Stunden | Quartalsweise |

**Gesamtaufwand Ersteinrichtung**: ~10 Stunden  
**Laufender Aufwand**: ~1 Stunde/Monat
