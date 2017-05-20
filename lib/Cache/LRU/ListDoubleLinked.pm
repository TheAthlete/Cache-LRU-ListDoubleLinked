package Cache::LRU::ListDoubleLinked;

use strict;
use warnings;
use feature 'say';

use List::DoubleLinked;
use Carp qw/carp croak/;
use Scalar::Util 'weaken';
use Storable qw/dclone freeze thaw/;

use constant {
    'KEY'   => 0,
    'VAL'   => 1,
    'EXP'   => 2,

    'SELF' => 0,
};

# Алгоритм замещения страниц (кэширования) LRU (Least recently used (Вытеснение давно неиспользуемых))

=head1 TODO

1. Реализовать быстрый алгоритм с помощью CircularBuffer из https://github.com/grinya007/2q
    - использовать циклический список
    - использовать предварительное создание списка размером $size
2. Реализовать быстрый алгоритм на C и C++ с использованием XS и Panda::XS

=cut

our $VERSION = '0.04';

sub new {
    my ($klass, $size) = @_;
    return bless {
        size => $size,
        entries => {}, # $key => $weak_valueref записи
        fifo    => List::DoubleLinked->new, # fifo queue of [ $key, $valueref ]
    }, $klass;
}

sub set {
    my ($self, $key, $value, $exp) = @_;
    croak 'Add key as first argument' unless defined $key;

    $exp = time() + $exp if $exp;

    if ($self->{entries}{$key}) {
        $self->{entries}{$key}->set([ $key, $value, $exp ]);
        return $value;
    }

    if ($self->{fifo}->size() == $self->{size}) {
        my $exp_key = $self->{fifo}->pop->[KEY];
        delete $self->{entries}->{$exp_key} if $self->{entries}->{$exp_key};
    }
    
    $self->{fifo}->unshift([ $key, $value, $exp ]);
    $self->{entries}{$key} = $self->{fifo}->begin; # сохраняем итератор

    $value;
}

sub get {
    my ($self, $key) = @_;
    croak 'Add key as first argument' unless defined $key;

    return undef unless my $iter = $self->{entries}{$key}; # получаем итератор

    my ($value, $exp) = @{$iter->get()}[VAL, EXP];

    if ($exp && $exp < time()) { # если время вышло, то удаляем ноду и выходим
        delete $self->{entries}{$key};
        $self->{fifo}->erase($iter);
        return undef; 
    }

    return $value if $iter == $self->{fifo}->begin;

    $self->{entries}{$key} = $self->{fifo}->splice($self->{fifo}->begin, $self->{fifo}, $self->{entries}{$key});

    $value;
}

sub remove {
    my ($self, $key) = @_;
    croak 'Add key as first argument' unless defined $key;

    if (my $iter = delete $self->{entries}{$key}) {
        my $value = $iter->get()->[VAL];
        $self->{fifo}->erase($iter);
        return $value;
    }
}

sub clear {
    $_[SELF]->remove($_) for keys %{ $_[SELF]->{entries} };
}

sub eviction_expired {
    my $self = shift;

    for my $key (keys %{$self->{entries}}) {
        my $iter = $self->{entries}{$key};
        my $exp = $iter->get()->[EXP];
        if ($exp && ($exp < time())) {
            delete $self->{entries}{$key};
            $self->{fifo}->erase($iter);
        }
    }
}

sub dump {
    my $self = shift;
    $self->eviction_expired();
    return freeze $self;
}

sub load {
    my ($class, $dump) = @_;
    croak 'Add dump as first argument' unless $dump;
    my $self = thaw $dump;
    $self->eviction_expired();
    return $self;
}

1;
__END__

=head1 NAME

Cache::LRU::ListDoubleLinked - a simple, implementation of LRU cache in pure perl with L<List::DoubleLinked>

=head1 SYNOPSIS

    use Cache::LRU::ListDoubleLinked;

    my $cache = Cache::LRU::ListDoubleLinked->new(
        size => $max_num_of_entries,
    );

    $cache->set($key => $value);

    $value = $cache->get($key);

    $removed_value = $cache->remove($key);

=head1 DESCRIPTION

Cache::LRU::ListDoubleLinked is a simple, implementation of an in-memory LRU cache in pure perl with List::DoubleLinked.
Based on the L<Cache::LRU> module.

=head1 FUNCTIONS

=head2 Cache::LRU::ListDoubleLinked->new($max_num_of_entries)

Creates a new cache object.  Takes size argument.  The only parameter currently recognized is the C<size> parameter that specifies the maximum number of entries to be stored within the cache object.

=head2 $cache->get($key)

Returns the cached object if exists, or undef otherwise.

=head2 $cache->set($key => $value)

Stores the given key-value pair.

=head2 $cache->remove($key)

Removes data associated to the given key and returns the old value, if any.

=head2 $cache->clear($key)

Removes all entries from the cache.

=head1 AUTHOR

Vyacheslav Koval

=head1 SEE ALSO

L<Cache::LRU>

L<Cache>

L<Cache::Ref>

L<Tie::Cache::LRU>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

See <http://www.perl.com/perl/misc/Artistic.html>

=cut
