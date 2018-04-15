#!/usr/local/bin/perl

=begin comment
Created by Nathan West
Date : 03/02/18

Description : This program is used for identifying the part-of-speech
              tag of a word The scorer.pl file determines how accurate the
              tagger.pl file is.

    No rules –> Accuracy : 84.31%
    
    Rule 1: All numbers should be tagged as numbers (CD)
         Accuracy : 85.02%
    Rule 2: All nouns that should with capital letters should be tagged as pronouns (NNP)
        Accuracy : 88.30%
    Rule 3: All nouns that end in 's' should be tagged as possessive nouns (NNS)
        Accuracy : 84.33%
    Rule 4: Hypenated words are compound adjectives or just adjectives (JJ)
        Accuracy : 84.70%
    Rule 5: Words that end in 'ly' should be adverbs
        Accuracy : 84.36%

    Final Accuracy, All rules : 89.20%

Example : Via the command-line, the user types in 2 files. The first file
          should be the training set file for the tagger and the second should
          be the test file

          INPUT : perl tagger.pl pos-train.txt pos-test.txt
          OUTPUT : A new file with tagged words from pos-test.txt

Algorithm : Both files are read through command-line arguments and parsed using
            regular expressions. The pos-train.txt file data is stored into a hash
            table of words and tags. The pos-test.txt file data is stored into an array.
            The algorithm cycles through the array and checks to see if each element
            in the array exists in the hash table. If it doesn't exist, that element/token/word's
            tag is a noun (NN). If it does exist, the algorithm loops through the sub-keys,
            calculating the most likely tag of the element/token/word.
            It then, prints to a file (pos-test-with-tags.txt).

=end comment
=cut

# use strict;
# use warnings;
use Data::Dumper qw(Dumper);

my @tokens, @words;   ## arrays for tokens
my %words_tags = ();   ## hash table for words -> tags
my %tag_set = ();   ## hash table for tag occurrences
my $count = 0;   ## count number of correct tag matches

#print STDOUT "-----------------\n";

open my $fh, $ARGV[0] or die "Could not open file.\n";   ## open/read training file
while ( !eof($fh) ) {
  my $data = <$fh>;
  chomp $data;
  $data =~ s/(\[\s)+|(\s\])+//g;   ## regex to remove brackets
  my @array = split/\s+/, $data;

  foreach my $e (@array) {
    if ($e =~ m/(.*)[\/]?\/(.*)/g) {
      $words_tags{$1}{$2}++;    ## add both to hash table, increment occurrence
      $word_set{$1}++;    ## add tag to tagset hash table, increment occurrence
    }
  }
}
close($fh);

open my $fh2, $ARGV[1] or die "Could not open file.\n";   ## open/read test file
while ( !eof($fh2) ) {
  my $data = <$fh2>;
  chomp $data;

  $data =~ s/(\[\s)+|(\s\])+//g;
  @words = split/\s+/, $data;   ## split line into tokens

  ## add each token to array of tokens
  foreach my $word (@words) {  push @tokens, $word;  }
}
close($fh2);

foreach my $token(@tokens) {  ## cycle through tokens
  my $max_tag;  ## initialize variable to hold max_tag
  if (exists $words_tags{$token}) {   ## if the token exists in words_tags hash
    while (my ($tag, $val) = each %{ $words_tags{$token} } ) {
      if (not defined $max_tag) {
        $max_tag = $tag;
      }
      if ($words_tags{$token}{$max_tag} < $val) {
        $max_tag = $tag;
      }
    }

    # rule 1: all numbers should be tagged as numbers (CD)
    if ($token =~ m/[0-9]/) {  $max_tag = "CD";  }

    if ($max_tag eq "NN") {
      ## rule 2: all nouns with capital letters should be proper nouns (NNP)
      if ($token =~ m/^[A-Z]/) {  $max_tag = "NNP";  }
      ## rule 3: all nouns with 's' should be plural nouns (NNS)
      if ($token =~ m/^[A-Za-z]s$/) {  $max_tag = "NNS";  }
    }

     # rule 4: hyphenated words are compound adjectives (JJ)
    if ($token =~ m/[0-9a-z]+-[0-9a-z]+/i) {  $max_tag = "JJ";  }

    ## rule 5: words that end in 'ly' should be adverbs (RB)
    if ($token =~ m/(.*)ly$/g) {  $max_tag = "RB";  }

    print STDOUT "$token/$max_tag\n";

  } else {
    $max_tag = "NN";
    if ($token =~ m/[0-9]/) {  $max_tag = "CD";  }  ## rule 1
    if ($token =~ m/^[A-Z]/) {  $max_tag = "NNP";  }   ## rule 2
    if ($token =~ m/^[A-Za-z]s$/) {  $max_tag = "NNS";  }  ## rule 3
    if ($token =~ m/[0-9a-z]+-[0-9a-z]+/i) {  $max_tag = "JJ"; }  ## rule 4
    if ($token =~ m/(.*)ly$/g) {  $max_tag = "RB";  }  ## rule 5

    print STDOUT "$token/$max_tag\n";
  }
}
