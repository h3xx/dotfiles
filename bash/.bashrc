# .bashrc

# aliases and functions
# test for interactive shell
if [[ $- = *i* ]]; then
	# test for login shell
	#if ! shopt -q login_shell; then
	#	# mimic shell login
	#	#exec $SHELL --login
	#	# mimic the behavior of /etc/profile's target functionality, as
	#	# this seems more efficient
	#	# Append any additional sh scripts found in /etc/profile.d/:
	#	for profile_script in /etc/profile.d/*.sh ; do
	#		if [[ -x "$profile_script" ]]; then
	#			. "$profile_script"
	#		fi
	#	done
	#
	#	unset profile_script
	#fi

	# note: .bashrc-screen is near first because it makes SSH connections
	# connect to screen by way of `exec' -- it cuts down on redundant
	# things happening in that case.

	# also: -prompt must be before -screen because -screen modifies $PS1

	for rc_name in \
		prompt \
		screen \
		tty \
		linux \
		slackware{,"-${USER}"} \
		progcomp \
		"${HOSTNAME}"{,"-${USER}"} \
		xterm \
		gpg-agent ; do

		if [[ -f "${HOME}/.bashrc-${rc_name}" ]]; then
			# for figuring out why new prompts lag
			#echo ".bashrc-$rc_name" >&2
			#time . "${HOME}/.bashrc-${rc_name}"
			. "${HOME}/.bashrc-${rc_name}"
		fi
	done

	unset rc_name
fi
