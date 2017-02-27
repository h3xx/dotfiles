# vi: ft=sh
# edit this file
alias rch='vi ~/.bashrc-$HOSTNAME'

FIGNORE='templates_c'
GLOBIGNORE='*~'

# most visited directories

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
	diff='diff -x CVS -x template_c' \
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

alias as_erik='sudo -u ebloomstrand'

complete -A hostname host nmap ping traceroute ssh ftp telnet

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
