#
#===============================================================================
#
#         FILE: MyPass.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/01/2013 15:53:05
#     REVISION: ---
#===============================================================================

package MyPass;

use strict;
use warnings;

use Exporter;
our @ISA= qw( Exporter );
our @EXPORT = qw( %mail );
#
our %mail = 
(
   user => 'grein@informatik.uni-frankfurt.de',
   password => ''
);
