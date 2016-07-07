#!/usr/bin/perl -w

use strict;
use DBI;

my $username = "michael";
my $userpwd = "michael";

my $dbh = DBI->connect( 'dbi:Pg:dbname=michael;host=192.168.56.107', $username, $userpwd, {AutoCommit => 0, RaiseError => 1});

my $SEL = "select count(*) from t";
my $sth = $dbh->prepare($SEL);

print "If you see this, parse phase succeeded without a problem.\n";

$sth->execute();

print "If you see this, execute phase succeeded without a problem.\n";

END {
    $dbh->disconnect if defined($dbh);
}
