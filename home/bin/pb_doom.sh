#!/bin/sh

LOADS_HUD=(
	# HUD (requires `hud_scale 1` in ~/.config/zandronum/autoexec.cfg)
	#'HXRTCHUD-DOOM_V1.2/HXRTCHUD-DOOM_V1.2.PK3'
	#'HUD/Simple_Hud_V1/SHud_16_9.pk3'
	#REPLACED:'HUD/UDV_v1.61_GZDoomOnly.1/UDV_v1.61_A_BASE_GZDoomOnly.pk3'
	#REPLACED:'HUD/UDV_v1.62/UDV_v1.62_A_BASE.pk3'
	#REPLACED:'HUD/UDV_v1.62/UDV_v1.62_B_PB_PATCH.pk3'
	'HUD/UDV_v1.71/UDV_v1.71_A_BASE.pk3'
	#'HUD/UDV_v1.71/UDV_v1.71_B_ADD_IN_Mod_ProjectBrutality.pk3'
)

LOADS=(
	#spriteHDpublic6/spriteHDpublic6.pk3
	# music
	'DoomMetalVol4/DoomMetalVol4.wad'
	# textures
	#REPLACED:'textures/Brutal_Doom_141_edition_2.0/BD141 DHTP HDtextures.pk3'
	'textures/dhtp/zandronum-dhtp-20161017.pk3'

#	#'textures/Brutal_Doom_141_edition_2.0/BDJ141.pk3' # crash
	#REPLACED:'textures/Brutal_Doom_141_edition_2.0/Brutal Doom 141 hud GZDoomOnly.pk3'
	#NEW_VERSION:'textures/Brutal_Doom_141_edition_2.0/HD gore , items, lamps , barrels etc.pk3'
	#REPLACED:'textures/Brutal_Doom_141_edition_2.0/SBrightmaps.pk3'
	#SUCKS:'textures/Brutal_Doom_Redemption_3.0/DOOM64SGnew.pk3'
	#SUCKS:'textures/Brutal_Doom_Redemption_3.0/DOOM64SSGnew.pk3'
	#'textures/Brutal_Doom_Redemption_3.0/HD gore , items, lamps , barrels etc fixed.pk3'

	# brightmaps
	#'resources/Sbrightmaps/SBrightmaps.pk3'

	# TC
	#'brutalv20/brutalv20.pk3'

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
