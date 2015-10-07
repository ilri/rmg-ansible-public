#!/usr/bin/env bash

# Purpose
#   - backup all libvirt images except for a chosen few such as:
#       - ibli-ubuntu1204.qcow2 — ibli
#       - ilrinrb6.qcow2 — azizi_test

readonly DATE=$(date +%Y-%m-%d)
readonly IMAGES_DIR="/var/lib/libvirt/images"
readonly IMAGES_BACKUP_DIR="/home/backup/vms"

# exit on error
set -e

# create libvirt images backup dir. if non-existent
if [[ ! -d ${IMAGES_BACKUP_DIR} ]]; then
    mkdir -p ${IMAGES_BACKUP_DIR}
fi

for disk_path in $IMAGES_DIR/*.qcow2; do
    disk_name=$(basename $disk_path)
    disk_backup_path="${IMAGES_BACKUP_DIR}/${disk_name%.qcow2}-${DATE}.qcow2"

    #skip a few vm images — ibli(115G), ilrinrb06(azizi-test,27G)
    if [[ $disk_name != "ibli-ubuntu1204.qcow2" || $name != "ilrinrb6.qcow2" ]]; then
        schedtool -B -n 19 -e ionice -c 3 cp -v --sparse=always ${disk_path} ${disk_backup_path}
    fi
done

# vim: set sw=4 ts=4:
