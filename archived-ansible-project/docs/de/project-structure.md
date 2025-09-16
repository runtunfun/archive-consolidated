# **Dokumentation und CI/CD-Workflow für Ansible-Projekte**

Dieses Dokument beschreibt den Ansatz, wie ein Ansible-Projekt mit einer strukturierten Dokumentation und einem konsistenten CI/CD-Workflow aufgebaut wird. Es richtet sich sowohl an aktuelle als auch künftige Teilnehmer, um eine einheitliche Arbeitsweise zu gewährleisten.

---

## **1. Zielsetzung**

- Sicherstellen, dass die Rollen, Playbooks und Variablen eines Ansible-Projekts konsistent bleiben und klar dokumentiert sind.
- Einen konsistenten Workflow für die Erstellung, Pflege und Bereitstellung der Dokumentation etablieren.

---

## **2. Struktur eines Ansible-Projekts**

Ein Beispiel für eine optimale Projektstruktur:

```plaintext
ansible-project/
├── ansible.cfg               # Zentrale Ansible-Konfiguration
├── inventory/
│   ├── hosts.yml             # Host-Inventar
│   ├── group_vars/           # Variablen für Gruppen
│   ├── host_vars/            # Variablen für spezifische Hosts
├── playbooks/
│   ├── playbook_webserver.yml  # Playbook für Webserver-Rolle
│   ├── playbook_database.yml   # Playbook für Datenbank-Rolle
├── roles/
│   ├── role_webserver/
│   │   ├── tasks/
│   │   ├── templates/
│   │   ├── vars/
│   ├── role_database/
│       ├── tasks/
│       ├── templates/
│       ├── vars/
├── docs/                     # Zentrale Dokumentation
│   ├── index.md              # Übersicht der Dokumentation
│   ├── playbooks/
│   │   ├── playbook_webserver.md
│   │   ├── playbook_database.md
│   ├── roles/
│       ├── role_webserver.md
│       ├── role_database.md
├── mkdocs.yml                # Konfigurationsdatei für MkDocs
├── setup.sh                  # Lokale Entwicklungsumgebung
├── Dockerfile                # Entwicklungsumgebung als Container
```

---

## **3. Namenskonventionen für Konsistenz**

Um sicherzustellen, dass Rollen, Playbooks und Variablen konsistent bleiben:
- **Rollen:** `role_<name>`
- **Playbooks:** `playbook_<name>.yml`
- **Variablen:** `vars_<name>.yml` (für Gruppen) und `vars_<hostname>.yml` (für Hosts)

Beispiele:
- **Rolle:** `role_webserver` → **Playbook:** `playbook_webserver.yml` → **Variablen:** `vars_webserver.yml`
- **Rolle:** `role_database` → **Playbook:** `playbook_database.yml` → **Variablen:** `vars_database.yml`

---

## **4. Automatische Dokumentation**

Ein Bash-Skript generiert automatisch die `index.md`, basierend auf den Namenskonventionen:

```bash
#!/bin/bash
OUTPUT_FILE="docs/index.md"

# Header
echo "# Projektübersicht" > $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Rollen
echo "## Rollen" >> $OUTPUT_FILE
for role in roles/role_*; do
  echo "- [$(basename $role)]($role/)" >> $OUTPUT_FILE
done
echo "" >> $OUTPUT_FILE

# Playbooks
echo "## Playbooks" >> $OUTPUT_FILE
for playbook in playbooks/playbook_*.yml; do
  echo "- [$(basename $playbook .yml)]($playbook)" >> $OUTPUT_FILE
done
echo "" >> $OUTPUT_FILE

# Variablen
echo "## Variablen" >> $OUTPUT_FILE
for vars in group_vars/vars_*.yml; do
  echo "- $(basename $vars .yml)" >> $OUTPUT_FILE
done

echo "Die Übersicht wurde erfolgreich erstellt."
```

---

## **5. CI/CD-Workflow für MkDocs**

Die folgende Pipeline beschreibt, wie MkDocs automatisch eine statische Webseite erstellt und bereitstellt.

### **5.1 Lokale Umgebung**

#### **Dockerfile**
```dockerfile
FROM python:3.9
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
CMD ["mkdocs", "serve", "-a", "0.0.0.0:8000"]
```

#### **requirements.txt**
```plaintext
mkdocs==1.4.2
mkdocs-material==8.5.9
mkdocs-mermaid2-plugin==0.6.0
```

#### **setup.sh**
```bash
#!/bin/bash
if ! [ -x "$(command -v docker)" ]; then
  echo "Docker ist nicht installiert."
  exit 1
fi
IMAGE_NAME="mkdocs-env"
if ! docker image inspect $IMAGE_NAME > /dev/null 2>&1; then
  docker build -t $IMAGE_NAME .
fi
docker run --rm -it -p 8000:8000 -v $(pwd):/app $IMAGE_NAME
```

Entwickler starten das Setup mit:
```bash
bash setup.sh
```

### **5.2 CI/CD-Pipeline**

### **Details zu `.gitlab-ci.yml`**

- **Name der Datei:** `.gitlab-ci.yml`
  - GitLab erkennt diese Datei automatisch, wenn sie im Root-Verzeichnis des Repositorys liegt.

- **Ort der Datei:** Das **Root-Verzeichnis** deines Projekts:
  ```plaintext
  ansible-project/
  ├── ansible.cfg
  ├── Dockerfile
  ├── .env
  ├── generate_ansible_role.sh
  ├── LICENSE
  ├── mkdocs.yml
  ├── project-structure.md
  ├── projekt-struktur.md
  ├── README.md
  ├── requirements.txt
  ├── setup.sh
  ├── docs
  │   ├── de
  │   │   ├── index.md
  │   │   ├── playbooks
  │   │   └── roles
  │   └── en
  │       ├── index.md
  │       ├── playbooks
  │       └── roles
  ├── inventory
  │   ├── hosts.yml
  │   ├── group_vars
  │   └── host_vars
  ├── playbooks
  └── roles
  ```

- **Funktion der Datei:** Diese Datei definiert die CI/CD-Jobs, die GitLab ausführt, sobald ein Push ins Repository oder eine bestimmte Bedingung (z. B. Merge-Request) erfolgt. 

---

### **Typischer Ablauf der Pipeline**

1. **Speicherung in `.gitlab-ci.yml`:**
   Du platzierst die Datei im Root-Verzeichnis deines Projekts mit folgendem Beispielinhalt:
    GitLab sucht standardmäßig im Root-Verzeichnis des Repositorys nach der Datei `.gitlab-ci.yml`. Eine andere Platzierung erfordert spezielle Konfigurationen, die unnötig kompliziert sind.
   ```yaml
   image: mkdocs-env

   stages:
     - build
     - deploy

   build:
     stage: build
     script:
       - mkdocs build
     artifacts:
       paths:
         - site

   deploy:
     stage: deploy
     script:
       - apt-get update && apt-get install -y lftp
       - lftp -c "open -u $FTP_USER,$FTP_PASS $FTP_HOST; mirror -R site/ /target-directory/"
     only:
       - main
   ```

2. **Speicherung im Repository:**
   Sobald du die Datei `.gitlab-ci.yml` im Root-Verzeichnis deines Repositorys committed hast, wird GitLab automatisch die Pipeline erkennen und starten.

3. **CI/CD-Verlauf in GitLab:**
   Du kannst den Status der Jobs in der GitLab-UI unter **CI/CD > Pipelines** einsehen.


---

## **6. Erweiterung um Mermaid**

Mermaid wird mit dem `mkdocs-mermaid2-plugin` integriert, um Diagramme in der Dokumentation zu ermöglichen:

### **Konfiguration in der `mkdocs.yml`**
```yaml
plugins:
  - search
  - mermaid2:
      arguments:
        theme: default
extra_javascript:
  - https://cdnjs.cloudflare.com/ajax/libs/mermaid/10.4.0/mermaid.min.js
```

### **Beispiel für Mermaid**
```
mermaid
   graph TD
    A[Start] --> B{Entscheidung}
    B -->|Ja| C[Weiter]
    B -->|Nein| D[Ende]   
```
## **7. Fazit**

Dieses Dokument bietet:
1. **Struktur für Ansible-Projekte:** Einheitliche Organisation von Code und Dokumentation.
2. **Konsistenz durch Namenskonventionen:** Verbindung zwischen Rollen, Playbooks und Variablen.
3. **Automatisierung:** Generierung der Übersicht und Bereitstellung der Dokumentation über CI/CD.
4. **Visualisierung:** Diagramme mit Mermaid.

Künftige Teilnehmer können die klare Struktur und Automatisierung nutzen, um effektiv zusammenzuarbeiten und die Dokumentation aktuell zu halten.

