#!/usr/bin/perl -w
use strict;
our $VERSION = 0.08;

sub HELP_MESSAGE {
	my $fh = shift;
	print $fh <<EOF
Usage: $0 FILES
Transform filenames of audio files so they contain all relevant metadata.

  -v			Verbose output.
  -f			Force overwrite of renamed files.
  -D			Dry run; don't perform any actions.
  -a ARTIST		Assume the album artist is ARTIST.
  -M			Assume MP3.
  -F			Assume FLAC.
  -O			Assume OGG.
  -C			Use compilation mode
			("ALBUM - YEAR - TRACK# - ARTIST - TITLE")

Copyright (C) 2010-2014 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
;

	exit 0;
}

require File::LibMagic;
use Cwd			qw/ abs_path /;
use Getopt::Std	qw/ getopts /;

# D => dry run
# f => force overwrite
# v => verbose
&getopts('fDva:FMOC', \ my %opts);

# tagformats determines how to format the different parts of the tag when used
# in a filename
my %tagformats;

@tagformats{qw/
	TITLE ARTIST ALBUM
		GENRE COMPOSER PERFORMER LICENSE ENCODED-BY
	DISCNUMBER
	TRACKNUMBER
	TRACKTOTAL
	DATE
	/} = (

	('%s') x 8,
	'(Disc %d)',
	sub {
		# if number, %02d, else %2s
		$_[0] =~ /\D/ ? '%2s' : '%02d'
	},
	'of %02d',
	'(%04d)',
);

my $flm = File::LibMagic->new;

sub taghash {
	my $filename = &abs_path(shift);

	my %tags;

	if (-e $filename) {
		my $mime_short;
		if ($opts{'M'}) {
			$mime_short = 'audio/mpeg';
		} elsif ($opts{'F'}) {
			$mime_short = 'audio/x-flac';
		} elsif ($opts{'O'}) {
			$mime_short = 'application/ogg';
		} else {
			# checktype_* will return the `charset=' attribute as well
			#
			# for instance: `audio/mpeg; charset=binary'
			($mime_short = $flm->checktype_filename($filename))
				=~ s/;.*$//;
		}

		if ($mime_short eq 'audio/mpeg') {
			%tags = &mp3_taghash($filename);
		} elsif ($mime_short eq 'audio/x-flac') {
			%tags = &flac_taghash($filename);
		} elsif ($mime_short eq 'application/ogg') {
			%tags = &ogg_taghash($filename);
		} else {
			print STDERR "unknown mimetype for file `$filename': $mime_short";
		}
	}

	wantarray ? %tags : \%tags
}

sub mp3_taghash {
	my $filename = shift;

	require MP3::Tag;
	(my $mp3 = MP3::Tag->new($filename))
		->get_tags;

	# make sure the library is reading the original performer's and
	# the composers' names right (also prevents them from being
	# superceded by the 'artist' tag value)
	$mp3->config('performer', 'TOPE');
	$mp3->config('composer', 'TCOM');

	# transform into a Vorbis-tag-styled hash
	my %tags = (
		'TITLE'		=> ($mp3->title)[0] || undef,
		'ARTIST'	=> ($mp3->artist)[0] || undef,
		'ALBUM'		=> ($mp3->album)[0] || undef,
		'DISCNUMBER'	=> ($mp3->get_id3v2_frames('TPOS'))[1] || undef,
		'DATE'		=> ($mp3->year)[0] || undef,
		'TRACKNUMBER'	=> (split /\//, $mp3->track)[0] || undef,
		'TRACKTOTAL'	=> (split /\//, $mp3->track)[1] || undef,
		'GENRE'		=> ($mp3->genre)[0] || undef,
		'DESCRIPTION'	=> ($mp3->comment)[0] || undef,
		'COMPOSER'	=> ($mp3->composer)[0] || undef,
		'PERFORMER'	=> ($mp3->performer)[0] || undef,
		'COPYRIGHT'	=> ((($mp3->get_id3v2_frames('TCOP'))[1] || '') =~ /^\(C\) (.*)$/)[0] || undef,
		'LICENSE'	=> (($mp3->get_id3v2_frames('WXXX'))[1] || {})->{'URL'} || undef,
		'ENCODED-BY'	=> ($mp3->get_id3v2_frames('TENC'))[1] || undef,
	);

	wantarray ? %tags : \%tags
}

sub flac_taghash {
	my $filename = shift;

	require Audio::FLAC::Header;
	my $flac = Audio::FLAC::Header->new($filename);

	# if this seems too easy, I don't know what to tell you
	my $tags = $flac->tags;
	map { (uc $_, $tags->{$_}) } keys %{$tags}
}

sub ogg_taghash {
	my $filename = shift;

	require Ogg::Vorbis;
	my $ogg = Ogg::Vorbis->new;

	open my $ifh, '<', $filename
		or die "cannot open file `$filename' for reading: $!";

	$ogg->open($ifh);

	my $tags = $ogg->comment;
	map { (uc $_, $tags->{$_}) } keys %{$tags}
}

sub tag_filename {
	my $filename = shift;

	my %tags = &taghash($filename);

	# eliminate ` (Disc \d)' from the album title if we have DISCNUMBER
	$tags{'ALBUM'} =~ s/\s*[(\[]?Disc\s*\d*.*[\])]?\s*$//
		if defined $tags{'DISCNUMBER'};

	if (defined $opts{'a'}) {
		# user specified overriding album artist
		$tags{'ARTIST'} = $opts{'a'};
	}

	my (@patterns, @parts, @layout);
	if ($opts{'C'}) {
		@layout = qw/
		ALBUM
		DISCNUMBER
		DATE
		TRACKNUMBER
		ARTIST
		TITLE
		/;
	} else {
		@layout = qw/
		ARTIST
		ALBUM
		DISCNUMBER
		DATE
		TRACKNUMBER
		TITLE
		/;
	}

	foreach my $tagname (@layout) {

		if (defined $tags{$tagname} and length $tags{$tagname}) {
			my $selected_format = $tagformats{$tagname};
			if (ref $selected_format eq 'CODE') {
				$selected_format = &{$selected_format}($tags{$tagname});
			}
			push @patterns, $selected_format;
			push @parts, $tags{$tagname};
		}
	}

	unless (@patterns) {
		print STDERR "Warning: Not enough tag information for file `$filename'\n";
		return $filename;
	}

	# make sure we don't have directory separators in the name
	s#/#--#g for @parts;

	sprintf
		# patterns
		join (' - ', @patterns) .
		# extension
		'.' . (split /\./, $filename)[-1],

		@parts
}

# works like `mkdir -p'
sub mkpath {
	my $path = shift;

	my $cdir = (($path =~ m#^/#) ? '' : '.'); # detect absolute paths
	foreach my $subdir (split /\/+/, $path) {
		length $subdir or next;
		$cdir .= '/' . $subdir;
		mkdir $cdir;
	}
}

foreach my $filename (@ARGV) {
	my $new_filename = &tag_filename($filename);

	next if $filename eq $new_filename;

	printf STDERR "`%s\' => `%s'\n", $filename, $new_filename;
	if ($opts{'f'} or ! -e $new_filename) {
		print STDERR "`$filename' => `$new_filename'\n" if $opts{'D'} or $opts{'v'};
		rename $filename, $new_filename unless $opts{'D'};
	} else {
		print STDERR "File exists, skipping.\n";
	}
}
