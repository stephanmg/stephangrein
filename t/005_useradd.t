#
#===============================================================================
#
#         FILE: 005_useradd.t
#
#  DESCRIPTION: test user adding via email
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 09/30/2013 16:59:47
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 2;                      # last test to print

my $dummy = 1;

ok($dummy eq $dummy, "Dummy not dummy. Something strange happened.");

ok(! ($dummy ne $dummy), "Dummy not dummy. Something strange happened.");
