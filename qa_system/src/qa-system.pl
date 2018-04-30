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

Algorithm : The algorithm reads in a question, then rewrites the question in a variety
            of different ways to answer the question. A search with the Wikipedia module
            locates the term and it's webpage, then cycles through the array of rewrites to
            find if a rewrite is found on the page. I could only got this feature to work for
            who and what questions, but for where and when questions, it finds the answers in
            the Infobox of the Wikipedia page. The question, raw information, and answer are
            print to the mylogfile.txt.

=end comment
=cut

# use strict;
# use warnings;
use WWW::Wikipedia;
use feature qw(switch);  ## use for given-when (from StackOverflow)
no if $] >= 5.018, warnings => qw( experimental::smartmatch );

print "This is a QA system created by Nathan West. It attempts to answer Who, What, When, and Where questions.\n";
print "Enter exit/quit/bye to quit the program.\n";

open my $logfile, '>', $ARGV[0] or die "Could not open file.\n";

my $input = "", $info, $answer;
my $q_reference, $tense, $term;
my $count = 0;

while ( 1 ) {

  print "\n=?> ";
  $input = <STDIN>;
  chomp $input;
  my @rewrites = ();  ## array of question rewrites

  given ($input) {
    when ($input eq ("quit") or $input eq ("bye") or $input eq ("exit")) {
      print "Goodbye, thank you!\n";
      last;
    }

    # regex for handling "who" questions
    when ($input =~ m/[Ww]ho['s]?\s(was|is|were|are)\s(.*)\?/g) {
      $q_reference = "who";
      $term = $2;

      if ($input =~ m/Nathan/) {
        print "=> That nigga.";
      }

      $rewrites[0] = "$term is";
      $rewrites[1] = "$term are";
      $rewrites[2] = "the $term are";
      $rewrites[3] = "the $term is";
      $rewrites[4] = "$term was";
      $rewrites[5] = "$term";

      if ($term =~ m/(.*)\s(.*)/) {
        $rewrites[6] = "$2 was";
        $rewrites[7] = "$2 is";
      }
    }

    # regex for handling "what" questions
    when ($input =~ m/[Ww]hat['s]?\s(was|is|were|are)\s(.*)\?/g) {
      $q_reference = "what";
      $term = $2;

      $rewrites[0] = "$term is";
      $rewrites[1] = "$term\'s are";
      $rewrites[2] = "$term was";
      $rewrites[3] = "$term is the";
      $rewrites[4] = "the $term is";
      $rewrites[5] = "the $term\'s are";
    }

    # regex for handling "where" questions
    when ($input =~ m/[Ww]here['s]?\s(is|are|was)\s(.*)\?/g) {
      $q_reference = "where";
      $term = $2;

      if ($term =~ m/(.*)\sborn/) {  $term = $1; }
    }

    # regex for handling "when" questions
    when ($input =~ m/[Ww]hen['s]?\s(is|was|are)\s(.*)\?/g) {
      $q_reference = "when";
      $term = $2;

      if ($term =~ m/(.*)\sborn/) {
       $rewrites[0] = "$1 was born";
       $rewrites[1] = "$1 was born in";
       $rewrites[2] = "$1\'s birthday";
       $rewrites[3] = "$1\'s birthday is";
       $rewrites[4] = "$1 was born on";
       $rewrites[5] = "$1 born";
       $term = $1;

       if ($term =~ m/(.*)\s(.*)/) {
         $rewrites[6] = "$2 was born";
         $rewrites[7] = "$2 was born on";
       }

      } else {
       $rewrites[0] = "$term was";
       $rewrites[1] = "the $term was";
       $rewrites[2] = "$term is";
       $rewrites[3] = "the $term is";
      }
    }

    when ($input =~ m/^(how|why)/) {
      print "=> Hmm.. I'm not sure about that one.\n";
      next;
    }
  }

  my $wiki = WWW::Wikipedia->new(clean_html => 1);
  my $result = $wiki->search($term);
  my $box = "", $text, $text_ref;
  my $full_text = "";

  if ($result) {
    $count++;  ## count the number of questions asked

    $text = $result->text();
    $full_text = $result->fulltext();
    $text =~ s/\'//g;
    $text_ref = $text;
    $text =~ s/\((.*?)\)//g;

    ## regex main inforation to search through
    $info = $text;
    $info =~ s/\n/ /g;
    $info =~ s/['=;\|]//g;
    $info =~ s/\<.*?\>//g;
    $info =~ s/{{(.*)}}//g;
    $info =~ s/\((.*?)\)//g;

    ## regex to grab just the Infobox
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

  ## statement to handle where questions
  if ($q_reference eq "where") {
    if ($input =~ m/born/) {  ## if input has born
      if ($box =~ m/birth_place\s?=?(.*?)\s[A-Za-z]+(\_[a-z]+)* =/) {
        $found = 1;
        $answer = "$term was born in $1";
        $answer =~ s/[<=>?'"–!]//g;
        print "=> $answer";
        print $logfile "ANSWER : $answer\n\n";
        next;
      }
    }
    if ($box =~ m/[Ll]ocation\s?=?(.*?)\s[A-Za-z]+(\_[a-z]+)* =/) {  ## finds location from Infobox
      $found = 1;
      $answer = "$term is located $1";
      $answer =~ s/[<=>?'"–!]//g;
      $answer =~ s/&nbsp/ /g;
      print "=> The $answer\n";
      print $logfile "ANSWER : $answer\n\n";
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
          $birth = $1;

          $answer = "$term was born on $birth";
          print "=> $answer\n";
          print $logfile "ANSWER : $answer\n\n";

          next;
        }
      }
    }
  }

  ## cycle through the array of rewrites, searching for each rewrite (who/what)
  for my $i(0..$#rewrites) {
    if ($info =~ m/$rewrites[$i]/) {
      $found = 1;
      $info =~ m/(.+?)(?=\.)/;
      $answer = $1;
      $answer =~ s/^\s+//;
      $answer =~ s/&nbsp/ /g;
      print "=> $answer\n";
      print $logfile "ANSWER : $answer\n\n";
      last;
    }
  }

  ## if the search is conducted, but no answer is found
  if ($found == 0) {
    print "=> Hmm.. I'm not sure about that.\n";
    print $logfile "ANSWER : Could not be produced.\n\n";
  }
}
