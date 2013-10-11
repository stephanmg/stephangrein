use strict;
use warnings;

use Test::More tests => 11;                      # last test to print
use MyApp;
use Dancer::Test;

# routes to check
my @routes=qw(CV About Publications Blog Blog/login Blog/logout Blog/useradd Blog/recover_password Blog/message/dummy Blog/delete_message/dummy, Blog/reply_message/dummy);

# check each route
my $route;
foreach (@routes) {
    $route = "/" . $_;
    route_exists [GET => $route], "Route >> $route << does exist.";
}
