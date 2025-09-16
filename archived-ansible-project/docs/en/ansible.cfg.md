Explanation of the Configuration
[defaults]:

inventory = inventory/hosts.yml: Refers to the central inventory file located in the inventory/ directory.

roles_path = roles/: Ensures that roles are loaded from the roles/ folder.

gathering = smart: Optimizes fact gathering based on the situation, enabling efficient execution.

stdout_callback = yaml: Displays output in a clean YAML format, making debugging more readable.

retry_files_enabled = True: Creates retry files to store playbook failures for re-execution.

force_color = True: Enables color-coded terminal output for easier understanding.

[privilege_escalation]:

Allows privilege escalation using sudo.

become = True: Enables privilege escalation for specific tasks.

become_method = sudo: Specifies sudo as the escalation method.

become_user = root: Runs escalated commands as the root user.

become_ask_pass = False: Disables password prompts for sudo, ideal for automated runs.

[ssh_connection]:

Uses ControlPersist to maintain SSH sessions, reducing the overhead of repeatedly creating connections.

ssh_args = -o ControlMaster=auto -o ControlPersist=60s: Configures efficient SSH connection handling with a persistence time of 60 seconds.

control_path = /tmp/ansible-ssh-%%h-%%p-%%r: Sets the location of the SSH control socket.

pipelining = True: Minimizes SSH operations for faster playbook execution.

Fact Caching and Plugins:

fact_caching = jsonfile: Stores collected facts as JSON files for quick retrieval during subsequent runs.

fact_caching_connection = .cache/: Specifies the .cache directory for storing fact cache files.
