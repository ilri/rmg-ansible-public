#!/usr/bin/env bash

# Purpose:
#   - Cleanup backups dir. by removing backup files older than 2 weeks

readonly BACKUP_DIR="/home/backup"

# Find files older than 2 weeks and delete them
schedtool -B -n1 -e ionice -c2 -n7 find -L ${BACKUP_DIR} -type f ! -newermt "2 weeks ago" -delete
