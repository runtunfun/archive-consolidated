# Projektwissen-Archiv

## Zweck

Archivierung aller Planungsdokumente, Designentscheidungen und Chat-Artefakte aus der Projektentwicklung.

## Struktur

- **01_xx_titel.md**: Hauptdokumente in chronologischer Reihenfolge
- **planning-sessions/**: Artefakte aus Claude-Chats mit Datum
- **decisions/**: Architecture Decision Records (ADRs)

## Arbeitsweise

```bash
# Chat-Artefakt archivieren
cp "Chat-Output.md" planning-sessions/$(date +%Y-%m-%d)_thema.md

# Designentscheidung dokumentieren  
cp "Architektur-Entscheidung.md" decisions/architecture_decision_vpn.md
```
