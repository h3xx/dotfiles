#!/bin/sh

FUNCTIONS=/etc/init.d/functions

if [ -f "$FUNCTIONS" ]; then
	. $FUNCTIONS
	ECHO=echo
	ECHO_OK="echo_success"
	ECHO_ERROR="echo_failure"
else
	SOURCE_FUNCS=:
	ECHO=echo
	ECHO_OK=:
	ECHO_ERROR=:
fi

if [ "$(realpath -- "$1")" = "$(realpath -- "$2")" ]; then
	err=0
	$ECHO_OK
else
	err=1
	$ECHO_ERROR
fi
$ECHO "$1 => $2"
exit $err
