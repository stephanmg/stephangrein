#
#===============================================================================
#
#         FILE: 009_disconnect_db.t
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/14/2013 12:50:21
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 4;                      # last test to print

use MyApp 'connect_db';
use MyApp 'disconnect_db';
use Dancer::Test;

use constant DATABASE => 'database.db';
use constant AUTH => 'auth.db';

my $dbh_db   = connect_db(DATABASE);
my $dbh_auth = connect_db(AUTH);

ok (defined(dbh_db), "DBH database not defined, i. e. connect failed.");
ok (defined(dbh_auth), "DBH auth not defined, i. e. connect failed.");

ok (disconnect_db($dbh_db), "Could not disconnect from db database.");
ok (disconnect_db($dbh_auth), "Could not disconnect from db auth.");
