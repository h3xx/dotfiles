" HELP_MESSAGE semi-standard function for shell scripts

append
USAGE() {
    printf 'Usage: %s [OPTIONS] [--] FILE...\n' \
        "${0##*/}"
}

HELP_MESSAGE() {
    USAGE
    cat <<EOF
Lorem ipsum dolor sit amet, consectetur adipiscing.

  -h        Show this help message.
  --        Terminate options list.

Copyright (C) YEAR Dan Church.
.
s/YEAR/\=strftime("%Y")/
append
License GPLv3: GNU GPL version 3.0 (https://www.gnu.org/licenses/gpl-3.0.html)
with Commons Clause 1.0 (https://commonsclause.com/).
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
You may NOT use this software for commercial purposes.
EOF
}
.
