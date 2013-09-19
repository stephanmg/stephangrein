#
#===============================================================================
#
#         FILE: 004_emoticons.t
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 09/18/2013 17:20:03
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 3;                      # last test to print

use MyApp;
use Dancer::Test;
use vars qw(%EMOTICONS);

my @strings = qw/:) :( :P/;
my $counter = 0;

foreach my $key (keys %EMOTICONS) {
    my $final_str = emoticonize($strings[$counter], %EMOTICONS);
    ok ($final_str eq $EMOTICONS{$key}, "final string should be equal to $EMOTICONS{$key}, but it is $final_str.");
    $counter++;
}
