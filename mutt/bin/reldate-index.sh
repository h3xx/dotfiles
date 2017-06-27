#!/bin/bash

# format relative time like ls(1) [kinda]

midnight=$(date -d '00:00' '+%s')

if [[ $1 -lt $midnight ]]; then
	df='%b %e'
else
	df='%H:%M'
fi

printf "%s%6($df)T%s" \
	"$2" \
	"$1" \
	"$3"
