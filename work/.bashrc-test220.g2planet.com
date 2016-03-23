# vi: ft=sh
# edit this file
alias rch='vi ~/.bashrc-$HOSTNAME'

if [[ $TERM = 'screen-256color' ]]; then
	export TERM=xterm-256color
fi

export MANPATH="$HOME/.usr/man:$HOME/.usr/share/man:${MANPATH:-$(manpath)}"
FIGNORE='templates_c'
GLOBIGNORE='*~'
export GITLAB_TOKEN=pysPnUmhNqU7aDaed4Cf

t=~/smartco/php/eclib/templates
p=~/smartco/php/eclib/page
d=~/smartco/php/eclib/database
da=~/smartco/php/eclib/data
u=~/smartco/php/eclib/utility
menu=~/smartco/php/eclib/data/menu.yaml
appconfig=~/smartco/php/eclib/configs/AppConfig.yaml
db=~/smartco/php/emaxlib/eventmax.sql
www=/usr/local/www/apache22/data
g2p=/usr/local/g2planet
export GREP_OPTIONS="${GREP_OPTIONS:+$GREP_OPTIONS }--exclude=*/templates_c/*"
export PYTHONPATH=~/.usr/lib/python2.7/site-packages

# laaaaaaazy
shopt -s \
	cdable_vars

# auto-logout after 30 minutes of being logged in idle
TMOUT=1800
export PAGER='less -R'

alias \
	diff='diff -x CVS -x template_c' \
	iii='sudo make prod pause install unpause' \
	iiii='sudo make demo pause install unpause' \
	ddd='sudo make prod pause backup deletedb createdb restore unpause' \
	dddd='sudo make demo pause backup deletedb createdb restore unpause' \
	-dd='sudo make prod pause deletedb createdb restore unpause' \
	-ddd='sudo make demo pause deletedb createdb restore unpause'

. /usr/local/share/git-core/contrib/completion/git-completion.bash

complete -A hostname host nmap ping traceroute ssh ftp telnet

## chmod
# usefulness: ****
alias \
	privatize='sudo find . \( -type f -exec chmod 0600 {} \; \) -o \( -type d -exec chmod 0700 {} \; \)' \
	publicize='sudo find . \( -type f -exec chmod 0644 {} \; \) -o \( -type d -exec chmod 0755 {} \; \)' \
	ppublicize='sudo find . \( -type f ! -perm +0111 -exec chmod 0644 {} \; \) -o \( \( -type d -o \( -type f -perm +0111 \) \) -exec chmod 0755 {} \; \)' \
	pprivatize='sudo find . \( -type f ! -perm +0111 -exec chmod 0600 {} \; \) -o \( \( -type d -o \( -type f -perm +0111 \) \) -exec chmod 0700 {} \; \)'

