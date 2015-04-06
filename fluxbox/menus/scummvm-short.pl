#!/usr/bin/perl -w
use strict;

# parses ${HOME}/.scummvmrc and generates a fluxbox-compatible menu in ./scummvm

open MENU, '>scummvm';
print MENU "[submenu] (scummvm) <~/.fluxbox/icons/scummvm.xpm>\n\t[exec] (scummvm) {scummvm} <~/.fluxbox/icons/scummvm.xpm>\n";

open SCUMMVMRC, "<$ENV{HOME}/.scummvmrc";

foreach (sort <SCUMMVMRC>) {
	if (/^\[(.+)\]$/ && ! /^\[scummvm\]$/) {
		print MENU "\t[exec] ($1) {scummvm $1}\n"
	}
}
close SCUMMVMRC;

print MENU "[end]\n";
close MENU;
