# host-specific bashrc
# vi: ft=sh
HISTIGNORE="${HISTIGNORE:+$HISTIGNORE:}rch"

# edit this file
alias rch='vi ~/.bashrc-$HOSTNAME'

alias \
	slapt-get='sudo /usr/sbin/slapt-get' \
	slap='slapt-get --update && slapt-get --upgrade --no-prompt'

t=~/future/php/eclib/templates
js=~/future/php/eclib/js
te=~/future/php/eclib/tests
p=~/future/php/eclib/page
d=~/future/php/eclib/database
u=~/future/php/eclib/utility
da=~/future/php/eclib/data
appconfig=~/future/php/eclib/configs/AppConfig.yaml
struct=~/future/php/eclib/configs/event_edit_structure.yaml
db=~/g2git/emaxlib/eventmax.sql
menu=~/future/php/eclib/data/menu.yaml
tweaks=~/future/php/eclib/data/tweaks.sql

# so can be reached from vim
export appconfig d da db menu p struct t te tweaks u

ec=~/documents/work/EC2

www=/srv/www/htdocs
steamapps_local=~/.local/share/Steam/steamapps/common

## frequently-edited files
alias \
	fb='$EDITOR ~/.fluxbox/menu' \
	fbk='$EDITOR ~/.fluxbox/keys' \
	t2='ssh t2'

type -t youtube-dl >/dev/null && alias youtube-dl='youtube-dl --audio-quality 6'

# TODO : put these in .bash_profile
export BROWSER=google-chrome
export JAVA_HOME=/usr/lib64/jvm/openjdk-1.8.0_40
export GOPATH=~/.go
export PATH="${PATH:+$PATH:}${JAVA_HOME}/bin:$GOPATH/bin"
#export GIT_ALTERNATE_OBJECT_DIRECTORIES=~/.gitrepos/__objects__

# annoying
_meld() {
	meld "$@" >/dev/null 2>&1 &
}
alias meld=_meld

_ghex() {
	ghex "$@" >/dev/null 2>&1 &
}
alias ghex=_ghex

find_nogit() {
	find "${@:-.}" ! \( -regextype posix-egrep -regex '.*/(\.(svn|git|hg|bzr)|CVS)(/.*)?' \)
}

# laaaazy
shopt -s \
	cdable_vars

# "magic directories" for ssh
# i.e. if you're in a project directory, it'll automatically cd to that directory on the target machine
_ssh() {
	if [[ $# -eq 1 ]]; then
		if [[ $(pwd -P) =~ public_html/code/([^/]+)/ec ]]; then
			echo "Magic directory: ~/${BASH_REMATCH[1]}"
			\ssh -t "$@" "cd ~/${BASH_REMATCH[1]};bash -l"
		elif [[ $(pwd -P) =~ public_html/code/([^/]+)/([^/]+) ]]; then
			echo "Magic directory: ~/${BASH_REMATCH[2]}"
			\ssh -t "$@" "cd ~/${BASH_REMATCH[2]};bash -l"
		else
			\ssh "$@"
		fi
	else
		\ssh "$@"
	fi
}
alias ssh=_ssh

complete -A hostname host nmap ping traceroute ssh ftp telnet

# postgresql support over SSH forwarded port ->dev
alias \
	psql='psql -h localhost -p 5498' \
	youtube-dl-music='youtube-dl -xwt --audio-format vorbis --audio-quality 8'

MERGE_TARGET=origin/master

# trial z
export _Z_NO_RESOLVE_SYMLINKS=1

# trial pgcli
alias pgcli='pgcli -h localhost -p 5498'
complete -o default -F _psqlcomp                pgcli
