#!/usr/bin/env bash

# Purpose
#   - backup all libvirt vms info. in an XML file
#

readonly DATE=$(date +%Y-%m-%d)
readonly XML_BACKUP_DIR="/home/backup/vms_xml"
readonly VMS=$(virsh list --all | sed -e '1,2d' -e '$d'| awk '{print $2}')

# create backup dir. if nonexistent
if [[ ! -d ${XML_BACKUP_DIR} ]]; then
    mkdir -p ${XML_BACKUP_DIR}
fi

for vm in $VMS; do
    vm_xml="${XML_BACKUP_DIR}/${vm}-$DATE.xml"
    virsh dumpxml $vm > $vm_xml
done

# vim: set sw=4 ts=4:
