use strict;
use warnings;

use Test::More;
use Test::Differences;

use List::DoubleLinked;

use constant {
    NAME => 0,
    KEY => 1,
};

subtest 'splice' => sub {
    my $list1 = List::DoubleLinked->new(qw/foo bar baz/);
    my $list2 = List::DoubleLinked->new(qw/x y z/);

    eq_or_diff([$list1->flatten], [qw/foo bar baz/], 'List1 has three members: foo bar baz');
    eq_or_diff([$list2->flatten], [qw/x y z/], 'List2 has three members: x y z');

    # $list2->tail -> $list1->head 
    $list1->splice($list1->begin, $list2, $list2->end->previous);
    eq_or_diff([$list1->flatten], [qw/z foo bar baz/]);
    eq_or_diff([$list2->flatten], [qw/x y/]);

    # list1->tail -> $list2->tail
    $list2->splice($list2->end, $list1, $list1->end->previous);
    eq_or_diff([$list1->flatten], [qw/z foo bar/]);
    eq_or_diff([$list2->flatten], [qw/x y baz/]);

    # list1->head -> $list2->tail
    $list2->splice($list2->end, $list1, $list1->begin);
    eq_or_diff([$list1->flatten], [qw/foo bar/]);
    eq_or_diff([$list2->flatten], [qw/x y baz z/]);

    # list2->head -> $list1->head
    $list1->splice($list1->begin, $list2, $list2->begin);
    eq_or_diff([$list1->flatten], [qw/x foo bar/]);
    eq_or_diff([$list2->flatten], [qw/y baz z/]);

    $list1->push(qw/a b c/);
    $list2->push(qw/f g h/);
    eq_or_diff([$list1->flatten], [qw/x foo bar a b c/]);
    eq_or_diff([$list2->flatten], [qw/y baz z f g h/]);

    # list1 (bar) -> list2 (before 'f')
    $list2->splice($list2->begin->next->next->next, $list1, $list1->begin->next->next);
    eq_or_diff([$list1->flatten], [qw/x foo a b c/]);
    eq_or_diff([$list2->flatten], [qw/y baz z bar f g h/]);
    
    # list1 (foo) -> list2 (before 'g')
    my $entries = {foo => $list1->begin->next};
    $list2->splice($list2->begin->next->next->next->next->next, $list1, $entries->{foo});
    eq_or_diff([$list1->flatten], [qw/x a b c/]);
    eq_or_diff([$list2->flatten], [qw/y baz z bar f foo g h/]);
};

done_testing();
