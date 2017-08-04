# .bashrc

# aliases and functions
# test for interactive shell
if [[ $- = *i* ]]; then
	for rc_name in \
		prompt \
		gpg-agent \
		tty \
		linux \
		slackware{,"-$USER"} \
		progcomp \
		"$HOSTNAME"{,"-$USER"} \
		xterm \
		; do

		if [[ -f ~/.bashrc-$rc_name ]]; then
			# for figuring out why new prompts lag
			#echo ".bashrc-$rc_name" >&2
			#time . ~/".bashrc-$rc_name"
			. ~/".bashrc-$rc_name"
		fi
	done

	unset rc_name
fi
