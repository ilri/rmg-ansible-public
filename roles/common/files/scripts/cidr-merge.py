#!/usr/bin/env python
#
# Takes a list of CIDR ranges or IP addresses, and removes duplicates and
# merges ranges.
#
# This was written by Richard van der Hoff and does not have a license.
# See: https://github.com/richvdh/cidr-merge

import ipaddress
import sys
from typing import Collection, Iterable, List, Union

NetworkList = Union[ipaddress.IPv4Network, ipaddress.IPv6Network]


def _parse_input(input: Iterable[str]) -> Collection[List[NetworkList]]:
    ipv4_networks: List[ipaddress.IPv4Network] = []
    ipv6_networks: List[ipaddress.IPv6Network] = []

    for line in input:
        line = line.strip()
        try:
            parsed = ipaddress.ip_network(line)
        except Exception as e:
            print(f"Invalid input: {line}: {e}", file=sys.stderr)
            exit(1)

        if isinstance(parsed, ipaddress.IPv4Network):
            ipv4_networks.append(parsed)
        elif isinstance(parsed, ipaddress.IPv6Network):
            ipv6_networks.append(parsed)
        else:
            raise Exception(f"Unknown address type {parsed}")

    return ipv4_networks, ipv6_networks


def _dedup_list(netlist: List[NetworkList]) -> List[NetworkList]:
    # sort the input by ascending network address and prefix length.
    netlist = sorted(netlist)

    # build a new list, with deduplicated/merged networks.
    results = []
    for net in netlist:
        # if this is the first entry, seed the result list.
        if not results:
            results.append(net)
            continue

        # first of all: if this network is a subnet of the previous result, we can
        # skip it. We know that the largest ranges will always come first, because
        # we've sorted by ascending network address

        last_result = results[-1]
        if net.subnet_of(last_result):
            # print(f"Skipping {net}, subnet of {last_result}")
            continue

        # next: if this network has the same supernet as the last result, we can merge
        # them ... and then possibly carry on all the way back up the results.
        while results:
            last_result = results[-1]
            assert not last_result.overlaps(net)

            supernet = net.supernet()
            last_result_supernet = last_result.supernet()
            if last_result_supernet != supernet:
                break

            # print(f"Merging {last_result} and {net} into {supernet}")
            results.pop()
            net = supernet

        results.append(net)

    return results


def main():
    netlists = _parse_input(sys.stdin)

    for netlist in netlists:
        for net in _dedup_list(netlist):
            print(net.with_prefixlen)


if __name__ == "__main__":
    main()
