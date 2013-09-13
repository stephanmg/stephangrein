use strict;
use warnings;

use Test::More tests => 6;                      # last test to print
use MyApp;
use Dancer::Test;

# routes to check
my @routes=qw(CV About Publications Blog Blog/login Blog/logout);

# check each route
my $route;
foreach (@routes) {
    $route = "/" . $_;
    route_exists [GET => $route], "Route >> $route << does exist.";
 #   reponse_status_is [GET => $route], 200, "Response status is 200.";
}
