#!/usr/local/bin/perl

=begin comment
Created by Nathan West
Date : 03/02/18

Description : The program is used to calculate how accurate the tagger.pl was
              at actual a word's part of speech tag. Created to be used after
              tagger.pl has finished.

Example : Via command-line arguments the use the user types in 2 files. The first
          file is the pos-test-with-tags.txt file which contains the expected
          tags of the words from the pos-test.txt file. The second file is the
          pos-test-key.txt file which contains the actual tags of the words
          from the pos-test.txt file. The program outputs the accuracy of tagger.pl
          to a new file and the confusion matrix that represents the errors of tagger.pl

          INPUT : perl scorer.pl pos-test-with-tags.txt pos-test-key.txt > pos-tagging-report.txt
          OUTPUT : A new file (pos-tagging-report.txt) containing accuracy and confusion matrix

Algorithm : Both files are read through command-line arguments, parsed, and put
            into different arrays. The algorithm cycles through the set of
            actual keys/tags from pos-test-key.txt and compares the expected tag
            to the actual tag. If the tags are the same, a correct counter is incremented.
            If the tags don't match, they're put into the confusion matrix and increment
            the error. The accuracy is calculated, then printed to the new file.
            Treated as a 2D array/hash, the confusion matrix is printed to the same file.

=end comment
=cut

use strict;
use warnings;
use Data::Dumper qw(Dumper);

open my $fh, $ARGV[0] or die "Could not open file.\n";
open my $fh2, $ARGV[1] or die "Could not open file.\n";

my @tag_set, @key_set;
my $expected, $actual;
my $count = 0;
my %confusionMatrix, %tag_list;

while (!eof($fh2) ) {
    my $data2 = <$fh2>;

    chomp $data2;
    $data2 =~ s/(\[\s)+|(\s\])+//g;   ## regex to remove brackets
    my @temp_set2 = split/\s+/, $data2;

    foreach my $token (@temp_set2) {
        if ($token =~ m/(.*)[\/]?\/(.*)/g) {

        }
        push @key_set, $token;  }
}
close($fh2);

while (!eof($fh)) {
    my $data = <$fh>;
    chomp $data;
    push @tag_set, $data;
}
close($fh);

foreach my $i (0..$#key_set) {
    if ($tag_set[$i] =~ m/(.*)[\/]?\/(.*)/g) {  $expected = $2; }  ## safety regex for expected tag
    if ($key_set[$i] =~ m/(.*)[\/]?\/(.*)/g) {  $actual = $2; } ## safety regex for actual tag

    if ($expected =~ m/(.*)(?=\|)/) {  $expected = $1; }  ## regex for OR symbol with tags
    if ($actual =~ m/(.*)(?=\|)/) {  $actual = $1; }

    $tag_list{$actual}++;

    if ($expected ne $actual) {   ## check if the two tags match
        $confusionMatrix{$expected}{$actual}++;   ## increment the confusionMatrix error count
    } else {
        $count++;   ## increment counter for correct tag matches
    }
}

my $accuracy = ($count / $#key_set) * 100;  ##  calculation of the accuracy
$accuracy = sprintf("%.2f", $accuracy);  ## format accuracy
print STDOUT "\nThe accuracy of tagger.pl is $accuracy percent\n";
print STDOUT "Confusion matrix : \n\n";

## set up for printing the confusionMatrix
my @tags;
foreach my $key (keys %tag_list) {
    push @tags, $key;
    print "$key | ";
}

print "\n";

for $n (0..$#tags) {
    for $m (0..$#tags) {
        ## checks both tags exists then retrieves value
        if (exists $confusionMatrix{$tags[$n]}{$tags[$m]}) {
            print "$confusionMatrix{$tags[$n]}{$tags[$m]}";
        }
        else{  print "0";  } ## zeros where tags did not interact
        print " | ";	## lines for reading
    }
    print "\n";
}
