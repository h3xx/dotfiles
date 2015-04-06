#!/usr/bin/perl -w
use strict;

use constant ICONS	=> "$ENV{HOME}/.fluxbox/icons";
use constant ICONS_	=> "~/.fluxbox/icons";

use constant AUDICON	=> '~/audicon';

# project audicon; program names and arguments
my %audicon = (
	'audacity'	=> '',
	'scilab'	=> '-e \'cd '.AUDICON.'\'',
	'grip'		=> '',
	'gentoo'	=> '-1 '.AUDICON.'/music -2 '.AUDICON,
	'easytag'	=> AUDICON.'/music',
	'sqlitebrowser'	=> AUDICON.'/samples.db'
);

# create menu
open PROJECTS, '>projects';
print PROJECTS '# current projects
[submenu] (projects)
	[submenu] (audicon)
';

foreach my $prog (keys %audicon) {
	print PROJECTS "\t\t[exec] ($prog) {$prog".
       		($audicon{$prog} ne '' ? " $audicon{$prog}}" : '}').
		( -f ICONS."/$prog.xpm" ? ' <'.ICONS_."/$prog.xpm>\n" : "\n");
}
print PROJECTS "\t[end]\n[end]\n";

