#!/bin/sh
# $XConsortium: xinitrc.cpp,v 1.4 91/08/22 11:41:34 rws Exp $

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
	xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
	xmodmap $sysmodmap
fi

if [ -f $userresources ]; then
	xrdb -merge $userresources
fi

if [ -f $usermodmap ]; then
	xmodmap $usermodmap
fi

if [[ -d ~/.font ]]; then
	xset +fp ~/.font
fi

# start gpg-agent (from man page)
#eval $(gpg-agent --daemon)

# Start the window manager:
#if [ -z "$DESKTOP_SESSION" -a -x /usr/bin/ck-launch-session ]; then
#	exec ck-launch-session /usr/bin/startfluxbox
#else
	exec /usr/bin/startfluxbox
#fi
