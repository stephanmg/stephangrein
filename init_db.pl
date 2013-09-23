#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: init_db.pl
#
#        USAGE: ./init_db.pl  
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
#      CREATED: 09/11/2013 12:03:59
#     REVISION: ---
#===============================================================================

use DBI;
use File::Slurp;
use Crypt::SaltedHash;

	my $dbh = DBI->connect("dbi:SQLite:dbname=./auth.sql") or
		die $DBI::errstr;
	my $schema = read_file('./schema.sql');
	$dbh->do($schema) or die $db->errstr;

	my $sql = 'insert into users (user, pass) values (?, ?)';
	my $sth = $dbh->prepare($sql) or die $db->errstr;

 my $csh = Crypt::SaltedHash->new(algorithm => 'SHA-1');
 $csh->add('test');
	$sth->execute("stephan", $csh->generate) or die $sth->errstr;
	$sql = 'insert into users (user, pass) values (?, ?)';
	$sth = $dbh->prepare($sql) or die $db->errstr;
	$sth->execute("tina", $csh->generate) or die $sth->errstr;
