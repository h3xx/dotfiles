# vi: ft=sh
# edit this file
HISTIGNORE="${HISTIGNORE:+$HISTIGNORE:}rcl"
alias rcl='vimreal ~/.bashrc-$HOSTNAME'

FIGNORE='templates_c'
GLOBIGNORE='*~'

# most visited directories

# system locations
backups=/mnt1/backups/g2planet
www=/usr/local/www/data
g2p=/usr/local/g2planet

# auto-logout after 8 hours of being logged in idle
TMOUT=28800

export BROWSER=lynx

# laaaaaaazy
shopt -s \
	cdable_vars

alias \
	cdf='colordiff |less -R' \
	ddd='sudo make prod pause backup deletedb createdb restore unpause' \
	dddd='sudo make demo pause backup deletedb createdb restore unpause' \
	-dd='sudo make prod pause deletedb createdb restore unpause' \
	-ddd='sudo make demo pause deletedb createdb restore unpause'

# "magic directories" for ssh
# i.e. if you're in a project directory, it'll automatically cd to that directory on the target machine
_ssh() {
	if [[ $# -eq 1 ]]; then
		if [[ $(pwd -P) =~ public_html/code/([^/]+)/ec ]]; then
			echo "Magic directory: ~/${BASH_REMATCH[1]}"
			\ssh -t "$@" "cd ~/${BASH_REMATCH[1]};bash"
		elif [[ $(pwd -P) =~ public_html/code/([^/]+)/([^/]+) ]]; then
			echo "Magic directory: ~/${BASH_REMATCH[2]}"
			\ssh -t "$@" "cd ~/${BASH_REMATCH[2]};bash"
		else
			\ssh "$@"
		fi
	else
		\ssh "$@"
	fi
}
alias ssh=_ssh

if [[ -d ~/.gitrepos ]]; then
	complete -o default -F _gcdcomp gcd
	_gcdcomp() {
        # is it on?
        local nullglob_off="$(shopt -q nullglob || echo 1)"
        shopt -s nullglob
        local repos=(~/.gitrepos/"$2"*.git)
        if [[ -n $nullglob_off ]]; then
            # turn it back off
            shopt -u nullglob
        fi
        repos=("${repos[@]%.git}")
        COMPREPLY=("${repos[@]##*/}")
	}

    gcd() {
        local \
            url="$1" \
            targetdir="$_"

        if [[ -d ~/.gitrepos/"$url".git/objects ]]; then
            # shortcut clone
            GIT_ALTERNATE_OBJECT_DIRECTORIES=~/.gitrepos/"$url".git/objects \
            git clone g2:g2planet/"$url".git &&
            targetdir="$_"
            (cd "$url" && git-alts.sh && (git remote rename origin o ; true)) ||
                return
        elif [[ ! $url =~ : ]]; then
            # I used a shorthand
            git clone "g2:g2planet/$*.git" || return
            targetdir="$_"
        else
            git clone "$@" || return
            targetdir="$_"
        fi

        if [[ -d "$targetdir" ]]; then
            cd "$targetdir"
            return
        fi

        targetdir="$(basename "$targetdir" .git)"
        cd "$targetdir"
    }
fi

complete -A hostname host nmap ping traceroute ssh ftp telnet

# g2clouddb sees databases after -d
if hash g2clouddb 2>/dev/null; then
    complete -o default -F _g2clouddb                g2clouddb
    _g2clouddb() {
        if [[ ${COMP_WORDS[$COMP_CWORD-1]} = '-d' ]]; then
            COMPREPLY=(
                $(g2clouddb list-databases |grep "^$2")
            )
        fi
    }
fi

## chmod
# usefulness: ****
alias \
	privatize='sudo find . \( -type f -exec chmod 0600 {} \; \) -o \( -type d -exec chmod 0700 {} \; \)' \
	publicize='sudo find . \( -type f -exec chmod 0644 {} \; \) -o \( -type d -exec chmod 0755 {} \; \)' \
	ppublicize='sudo find . \( -type f ! -perm /0111 -exec chmod 0644 {} \; \) -o \( \( -type d -o \( -type f -perm /0111 \) \) -exec chmod 0755 {} \; \)' \
	pprivatize='sudo find . \( -type f ! -perm /0111 -exec chmod 0600 {} \; \) -o \( \( -type d -o \( -type f -perm /0111 \) \) -exec chmod 0700 {} \; \)'

# --- Linux server annoyances ---
alias ls='ls --color=auto'
eval `dircolors -b $HOME/.dir_colors`
export LANG=en_US LC_COLLATE=C
