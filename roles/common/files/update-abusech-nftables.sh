#!/usr/bin/env bash
#
# update-abuseipdb-nftables.sh v0.0.1
#
# Download IP addresses seen using a blacklisted SSL certificate and load them
# into nftables sets. As of 2021-07-28 these appear to only be IPv4.
# 
# See: https://sslbl.abuse.ch/blacklist
#
# Copyright (C) 2021 Alan Orth
#
# SPDX-License-Identifier: GPL-3.0-only

# Exit on first error
set -o errexit

abusech_ipv4_set_path=/etc/nftables/abusech-ipv4.nft
abusech_list_temp=$(mktemp)

echo "Downloading Abuse.sh SSL Blacklist IPs"

abusech_response=$(curl -s -G -w "%{http_code}\n" https://sslbl.abuse.ch/blacklist/sslipblacklist.txt --output "$abusech_list_temp")

if [[ $abusech_response -ne 200 ]]; then
	echo "Abuse.ch responded: HTTP $abusech_response"

	exit 1
fi

if [[ -f "$abusech_list_temp" ]]; then
    echo "Processing IPv4 list"

    abusech_ipv4_list_temp=$(mktemp)
    abusech_ipv4_set_temp=$(mktemp)

    # Remove comments, DOS carriage returns, and IPv6 addresses (even though
    # Abuse.ch seems to only have IPv4 addresses, let's not break our shit on
    # that assumption some time down the line).
    sed -e '/#/d' -e 's///' -e '/:/d' "$abusech_list_temp" > "$abusech_ipv4_list_temp"

    echo "Building abusech-ipv4 set"
    cat << NFT_HEAD > "$abusech_ipv4_set_temp"
#!/usr/sbin/nft -f

define ABUSECH_IPV4 = {
NFT_HEAD

    while read -r network; do
        # nftables doesn't mind if the last element in the set has a trailing
        # comma so we don't need to do anything special here.
        echo "$network," >> "$abusech_ipv4_set_temp"
    done < $abusech_ipv4_list_temp

    echo "}" >> "$abusech_ipv4_set_temp"

    install -m 0600 "$abusech_ipv4_set_temp" "$abusech_ipv4_set_path"

    rm -f "$abusech_list_temp" "$abusech_ipv4_list_temp" "$abusech_ipv4_set_temp"
fi

echo "Reloading nftables"
# The abusech nftables sets are included by nftables.conf
/usr/sbin/nft -f /etc/nftables.conf
