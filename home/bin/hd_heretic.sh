#!/bin/sh

LOADS=(
	heretic_high_resolution_pack/heretic_high_resolution_pack.pk3
	HR_HereticWidescreenv2/HR_HereticWidescreenv2.wad
	ketchuptest4/ketchuptest4.pk3


	#WOM: NO
	#'WOM_Final.3/WOM073.WAD'
	#'WOM_Final.3/WOMFinal.3.ded'
	#'WOM_Final.3/bag fix for HZONE/bag.ded'
	#'WOM_Final.3/bag fix for HZONE/bag.wad'

)
exec zandronum "${LOADS[@]}" "$@"
