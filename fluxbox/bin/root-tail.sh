#!/bin/bash
# vi: et sts=4 sw=4 ts=4

RT_PID=$(/sbin/pidof 'root-tail' 2>/dev/null)
if [[ -n $RT_PID ]]; then
    printf 'root-tail is already running on pid %d\n' "$RT_PID" >&2
    exit 2
fi

rt_opts=(
    --geometry 800x600+20+20
    --noinitial

    --font 6x10
    --outline

    # Split line handling
    --cont '> '
    --cont-color gray50

    # Immediately fork to the background
    #--fork

    # Reduce flicker (double buffer?)
    #--noflicker
)

logs=(
    # File                          Color           Label
    # ---------------------------------------------------
    /var/log/messages               brown           messages
    /var/log/debug                  brown           debug
    /var/log/secure                 red             secure
    /var/log/acpid                  red             acpid
    /var/log/Xorg.0.log             brown           X

    /var/log/httpd/access_log       orange          apache
    /var/log/httpd/error_log        brown           apache-errors

    /var/lib/mysql/necronomicon.err orange          mysql
    /var/lib/pgsql/serverlog        orange          pgsql

#   /var/log/cups/access_log        brown           cups
    /var/log/cups/error_log         orange          cups

    ~/.log/procmail.log             yellow          mail
#   ~/.log/chatsound.log            yellow          chat
#   ~/.log/fluxbox.log              orange          fluxbox
    ~/.log/kippo.log                red             kippo
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
