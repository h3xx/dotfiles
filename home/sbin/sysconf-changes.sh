#!/bin/bash
# vi: et sts=4 sw=4 ts=4

# Version 1.2

SYSCONFDIRS=(
    /etc
    # system-wide vimrc has been known to stage changes with a .new file
    /usr/share/vim
)

APPLY_ALL=0
USE_COLORDIFF=1

while getopts 'aC' FLAG; do
    case "$FLAG" in
        'a')
            APPLY_ALL=1
            ;;
        'C')
            USE_COLORDIFF=0
            ;;
    esac
done

shift "$((OPTIND-1))"

# check to see if colordiff(1) is installed
if [[ $USE_COLORDIFF -ne 0 ]] &&
    ! type colordiff &>/dev/null; then
    USE_COLORDIFF=0
fi

DIFF_OPTS=(
    --side-by-side
    --report-identical-files
    --suppress-common-lines
    #--context=3
)

DIFFTOOL=vimdiff

report_change() {
    local \
        OLD_CONF=$1 \
        NEW_CONF=$2

    if [[ -z $NEW_CONF ]]; then
        NEW_CONF=${OLD_CONF}.new
    fi

    if [[ -f $OLD_CONF && -f $NEW_CONF ]]; then

        echo '*****'
        if [[ $USE_COLORDIFF -ne 0 ]]; then
            diff "${DIFF_OPTS[@]}" -- "$OLD_CONF" "$NEW_CONF" |colordiff
        else
            diff "${DIFF_OPTS[@]}" -- "$OLD_CONF" "$NEW_CONF"
        fi
        echo '*****'
    else
        printf 'Error finding changes for configuration file "%s" => "%s"\n' \
            "$OLD_CONF" \
            "$NEW_CONF" \
            >&2
    fi
}

accept_change() {
    local \
        OLD_CONF=$1 \
        NEW_CONF=$2

    if [[ -z $NEW_CONF ]]; then
        NEW_CONF=$OLD_CONF.new
    fi

    if [[ -f $OLD_CONF && -f $NEW_CONF ]]; then
        mv -v -- "$NEW_CONF" "$OLD_CONF" || exit 1
    else
        printf 'error applying changes for configuration file "%s" => "%s"\n' "$OLD_CONF" "$NEW_CONF" >&2
    fi
}

reject_change() {
    local \
        OLD_CONF=$1 \
        NEW_CONF=$2

    if [[ -z $NEW_CONF ]]; then
        NEW_CONF=$OLD_CONF.new
    fi

    if [[ -f $NEW_CONF ]]; then
        rm -fv -- "$NEW_CONF" || exit 1
    else
        printf 'Couldn'\''t delete file "%s"\n' \
            "$NEW_CONF" \
            >&2
    fi
}

edit_change() {
    local \
        OLD_CONF=$1 \
        NEW_CONF=$2

    if [[ -z $NEW_CONF ]]; then
        NEW_CONF=${OLD_CONF}.new
    fi

    $DIFFTOOL "$OLD_CONF" "$NEW_CONF"
}

prompt_change() {
    local \
        OLD_CONF=$1 \
        NEW_CONF=$2 \
        ANSWER

    if [[ -z $NEW_CONF ]]; then
        NEW_CONF=${OLD_CONF}.new
    fi

    if [[ -f $OLD_CONF && -f $NEW_CONF ]]; then
        # Show the user what they're accepting
        report_change "$OLD_CONF" "$NEW_CONF"

        if [[ $APPLY_ALL -ne 0 ]]; then
            # User wants to install all of them
            accept_change "$OLD_CONF" "$NEW_CONF"
        else
            read -r -p "$OLD_CONF => $NEW_CONF [y/N/e/d/a]? " ANSWER
            case "${ANSWER//[A-Z]/[a-z]}" in
                'a')
                    APPLY_ALL=1
                    accept_change "$OLD_CONF" "$NEW_CONF"
                    ;;
                'y')
                    accept_change "$OLD_CONF" "$NEW_CONF"
                    ;;
                'd')
                    reject_change "$OLD_CONF" "$NEW_CONF"
                    ;;
                'e')
                    edit_change "$OLD_CONF" "$NEW_CONF"
                    prompt_change "$OLD_CONF" "$NEW_CONF"
                    ;;

                #*)
                    # do nothing...
            esac
        fi
    fi
}


if [[ $# -eq 1 ]]; then
    # We're being called from find(1) or on a single file

    for NCONF; do
        prompt_change "$(dirname -- "$NCONF")/$(basename -- "$NCONF" .new)" "$NCONF"
    done
else
    # We're scheduling

    # Send myself a message
    PASS_OPTS=()
    if [[ $APPLY_ALL -ne 0 ]]; then
        PASS_OPTS+=('-a')
    fi
    if [[ $USE_COLORDIFF -eq 0 ]]; then
        PASS_OPTS+=('-C')
    fi

    find "${SYSCONFDIRS[@]}" \
        -type f \
        -name '*.new' \
        -exec "$0" "${PASS_OPTS[@]}" {} \;
fi
