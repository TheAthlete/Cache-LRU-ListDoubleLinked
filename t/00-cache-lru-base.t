use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok("Cache::LRU::ListDoubleLinked");
};

my $cache = Cache::LRU::ListDoubleLinked->new(3);

ok ! defined $cache->get('a'), 'a is not defined';

is $cache->set(a => 1), 1, "set a => 1"; # a
is $cache->get('a'), 1, 'get a == 1'; # a

is $cache->set(b => 2), 2, 'set b => 2'; # b a
is $cache->get('a'), 1, 'get a == 1'; # a b
is $cache->get('b'), 2, 'get b == 2'; # b a

is $cache->set(c => 3), 3, 'set c => 3'; # c b a
is $cache->get('a'), 1, 'get a == 1'; # a c b
is $cache->get('b'), 2, 'get b == 2'; # b a c
is $cache->get('c'), 3, 'get c == 3'; # c b a

is $cache->set(b => 4), 4, 'set b => 4'; 
is $cache->get('a'), 1, 'get a == 1';
is $cache->get('b'), 4, 'get b == 4';
is $cache->get('c'), 3, 'get c == 3';

my $keep;
is +($keep = $cache->get('a')), 1, 'the order is now a => c => b'; # the order is now a => c => b
is $cache->set(d => 5), 5, 'set d => 5';
is $cache->get('a'), 1, 'get a == 1';
ok ! defined $cache->get('b'), 'b is not defined';
is $cache->get('c'), 3, 'get c == 3';
is $cache->get('d'), 5, 'the order is now d => c => a'; # the order is now d => c => a

is $cache->set('e', 6), 6, 'set e => 6';
ok ! defined $cache->get('a'), 'a is not defined';
ok ! defined $cache->get('b'), 'b is not defined';
is $cache->get('c'), 3;
is $cache->get('d'), 5;
is $cache->get('e'), 6;

is $cache->remove('d'), 5;
is $cache->get('c'), 3;
ok ! defined $cache->get('d');
is $cache->get('e'), 6;

$cache->clear;
ok ! defined $cache->get('c');
ok ! defined $cache->get('e');

done_testing;
