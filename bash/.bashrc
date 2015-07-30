# .bashrc

# aliases and functions
# test for interactive shell
if [[ $- = *i* ]]; then
	# note: .bashrc-screen is near first because it makes SSH connections
	# connect to screen by way of `exec' -- it cuts down on redundant
	# things happening in that case.

	# also: -prompt must be before -screen because -screen modifies $PS1

	for rc_name in \
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

		if [[ -f ~/.bashrc-$rc_name ]]; then
			# for figuring out why new prompts lag
			#echo ".bashrc-$rc_name" >&2
			#time . ~/".bashrc-$rc_name"
			. ~/".bashrc-$rc_name"
		fi
	done

	unset rc_name
fi
