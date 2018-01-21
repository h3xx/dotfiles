#!/bin/bash
# vi: et sts=4 sw=4 ts=4

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

assert_equals() {
    local \
        STARTER=$1 \
        NEXT
    shift 1
    for NEXT; do
        if [[ $STARTER != "$NEXT" ]]; then
            echo_failure "$STARTER does not equal $NEXT"
            echo
            return 1
        fi
        echo_success "$STARTER equals $NEXT"
        echo
    done
}

assert_file_exists() {
    local FN
    for FN; do
        if [[ ! -e $FN ]]; then
            echo_failure "$FN does not exist"
            echo
            return 1
        fi
    done
}

assert_hardlinked() {
    local \
        STARTER=$1 \
        NEXT
    shift 1
    for NEXT; do
        if [[ ! $STARTER -ef $NEXT ]]; then
            echo_failure "$STARTER is not hard-linked to $NEXT"
            echo
            return 1
        fi
        echo_success "$STARTER is hard-linked to $NEXT"
        echo
    done
}

assert_nothardlinked() {
    local \
        STARTER=$1 \
        NEXT
    shift 1
    for NEXT; do
        if [[ $STARTER -ef $NEXT ]]; then
            echo_failure "$STARTER is hard-linked to $NEXT"
            echo
            return 1
        fi
        echo_success "$STARTER is not hard-linked to $NEXT"
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
