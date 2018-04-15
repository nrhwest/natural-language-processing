#!/usr/local/bin/perl

=begin comment
Created by Nathan West
Date : 03/15/18

Description : This program seeks to identify the context in which a particular
              word is use. The target word is line and the two senses are product
              and phone.

              Accurary : 82.40%
              Confusion Matrix:
                                   phone | product
                                  -------|--------
                         phone    |  40  |  8
                        product   |  21  |  48

Example : Via the command-line, the user inputs the training file, the test file,
          an empty decision list file, and outputs to another file.

          INPUT : perl decision-list.pl line-train.txt line-test.txt my-decision-list.txt > my-line-answers.text
          OUTPUT : a non-empty my-line-answers.txt file

Algorithm : First, the algorithm builds the corpuses from training file, then creates
            the decision list and ranking the features of the words around the target word n
            (n-1, n-2, n+1, n+2, 1-n+1) and calculates the likelihood of the feature using
            the log( (S1|fi) / (S2|fi) ). The algorithm builds the corpus from the test file,
            then cycles through the corpus capturing the instance ID it's features
            around the target word. The algorithm then loops the decision list, calculating
            sense for each feature from the test file, then choosing the sense with
            the highest rank. The output is then printed to the my-line-answers.txt
            which is used as input for the scorer.pl file.

=end comment
=cut


use Data::Dumper qw(Dumper);

open my $fh_train, $ARGV[0] or die "Could not open file.\n";
my %decision_list, %sense_list;
my @train_set;

## read training file and build training corpus
while (!eof($fh_train)) {
  my $data = <$fh_train>;
  chomp $data;
  $data =~ s/[,'"]//g;
  my @line = split/\s+/, $data;
  push @train_set, @line;
}

## capture sense occurrence
for my $i (0..$#train_set) {
  if ($train_set[$i] =~ m/senseid=(.*)\/\>/) {  $sense = $1;  }

  ## build decision list by finding words around target word
  if ($train_set[$i] =~ m/<head>[lL]ine(s)?\</g) {
    $decision_list{"$train_set[$i-2] $train_set[$i-1] line"}{$sense}++;
    $decision_list{"$train_set[$i-1] line"}{$sense}++;
    $decision_list{"$train_set[$i-1] line $train_set[$i+1]"}{$sense}++;
    $decision_list{"line $train_set[$i+1]"}{$sense}++;
    $decision_list{"line $train_set[$i+1] $train_set[$i+2]"}{$sense}++;
  }
}

## create the my-decision-list text file
open my $fh_list, '>', $ARGV[2] or die "Could not open file.\n";
my @sense_scores = ();
foreach my $key (keys %decision_list) {
  my $max = 0, $count = 0;
  my $sense, $likelihood = "";
  while (my ($sub, $val) = each %{$decision_list{$key}}) {
    if ($max < $val) {
      $max = $val;
      $sense = $sub;
    }
    $count++;
  }

  ## if the context has 2 or less senses (product or phone)
  if ($count <= 2) {
    if ($count == 1) {
      $likelihood = "1 >> $key >> $sense";
      push @sense_scores, $likelihood;
      print $fh_list "$likelihood\n";
      next;
    }

    ## if context has 2 senses, perform following log likelihood calculations
    my @temp;
    while (my ($sub, $val) = each %{$decision_list{$key}})  {  push @temp, $val; }

    ## calculate log likelihood of senses
    my $total = $temp[0] + $temp[1];
    my $score = abs(log( ($temp[0] / $total) / ($temp[1] / $total) ));
    $likelihood = "$score >> $key >> $sense";
    push @sense_scores, $likelihood;

    print $fh_list "$likelihood\n";
  }
}

my @test_set;

## build corpus for the test file
open $fh_test, $ARGV[1] or die "Could not open file.\n";
while (!eof($fh_test)) {
  my $data = <$fh_test>;
  chomp $data;
  $data =~ s/[,'"]//g;
  my @line = split/\s+/, $data;
  push @test_set, @line;
}

my $ins_id = "";
for my $i(0..$#test_set) {

  ## capture the instance id
  if ($test_set[$i] =~ m/id=(.*)/g) {
    $ins_id = $1;

    if ($ins_id =~ m/line-n.art7}/) {  ## safety regex for the differently formatted instance id
      $ins_id .= " $test_set[$i+1] $test_set[$i+2]";
    }
  }

  my $f1, $f2, $f3, $f4, $f5;  ## grab the 5 features around target word
  if ($test_set[$i] =~ m/<head>[lL]ine(s)?\</g) {
    $f1 = "$test_set[$i-2] $test_set[$i-1] line";
    $f2 = "$test_set[$i-1] line";
    $f3 = "$test_set[$i-1] line $test_set[$i+1]";
    $f4 = "line $test_set[$i+1]";
    $f5 = "line $test_set[$i+1] $test_set[$i+2]";

    my $real_sense = "";

    $real_sense = find_sense(\@sense_scores, $real_sense, $f1);
    $real_sense = find_sense(\@sense_scores, $real_sense, $f2);
    $real_sense = find_sense(\@sense_scores, $real_sense, $f3);
    $real_sense = find_sense(\@sense_scores, $real_sense, $f4);
    $real_sense = find_sense(\@sense_scores, $real_sense, $f5);

    print "<answer instance=\"$ins_id\" senseid=\"$real_sense\"/>\n";
  }
}

## Cycle through the decision list for each feature
## to find the sense with the highest rank for the context.
sub find_sense {
  my @array = @{$_[0]};
  my $rl_sense = $_[1], $feature = $_[2];
  my $log_check = -1;

  foreach (@array) {
    my $context, $sense, $likelihood;
    if ($_ =~ m/(.*)\s>>\s(.*)\s>>\s(.*)/) {
      $likelihood = $1;
      $context = $2;
      $sense = $3;
    }
    if ($context eq $feature) {
      if ($likelihood > $log_check) {
        $log_check = $likelihood;
        $rl_sense = $sense;
      }
      last;
    }
  }

  return $rl_sense;
}
