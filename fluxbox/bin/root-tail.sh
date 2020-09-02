#!/bin/bash

rt_pid="$(/sbin/pidof 'root-tail' 2>/dev/null)"
if [[ -n "$rt_pid" ]]; then
    echo "root-tail is already running on pid $rt_pid" >&2
    exit 2
fi

# palette
COLOR_LOW_PRIO='#816ff7'
COLOR_MED_PRIO='#30d4bb'
COLOR_HIGH_PRIO='#ff00aa'

rt_opts=(
    '--geometry'    '1600x600+20+20'
    '--noinitial'

    '--font'    '6x10'
    '--outline'

    # split line handling
    '--cont'    '> '
    '--cont-color'  'gray50'

    # immediately fork to the background
    #'--fork'

    # reduce flicker (double buffer?)
    #'--noflicker'
)

logs=(
    # file                          color           label
    # ---------------------------------------------------
    /var/log/secure                 "$COLOR_HIGH_PRIO"      secure
    /var/log/messages               "$COLOR_LOW_PRIO"       messages
    /var/log/debug                  "$COLOR_LOW_PRIO"       debug
    /var/log/Xorg.0.log             "$COLOR_LOW_PRIO"       X

    /var/log/httpd/access_log       "$COLOR_LOW_PRIO"       apache
    /var/log/httpd/error_log        "$COLOR_LOW_PRIO"       apache-errors

    #/var/log/cups/access_log       "$COLOR_LOW_PRIO"       cups
    /var/log/cups/error_log         "$COLOR_MED_PRIO"       cups

    ~/.log/procmail.log             "$COLOR_HIGH_PRIO"      mail
    #~/.log/chatsound.log           "$COLOR_HIGH_PRIO"      chat
    #~/.log/fluxbox.log             "$COLOR_HIGH_PRIO"      fluxbox
    ~/.log/kippo.log                "$COLOR_HIGH_PRIO"      kippo
)

for ((l_idx=0;l_idx<${#logs[@]};l_idx+=3)); do
    log_file="${logs[l_idx]}"
    log_color="${logs[l_idx+1]}"
    log_label="${logs[l_idx+2]}"

    if [[ -r $log_file && ! -d $log_file ]]; then
        # can tail it
        rt_opts+=(
"${log_file}${log_color:+,${log_color}}${log_label:+,${log_label}}"
        )
    else
        echo "cannot read log file \`${log_file}'" >&2
    fi
done

exec root-tail "${rt_opts[@]}"
# vi: ts=4 sts=4 ts=4 et
