#!/usr/bin/perl
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;

our $VERSION = 0.02;

# gives all files in the [recursive] paths specified their own inodes

use File::Find      qw/ find /;
use File::Temp      qw/ tempfile /;
use File::Basename  qw/ basename /;

# if no directories given, search the current directory
push @ARGV, $ENV{'PWD'}
    unless @ARGV;

my $temp_template = &basename($0) . 'XXXXXX';

&find(\&findexec,
    map {
        # convert relative to absolute paths
        m#^/# ?
            $_ :
            $ENV{'PWD'} . $_
    } @ARGV
);

sub findexec {
    my %stats;

    # (this has the added effect of filling the stat buffer `_')
    @stats{qw/ dev ino mode nlink uid gid rdev size atime mtime /} =
        lstat $File::Find::name;

    # make sure the file exists and it's not a link
    if (-f _ && ! -l _) {

        if ($stats{'nlink'} > 1) {
            # it's hard-linked somewhere

            open my $ofh, '<', $File::Find::name
                or die "Failed to open file `$File::Find::name' for reading: $!";

            # use a temporary file to put the new data
            my ($tfh, $tfn) = &tempfile($temp_template, TMPDIR=>1);

            # copy the data over to the temporary file
            binmode $ofh;
            binmode $tfh;

            {local $/; print $tfh (<$ofh>);} # slurp-spit!

            # now, the temporary file contains the same contents as
            # the original file

            close $ofh;
            close $tfh;

            # preserve the timestamps
            utime @stats{qw/ atime mtime /}, $tfn;

            # preserve mode
            chmod $stats{'mode'}, $tfn;

            # move the data back (`rename' overwrites)
            rename $tfn, $File::Find::name;

            print "gave own inode to `$File::Find::name'\n";
        }
    }
}
