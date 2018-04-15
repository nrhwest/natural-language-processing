#!/usr/local/bin/perl

=begin comment
Created by Nathan West
Date : 01/25/18
Description : This program models the Eliza chatter bot program that was
              created by Joesph Weizenbaum in 1950. This program asks the user questions
              then responds accordingly.
Example : Eliza asks you a questions –> How are you feeling today?
          You should response like so –> I feel really happy
          Then Eliza will respond –> Why do you feel happy?
          ...
          You can continue conversing with Eliza until the user terminates the program
          by typing in quit, bye, or exit
Algorithm : Eliza prints out greeting, then prompts user for input. In an infinite loop,
            the input is set to lowercase, then checked for the containing phrases listed
            below such as; 'im feeling', 'i need/want', 'i am', etc. Once Eliza detects
            one of these phrases, she'll search for each token in an keywords and if it
            identifies a keyword, Eliza personalizes the response. If no phrase is found
            within the input, Eliza responds with a confused message.
=end comment
=cut

use warnings;
use feature qw(switch);  ## use for given-when (from StackOverflow)
no if $] >= 5.018, warnings => qw( experimental::smartmatch );

my $eliza = "[eliza]";
my $user = "[user]";

print "\n";

# short list of greetings sentences for Eliza to pick randomly from
my @greetings = ("what's on your mind?",
                 "how can I help you?",
                 "tell me what's going on?",
                 "how are you feeling today?");

# short list of goodbye sentences for Eliza to pick from randomly
my @goodbyes = ("Thank you for chatting with me!",
                "See you next time!",
                "Thank you and I hope everything works out for you.",
                "Good-bye. Come back and talk with me sometime.",
                "Well, that's our time. Let's meet again soon.");

# word bank for spotting keywords
my @keywords = ("sad", "happy", "great", "depressed", "lonely", "excited", "determined",
                "friendly", "angry", "pissed", "mad", "stupid", "afraid", "scared",
                "crave", "lonely", "play", "go", "die", "love",
                "family", "friends", "friend", "father", "mother", "funny", "power",
                "tight", "tired", "something", "see", "help", "save");

# short list of confused sentences for Eliza to pick from randomly
my @confused = ("I'm afraid I don't understand. Could you explain that again?",
                "That doesn't make any sense to me.",
                "What are you talking about?",
                "I didn't quite get that. Could you explain it?",
                "I don't understand, but maybe the answer lies within yourself.");

print "$eliza Hi, I'm your personal psychotherapist. What's your name?\n";
print "$user "; my $name = <STDIN>; chomp $name;  ## prompt user for input and trim new line

# regular expression to extract the user's name
$user = $name =~ m/([M|m]y name is\s|[I|i]'m\s|[I|i]m\s|[I|i] am\s)?([A-Za-z]*)/;
$user = $2;

print "$eliza Hi $user, $greetings[rand @greetings]\n";

my $input = "";
while (1) {

  print "\n[$user] ";
  $input = <STDIN>; chomp $input;  ## prompt user for input and trim new line
  $input = lc($input);  ## set the input to all lowercase strings

  ## given-when statement
  given ($input) {
    when ($input eq ("quit") or $input eq ("bye") or $input eq ("exit")) {
      print "\n$eliza $goodbyes[rand @goodbyes]\n";
      last;
    }

    ## regex that for sentences with 'im feeling'
    when ($input =~ m/([i'|i]+(\sa)?m feeling|i feel)\s(.*)/) {
      my $sentence = $3;  ## grabs everything after specified regex
      my $found = 0;  ## boolean value for if the word is found in keywords
      my @words = split(' ',$input);  ## split the input at whitespace
      foreach my $k(@keywords) {  ## cycle through list of keywords
        foreach my $word(@words) {  ## cycle through list of split words from inpuut
          if ($word eq $k) {  ## if a word equals a word in the keyword array
            $found = 1;
            $input =~ s/([i'|i]+(\sa)?m feeling|i feel)\s(.*)/Why do you feel $3?/;
            print "$eliza $input"; last;
          }  }  }
      if ($found ne 1) {
        $input = "Why do you feel $sentence?";
        print "$eliza $input";
      }
    }

    ## regex that for sentences with 'i need'
    when ($input =~ m/(.+)?i\sneed\s(.*)/) {
      my $sentence = $2;
      my $found = 0;
      my @words = split(' ',$input);
      foreach my $w(@keywords) {
        foreach my $word(@words) {
          if ($word eq $w) {
            $found = 1;
            $input =~ s/(.+)?i\sneed\s(.*)/When you think about it, do you really need $2?/;
            print "$eliza $input"; last;
          }  }  }
      if ($found ne 1) {
        $input = "When you think about it, do you really need $2?";
        print "$eliza $input";
      }
    }

    ## regex that for sentences with 'i want'
    when ($input =~ m/(.+)?i\swant\s(.*)/) {
      my $sentence = $2;
      my $found = 0;
      my @words = split(' ',$input);
      foreach my $w(@keywords) {
        foreach my $word(@words) {
          if ($word eq $w) {
            $found = 1;
            $input =~ s/(.+)?i\swant\s(.*)/Why do you want $2?/;
            print "$eliza $input"; last;
          }  }  }
      if ($found ne 1) {
        $input = "Why do you want $sentence?";
        print "$eliza $input";
      }
    }

    ## regex that for sentences with 'i am'
    when ($input =~ m/(i am\s)|(i'm|im)\s/) {
      my @words = split(' ',$input);
      my $sentence = $';
      my $found = 0;
      foreach my $w(@keywords) {
        foreach my $word(@words) {
          if ($word eq $w) {
            $found = 1;
            $input =~ s/(i am\s)|(i'm|im)\s(.*)/Tell me more about your $word?/;
            print "$eliza $input"; last;
          }  }  }
      if ($found ne 1) {
        $input = "Why do you think you're $sentence?";
        print "$eliza $input";
      }
    }

    ## regex that for sentences with 'i think or believe'
    when ($input =~ m/(.+)?i\sthink\s(.*)/) {
      my $sentence = $2;
      my $found = 0;
      my @words = split(' ', $input);
      foreach my $w(@keywords) {
        foreach my $word(@words) {
          if ($word eq $w) {  ## word spotting
            $found = 1;
            if ($word =~ m/e$/) {  ## once the word is found, check for last character
              $word =~ s/e$/ings/;  ## substitute end character with 'ing'
              my $output = "Why do you think you $word";
              print "$eliza $output"; last;
            } } } }
      if ($found ne 1) {
        $input = "Tell me more about your $sentence.";
        print "$eliza $input";
      }
    }

    ## regex for sentences that start with various spellings of 'yes'
    when ($input =~ m/yes|yeah|yea|yup/) {
      $input = "Well, you seem quite sure";
      print "$eliza $input";
    }

    ## regex for sentences that start with various spellings of 'yes'
    when ($input =~ m/no|nah|nope|nada\s(.+)/) {
      $input = "Please tell me more.";
      print "$eliza $input";
    }

    ## regex for sentences with 'i dont'
    when ($input =~ m/i don'?t\s/) {
      my $sentence = $';
      $input = "Why don't you $sentence?";
      print "$eliza $input";
    }

    ## regex for sentences with 'i cant'
    when ($input =~ m/i can'?t\s/) {
      my $sentence = $';
      $input = "Why can't you $sentence?";
      print "$eliza $input";
    }

    ## regex for sentences with 'my'
    when ($input =~ m/my\s([A-Za-z]*)\s(is|was|could|should|told|would)\s(.*)/) {
        my $sentence = $1;
        $input = "So, are there any issues with your $sentence?";
        print "$eliza $input";
    }

    ## regex for sentences with 'i like'
    when ($input =~ m/i like|love\s/) {
      my $sentence = $';
      $input = "Tell me more about your desires.";
      print "$eliza $input";
    }

    ## regex for sentences with 'i hate'
    when ($input =~ m/i\shate\s/) {
      my $sentence = $';
      $input = "Why do you hate $sentence?";
      print "$eliza $input";
    }

    ## default case for any confusing the user might input
    default {  print "$eliza $confused[rand @confused]";  }
  }
}
