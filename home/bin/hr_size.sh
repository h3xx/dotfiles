#!/bin/bash
# vi: et sts=4 sw=4 ts=4

hr_size() (
    declare -i BYTES=$1

    #UNITS=(B KB MB GB TB PB EB ZB YB) # shell math can only go so far...
    UNITS=(B KB MB GB TB)
    FACT=1024
    THRESH=9/10
    DECIMALS=1
    DECIMALS_FACTOR=$(( 10 ** DECIMALS ))

    # cycle through units from largest to smallest, exiting when it finds the
    # largest applicable unit
    for (( EXP = ${#UNITS[@]} - 1; EXP > -1; --EXP )); do
        # check if the unit is close enough to the unit's size, within the
        # threshold
        if [[ $BYTES -gt $((FACT ** EXP * $THRESH)) ]]; then
            # we found the applicable unit

            # must multiply by a factor of 10 here to not truncate
            # the given number of decimal places after the point
            HR_VAL=$(( BYTES * DECIMALS_FACTOR / FACT ** EXP ))

            # put the decimal point in
            if [[ $DECIMALS -gt 0 ]]; then
                HR_VAL=$(( HR_VAL / DECIMALS_FACTOR )).$(( HR_VAL % DECIMALS_FACTOR ))
            fi

            HR_UNIT=${UNITS[$EXP]}
            break
        fi
    done

    if [[ -z $HR_UNIT ]]; then
        HR_VAL=$BYTES
        HR_UNIT=${UNITS[0]}
    fi

    printf '%s %s\n' "$HR_VAL" "$HR_UNIT"
)

hr_size "$1"
