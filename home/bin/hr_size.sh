#!/bin/sh

hr_size() {
	local \
		bytes="$1" \
		units \
		fact \
		thresh \
		decimals \
		exp \
		hr_val \
		hr_unit \

	#units=(B KB MB GB TB PB EB ZB YB) # shell math can only go so far...
	units=(B KB MB GB TB)
	fact=1024
	thresh=9/10
	decimals=1

	# cycle through units from largest to smallest, exiting when it finds
	# the largest applicable unit
	for ((exp = ${#units[@]} - 1; exp > -1; --exp)); do
		# check if the unit is close enough to the unit's size, within
		# the threshold
		if [ "$bytes" -gt "$((fact**exp*${thresh}))" ]; then
			# we found the applicable unit

			# must multiply by a factor of 10 here to not truncate
			# the given number of decimal places after thr point
			hr_val="$((bytes*10**decimals/fact**exp))"

			# put the decimal point in
			if [ "$decimals" -gt 0 ]; then
				# left: divide and truncate
				# right: modulus
				hr_val="$((hr_val/10**decimals)).$((hr_val%10**decimals))"
			fi

			hr_unit="${units[$exp]}"
			break
		fi
	done

	if [ -z "$hr_unit" ]; then
		hr_val="$bytes"
		hr_unit="${units[0]}"
	fi

	echo "${hr_val} ${hr_unit}"
}

hr_size "$1"
