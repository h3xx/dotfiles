#!/usr/bin/perl
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;

sub hr_size {
    my $sz = shift;
    my @sizes = qw/ B KB MB GB TB PB EB ZB YB /;
    my $fact = 1024;
    my $thresh = 0.1;
    my @ret;
    foreach my $exp (reverse 0 .. $#sizes) {
        if ($sz > (1 - $thresh) * $fact ** $exp) {
            @ret = ($sz / $fact ** $exp, $sizes[$exp]);
            last;
        }
    }

    # default to [SIZE] bytes
    @ret = ($sz, $sizes[0]) unless @ret;

    wantarray ? @ret : $ret[0];
}

foreach my $bytes (@ARGV) {
    print join (' ', &hr_size($bytes)), "\n";
}
