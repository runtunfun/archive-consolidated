# **Documentation and CI/CD Workflow for Ansible Projects**

This document describes the approach to building an Ansible project with structured documentation and a consistent CI/CD workflow. It is intended for current and future participants to ensure a unified way of working.

---

## **1. Objectives**

- Ensure roles, playbooks, and variables of an Ansible project remain consistent and clearly documented.
- Establish a consistent workflow for creating, maintaining, and providing documentation.

---

## **2. Structure of an Ansible Project**

An example of an optimal project structure:

```plaintext
ansible-project/
├── ansible.cfg               # Central Ansible configuration
├── inventory/
│   ├── hosts.yml             # Host inventory
│   ├── group_vars/           # Variables for groups
│   ├── host_vars/            # Variables for specific hosts
├── playbooks/
│   ├── playbook_webserver.yml  # Playbook for the web server role
│   ├── playbook_database.yml   # Playbook for the database role
├── roles/
│   ├── role_webserver/
│   │   ├── tasks/
│   │   ├── templates/
│   │   ├── vars/
│   ├── role_database/
│       ├── tasks/
│       ├── templates/
│       ├── vars/
├── docs/                     # Central documentation
│   ├── index.md              # Documentation overview
│   ├── playbooks/
│   │   ├── playbook_webserver.md
│   │   ├── playbook_database.md
│   ├── roles/
│       ├── role_webserver.md
│       ├── role_database.md
├── mkdocs.yml                # Configuration file for MkDocs
├── setup.sh                  # Local development environment
├── Dockerfile                # Development environment as a container
```

---

## **3. Naming Conventions for Consistency**

To ensure roles, playbooks, and variables remain consistent:
- **Roles:** `role_<name>`
- **Playbooks:** `playbook_<name>.yml`
- **Variables:** `vars_<name>.yml` (for groups) and `vars_<hostname>.yml` (for hosts)

Examples:
- **Role:** `role_webserver` → **Playbook:** `playbook_webserver.yml` → **Variables:** `vars_webserver.yml`
- **Role:** `role_database` → **Playbook:** `playbook_database.yml` → **Variables:** `vars_database.yml`

---

## **4. Automated Documentation**

A Bash script automatically generates the `index.md` based on naming conventions:

```bash
#!/bin/bash
OUTPUT_FILE="docs/index.md"

# Header
echo "# Project Overview" > $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Roles
echo "## Roles" >> $OUTPUT_FILE
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

# Variables
echo "## Variables" >> $OUTPUT_FILE
for vars in group_vars/vars_*.yml; do
  echo "- $(basename $vars .yml)" >> $OUTPUT_FILE
done

echo "The overview has been successfully generated."
```

---

## **5. CI/CD Workflow for MkDocs**

The following pipeline describes how MkDocs automatically creates and deploys a static website.

### **5.1 Local Environment**

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
  echo "Docker is not installed."
  exit 1
fi
IMAGE_NAME="mkdocs-env"
if ! docker image inspect $IMAGE_NAME > /dev/null 2>&1; then
  docker build -t $IMAGE_NAME .
fi
docker run --rm -it -p 8000:8000 -v $(pwd):/app $IMAGE_NAME
```

Developers start the setup with:
```bash
bash setup.sh
```

### **5.2 CI/CD Pipeline**

### **Details of `.gitlab-ci.yml`**

- **Filename:** `.gitlab-ci.yml`
  - GitLab automatically detects this file when placed in the root directory of the repository.

- **Location of File:** The **root directory** of your project:
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

- **Function of the File:** Defines the CI/CD jobs GitLab executes whenever a push to the repository or a specific condition (e.g., merge request) occurs.

---

### **Typical Pipeline Workflow**

1. **Saving in `.gitlab-ci.yml`:**
   Place the file in the root directory of your project with the following example content:
   GitLab defaults to searching for `.gitlab-ci.yml` in the repository's root directory. Any other placement requires special configurations, which are unnecessarily complex.
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

2. **Storing in the Repository:**
   Once the `.gitlab-ci.yml` file is committed to the root directory of your repository, GitLab will automatically detect and start the pipeline.

3. **CI/CD Progress in GitLab:**
   View the status of jobs in the GitLab UI under **CI/CD > Pipelines**.

---

## **6. Expanding with Mermaid**

Mermaid is integrated with the `mkdocs-mermaid2-plugin` to enable diagrams in the documentation:

### **Configuration in `mkdocs.yml`**
```yaml
plugins:
  - search
  - mermaid2:
      arguments:
        theme: default
extra_javascript:
  - https://cdnjs.cloudflare.com/ajax/libs/mermaid/10.4.0/mermaid.min.js
```

### **Example for Mermaid**
```
mermaid
   graph TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Continue]
    B -->|No| D[End]   
```
---

## **7. Conclusion**

This document offers:
1. **Structure for Ansible projects:** Unified organization of code and documentation.
2. **Consistency through naming conventions:** Connection between roles, playbooks, and variables.
3. **Automation:** Generating the overview and providing documentation via CI/CD.
4. **Visualization:** Diagrams with Mermaid.

Future participants can leverage this clear structure and automation to collaborate effectively and keep documentation up-to-date.

---
