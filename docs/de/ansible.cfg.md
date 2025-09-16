Erläuterung der wichtigsten Einstellungen:
[defaults]:

inventory = inventory/hosts.yml: Verweist auf die zentrale Inventar-Datei innerhalb des inventory/-Ordners.

roles_path = roles/: Stellt sicher, dass Rollen aus dem roles/-Ordner geladen werden.

gathering = smart: Optimiert das Sammeln von Host-Fakten basierend auf der Situation.

stdout_callback = yaml: Ermöglicht eine übersichtliche Ausgabe im YAML-Format.

retry_files_enabled = True: Erstellt Wiederholungsdateien bei fehlerhaften Playbook-Ausführungen.

[privilege_escalation]: Ermöglicht das Ausführen von Befehlen mit sudo, ohne eine Passworteingabe (become_ask_pass = False).

[ssh_connection]:

Effiziente SSH-Verbindungen durch ControlPersist, um den Overhead bei wiederholtem Aufbau von Verbindungen zu reduzieren.

pipelining = True minimiert die Anzahl der SSH-Operationen und erhöht die Geschwindigkeit.

Cache und Fakten:

fact_caching = jsonfile: Speichert gesammelte Fakten im JSON-Format, sodass sie schneller abgerufen werden können.

fact_caching_connection = .cache/: Speichert die Daten im .cache-Ordner des Projekts.
