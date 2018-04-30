#!/usr/local/bin/perl

use Data::Dumper;


my $text = "Pierre Vinken, 61 years old, will join the board as a nonexecutive director Nov.";
my $output = `echo \"$text\" | ./opennlp TokenNameFinder en-ner-person.bin`;
print STDERR "OUTPUT: $output\n";

# open my $file, '>', $ARGV[0] or die "Could not open file.\n";
# my $text = "Pierre Vinken , 61 years old , will join the board as a nonexecutive director Nov.
# 29 .";
#
# @results = `echo \"$text\" | opennlp TokenNameFinder en-ner-person.bin`;
#
# print "$output\n";
# print STDERR "OUTPUT: $output\n";

#print "OUTPUT: \n";
# print Dumper (\@output);
