#!/usr/bin/env bash

# Purpose:
#   - Cleanup backups dir. by removing backup files older than 2 weeks

readonly BACKUP_DIR="/home/backup"

# Find files older than 2 weeks and delete them
find -L ${BACKUP_DIR} -type f ! -newermt "2 weeks ago" -delete
