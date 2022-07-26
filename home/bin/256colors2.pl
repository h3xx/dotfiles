#!/usr/bin/perl
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;
use Getopt::Std	qw/ getopts /;

# Author: Todd Larason <jtl@molehill.org>
# $XFree86: xc/programs/xterm/vttests/256colors2.pl,v 1.2 2002/03/26 01:46:43 dickey Exp $
# modified by Dan Church to output the terminal color numbers in order to aid in writing Vim color schemes
# modified AGAIN by Dan Church to provide better contrast between the colors and the numbers
# modified AGAIN by Dan Church to show a specific palette by passing the script a list of numbers
# modified AGAIN by Dan Church to make OO and DRY
# modified AGAIN by Dan Church to support printing escape sequences


sub HELP_MESSAGE {
    my $fh = shift;
    print $fh <<EOF
Usage: $0 [OPTIONS] [COLOR...]
Display a terminal color cube.

  -a            Display TERM::ANSIColor compatible aliases.
  -f            Display foreground escape sequences.
  -O            When filtering by colors, show ONLY those colors.

Copyright (C) 2015-2022 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
;
    exit 0;
}


MAIN: {
    &getopts('afO', \ my %opts);

    my %reverse_colors;
    my $limit_to_colors;
    if (@ARGV) {
        @reverse_colors{0..255} = (1) x 256;
        if ($opts{O}) {
            $limit_to_colors = {};
            @{$limit_to_colors}{@ARGV} = (1) x @ARGV;
        } else {
            @reverse_colors{@ARGV} = (0) x @ARGV;
        }
    }

    my $cc = Color::Cube->new(
        reverse_colors => \%reverse_colors,
        limit_to_colors => $limit_to_colors,
        ($opts{a}
            ? (format => 'ansicolor')
            : ($opts{f}
                ? (format => 'fg_escape')
                : ()
            )
        ),
    );

    print $cc, "\n";
}

package Color::Cube;
use strict;
use warnings;
use overload '""' => 'to_string';

sub new {
    my $class = shift;

    my $self = bless {
        format => 'number',
        limit_to_colors => undef,
        reverse_colors => {},
        @_,
    }, $class;

    $self;
}

sub to_string {
    my $self = shift;
    my @out = (
        $self->set_resources,
        "System colors:\n",
        $self->system_colors,
        "\n\n",
        "Color cube, 6x6x6:\n",
        $self->color_cube,
        "Grayscale ramp:\n",
        $self->gray_ramp,
    );
    join '', @out
}

sub luminance {
    my ($red, $green, $blue) = @_;
    # source: https://en.wikipedia.org/wiki/Relative_luminance
    0.2126 * $red + 0.7152 * $green + 0.0722 * $blue
}

sub fg {
    my $self = shift;
    my ($color, $red, $green, $blue) = @_;

    if ($self->{reverse_colors}->{$color}) {
        return '30;07'; # black, reversed
    }
    if (defined $red) {
        return (&luminance($red, $green, $blue) < 3) ?
            '37' : # white
            '30'; # black
    }
    if ($color > 231) {
        # in gray ramp
        if ($color < 244) {
            return '37'; # white
        } else {
            return '30'; # black
        }
    }
    return '';
}

sub set_resources {
    my $self = shift;
    my @out;

    # use the resources for colors 0-15 - usually more-or-less a
    # reproduction of the standard ANSI colors, but possibly more
    # pleasing shades

    # colors 16-231 are a 6x6x6 color cube
    foreach my $red (0 .. 5) {
        foreach my $green (0 .. 5) {
            foreach my $blue (0 .. 5) {
                push @out, sprintf "\x1b]4;%d;rgb:%2.2x/%2.2x/%2.2x\x1b\\",
                16 + ($red * 36) + ($green * 6) + $blue,
                ($red ? ($red * 40 + 55) : 0),
                ($green ? ($green * 40 + 55) : 0),
                ($blue ? ($blue * 40 + 55) : 0);
            }
        }
    }

    # colors 232-255 are a grayscale ramp, intentionally leaving out
    # black and white
    foreach my $gray (0 .. 23) {
        my $level = ($gray * 10) + 8;
        push @out, sprintf "\x1b]4;%d;rgb:%2.2x/%2.2x/%2.2x\x1b\\",
            232 + $gray, $level, $level, $level;
    }
    @out
}

sub text {
    my $self = shift;
    my ($alias, $color) = @_;
    if ($self->{format} eq 'ansicolor') {
        return $alias;
    } elsif ($self->{format} eq 'fg_escape') {
        my $escape;
        if ($color < 16) {
            $escape = $color + 30;
            if ($color > 7) {
                $escape = "1;$escape";
            }
        } else {
            $escape = "30;07;48;5;$color";
        }
        return "\\e[${escape}m";
    }
    return $color;
}

sub brick {
    my $self = shift;
    my ($alias, $color, $red, $green, $blue) = @_;
    if (defined $self->{limit_to_colors} and not defined $self->{limit_to_colors}->{$color}) {
        return '';
    }
    my $fg = $self->fg($color, $red, $green, $blue);
    sprintf "\x1b[%s;48;5;%dm%3s \x1b[0m", $fg, $color, $self->text($alias, $color);
}

sub system_colors {
    my $self = shift;
    my @out = (
        (map { $self->brick("ansi$_", $_) } 0 .. 7),
        "\n",
        (map { $self->brick("ansi$_", $_) } 8 .. 15),
    );
    @out
}

sub color_cube {
    my $self = shift;
    my @out;
    foreach my $green (0 .. 5) {
        my @row;
        foreach my $red (0 .. 5) {
            my @group;
            foreach my $blue (0 .. 5) {
                my $color = 16 + ($red * 36) + ($green * 6) + $blue;
                my $brick = $self->brick("rgb$red$green$blue", $color, $red, $green, $blue);
                if ($brick) {
                    push @group, $brick;
                }
            }
            if (@group) {
                push @row, @group, " ";
            }
        }
        if (@row) {
            push @out, @row, "\n";
        }
    }
    @out
}

sub gray_ramp {
    my $self = shift;
    my @out;
    push @out, map { $self->brick('grey' . ($_ - 232), $_) } 232 .. 255;

    @out
}
