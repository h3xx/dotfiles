#!/bin/bash
OPTS=(
    reconnect
    idmap=user
    cache=yes
    dir_cache=yes
    kernel_cache
    cache_timeout=600
    noatime
    max_conns=4
)
sshfs -o "$(IFS=,; echo "${OPTS[*]}")" dev224-0: /home/dchurch/.sshfs/dchurch@dev224-0.1
