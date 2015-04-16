#!/bin/bash

# Example start script for a qemu system (windows 7 compatible settings)
#
# Features:
# * detects KVM support

ARCH='x86_64'
CPU='qemu64'
DRIVE_C="${1:-drive_c-playground.qed}"
SWAP='swap.raw'
MEM_MIN=400
HEADLESS=0
VNC_SOCK='localhost:5'

qemu_opts=(
	-cpu "$CPU"

	# networking options
	# vlan=0      : needed for headless mode (good idea anyway)
	# type=virtio : maybe will speed up access?
#	-net	'nic,model=pcnet'
	# win7 has driver for this maybe?
	-net	'nic,model=rtl8139'

	# sound is not important
#	-soundhw ac97

	# this enables native mouse support in vnc mode
	-usbdevice tablet

	# dir => virtual smb share (accessible through 10.0.2.4\qemu)
	# In the guest Windows OS, the line:
	# 10.0.2.4 smbserver
	# must be added to C:\WINDOWS\LMHOSTS or
	# C:\WINNT\SYSTEM32\DRIVERS\ETC\LMHOSTS
	# ... unfortunately, smbd must be configured correctly
#	-net 'user,vlan=0,smb=./smbserver'
	-net user

	#-rtc	'base=utc'	# avoid some weird time discrepancies
	-localtime		# wandows pls
)

if [ -n "$DRIVE_C" ]; then
	qemu_opts+=(
	-drive "file=$DRIVE_C,media=disk"
	)
fi

if [ -n "$SWAP" ]; then
	qemu_opts+=(
	-drive "file=$SWAP,format=raw,media=disk"
	)
fi

if [ -w /dev/kvm ]; then
	qemu_opts+=(
	'-machine' 'type=pc,accel=kvm'
	)
else
	echo "Warning: no KVM support." >&2
fi

if [ -z "$MEMSIZE" ]; then
	total_mem="$(
		free -m |
		grep '^Mem:' |
		sed -e 's,[\t ][\t ]*,\t,g' |
		cut -f 2 |
		tr -dc '0-9'
	)"
	MEMSIZE="$((total_mem/8))"
	if [ "${MEMSIZE:-0}" -lt $MEM_MIN ]; then
		MEMSIZE=$MEM_MIN
	fi
	echo "Setting memory size to ${MEMSIZE}M" >&2
fi

if [ -n "$MEMSIZE" -a "$MEMSIZE" -gt 0 ]; then
	qemu_opts+=(
	'-m'		"$MEMSIZE"
	)
fi

if [ "$HEADLESS" -ne 0 ]; then
	qemu_opts+=(
	-vnc "$VNC_SOCK"
	)
	echo "Start vncviewer $VNC_SOCK"
fi

echo
set -x
exec \
qemu-system-$ARCH "${qemu_opts[@]}" "$@"
