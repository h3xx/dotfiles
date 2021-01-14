#!/bin/bash
# vi: et sts=4 sw=4 ts=4

RES_COL=15
RES_COL2=14
SHOW_ERRORS=1
MOVE_TO_COL=$'\e['"${RES_COL}G"
SETCOLOR_HIGHPOWER=$'\e[1;32m'
SETCOLOR_LOWPOWER=$'\e[1;36m'
SETCOLOR_FAILURE=$'\e[1;31m'
SETCOLOR_NORMAL=$'\e[0;39m'

if ! hash smartctl &>/dev/null; then
    echo 'smartctl: Not found' >&2
    exit 1
fi

is_low_power() {
    local DEV=$1 ST
    if [[ ! -e $DEV ]]; then
        # Missing
        return 3
    #elif [[ ! -b $DEV ]]; then
        # Incompatible
        #return 2
    fi

    # smartctl only retuns 2 if the drive is in standby mode
    smartctl -i -q errorsonly -n standby "$DEV" >/dev/null
    case "$?" in
        0)
            # High-power mode
            return 1
            ;;
        2)
            # Lower-power (standby) mode
            return 0
            ;;
        *)
            # Other error status (such as drive doesn't support S.M.A.R.T.
            # commands)
            return 2
            ;;
    esac
}

report_dev() {
    local DESC="  $1"
    is_low_power "$1"
    case "$?" in
        0)
            echo_lowpower "$1"
            ;;
        1)
            echo_highpower "$1"
            ;;
        2)
            if [[ $SHOW_ERRORS -ne 0 ]]; then
                echo_error "$1"
                return 1
            fi
            ;;
        3)
            if [[ $SHOW_ERRORS -ne 0 ]]; then
                echo_missing "$1"
                return 1
            fi
            ;;
    esac
}

print_stat() {
    printf "%-${RES_COL2}s"'[%s %-4s %s]\n' \
        "  $1" \
        "$2" \
        "$3" \
        "$SETCOLOR_NORMAL"
}

echo_highpower() {
    print_stat "$1" "$SETCOLOR_HIGHPOWER" 'HIGH'
}

echo_lowpower() {
    print_stat "$1" "$SETCOLOR_LOWPOWER" 'LOW'
}

echo_error() {
    print_stat "$1" "$SETCOLOR_FAILURE" 'ERROR'
}

echo_missing() {
    print_stat "$1" "$SETCOLOR_FAILURE" 'N/A'
}

if [[ $# -gt 0 ]]; then
    DEVS=("$@")
else
    shopt -s nullglob
    SHOW_ERRORS=0
    DEVS=(/dev/sd[a-z])
fi

for D in "${DEVS[@]}"; do
    report_dev "$D"
done
