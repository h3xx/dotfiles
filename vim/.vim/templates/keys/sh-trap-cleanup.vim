" exit cleanup process for shell scripts

append
TEMP_DIR=$(mktemp -d -t "${0##*/}.XXXXXX")
cleanup() {
    rm -fr -- "$TEMP_DIR"
}
trap 'cleanup' EXIT
.
