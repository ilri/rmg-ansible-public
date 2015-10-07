#!/usr/bin/env bash

# Purpose:
#   - compress & backup a list of dirs e.g. /etc

readonly BACKUP_DEST_DIR="/home/backup/etc"
readonly CURRENT_DATE=$(date +%Y-%m-%d)

# list of dir(s) to backup
readonly DIRS="/etc"

# path to bins
readonly BIN_TAR="/bin/tar"
readonly BIN_MKDIR="/bin/mkdir"

# exit on error
set -e

# create backup destination dir if nonexistent
if [[ ! -d ${BACKUP_DEST_DIR} ]]; then
    $BIN_MKDIR -p ${BACKUP_DEST_DIR}
fi

# backup dirs
for dir in ${DIRS}; do
    backup_filename="${BACKUP_DEST_DIR}/$(basename ${dir})-${CURRENT_DATE}.tar.gz"
    $BIN_TAR -czpf ${backup_filename} ${dir}
done

# vim: set sw=4 ts=4:
