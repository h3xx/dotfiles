#!/bin/sh

LOADS=(
	StrifeCover/StrifeMusic.pk3
)
exec zandronum "${LOADS[@]}" "$@"
