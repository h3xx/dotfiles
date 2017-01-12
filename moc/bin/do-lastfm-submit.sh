#!/bin/sh

# Purpose:
#
# The perl script doing this before was getting stuck in zombie mode after
# finishing, but only when called from mocp. This seems to be an adequate
# workaround.

~/bin/lastfm-submit "$@"
