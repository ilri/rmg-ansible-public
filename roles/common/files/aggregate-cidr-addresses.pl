#!/usr/bin/perl
#
# aggregate-cidr-addresses - combine a list of CIDR address blocks
# Copyright (C) 2001,2007 Mark Suter <suter@zwitterion.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see L<http://www.gnu.org/licenses/>.
#
# [MJS 22 Oct 2001] Aggregate CIDR addresses
# [MJS  9 Oct 2007] Overlap idea from Anthony Ledesma at theplanet dot com.
# [MJS 16 Feb 2012] Prompted to clarify license by Alexander Talos-Zens - at at univie dot ac dot at
# [MJS 21 Feb 2012] IPv6 fixes by Alexander Talos-Zens
# [MJS 21 Feb 2012] Split ranges into prefixes (fixes a 10+ year old bug)

use strict;
use warnings;
use English qw( -no_match_vars );
use Net::IP;

## Read in all the IP addresses
my @addrs = map { Net::IP->new($_) or die "$PROGRAM_NAME: Not an IP: \"$_\"."; }
    map { / \A \s* (.+?) \s* \Z /msix and $1; } <>;

## Split any ranges into prefixes
@addrs = map {
    defined $_->prefixlen ? $_ : map { Net::IP->new($_) }
        $_->find_prefixes
} @addrs;

## Sort the IP addresses
@addrs = sort { $a->version <=> $b->version or $a->bincomp( 'lt', $b ) ? -1 : $a->bincomp( 'gt', $b ) ? 1 : 0 } @addrs;

## Handle overlaps
my $count   = 0;
my $current = $addrs[0];
foreach my $next ( @addrs[ 1 .. $#addrs ] ) {
    my $r = $current->overlaps($next);
    if ( $current->version != $next->version or $r == $IP_NO_OVERLAP ) {
        $current = $next;
        $count++;
    }
    elsif ( $r == $IP_A_IN_B_OVERLAP ) {
        $current = $next;
        splice @addrs, $count, 1;
    }
    elsif ( $r == $IP_B_IN_A_OVERLAP or $r == $IP_IDENTICAL ) {
        splice @addrs, $count + 1, 1;
    }
    else {
        die "$PROGRAM_NAME: internal error - overlaps() returned an unexpected value!\n";
    }
}

## Keep aggregating until we don't change anything
my $change = 1;
while ($change) {
    $change = 0;
    my @new_addrs = ();
    $current = $addrs[0];
    foreach my $next ( @addrs[ 1 .. $#addrs ] ) {
        if ( my $total = $current->aggregate($next) ) {
            $current = $total;
            $change  = 1;
        }
        else {
            push @new_addrs, $current;
            $current = $next;
        }
    }
    push @new_addrs, $current;
    @addrs = @new_addrs;
}

## Print out the IP addresses
foreach (@addrs) {
    print $_->prefix(), "\n";
}

# $Id: aggregate-cidr-addresses,v 1.9 2012/02/21 10:14:22 suter Exp suter $
