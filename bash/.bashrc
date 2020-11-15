# .bashrc

# aliases and functions
# test for interactive shell
if [[ $- = *i* ]]; then
	for RC_NAME in \
		promptgen \
		gpg-agent \
		tty \
		linux \
		slackware{,"-$USER"} \
		progcomp \
		"$HOSTNAME"{,"-$USER"} \
		xterm \
		; do

		if [[ -f ~/.bashrc-$RC_NAME ]]; then
			# for figuring out why new prompts lag
			#echo ".bashrc-$RC_NAME" >&2
			#time . ~/".bashrc-$RC_NAME"
			. ~/".bashrc-$RC_NAME"
		fi
	done

	unset RC_NAME
fi
