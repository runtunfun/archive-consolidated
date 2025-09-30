# Verschlüsselte Debian-Server mit dropbear-ssh via Ansible

## Übersicht

Diese Anleitung beschreibt die Einrichtung von 3 verschlüsselten Debian-Servern mit automatisierter Remote-Entschlüsselung über dropbear-ssh via Ansible.

**Zielsetzung:**
- Remote-Entschlüsselung von LUKS-verschlüsselten Servern während des Boot-Prozesses
- Automatisierte Konfiguration via Ansible
- Minimaler, wartbarer Ansatz

## Umgebung

| System | IP-Adresse | Rolle | Besonderheiten |
|--------|------------|-------|----------------|
| debian-admin | 192.168.1.245 | Ansible Controller | SSH-Schlüssel, Ansible |
| debian-01 | 192.168.1.246 | Target Server | LUKS-verschlüsselt |
| debian-02 | 192.168.1.247 | Target Server | LUKS-verschlüsselt |
| debian-03 | 192.168.1.248 | Target Server | LUKS-verschlüsselt |

**Benutzer:** `stefan` 

## Voraussetzungen

### Auf allen Servern
- ✅ Debian-Installation mit LVM-Verschlüsselung aktiviert
- ✅ SSH-Server läuft
- ✅ Benutzer `stefan` existiert und ist in `sudo`-Gruppe
- ✅ `sudo` ist installiert
- ✅ Netzwerk-Konnektivität zwischen Servern

### Auf debian-admin
- ✅ Debian/Ubuntu-System mit Ansible installiert
- ✅ Internet-Zugang für Paket-Installation

## 1. Vorbereitung debian-admin

### Projektverzeichnis erstellen
```bash
mkdir ~/ansible-dropbear
cd ~/ansible-dropbear
```

### SSH-Verbindung zu allen Servern testen
```bash
# Test der Grundverbindung
ssh stefan@192.168.1.246
ssh stefan@192.168.1.247  
ssh stefan@192.168.1.248
# Mit exit wieder ausloggen
```

## 2. Ansible-Konfiguration

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

## 3. Ansible-Playbooks

### SSH-Setup und passwordless sudo
```bash
cat > 01-ssh-setup.yml << 'EOF'
---
- name: SSH-Setup und passwordless sudo
  hosts: debian_servers
  gather_facts: yes
  become: yes
  
  pre_tasks:
    - name: SSH-Schlüssel auf Admin-System prüfen/erstellen
      block:
        - name: Prüfen ob SSH-Schlüssel vorhanden
          stat:
            path: "{{ lookup('env', 'HOME') }}/.ssh/id_ed25519"
          register: ssh_key_check
          delegate_to: localhost
          run_once: true
        
        - name: SSH-Schlüssel erstellen (falls nicht vorhanden)
          openssh_keypair:
            path: "{{ lookup('env', 'HOME') }}/.ssh/id_ed25519"
            type: ed25519
            comment: "ansible@debian-admin"
            force: no
          delegate_to: localhost
          run_once: true
          when: not ssh_key_check.stat.exists
  
  tasks:
    - name: SSH-Schlüssel für stefan kopieren
      authorized_key:
        user: stefan
        state: present
        key: "{{ lookup('file', lookup('env', 'HOME') + '/.ssh/id_ed25519.pub') }}"
        comment: "ansible@debian-admin"
    
    - name: passwordless sudo für stefan einrichten
      lineinfile:
        path: /etc/sudoers.d/stefan
        line: 'stefan ALL=(ALL) NOPASSWD:ALL'
        create: yes
        mode: '0440'
        validate: '/usr/sbin/visudo -cf %s'
    
    - name: SSH-Konfiguration härten
      blockinfile:
        path: /etc/ssh/sshd_config
        block: |
          # Sicherheits-Optimierungen
          PermitRootLogin no
          PasswordAuthentication yes
          PubkeyAuthentication yes
          UseDNS no
          MaxAuthTries 3
          Protocol 2
        marker: "# {mark} ANSIBLE MANAGED SECURITY BLOCK"
        backup: yes
      notify: restart ssh
    
    - name: Grundlegende Pakete installieren
      apt:
        name:
          - curl
          - wget
          - vim
          - htop
          - unzip
          - git
        state: present
        update_cache: yes
  
  handlers:
    - name: restart ssh
      service:
        name: ssh
        state: restarted
EOF
```

### dropbear-ssh Installation (Test)
```bash
cat > 02-dropbear-minimal.yml << 'EOF'
---
- name: dropbear-ssh Installation (TEST)
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
    
    - name: dropbear-Konfiguration
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
    
    - name: dropbear-Module in initramfs prüfen
      shell: lsinitramfs /boot/initrd.img-{{ ansible_kernel }} | grep -E "(dropbear|ssh)" || true
      register: dropbear_check
      changed_when: false
    
    - name: dropbear-Module anzeigen
      debug:
        var: dropbear_check.stdout_lines
EOF
```

### Validierung
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
    
    - name: Verschlüsselte Partitionen anzeigen
      shell: lsblk -f | grep crypt || echo "Keine verschlüsselten Partitionen gefunden"
      register: encrypted_partitions
      changed_when: false
    
    - name: Verschlüsselte Partitionen
      debug:
        var: encrypted_partitions.stdout_lines
EOF
```

### Rollout auf weitere Server
```bash
cat > 02-dropbear-rollout.yml << 'EOF'
---
- name: dropbear-ssh Installation (Rollout)
  hosts: remaining_servers
  gather_facts: yes
  
  pre_tasks:
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
    
    - name: dropbear-Konfiguration
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
EOF
```

## 4. Ausführung

### Schritt 1: SSH-Setup
```bash
cd ~/ansible-dropbear

# Einmalig mit BEIDEN Passwörtern beim ersten Mal:
# --ask-pass = SSH-Passwort (da noch keine SSH-Keys installiert)
# --ask-become-pass = sudo-Passwort (für passwordless sudo setup)
ansible-playbook 01-ssh-setup.yml --ask-pass --ask-become-pass
```

**Erwartete Abfragen:**
1. `SSH password:` - Das SSH-Passwort für stefan
2. `BECOME password:` - Das sudo-Passwort für stefan

### Schritt 2: Verbindung testen
```bash
# Sollte jetzt ohne Passwort funktionieren
ansible debian_servers -m ping
```

### Schritt 3: dropbear auf Test-Server installieren
```bash
# Kein --ask-pass oder --ask-become-pass mehr nötig 
# (SSH-Keys und passwordless sudo sind jetzt konfiguriert)
ansible-playbook 02-dropbear-minimal.yml
```

### Schritt 4: Installation validieren
```bash
ansible-playbook 03-validate-dropbear.yml
```

## 5. Test-Szenario

### Test-Reboot
```bash
echo "ACHTUNG: Test-Reboot für debian-01!"
read -p "Console-Zugriff bereithalten! Weiter? (y/N): " confirm

if [ "$confirm" = "y" ]; then
    ansible test_server -m reboot
fi
```

### dropbear-SSH-Zugriff testen
```bash
# Nach ca. 1-2 Minuten dropbear verfügbar
ssh -v stefan@192.168.1.246

# Im dropbear-Modus:
# 1. Verschlüsselte Partitionen identifizieren
lsblk -f | grep crypt

# 2. Partition entschlüsseln
cryptsetup luksOpen /dev/sda5 sda5_crypt
# Passphrase eingeben

# 3. Boot fortsetzen
exit
```

### Normaler Boot-Abschluss
```bash
# Nach ca. 2-3 Minuten normaler SSH-Zugriff
ssh stefan@192.168.1.246
```

## 6. Rollout auf weitere Server

**Nur bei erfolgreichem Test:**

```bash
# Server einzeln deployen
ansible-playbook 02-dropbear-rollout.yml --limit debian-02
ansible-playbook 02-dropbear-rollout.yml --limit debian-03

# Validierung aller Server
ansible-playbook 03-validate-dropbear.yml --limit remaining_servers
```

## 7. Troubleshooting

### Problem: "Permission denied (publickey,password)" beim ersten SSH-Setup
```bash
# Fehler-Symptom:
# stefan@192.168.1.246: Permission denied (publickey,password)

# Ursache: --ask-pass Parameter fehlt beim ersten Mal
# Lösung: Beide Parameter verwenden
ansible-playbook 01-ssh-setup.yml --ask-pass --ask-become-pass

# Erklärung:
# --ask-pass        = SSH-Passwort (da noch keine SSH-Keys installiert)
# --ask-become-pass = sudo-Passwort (für root-Rechte auf den Servern)
```

### Problem: SSH-Passwort-Authentifizierung deaktiviert
```bash
# Falls SSH-Passwort-Login nicht funktioniert:
# Auf dem Ziel-Server SSH-Konfiguration prüfen:
grep "PasswordAuthentication" /etc/ssh/sshd_config
# Sollte sein: PasswordAuthentication yes

# Falls "PasswordAuthentication no":
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh
```

### Problem: dropbear startet nicht nach Reboot
```bash
# Logs prüfen (nach normalem Boot)
ansible test_server -m shell -a "journalctl -u dropbear"

# initramfs-Backup wiederherstellen
ansible test_server -m copy -a "src=/boot/initrd.img-$(uname -r).backup dest=/boot/initrd.img-$(uname -r) remote_src=yes"
ansible test_server -m reboot
```

### Problem: SSH-Verbindung zu dropbear fehlschlägt
```bash
# dropbear-Module in initramfs prüfen
ansible test_server -m shell -a "lsinitramfs /boot/initrd.img-$(uname -r) | grep dropbear"
```

### Problem: LUKS-Entschlüsselung funktioniert nicht
- Korrekte Partition mit `lsblk -f` identifizieren
- Syntax: `cryptsetup luksOpen /dev/[device] [name]`
- Bei mehreren Partitionen: alle einzeln entschlüsseln

## 8. Integration in Homelab-Infrastruktur

### IP-Schema
Test-Bereich aus Reserve abgezweigt:
- **Test-VMs:** 192.168.1.245 - 192.168.1.254 (10 IPs)
- **Reserve:** 192.168.1.221 - 192.168.1.244 (24 IPs)

### DNS-Integration
```bash
# Pi-hole DNS-Einträge
192.168.1.245    lab-debian-admin-01.lab.[DOMAIN]
192.168.1.246    lab-debian-test-01.lab.[DOMAIN]  
192.168.1.247    lab-debian-prod-01.lab.[DOMAIN]
192.168.1.248    lab-debian-prod-02.lab.[DOMAIN]
```

## 9. Sicherheitshinweise

### SSH-Schlüssel
- ✅ Private Schlüssel auf debian-admin sicher verwahren
- ✅ Regelmäßige Rotation erwägen

### dropbear-Zugriff
- ⚠️ dropbear läuft nur während Boot-Phase (ca. 2-3 Minuten)
- ⚠️ Minimale Shell-Umgebung
- ⚠️ Root-Zugriff über SSH-Schlüssel

### Netzwerk
- ✅ Firewall-Regeln für SSH-Port 22
- ✅ VPN-Zugang für Remote-Administration erwägen
- ✅ Boot-Zeiten überwachen

## 10. Nächste Schritte

- [ ] Tang/Clevis für automatische Entschlüsselung
- [ ] VPN-Software (pangolin/headscale) evaluieren
- [ ] Boot-Zeit-Monitoring einrichten
- [ ] Backup-Strategien für verschlüsselte Systeme

---

**Dokumentation für verschlüsselte Debian-Server mit dropbear-ssh Remote-Entschlüsselung via Ansible.**
