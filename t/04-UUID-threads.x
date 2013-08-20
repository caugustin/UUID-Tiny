#!/usr/bin/perl
# Initially created by Michael G. Schwern <schwern@pobox.com>

use strict;
use warnings;

my $Have_Threads;
BEGIN {
    $Have_Threads = eval {
        require threads;
        require threads::shared;
        threads::shared->import;
        1;
    };
    require Test::More;
    Test::More->import;
}

plan skip_all => "Needs threads" unless $Have_Threads;

use UUID::Tiny qw(:std);

my $Num_Threads = 5;

my %uuids : shared;
$uuids{create_uuid_as_string(UUID_V4)}++;

for(1..$Num_Threads) {
    threads->create(sub {
        $uuids{create_uuid_as_string(UUID_V4)}++;
    });
}

diag "All threads started";
$_->detach for threads->list;
diag "All threads joined";

is keys %uuids, $Num_Threads + 1, "All v4 uuids should be unique per thread";

done_testing;
