#!/bin/sh
exec sqlite3 \
    -init /dev/null \
    -bail "$1" \
    .dump
