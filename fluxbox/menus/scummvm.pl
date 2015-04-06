#!/usr/bin/perl -w
use strict;

# parses ${HOME}/.scummvmrc and generates a fluxbox-compatible menu in ./scummvm

open MENU, '>scummvm';
print MENU "[submenu] (scummvm) <~/.fluxbox/icons/scummvm.xpm>\n\t[exec] (scummvm) {scummvm} <~/.fluxbox/icons/scummvm.xpm>\n";

open SCUMMVMRC, "<$ENV{HOME}/.scummvmrc";

my $game_id;
foreach (<SCUMMVMRC>) {
	if (/^\[([^\]]+)\]$/ && ! /^\[scummvm\]$/) {
		$game_id = $1
	} elsif ($game_id && /^description=(.+)$/) {
		my $desc = $1;
		$desc =~ s/ \(English \(.+$//;
		$desc =~ s/(\))/\\$1/g;
		print MENU "\t[exec] ($desc) {scummvm $game_id}\n"
	}
}
close SCUMMVMRC;

print MENU "[end]\n";
close MENU;
