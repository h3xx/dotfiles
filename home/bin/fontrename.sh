#!/bin/bash
# vi: et sts=4 sw=4 ts=4

USAGE() {
    printf 'Usage: %s [OPTIONS] [--] FILE...\n' \
        "${0##*/}"
}

HELP_MESSAGE() {
    USAGE
    cat <<EOF
Auto-rename font files according to the font's canonical name.

  -h    Show this help message.

Copyright (C) 2011-2017 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
}

while getopts 'h' FLAG; do
    case "$FLAG" in
        'h')
            HELP_MESSAGE
            exit 0
            ;;
        *)
            printf 'Unrecognized flag: %s\n' \
                "$FLAG" \
                >&2
            USAGE >&2
            exit 1
            ;;
    esac
done

shift "$((OPTIND-1))"

TEMP_FILES=()

cleanup() {
    rm -rf -- "${TEMP_FILES[@]}"
}

trap 'cleanup' EXIT

# prints out the simple mimetype (e.g. `image/jpeg') of a file's contents
get_mimetype() {
    file \
        --preserve-date \
        --dereference \
        --brief \
        --mime-type \
        -- \
        "$@" \
        2>/dev/null
}

fontname() {
    local \
        FONT=$1 \
        MIMETYPE \
        TEMPDIR

    MIMETYPE=$(get_mimetype "$FONT")
    case "$MIMETYPE" in

        'application/font-sfnt'|'application/x-font-ttf')
            # XXX : for some reason, ttf2afm requires a .ttf file
            #   extension, so the creation of a temporary
            #   symlink is necessary

            TEMPDIR=$(mktemp -d -t "${0##*/}.XXXXXX")
            TEMP_FILES+=("$TEMPDIR")

            ln -sf -- "$(realpath -- "$FONT")" "$TEMPDIR/foo.ttf" &&

            # XXX : segfaulting ttf2afm needs this to die safely
            (trap 'true' ERR; exec ttf2afm -- "$TEMPDIR/foo.ttf") |
            grep -- '^FullName ' |
            cut -f 2- -d ' ' |
            head -1

            return

            # XXX : code for when/if ttf2afm is ever fixed so that
            #   it doesn't require a .ttf file extension

            #ttf2afm -- "$FONT" |
            #grep -- '^FullName ' |
            #cut -f 2- -d ' ' |
            #head -1

            ;;

        # FIXME : file(1) may be reporting the wrong mimetype the long
        #     filetype is "ASCII font metrics"
        'text/x-fortran'|'text/plain'*)
            grep -- '^FullName ' "$FONT" |
            cut -f 2- -d ' ' |
            head -1

            return
            ;;

        *)
            printf 'Unsupported font mimetype: %s\n' \
                "$MIMETYPE" \
                >&2
            return 1
            ;;
    esac

}

# prints the file extension--including the period--for a given font file, based
# on that file's detected mimetype (via file(1))
#
# supports:
#   application/x-font-ttf      (truetype => `.ttf')
#   application/x-font-type1    (adobe => `.afm') -- often mis-typed as text/x-fotran
#   application/vnd.ms-opentype (opentype => `.otf')
#   application/x-font-woff     (woff => `.woff')
#   application/vnd.ms-fontobject   (m$ eot file => `.eot')
#
# arguments:
#   $1: the font file
fontext() {
    local \
        FONT=$1 \
        MIMETYPE

    MIMETYPE=$(get_mimetype "$FONT")
    case "$MIMETYPE" in

        'application/font-sfnt'|'application/x-font-ttf')
            echo '.ttf'
            return 0
            ;;

        # FIXME : file(1) is probably reporting the wrong mimetype
        #     the long filetype is "ASCII font metrics"
        'application/x-font-type1'|'text/x-fortran'|'text/plain'*)
            echo '.afm'
            return 0
            ;;

        'application/vnd.ms-opentype')
            echo '.otf'
            return 0
            ;;

        'application/x-font-woff')
            echo '.woff'
            return 0
            ;;

        'application/vnd.ms-fontobject')
            echo '.eot'
            return 0
            ;;

        *)
            printf 'Unsupported font mimetype: %s\n' \
                "$MIMETYPE" \
                >&2
            return 1
            ;;
    esac

}

rename_font() {
    local \
        FONT \
        EXT \
        FONTBASE \
        FONTDIR \
        NAME \
        TARGET

    for FONT; do
        NAME=$(fontname "$FONT")
        EXT=$(fontext "$FONT")
        FONTBASE=$(basename -- "$FONT")
        FONTDIR=$(dirname -- "$FONT")
        TARGET=$FONTDIR/$NAME$EXT
        if [[ -z $NAME ]]; then
            printf 'Cannot rename font %s: no full name found\n' \
                "$FONT" \
                >&2
        elif [[ -z $EXT ]]; then
            printf 'Cannot rename font %s: no extension\n' \
                "$FONT" \
                >&2
        elif [[ $FONTBASE = "$NAME$EXT" ]]; then
            printf 'Font %s already renamed\n' \
                "$FONT" \
                >&2
        elif [[ -e $TARGET ]]; then
            printf 'Cannot rename font %s: %s already exists\n' \
                "$FONT" \
                "$TARGET" \
                >&2
        else
            mv -v -- "$FONT" "$TARGET"
        fi
    done
}

rename_font "$@"
