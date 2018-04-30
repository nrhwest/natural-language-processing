use strict;
use warnings;
use diagnostics;

use feature 'say';
use feature 'switch';
use v5.16;

print "hello world!\n";

my $name = 'Nate';
my ($age, $major, $school) = (23, 'computer science', 'VCU');

my $my_info = "$age majoring in $major at $school\n";
print "hello $name, you're $my_info";

my $more_info = <<"END";  ## multi-line string
\nYou're reading a string
variable that's very,
very long and on
multiple lines
END
say $more_info;  ## END counts as new line

# my $big_int = 18446744073709551614;  ## biggest int in perl
# print $big_int

my $one = 1;
my $two = 2;
say "$one $two";
($one, $two) = ($two, $one);  ## swaps values
say "$one $two";

say "4 + 7 = ", 4 + 7;
say "4 - 7 = ", 4 - 7;
say "4 * 7 = ", 4 * 7;
say "4 / 7 = ", 4 / 7;
say "4 % 7 = ", 4 % 7;
say "4 ** 7 = ", 4 ** 7;  ## 4 to the power of 7

say "random # between 0 - 10 = ", int(rand 11);
