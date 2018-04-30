#!/usr/local/bin/perl

=begin comment
Created by Nathan West
Date : 03/31/18

Description : This program runs as a question-answering system which use Wikipedia
              to search for the terms and topics.

Example : Via the command-line, the user runs the program and the system a
          Who, What, Where, or When question. The system will respond with the answer
          to that question (hopefully).

          ALL QUESTIONS SHOULD BE TYPED IN THE FORM = Who is TERM?

          INPUT : Who is George Washington?
          OUTPUT : George Washington is the 1st President of the United States
                   and one of the Founding Fathers.

          ENHANCEMENTS:
          OpenNLP Tokenizer
          OpenNLP Sentence Detector

Algorithm : The algorithm reads in a question, then Tokenizes the term using the opennlp
            Tokenizer. A search with the Wikipedia module
            locates the term and it's webpage, then the OpenNLP Sentence Detector module
            breaks up all the sentences and the Tokenized term is search
            . I could only got this feature to work for
            who and what questions, but for where and when questions, it finds the answers in
            the Infobox of the Wikipedia page. The question, raw information, and answer are
            print to the mylogfile.txt.

=end comment
=cut

# use strict;
# use warnings;
use WWW::Wikipedia;
use Data::Dumper qw(Dumper);
use feature qw(switch);  ## use for given-when (from StackOverflow)
no if $] >= 5.018, warnings => qw( experimental::smartmatch );

print "This is a QA system created by Nathan West. It attempts to answer Who, What, When, and Where questions.\n";
print "Enter exit/quit/bye to quit the program.\n";

open my $logfile, '>', $ARGV[0]
  or die "Could not open file.\n";

my $testfile = "test.txt";

my $input = "", $info, $fullinfo ,$answer;
my $q_reference, $verb, $term, $stuff;
my @term_tokens;
my $count = 0;
my $confidence_score;

while ( 1 ) {

  print "\n=?> ";
  $input = <STDIN>;
  chomp $input;

  given ($input) {
    when ($input eq ("quit") or $input eq ("bye") or $input eq ("exit")) {
      print "Goodbye, thank you!\n";
      last;
    }

    ## handles all questions
    when ($input =~ m/(Who|What|Where|When)\s(is|are|was|were)\s(the|an?)?(.*)\?/i) {
      $q_reference = lc($1);
      $verb = $2;
      $stuff = $3;
      $term = $4;
      chomp $term;

      open my $scan, '>', $testfile or die "Could not open file.\n";

      ## scan the term into a temp file to send to OpenNLP module Tokenizer
      print $scan $term; close $scan;
      $output = `./opennlp TokenizerME en-token.bin < $testfile`;
    	@term_tokens = split/\s/, $output;
    }

    when ($input =~ m/^(how|why)/i) {
      print "=> Hmm.. I'm not sure about that one.\n";
      next;
    }
  }

  my $wiki = WWW::Wikipedia->new(clean_html => 1);
  my $result = $wiki->search($term);

  my $box = "", $text, $text_ref;
  my @extras;
  ## if result is false, continue to remove extra tokens until actual term is found
	while (!$result){
		$trim = pop @term_tokens;
		$term = join(' ',@term_tokens);

		$result = $wiki->search($term);
		push @extras, $trim;
		$extra = join(' ',@extras);
	}
	if ($extra){
		$termextrascore = ($#term_tokens+1)/($#term_tokens+$#extras+2);
    print "extrascore = $termextrascore\n";
	}

  my @sentences;

  if ($result) {
    $count++;  ## count the number of questions asked

    $text = $result->text();
    $text =~ s/\'//g;
    #$text_ref = $text;
    $text =~ s/\((.*?)\)//g;

    # ## regex main information to search through
    $info = $text;
    $info =~ s/\n/ /g;
    $info =~ s/['=;\|]//g;
    $info =~ s/\<.*?\>//g;
    $info =~ s/{{(.*)}}//g;
    $info =~ s/\((.*?)\)//g;

    $fullinfo = $result->fulltext();
    $fullinfo =~ s/\n/ /g;
    $fullinfo =~ s/\<.*?\>//g;
    #print "$fullinfo\n";


    open my $scan, '>', $testfile or die "Could not open file.\n";
    print $scan $info; close $scan;
    @sentences = `./opennlp SentenceDetector en-sent.bin < $testfile`;

    ## regex to grab just the Infobox for logfile output
    if ($text =~ m/{{((.|\n)*)}}/) {  $box = $1; }

    print $logfile "Q$count : $input\n";
    print $logfile "$box\n";
  } else {
    print "I'm not sure about that one.\n";
    next;
  }

  my $found = 0;  ## boolean variable for if answer is found
  $box =~ s/\n/ /g;
  $box =~ s/\|//g;

  if ($q_reference eq "who") {
    for my $i(0..$#sentences) {
      $sentences[$i] =~ s/\s\s+/ /g;
      if ($sentences[$i] =~ m/$term\s((was|is|are|were) [A-Za-z].*)/) {
        $found = 1;
        $answer = "$term $1";
        $answer =~ s/\s\s+/ /g;
        $answer =~ s/[<=>?'"–!]//g;
        print "=> $answer";
        print $logfile "ANSWER : $answer\n";

        $confidence_score = 1 - (($i + 1)/($#sentences + 1));

        last;
      }
    }
  }

  if ($q_reference eq "what") {
    for my $i(0..$#sentences) {
      $sentences[$i] =~ s/\s\s+/ /g;
      if ($sentences[$i] =~ m/$term\s((was|is|are|were) [A-Za-z].*)/) {
        $found = 1;
        $answer = "$term $1";
        $answer =~ s/\s\s+/ /g;
        $answer =~ s/[<=>?'"–!]//g;
        print "=> $answer";
        print $logfile "ANSWER : $answer\n";

        $confidence_score = 1 - (($i + 1)/($#sentences + 1));
        last;
      }
    }
  }

  if ($q_reference eq "where") {
    if ($input =~ m/born/) {  ## if input has born
      if ($box =~ m/birth_place\s?=?(.*?)\s[A-Za-z]+(\_[a-z]+)* =/) {
        $found = 1;
        $answer = "$term was born in $1";
        $answer =~ s/\s\s+/ /g;
        $answer =~ s/[<=>?'"–!]//g;
        print "=> $answer";
        print $logfile "ANSWER : $answer\n";

        $confidence_score = 1 - (($i + 1)/($#sentences + 1));
        next;
      }
    }
    if ($box =~ m/[Ll]ocation\s?=?(.*?)\s[A-Za-z]+(\_[a-z]+)* =/) {  ## finds location from Infobox
      $found = 1;
      $answer = "The $term is located $1";
      $answer =~ s/\s\s+/ /g;
      $answer =~ s/[<=>?'"–!]//g;
      $answer =~ s/&nbsp/ /g;
      print "=> $answer\n";
      print $logfile "ANSWER : $answer\n";

      $confidence_score = 1 - (($i + 1)/($#sentences + 1));
      next;
    }
  }

  ## statement to handle when questions
  if ($q_reference eq "when") {
    my $last_name = "";
    if ($input =~ m/born/) {
      if ($term =~ m/(.*)\s(.*)/) { $last_name = $2; }
      if ($text_ref =~ m/$last_name\s(.*)\s(is|was)/) {
        my $birth = "$1";
        $birth =~ s/[)({})]//g;
        if ($birth =~ m/(.*)(?=\&)/ or $birth =~ m/born\s(.*)/) {
          $found = 1;
          $birth = $1;
          $answer = "$term was born on $birth";
          $answer =~ s/\s\s+/ /g;
          print "=> $answer\n";
          print $logfile "ANSWER : $answer\n";

          $confidence_score = 1 - (($i + 1)/($#sentences + 1));
          next;
        }
      }
    }
  }
  
  $confidence_score = $confidence_score * $termextrascore;
  print $logfile "Confidence Score = $confidence_score\n\n";

  ## if the search is conducted, but no answer is found, search through the fulltext
  if ($found == 0) {
    print "=> Hmm.. I'm not sure about that.\n";
    print $logfile "ANSWER : Could not be produced.\n\n";
  }
}
