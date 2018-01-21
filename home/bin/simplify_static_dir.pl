#!/usr/bin/perl
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;

our $VERSION = '2.0.0';

=pod

=head1 NAME

simplify_static_dir - optimize directories for size by combinining identical
files

=head1 SYNOPSIS

B<simplify_static_dir> [I<OPTIONS>] [I<DIR>]...

=head1 DESCRIPTION

The more files this script can process at once, the better. It maintains an
internal hash of files indexed by their SHA1 checksum. When it finds a
collision it removes the file with the least amount of file system links, then
creates a hard link to the other in its place. The larger the number of files
scanned, the more likely it is that there will be collisions.

There are failsafes in place, though. If somehow two files' SHA1 checksums are
identical, but the file sizes do not match, this program will error out (and
you can go ahead and report the collision; it may be worth money).

There are other features built in as well. Following the logic that unique
data, once created has the attribute of being unique of that point in time,
this script will copy the timestamp of the older file onto the newer file just
before it makes the hard link. Therefore, many times, simplified directories
will have the appearance of being older than they actually are.

From the perspective of any program reading files from the simplified
directoriws, the files will lookB<*> and behave the same way as the initial
state.

B<*> Except for having an increased number of hard links.

=head1 OPTIONS

=over

=item B<-v>

Verbose output.

=item B<-f>

Print a sum of the number of freed bytes.

=item B<-m> I<REGEX>

Only match file paths matching I<REGEX>.

=item B<-M> I<REGEX>

Exclude file paths matching I<REGEX>.

=item B<-z>

Include zero-length files in search. Normally they are ignored (you don't save
diskspace by hard-linking empty files).

=item B<--help>

Output this help message and exit.

=item B<--version>

Output version information and exit.

=back

By default, scans the current directory. Files not able to be hard-linked are
symlinked by default.

=head1 COPYRIGHT

Copyright (C) 2010-2018 Dan Church.

License GPLv3+: GNU GPL version 3 or later (L<http://gnu.org/licenses/gpl.html>).

This is free software: you are free to change and redistribute it.

There is NO WARRANTY, to the extent permitted by law.

=head1 AUTHOR

Written by Dan Church S<E<lt>amphetamachine@gmail.comE<gt>>

=cut

use File::Find qw/ find /;
require Digest::SHA;
use Getopt::Std qw/ getopts /;

sub HELP_MESSAGE {
    my $fh = shift;
    print $fh <<EOF
Usage: $0 [DIRS]
Simplify a directory by hard-linking identical files.

  -v            Verbose output.
  -f            Print a sum of the number of freed bytes.
  -m REGEX      Only match file paths matching REGEX.
  -M REGEX      Exclude file paths matching REGEX.
  -z            Include zero-length files in search.

By default, scans the current directory.

See also `perldoc $0'
EOF
;
    exit 0;
}

my %opts = (
    v => 0,
    f => 0,
    m => '',
    M => '',
    z => 0,
);

&getopts('vfm:M:z', \%opts);

my $filehash = new Util::FileHash;

# include zero-length files if wanted (`-z')
$filehash->min_linkable_size(0)
    if $opts{z};

# correct relative paths
# OR if no directories given, search the current directory
push @ARGV, $ENV{PWD} unless map { s#^([^/])#$ENV{PWD}/$1# } @ARGV;

my $freed_bytes = 0;

&find(\&findexec, @ARGV);

printf STDERR "freed %d bytes (%0.4G %s)\n",
    $freed_bytes, &hr_size($freed_bytes)
        if $opts{f} or $opts{v};

sub findexec {
    # outright skip directories (don't report skip)
    return if -d $File::Find::name;

    # limit to or exclude file patterns specified by `-m' or `-M',
    # respectively

    # truth table
    # -m matches    | -M is used & matches  | !return?
    # 0     | 0         | 0
    # 0     | 1         | 0
    # 1     | 0         | 1
    # 1     | 1         | 0
    # note: m// will match everything
    unless ($File::Find::name =~ m/$opts{m}/ and
        !(length $opts{M} and $File::Find::name =~ m/$opts{M}/)) {

        print STDERR "Skipping path `$File::Find::name'\n"
            if $opts{v};
        return;
    }

    # skip non-existent files and links
    unless (-f $File::Find::name && ! -l $File::Find::name) {
        return;
    }

    my $entry = $filehash->make_entry($File::Find::name);

    my @linkable = $filehash->find_hardlinkable($entry);
    if (@linkable) {
        &hardlink_entries($entry, @linkable);
    }
    $filehash->add_entry($entry);
}

sub hardlink_entries {
    my ($entry, @linkable) = @_;

    # only one of the linkable entries should suffice
    my $linking_with = $linkable[0];

    # calculate the timestamp of the resulting file
    my ($atime, $mtime) = @{(
        $filehash->oldest_mtime($entry, $linking_with)
    )[0]}{qw/ atime mtime /};

    # find the file less embedded in the file system
    my ($less_linked, $more_linked) = $filehash->less_linked($entry, $linking_with);

    printf STDERR "removing file `%s'\n", $less_linked->{name}
        if $opts{v};

    unless (unlink $less_linked->{name}) {
        printf STDERR "Failed to remove file `%s': %s\n(using `%s')\n",
            $less_linked->{name},
            $!,
            $more_linked->{name};

        # if we can't do this, there's no point in continuing
        unless (unlink $more_linked->{name}) {
            printf STDERR "Failed to remove file `%s' (second failure on match): %s\nSkipping...\n",
                $more_linked->{name},
                $!;

            return;
        }

        # the ol' switcheroo
        ($more_linked, $less_linked) =
        ($less_linked, $more_linked);
    }

    # we unlinked it or failed out
    $freed_bytes += $less_linked->{size}
        unless $less_linked->{nlink} > 1;

    printf STDERR "hard linking `%s' => `%s'\n",
        $less_linked->{name}, $more_linked->{name}
    if $opts{v};

    # hard link the files
    link $more_linked->{name},
    $less_linked->{name};

    # preserve older time stamp
    utime $atime, $mtime, $more_linked->{name};
    $more_linked->{atime} = $atime;
    $more_linked->{mtime} = $mtime;

    # update link count in our hash to reflect the file system (referenced)
    ++$more_linked->{nlink};

    # update old entry with the info from the new one
    foreach my $copy_attr (qw/
        ino
        nlink
        mode
        uid
        gid
        atime
        mtime
        ctime
    /) {
        $less_linked->{$copy_attr} = $more_linked->{$copy_attr};
    }
}

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

    # default to ($sz, 'bytes')
    @ret = ($sz, $sizes[0]) unless @ret;

    wantarray ? @ret : "@ret"
}

package Util::FileHash;

use strict;
use warnings;

=head1 DESCRIPTION

Object for abstracting management of a hashed filesystem

=head1 COPYRIGHT

Copyright (C) 2010-2018 Dan Church.

License GPLv3+: GNU GPL version 3 or later (L<http://gnu.org/licenses/gpl.html>).

This is free software: you are free to change and redistribute it.

There is NO WARRANTY, to the extent permitted by law.

=head1 AUTHOR

Written by Dan Church S<E<lt>amphetamachine@gmail.comE<gt>>

=cut

sub new {
    my ($class, $self) = (shift, {});

    $self->{_files} = {};

    require Digest::SHA;
    $self->{_ctx} = Digest::SHA->new;

    # default options
    $self->{_min_linkable_size} = 1;

    bless $self, $class
}

=head2 min_linkable_size($bytes)

Set or get the minimum size of files to be considered hard-linkable. Default is 1.

=cut

sub min_linkable_size {
    my $self = shift;
    my $in = shift;
    if (defined $in) {
        $self->{_min_linkable_size} = $in;
    }
    $self->{_min_linkable_size}
}

=head2 make_entry($filename)

=cut

sub make_entry {
    my $self = shift;
    my ($filename) = @_;
    # organize results from lstat into hash
    my $entry = {};
    (@{$entry}{qw/ name dev ino mode nlink uid gid rdev size
            atime mtime ctime blksize blocks /})
        = ($filename, lstat $filename);

    $entry->{hash} = $self->_hash($filename);

    $entry
}

=head2 add_entry($entry)

=cut

sub add_entry {
    my $self = shift;
    my ($entry) = @_;

    my $hash = $entry->{hash};

    unless (defined $self->{_files}->{$hash}) {
        $self->{_files}->{$hash} = [];
    }
    push @{$self->{_files}->{$hash}}, $entry;
}

sub find_hardlinkable {
    my $self = shift;
    my ($entry) = @_;

    my $hash = $entry->{hash};

    # no matching entries
    unless (defined $self->{_files}->{$hash}) {
        return ();
    }

    my @matches;
    foreach my $ent (@{$self->{_files}->{$hash}}) {
        if ($self->_entries_are_hard_linkable($entry, $ent)) {
            push @matches, $ent;
        }
    }

    return @matches;

}

=head2 oldest($entry_a, $entry_b, ...)

Find the file less embedded in the file system.

=cut

sub less_linked {
    my $self = shift;
    return sort
        {$a->{nlink} <=> $b->{nlink}}
        @_;
}

=head2 oldest($entry_a, $entry_b, ...)

Find the entry with the oldest time stamp.

=cut

sub oldest_mtime {
    my $self = shift;

    return sort
        {$a->{mtime} <=> $b->{mtime}}
        @_;
}

sub _hash {
    my $self = shift;
    my ($filename) = @_;
    $self->{_ctx}->addfile($filename);
    return $self->{_ctx}->hexdigest;
}

sub _entries_are_hard_linkable {
    my $self = shift;
    my ($entry_a, $entry_b) = @_;

    # obviously, if the sizes aren't the same, they're not the same file
    unless (&_entries_sizes_match($entry_a, $entry_b)) {
        return 0;
    }

    # too small to be hard-linked
    if ($entry_a->{size} < $self->min_linkable_size) {
        return 0;
    }

    # they're the same file, don't try it
    if (&_entries_are_same_filename($entry_a, $entry_b)) {
        return 0;
    }
    if (&_entries_are_already_hard_linked($entry_a, $entry_b)) {
        return 0;
    }

    if (&_entries_contents_match($entry_a, $entry_b)) {
        return 1;
    }
    return 0;
}

sub _entries_are_same_filename {
    my ($entry_a, $entry_b) = @_;

    if ($entry_a->{name} eq $entry_b->{name}) {
        return 1;
    }
    return 0;
}

sub _entries_are_already_hard_linked {
    my ($entry_a, $entry_b) = @_;

    if ($entry_a->{ino} == $entry_b->{ino} and
        $entry_a->{dev} == $entry_b->{dev}) {
        return 1;
    }

    return 0;
}

sub _entries_sizes_match {
    my ($entry_a, $entry_b) = @_;
    if ($entry_a->{size} != $entry_b->{size}) {
        return 0;
    }
    return 1;
}

sub _entries_contents_match {
    my ($entry_a, $entry_b) = @_;

    # also, if the hashes aren't the same, they cannot be the same file
    if ($entry_a->{hash} ne $entry_b->{hash}) {
        return 0;
    }

    use File::Compare   qw/ compare /;
    my $contents_same = (0 == &compare($entry_a->{name}, $entry_b->{name}));

    # warn about hash collision
    unless ($contents_same) {
        warn "Hash collision between files:\n* $entry_a->{name}\n* $entry_b->{name}\n  (don't panic)\n";
    }
    return $contents_same;
}

1;
