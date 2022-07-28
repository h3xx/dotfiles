" check_required_binaries semi-standard function for shell scripts

append
check_required_binaries() {
    local BIN MISSING=()
    for BIN; do
        if ! type -t "$BIN" &>/dev/null; then
            MISSING+=("$BIN")
        fi
    done
    if [[ ${#MISSING[@]} -gt 0 ]]; then
        printf 'Error: You are missing required programs:\n' >&2
        for BIN in "${MISSING[@]}"; do
            printf -- '- %s\n' "$BIN" >&2
        done
        exit 2
    fi
}

.
