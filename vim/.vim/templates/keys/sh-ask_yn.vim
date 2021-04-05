" handy yes/no prompt function

append
ask_yn() (
    PROMPT=$1
    DEFAULT=$2
    read -p "$PROMPT [$([[ $DEFAULT = 'y' ]] && echo 'Y/n' || echo 'y/N')]? " ANSWER
    [[ $ANSWER =~ [01NYny] ]] || ANSWER=$DEFAULT
    # return
    [[ $ANSWER =~ [1Yy] ]]
)
.
