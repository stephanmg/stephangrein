use strict;
use warnings;

use Test::More tests => 8;                      # last test to print
use MyApp;
use Dancer::Test;

# routes to check
my @routes=qw(CV About Publications Blog Blog/login Blog/logout Blog/useradd Blog/recover_password);

# check each route
my $route;
foreach (@routes) {
    $route = "/" . $_;
    route_exists [GET => $route], "Route >> $route << does exist.";
}
