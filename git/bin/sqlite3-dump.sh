#!/bin/sh
exec sqlite3 \
    -bail "$1" \
    .dump
