use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Cache::LRU::ListDoubleLinked');
};

my $cache = Cache::LRU::ListDoubleLinked->new(3);

$cache->set(a => Foo->new());
is $Foo::cnt, 1;
$cache->set(a => 2);
is $Foo::cnt, 0;

$cache->set(b => Foo->new());
is $Foo::cnt, 1;
$cache->remove('b');
is $Foo::cnt, 0;

done_testing;

package Foo;

our $cnt = 0;

sub new {
    my $klass = shift;
    $cnt++;
    bless {}, $klass;
}

sub DESTROY {
    --$cnt;
}
