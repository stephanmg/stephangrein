#
#===============================================================================
#
#         FILE: 004_emoticons.t
#
#  DESCRIPTION: testing emoticons subroutines
#
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: stephan (stephan@syntaktischer-zucker.de) 
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

my @strings = qw/:) :( :P/;
my $counter = 0;

foreach my $key (keys %EMOTICONS) {
    foreach my $str (@strings) {
        my $final_str = emoticonize($str, \%EMOTICONS);
        (my $clean_key = $key) =~ s!\\!!g;

        if ($clean_key eq $str) {
           ok ($final_str eq $EMOTICONS{$key}, "final string should be equal to $EMOTICONS{$key}, but it is $final_str.");
         }
        $counter++;
    }
}

