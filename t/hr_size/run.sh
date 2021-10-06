#!/bin/bash
# vi: et sts=4 sw=4 ts=4

WORKDIR=${0%/*}
SCRIPT=$WORKDIR/../../home/bin/hr_size.sh
. "$WORKDIR/../funcs.sh"

CASES=(
    1 '1 B'
    1234 '1.2 KB'
    12340 '12 KB'
    14440 '14.1 KB'
)

test_cases() {
    local \
        IN=$1 \
        EXPECTED_OUT=$2
    local -r OUT=$($SCRIPT "$IN" 2>&1)
    assert_equals "$EXPECTED_OUT" "$OUT"
}

TEST_COUNT=0
TESTS_PASSED=0
for TESTNAME in \
    test_cases \
    ; do

    case "$TESTNAME" in
        test_cases)
            for (( I = 0; I < ${#CASES[@]}; I += 2)); do
                (( TEST_COUNT++ ))
                IN=${CASES[$I]}
                EXPECTED_OUT=${CASES[$(( I + 1 ))]}
                if $TESTNAME "$IN" "$EXPECTED_OUT"; then
                    (( TESTS_PASSED++ ))
                else
                    echo_failure "$TESTNAME failed"
                    echo
                fi
            done
            ;;
        *)
            (( TEST_COUNT++ ))
            if $TESTNAME; then
                (( TESTS_PASSED++ ))
            else
                echo_failure "$TESTNAME failed"
                echo
            fi
            ;;
    esac

done

printf '%d/%d tests passed\n' "$TESTS_PASSED" "$TEST_COUNT"
if [[ $TESTS_PASSED -ne $TEST_COUNT ]]; then
    exit 1
fi
