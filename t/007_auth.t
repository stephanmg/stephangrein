#
#===============================================================================
#
#         FILE: 007_auth.t
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/09/2013 16:47:24
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 1;                      # last test to print

use MyInit;
use Dancer::Test;

ok(init_auth(), "Initializing auth (auth.db) failed");
