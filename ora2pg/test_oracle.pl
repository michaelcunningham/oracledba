#!/usr/bin/perl -w

use strict;
use DBI;

my $dbh = DBI->connect( "dbi:Oracle:fmd", "tag", "zx6j1bft" ) || die( $DBI::errstr . "\n" );

$dbh->{AutoCommit}    = 0;
$dbh->{RaiseError}    = 1;
$dbh->{ora_check_sql} = 0;
$dbh->{RowCacheSize}  = 16;

my $SEL = "select count(*) from ttable_audit";
my $sth = $dbh->prepare($SEL);

print "If you see this, parse phase succeeded without a problem.\n";

$sth->execute();

print "If you see this, execute phase succeeded without a problem.\n";

END {
    $dbh->disconnect if defined($dbh);
}
