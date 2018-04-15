#!/usr/local/bin/perl

=begin comment
Created by Nathan West
Date : 02/07/18

Description : The purpose of this program to randomly generate a number of
              sentences (entered by the user) based on an n gram model.

Example : Via the command-line, the user types in the number of
          n-grams to model, the number of $sentences to generate and 1..n files

          INPUT:   2 10 file1.txt file2.txt file3.txt ...
          OUTPUT:  for my can I better than you but my name.

Algorithm : The algorithm is heavily based on the lecture slides.
            First, it reads input via command line arguments. Then,
            sets the first 2 values to their corresponding variables. It reads all
            the files, removing uncommon/unnecessary punctation, then splits the line
            into an array of tokens. To calculate the ending points of our n-gram, we
            set a variable equal to the end of the sentence and another variable equal to
            the n-1 word in the sentence. We choose a word from the array, set it to lowercase
            then set that word as a main key for the hash table. We then add the n-1 $words
            that appear after the key into another hash table, then increment it's occurrence value.

=end comment
=cut

use strict;
use warnings;
use Data::Dumper qw(Dumper);

print "––––––––––––––––––––\nAuthor: Nathan West\n";
print "This program generates random sentences based on an n-gram model\n\n";

my $numArgs = $#ARGV + 1;     ## size of the arguments passed
my $n = $ARGV[0];             ## capture number of n-grams
my $sentences = $ARGV[1];     ## capture number of random generated sentences
my %hash = ();                ## intitialize empty n hash table
my %original = ();
my $word_count = 0;        ## intitalize empty n-1 hash table

while(<>) {

  chomp $_;
  for my $i (0..length($_) - 1) {  ## cycle through chars, removing uncommon punctation
    $_ =~ s/\-|\:|\;|\"+|\'+|\/|\\|\_|\#|\[|\]|\{|\}|\-|\(|\)|\$|\*|\%//g;
    $_ =~ s/\'//g;
  }

  # regex to parse main/common punctation and add start chars after ends of sentences
  ($_ =~ s/\.+/ . <s> /g); ($_ =~ s/\!+/ ! <s> /g); ($_ =~ s/\?+/ ? <s> /g); ($_ =~ s/\,+/ , /g);
  my @words = split/\s+/;  ## split the sentence into token;

  for my $i (0..$#words) {  ## cycle until size of array of words is reached
    $word_count++;
    my $j = $i + $n - 1;
    my $x = $i + $n - 2;

    my $key = $words[$i];     ## pick a word from the sentence
    $key = lc($key);          ## set the word to lowercase

    ## safety regex to take out all punctation for the keys
    for my $p (0..length($key)) {
      $key =~ s/\,|\.|\?|\!|\"+|\'+//g;
    }

    ## initialize n-gram model  |  initialize n-1 gram model
    my $ngram = "";
    my $kgram = "";

    ## if we've reached the end of the sentence, move on to next word
    if ($j > $#words) { next; }

    for my $k ($i..$j) {
      $ngram .= "$words[$k] ";    ## concatenate n-gram strings
      $ngram = lc($ngram);        ## set the n-gram string at lowercase
      $ngram =~ s/\-|\:|\;|\"+|\'+|\/|\\|\_|\#|\[|\]|\{|\}|\-|\(|\)|\$|\*|\%//g;
    }

    for my $y ($i..$x) {
      $kgram .= "$words[$y] ";    ## concatenate n-1 gram strings
      $kgram = lc($kgram);        ## set the n-1 gram string at lowercase
      $kgram =~ s/\-|\:|\;|\"+|\'+|\/|\\|\_|\#|\[|\]|\{|\}|\-|\(|\)|\$|\*|\%//g;
    }

    $hash{$key}{$ngram}++;  ## set the n-gram as the key and increment occurrence value
    $original{$key}{$kgram}++;  ## set the n-1 gram as the key and increment occurrence value

    my $frequency = $hash{$key}{$ngram} / $original{$key}{$kgram};  ## calculate token frequencies (n gram / n-1 gram)
    $hash{$key}{$ngram} = sprintf("%.4f", $frequency);
  }
}
print "––––––––––––––––––––\n";
print "word_count = $word_count\n";
#print Dumper(\%hash);

my $loop_count = 0;

START:
for my $i(0..$sentences) {  ## cycle through number of sentences
  my $sentence = "";  ## intitalize empty sentence for concatenate
  my $token = "";
  FIRST:
  foreach my $key (keys %hash) {
    $loop_count++;
    #print ("key = $key\n");
    my $rand_num = rand();  ## generate random number
    if ($key =~ m/<s>/) {  ## if the key matches the <s> tag
    #print "key = $key\n";
      while (my ($subkey, $val) = each %{ $hash{$key} } ) {  ## enter that key's keys
        if ($val >= $rand_num) {  ## compare frequencies with random value
          $subkey =~ s/^\S+\s*//;  ## capture last token before <s> tag
          $token = $subkey;
          $sentence = $sentence . $token;  ## concatenate string
          print "1ST IF –> sentence = $sentence\n";
          next FIRST;
        }
      }
    }
    #print "between ifs ––– key = $key\n";
    if ($key eq $token) {

      $loop_count++;
      #print "key = $key   ||||   token = $token\n";
      while (my ($subkey, $val) = each %{ $hash{$key} } ) {
      #  print "in key;token while loop –– subkey = $subkey\n";
        if ($val >= $rand_num) {
          print "subkey = $subkey\n";
          $token = $subkey;
          $token =~ s/\s(\w+)$//;
          $sentence = $sentence . ' ' . $subkey;
          print "2ND IF –> sentence = $sentence\n";
          if ($sentence =~ m/\.|\?|\!/) {
            print "$sentence\n";
            next START;
          } else {  next FIRST;  }
        }
      }
    }
  }
}

print ("loop_count = $loop_count\n");
