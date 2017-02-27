# vi: ft=sh
# edit this file
alias rch='vi ~/.bashrc-$HOSTNAME'

FIGNORE='templates_c'
GLOBIGNORE='*~'

# system locations
www=/usr/local/www/data
g2p=/usr/local/g2planet

# auto-logout after 5 minutes of being logged in idle
TMOUT=300

# --- Linux server annoyances ---
alias ls='ls --color=auto'
alias make='bmake'
eval `dircolors -b $HOME/.dir_colors`
export LANG=en_US LC_COLLATE=C
