#!/usr/bin/perl
# vi: et sts=4 sw=4 ts=4

package main;
use strict;
use warnings;
require Cwd;

our $VERSION = '3.0.0';

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
directories, the files will lookB<*> and behave the same way as the initial
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


MAIN: {
    my %opts = (
        v => 0,
        f => 0,
        m => '',
        M => '',
        z => 0,
    );

    &getopts('vfm:M:z', \%opts);

    # correct relative paths
    # OR if no directories given, search the current directory
    my @dirs_to_process = map { Cwd::abs_path($_) } (@ARGV ? @ARGV : ($ENV{PWD}));

    my @files;
    print STDERR 'Finding files...'
        if $opts{v};

    &find(sub {
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

        push @files, $File::Find::name;
    }, @dirs_to_process);

    printf STDERR "%s files found.\nGenerating hashes...", scalar @files
        if $opts{v};

    my $filehash = Directory::Simplify::FileHash->new;
    $filehash->add(@files);
    print STDERR "done.\n"
        if $opts{v};

    my $generator = Directory::Simplify::Instruction::Generator->new(
        filehash => $filehash,
        min_size => ($opts{z} ? 0 : 1),
    );

    my $freed_bytes = 0;

    foreach my $inst ($generator->instructions) {
        print STDERR $inst, "\n" if $opts{v};
        $inst->run;
        $freed_bytes += $inst->bytes_freed;
    }

    printf STDERR "freed %d bytes (%0.4G %s)\n",
        $freed_bytes, Directory::Simplify::Utils::hr_size($freed_bytes)
            if $opts{f} or $opts{v};
}

package Directory::Simplify::Utils;
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

    # default to ($sz, 'bytes')
    @ret = ($sz, $sizes[0]) unless @ret;

    wantarray ? @ret : "@ret"
}

sub shell_quote {
    # shell-escape argument for inclusion in non-interpolated single quotes
    my @transformed = map {
        (my $out = $_)
            =~ s/'/'\\''/g;
        "'$out'";
    } @_;
    wantarray ? @transformed : $transformed[0];
}

package Directory::Simplify::Instruction::Hardlink;
use strict;
use warnings;
use overload '""' => 'as_string';

sub new {
    my $class = shift;
    return bless {
        freed => 0,
        @_,
    }, $class;
}

sub run {
    my $self = shift;
    # hard link the files

    unless (unlink $self->{target}->{name}) {
        die "Failed to remove file `$self->{target}->{name}': $!\n";
    }
    unless (link $self->{source}->{name}, $self->{target}->{name}) {
        die "Failed to hard link `$self->{source}->{name}' => `$self->{target}->{name}': $!";
    }
    # bookkeeping
    ++$self->{source}->{nlink};
    if (--$self->{target}->{nlink} == 0) {
        $self->{freed} = $self->{target}->{size};
    }
}

sub bytes_freed {
    my $self = shift;
    return $self->{freed};
}

sub as_string {
    my $self = shift;
    return sprintf 'ln -sf %s %s', Directory::Simplify::Utils::shell_quote($self->{source}->{name}, $self->{target}->{name});
}

package Directory::Simplify::Instruction::CopyTimestamp;
use strict;
use warnings;
use overload '""' => 'as_string';

sub new {
    my $class = shift;
    return bless {
        @_,
    }, $class;
}

sub run {
    my $self = shift;
    # preserve older time stamp
    utime $self->{source}->{atime}, $self->{source}->{mtime}, $self->{target}->{name};
}

sub bytes_freed {
    return 0;
}

sub as_string {
    my $self = shift;
    return sprintf 'touch -r %s %s', Directory::Simplify::Utils::shell_quote($self->{source}->{name}, $self->{target}->{name});
}

package Directory::Simplify::Instruction::Generator;
use strict;
use warnings;
use overload '""' => 'as_string';
use File::Basename qw/ dirname /;
use File::Compare qw/ compare /;

sub new {
    my $class = shift;
    return bless {
        filehash => undef,
        min_size => 1,
        @_,
    }, $class;
}

sub as_string {
    my $self = shift;
    join "\n", $self->instructions;
}

sub buckets {
    my $self = shift;

    my @candidate_lists = $self->{filehash}->entries;

    my @buckets;
    foreach my $candidates (@candidate_lists) {
        my @ca = @{$candidates}; # make a clone
        my @these_buckets;

        # at least two files needed to link together
        if (@ca > 1) {
            ELIMINATOR: while (@ca) {
                my $entry = shift @ca;

                next ELIMINATOR if $self->_entry_should_be_skipped($entry);

                foreach my $bucket_idx (0 .. $#these_buckets) {
                    if (&_entries_are_hard_linkable($these_buckets[$bucket_idx]->[0], $entry)) {
                        push @{$these_buckets[$bucket_idx]}, $entry;
                        next ELIMINATOR;
                    }
                }
                # didn't find a bucket (even though the hash matched!)
                # -> new bucket
                push @these_buckets, [$entry];
            }
        }
        push @buckets, @these_buckets;
    }

    @buckets
}

sub _entry_should_be_skipped {
    my ($self, $entry_a) = @_;
    # too small to be hard-linked
    if ($entry_a->{size} < $self->{min_size}) {
        return 1;
    }
    return 0;
}

sub _entries_are_hard_linkable {
    my ($entry_a, $entry_b) = @_;

    # obviously, if the sizes aren't the same, they're not the same file
    unless (&_entries_sizes_match($entry_a, $entry_b)) {
        return 0;
    }

    # they're the same file, don't try it
    if (&_entries_are_already_hard_linked($entry_a, $entry_b)) {
        return 0;
    }

    if (&_entries_contents_match($entry_a, $entry_b)) {
        return 1;
    }
    return 0;
}

sub oldest_mtime {
    my $self = shift;
    return sort {
        $a->{mtime} <=> $b->{mtime}
    } @_;
}

sub more_linked {
    my $self = shift;
    my %warned;
    return sort {
        if (! -w &dirname($a->{name})) {
            warn "Warning: $a->{name} not able to be unlinked!" unless $warned{$a->{name}}++;
            return 1; # favor a -> front
        } elsif (! -w &dirname($b->{name})) {
            warn "Warning: $b->{name} not able to be unlinked!" unless $warned{$b->{name}}++;
            return -1; # favor b -> front
        }
        $b->{nlink} <=> $a->{nlink}
    } @_;
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

    my $contents_same = (0 == &File::Compare::compare($entry_a->{name}, $entry_b->{name}));

    # warn about hash collision
    unless ($contents_same) {
        warn "Hash collision between files:\n* $entry_a->{name}\n* $entry_b->{name}\n  (don't panic)\n";
    }
    return $contents_same;
}

# generate hardlink instructions
sub instructions {
    require Scalar::Util;
    my $self = shift;

    # start generating instructions
    my @inst;
    foreach my $bucket ($self->buckets) {

        # of the bucket, find the oldest timestamp
        my ($oldest_entry) = $self->oldest_mtime(@{$bucket});

        # of the bucket, find the file most embedded in the file system
        my @to_link = $self->more_linked(@{$bucket});
        my $most_linked_entry = shift @to_link;
        foreach my $entry (@to_link) {
            # XXX there shouldn't be a need to update entries' link counts,
            # since this generates all the instructions at once
            push @inst, Directory::Simplify::Instruction::Hardlink->new(
                source => $most_linked_entry,
                target => $entry,
            );
            push @inst, Directory::Simplify::Instruction::CopyTimestamp->new(
                source => $oldest_entry,
                target => $entry,
            );
        }
        if (&Scalar::Util::refaddr($most_linked_entry) != &Scalar::Util::refaddr($oldest_entry)) {
            # most_linked_entry should get its timestamp updated
            push @inst, Directory::Simplify::Instruction::CopyTimestamp->new(
                source => $oldest_entry,
                target => $most_linked_entry,
            );
        }
    }
    @inst
}

package Directory::Simplify::FileHash;
use strict;
use warnings;
require Digest::SHA;

=head1 DESCRIPTION

Object for abstracting management of a hashed filesystem

=head1 COPYRIGHT

Copyright (C) 2010-2020 Dan Church.

License GPLv3+: GNU GPL version 3 or later (L<http://gnu.org/licenses/gpl.html>).

This is free software: you are free to change and redistribute it.

There is NO WARRANTY, to the extent permitted by law.

=head1 AUTHOR

Written by Dan Church S<E<lt>amphetamachine@gmail.comE<gt>>

=cut

sub new {
    my $class = shift;
    return bless {
        _entries => {},
        _files_in_hash => {},
        @_,
    }, $class;
}

sub add {
    require Cwd;
    my $self = shift;
    my $ctx = $self->{_ctx};
    unless (defined $ctx) {
        $ctx = $self->{_ctx} = Digest::SHA->new;
    }
    foreach my $filename (@_) {
        $filename = Cwd::abs_path($filename);
        unless ($self->{_files_in_hash}->{$filename}) {
            my $entry = {};
            (@{$entry}{qw/ name dev ino mode nlink uid gid rdev size
                atime mtime ctime blksize blocks /})
            = ($filename, lstat $filename);

            $ctx->addfile($filename);
            my $hash = $ctx->hexdigest;
            unless (defined $self->{_entries}->{$hash}) {
                $self->{_entries}->{$hash} = [];
            }
            push @{$self->{_entries}->{$hash}}, $entry;
        }
        $self->{_files_in_hash}->{$filename} = 1;
    }
}

sub entries {
    my $self = shift;
    values %{$self->{_entries}}
}
