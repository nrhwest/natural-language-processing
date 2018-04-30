#!/usr/bin/perl
use warnings;
use strict;

my $sentence = "under understand. until we meet unknown.";

if ($sentence =~ m/^un?(.*)/) {
  print "true\n";
} else {
  print "false\n";
}
