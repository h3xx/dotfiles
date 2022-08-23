#!/usr/bin/perl
# vi: et sts=4 sw=4 ts=4
package main;
use strict;
use warnings;

=pod

=head1 NAME

sort-gitconfig.pl - Sort Git config files

=head1 SYNOPSIS

B<sort-gitconfig.pl> < I<FILE1> > I<FILE2>

B<sort-gitconfig.pl> < ~/.config/git/config > ~/.config/git/config.sorted

=head1 COPYRIGHT

Copyright (C) 2021-2022 Dan Church S<E<lt>amphetamachine@gmail.comE<gt>>

License GPLv3: GNU GPL version 3.0 (L<https://www.gnu.org/licenses/gpl-3.0.html>)

with Commons Clause 1.0 (L<https://commonsclause.com/>).

This is free software: you are free to change and redistribute it.

There is NO WARRANTY, to the extent permitted by law.

You may NOT use this software for commercial purposes.

=cut

MAIN: {
    my $gc = Git::Config->new_from_text(<>);
    print $gc->unique;
}

package Git::Config;
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
        if ($line =~ /^\S/) {
            if (@curr_lines) {
                push @{$self->{ents}}, Git::Config::Section->new_from_text(@curr_lines);
                # Start over
                @curr_lines = ();
            }
        }
        push @curr_lines, $line;
    }
    if (@curr_lines) {
        push @{$self->{ents}}, Git::Config::Section->new_from_text(@curr_lines);
    }
}

sub unique {
    my $self = shift;
    my %new_ents = map {
        ($_->_name, $_)
    } @{$self->{ents}};
    Git::Config->new(
        ents => [values %new_ents],
    );
}

sub as_string {
    my $self = shift;
    # No header, just entries
    (join "\n\n", (
        sort {
            $a->{_name} cmp $b->{_name}
        } @{$self->{ents}}
    )) . "\n"
}

package Git::Config::Section;
use strict;
use warnings;
use overload '""' => 'as_string';

use Class::Tiny qw/
    _name
    lines
/;

sub new_from_text {
    my $class = shift;
    my @lines = map { split /\n/, $_ } @_;

    my @sub_lines;
    my $name = '';
    foreach my $line (@lines) {
        # Ignore blank lines
        next if $line =~ /^\s*$/;

        if ($line =~ /^\[(.*)\]$/) {
            #die "Tried to begin a new entry (name=$1)" if defined $name;
            die "Tried to begin a new entry (name=$1)\n" . (join "\n", @lines) . "\n" if $name;
            $name = $1;
        } else {
            push @sub_lines, $line;
        }
    }

    return __PACKAGE__->new(
        lines => \@sub_lines,
        _name => $name,
    );
}

sub as_string {
    my $self = shift;
    my $out = '';
    if ($self->_name) {
        $out .= sprintf "[%s]\n", $self->_name;
    }
    $out .
    (join "\n", @{$self->lines})
}
