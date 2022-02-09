#!/usr/bin/env bash

# backup-libvirt-xml.sh
#
# Backup XML domains for libvirt VMs.
#

readonly XML_BACKUP_DIR="/home/backup/libvirt-xml"
readonly VMS=$(virsh list --all | sed -e '1,2d' -e '$d'| awk '{print $2}')

# Create backup directory if it doesn't exist
if [[ ! -d "$XML_BACKUP_DIR" ]]; then
    mkdir -p "$XML_BACKUP_DIR"
fi

for vm in $VMS; do
    vm_xml="${XML_BACKUP_DIR}/${vm}.xml"
    virsh dumpxml "$vm" > "$vm_xml"
done

# vim: set sw=4 ts=4:
