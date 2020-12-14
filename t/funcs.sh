#!/bin/sh
# vi: et sts=4 sw=4 ts=4

echo_success() {
    printf '[\033[1;32m%s\033[0;39m] %s' \
        '  OK  ' \
        "$(escape_nonprinting "$*")"
}

echo_failure() {
    printf '[\033[1;31m%s\033[0;39m] %s' \
        'FAILED' \
        "$(escape_nonprinting "$*")"
}

echo_warning() {
    printf '[\033[1;33m%s\033[0;39m] %s' \
        'WARNING' \
        "$(escape_nonprinting "$*")"
}

echo_passed() {
    printf '[\033[1;33m%s\033[0;39m] %s' \
        'PASSED' \
        "$(escape_nonprinting "$*")"
}

escape_nonprinting() {
    echo "$*" |cat -v
}
