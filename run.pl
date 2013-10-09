#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: run.pl
#
#        USAGE: ./run.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/08/2013 14:28:21
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use Cwd;
use constant 'WEBAPP' => cwd() . '/bin/app.pl';
use IPC::System::Simple qw(system capture);

use lib './lib/';
use MyInit;

init_auth();
init_db();

exec(WEBAPP);
