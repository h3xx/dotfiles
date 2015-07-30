# .bashrc

# aliases and functions
# test for interactive shell
if [[ $- = *i* ]]; then
	# note: .bashrc-screen is near first because it makes SSH connections
	# connect to screen by way of `exec' -- it cuts down on redundant
	# things happening in that case.

	# also: -prompt must be before -screen because -screen modifies $PS1

	for RC_NAME in \
		prompt \
		screen \
		tty \
		linux \
		slackware{,"-$USER"} \
		progcomp \
		"$HOSTNAME"{,"-$USER"} \
		xterm \
		gpg-agent \
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
