#!/usr/bin/perl
# Author: Todd Larason <jtl@molehill.org>
# $XFree86: xc/programs/xterm/vttests/256colors2.pl,v 1.2 2002/03/26 01:46:43 dickey Exp $
# modified by Dan Church to output the terminal color numbers in order to aid in writing Vim color schemes
# modified AGAIN by Dan Church to provide better contrast between the colors and the numbers

sub luminance {
	my ($red, $green, $blue) = @_;
	# source: https://en.wikipedia.org/wiki/Relative_luminance
	0.2126 * $red + 0.7152 * $green + 0.0722 * $blue
}

# use the resources for colors 0-15 - usually more-or-less a
# reproduction of the standard ANSI colors, but possibly more
# pleasing shades

# colors 16-231 are a 6x6x6 color cube
for ($red = 0; $red < 6; $red++) {
    for ($green = 0; $green < 6; $green++) {
	for ($blue = 0; $blue < 6; $blue++) {
	    printf("\x1b]4;%d;rgb:%2.2x/%2.2x/%2.2x\x1b\\",
		   16 + ($red * 36) + ($green * 6) + $blue,
		   ($red ? ($red * 40 + 55) : 0),
		   ($green ? ($green * 40 + 55) : 0),
		   ($blue ? ($blue * 40 + 55) : 0));
	}
    }
}

# colors 232-255 are a grayscale ramp, intentionally leaving out
# black and white
for ($gray = 0; $gray < 24; $gray++) {
    $level = ($gray * 10) + 8;
    printf("\x1b]4;%d;rgb:%2.2x/%2.2x/%2.2x\x1b\\",
	   232 + $gray, $level, $level, $level);
}


# display the colors

# first the system ones:
print "System colors:\n";
for ($color = 0; $color < 8; $color++) {
    printf "\x1b[48;5;%dm%3s ", $color, $color;
}
print "\x1b[0m\n";
for ($color = 8; $color < 16; $color++) {
    printf "\x1b[48;5;%dm%3s ", $color, $color;
}
print "\x1b[0m\n\n";

# now the color cube
print "Color cube, 6x6x6:\n";
for ($green = 0; $green < 6; $green++) {
    for ($red = 0; $red < 6; $red++) {
	for ($blue = 0; $blue < 6; $blue++) {
	    $color = 16 + ($red * 36) + ($green * 6) + $blue;
	    $fg = (&luminance($red, $green, $blue) < 3) ?
	    '37' : # white
	    '30'; # black
	    printf "\x1b[%d;48;5;%dm%3s ", $fg, $color, $color;
	}
	print "\x1b[0m ";
    }
    print "\n";
}


# now the grayscale ramp
print "Grayscale ramp:\n";
for ($color = 232; $color < 256; $color++) {
	$fg = ($color < 244) ?
	'37' : # white
	'30'; # black
	printf "\x1b[%d;48;5;%dm%3s ", $fg, $color, $color;
}
print "\x1b[0m\n";
