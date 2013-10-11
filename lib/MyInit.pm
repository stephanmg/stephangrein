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

package MyInit;

use strict;
use warnings;

use DBI;
use File::Slurp;
use Crypt::SaltedHash;
use Exporter;
our @ISA= qw( Exporter );
our @EXPORT = qw( init_auth init_db );

# initialize auth db {{{
sub init_auth {
	my $dbh = DBI->connect("dbi:SQLite:dbname=./lib/auth.db") or
		die $DBI::errstr;
	my $schema = read_file('./lib/auth.sql');
	$dbh->do($schema) or die $dbh->errstr;

	my $sql = 'insert into users (user, pass) values (?, ?)';
	my $sth = $dbh->prepare($sql) or die $dbh->errstr;

 my $csh = Crypt::SaltedHash->new(algorithm => 'SHA-1');
 $csh->add('test');
	$sth->execute("stephan", $csh->generate) or die $sth->errstr;

	$sql = 'insert into users (user, pass) values (?, ?)';
	$sth = $dbh->prepare($sql) or die $dbh->errstr;

 $csh = Crypt::SaltedHash->new(algorithm => 'SHA-1');
 $csh->add('UgRAUU#2');
	$sth->execute("tina", $csh->generate) or die $sth->errstr;

	$sql = 'insert into users (user, pass) values (?, ?)';
	$sth = $dbh->prepare($sql) or die $dbh->errstr;

 $csh = Crypt::SaltedHash->new(algorithm => 'SHA-1');
 $csh->add('test');
	$sth->execute("admin", $csh->generate) or die $sth->errstr;
}
# }}}

# initialize database db {{{
sub init_db {

	my $db = DBI->connect("dbi:SQLite:dbname=./lib/database.db") or
		die $DBI::errstr;

	my $schema = read_file('./lib/schema_entry.sql');
	$db->do($schema) or die $db->errstr;
  $schema = read_file('./lib/schema_comments.sql');
	$db->do($schema) or die $db->errstr;
  $schema = read_file('./lib/schema_messages.sql');
  $db->do($schema) or die $db->errstr;
}
# }}}
