# vi: ft=sh
# edit this file
alias rch='vi ~/.bashrc-$HOSTNAME'

FIGNORE='templates_c'
GLOBIGNORE='*~'

# most visited directories
e=~/erik/smartco/ec/php/eclib/templates
eb=~/erik/brocade/ec/php/eclib/templates

t=~/future/php/eclib/templates
p=~/future/php/eclib/page
d=~/future/php/eclib/database
da=~/future/php/eclib/data
u=~/future/php/eclib/utility
menu=~/future/php/eclib/data/menu.yaml
appconfig=~/future/php/eclib/configs/AppConfig.yaml
tweaks=~/future/php/eclib/data/tweaks.sql
db=~/future/php/emaxlib/eventmax.sql
pj=~pjarosch/public_html/code/future-ec/php/eclib/

# system locations
backups=/mnt1/backups/g2planet
www=/usr/local/www/data
g2p=/usr/local/g2planet

# auto-logout after 5 minutes of being logged in idle
TMOUT=300

export BROWSER=lynx

# laaaaaaazy
shopt -s \
	cdable_vars

alias \
	cdf='colordiff |less -R' \
	ddd='sudo make prod pause backup deletedb createdb restore unpause' \
	dddd='sudo make demo pause backup deletedb createdb restore unpause' \
	-dd='sudo make prod pause deletedb createdb restore unpause' \
	-ddd='sudo make demo pause deletedb createdb restore unpause' \
	t2='ssh t2'

chownerik() {
	sudo chown -R ebloomstrand:www "$@" &&
	sudo find "$@" \( -type f -exec chmod 0666 {} \; \) -o \( -type d -exec chmod 0777 {} \; \)
	#sudo chmod -R 0777 "$@"
}

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

alias as_erik='sudo -u ebloomstrand'

# pipe stuff to this to eliminate shit files we don't care about
alias nogarbage="egrep -v '(~$|/CVS|/templates_c|/\.#)'"

# xclip to local machine
xclip() {
	local ssh_from="${SSH_CONNECTION/ */}"
	\ssh -p 22 "$ssh_from" DISPLAY=:0 xclip -selection clipboard &
}

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

## chmod
# usefulness: ****
alias \
	privatize='sudo find . \( -type f -exec chmod 0600 {} \; \) -o \( -type d -exec chmod 0700 {} \; \)' \
	publicize='sudo find . \( -type f -exec chmod 0644 {} \; \) -o \( -type d -exec chmod 0755 {} \; \)' \
	ppublicize='sudo find . \( -type f ! -perm +0111 -exec chmod 0644 {} \; \) -o \( \( -type d -o \( -type f -perm +0111 \) \) -exec chmod 0755 {} \; \)' \
	pprivatize='sudo find . \( -type f ! -perm +0111 -exec chmod 0600 {} \; \) -o \( \( -type d -o \( -type f -perm +0111 \) \) -exec chmod 0700 {} \; \)'

# --- Linux server annoyances ---
alias ls='ls --color=auto'
eval `dircolors -b $HOME/.dir_colors`
export LANG=en_US LC_COLLATE=C
