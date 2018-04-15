#!/usr/local/bin/perl

=begin comment
Created by Nathan West
Date : 03/15/18

Description : This program calculates the accuracy and confusion matrix of the
              decision-list.pl file.

Example : Via the command-line, this program takes in the my-line-answers.txt, which
          was created from the decision-list.pl program and line-key.txt, which contains
          the actual senses from the line-test.txt file

          INPUT : perl scorer.pl my-line-answers.txt line-key.text
          OUTPUT : Accurary and confusion matrix

Algorithm : Both files are read through command-line arguments, parsed, and put
            into different arrays. The algorithm cycles through the array from line-key.txt
            and captures the instance id and compares they're senses to each to see if they match.
            The accurary is calculated, then printed and the confusion matrix is printed after.

=end comment
=cut

my @line_answers, @line_key;
my $count;
my %confusion_matrix;

open my $fh, $ARGV[0] or die "Could not open file.\n";
while (!eof($fh)) {
  my $data = <$fh>;
  chomp $data;
  $data =~ s/[>]//;  ## safety regex to extract gator bracket
  push @line_answers, $data;
}

open my $fh2, $ARGV[1] or die "Could not open file.\n";
while (!eof($fh2)) {
  my $data = <$fh2>;
  chomp $data;
  push @line_key, $data;
}

for my $i(0..$#line_key) {
  my $answer_id = $line_answers[$i];
  my $key_id = $line_key[$i];

  $answer_id =~ s/(.*)instance="(.*)"\s(.*)/$2/g;
  $key_id =~ s/(.*)instance="(.*)"\s(.*)/$2/g;

  if ($answer_id eq $key_id) {
    my $answer_sense = $line_answers[$i];
    my $key_sense = $line_key[$i];

    $answer_sense =~ s/(.*)senseid="(.*)"\/>/$2/g;
    $key_sense =~ s/(.*)senseid="(.*)"\/>/$2/g;

    if ($answer_sense eq $key_sense) {  $count++;  }
    $confusion_matrix{$key_sense}{$answer_sense}++;
  }
}

my $accuracy = ($count / $#line_key) * 100;   ##  calculation of the accuracy
$accuracy = sprintf("%.2f", $accuracy);   ## format accuracy
print STDOUT "\nThe accuracy of decision-list.pl is $accuracy percent\n";
print STDOUT "Confusion matrix: \n";

## using same operations from assignment 3 to print confusion matrix
my @senses;
foreach my $key (keys \%confusion_matrix) {
    push @senses, $key;
    print "$key |  ";
}

print "\n";

## using same operations from assignment 3 to print confusion matrix
for $n (0..$#senses) {
  for $m (0..$#senses) {
        if (exists $confusion_matrix{$senses[$n]}{$senses[$m]}) {
            print "$confusion_matrix{$senses[$n]}{$senses[$m]}";
        }
        else{  print "0";  }
        print " | ";
    }
    print "\n";
}
