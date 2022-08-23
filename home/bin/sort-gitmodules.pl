#!/usr/bin/perl
# vi: et sts=4 sw=4 ts=4
package main;
use strict;
use warnings;

=pod

=head1 NAME

sort-gitmodules.pl - Sort Git module files

=head1 SYNOPSIS

B<sort-gitmodules.pl> < I<FILE1> > I<FILE2>

B<sort-gitmodules.pl> < .gitmodules > .gitmodules.sorted

=head1 COPYRIGHT

Copyright (C) 2020-2022 Dan Church S<E<lt>amphetamachine@gmail.comE<gt>>

License GPLv3: GNU GPL version 3.0 (L<https://www.gnu.org/licenses/gpl-3.0.html>)

with Commons Clause 1.0 (L<https://commonsclause.com/>).

This is free software: you are free to change and redistribute it.

There is NO WARRANTY, to the extent permitted by law.

You may NOT use this software for commercial purposes.

=cut

MAIN: {
    my $gm = Git::Modules->new_from_text(<>);
    print $gm->unique;
}

package Git::Modules;
use strict;
use warnings;
use overload '""' => 'as_string';

sub new {
    my $class = shift;
    bless {
        ents => [],
        @_,
    }, $class
}

sub new_from_text {
    my $class = shift;
    my $self = &new($class);
    $self->add_from_text(@_);
    $self;
}

sub add_from_text {
    my $self = shift;
    my @lines = map { split /\n/, $_ } @_;
    my @curr_lines;
    foreach my $line (@lines) {
        if ($line =~ /^\[submodule\s+".*"\]$/) {
            if (@curr_lines) {
                push @{$self->{ents}}, Git::Modules::Entry->new_from_text(@curr_lines);
                # Start over
                @curr_lines = ();
            }
        }
        push @curr_lines, $line;
    }
    if (@curr_lines) {
        push @{$self->{ents}}, Git::Modules::Entry->new_from_text(@curr_lines);
    }
}

sub unique {
    my $self = shift;
    my %new_ents = map {
        ($_->_name, $_)
    } @{$self->{ents}};
    Git::Modules->new(
        ents => [values %new_ents],
    );
}

sub as_string {
    my $self = shift;
    # No header, just entries
    (join "\n", (
        sort {
            $a->{_name} cmp $b->{_name}
        } @{$self->{ents}}
    )) . "\n"
}

package Git::Modules::Entry;
use strict;
use warnings;
use overload '""' => 'as_string';

use Class::Tiny qw/
    _name
    branch
    path
    url
/;

sub new_from_text {
    my $class = shift;
    my @lines = map { split /\n/, $_ } @_;

    my $found_head = 0;
    my %attrs;
    foreach my $line (@lines) {
        # Ignore blank lines
        next if $line =~ /^\s*$/;

        if ($line =~ /^\[submodule\s+"(.*)"\]$/) {
            my $name = $1;
            die "Tried to begin a new entry (name=$1)" if $found_head;
            $found_head = 1;
            $attrs{_name} = $name;
        } elsif ($line =~ /^\s*([^=]+?)\s*=\s*(.*)$/) {
            $attrs{$1} = $2;
        } else {
            die "Unrecognized line: $line";
        }
    }

    return __PACKAGE__->new(%attrs);
}

sub as_string {
    my $self = shift;
    # TODO what if there's a quote

    # Put these keys first, in this order
    my @keys_first = qw/ path url branch /;
    my %used_keys;
    @used_keys{@keys_first} = (1) x @keys_first;
    my @rest_of_keys = grep {
        /^[^_]/ &&
        !$used_keys{$_}
    } keys %{$self};
    #@used_keys{@rest_of_keys} = (1) x @rest_of_keys;
    my @keys = (
        @keys_first,
        (sort @rest_of_keys),
    );

    (sprintf "[submodule \"%s\"]\n", $self->_name) .
    (join "\n", (
        map {
            sprintf "\t%s = %s", $_, $self->{$_}
        } grep {
            defined $self->{$_}
        } @keys
    ))
}
