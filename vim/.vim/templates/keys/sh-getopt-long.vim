" long option processing structure for shell scripts

append
FILES=()
NO_MORE_FLAGS=0
for ARG; do
    # Assume arguments that don't begin with a - are supposed to be files or other operands
    if [[ $NO_MORE_FLAGS -eq 0 && $ARG = -* ]]; then
        case "$ARG" in
            --foo=*)
                FOO=${ARG#*=}
                ;;
            --help|-h)
                HELP_MESSAGE
                exit 0
                ;;
            --)
                NO_MORE_FLAGS=1
                ;;
            *)
                printf 'Unrecognized flag: %s\n' \
                    "$ARG" \
                    >&2
                USAGE >&2
                exit 2
                ;;
        esac
    else
        FILES+=("$ARG")
    fi
done

.
