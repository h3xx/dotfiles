#!/bin/sh

neonwolf_palette=(
	39
	81
	82
	121
	154
	165
	166
	196
	222
	# grays
	232
	235
	238 # used in tig as digraph line color, nowhere else
	240
	255
)

# colors that were part of the original palette, but that I've been ignoring
badwolf_palette_aux=(
	16
	27
	137
	173
	211
	214
	221
	# grays
	241
)

SCRIPTDIR="$(dirname "$0")"
exec "$SCRIPTDIR"/256colors2.pl "${neonwolf_palette[@]}" "${badwolf_palette_aux[@]}"
