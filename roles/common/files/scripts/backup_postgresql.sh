#!/usr/bin/env bash

# DATE: December 5, 2014
# get a list databases except postrges,template{0,1}
# loop through the list & back them up one by one.

# exit on error
set -e

readonly DATE=$(date +%Y-%m-%d)
readonly BACKUP_DIR="/home/backup/postgresql"
readonly SHOW_DBS="select datname from pg_database where datname != 'template0' and datname != 'template1' and datname != 'postgres';"
readonly DB_NAMES=$(psql -t -c "${SHOW_DBS}");

# run as postgres user
if [[ $USER != "postgres" ]]; then
    echo "Run script as postgres user, otherwise backups will fail."
    exit 1
fi

# Create postgresql backup dir. if nonexistent
if [[ ! -d ${BACKUP_DIR} ]]; then
    mkdir -p ${BACKUP_DIR}
fi

for db in $DB_NAMES; do
    pg_dump -b -v -o --format=custom -f ${BACKUP_DIR}/${db}_${DATE}.backup $db
done

# vim: set sw=4 ts=4:
