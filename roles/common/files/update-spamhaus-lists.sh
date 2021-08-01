#!/usr/bin/env bash
#
# update-spamhaus-lists.sh v0.0.5
#
# Download Spamhaus DROP lists and load them into firewalld ipsets. Should work
# with both the iptables and nftables backends.
# 
# See: https://www.spamhaus.org/drop/
#
# Copyright (C) 2021 Alan Orth
#
# SPDX-License-Identifier: GPL-3.0-only

# Exit on first error
set -o errexit

firewalld_ipsets=$(firewall-cmd --get-ipsets)
xml_temp=$(mktemp)
spamhaus_ipv4_ipset_path=/etc/firewalld/ipsets/spamhaus-ipv4.xml
spamhaus_ipv6_ipset_path=/etc/firewalld/ipsets/spamhaus-ipv6.xml

function download() {
    echo "Downloading $1"
    wget -q -O - "https://www.spamhaus.org/drop/$1" > "$1"
}

download drop.txt
download edrop.txt
download dropv6.txt

if [[ -f "drop.txt" && -f "edrop.txt" ]]; then
    echo "Processing IPv4 DROP lists"

    # Extract all networks from drop.txt and edrop.txt, skipping blank lines and
    # comments.
    networks=$(cat drop.txt edrop.txt | sed -e '/^$/d' -e '/^;.*/d' -e 's/[[:space:]];[[:space:]].*//')

    # If firewalld already has this ipset we should delete it first to emulate
    # `ipset flush` (but I don't want to use that because newer hosts might be
    # using nftables and firewalld will handle that for us).
    if [[ "$firewalld_ipsets" =~ spamhaus-ipv4 ]]; then
        echo "Deleting existing spamhaus-ipv4 ipset"
        # This deletes the firewalld ipset XML file as well as the ipset itself
        firewall-cmd --permanent --delete-ipset=spamhaus-ipv4
    else
        echo "Creating placeholder spamhaus-ipv4 ipset"
        # Create a placeholder ipset so firewalld doesn't complain when we try
        # to reload the ipset later after having added a new XML definition. I
        # don't know why, but depending on the system state there may not be a
        # ipset defined and firewalld errors on INVALID_IPSET.
        firewall-cmd --permanent --new-ipset=spamhaus-ipv4 --type=hash:net --option=family=inet
    fi

    # I'm not proud of this, but writing the XML directly is WAY faster than
    # using firewall-cmd to add each entry one by one (and we can't add from
    # a file because many of our hosts are using old firewalld).
    cat << XML_HEAD > "$xml_temp"
<?xml version="1.0" encoding="utf-8"?>
<ipset type="hash:net">
  <option name="family" value="inet" />
  <short>spamhaus-ipv4</short>
  <description>Spamhaus DROP and EDROP lists (IPv4).</description>
XML_HEAD

    for network in $networks; do
		echo "    <entry>$network</entry>" >> "$xml_temp"
    done

    echo "</ipset>" >> "$xml_temp"

    install -m 0600 "$xml_temp" "$spamhaus_ipv4_ipset_path"
fi

if [[ -f "dropv6.txt" ]]; then
    echo "Processing IPv6 DROP list"

    networks=$(sed -e '/^$/d' -e '/^;.*/d' -e 's/[[:space:]];[[:space:]].*//' dropv6.txt)

    if [[ "$firewalld_ipsets" =~ spamhaus-ipv6 ]]; then
        echo "Deleting existing spamhaus-ipv6 ipset"
        firewall-cmd --permanent --delete-ipset=spamhaus-ipv6
    else
        echo "Creating placeholder spamhaus-ipv6 ipset"
        firewall-cmd --permanent --new-ipset=spamhaus-ipv6 --type=hash:net --option=family=inet6
    fi

    cat << XML_HEAD > "$xml_temp"
<?xml version="1.0" encoding="utf-8"?>
<ipset type="hash:net">
  <option name="family" value="inet6" />
  <short>spamhaus-ipv6</short>
  <description>Spamhaus DROP lists (IPv6).</description>
XML_HEAD

    for network in $networks; do
		echo "    <entry>$network</entry>" >> "$xml_temp"
    done

    echo "</ipset>" >> "$xml_temp"

    install -m 0600 "$xml_temp" "$spamhaus_ipv6_ipset_path"
fi

echo "Reloading firewalld"
firewall-cmd --reload

rm -v drop.txt edrop.txt dropv6.txt "$xml_temp"
