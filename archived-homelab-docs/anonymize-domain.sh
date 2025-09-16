#!/bin/bash

# =============================================================================
# Domain Anonymizer Script für Homelab-Dokumentation
# Ersetzt enzmann.online durch ein anonymes Synonym für Präsentationen
# =============================================================================

set -e  # Exit bei Fehlern

# Konfiguration
ORIGINAL_DOMAIN="enzmann.online"
ANONYMOUS_DOMAIN="homelab.example"
PROJECT_DIR="$(pwd)"
BACKUP_BRANCH="backup-original-domain"

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging-Funktion
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Hilfe anzeigen
show_help() {
    cat << EOF
Usage: $0 [OPTION] [CUSTOM_DOMAIN]

Domain-Anonymisierungs-Script für Homelab-Dokumentation

OPTIONS:
    anonymize          Ersetzt $ORIGINAL_DOMAIN durch $ANONYMOUS_DOMAIN
    restore           Stellt originale Domain wieder her
    preview           Zeigt Vorschau der Änderungen ohne Ausführung
    help              Zeigt diese Hilfe an

CUSTOM_DOMAIN:
    Optionale benutzerdefinierte Domain (Standard: $ANONYMOUS_DOMAIN)

EXAMPLES:
    $0 anonymize                    # Standard-Anonymisierung
    $0 anonymize mycompany.local    # Benutzerdefinierte Domain
    $0 preview                      # Vorschau der Änderungen
    $0 restore                      # Originale Domain wiederherstellen

SAFETY:
    - Erstellt automatisch Git-Backup-Branch
    - Zeigt Anzahl der Änderungen vor Ausführung
    - Unterstützt Rückgängigmachung
EOF
}

# Git-Status prüfen
check_git_status() {
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        error "Nicht in einem Git-Repository. Bitte aus dem Projekt-Verzeichnis ausführen."
        exit 1
    fi
    
    if [[ -n $(git status --porcelain) ]]; then
        warning "Uncommitted changes gefunden. Empfehlung: Erst committen."
        read -p "Trotzdem fortfahren? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "Abgebrochen. Bitte committen Sie Ihre Änderungen zuerst."
            exit 1
        fi
    fi
}

# Backup erstellen
create_backup() {
    log "Erstelle Backup-Branch: $BACKUP_BRANCH"
    
    # Prüfen ob Branch bereits existiert
    if git show-ref --quiet refs/heads/$BACKUP_BRANCH; then
        warning "Backup-Branch '$BACKUP_BRANCH' existiert bereits."
        read -p "Überschreiben? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git branch -D $BACKUP_BRANCH
        else
            log "Verwende existierenden Backup-Branch."
            return 0
        fi
    fi
    
    git checkout -b $BACKUP_BRANCH
    git checkout -
    success "Backup erstellt: $BACKUP_BRANCH"
}

# Dateien finden die geändert werden
find_target_files() {
    # Alle relevanten Dateien finden (außer .git, site/, venv/)
    find "$PROJECT_DIR" \
        -type f \
        \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" -o -name "*.txt" -o -name "*.sh" \) \
        -not -path "*/.git/*" \
        -not -path "*/site/*" \
        -not -path "*/venv/*" \
        -not -path "*/__pycache__/*"
}

# Vorschau der Änderungen
preview_changes() {
    local from_domain="$1"
    local to_domain="$2"
    
    log "Vorschau: Ersetze '$from_domain' durch '$to_domain'"
    echo
    
    local total_matches=0
    local files_with_matches=0
    
    while IFS= read -r file; do
        local matches=$(grep -c "$from_domain" "$file" 2>/dev/null || true)
        if [[ $matches -gt 0 ]]; then
            echo "📄 $file: $matches Vorkommen"
            # Erste 3 Matches anzeigen
            grep -n "$from_domain" "$file" | head -3 | sed 's/^/   /'
            if [[ $matches -gt 3 ]]; then
                echo "   ... und $((matches - 3)) weitere"
            fi
            echo
            ((files_with_matches++))
            ((total_matches += matches))
        fi
    done < <(find_target_files)
    
    success "Gefunden: $total_matches Vorkommen in $files_with_matches Dateien"
}

# Domain ersetzen
replace_domain() {
    local from_domain="$1"
    local to_domain="$2"
    local files_changed=0
    local total_replacements=0
    
    log "Ersetze '$from_domain' durch '$to_domain'..."
    
    while IFS= read -r file; do
        # Prüfen ob Datei die Domain enthält
        if grep -q "$from_domain" "$file" 2>/dev/null; then
            local before_count=$(grep -c "$from_domain" "$file" 2>/dev/null || true)
            
            # Backup der Datei (temporär)
            cp "$file" "$file.backup"
            
            # Domain ersetzen
            sed -i "s/$from_domain/$to_domain/g" "$file"
            
            local after_count=$(grep -c "$from_domain" "$file" 2>/dev/null || true)
            local replaced=$((before_count - after_count))
            
            if [[ $replaced -gt 0 ]]; then
                echo "✅ $file: $replaced Ersetzungen"
                ((files_changed++))
                ((total_replacements += replaced))
            fi
            
            # Temporäres Backup entfernen
            rm "$file.backup"
        fi
    done < <(find_target_files)
    
    success "Abgeschlossen: $total_replacements Ersetzungen in $files_changed Dateien"
}

# Domain anonymisieren
anonymize() {
    local target_domain="${1:-$ANONYMOUS_DOMAIN}"
    
    log "=== DOMAIN ANONYMISIERUNG ==="
    log "Von: $ORIGINAL_DOMAIN"
    log "Nach: $target_domain"
    echo
    
    check_git_status
    
    # Vorschau anzeigen
    preview_changes "$ORIGINAL_DOMAIN" "$target_domain"
    echo
    
    # Bestätigung einholen
    read -p "Anonymisierung durchführen? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Abgebrochen."
        exit 0
    fi
    
    # Backup erstellen
    create_backup
    
    # Ersetzen
    replace_domain "$ORIGINAL_DOMAIN" "$target_domain"
    
    # Git Status
    echo
    log "Git Status nach Änderungen:"
    git status --short
    
    echo
    success "Anonymisierung abgeschlossen!"
    log "💡 Tipp: Committen Sie die Änderungen für Präsentation"
    log "💡 Wiederherstellung mit: $0 restore"
}

# Originale Domain wiederherstellen
restore() {
    log "=== DOMAIN WIEDERHERSTELLUNG ==="
    
    check_git_status
    
    # Prüfen ob Backup-Branch existiert
    if ! git show-ref --quiet refs/heads/$BACKUP_BRANCH; then
        error "Backup-Branch '$BACKUP_BRANCH' nicht gefunden."
        log "Mögliche Alternativen:"
        log "1. Manuell: git checkout $BACKUP_BRANCH"
        log "2. Git Reset: git reset --hard HEAD~1"
        exit 1
    fi
    
    log "Backup-Branch gefunden: $BACKUP_BRANCH"
    
    # Vorschau der Wiederherstellung
    log "Aktuelle anonyme Domain wird durch $ORIGINAL_DOMAIN ersetzt."
    echo
    
    read -p "Wiederherstellung durchführen? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Abgebrochen."
        exit 0
    fi
    
    # Dateien vom Backup-Branch wiederherstellen
    log "Stelle Dateien vom Backup-Branch wieder her..."
    
    # Relevante Dateien vom Backup-Branch checkout
    git checkout "$BACKUP_BRANCH" -- docs/ mkdocs.yml README.md 2>/dev/null || true
    
    success "Wiederherstellung abgeschlossen!"
    log "Originale Domain ($ORIGINAL_DOMAIN) wiederhergestellt."
    
    echo
    log "Git Status:"
    git status --short
}

# Hauptfunktion
main() {
    case "${1:-help}" in
        "anonymize")
            anonymize "$2"
            ;;
        "restore")
            restore
            ;;
        "preview")
            preview_changes "$ORIGINAL_DOMAIN" "${2:-$ANONYMOUS_DOMAIN}"
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            error "Unbekannte Option: $1"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Script ausführen
main "$@"
