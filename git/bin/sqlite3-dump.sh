#!/bin/sh
exec sqlite3 \
    -init '' \
    -bail "$1" \
    .dump
