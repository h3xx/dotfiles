#!/usr/bin/perl -w
use strict;

use MP3::Tag;

foreach my $file (@ARGV) {
	(my $mp3 = MP3::Tag->new($file))
		->get_tags;
	if ($mp3->have_id3v2_frame('APIC')) {
		print STDERR "`$file' has an attached picture";
		$mp3->config('id3v2_shrink'	=> 1,
			'id3v2_minpadding'	=> 0,
			'id3v2_sizemult'	=> 1,
			'id3v2_mergepadding'	=> 1);
		$mp3->set_id3v2_frame('APIC');
		$mp3->{'ID3v2'}->write_tag;
		print STDERR " (removed)\n";
	}
}
