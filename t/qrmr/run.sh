#!/bin/bash
# vi: et sts=4 sw=4 ts=4

shopt -s inherit_errexit
set -e

WORKDIR=${0%/*}
. "$WORKDIR/../funcs.sh"
SCRIPT=$(realpath -- "$WORKDIR/../../home/bin/qrmr")
TEMPDIR=$(mktemp -d -t "${0##*/}.XXXXXX")

# Directory list relative to $TEMPDIR
RAINBOW=t/rainbow-of-permissions
UNTRAVERSABLE=t/untraversable
EACH_CASE=(
    "$RAINBOW"
    "$UNTRAVERSABLE"
)

_dir_entry_count() (
    shopt -s nullglob
    ENTRIES=("$1"/*)
    printf '%d\n' "${#ENTRIES[@]}"
)

_prep_dir() (
    _full_delete t

    for PERM in {0..7}{0..7}{0..7}; do
        DIR=$RAINBOW/$PERM
        # Regular file
        install -D -m 0644 /dev/null "$DIR/test-file"
        chmod "0$PERM" "$DIR"
    done

    install -d "$UNTRAVERSABLE/foo/bar"
    chmod 0000 "$UNTRAVERSABLE"
)

_full_delete() (
    for FILE; do
        if [[ -d $FILE ]]; then
            find "$FILE" \
                -type d \
                \( \
                    ! \( -executable -readable \) \
                    -exec chmod +rwx -- {} \; \
                    -o \
                    ! -writable \
                    -exec chmod +w -- {} + \
                \)
        fi
    done
    rm -rf -- "$FILE"
    if [[ -e $FILE ]]; then
        printf '"%s" still exists!\n' \
            "$FILE" \
            >&2
        exit 1
    fi
)
cleanup() {
    # XXX specialized cleanup
    _full_delete "$TEMPDIR"
}
trap 'cleanup' EXIT

test_delete_each() (
    _prep_dir
    # -f: Execute in foreground so we don't have to wait for the script to
    # finish executing
    "$SCRIPT" -f "$1"

    # Ensure the directory was removed
    assert_file_doesnt_exist "$1"
)

test_clean_delete_each() (
    _prep_dir
    T_ENTRIES_BEFORE=$(_dir_entry_count 't')
    ENTRIES_BEFORE=$(_dir_entry_count '.')
    "$SCRIPT" -f "$1"
    T_ENTRIES_AFTER=$(_dir_entry_count 't')
    ENTRIES_AFTER=$(_dir_entry_count '.')

    # Ensure we deleted one entry from 't'
    assert_equals "entries in t:$((T_ENTRIES_BEFORE-1))" "entries in t:$T_ENTRIES_AFTER"
    # Ensure we didn't leave anything nasty in the current directory
    assert_equals "entries in pwd:$ENTRIES_BEFORE" "entries in pwd:$ENTRIES_AFTER"
)

cd "$TEMPDIR"
TEST_COUNT=0
TESTS_PASSED=0
for TESTNAME in \
    test_delete_each \
    test_clean_delete_each \
    ; do

    case "$TESTNAME" in
        *_each)
            for CASE in "${EACH_CASE[@]}"; do
                (( ++TEST_COUNT ))
                if "$TESTNAME" "$CASE"; then
                    echo_success "$TESTNAME ($CASE)"
                    echo
                    (( ++TESTS_PASSED ))
                else
                    echo_failure "$TESTNAME ($CASE) failed"
                    echo
                fi
            done
            ;;

        *)
            (( ++TEST_COUNT ))
            if "$TESTNAME"; then
                echo_success "$TESTNAME"
                echo
                (( ++TESTS_PASSED ))
            else
                echo_failure "$TESTNAME failed"
                echo
            fi
            ;;
    esac

done

cleanup

printf '%d/%d tests passed\n' "$TESTS_PASSED" "$TEST_COUNT"
if [[ $TESTS_PASSED -ne $TEST_COUNT ]]; then
    exit 1
fi
