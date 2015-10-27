#!/usr/bin/perl -w
use strict;

sub line {
	my ($start_char, $chars) = @_;

	my $out = "";

	for (my $o = 0; $o < $chars; ++$o) {
		last if $start_char + $o > 0xff;
		$out .= chr($start_char + $o) . " ";
	}

	$out
}

sub sg_line {
	"\e)2\x0e" . &line(@_) . "\x0f";
}

my $chars_per_line=16;

for (my $ch = 0; $ch < 256; $ch+=$chars_per_line) {
	print &line($ch, $chars_per_line),
		"\n",
		&sg_line($ch, $chars_per_line),
		"\n";
}

__END__
print map {
	my $r = $_ .
	" \x0f".chr.
	" \e)0\x0e".chr;

	$r .=
	" \e)2\x0e".chr;


	"$r\n"
} 0..255;

print "\x0f";
