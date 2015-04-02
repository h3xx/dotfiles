#!/usr/bin/perl -w
# Looks through a directory and throws out duplicate files.
# This is especially useful when used on a maildir.
# UPDATE: outputs UNIX-style messages now (ala 'rm -v,' 'ln -v,' etc.)

use strict;

use File::Find qw/ find /;
use Digest::MD5;
use Getopt::Std	qw/ getopts /;

&getopts('dz', \ my %opts);

my %files;

# correct relative paths
# OR if no directories given, search the current directory
push @ARGV, $ENV{'PWD'} unless map { s#^([^/])#$ENV{'PWD'}/$1# } @ARGV;

&find (\&findexec, @ARGV);

sub findexec {
	# make sure the file exists and it's not a link
	if (-f $File::Find::name && ! -l $File::Find::name) {
		# perform a stat on the file
		my $entry;
		(@{$entry}{qw/ name dev ino mode nlink uid gid rdev size
				atime mtime ctime blksize blocks /})
			= ($File::Find::name, lstat $File::Find::name);

		# ignore if empty and the user doesn't care about them
		return if $opts{'z'} and ! $entry->{'size'};

		# perform an MD5 hash on the file
		my $ctx = Digest::MD5->new;
		open FILE, "<$File::Find::name";
		$ctx->addfile(*FILE);
		my $digest = $ctx->hexdigest; # (reading the value destroys it)

		# check to see if we've come across a file with the same MD5
		if (exists $files{$digest}) {
			my $curr_entry = $files{$digest};

			# don't waste my time
			return if $curr_entry->{'name'} eq $entry->{'name'}
				or $curr_entry->{'dev'} eq $entry->{'dev'}
				and $curr_entry->{'ino'} eq $entry->{'ino'};

			# identical files should be the same size (I'm paranoid
			# of checksumming procedures); if it's not, there's a
			# problem with the checksumming procedure or this
			# script is processing WAY too many files
			die 'ERROR: checksums identical for two non-identical'.
			"files:\n$curr_entry->{'name'}\n$entry->{'name'}\nMD5:".
			"$digest\n(this is probably a limit of MD5; try".
			'processing fewer files)'
				if $curr_entry->{'size'} != $entry->{'size'};

			# find file less embedded in the file sys
			my ($less_linked, $more_linked) = sort
				{$a->{'nlink'} <=> $b->{'nlink'}}
				($entry, $curr_entry);

			unlink $less_linked->{'name'} unless $opts{'d'};
			print "removed `$less_linked->{'name'}'\n";

			# update entry in file table
			$files{$digest} = $more_linked;
		} else {
			# the file is unique (as far as we know)
			# create a new entry in the hash table
			$files{$digest} = $entry;
		}
	}
}
