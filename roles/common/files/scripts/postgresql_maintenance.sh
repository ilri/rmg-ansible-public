#!/usr/bin/env bash

# DATE: December 05, 2014
# clean & analyze postgresql databases

# run as postgres user
if [[ $USER != "postgres" ]]; then
    echo "Run script as postgres user, otherwise vacuum will fail."
    exit 1
fi

# run vacuum
vacuumdb --all --analyze --username=postgres

# vim: set sw=4 ts=4:
