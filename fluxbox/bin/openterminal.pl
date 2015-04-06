#!/usr/bin/perl -w
use strict;

# Starts a program in screen and opens a terminal to it.
# Does not start the program if it has already been started.

use File::Basename	qw/ basename /;
use Getopt::Std		qw/ getopts /;

use constant PROCDIR	=> '/proc';
use constant SCREEN	=> '/usr/bin/SCREEN';

my %opts = (
	'b'	=> 0,
);

&getopts(':b', \%opts);

my $executable = $opts{'b'} ? &basename($ARGV[0]) : $ARGV[0];

# if they didn't specify a full path, we're going to have to match by basename
$opts{'b'} if $ARGV[0] eq &basename($ARGV[0]);

$/ = "\0"; # for reading /proc/$PID/cmdline files

opendir PROC, PROCDIR;
my $screen_pid = (grep { /^\d+$/ &&  eq &cmdline($_)

sub cmdline {
	my @cmd =
		open CMDLINE, '<'.PROCDIR.'/'.shift.'/cmdline' ?
			() :
			<CMDLINE>;
	
	close CMDLINE;

	$cmd[0] = &basename($cmd[0]) if $opts{'b'};

	@cmd
}
