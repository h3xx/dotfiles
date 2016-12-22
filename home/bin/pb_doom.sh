#!/bin/sh

LOADS_HUD=(
	'HUD/UDV_v1.71/UDV_v1.71_A_BASE.pk3'
	#OPTIONAL:'HUD/UDV_v1.71/UDV_v1.71_B_ADD_IN_Mod_ProjectBrutality.pk3'
)

LOADS=(
	# music
	'DoomMetalVol4/DoomMetalVol4.wad'
	# textures
	#REPLACED:'textures/Brutal_Doom_141_edition_2.0/BD141 DHTP HDtextures.pk3'
	'textures/dhtp/zandronum-dhtp-20161017.pk3'

	# TC
	'Project_Brutality_12-1-15/Project Brutality.pk3'
	'Project_Brutality_12-1-15/Misc/Allow_SV_Cheats.pk3'
)

while getopts 'Hh' flag; do
	case "$flag" in
		'H')
			# disable HUD
			LOADS_HUD=()
			;;
		*)
			HELP_MESSAGE 1
			;;
	esac
done

shift "$((OPTIND-1))"

LOADS+=("${LOADS_HUD[@]}")

exec zandronum "${LOADS[@]}" "$@"
