#!/bin/bash
# vi: et sts=4 sw=4 ts=4

WORKDIR=${0%/*}
. "$WORKDIR/../funcs.sh"
SCRIPT=$(realpath -- "$WORKDIR/../../home/bin/simplify_static_dir.pl")
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

test_normal_linkage() {
    _prep_tar &&
    $SCRIPT t || return 2
    local \
        FILE1=t/normal/foo/same \
        FILE2=t/normal/same
    assert_file_exists $FILE1 $FILE2 &&
    assert_hardlinked $FILE1 $FILE2
}

test_normal_nonlinkage() {
    _prep_tar &&
    $SCRIPT t || return 2
    local \
        FILE1=t/normal/foo/same \
        FILE2=t/normal/not-same
    assert_file_exists $FILE1 $FILE2 &&
    assert_nothardlinked $FILE1 $FILE2
}

test_sha1collision_nonlinkage() {
    _prep_tar &&
    $SCRIPT t || return 2
    local \
        FILE1=t/sha1-collision/shattered-1.pdf \
        FILE2=t/sha1-collision/shattered-2.pdf
    assert_file_exists $FILE1 $FILE2 &&
    assert_nothardlinked $FILE1 $FILE2
}

test_zero_size_nonlinkage() {
    _prep_tar &&
    $SCRIPT t || return 2
    local \
        FILE1=t/zero-size/empty1 \
        FILE2=t/zero-size/empty2
    assert_file_exists $FILE1 $FILE2 &&
    assert_nothardlinked $FILE1 $FILE2
}

test_link_counting() {
    _prep_tar &&
    $SCRIPT t || return 2
    local FILES=(
        t/link-counting/{most-links,second-most-links}
    )
    assert_file_exists "${FILES[@]}" &&
    assert_hardlinked ${FILES[0]} ${FILES[1]}
}

test_timestamp_preservation() {
    _prep_tar &&
    $SCRIPT t || return 2
    local \
        FILE1=t/timestamp-preservation/newer-more-linked \
        FILE2=t/timestamp-preservation/older-less-linked
    assert_file_exists $FILE1 $FILE2 &&
    assert_hardlinked $FILE1 $FILE2 &&
    assert_older_than $FILE2 $FILE1
}

test_freed_bytes() {
    _prep_tar &&
    local OUT=$($SCRIPT -f t/freed-bytes{,,} 2>&1 |tail -1)
    local FILES=(
        t/freed-bytes/{1,2,3,4}
    )
    assert_file_exists "${FILES[@]}" &&
    assert_equals "$OUT" "freed 24 bytes (24 B)"
}

cd "$TEMPDIR"
TEST_COUNT=0
TESTS_PASSED=0
for TESTNAME in \
    test_normal_linkage \
    test_normal_nonlinkage \
    test_sha1collision_nonlinkage \
    test_zero_size_nonlinkage \
    test_link_counting \
    test_timestamp_preservation \
    test_freed_bytes \
    ; do

    let TEST_COUNT++
    if $TESTNAME; then
        let TESTS_PASSED++
    else
        echo_failure "$TESTNAME failed"
        echo
    fi

done

cleanup

printf '%d/%d tests passed\n' $TESTS_PASSED $TEST_COUNT
if [[ $TESTS_PASSED -ne $TEST_COUNT ]]; then
    exit 1
fi
