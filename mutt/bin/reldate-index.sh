#!/bin/bash
# vi: noet sts=4 sw=4 ts=4

# format relative time like ls(1) [kinda]

MIDNIGHT=$(date -d '00:00' '+%s')

if [[ $1 -lt $MIDNIGHT ]]; then
	DF='%b %e'
else
	DF='%H:%M'
fi

printf "%s%6($DF)T%s" \
	"$2" \
	"$1" \
	"$3"
