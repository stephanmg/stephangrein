#
#===============================================================================
#
#         FILE: 006_database.t
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/09/2013 16:47:15
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 1;                      # last test to print

use MyInit;
use Dancer::Test;

ok(init_db(), "Initializing database (database.db)  failed");
