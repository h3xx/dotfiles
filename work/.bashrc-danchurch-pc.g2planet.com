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
scumm=/usr/share/games/scummvm

# so can be reached from vim
export appconfig d da db js menu p struct t te tweaks u

www=/srv/www/htdocs
steamapps_local=~/.local/share/Steam/steamapps/common

## frequently-edited files
alias \
	fb='$EDITOR ~/.fluxbox/menu' \
	fbk='$EDITOR ~/.fluxbox/keys' \
	t2='ssh t2'

type -t youtube-dl >/dev/null && alias youtube-dl='youtube-dl --audio-quality 6'

# TODO : put these in .bash_profile
export JAVA_HOME=/usr/lib64/jvm/openjdk
export PATH="$JAVA_HOME/bin:$PATH"
export BROWSER=google-chrome
if [[ -d ~/.go ]]; then
    export GOPATH=~/.go
    export PATH="${PATH:+$PATH:}$GOPATH/bin"
fi
#export GIT_ALTERNATE_OBJECT_DIRECTORIES=~/.gitrepos/__objects__

# quicker cloning
# `gcd eclib` => much quicker
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
            git clone --reference ~/.gitrepos/"$url".git g2:g2planet/"$url".git &&
            targetdir="$_"
            (cd "$url" && (git remote rename origin o ; true)) ||
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

# annoying
hash ghex && alias ghex='_noout_bg ghex'
hash libreoffice && alias libreoffice='_noout_bg libreoffice'

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
	psql='LC_ALL=en_US.utf8 psql -h localhost -p 5498' \
	youtube-dl-music='youtube-dl -xwt --audio-format vorbis --audio-quality 8'

MERGE_TARGET=origin/master

export PERL5LIB=~/perl5/lib/perl5

# progcomp for myopic programs

complete -o default -F _cross_project_grep cross-project-grep
_cross_project_grep() {
    local opts=(
        --no-tests
        --all
    ) \
        opt
    for opt in "${opts[@]}"; do
        # wacky but fast syntax that tests if opt begins with the input
        if [[ ${opt:0:${#2}} = $2 ]]; then
            COMPREPLY+=(
                "$opt"
            )
        fi
    done
}

complete -o default -F _gcd gcd
_gcd() {
    if [[ -d ~/g2git/__all_projects__ ]]; then
        COMPREPLY=(
            $(
                cd ~/g2git/__all_projects__ &&
                compgen -G "$2*" "$2"
            )
        )
    fi
}

# trial z
export _Z_NO_RESOLVE_SYMLINKS=1

# trial pgcli
alias pgcli='pgcli -h localhost -p 5498'
complete -o default -F _psqlcomp                pgcli
