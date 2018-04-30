#Kyle Sutherland
#CMSC 416
#5/3/17
#Assignment 6

#This program runs in the format:
#     perl qa-system.pl mylogfile.txt
# where mylogfile.txt is an output log file

#This is a question answering system.  It uses wikipedia to search for topics
#and answer questions.  Questions should come in the format:
#    "Who|What|When|Where _____________?"
#It then splits the question into pieces and polls wikipedia to return the
#answer.  It captures the type of question to find out what to search the
#wikipedia article for, comes up with an answer based on what the question type
#and any extra information, then the answer is and then reformats the answer into
#natural language.  The answer is then printed to STDOUT.  The question, search term, extras,
#wiki text, chosen sentence, concluded answer, and confidence are all recorded
#in the log file.  Logic dictates that the most pertinent information in a
#wikipedia article is found towards the beginning, so the first answer returned
#is chosen as the response.


#this qa system is designed to use enhancements to query reformulation and
#answer composition as follows

#query
#1	Tokenize query after pulling the question word and the 'is' word
#2	backoff model for searching.  search for words and pop off the final
#		word until the search returns a hit;

#answer
#1	Sentence Detection through the articles
#2	NER to determine answers for question types, returning the
#		correct type of word as the answer

#The confidence of the answer is determined by how many words are popped off of
#the query and how far down the article the answer is found.  Answers found in
#the infobox are estimated at 90% confidence.


#usages
use WWW::Wikipedia;
use Data::Dumper;
use open ':std', ':encoding(UTF-8)';
my $perl     = $^X;

#initialize wiki variable
my $wiki = WWW::Wikipedia->new();
my $result;

#open log file for writing
$file = @ARGV[0];
open(my $logf, '>', $file)
 or die "Could not open file '$file' $!";

$tempfile = "test.txt";


#prompt user
print "This is a QA system by Kyle Sutherland. It will try to answer questions that start with Who, What, When or Where. Enter 'exit' to leave the program.\n";
#get initial question
$line = <STDIN>;
chomp $line;


################################################################################

while ($line ne "exit"){
	#initialize variables
	my $term;
	my $qtype = "default";
	my $extra;
	my $ans;
	my $athe;
	my $tense;
	my @extraarr;
	my $fulltext;
	my $iswas;
	my $savesent;
	my $confidence = 0;

	#grab search material and determine question type
	if($line=~m/(Who|What|When|Where) (was|is|were|are) (the |an? )?(.*)\?/i){
		$qtype = lc($1);
		$athe = $3;
		$term = $4;
		$tense = $2;
		$iswas = lc($2);
	}


	#capitalize article for answer return
	$athe = ucfirst($athe);
	#remove posessives
	$term =~s/(.*)'s/$1/;

	########################################################################


	#tokenizer
	open(my $temptext, '>', $tempfile) or die "Could not open file 'wikitext.txt' $!";
	print $temptext $term;
	close $temptext;
	$tokens = `./opennlp TokenizerME en-token.bin < $tempfile`;
	#trim opennlp extras
	$tokens =~s/(.*)\nExecution time(.*)\n/$1/;
	@tokenarr = split/ /, $tokens;

	print Dumper \@tokenarr;
	my @extraarr;

	print "$term";


  #
	# ########################################################################
  #
	# #try search for term.  if no term found, back off and save extra information
	# $result = $wiki->search($term);
	# while (!$result){
	# 	#pop last token
	# 	$trim = pop @tokenarr;
	# 	$term = join(' ',@tokenarr);
	# 	#try to search
	# 	$result = $wiki->search($term);
	# 	#save extras as string and array
	# 	push @extraarr, $trim;
	# 	$extra = join(' ',@extraarr);
	# }
	# if ($extra){
	# 	$termextrascore = ($#tokenarr+1)/($#tokenarr+$#extraarr+2);
	# }
  #
  #
	# ########################################################################
  #
  #
	# #load text for simple questions, fulltext for longer questions
	# if($result){
	# 	$phold = $result->text();
	# 	#trim newlines and carrots
	# 	$phold =~s/\n/ /g;
	# 	$phold=~s/\<.*?\>//g;
	# 	$text = $phold;
  #
	# 	$phold = $result->fulltext();
	# 	#trim newlines and carrots
	# 	$phold =~s/\n/ /g;
	# 	$phold=~s/\<.*?\>//g;
	# 	$fulltext = $phold;
	# }
	# #fail if search doesn't return
	# else {
	# 	print "I'm sorry, I don't know.\n";
	# 	$line = <STDIN>;
	# 	chomp $line;
	# 	next;
	# }
  #
  #
  #
	# ########################################################################
  #
  #
	# #pull answer based on type of question
  #
	# if (!$extra){
	# #who and what questions are the same
	# 	if ($qtype eq "who"){
	# 		#sentence detection:
	# 		open(my $wikitext, '>', $tempfile) or die "Could not open file 'wikitext.txt' $!";
	# 		print $wikitext "$text";
	# 		close $wikitext;
	# 		@arr = `opennlp SentenceDetector en-sent.bin < $tempfile`;
  #
	# 		for my $i (0..$#arr+1){
	# 			#grab the first sentence with 'is' words
	# 			if (@arr[$i]=~m/ ((was|were|is|are) [a-z].*)/i){
	# 				$confidence = 1-(($i+1)/($#arr+1));
	# 				$ans = $1;
	# 				last;
	# 			}
	# 		}
	# 		if ($ans){
	# 			$printout =  "$athe$term $ans.\n";
	# 		}
	# 	}
	# 	elsif ($qtype eq "what"){
	# 		#sentence detection:
	# 		open(my $wikitext, '>', $tempfile) or die "Could not open file 'wikitext.txt' $!";
	# 		print $wikitext "$text";
	# 		close $wikitext;
	# 		@arr = `opennlp SentenceDetector en-sent.bin < $tempfile`;
  #
	# 		for my $i (0..$#arr+1){
	# 			#grab the first sentence with 'is' words
	# 			if (@arr[$i]=~m/ ((was|were|is|are) [a-z].*)/i){
	# 				$confidence = 1-(($i+1)/($#arr+1));
	# 				$ans = $1;
	# 				last;
	# 			}
	# 		}
	# 		if ($ans){
	# 			$printout =  "$athe$term $ans.\n";
	# 		}
	# 	}
	# 	#answer where questions
	# 	elsif ($qtype eq "where"){
	# 		#remove bars from infobox
	# 		$text=~s/\|//g;
	# 		#get location from infobox if available
	# 		if ($text=~m/location *= *(.*?) *[a-z]+(\_[a-z]+)* *=/i){
	# 			$ans ="in $1";
	# 			$confidence = .90;
  #
	# 		}
	# 		#else look through the text
	# 		else{
	# 			#sentence detection:
	# 			open(my $wikitext, '>', $tempfile) or die "Could not open file 'wikitext.txt' $!";
	# 			print $wikitext "$text";
	# 			close $wikitext;
	# 			@arr = `opennlp SentenceDetector en-sent.bin < $tempfile`;
	# 			#@arr=split/\. |\.(svg|png|jpeg)/,$text;
	# 			for my $i (0..$#arr+1){
	# 				if (@arr[$i]=~m/ in ([a-z].*)/i){
	# 					$ans = "in $1";
	# 					$confidence = 1-(($i+1)/($#arr+1));
	# 					last;
	# 				}
	# 			}
	# 			for my $i (0..$#arr+1){
	# 				if (@arr[$i]=~m/ located ([a-z].*)/i){
	# 					$ans = $1;
	# 					$confidence = 1-(($i+1)/($#arr+1));
	# 					last;
	# 				}
	# 				}
  #
  #
	# 		}
	# 		#print if answer
	# 		if ($ans){
	# 			$printout = "$athe$term is located $ans.\n";
	# 		}
	# 	}
	# 	#answer when questions
	# 	elsif ($qtype eq "when"){
	# 		#remove bars from infobox
	# 		$text=~s/\|//g;
	# 		#check infobox for date
	# 		if ($text=~m/date = +(.*?) +[a-z]+(\_[a-z]+)* =/i){
	# 			$ans = $1;
	# 			$confidence = .90;
	# 		}
  #
	# 		#fix tense based on original question
	# 		if ($ans){
	# 			if ($tense eq ("are"|"is")){
	# 				$printout = "$term is $ans.\n";
	# 			}else{
	# 				$printout = "$term was $ans.\n";
	# 			}
	# 		}
	# 	}
  #
  #
  #
	# }
  #
  #
	# #for more complicated questions
	# elsif($extra){
	# 	#NER followed by sentence detection on full text
	# 	open(my $wikitext, '>', $tempfile) or die "Could not open file 'wikitext.txt' $!";
	# 	print $wikitext "$fulltext";
	# 	close $wikitext;
	# 	$outputfile = "ttemp.txt";
	# 	$output = `opennlp TokenNameFinder en-ner-date.bin  en-ner-person.bin en-ner-location.bin< $tempfile > $outputfile`;
	# 	@arr = `opennlp SentenceDetector en-sent.bin < $outputfile`;
  #
	# 	#save sentence for debugging
	# 	$savesent = "";
  #
	# 	#check sentences for trigger tags for each question type and
	# 	#save answers.  All types follow the same algorithm.
  #
	# 	#check question type
	# 	if($qtype eq "when"){
	# 		#check all extras
	# 		for my $i (0..$#extraarr+1){
	# 			#check all sentences
	# 			for my $j (0..$#arr+1){
	# 				#look for extra
	# 				if (@arr[$j]=~m/@extraarr[$i]/i){
	# 					#look for tag
	# 					if (@arr[$j]=~m/\<START:date\>(.*?)\<END\>/i){
	# 						#save sentence for debugging
	# 						$savesent = @arr[$j];
	# 						#save and format answer
	# 						$ans = $1;
	# 						$printout = "$term $iswas $extra $ans.\n";
	# 						#quit when answer is found
	# 						$confidence = 1-(($j+1)/($#arr+1));
	# 						last;
	# 					}
	# 				}
  #
	# 			}
	# 		}
  #
	# 	}
	# 	elsif($qtype eq "who"){
	# 		for my $i (0..$#extraarr+1){
	# 			for my $j (0..$#arr+1){
	# 				if (@arr[$j]=~m/@extraarr[$i]/i){
	# 					if (@arr[$j]=~m/\<START:person\>(.*?)\<END\>/i){
	# 						$savesent = @arr[$j];
	# 						$ans = $1;
	# 						$printout = "$term $extra $iswas $ans.\n";
	# 						$confidence = 1-(($j+1)/($#arr+1));
	# 						last;
	# 					}
	# 				}
  #
	# 			}
	# 		}
  #
	# 	}
	# 	elsif($qtype eq "where"){
	# 		for my $i (0..$#extraarr+1){
	# 			for my $j (0..$#arr+1){
	# 				if (@arr[$j]=~m/@extraarr[$i]/i){
	# 					if (@arr[$j]=~m/\<START:location\>(.*?)\<END\>/i){
	# 						$savesent = @arr[$j];
	# 						$ans = $1;
	# 						$printout = "$term $extra $iswas at $ans.\n";
	# 						$confidence = 1-(($j+1)/($#arr+1));
	# 						last;
	# 					}
	# 				}
  #
	# 			}
	# 		}
  #
	# 	}
	# 	elsif($qtype eq "what"){
	# 		for my $i (0..$#extraarr+1){
	# 			for my $j (0..$#arr+1){
	# 				if (@arr[$j]=~m/@extraarr[$i]/i){
	# 					if (@arr[$j]=~m/ ((was|were|is|are) [a-z].*)/i){
	# 						$savesent = @arr[$j];
	# 						$ans = $1;
	# 						#trim out tags
	# 						$ans=~s/\<START:[a-z]+\>(.*?)\<END\>/$1/gi;
	# 						$printout = "$term $extra $ans.\n";
	# 						$confidence = 1-(($j+1)/($#arr+1));
	# 						last;
	# 					}
	# 				}
  #
	# 			}
	# 		}
	# 	}
	# 	$confidence = $confidence * $termextrascore;
	# }
  #
	# ########################################################################
  #
	# #if no answer was found or answer is gibberish
	# if ((!$ans)||($printout=~m/[{}=]/i)){
	# 	print "I'm sorry, I don't know.\n";
	# }
	# #if answer was found
	# else{
	# 	print $printout;
	# }
  #
  #
	# ########################################################################
	# #print to log file
  #
	# print $logf "Question:  $line\nSearch Term:  $term\nExtras:  $extra\nAnswer:";
	# print $logf "  $printout\nConfidence:  $confidence\n\n Saved Sentence:  ";
	# print $logf "$savesent\nText:\n$text\n\n";
	# print $logf "*********************************************************************\n\n";



	########################################################################
	#start over
	$line = <STDIN>;
	chomp $line;
}
