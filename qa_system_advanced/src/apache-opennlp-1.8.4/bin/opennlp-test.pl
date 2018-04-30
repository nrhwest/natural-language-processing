#!/usr/local/bin/perl

use Data::Dumper;


my $text = "Thomas Jefferson (April 13 [O.S. April 2] 1743 – July 4, 1826) was an American Founding Father who was the principal author of the Declaration of Independence and later served as the third President of the United States from 1801 to 1809. Previously, he was elected the second Vice President of the United States, serving under John Adams from 1797 to 1801. A proponent of democracy, republicanism, and individual rights motivating American colonists to break from Great Britain and form a new nation, he produced formative documents and decisions at both the state and national level. He was a land owner and farmer.

Jefferson was primarily of English ancestry, born and educated in colonial Virginia. He graduated from the College of William & Mary and briefly practiced law, at times defending slaves seeking their freedom. During the American Revolution, he represented Virginia in the Continental Congress that adopted the Declaration, drafted the law for religious freedom as a Virginia legislator, and he served as a wartime governor (1779–1781). He became the United States Minister to France in May 1785, and subsequently the nation's first Secretary of State in 1790–1793 under President George Washington. Jefferson and James Madison organized the Democratic-Republican Party to oppose the Federalist Party during the formation of the First Party System. With Madison, he anonymously wrote the controversial Kentucky and Virginia Resolutions in 1798–1799, which sought to embolden states' rights in opposition to the national government by nullifying the Alien and Sedition Acts.";
my @output = `echo \"$text\" | ./opennlp TokenNameFinder en-ner-location.bin`;
#print STDERR "OUTPUT: $output\n";

# open my $file, '>', $ARGV[0] or die "Could not open file.\n";
# my $text = "Pierre Vinken , 61 years old , will join the board as a nonexecutive director Nov.
# 29 .";
#
# @results = `echo \"$text\" | opennlp TokenNameFinder en-ner-person.bin`;
#
# print "$output\n";
# print STDERR "OUTPUT: $output\n";

#print "OUTPUT: \n";
print Dumper (\@output);
