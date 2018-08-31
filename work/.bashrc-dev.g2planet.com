# vi: ft=sh
# edit this file
HISTIGNORE="${HISTIGNORE:+$HISTIGNORE:}rcl"
alias rcl='vimreal ~/.bashrc-$HOSTNAME'

alias ls='ls --color=auto'

# home is not set correctly
#HOME="/usr/home/$USER"
#cd
export MANPATH="$HOME/.usr/man:$HOME/.usr/share/man:${MANPATH:-$(manpath)}"
FIGNORE='templates_c'
GLOBIGNORE='*~'
# XXX : remove this line when we move away from CVS
#GLOBIGNORE+=':*/CVS:CVS:*/.#*:.#*'
#HISTIGNORE="${HISTIGNORE:+$HISTIGNORE:}cvs up:cvs -n up"

# most visited directories
e=~/erik/smartco/ec/php/eclib/templates
eb=~/erik/brocade/ec/php/eclib/templates

t=~/smartco/php/eclib/templates
p=~/smartco/php/eclib/page
d=~/smartco/php/eclib/database
da=~/smartco/php/eclib/data
u=~/smartco/php/eclib/utility
menu=~/smartco/php/eclib/data/menu.yaml
appconfig=~/smartco/php/eclib/configs/AppConfig.yaml
db=~/smartco/php/emaxlib/eventmax.sql
pj=~pjarosch/public_html/code/smartco/ec/php/eclib

ht=~/hilti/php/templates
hp=~/hilti/php/page
hd=~/hilti/php/database
hda=~/hilti/data
hmenu=~/hilti/data/menu.yaml
happconfig=~/hilti/php/configs/AppConfig.yaml

# system locations
backups=/mnt1/backups/g2planet
www=/usr/local/www/apache22/data
g2p=/usr/local/g2planet

# auto-logout after 5 minutes of being logged in idle
TMOUT=300

export GREP_OPTIONS="${GREP_OPTIONS:+$GREP_OPTIONS }--exclude=*/templates_c/*"

# /tmp is full - fix it Randy!
export TMPDIR=~/.tmp
export PYTHONPATH=~/.usr/lib/python2.7/site-packages
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
	-ddd='sudo make demo pause deletedb createdb restore unpause' \
	t2='ssh t2'

chownerik() {
	sudo chown -R ebloomstrand:www "$@" &&
	sudo find "$@" \( -type f -exec chmod 0666 {} \; \) -o \( -type d -exec chmod 0777 {} \; \)
	#sudo chmod -R 0777 "$@"
}

# ultimate CVS wrapper function
# - pipe cvs log and blame through less(1) [provided we're a terminal]
# - pipe cvs diff through colordiff and less(1) [provided we're a terminal]
# - `cvs new' => give bare filenames of only new (untracked files)
# - `cvs ff' => Update files that can be "safely" updated, i.e. no local changes.
_cvs() {
	case "$1" in
		'log'|'blame')
			if [ -t 1 ]; then
				\cvs "$@" |less
			else
				\cvs "$@"
			fi
			;;
		'diff')
			if [ -t 1 ]; then
				# just like "git diff"
				\cvs "$@" |colordiff |less -R
			else
				\cvs "$@"
			fi
			;;
		'new')
			shift 1
			# sed incantation means "grep for '^? ' and print stuff
			# after it"
			\cvs -n update -A "$@" |sed -e 's/^? //p;d'
			;;
		'm'|'modified')
			shift 1
			# sed incantation means "grep for '...' and print stuff
			# after it"
			\cvs -n update -A "$@"  2>/dev/null |sed -e 's/^[MA] //p;d'
			;;
		'w'|'whatchanged')
			shift 1
			# sed incantation means "grep for '^[?MA] ' and print stuff
			# after it"
			\cvs -n update -A "$@" |sed -e 's/^[?MA] //p;d'
			;;
		'ff')
			shift 1
			\cvs update $(cvs -n update "$@" |sed -e 's/^U //p;d')
			;;
		'stag')
			\cvs up -r `stag` "$@"
			;;
		*)
			\cvs "$@"
			;;
	esac
}
alias cvs=_cvs

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

complete -A hostname host nmap ping traceroute ssh ftp telnet

## chmod
# usefulness: ****
alias \
	privatize='sudo find . \( -type f -exec chmod 0600 {} \; \) -o \( -type d -exec chmod 0700 {} \; \)' \
	publicize='sudo find . \( -type f -exec chmod 0644 {} \; \) -o \( -type d -exec chmod 0755 {} \; \)' \
	ppublicize='sudo find . \( -type f ! -perm +0111 -exec chmod 0644 {} \; \) -o \( \( -type d -o \( -type f -perm +0111 \) \) -exec chmod 0755 {} \; \)' \
	pprivatize='sudo find . \( -type f ! -perm +0111 -exec chmod 0600 {} \; \) -o \( \( -type d -o \( -type f -perm +0111 \) \) -exec chmod 0700 {} \; \)'

MERGE_TARGET=origin/master
