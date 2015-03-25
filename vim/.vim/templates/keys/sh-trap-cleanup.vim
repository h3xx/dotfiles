" exit cleanup process for shell scripts

append
TEMP_FILES=()

cleanup() {
	rm -f -- "${TEMP_FILES[@]}"
}

trap 'cleanup'	EXIT
.
