#!/bin/bash
# vi: et sts=4 sw=4 ts=4

LOADS=(
    StrifeCover/StrifeMusic.pk3
)
exec zandronum "${LOADS[@]}" "$@"
