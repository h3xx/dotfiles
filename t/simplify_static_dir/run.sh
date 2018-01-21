#!/bin/bash
# vi: et sts=4 sw=4 ts=4 fdm=marker fdl=-1

SCRIPT=../../home/bin/simplify_static_dir.pl

# {{{echo funcs
echo_success() {
    printf '[\033[1;32m%s\033[0;39m] %s' \
        '  OK  ' \
        "$*"
}

echo_failure() {
    printf '[\033[1;31m%s\033[0;39m] %s' \
        'FAILED' \
        "$*"
}

echo_warning() {
    printf '[\033[1;33m%s\033[0;39m] %s' \
        'WARNING' \
        "$*"
}

echo_passed() {
    printf '[\033[1;33m%s\033[0;39m] %s' \
        'PASSED' \
        "$*"
}
# }}}

assert_equals() {
    local \
        starter=$1 \
        next
    shift 1
    for next; do
        if [[ $starter != $next ]]; then
            echo_failure "$starter does not equal $next"
            echo
            return 1
        fi
        echo_success "$starter equals $next"
        echo
    done
}

assert_file_exists() {
    local fn
    for fn; do
        if [[ ! -e $fn ]]; then
            echo_failure "$fn does not exist"
            echo
            return 1
        fi
    done
}

assert_hardlinked() {
    local \
        starter=$1 \
        next
    shift 1
    for next; do
        if [[ ! $starter -ef $next ]]; then
            echo_failure "$starter is not hard-linked to $next"
            echo
            return 1
        fi
        echo_success "$starter is hard-linked to $next"
        echo
    done
}

assert_nothardlinked() {
    local \
        starter=$1 \
        next
    shift 1
    for next; do
        if [[ $starter -ef $next ]]; then
            echo_failure "$1 is hard-linked to $2"
            echo
            return 1
        fi
        echo_success "$1 is not hard-linked to $2"
        echo
    done
}

assert_older_than() {
    if [[ $1 -ot $2 ]]; then
        echo_failure "$1 is older than $2"
        echo
        return 1
    fi
    echo_success "$1 is not older than $2"
    echo
}

_prep_tar() {
    rm -rf t &&
    tar xf t.tar
}
_cleanup() {
    rm -rf t
}

test_normal_linkage() {
    _prep_tar &&
    $SCRIPT t || return 2
    local \
        file1=t/normal/foo/same \
        file2=t/normal/same
    assert_file_exists $file1 $file2 &&
    assert_hardlinked $file1 $file2
}

test_normal_nonlinkage() {
    _prep_tar &&
    $SCRIPT t || return 2
    local \
        file1=t/normal/foo/same \
        file2=t/normal/not-same
    assert_file_exists $file1 $file2 &&
    assert_nothardlinked $file1 $file2
}

test_sha1collision_nonlinkage() {
    _prep_tar &&
    $SCRIPT t || return 2
    local \
        file1=t/sha1-collision/shattered-1.pdf \
        file2=t/sha1-collision/shattered-2.pdf
    assert_file_exists $file1 $file2 &&
    assert_nothardlinked $file1 $file2
}

test_zero_size_nonlinkage() {
    _prep_tar &&
    $SCRIPT t || return 2
    local \
        file1=t/zero-size/empty1 \
        file2=t/zero-size/empty2
    assert_file_exists $file1 $file2 &&
    assert_nothardlinked $file1 $file2
}

test_link_counting() {
    _prep_tar &&
    $SCRIPT t || return 2
    local files=(
        t/link-counting/{most-links,second-most-links}
    )
    assert_file_exists "${files[@]}" &&
    assert_hardlinked ${files[0]} ${files[1]}
}

test_timestamp_preservation() {
    _prep_tar &&
    $SCRIPT t || return 2
    local \
        file1=t/timestamp-preservation/newer-more-linked \
        file2=t/timestamp-preservation/older-less-linked
    assert_file_exists $file1 $file2 &&
    assert_hardlinked $file1 $file2 &&
    assert_older_than $file2 $file1
}

test_freed_bytes() {
    _prep_tar &&
    local out=$($SCRIPT -f t/freed-bytes{,,} 2>&1 |tail -1)
    local files=(
        t/freed-bytes/{1,2,3,4}
    )
    assert_file_exists "${files[@]}" &&
    assert_equals "$out" "freed 24 bytes (24 B)"
}

test_count=0
tests_passed=0
for testname in \
    test_normal_linkage \
    test_normal_nonlinkage \
    test_sha1collision_nonlinkage \
    test_zero_size_nonlinkage \
    test_link_counting \
    test_timestamp_preservation \
    test_freed_bytes \
    ; do

    let test_count++
    if $testname; then
        let tests_passed++
    else
        echo_failure "$testname failed"
        echo
    fi

done

_cleanup

printf '%d/%d tests passed\n' $tests_passed $test_count
if [[ $tests_passed -ne $test_count ]]; then
    exit 1
fi
