#!/usr/bin/perl
use warnings;
use strict;

my %hash = ();

$hash{"192.168.0.1"}{"randy"} = "thomas";
$hash{"192.168.0.1"}{"ken"} = "samual";
$hash{"192.168.0.2"}{"jessie"} = "jessica";
$hash{"192.168.0.2"}{"terry"} = "ryan";

foreach my $ip (keys %hash) {
    while (my ($key, $value) = each %{ $hash{$ip} } ) {
        print "$key = $value \n";
    }
}
