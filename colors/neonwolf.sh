#!/bin/bash
# vi: et sts=4 sw=4 ts=4

NEONWOLF_PALETTE=(
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
BADWOLF_PALETTE_AUX=(
	16
	27
	137
	173
	211
	214
	#221
	# grays
	241
)

256colors2.pl \
    "$@" \
    "${NEONWOLF_PALETTE[@]}" \
    "${BADWOLF_PALETTE_AUX[@]}"
