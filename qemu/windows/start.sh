#!/bin/bash
# vi: et sts=4 sw=4 ts=4

# Example start script for a qemu system (windows 7 compatible settings)
#
# Features:
# * detects KVM support

ARCH='x86_64'
CPU='qemu64'
DRIVE_C=${1:-drive_c-playground.qed}
SWAP='swap.raw'
MEM_MIN=400
HEADLESS=0
VNC_SOCK='localhost:5'

QEMU_OPTS=(
    -cpu "$CPU"

    # networking options
    # vlan=0      : needed for headless mode (good idea anyway)
    # type=virtio : maybe will speed up access?
    #-net 'nic,model=pcnet'
    # win7 has driver for this maybe?
    -net 'nic,model=rtl8139'

    # sound is not important
    #-soundhw ac97

    # this enables native mouse support in vnc mode
    -usbdevice tablet

    # dir => virtual smb share (accessible through 10.0.2.4\qemu)
    # In the guest Windows OS, the line:
    # 10.0.2.4 smbserver
    # must be added to C:\WINDOWS\LMHOSTS or
    # C:\WINNT\SYSTEM32\DRIVERS\ETC\LMHOSTS
    # ... unfortunately, smbd must be configured correctly
    #-net 'user,vlan=0,smb=./smbserver'
    -net user

    # avoid some weird time discrepancies
    #-rtc   'base=utc'
    # Wandows pls
    -localtime
)

if [[ -n $DRIVE_C ]]; then
    QEMU_OPTS+=(
        -drive "file=$DRIVE_C,media=disk"
    )
fi

if [[ -n $SWAP ]]; then
    QEMU_OPTS+=(
        -drive "file=$SWAP,format=raw,media=disk"
    )
fi

if [[ -w /dev/kvm ]]; then
    QEMU_OPTS+=(
        -machine 'type=pc,accel=kvm'
    )
else
    printf 'Warning: no KVM support.\n' \
        >&2
fi

if [[ -z $MEMSIZE ]]; then
    TOTAL_MEM=$(
        free -m |
        grep '^Mem:' |
        sed -e 's,[\t ][\t ]*,\t,g' |
        cut -f 2 |
        tr -dc '0-9'
    )
    MEMSIZE=$(( TOTAL_MEM / 8 ))
    if [[ ${MEMSIZE:-0} -lt $MEM_MIN ]]; then
        MEMSIZE=$MEM_MIN
    fi
    printf 'Setting memory size to %sm\n' \
        "$MEMSIZE" \
        >&2
fi

if [[ -n $MEMSIZE && $MEMSIZE -gt 0 ]]; then
    QEMU_OPTS+=(
        '-m' "$MEMSIZE"
    )
fi

if [[ $HEADLESS -ne 0 ]]; then
    QEMU_OPTS+=(
        -vnc "$VNC_SOCK"
    )
    printf 'Start vncviewer %s\n' \
        "$VNC_SOCK" \
        >&2
fi

echo
set -x
exec \
"qemu-system-$ARCH" \
    "${QEMU_OPTS[@]}" \
    "$@"
