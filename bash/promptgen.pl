#!/usr/bin/perl
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;

=head1 NAME

promptgen.pl - Color prompt generator

=head1 SYNOPSIS

B<promptgen.pl> [I<OPTION>]...

=head1 OPTIONS

Colors are specified using a colon-separated list in the form of I<FG:BG:FLAG...>

C<39:-235:b:u> means color 39 (blue-teal) on color 235 (slate), +bold +underline

=over 4

=item B<--git>

Generate a git prompt (default).

=item B<--no-git>

Generate a non-git prompt.

=item B<--basic-git>

Generate a basic git prompt with only the branch name.

=item B<--utf8>

Generate a UTF-8 prompt.

=item B<--no-utf8>

Generate a non-UTF-8 prompt (default).

=item B<-h> I<COLOR>, B<--host-color>=I<COLOR>

=item B<-u> I<COLOR>, B<--user-color>=I<COLOR>

=item B<-f> I<COLOR>, B<--frame-color>=I<COLOR>

Default is C<0:b>.

=item B<-s> I<COLOR>, B<--strudel-color>=I<COLOR>

Set the color of the C<@> character. Default is C<7:-0>.

=item B<-e> I<COLOR>, B<--err-color>=I<COLOR>

Set the color of the error return code message. Default is C<222:-235:b>.

=item B<--help>

Display this help and exit.

=back

=head1 COPYRIGHT

Copyright (C) 2020-2021 Dan Church.
License GPLv3+: GNU GPL version 3 or later (L<http://gnu.org/licenses/gpl.html>).
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

=cut

use Getopt::Long qw/ GetOptions /;
use Pod::Usage qw/ pod2usage /;

our $VERSION = '1.0.1';

MAIN: {
    my (
        $basic_git,
        $err_color,
        $frame_color,
        $git,
        $help,
        $host_color,
        $no_git,
        $no_utf8,
        $strudel_color,
        $user_color,
        $utf8,
    );
    # Defaults
    ($git, $utf8, $basic_git) = (1, 0, 0);

    &GetOptions(
        'utf8' => \$utf8,
        'no-utf8' => \$no_utf8,
        'git' => \$git,
        'help' => \$help,
        'no-git' => \$no_git,
        'basic-git' => \$basic_git,
        'user-color=s' => \$user_color, 'u=s' => \$user_color,
        'host-color=s' => \$host_color, 'h=s' => \$host_color,
        'frame-color=s' => \$frame_color, 'f=s' => \$frame_color,
        'strudel-color=s' => \$strudel_color, 's=s' => \$strudel_color,
        'err-color=s' => \$err_color, 'e=s' => \$err_color,
    ) || &pod2usage(
        -exitval => 2,
        -msg => "Try '$0 --help' for more information",
    );

    &pod2usage(
        -verbose => 1,
        -exitval => 0,
    ) if $help;

    $git = 0 if defined $no_git;
    $utf8 = 0 if defined $no_utf8;

    # default: green / yellow
    if ($ENV{USER} eq 'root') {
        $host_color = '3' unless defined $host_color;
        $user_color = '3:b' unless defined $user_color;
    } else {
        $host_color = '2' unless defined $host_color;
        $user_color = '2:b' unless defined $user_color;
    }

    my $prompt = Prompt->new(
        utf8 => $utf8,
        colors => {
            host => $host_color,
            user => $user_color,
            frame => $frame_color,
            strudel => $strudel_color,
            err => $err_color,
        },
        features => {
            git => $git,
        },
        basic_git => $basic_git,
    );

    binmode(STDOUT, ":utf8");
    print $prompt, "\n";
}
package Color;
use strict;
use warnings;

sub new {
    my $class = shift;
    bless {
        bg => 0,
        bold => 0,
        fg => 7,
        mode => 'normal',
        underline => 0,
        @_,
    }, $class
}

sub from_string {
    my ($class, $str) = @_;
    my $self = Color->new;
    my %mode_map = (
        u => [ 'underline', 1 ],
        b => [ 'bold', 1 ],
        n => [ 'mode', 'normal' ],
        g => [ 'mode', 'G1' ],
    );
    foreach my $arg (split /[:;]/, $str) {
        if (defined $mode_map{$arg}) {
            $self->{$mode_map{$arg}->[0]} = $mode_map{$arg}->[1];
        } elsif ($arg =~ /^-?[0-9]+$/) {
            if ($arg =~ /^-/) {
                $self->{bg} = abs $arg;
            } else {
                $self->{fg} = $arg;
            }
        }
    }
    $self
}

package Color::Transform;
use strict;
use warnings;
use overload '""' => 'to_string';

sub new {
    my $class = shift;
    bless {
        actions => [],
        @_,
    }, $class
}

sub new_from_colors {
    my $class = shift;
    my ($from, $to) = @_;

    $from = Color->new unless defined $from;

    my $self = Color::Transform->new;

    # XXX if we unset bold or underline, we have to set our color again because
    # unsetting underline involves resetting the color
    if (
        $from->{bold} != $to->{bold}
        && !$to->{bold}
        || $from->{underline} != $to->{underline}
        && !$to->{underline}
    ) {
        $self->with_reset;
        $from = Color->new(
            mode => $from->{mode},
        );
    }

    if ($from->{bold} != $to->{bold}) {
        $self->bold;
    }

    if ($from->{underline} != $to->{underline}) {
        $self->underline;
    }

    if ($from->{fg} != $to->{fg}) {
        $self->fg($to->{fg});
    }

    if ($from->{bg} != $to->{bg}) {
        $self->bg($to->{bg});
    }

    if ($from->{mode} ne $to->{mode}) {
        $self->mode($to->{mode});
    }

    $self
}

sub with_reset {
    my $self = shift;
    if (@{$self->{actions}} < 1 || $self->{actions}->[0] != 0) {
        unshift @{$self->{actions}}, 0;
    }
    $self
}

sub bold {
    my $self = shift;
    $self->_push(1);
}

sub underline {
    # TODO this is right in uxterm, but wrong in xterm. \e[4;37m works, though.
    my $self = shift;
    $self->_push(4);
}

sub fg {
    my $self = shift;
    if ($_[0] < 16) {
        $self->_push($_[0] + 30);
    } else {
        $self->_push(38, 5, $_[0]);
    }
}

sub bg {
    my $self = shift;
    if ($_[0] < 16) {
        $self->_push($_[0] + 40);
    } else {
        $self->_push(48, 5, $_[0]);
    }
}

sub mode {
    my $self = shift;
    if ($_[0] eq 'G1') {
        $self->{after} = '\016';
    } else {
        # Normal
        $self->{after} = '\017';
    }
}

sub _push {
    my $self = shift;
    push @{$self->{actions}}, @_;
}

sub to_string {
    my $self = shift;
    my $out = '';
    if (@{$self->{actions}}) {
        $out .= sprintf '\e[%sm',
            (join ';', @{$self->{actions}}),
    }
    $out .= $self->{after} if defined $self->{after};
    $out
}

package Color::Transform::State;
use strict;
use warnings;

sub new {
    my $class = shift;

    bless {
        curr_color => Color->new,
        @_,
    }, $class
}

sub reset {
    my $self = shift;
    $self->{curr_color} = Color->new;
}

sub next_nonprinting {
    my ($self, $bg) = @_;
    $self->next(Color->new(%{$self->{curr_color}},
        bg => $bg,
        underline => 0,
    ))
}

sub next {
    my ($self, $next_color) = @_;
    my $ret = Color::Transform->new_from_colors($self->{curr_color}, $next_color);
    $self->{curr_color} = $next_color;
    return $ret;
}

package Prompt;
use strict;
use warnings;
use overload '""' => 'to_string';

sub new {
    my $class = shift;

    my %default_features = (
        err => 1,
        tty => 1,
        git => 1,
        git_loader => 1,
    );
    my %default_colors = (
        dollar => '7:-0:b',
        err => '222:-235:b',
        frame => '0:b',
        git_bad => '222:-235:b',
        git_default => '121:-235:b',
        git_flags => '81:-233:b',
        git_ok => '121:-235:b',
        pwd => '7:-0',
        strudel => '7:-0',
        tty => '0:b',
        host => '2',
        user => '2:b',
    );
    my $self = bless {
        colors => {},
        space_bg => 0,
        @_,
    }, $class;
    # Merge options
    $self->{features} = {
        %default_features,
        (defined $self->{features} ? %{$self->{features}} : ()),
    };
    # Eliminate undef colors, apply default colors
    delete @{$self->{colors}}{ grep { not defined $self->{colors}->{$_} } keys %{$self->{colors}} };
    $self->{colors} = {
        %default_colors,
        %{$self->{colors}},
    };
    foreach my $key (keys %{$self->{colors}}) {
        $self->{colors}->{$key} = Color->from_string($self->{colors}->{$key})
            unless ref $self->{colors}->{$key};
    }

    $self
}

sub frame_color_box {
    my $self = shift;
    Color->new(%{$self->{colors}->{frame}}, mode => 'G1');
}

sub blocker {
    my $str = join '', @_;
    length $str ? "\\[$str\\]" : '';
}

sub line1_frame_left {
    my ($self, $state) = @_;
    if ($self->{utf8}) {
        &blocker($state->next($self->{colors}->{frame}))
        . "\x{250c}\x{2500}\x{2500}\x{2524}"
    } else {
        &blocker(
            '\e)0', # \e)0 sets G1 to special characters,
            $state->next($self->frame_color_box), # (turn on box drawing)
        )
        . 'lqqu'
    }
}

sub line1_left {
    my ($self, $state) = @_;

    return
        $self->line1_frame_left($state)
        . (
            $self->{features}->{tty}
                # TTY number
                ? &blocker($state->next($self->{colors}->{tty})) . '\l'
                : ''
        )
        # Add a space, don't care what the foreground color is
        . &blocker($state->next_nonprinting($self->{space_bg}))
        . ' '
        . &blocker($state->next($self->{colors}->{user}))
        . '\u'
        . &blocker($state->next($self->{colors}->{strudel}))
        . '@'
        . &blocker($state->next($self->{colors}->{host}))
        . '\h'
}

sub line1_right {
    my ($self, $state) = @_;

    if ($self->{utf8}) {
        # Add a space, don't care what the foreground color is
        &blocker($state->next_nonprinting($self->{space_bg}))
        . ' '
        . &blocker($state->next($self->{colors}->{frame}))
        . "\x{251c}\x{2500}\x{25c6}"
    } else {
        # Add a space, don't care what the foreground color is
        &blocker($state->next_nonprinting($self->{space_bg}))
        . ' '
        . &blocker($state->next($self->frame_color_box)) # (turn on box drawing)
        . 'tq\\`'
        . &blocker($state->next($self->{colors}->{frame})) # (turn off box drawing)
    }
}

sub err {
    my ($self, $state) = @_;
    return
        q~$(err=$?; [[ $err -eq 0 ]] || printf ' \[%s\][%d]' '~
        . $state->next($self->{colors}->{err})
        . q~' $err)~
}

sub line2_frame_left {
    my ($self, $state) = @_;

    if ($self->{utf8}) {
        &blocker($state->next($self->{colors}->{frame})->with_reset)
        . "\x{2514}\x{2500}["
    } else {
        &blocker($state->next($self->frame_color_box)->with_reset)
        . 'mq['
    }
}

sub line2 {
    my ($self, $state) = @_;
    $state->reset;
    return
        '\n'
        . $self->line2_frame_left($state)
        # Add a space, don't care what the foreground color is
        . &blocker($state->next_nonprinting($self->{space_bg}))
        . ' '
        . &blocker($state->next($self->{colors}->{pwd}))
        . '\w'
        # Add a space, don't care what the foreground color is
        . &blocker($state->next_nonprinting($self->{space_bg}))
        . ' '
        . &blocker($state->next($self->{colors}->{frame}))
        . ']='
        # Add a space, don't care what the foreground color is
        . &blocker($state->next_nonprinting($self->{space_bg}))
        . ' '
        . &blocker($state->next($self->{colors}->{dollar}))
        . '\$'
        . &blocker($state->next(Color->new)->with_reset)
        . ' '
}

sub git_prompt_loader {
    my $self = shift;
    return undef unless $self->{features}->{git_loader};
    my @candidates = (
        '/usr/doc/git-*.*.*/contrib/completion/git-prompt.sh',
        '/usr/share/git-core/contrib/completion/git-prompt.sh',
        '/usr/lib/git-core/git-sh-prompt',
    );
    foreach my $globstr (@candidates) {
        if ($globstr =~ /\*|\?/) {
            if (glob $globstr) {
                return sprintf
                    'test -z "$(for fn in %s; do '
                    . 'if [[ -f $fn ]]; then '
                    . 'echo "$fn"; '
                    . 'break; '
                    . 'fi; '
                    . 'done'
                    . ')" || { . "$_"; }',
                    $globstr
            }
        } else {
            if (-f $globstr) {
                return ". $globstr"
            }
        }
    }
    return undef;
}

sub git_color_override {
    my $self = shift;
    my ($red, $green, $lblue) = @{$self->{colors}}{qw/ git_bad git_ok git_flags /};

    my $space = Color->new(bg => $self->{space_bg});
    # Taken from git-prompt.sh and made more compact
    q~__git_ps1_colorize_gitstring() {
local bad_color='~
    . &blocker(Color::Transform->new_from_colors($space, $red))
    . q~' ok_color='~
    . &blocker(Color::Transform->new_from_colors($space, $green))
    . q~' flags_color='~
    . &blocker(Color::Transform->new_from_colors($space, $lblue))
    . q~' c_clear='\[\e[0m\]' branch_color
[[ $detached = no ]] && branch_color=$ok_color || branch_color=$bad_color
c=$branch_color$c
z=$c_clear$z
[[ $w != '*' ]] || w=$bad_color$w
[[ -z $i ]] || i=$ok_color$i
[[ -z $s ]] || s=$flags_color$s
[[ -z $u ]] || u=$bad_color$u
r=$c_clear$r
}~;

}

# Basic git-enabled prompt; Will show you the branch or tag, but that's about
# it.
sub git_basic_ps1 {
    my ($self, $state) = @_;
    $self->line1_left($state)
        . '$(__git_ps1 \''
            . &blocker($state->next_nonprinting($self->{space_bg}))
            . ' '
            . &blocker($state->next($self->{colors}->{git_default}))
            . '%s\')'
        . $self->line1_right($state)
        . ($self->{features}->{err} ? $self->err($state) : '')
        . $self->line2($state)
}

sub git_prompt {
    my $self = shift;
    my @lines = (
        $self->git_prompt_loader,
    );
    my $state = Color::Transform::State->new;
    if ($self->{basic_git}) {
        (my $p = $self->git_basic_ps1($state)) =~ s/'/'\\''/g;
        push @lines, "PS1='$p'";
    } else {
        (my $p = $self->git_prompt_command($state)) =~ s/'/'\\''/g;
        push @lines,
            $self->git_color_override,
            'GIT_PS1_SHOWCOLORHINTS=1',
            "PROMPT_COMMAND='$p'";
    }
    join "\n", grep { defined $_ } @lines;
}

# Fancy git prompt; Shows branch, tag, special status, all in different colors
sub git_prompt_command {
    my ($self, $state) = @_;
    my $l1left = $self->line1_left($state);
    # The space before the git section is based on the last color state of the
    # line1_left. In order to color the space properly, we need to calculate it
    # just after.
    my $space_before_git_prompt = &blocker($state->next_nonprinting($self->{space_bg})) . ' ';
    sprintf q~__git_ps1 '%s' '%s'%s'%s' '%s%%s'~,
        $l1left,
        $self->line1_right($state),
        ($self->{features}->{err} ? '"' . $self->err($state) . '"' : ''),
        $self->line2($state),
        $space_before_git_prompt
}

sub non_git_prompt {
    my $self = shift;
    my $state = Color::Transform::State->new;
    (my $p = $self->non_git_ps1($state)) =~ s/'/'\\''/g;
    sprintf q~PS1='%s'~, $p;
}

sub non_git_ps1 {
    my ($self, $state) = @_;
    $self->line1_left($state)
        . $self->line1_right($state)
        . ($self->{features}->{err} ? $self->err($state) : '')
        . $self->line2($state)
}

sub to_string {
    my $self = shift;
    $self->{features}->{git} ? $self->git_prompt : $self->non_git_prompt
}

