#!/bin/bash
# vi: et sts=4 sw=4 ts=4

LOADS_HUD=(
    # HUD (requires `hud_scale 1` in ~/.config/zandronum/autoexec.cfg)
    #'HXRTCHUD-DOOM_V1.2/HXRTCHUD-DOOM_V1.2.PK3'
    #'HUD/Simple_Hud_V1/SHud_16_9.pk3'
    #REPLACED:'HUD/UDV_v1.61_GZDoomOnly.1/UDV_v1.61_A_BASE_GZDoomOnly.pk3'
    #REPLACED:'HUD/UDV_v1.62/UDV_v1.62_A_BASE.pk3'
    'HUD/UDV_v1.71/UDV_v1.71_A_BASE.pk3'
)

LOADS_GRAPHICS=(
    #spriteHDpublic6/spriteHDpublic6.pk3
    # textures
    #REPLACED:'textures/Brutal_Doom_141_edition_2.0/BD141 DHTP HDtextures.pk3'
    'textures/dhtp/zandronum-dhtp-20161017.pk3'

#   #'textures/Brutal_Doom_141_edition_2.0/BDJ141.pk3' # crash
    #REPLACED:'textures/Brutal_Doom_141_edition_2.0/Brutal Doom 141 hud GZDoomOnly.pk3'
    #NEW_VERSION:'textures/Brutal_Doom_141_edition_2.0/HD gore , items, lamps , barrels etc.pk3'
    #REPLACED:'textures/Brutal_Doom_141_edition_2.0/SBrightmaps.pk3'
    #SUCKS:'textures/Brutal_Doom_Redemption_3.0/DOOM64SGnew.pk3'
    #SUCKS:'textures/Brutal_Doom_Redemption_3.0/DOOM64SSGnew.pk3'
    'textures/Brutal_Doom_Redemption_3.0/HD gore , items, lamps , barrels etc fixed.pk3'

    # brightmaps
    'resources/Sbrightmaps/SBrightmaps.pk3'

    # weapon animations
    'resources/animations/pk_anim1.wad'
)

LOADS=(
    # music
    'DoomMetalVol4/DoomMetalVol4.wad'
    # sound
    'sound/pk_doom_sfx/pk_doom_sfx_20120224.wad'

)

while getopts 'HGh' flag; do
    case "$flag" in
        'h')
            # use Taggart's HUD
            # disable HUD
            LOADS_HUD=(
                'HUD/TaggartHUD.1/TaggartHUD.wad'
            )
            ;;
        'H')
            # disable HUD
            LOADS_HUD=()
            ;;
        'G')
            # disable graphics
            LOADS_GRAPHICS=()
            ;;
        *)
            HELP_MESSAGE 1
            ;;
    esac
done

shift "$((OPTIND-1))"

LOADS+=(
    "${LOADS_HUD[@]}"
    "${LOADS_GRAPHICS[@]}"
)

exec zandronum "${LOADS[@]}" "$@"
