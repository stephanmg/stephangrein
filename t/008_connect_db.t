#
#===============================================================================
#
#         FILE: 008_connect_db.t
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/10/2013 13:44:43
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 2;                      # last test to print

use MyApp 'connect_db';
use Dancer::Test;

use constant DATABASE => 'database.db';
use constant AUTH => 'auth.db';

ok(defined(connect_db(DATABASE)), "Could not connect to database db");
ok(defined(connect_db(AUTH)), "Could not connect to auth db.");
