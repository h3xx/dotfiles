#!/usr/bin/perl -w
use strict;

our $VERSION = '1.2.3';

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

=item B<-s>

Generate symlinks only.

=item B<-S>

Do not generate ANY symlinks.

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

use File::Find		qw/ find /;
require Digest::SHA;
use Getopt::Std		qw/ getopts /;

sub HELP_MESSAGE {
#	my $fh = shift;
#	print $fh <<EOF
#Usage: $0 [DIRS]
#Simplify a directory by hard-linking identical files.
#
#  -v			Verbose output.
#  -f			Print a sum of the number of freed bytes.
#  -m REGEX		Only match file paths matching REGEX.
#  -M REGEX		Exclude file paths matching REGEX.
#  -s			Generate symlinks only.
#  -S			Do not generate ANY symlinks.
#  -z			Include zero-length files in search.
#
#By default, scans the current directory. Files not able to be hard-linked are
#symlinked by default.
#EOF
#;
	require Pod::Text;
	my ($fh, $pod) = (shift, Pod::Text->new);
	$pod->parse_from_file($0, $fh);

	exit 0;
}

my %opts = (
	v	=> 0,
	f	=> 0,
	m	=> '',
	M	=> '',
	s	=> 0,
	S	=> 0,
	z	=> 0,
);

&getopts('vfm:M:sSz', \%opts);

my %files;

# correct relative paths
# OR if no directories given, search the current directory
push @ARGV, $ENV{PWD} unless map { s#^([^/])#$ENV{PWD}/$1# } @ARGV;

my $freed_bytes = 0;

&find(\&findexec, @ARGV);

sub findexec {
	# outright skip directories (don't report skip)
	return if -d $File::Find::name;

	# limit to or exclude file patterns specified by `-m' or `-M',
	# respectively

	# truth table
	# -m matches	| -M is used & matches	| !return?
	# 0		| 0			| 0
	# 0		| 1			| 0
	# 1		| 0			| 1
	# 1		| 1			| 0
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

	#my $ctx = Digest::MD5->new;
	my $ctx = Digest::SHA->new;
	$ctx->addfile($File::Find::name);

	# save the hex digest because reading the value from
	# Digest::* destroys it
	my $digest = $ctx->hexdigest;

	# organize results from lstat into hash
	my $entry = {};
	(@{$entry}{qw/ name dev ino mode nlink uid gid rdev size
			atime mtime ctime blksize blocks /})
		= ($File::Find::name, lstat $File::Find::name);

	# skip zero-length files if wanted (`-z')
	return unless $opts{z} or $entry->{size};

	# check to see if we've come across a file with the same checksum
	unless (exists $files{$digest}) {
		# the file is unique (as far as we know)
		# create a new entry in the hash table
		$files{$digest} = $entry;
		return;
	}

	my $curr_entry = $files{$digest};

	# don't waste my time
	return if $curr_entry->{name} eq $entry->{name} or
		$curr_entry->{ino} == $entry->{ino};

	# identical files should be the same size (I'm paranoid
	# of checksumming procedures); if it's not, there's a
	# problem with the checksumming procedure or this
	# script is processing WAY too many files
	# (addendum: perhaps I should congratulate the user on
	# finding a collision in SHA-1)
	if ($curr_entry->{size} != $entry->{size}) {
		die "ERROR: checksums identical for two non-identical files!!!:\n".
		"files:\t`$curr_entry->{name}'\n".
		"\t`$entry->{name}'\n".
		"SHA1: ($digest)\n".
		'(this is probably a limit of SHA1; try processing fewer files)';
	}

	# find the oldest time stamp
	my ($atime, $mtime) = @{(sort
		{$a->{mtime} <=> $b->{mtime}}
		($entry, $curr_entry)
	)[0]}{qw/ atime mtime /};

	# find the file less embedded in the file system
	my ($less_linked, $more_linked) = sort
		{$a->{nlink} <=> $b->{nlink}}
		($entry, $curr_entry);

	# hard-linkable files must exist on the same device and
	# must not already be hard-linked
	if ($curr_entry->{dev} == $entry->{dev} &&
		! $opts{s}) {
		# attempt to unlink the file
		printf STDERR "removing file `%s'\n",
			$less_linked->{name} if $opts{v};
		unless (unlink $less_linked->{name}) {

			# couldn't do it; try more-linked file

			printf STDERR "Failed to remove file `%s': %s\n(using `%s')\n",
				$less_linked->{name},
				$!,
				$more_linked->{name}
			if $opts{v};

			# if we can't do this, there's no point
			# in continuing
			unless (unlink $more_linked->{name}) {
				printf STDERR "Failed to remove file `%s' (second failure on match): %s\nSkipping...\n",
					$more_linked->{name},
					$!
					if $opts{v};

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

		# update link count in our hash to reflect the
		# file system (referenced)
		++$more_linked->{nlink};

		# preserve older time stamp
		utime $atime, $mtime, $less_linked->{name};
	} elsif (! $opts{S}) {
		# files are on different drives;
		# most that can be done is to soft-link them

		unless (unlink $less_linked->{name}) {

			# couldn't do it; try more-linked file

			printf STDERR "couldn't remove file `%s' (using `%s')\n",
			$less_linked->{name},
			$more_linked->{name} if $opts{v};

			# if we can't do this, there's no point
			# in continuing
			unlink $more_linked->{name}
				or return;

			# the ol' switcheroo
			($more_linked, $less_linked) =
			($less_linked, $more_linked);

		}

		# we unlinked it or failed out
		$freed_bytes += $less_linked->{size};

		printf STDERR "soft-linking %s => %s\n",
			$less_linked->{name}, $more_linked->{name}
		if $opts{v};

		# create a soft link (TODO: relative links)
		symlink $more_linked->{name},
		$less_linked->{name};

		# preserve older time stamp
		utime $atime, $mtime, $less_linked->{name};
	}
	#} elsif (-l $File::Find::name) {
	#	# do something to simplify symlinks
	#	printf STDERR "FIXME: simplifying symlink `%s'\n",
	#	$File::Find::name
	#	if $opts{v};

	#	printf STDERR "symlink `%s' points to `%s'\n",
	#	$File::Find::name, readlink $File::Find::name;
}

printf STDERR "freed %d bytes (%0.4G %s)\n",
	$freed_bytes, &hr_size($freed_bytes)
		if $opts{f} or $opts{v};

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
