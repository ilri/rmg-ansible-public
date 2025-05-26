#!/usr/bin/env bash

OUTPUT_FILE=roles/dspace/files/nginx/datacenter-networks.conf

# Write list of networks as comments
xargs -P0 -I% echo "# %" < scripts/datacenter-networks.tsv \
    > "$OUTPUT_FILE"

PREFIXES_TEMP=$(mktemp)

cut -f1 scripts/datacenter-networks.tsv \
    | roles/common/files/scripts/asn2ip.py \
    > "$PREFIXES_TEMP"

echo "# Last update: $(date)" >> "$OUTPUT_FILE"

roles/common/files/scripts/cidr-merge.py < "$PREFIXES_TEMP" \
    | xargs -P0 -I% echo "% 'bot';" \
    | sort >> "$OUTPUT_FILE"

echo "Wrote $OUTPUT_FILE"
