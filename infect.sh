#!/bin/bash
# vi: et sts=4 sw=4 ts=4

ask_yn() (
    PROMPT=$1
    DEFAULT=$2
    read -p "$PROMPT [$([[ $DEFAULT = 'y' ]] && echo 'Y/n' || echo 'y/N')]? " ANSWER
    [[ $ANSWER =~ [01NYny] ]] || ANSWER=$DEFAULT
    # return
    [[ $ANSWER =~ [1Yy] ]]
)

if ! ask_yn "This will infect your configuration files (nicely). Continue?" y; then
    echo 'Aborted.' >&2
    exit 1
fi

# Make it so e.g. bash/* will list .bashrc
shopt -s dotglob
# Make it so e.g. vim/!(.bsdvimrc) will NOT list .bsdvimrc
shopt -s extglob

# OPTIONS
DRY_RUN=0
FORCE=0
GUI=1
TERSE=1
# END OPTIONS

DOTFILES=$(dirname -- "$0")
RES_COL=80
MOVE_TO_COL=$'\033['"${RES_COL}G"
SETCOLOR_SUCCESS=$'\033[1;32m'
SETCOLOR_FAILURE=$'\033[1;31m'
SETCOLOR_WARNING=$'\033[1;33m'
SETCOLOR_NORMAL=$'\033[0;39m'
FAIL_CT=0
LINK_CT=0
DIR_CT=0

echo_success() {
    printf '%s[%s%s%s]\r' \
        "$MOVE_TO_COL" \
        "$SETCOLOR_SUCCESS" \
        $"  OK  " \
        "$SETCOLOR_NORMAL"
    if [[ -n $1 ]]; then
        printf '%s\n' "$1"
    fi
    return 0
}

echo_link() {
    printf '%s[%s%s%s]\r' \
        "$MOVE_TO_COL" \
        "$SETCOLOR_SUCCESS" \
        $" LINK " \
        "$SETCOLOR_NORMAL"
    if [[ -n $1 ]]; then
        printf '%s\n' "$1"
    fi
    return 0
}

echo_mkdir() {
    printf '%s[%s%s%s]\r' \
        "$MOVE_TO_COL" \
        "$SETCOLOR_SUCCESS" \
        $" DIR  " \
        "$SETCOLOR_NORMAL"
    if [[ -n $1 ]]; then
        printf '%s\n' "$1"
    fi
    return 0
}

echo_already_linked() {
    if [[ $TERSE -ne 1 ]]; then
        printf '%s[%s%s%s]\r' \
            "$MOVE_TO_COL" \
            "$SETCOLOR_SUCCESS" \
            $"  OK  " \
            "$SETCOLOR_NORMAL"
        if [[ -n $1 ]]; then
            printf '%s\n' "$1"
        fi
        return 0
    fi
}

echo_failure() {
    printf '%s[%s%s%s]\r' \
        "$MOVE_TO_COL" \
        "$SETCOLOR_FAILURE" \
        $"FAILED" \
        "$SETCOLOR_NORMAL"
    if [[ -n $1 ]]; then
        printf '%s\n' "$1"
    fi
    return 1
}

soft_link() {
    local \
        DST=$2 \
        LINK_RESULT \
        SRC=$1
    # Transform to prettier destination
    local DST_PRETTY=${DST/$HOME/\~}

    if [[ $(realpath "$SRC") = $(realpath "$DST") ]]; then
        echo_already_linked "$DST_PRETTY"
    else
        if [[ -e $DST && $FORCE -ne 1 ]]; then
            let ++FAIL_CT
            echo_failure "$DST_PRETTY already exists, not the same file"
        else
            # Transform to relative link
            # (This also preserves the fact it's a link to a link)
            SRC=$(realpath --relative-to="$(dirname "$DST")" "$(dirname -- "$SRC")")/$(basename -- "$SRC")
            if [[ $DRY_RUN -ne 1 ]]; then
                if ! LINK_RESULT=$(ln -sfv "$SRC" "$DST" 2>&1); then
                    let ++FAIL_CT
                    echo_failure "$LINK_RESULT"
                else
                    let ++LINK_CT
                    echo_link "$LINK_RESULT"
                fi
            else
                let ++LINK_CT
                echo_link "[$DST_PRETTY -> $SRC]"
            fi
        fi
    fi
}

soft_link_all() {
    local \
        DST_DIR=$1 \
        FILE \
        MKDIR_RESULT
    shift
    if [[ ! -d $DST_DIR ]]; then
        if [[ ! -e $DST_DIR ]]; then
            if [[ $DRY_RUN -ne 1 ]]; then
                if ! MKDIR_RESULT=$(mkdir -pv -- "$DST_DIR" 2>&1); then
                    let ++FAIL_CT
                    echo_failure "$MKDIR_RESULT"
                else
                    let ++DIR_CT
                    echo_mkdir "$MKDIR_RESULT"
                fi
            else
                let ++DIR_CT
                echo_mkdir "[mkdir $DST_DIR]"
            fi
        else
            printf 'Destination dir %s exists, but is not a directory!\n' >&2
            exit 2
        fi
    fi
    for FILE; do
        soft_link "$FILE" "$DST_DIR/$(basename "$FILE")"
    done
}

is_slackware() {
    [[ -e /sbin/installpkg ]]
}

# Install bashrc's
soft_link_all ~ "$DOTFILES/bash"/!(.|..|.bashrc-prompt_lite)

# Install ~/bin
soft_link_all ~/bin "$DOTFILES/home/bin"/*

if is_slackware; then
    # Slackware system - more bins
    soft_link_all ~/bin "$DOTFILES/slackware/bin"/*

    if [[ $UID -eq 0 ]]; then
        soft_link_all ~/bin "$DOTFILES/home/sbin"/*
    fi
fi

# Install git
soft_link_all ~/.config "$DOTFILES/git"

# Install vim
soft_link_all ~ "$DOTFILES/vim"/!(.|..|.bsdvimrc)

# Install misc other files
soft_link_all ~ "$DOTFILES/home"/!(.|..|.fonts|.local|bin|rc.d|sbin)

if [[ $GUI -ne 0 ]]; then
    soft_link "$DOTFILES/font" ~/.font
    soft_link_all ~/.fonts "$DOTFILES/home/.fonts"/!(.|..|.gitignore)
    soft_link_all ~/.local/share/applications "$DOTFILES/home/.local/share/applications"/*
fi

# OPT: ack
if hash ack 2>/dev/null; then
    soft_link_all ~ "$DOTFILES/ack/.ackrc"
fi

# OPT: fluxbox
if hash fluxbox 2>/dev/null; then
    if [[ $GUI -ne 0 ]]; then
        soft_link "$DOTFILES/fluxbox" ~/.fluxbox
    fi
fi

# OPT: ipager
if hash ipager 2>/dev/null; then
    if [[ $GUI -ne 0 ]]; then
        soft_link "$DOTFILES/ipager" ~/.ipager
    fi
fi

# OPT: irssi
if hash irssi 2>/dev/null; then
    soft_link "$DOTFILES/irssi" ~/.irssi
fi

# OPT: newsbeuter
if hash newsbeuter 2>/dev/null; then
    soft_link "$DOTFILES/newsbeuter" ~/.newsbeuter
fi

# OPT: mutt
# (don't link dir, the config repo is meant to be added to with sensitive files)
if hash mutt 2>/dev/null; then
    soft_link_all ~/.mutt "$DOTFILES/mutt"/!(.|..|*.xbm)
fi

# OPT: quakespasm
if hash quakespasm 2>/dev/null; then
    if [[ $GUI -ne 0 ]]; then
        soft_link_all ~/.quakespasm/id1 "$DOTFILES/quakespasm/id1"/*
    fi
fi

# OPT: redshift
if hash redshift 2>/dev/null; then
    if [[ $GUI -ne 0 ]]; then
        soft_link_all ~/.config "$DOTFILES/redshift"/*
    fi
fi

# OPT: stone_soup (crawl)
if hash crawl 2>/dev/null; then
    soft_link "$DOTFILES/stone_soup" ~/.crawl
fi

# OPT: tig
if hash tig 2>/dev/null; then
    soft_link "$DOTFILES/tig" ~/.config/tig
fi

# OPT: tmux
if hash tmux 2>/dev/null; then
    soft_link_all ~ "$DOTFILES/tmux"/*
fi

# OPT: urlview
if hash urlview 2>/dev/null; then
    soft_link_all ~ "$DOTFILES/urlview"/*
fi

# Report
printf '%d links created\n' "$LINK_CT"
printf '%d dirs created\n' "$DIR_CT"
printf '%d items failed\n' "$FAIL_CT"
if [[ $FAIL_CT -gt 0 ]]; then
    exit 2
fi
