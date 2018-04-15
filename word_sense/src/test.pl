#!/usr/bin/perl


# This is an application to determine the senses of the word 'line' being used
# using word sense disambiguation.  For this particular example the word being
# solved is 'line' and the senses are phone and product.
# The program runs as follows:
#       perl decision-list.pl line-train.txt line-test.txt my-decision-list.txt > my-line-answers.txt
# where line-train.txt is the training file, line-test.txt is the test file,
# my-decision-list.txt is an output of the decision list, and
# my-line-answers.txt is the output of the program.
#
# The program first grabs the files and opens each.  Then it builds a training
# corpus iterating through the training file, ignoring punctuation.  After that,
# it runs through the training corpus, collecting contexts at each instance of
# the word 'line'.  The contexts are: previous 2 words, previous word, next 2
# words, next word, and next and previous words.  It keeps track of each context
# and how many of each sense apply to each context.  Then it iterates through all
# of the contexts and builds a decision list based on the log-likelihood of each
# context and how strongly they correlate to each sense.  If a context only applies
# to one sense then that log-likelihood is defaulted to 99999 as it will be
# automatically chosen.  The list is ordered so that it can be iterated through
# descendingly.
#
#
# Then we iterate through the test file, collecting contexts and instance IDs for
# each instane of 'line'.  Then we check each context through the decision list
# and return the predicted sense of the context with the highest log-likelihood.
# Then each instance and sense is printed in a format that is equal to line-key.txt
#





use Data::Dumper;

#grab command line arguments for files
$file0 = @ARGV[0];
$file1 = @ARGV[1];
$file2 = @ARGV[2];


#open training file
open(my $train, '<:encoding(UTF-8)', $file0)
 or die "coult not open file '$file0' $!";

#open test file
open(my $test, '<:encoding(UTF-8)', $file1)
 or die "coult not open file '$file1' $!";

#open list file for writing
open(my $dlist, '>', $file2)
 or die "Could not open file '$file2' $!";

my @corpus;

#build corpus
while (my $row = <$train>) {
	chomp $row;
	$row =~s/[,'"@]|(--)//g;
# splits on white
	@line = split/ +/, $row;
#add to corpus
	push @corpus, @line;
}


my %decision;
my $sense;
%senses;



#gather senses and contexts
for my $i (0 .. $#corpus+1){
	$word = @corpus[$i];
	if ($word=~m/senseid=(.*)\/\>/){
		$sense = $1;
		$senses{$sense}++;
	}
	if ($word=~m/\<head\>line(s)?\<\/head\>/i){
		$p0 = "$corpus[$i-2] $corpus[$i-1] line";
		$p1 = "$corpus[$i-1] line $corpus[$i+1]";
		$p2 = "line $corpus[$i+1] $corpus[$i+2]";
		$p3 = "line $corpus[$i+1]";
		$p4 = "$corpus[$i-1] line";
		$decision{$p0}{$sense}++;
		$decision{$p1}{$sense}++;
		$decision{$p2}{$sense}++;
		$decision{$p3}{$sense}++;
		$decision{$p4}{$sense}++;
	}

}


#  build decision list
my @logl;
foreach my $ip (keys %decision){
	my $count = 0;
	my $csense = "";
	my $cval=0;
	while (my($key, $value) = each %{ $decision{$ip}}){
		if ($value > $cval){
			$cval = $value;
			$csense = $key;
		}
		$count++;
	}

	if ($count == 1){
		$entry = "99999||$csense||$ip";
		push @logl, $entry;
	}

	#get log likelihood of each context and corresponding sense
	if ($count == 2){
		my @tbd;
		while (my($key, $value) = each %{ $decision{$ip}}){
			push @tbd, $value;
		}
		$totes = @tbd[0] + @tbd[1];
		$prob0 = @tbd[0]/$totes;
		$prob1 = @tbd[1]/$totes;
		$loglike = abs(log($prob0/$prob1));
		if ($loglike == 0){
			$loglike = "0.000";
		}
		$entry = "$loglike||$csense||$ip";
		push @logl, $entry;
	}
}
#sort decision list by log-likelihood
@logl = reverse (sort @logl);

#print decision list
print $dlist Dumper (\@logl);



# get default sense based on highest frequency
$maxsense = 0;
$default = "";
while (my ($key, $value) = each %senses){
	if ($value>$maxsense){
		$maxsense = $value;
		$default = $key;
	}
}

print "default = $default\n";

#build test corpus
while (my $row = <$test>) {
	chomp $row;
	$row =~s/[,'"@]|(--)//g;
	@line = split/ +/, $row; # splits on white
	push @text, @line;
}


my $instance;
for my $i (0..$#text+1){
	$word = @text[$i];
	#get instance id
	if ($word=~m/id=line-n(.*)\>/){
		$instance = $1;
	}

	if ($word=~m/\<head\>line(s)?\<\/head\>/i){


		#gather each context
		$p0 = "$text[$i-2] $text[$i-1] line";
		$p1 = "$text[$i-1] line $text[$i+1]";
		$p2 = "line $text[$i+1] $text[$i+2]";
		$p3 = "line $text[$i+1]";
		$p4 = "$text[$i-1] line";
		my $curlog = -1;
		my $cursense = $default;

		#check each context
		for my $j (0..$#logl){
			@entry = split/\|\|/, @logl[$j];
			if (@entry[2] eq $p1){
				if (@entry[0] > $curlog){
					print "@entry[0]    $curlog\n";
					$curlog = @entry[0];
					$cursense = @entry[1];
					# print "\n$p1\n";
					# print "$curlog    $cursense  \n";
				}
				last;
			}
		}
		for my $j (0..$#logl){
			@entry = split/\|\|/, @logl[$j];
			if (@entry[2] eq $p2){
				if (@entry[0] > $curlog){
					print "@entry[0]    $curlog\n";

					$curlog = @entry[0];
					$cursense = @entry[1];
					# print "\n$p2\n";
					# print "$curlog    $cursense  \n";
				}
				last;
			}
		}
		for my $j (0..$#logl){
			@entry = split/\|\|/, @logl[$j];
			if (@entry[2] eq $p3){
				if (@entry[0] > $curlog){
					$curlog = @entry[0];
					$cursense = @entry[1];
					# print "\n$p3\n";
					# print "$curlog    $cursense  \n";
				}
				last;
			}
		}
		for my $j (0..$#logl){
			@entry = split/\|\|/, @logl[$j];
			if (@entry[2] eq $p4){
				if (@entry[0] > $curlog){
					$curlog = @entry[0];
					$cursense = @entry[1];
					# print "\n$p4\n";
					# print "$curlog    $cursense  \n";
				}
				last;
			}
		}
		for my $j (0..$#logl){
			@entry = split/\|\|/, @logl[$j];
			if (@entry[2] eq $p5){
				if (@entry[0] > $curlog){
					$curlog = @entry[0];
					$cursense = @entry[1];
					# print "\n$p5\n";
					# print "$curlog    $cursense  \n";
				}
				last;
			}
		}
		#print each sense
		#print "<answer instance=\"line-n$instance\" senseid=\"$cursense\"/>\n";
	}


}
