#!/bin/bash
# vi: et sts=4 sw=4 ts=4

LOADS=(
    hexen_high_resolution_pack/hexen_high_resolution_pack.pk3
    ketchuptest4/ketchuptest4.pk3

)
exec zandronum "${LOADS[@]}" "$@"
