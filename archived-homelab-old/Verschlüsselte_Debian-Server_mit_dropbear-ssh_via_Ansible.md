# Verschlüsselte Debian-Server mit dropbear-ssh via Ansible

## Übersicht

Diese Anleitung beschreibt die Einrichtung von 3 verschlüsselten Debian-Servern für eine zukünftige VPN-Lösung (pangolin/headscale) mit automatisierter Remote-Entschlüsselung über dropbear-ssh.

**Zielsetzung:**
- Remote-Entschlüsselung von LUKS-verschlüsselten Servern während des Boot-Prozesses
- Automatisierte Konfiguration via Ansible
- Vorbereitung für VPN-Infrastruktur
- Minimaler, wartbarer Ansatz

## Umgebung

| System | IP-Adresse | Rolle | Besonderheiten |
|--------|------------|-------|----------------|
| debian-admin | 192.168.1.245 | Ansible Controller | SSH-Schlüssel, Ansible |
| debian-01 | 192.168.1.246 | Target Server | LUKS-verschlüsselt |
| debian-02 | 192.168.1.247 | Target Server | LUKS-verschlüsselt |
| debian-03 | 192.168.1.248 | Target Server | LUKS-verschlüsselt |

**Benutzer:** `stefan` (kann sudo mit Passwort ausführen)

## Voraussetzungen

### Auf allen Servern
- ✅ Debian-Installation mit LVM-Verschlüsselung aktiviert
- ✅ SSH-Server läuft
- ✅ Benutzer `stefan` existiert
- ✅ Netzwerk-Konnektivität zwischen Servern

### Auf debian-admin
- ✅ Debian/Ubuntu-System
- ✅ Internet-Zugang für Paket-Installation

## Bekannte Probleme bei frischen Debian-Installationen

**Problem:** Auf minimalen Debian-Installationen ist oft:
- `sudo` nicht installiert
- Benutzer nicht in der `sudo`-Gruppe
- Nur `root` kann Administrative Aufgaben ausführen

**Lösung:** Unsere Ansible-Playbooks berücksichtigen diese Situation automatisch.

## 1. Vorbereitung debian-admin (Root-Setup)

### Problem bei frischen Debian-Installationen
Bei einer minimalen Debian-Installation ist häufig:
- `sudo` nicht installiert
- Benutzer `stefan` nicht in der `sudo`-Gruppe
- Nur `root` kann administrative Aufgaben ausführen

### Lösung: Manuelle Konfiguration als root

**Schritt 1: Als root einloggen**
```bash
# Via SSH (falls root-SSH erlaubt ist)
ssh root@192.168.1.245

# Oder lokal/Console
su -
# Root-Passwort eingeben
```

**Schritt 2: sudo installieren und konfigurieren**
```bash
# System aktualisieren
apt update && apt upgrade -y

# sudo und weitere Tools installieren
apt install sudo ansible sshpass git curl wget vim -y

# stefan zur sudo-Gruppe hinzufügen
usermod -aG sudo stefan

# Gruppenmitgliedschaft prüfen
groups stefan
# Sollte: stefan : stefan sudo

# sudo-Gruppe in sudoers aktivieren (normalerweise bereits aktiv)
grep "^%sudo" /etc/sudoers
# Sollte zeigen: %sudo   ALL=(ALL:ALL) ALL

# Optional: Passwortloses sudo für stefan einrichten (für Ansible-Komfort)
tee /etc/sudoers.d/stefan << 'EOF'
stefan ALL=(ALL) NOPASSWD:ALL
EOF
chmod 440 /etc/sudoers.d/stefan
```

**Schritt 3: SSH-Konfiguration optimieren (optional)**
```bash
# SSH-Konfiguration für bessere Sicherheit
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

cat >> /etc/ssh/sshd_config << 'EOF'

# Optimierungen für Admin-System
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
UseDNS no
EOF

# SSH neu starten
systemctl restart ssh
```

**Schritt 4: Als stefan testen**
```bash
# Neue SSH-Session als stefan
exit  # Root-Session beenden

# Als stefan einloggen
ssh stefan@192.168.1.245

# sudo testen
sudo whoami
# Sollte "root" ausgeben nach Passwort-Eingabe
```

## 2. Vorbereitung debian-admin (Als stefan)

### Projektverzeichnis erstellen
```bash
# Jetzt als stefan mit sudo-Rechten
mkdir ~/ansible-dropbear
cd ~/ansible-dropbear
```

### Paket-Status prüfen
```bash
# Prüfen ob alle Tools verfügbar sind
which ansible
which git
which ssh-keygen

# Falls etwas fehlt:
sudo apt install ansible sshpass git -y
```

### SSH-Verbindung zu allen Servern testen
```bash
# Test der Grundverbindung (einmalig mit Passwort)
ssh stefan@192.168.1.246
ssh stefan@192.168.1.247  
ssh stefan@192.168.1.248
# Mit exit wieder ausloggen
```

## 3. Ansible-Konfiguration

### Inventory erstellen
```bash
cat > inventory.ini << 'EOF'
[debian_servers]
debian-01 ansible_host=192.168.1.246
debian-02 ansible_host=192.168.1.247  
debian-03 ansible_host=192.168.1.248

[test_server]
debian-01 ansible_host=192.168.1.246

[remaining_servers]
debian-02 ansible_host=192.168.1.247
debian-03 ansible_host=192.168.1.248

[debian_servers:vars]
ansible_user=stefan
ansible_become=yes
ansible_become_method=sudo
EOF
```

### Ansible-Konfiguration
```bash
cat > ansible.cfg << 'EOF'
[defaults]
inventory = inventory.ini
host_key_checking = False
retry_files_enabled = False
stdout_callback = yaml

[privilege_escalation]
become = True
become_method = sudo
become_ask_pass = False

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null
pipelining = True
EOF
```

## 4. Ansible-Playbooks

### Setup-Validierung (Optional)
```bash
cat > 00-validate-setup.yml << 'EOF'
---
- name: Setup-Validierung vor Ausführung
  hosts: localhost
  gather_facts: yes
  
  tasks:
    - name: SSH-Verzeichnis prüfen
      file:
        path: "{{ ansible_env.HOME }}/.ssh"
        state: directory
        mode: '0700'
    
    - name: SSH-Schlüssel-Typ prüfen/anzeigen
      block:
        - name: Vorhandene SSH-Schlüssel auflisten
          find:
            paths: "{{ ansible_env.HOME }}/.ssh"
            patterns: "id_*"
            file_type: file
          register: existing_keys
        
        - name: Vorhandene Schlüssel anzeigen
          debug:
            msg: "Gefundene SSH-Schlüssel: {{ existing_keys.files | map(attribute='path') | list }}"
        
        - name: Empfehlung bei fehlenden Schlüsseln
          debug:
            msg: |
              HINWEIS: Es wurden keine SSH-Schlüssel gefunden.
              Das Playbook 01-ssh-setup.yml wird automatisch einen ed25519-Schlüssel erstellen.
              Alternativ können Sie manuell einen erstellen mit:
              ssh-keygen -t ed25519 -C "ansible@{{ ansible_hostname }}"
          when: existing_keys.files | length == 0
    
    - name: Netzwerk-Konnektivität zu Servern testen
      wait_for:
        host: "{{ item }}"
        port: 22
        timeout: 5
      loop:
        - 192.168.1.246
        - 192.168.1.247
        - 192.168.1.248
      ignore_errors: yes
      register: connectivity_test
    
    - name: Konnektivitäts-Ergebnis
      debug:
        msg: "Server {{ item.item }}: {{ 'erreichbar' if item is not failed else 'NICHT erreichbar' }}"
      loop: "{{ connectivity_test.results }}"
EOF
```

### SSH-Setup und sudo-Konfiguration
```bash
cat > 01-ssh-setup.yml << 'EOF'
---
- name: SSH-Setup und passwordless sudo
  hosts: debian_servers
  gather_facts: no
  become: no  # Wichtig: Erstmal ohne sudo starten
  
  pre_tasks:
    - name: SSH-Schlüssel auf Admin-System prüfen/erstellen
      block:
        - name: Prüfen ob SSH-Schlüssel vorhanden
          stat:
            path: "{{ lookup('env', 'HOME') }}/.ssh/id_ed25519"
          register: ssh_key_check
          delegate_to: localhost
          run_once: true
        
        - name: SSH-Schlüssel-Status anzeigen
          debug:
            msg: "SSH-Schlüssel {{ 'gefunden' if ssh_key_check.stat.exists else 'NICHT gefunden - wird erstellt' }}"
          delegate_to: localhost
          run_once: true
        
        - name: SSH-Schlüssel erstellen (falls nicht vorhanden)
          openssh_keypair:
            path: "{{ lookup('env', 'HOME') }}/.ssh/id_ed25519"
            type: ed25519
            comment: "ansible@{{ inventory_hostname }}"
            force: no
          delegate_to: localhost
          run_once: true
          when: not ssh_key_check.stat.exists
        
        - name: Öffentlichen Schlüssel anzeigen
          slurp:
            src: "{{ lookup('env', 'HOME') }}/.ssh/id_ed25519.pub"
          register: public_key_content
          delegate_to: localhost
          run_once: true
        
        - name: Öffentlicher SSH-Schlüssel
          debug:
            msg: "{{ public_key_content.content | b64decode | trim }}"
          delegate_to: localhost
          run_once: true
  
  tasks:
    # Grundlegende Facts sammeln (ohne sudo)
    - name: Basis-Systeminformationen sammeln
      setup:
        gather_subset: '!all,network,virtual,hardware'
    
    # Prüfen ob sudo vorhanden ist (ohne sudo)
    - name: Prüfen ob sudo installiert ist
      raw: which sudo
      register: sudo_check
      ignore_errors: yes
      changed_when: false
    
    - name: sudo-Status anzeigen
      debug:
        msg: "sudo {{ 'ist installiert' if sudo_check.rc == 0 else 'ist NICHT installiert - wird installiert' }}"
    
    # sudo installieren (mit verbesserter Fehlerbehandlung)
    - name: sudo-Status detailliert prüfen
      raw: dpkg -l sudo
      register: sudo_installed
      ignore_errors: yes
      failed_when: false

    - name: sudo installieren mit become_method su
      raw: apt update && apt install -y sudo
      become: yes
      become_method: su
      when: sudo_installed.rc != 0
      register: sudo_install_result
    
    # Ab hier mit sudo arbeiten
    - name: Facts vollständig sammeln (mit sudo)
      setup:
      become: yes
    
    - name: stefan zur sudo-Gruppe hinzufügen
      user:
        name: stefan
        groups: sudo
        append: yes
      become: yes
    
    - name: SSH-Schlüssel kopieren
      authorized_key:
        user: stefan
        state: present
        key: "{{ lookup('file', lookup('env', 'HOME') + '/.ssh/id_ed25519.pub') }}"
      become: yes
    
    - name: passwordless sudo für stefan
      lineinfile:
        path: /etc/sudoers.d/stefan
        line: 'stefan ALL=(ALL) NOPASSWD:ALL'
        create: yes
        mode: '0440'
        validate: '/usr/sbin/visudo -cf %s'
      become: yes
    
    - name: SSH-Konfiguration optimieren
      blockinfile:
        path: /etc/ssh/sshd_config
        block: |
          # Optimierungen für Ansible
          UseDNS no
          PermitRootLogin no
          PasswordAuthentication yes
          PubkeyAuthentication yes
        marker: "# {mark} ANSIBLE MANAGED BLOCK"
        backup: yes
      become: yes
      notify: restart ssh
  
  handlers:
    - name: restart ssh
      service:
        name: ssh
        state: restarted
      become: yes
EOF
```

### dropbear-ssh Installation (Minimale Version)
```bash
cat > 02-dropbear-minimal.yml << 'EOF'
---
- name: dropbear-ssh minimal Installation (TEST)
  hosts: test_server
  gather_facts: yes
  
  pre_tasks:
    - name: System-Info sammeln
      debug:
        msg: "Testing auf: {{ inventory_hostname }} ({{ ansible_default_ipv4.address }})"
    
    - name: Aktuelle initramfs sichern
      copy:
        src: "/boot/initrd.img-{{ ansible_kernel }}"
        dest: "/boot/initrd.img-{{ ansible_kernel }}.backup"
        remote_src: yes
        backup: yes
  
  tasks:
    - name: dropbear-initramfs installieren
      apt:
        name: dropbear-initramfs
        state: present
        update_cache: yes
    
    - name: SSH-Schlüssel für dropbear kopieren
      copy:
        src: ~/.ssh/id_ed25519.pub
        dest: /etc/dropbear/initramfs/authorized_keys
        mode: '0600'
        owner: root
        group: root
        backup: yes
    
    - name: Erweiterte dropbear-Konfiguration
      copy:
        content: |
          # dropbear-Konfiguration für Remote-Entschlüsselung
          DROPBEAR_OPTIONS="-p 22 -s -j -k"
        dest: /etc/dropbear/initramfs/dropbear.conf
        mode: '0644'
        backup: yes
    
    - name: Netzwerk-Interface ermitteln
      shell: ip route | grep default | awk '{print $5}' | head -1
      register: default_interface
      changed_when: false
    
    - name: Ermitteltes Interface anzeigen
      debug:
        msg: "Standard-Interface: {{ default_interface.stdout }}"
    
    - name: initramfs neu generieren
      shell: update-initramfs -u -v
      register: initramfs_result
      failed_when: initramfs_result.rc != 0
    
    - name: initramfs-Ergebnis prüfen
      debug:
        var: initramfs_result.stdout_lines
    
    - name: dropbear-Module in initramfs prüfen
      shell: lsinitramfs /boot/initrd.img-{{ ansible_kernel }} | grep -E "(dropbear|ssh)" || true
      register: dropbear_check
      changed_when: false
    
    - name: dropbear-Module anzeigen
      debug:
        var: dropbear_check.stdout_lines
EOF
```

### Validierung und System-Info
```bash
cat > 03-validate-dropbear.yml << 'EOF'
---
- name: dropbear-Installation validieren
  hosts: test_server
  gather_facts: yes
  
  tasks:
    - name: dropbear-Paket Status
      shell: dpkg -l dropbear-initramfs
      register: dropbear_package
      changed_when: false
    
    - name: Paket-Status anzeigen
      debug:
        var: dropbear_package.stdout_lines
    
    - name: dropbear-Konfiguration prüfen
      slurp:
        src: /etc/dropbear/initramfs/dropbear.conf
      register: dropbear_config
    
    - name: Konfiguration anzeigen
      debug:
        msg: "{{ dropbear_config.content | b64decode }}"
    
    - name: SSH-Keys prüfen
      stat:
        path: /etc/dropbear/initramfs/authorized_keys
      register: authorized_keys
    
    - name: SSH-Keys Status
      debug:
        msg: "authorized_keys vorhanden: {{ authorized_keys.stat.exists }}, Größe: {{ authorized_keys.stat.size | default('N/A') }}"
    
    - name: initramfs-Backup Status
      stat:
        path: "/boot/initrd.img-{{ ansible_kernel }}.backup"
      register: backup_status
    
    - name: Backup-Status anzeigen
      debug:
        msg: "Backup vorhanden: {{ backup_status.stat.exists }}"
    
    - name: Verschlüsselte Partitionen anzeigen
      shell: lsblk -f | grep crypt || echo "Keine verschlüsselten Partitionen gefunden"
      register: encrypted_partitions
      changed_when: false
    
    - name: Verschlüsselte Partitionen
      debug:
        var: encrypted_partitions.stdout_lines
EOF
```

### Rollout auf weitere Server (nach erfolgreichem Test)
```bash
cat > 02-dropbear-rollout.yml << 'EOF'
---
- name: dropbear-ssh Installation (Rollout)
  hosts: remaining_servers
  gather_facts: yes
  
  pre_tasks:
    - name: System-Info sammeln
      debug:
        msg: "Rollout auf: {{ inventory_hostname }} ({{ ansible_default_ipv4.address }})"
    
    - name: Aktuelle initramfs sichern
      copy:
        src: "/boot/initrd.img-{{ ansible_kernel }}"
        dest: "/boot/initrd.img-{{ ansible_kernel }}.backup"
        remote_src: yes
        backup: yes
  
  tasks:
    - name: dropbear-initramfs installieren
      apt:
        name: dropbear-initramfs
        state: present
        update_cache: yes
    
    - name: SSH-Schlüssel für dropbear kopieren
      copy:
        src: ~/.ssh/id_ed25519.pub
        dest: /etc/dropbear/initramfs/authorized_keys
        mode: '0600'
        owner: root
        group: root
        backup: yes
    
    - name: Erweiterte dropbear-Konfiguration
      copy:
        content: |
          # dropbear-Konfiguration für Remote-Entschlüsselung
          DROPBEAR_OPTIONS="-p 22 -s -j -k"
        dest: /etc/dropbear/initramfs/dropbear.conf
        mode: '0644'
        backup: yes
    
    - name: initramfs neu generieren
      shell: update-initramfs -u -v
      register: initramfs_result
      failed_when: initramfs_result.rc != 0
    
    - name: initramfs-Ergebnis prüfen
      debug:
        var: initramfs_result.stdout_lines
EOF
```

## 5. Ausführung

### Schritt 1: Setup validieren (optional)
```bash
cd ~/ansible-dropbear
# Validierung läuft nur lokal, daher kein --ask-pass nötig
# Aber --ask-become-pass für lokale sudo-Operationen (SSH-Verzeichnis erstellen)
ansible-playbook 00-validate-setup.yml --ask-become-pass
```

**Hinweis:** Die Validierung testet die Netzwerk-Konnektivität, aber baut noch keine SSH-Verbindungen auf. Daher ist `--ask-pass` hier nicht erforderlich.

### Schritt 2: SSH-Setup und sudo-Konfiguration
```bash
# Wichtig: BEIDE Parameter beim ersten Mal:
# --ask-pass = SSH-Passwort (da noch keine SSH-Keys installiert)
# --ask-become-pass = sudo-Passwort (da noch kein passwortloses sudo)
ansible-playbook 01-ssh-setup.yml --ask-pass --ask-become-pass
```

**Erwartete Abfragen:**
1. `SSH password:` - Das SSH-Passwort für stefan
2. `BECOME password:` - Das sudo-Passwort für stefan (meist identisch)

**Erwartete Ausgabe:**
- SSH-Schlüssel wird erstellt (falls nicht vorhanden)
- sudo wird installiert (auf Target-Servern)
- stefan wird zur sudo-Gruppe hinzugefügt
- SSH-Schlüssel wird auf alle Server kopiert
- Passwordless sudo wird aktiviert (auf allen Systemen)

### Schritt 3: Verbindung testen
```bash
# Sollte jetzt ohne Passwort funktionieren
ansible debian_servers -m ping
```

**Erwartete Ausgabe:**
```
debian-01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

### Schritt 4: dropbear auf Test-Server installieren
```bash
# NUR auf debian-01 testen
# Kein --ask-become-pass mehr nötig (passwortloses sudo ist jetzt konfiguriert)
ansible-playbook 02-dropbear-minimal.yml
```

### Schritt 5: Installation validieren
```bash
# Kein --ask-become-pass mehr nötig
ansible-playbook 03-validate-dropbear.yml
```

## 6. Test-Szenario

### Vorbereitung für Test
```bash
echo "ACHTUNG: Test-Reboot für debian-01!"
echo "Console-Zugriff bereithalten!"
read -p "Weiter? (y/N): " confirm

if [ "$confirm" = "y" ]; then
    ansible test_server -m reboot
fi
```

### Test 1: dropbear-SSH-Zugriff
1. **Warten (ca. 1-2 Minuten)** bis dropbear verfügbar ist
2. **SSH-Verbindung zu dropbear:**
   ```bash
   ssh -v stefan@192.168.1.246
   ```

3. **Im dropbear-Modus erwarten:**
   - Minimale Shell (busybox)
   - Begrenzte Befehle: `ls`, `cryptsetup`, `exit`, `cat`
   - Fokus auf Entschlüsselung

### Test 2: LUKS-Entschlüsselung
```bash
# Im dropbear-SSH:

# 1. Verschlüsselte Partitionen identifizieren
ls /dev/disk/by-uuid/
blkid | grep crypto_LUKS

# 2. Partition entschlüsseln (Beispiel)
cryptsetup luksOpen /dev/sda5 sda5_crypt
# Passphrase eingeben

# 3. Boot-Prozess fortsetzen
exit
```

### Test 3: Normaler Boot-Abschluss
```bash
# Nach ca. 2-3 Minuten normaler SSH-Zugriff
ssh stefan@192.168.1.246
# System sollte normal verfügbar sein
```

## 7. Rollout auf weitere Server

**Nur bei erfolgreichem Test auf debian-01:**

```bash
# Server einzeln deployen für bessere Kontrolle
ansible-playbook 02-dropbear-rollout.yml --limit debian-02

# Test auf debian-02, dann:
ansible-playbook 02-dropbear-rollout.yml --limit debian-03

# Validierung aller Server
ansible-playbook 03-validate-dropbear.yml --limit remaining_servers
```

## 8. Troubleshooting

### Problem: SSH-Setup schlägt fehl
```bash
# Manuelle Überprüfung auf Target-Server
ssh stefan@192.168.1.246
sudo whoami  # Sollte "root" ausgeben

# Falls sudo fehlt, auf dem Server direkt:
su -  # Als root einloggen
apt update && apt install sudo
usermod -aG sudo stefan
```

### Problem: sudo auf debian-admin nicht verfügbar
```bash
# Als root auf debian-admin:
su -
apt update && apt install sudo ansible sshpass git -y
usermod -aG sudo stefan

# Session neu starten
exit
ssh stefan@192.168.1.245
sudo whoami  # Sollte "root" ausgeben
```

### Problem: "Permission denied (publickey,password)" beim ersten SSH-Setup
```bash
# Fehler-Symptom:
# fatal: [debian-01]: UNREACHABLE! => changed=false
#   msg: 'Failed to connect to the host via ssh: stefan@192.168.1.246: Permission denied (publickey,password).'

# Ursache: Ansible braucht BEIDE Passwörter beim ersten Mal
# SSH-Passwort (da noch keine Keys installiert) + sudo-Passwort

# Lösung: Beide Parameter verwenden
ansible-playbook 01-ssh-setup.yml --ask-pass --ask-become-pass

# Manuelle SSH-Verbindung testen (sollte mit Passwort funktionieren):
ssh stefan@192.168.1.246
# Falls das fehlschlägt, SSH-Konfiguration auf dem Server prüfen
```

### Problem: SSH-Passwort-Authentifizierung deaktiviert
```bash
# Falls ssh stefan@192.168.1.246 mit Passwort nicht funktioniert:
# Auf dem Ziel-Server als root SSH-Konfiguration prüfen:

grep "PasswordAuthentication" /etc/ssh/sshd_config
# Sollte sein: PasswordAuthentication yes

# Falls "PasswordAuthentication no":
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh
```

### Problem: Vergessenes --ask-pass bei erstem Setup
```bash
# Wenn Sie --ask-pass beim ersten Mal vergessen haben:

# Korrekt: Beide Parameter verwenden
ansible-playbook 01-ssh-setup.yml --ask-pass --ask-become-pass

# Erklärung der Parameter:
# --ask-pass        = SSH-Passwort (für Verbindung zu den Servern)
# --ask-become-pass = sudo-Passwort (für root-Rechte auf den Servern)

# Nach erfolgreichem Setup:
# - SSH-Keys sind installiert (kein --ask-pass mehr nötig)
# - Passwortloses sudo ist konfiguriert (kein --ask-become-pass mehr nötig)
```

### Problem: dropbear startet nicht nach Reboot
```bash
# Logs prüfen (nach normalem Boot)
ansible test_server -m shell -a "journalctl -u dropbear" --become

# initramfs-Backup wiederherstellen
ansible test_server -m copy -a "src=/boot/initrd.img-$(uname -r).backup dest=/boot/initrd.img-$(uname -r) remote_src=yes" --become
ansible test_server -m reboot
```

### Problem: SSH-Verbindung zu dropbear fehlschlägt
```bash
# Nach normalem Boot prüfen:
ansible test_server -m shell -a "lsinitramfs /boot/initrd.img-$(uname -r) | grep dropbear" --become

# Interface-Konfiguration prüfen
ansible test_server -m shell -a "ip link show" --become
```

### Problem: LUKS-Entschlüsselung funktioniert nicht
- Korrekte Partition mit `lsblk -f` identifizieren
- Syntax: `cryptsetup luksOpen /dev/[device] [name]`
- Bei mehreren Partitionen: alle einzeln entschlüsseln
- Passphrase korrekt eingeben (keine Anzeige)

## 9. Sicherheitshinweise

### SSH-Schlüssel
- ✅ Private Schlüssel auf debian-admin sicher verwahren
- ✅ Keine Passphrase bei Ansible-Schlüsseln (für Automatisierung)
- ✅ Regelmäßige Rotation erwägen

### dropbear-Zugriff
- ⚠️ dropbear läuft nur während Boot-Phase (ca. 2-3 Minuten)
- ⚠️ Minimale Shell-Umgebung
- ⚠️ Root-Zugriff über SSH-Schlüssel

### Netzwerk
- ✅ Firewall-Regeln für SSH-Port 22
- ✅ VPN-Zugang für Remote-Administration erwägen
- ✅ Boot-Zeiten überwachen

## 10. Dateien-Übersicht

Nach der Installation sollten folgende Dateien vorhanden sein:

```
~/ansible-dropbear/
├── ansible.cfg                 # Ansible-Konfiguration
├── inventory.ini               # Server-Definition
├── 00-validate-setup.yml       # Setup-Validierung (optional)
├── 01-ssh-setup.yml           # SSH + sudo Setup
├── 02-dropbear-minimal.yml     # dropbear Test-Installation  
├── 02-dropbear-rollout.yml     # dropbear Rollout
└── 03-validate-dropbear.yml    # dropbear Validierung
```

## 11. Integration in Homelab-Infrastruktur

### IP-Schema Anpassung

Die Server nutzen den **Test-Bereich** des bestehenden Homelab-Schemas:

```bash
#### Test-Bereich (192.168.1.245 - 192.168.1.254)

| Bereich | IP-Bereich | Anzahl IPs | Verwendung |
|---------|------------|------------|------------|
| **Test-VMs** | 192.168.1.245 - 192.168.1.254 | 10 | Experimentelle Setups, Ansible-Tests, dropbear-Entwicklung |

#### Angepasste Reserve (192.168.1.221 - 192.168.1.244)

| Bereich | IP-Bereich | Anzahl IPs | Verwendung |
|---------|------------|------------|------------|
| **Reserve** | 192.168.1.221 - 192.168.1.244 | 24 | Für zukünftige Produktiv-Erweiterungen |
```

### DNS-Integration
```bash
# Pi-hole DNS-Einträge für Test-Server
192.168.1.245    lab-debian-admin-01.lab.[DOMAIN]
192.168.1.246    lab-debian-test-01.lab.[DOMAIN]  
192.168.1.247    lab-debian-prod-01.lab.[DOMAIN]
192.168.1.248    lab-debian-prod-02.lab.[DOMAIN]
```

## 12. Lessons Learned

### Was funktioniert:
- ✅ Erweiterte dropbear-Konfiguration (`-p 22 -s -j -k`)
- ✅ Automatische SSH-Schlüssel-Erstellung
- ✅ Verbesserte sudo-Installation über Ansible
- ✅ Schritt-für-Schritt-Validierung
- ✅ initramfs-Backups vor Änderungen

### Was Probleme verursacht hat:
- ❌ Zu minimale dropbear-Optionen (nur `-p 22`)
- ❌ Fehlerhafte sudo-Installation via raw-Befehle
- ❌ Rollout ohne Test auf einzelnem Server
- ❌ Fehlende Backup-Strategie

### Best Practices:
1. **Immer VM-Snapshots** vor kritischen Änderungen
2. **Test auf einem Server** vor Rollout
3. **Erweiterte dropbear-Konfiguration** verwenden
4. **Automatische Backups** in Playbooks integrieren
5. **Console-Zugriff** als Fallback bereithalten

## 13. Nächste Schritte

Nach erfolgreichem dropbear-Setup:

### VPN-Vorbereitung
- [ ] Tang/Clevis für automatische Entschlüsselung
- [ ] VPN-Software (pangolin/headscale) evaluieren
- [ ] Netzwerk-Routing für VPN planen

### Monitoring & Wartung
- [ ] Boot-Zeit-Monitoring einrichten
- [ ] Automatische Updates planen
- [ ] Backup-Strategien für verschlüsselte Systeme
- [ ] Recovery-Dokumentation erstellen

### Sicherheit
- [ ] Firewall-Regeln verfeinern
- [ ] SSH-Key-Rotation planen
- [ ] Audit-Logging aktivieren
- [ ] Intrusion Detection evaluieren

## Anhang: Manuelle Fallback-Prozeduren

### Ohne Ansible: Manuelles dropbear-Setup

Falls Ansible nicht verfügbar ist:

```bash
# Auf dem Ziel-Server (als root oder mit sudo):
apt update && apt install dropbear-initramfs

# SSH-Schlüssel kopieren
mkdir -p /etc/dropbear/initramfs/
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5..." > /etc/dropbear/initramfs/authorized_keys
chmod 600 /etc/dropbear/initramfs/authorized_keys

# Erweiterte Konfiguration
echo 'DROPBEAR_OPTIONS="-p 22 -s -j -k"' > /etc/dropbear/initramfs/dropbear.conf

# initramfs neu generieren
update-initramfs -u

# Backup für Rollback
cp /boot/initrd.img-$(uname -r) /boot/initrd.img-$(uname -r).backup
```

### Manuelle sudo-Installation (frische Debian-Systeme)

Für alle Server bei frischer Installation:

```bash
# Als root auf jedem Server:
su -

# sudo installieren
apt update && apt install sudo -y

# Benutzer zur sudo-Gruppe hinzufügen
usermod -aG sudo stefan

# Testen
su - stefan
sudo whoami  # Sollte "root" ausgeben
```

### Recovery ohne Console-Zugriff

Bei Problemen ohne Console-Zugriff:

1. **VM-Snapshot wiederherstellen** (wenn verfügbar)
2. **Live-System booten** und chroot-Recovery
3. **Hosting-Provider kontaktieren** für Console-Zugriff
4. **Hardware-Reset** als letzter Ausweg

---

**Dokumentation erstellt basierend auf Chat-Verlauf und praktischen Erfahrungen beim Setup von verschlüsselten Debian-Servern mit dropbear-ssh Remote-Entschlüsselung.**
