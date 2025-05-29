#! /bin/bash
#
# Provisioning script for control

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

# Enable "Bash strict mode"
set -o errexit  # abort on nonzero exitstatus
set -o nounset  # abort on unbound variable
set -o pipefail # don't mask errors in piped commands

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

SRC_DIR="/vagrant"
readonly SRC_DIR

#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Utility functions
source "$SRC_DIR/scripts/util.sh"
# Actions/settings common to all servers
source "$SRC_DIR/scripts/common.sh"

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------

log "Starting server specific provisioning tasks on ${HOSTNAME}"

# TODO: insert code here, e.g. install Apache, add users (see the provided
# functions in utils.sh), etc.

dnf install --assumeyes \
    epel-release

dnf install --assumeyes \
    python3-pip \
    sshpass

python3 -m pip install --user ansible

# Scan for SSH keys
log "Scanning remote hosts"

hosts=(192.168.56.10 192.168.56.78 192.168.56.254)

for host in "${hosts[@]}"; do
    if ping -c 1 -W 1 "$host" &>/dev/null; then
        if ! ssh-keygen -F "$host" &>/dev/null; then
            ssh-keyscan -H "$host" 2>/dev/null | sudo tee -a ~/.ssh/known_hosts &>/dev/null
            log "Host $host is added to known hosts and public key is transferred"
        else
            log "Host $host is already in known hosts"
        fi
    else
        log "Host $host is offline"
    fi
done

log "Running Ansible playbooks"
# ansible-playbook -i "$SRC_DIR/ansible/inventory.yml" "$SRC_DIR/ansible/site.yml"

ansible-playbook -i "$SRC_DIR/ansible/inventory.yml" "$SRC_DIR/ansible/pfsense.yml"

ansible-playbook -i "$SRC_DIR/ansible/inventory.yml" "$SRC_DIR/ansible/docker.yml"
ansible-playbook -i "$SRC_DIR/ansible/inventory.yml" "$SRC_DIR/ansible/adguard.yml"