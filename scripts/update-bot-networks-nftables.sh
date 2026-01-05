#!/usr/bin/env bash
#
# Still a work in progress. Meant to be used to respond quickly to increased
# load caused by bots on Chinese networks. We must merge resulting networks
# with cidr-merge.py so nftables doesn't complain about conflicting intervals.

NETWORKS=scripts/chinese-networks.tsv
OUTPUT_FILE_IPV4=roles/common/files/chinese_networks-ipv4.nft
OUTPUT_FILE_IPV6=roles/common/files/chinese_networks-ipv6.nft
PREFIXES_TEMP=$(mktemp)

cut -f1 "$NETWORKS" \
    | roles/common/files/scripts/asn2ip.py \
    > "$PREFIXES_TEMP"

echo "#!/usr/sbin/nft -f" > "$OUTPUT_FILE_IPV4"
# Write list of networks as comments
cat "$NETWORKS" \
    | xargs -P0 -I% echo "# %" \
    >> "$OUTPUT_FILE_IPV4"
echo "# Last update: $(date)" >> "$OUTPUT_FILE_IPV4"
echo "define CHINESE_IPV4 = {" >> "$OUTPUT_FILE_IPV4"

# Filter out IPv6 networks
grep -v ':' "$PREFIXES_TEMP" \
    | scripts/cidr-merge.py \
    | sed "s/\$/,/" \
    | sort >> "$OUTPUT_FILE_IPV4"
echo "}" >> "$OUTPUT_FILE_IPV4"

echo "Wrote $OUTPUT_FILE_IPV4"

echo "#!/usr/sbin/nft -f" > "$OUTPUT_FILE_IPV6"
# Write list of networks as comments
cat "$NETWORKS" \
    | xargs -P0 -I% echo "# %" \
    >> "$OUTPUT_FILE_IPV6"
echo "# Last update: $(date)" >> "$OUTPUT_FILE_IPV6"
echo "define CHINESE_IPV6 = {" >> "$OUTPUT_FILE_IPV6"

# We should filter networks here so we don't get false positives
grep ":" "$PREFIXES_TEMP" \
    | scripts/cidr-merge.py \
    | sed "s/\$/,/" \
    | sort >> "$OUTPUT_FILE_IPV6"
echo "}" >> "$OUTPUT_FILE_IPV6"

echo "Wrote $OUTPUT_FILE_IPV6"
