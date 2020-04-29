# host-specific bashrc
# vi: ft=sh
HISTIGNORE="${HISTIGNORE:+$HISTIGNORE:}rcl:a:api"

# edit this file
alias rcl='vimreal ~/.bashrc-$HOSTNAME'

alias \
	slapt-get='sudo /usr/sbin/slapt-get' \
	slap='slapt-get --update && slapt-get --upgrade --no-prompt'

t=~/next/php/eclib/templates
js=~/next/php/eclib/js
te=~/next/php/eclib/tests
p=~/next/php/eclib/page
d=~/next/php/eclib/database
u=~/next/php/eclib/utility
da=~/next/php/eclib/data
#a=~/g2git/smartco-testevent-v2/EMCCv2
a=~/PhpstormProjects/g2planet-sso/site
appconfig=~/next/php/eclib/configs/AppConfig.yaml
struct=~/next/php/eclib/configs/event_edit_structure.yaml
db=~/g2git/emaxlib/eventmax.sql
menu=~/next/php/eclib/data/menu.yaml
tweaks=~/next/php/eclib/data/tweaks.sql
scumm=/usr/share/games/scummvm
dos=/usr/share/games/dos

# so can be reached from vim
export appconfig d da db js menu p struct t te tweaks u

www=/srv/www/htdocs
steamapps_local=~/.local/share/Steam/steamapps/common

## frequently-edited files
alias \
	fb='$EDITOR ~/.fluxbox/menu' \
	fbk='$EDITOR ~/.fluxbox/keys'

alias \
    yiq='yi --silent --no-progress &>/dev/null &'

type -t youtube-dl >/dev/null && alias youtube-dl='youtube-dl --audio-quality 6'

# TODO : put these in .bash_profile
export JAVA_HOME=/usr/lib64/jvm/openjdk
export PATH="$JAVA_HOME/bin:$PATH"
export BROWSER=google-chrome
if [[ -d ~/.go ]]; then
    export GOPATH=~/.go
    export PATH="${PATH:+$PATH:}$GOPATH/bin"
fi
if [[ -d ~/.config/composer/vendor/bin ]]; then
    export PATH="${PATH:+$PATH:}$HOME/.config/composer/vendor/bin"
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
            targetdir=$_ \
            quick_and_dangerous=0
        if [[ $1 = -q ]]; then
            quick_and_dangerous=1
            shift 1
        fi
        local url=$1

        local pcc=~/.gitrepos/$url.git
        local pcc_dangerous=~/g2git/__all_projects__/.git/modules/$url

        if [[ -d $pcc/objects ]]; then
            # shortcut clone
            printf 'Using pre-cloned objects in %s\n' "$pcc" >&2
            git clone --reference "$pcc" "g2:g2planet/$url.git" &&
            targetdir=$_
            (cd "$url" && (git remote rename origin o ; true)) || return
        elif [[ $quick_and_dangerous -ne 0 && -d $pcc_dangerous/objects ]]; then
            printf 'Using pre-cloned objects in %s\n' "$pcc_dangerous" >&2
            git clone --reference "$pcc_dangerous" "g2:g2planet/$url.git" &&
            targetdir=$_
            (cd "$url" && (git remote rename origin o ; true)) || return
        elif [[ ! $url =~ : ]]; then
            # I used a shorthand
            git clone "g2:g2planet/$*.git" || return
            targetdir=$_
        else
            git clone "$@" || return
            targetdir=$_
        fi

        if [[ -d $targetdir ]]; then
            cd "$targetdir"
            return
        fi

        targetdir=$(basename "$targetdir" .git)
        cd "$targetdir"

        # mark known huuuge zipfiles as ignored by git update-index
        if [[ -d data/zipcodes ]]; then
            find data/zipcodes/ -type f -exec git update-index --assume-unchanged {} +
        fi
    }
fi

# annoying
hash ghex && alias ghex='_noout_bg ghex'
hash libreoffice && alias libreoffice='_noout_bg libreoffice'
alias api='gr && if [[ -d api ]]; then cd api; elif [[ -d ../g2p_api ]]; then cd ../g2p_api; else echo "Nope."; false; fi'
alias a='gr && if [[ -d ../EMCCv2 ]]; then cd ../EMCCv2; else cd site; fi'

# laaaazy
shopt -s \
	cdable_vars

complete -A hostname host nmap ping traceroute ssh ftp telnet

# postgresql support over SSH forwarded port ->dev
alias \
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

. /etc/bash_completion.d/yarn

complete -o default -F _psqlcomp                pgcli
