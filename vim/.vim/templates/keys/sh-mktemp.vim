" mktemp invocation for shell scripts

append
="$(mktemp -t "$(basename -- "$0").XXXXXX")"
.
