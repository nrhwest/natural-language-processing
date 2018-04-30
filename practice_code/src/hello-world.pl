#!/usr/bin/env perl

print "hello world!\n";

# three main variable types: scalars, arrays, and hashes

my $animal = "fossa";  ## scalars: which represent single value
my $result = 47;

print "i want a $animal\n";

my @animals = ("camel\n", "dog\n", "wolf\n", "wallaby\n");  ## arrays: list of values

print $animals[1];
print $animals[$#animals];  ## tells you last element

if (@animals < 5) {  ## if-statement - @animals gets size of array
	print $animals[3];
	} else {
	print $animals[0];
	}

my $guess;
my $rand_num = 7;

print "guess a number between 1-10 : ";
$guess = <STDIN>;
while ($guess != $rand_num) {
	if ($guess == $rand_num) {  ## could also use 'eq' for strings
		print "correct\n";
		last;  ## breaks out of loop
	} else {
		print "guess again\n";
		$guess = <STDIN>;  ## reads input from user
	}
}

my $long_string = "this is a very very very long string\n";
printf("long is at index = %d\n", index $long_string, "long");

my @abcs = ('a' .. 'z');
print join(": ", @abcs), "\n";

$animal = uc($animal);
print "$animal\n";
$animal = lc($animal);
print "$animal\n";
