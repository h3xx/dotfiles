" mktemp invocation for shell scripts

append
=$(mktemp -p "$TEMP_DIR" -t 'file.XXXXXX')
.
