" mktemp invocation for shell scripts

append
=$(mktemp -t "${0##*/}.XXXXXX")
.
