#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

source /opt/ansible/hacking/env-setup

ROLE="${1}"
INVENTORY_FILE="/host_inventory"
HOST_ROOT="/host_root"
ANSIBLE_CFG_FILE="/ansible.cfg"

cat <<EOF > "${INVENTORY_FILE}"
[${ROLE}]
${HOST_ROOT}
EOF

cat <<EOF > "${ANSIBLE_CFG_FILE}"
[defaults]
remote_tmp = /tmp
EOF

ansible-playbook -i "${INVENTORY_FILE}" --connection=chroot /opt/playbooks/install.yml
