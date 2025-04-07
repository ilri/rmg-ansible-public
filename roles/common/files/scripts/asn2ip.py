#!/usr/bin/env python
#
# asn2ip.py v0.0.1
#
# Copyright Alan Orth.
#
# SPDX-License-Identifier: GPL-3.0-only
#
# ---
#
# For a list of ASNs, retrieve the prefixes known to RIPE. Keep this simple so
# it is composable, for example:
#
# ./asn2ip.py < asns.txt | ./cidr-merge.py | ./nginx-acl.py allow

import json
import sys
import urllib.request
from typing import Iterable, List
from urllib.error import HTTPError


def parse_input(input: Iterable[str]) -> List[str]:
    asns = []

    for line in input:
        # Clean up whitespace and make sure we only have the AS number
        line = line.strip().lstrip("AS").lstrip("ASN")

        if line not in asns:
            asns.append(line)

    return asns


def fetch_prefixes(asn: str) -> list:
    try:
        response = urllib.request.urlopen(
            f"https://stat.ripe.net/data/announced-prefixes/data.json?resource=AS{asn}&sourceapp=asn2ip.py"
        )
        response_status = response.status  # 200, 301, etc
    except HTTPError as error:
        print(f"Invalid input: {asn}: HTTP error {error.code}", file=sys.stderr)
        exit(1)

    response_body = response.read()

    # decode bytes to utf-8
    response_json = json.loads(response_body.decode("utf-8"))

    prefixes = [prefix["prefix"] for prefix in response_json["data"]["prefixes"]]

    return prefixes


def main():
    asns = parse_input(sys.stdin)

    for asn in asns:
        for prefix in fetch_prefixes(asn):
            print(prefix)


if __name__ == "__main__":
    main()
