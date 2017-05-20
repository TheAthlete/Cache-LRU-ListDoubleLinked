#!/usr/bin/env perl 
use strict;
use warnings;
use utf8;
use feature 'say';

use Test::More;
use Time::HiRes qw/time/;
use String::Random;

use FindBin qw/$Bin/;
use lib "$Bin/../../lib";
use Cache::LRU::ListDoubleLinked;

my $cache = Cache::LRU::ListDoubleLinked->new(20);

# initialize cache
note 'cache initialization...';
my ($exp, $count) = (3, 0); # exp -> 15 seconds
my $string_gen = String::Random->new;
for (map { $string_gen->randregex('\d\d\d') } 1..100) {
    chomp;
    $count++;
    $cache->set($_, ($_ x 100), (($count % 10) ? 0 : $exp )) unless $cache->get($_);
}
note 'done';

# say join ' ', map $_->[0], $cache->{fifo}->flatten;

$cache->set($_, ($_ x 100), $exp) for qw/7 9/;

ok ((my $dump = $cache->dump), 'cache is dumped');
ok ((my $load_cache = $cache->load($dump)), 'cache is loaded');

is $load_cache->get($_), $_ x 100, "get key '$_' from loaded cache" for qw/7 9/;

my $expired = $exp + 2;
note "sleep by $expired secs...";
sleep $expired;

ok (($dump = $cache->dump), 'cache now is dumped');
ok (($load_cache = $cache->load($dump)), 'cache now is loaded');

ok ! defined $load_cache->get($_), "key '$_' is evicted" for qw/7 9/;

done_testing();
