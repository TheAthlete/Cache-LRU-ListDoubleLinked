use strict;
use warnings;

use Test::More;
use Test::Differences;

use Cache::LRU::ListDoubleLinked;

my @data = (
    [0, [qw/0    /]],
    [3, [qw/3 0  /]],
    [1, [qw/1 3 0/]],
    [2, [qw/2 1 3/]],
    [3, [qw/3 2 1/]],
    [2, [qw/2 3 1/]],
    [0, [qw/0 2 3/]],
    [1, [qw/1 0 2/]],
    [0, [qw/0 1 2/]],
    [1, [qw/1 0 2/]],
    [3, [qw/3 1 0/]],
    [0, [qw/0 3 1/]],
    [2, [qw/2 0 3/]],
    [3, [qw/3 2 0/]],
    [1, [qw/1 3 2/]],
);

subtest 'LRU cache implementation' => sub {
    my $cache = Cache::LRU::ListDoubleLinked->new(3);

    for my $item (@data) {
        $cache->set($item->[0], ($item->[0] + 5)) unless $cache->get($item->[0]);
        eq_or_diff [map $_->[0], $cache->{fifo}->flatten], $item->[1], "$item->[0], [@{$item->[1]}]";
    }
};

done_testing();

