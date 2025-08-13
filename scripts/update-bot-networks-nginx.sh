#!/usr/bin/env bash

OUTPUT_FILE=roles/dspace/files/nginx/datacenter-networks.conf

# Write list of networks as comments
xargs -P0 -I% echo "# %" < scripts/datacenter-networks.tsv \
    > "$OUTPUT_FILE"

PREFIXES_TEMP=$(mktemp)

cut -f1 scripts/datacenter-networks.tsv \
    | roles/common/files/scripts/asn2ip.py \
    > "$PREFIXES_TEMP"

IPV4_TEMP=$(mktemp)
IPV6_TEMP=$(mktemp)

# Filter IPv4 networks of /24 or higher
grep -v ":" "$PREFIXES_TEMP" \
    | awk -F "/" '$2 >= 24 && $2 <= 32' \
    > "$IPV4_TEMP"

# Filter IPv6 networks of /56 or higher
grep ":" "$PREFIXES_TEMP" \
    | awk -F "/" '$2 >= 56' \
    > "$IPV6_TEMP"

echo "# Last update: $(date)" >> "$OUTPUT_FILE"

# Sort unique so nginx doesn't complain about duplicate networks
# Sort with "V" to make sure IPv4 addresses at least are in ascending order
# to load more efficiently in nginx (see ngx_http_geo_module docs)
sort -uV "$IPV4_TEMP" "$IPV6_TEMP" \
    | xargs -P0 -I% echo "% 'bot';" \
    >> "$OUTPUT_FILE"

echo "Wrote $OUTPUT_FILE"
