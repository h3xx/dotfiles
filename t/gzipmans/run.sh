#!/bin/bash
# vi: et sts=4 sw=4 ts=4

WORKDIR=${0%/*}
. "$WORKDIR/../funcs.sh"
SCRIPT=$(realpath -- "$WORKDIR/../../slackware/bin/gzipmans")
TAR=$(realpath -- "$WORKDIR/t.tar")
TEMPDIR=$(mktemp -d -t "${0##*/}.XXXXXX")

_prep_tar() {
    rm -rf t &&
    tar xf "$TAR"
}
cleanup() {
    rm -rf -- "$TEMPDIR"
}
trap 'cleanup' EXIT

assert_gzipped() (
    GZIP_MIMETYPE='application/gzip'
    assert_file_has_mimetype "$GZIP_MIMETYPE" "$@"
)

assert_not_gzipped() (
    PLAIN_MIMETYPE='text/plain'
    assert_file_has_mimetype "$PLAIN_MIMETYPE" "$@"
)

test_normal_zippage() {
    _prep_tar &&
    "$SCRIPT" t/normal || return 2
    local -r \
        FILE1=t/normal/usr/man/man1/hello.1 \
        FILE2=t/normal/usr/man/man1/world.1
    assert_file_doesnt_exist "$FILE1" "$FILE2" &&
    assert_file_exists "$FILE1.gz" "$FILE2.gz" &&
    assert_gzipped "$FILE1.gz" "$FILE2.gz"
}

# Test whether the directories given exclude other directories, i.e. "gzipmans
# dir1" leaves files alone in "dir2"
test_exclusion() {
    _prep_tar &&

    cp -a t/normal t/excluded &&
    "$SCRIPT" t/normal || return 2
    local -r \
        EX_FILE1=t/excluded/usr/man/man1/hello.1 \
        EX_FILE2=t/excluded/usr/man/man1/world.1
    assert_file_exists "$EX_FILE1" "$EX_FILE2" &&
    assert_file_doesnt_exist "$EX_FILE1.gz" "$EX_FILE2.gz" &&
    assert_not_gzipped "$EX_FILE1" "$EX_FILE2"
}

test_linkage() {
    _prep_tar &&
    "$SCRIPT" t/links || return 2
    local -r \
        FILE1=t/links/man1/hello.1 \
        LINK=t/links/man1/link.1
    assert_file_exists "$FILE1.gz" &&
    assert_file_is_symlink "$LINK.gz" &&
    assert_file_is_symlink_to "$FILE1.gz" "$LINK.gz"
}

cd "$TEMPDIR" || exit
TEST_COUNT=0
TESTS_PASSED=0
for TESTNAME in \
    test_normal_zippage \
    test_exclusion \
    test_linkage \
    ; do

    (( TEST_COUNT++ ))
    if "$TESTNAME"; then
        echo_success "$TESTNAME"
        echo
        (( TESTS_PASSED++ ))
    else
        echo_failure "$TESTNAME failed"
        echo
    fi

done

cleanup

printf '%d/%d tests passed\n' "$TESTS_PASSED" "$TEST_COUNT"
if [[ $TESTS_PASSED -ne $TEST_COUNT ]]; then
    exit 1
fi
