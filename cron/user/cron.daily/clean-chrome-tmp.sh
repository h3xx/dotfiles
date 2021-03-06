#!/bin/bash
# clean out stale temporary sockets left behind by google chrome

. ~/.cron/cron.conf

TMP='/tmp'
SOCKET='SingletonSocket'
COOKIE='SingletonCookie'

for tmpdir in \
	"$TMP"/.com.google.[Cc]hrome.?????? \
	"$TMP"/.org.chromium.[Cc]hromium.?????? ; do
	if [[ -d $tmpdir && -w $tmpdir ]]; then
		if [[ ! -e "$tmpdir/$SOCKET" ]] ||
		   ! fuser --silent "$tmpdir/$SOCKET" 2>/dev/null; then

			# not in use -- okay to delete
			rm -rfv -- "$tmpdir" >>"$LOG"

		else
			# may be empty dir; try to delete it
			rmdir --ignore-fail-on-non-empty -- "$tmpdir" >>"$LOG"
		fi
	fi
done

for tmpsocket in \
	"$TMP"/????????????????????????????????????????.[0-9]*_service_ipc ; do
	if ! fuser --silent "$tmpsocket" 2>/dev/null; then
		rm -fv -- "$tmpsocket" >>"$LOG"
	fi
done
